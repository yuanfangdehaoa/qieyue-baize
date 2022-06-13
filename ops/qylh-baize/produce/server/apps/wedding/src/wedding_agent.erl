%% @author rong
%% @doc
-module(wedding_agent).

-behaviour(gen_server).

-include("game.hrl").
-include("table.hrl").
-include("proto.hrl").
-include("errno.hrl").
-include("wedding.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("msgno.hrl").

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/1]).
-export([invite/2, add_invite/1]).
-export([invite_request/2, request_accept/2, request_refuse/2]).
-export([start_wedding/1, stop_wedding/1]).

-record(state, {start_time, end_time, couple=[]}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link(Wedding) ->
    gen_server:start_link(?MODULE, Wedding, []).

invite(Pid, InviteID) ->
    gen_server:call(Pid, {invite, InviteID}).

add_invite(Pid) ->
    gen_server:call(Pid, add_invite).

invite_request(Pid, RoleID) ->
    gen_server:call(Pid, {invite_request, RoleID}).

request_accept(Pid, IDs) ->
    gen_server:call(Pid, {request_accept, IDs}).

request_refuse(Pid, IDs) ->
    gen_server:call(Pid, {request_refuse, IDs}).

start_wedding(Pid) ->
    gen_server:cast(Pid, start_wedding).

stop_wedding(Pid) ->
    gen_server:cast(Pid, stop_wedding).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(Wedding) ->
    process_flag(trap_exit, true),
    {ok, #state{
        start_time = element(1, Wedding#wedding.time),
        end_time   = element(2, Wedding#wedding.time),
        couple     = Wedding#wedding.couple
    }}.

handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
    ?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call({invite, InviteID}, _From, State) ->
    #wedding{invite=Invite, add=Add, couple=Couple} = Wedding = wedding_ets:get(key(State)),
    ?_check(not lists:member(InviteID, Invite), ?ERR_WEDDING_ALREADY_INVITE),
    ?_check(not lists:member(InviteID, Couple), ?ERR_WEDDING_ALREADY_INVITE),
    ?_check(length(Invite) < cfg_marriage:invite() + Add, ?ERR_WEDDING_MAX_INVITE),
    Guest = role:get_base(InviteID),
    wedding_ets:set(Wedding#wedding{invite=[InviteID|Invite]}),
    bc(#m_wedding_guest_invite_toc{guest=Guest}, State),
    send_accept_mail(InviteID, State),
    {reply, ok, State};

do_handle_call(add_invite, _From, State) ->
    #wedding{add=Add} = Wedding = wedding_ets:get(key(State)),
    wedding_ets:set(Wedding#wedding{add=Add+1}),
    InviteMax = cfg_marriage:invite(),
    {reply, {ok, InviteMax+Add+1}, State};

do_handle_call({invite_request, RoleID}, _From, State) ->
    #wedding{invite=Invite, request=Request} = Wedding = wedding_ets:get(key(State)),
    ?_check(not lists:member(RoleID, Invite), ?ERR_WEDDING_NO_NEED_REQUEST),
    ?_check(not lists:member(RoleID, Request), ?ERR_WEDDING_ALREADY_REQUEST),
    wedding_ets:set(Wedding#wedding{request=[RoleID|Request]}),
    bc(#m_wedding_invitation_apply_toc{guest=role:get_base(RoleID)}, State),
    {reply, ok, State};

do_handle_call({request_accept, IDs}, _From, State) ->
    #wedding{request=Request, add=Add, invite=Invite} = Wedding = wedding_ets:get(key(State)),
    Max = Add + cfg_marriage:invite(),
    Remain = max(0, Max - length(Invite)),
    ?_check(Remain > 0, ?ERR_WEDDING_INVITE_MAX),
    Invite2 = lists:sublist(IDs, Remain),
    [send_accept_mail(ID, State) || ID <- Invite2],
    wedding_ets:set(Wedding#wedding{request=Request--Invite2, invite=Invite2 ++ Invite}),
    bc(#m_wedding_invitation_request_accept_toc{ids=Invite2}, State),
    {reply, ok, State};

do_handle_call({request_refuse, ID}, _From, State) ->
    #wedding{request=Request} = Wedding = wedding_ets:get(key(State)),
    wedding_ets:set(Wedding#wedding{request=lists:delete(ID, Request)}),
    bc(#m_wedding_invitation_request_refuse_toc{id=ID}, State),
    {reply, ok, State};

do_handle_call(Req, _From, State) ->
    ?error("unhandle cast: ~p", [Req]),
    {reply, {error, unknown_call}, State}.

do_handle_cast(start_wedding, State) ->
    #state{couple=[ID1, ID2]} = State,
    {ok, #role_cache{name=Name1}} = role:get_cache(ID1),
    {ok, #role_cache{name=Name2}} = role:get_cache(ID2),
    ?notify(?MSG_WEDDING_START, [
        {role, ID1, Name1},
        {role, ID2, Name2}
    ]),
    scene:create(wedding_util:scene(), 0, #{
        start_time => State#state.start_time,
        end_time   => State#state.end_time,
        couple     => State#state.couple
    }),
    {noreply, State};

do_handle_cast(stop_wedding, State) ->
    #state{start_time=StartTime, end_time=EndTime} = State,
    Wedding = wedding_ets:get(key(State)),
    % 标记婚礼已完整跑完
    wedding_ets:set(Wedding#wedding{finish=true}),
    scene:destroy(wedding_util:scene()),
    marriage_manager:clear_wtime(State#state.couple, {StartTime, EndTime}),
    {stop, normal, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.

key(State) ->
    {State#state.start_time, State#state.end_time}.

bc(Msg, State) ->
    [role:is_online(RoleID) andalso ?ucast(RoleID, Msg) || RoleID <- State#state.couple].

send_accept_mail(RoleID, State) ->
    Args = [begin
        {ok, Cache} = role:get_cache(ID),
        Cache#role_cache.name
    end || ID <- State#state.couple] ++ [ut_time:seconds_to_string(State#state.start_time)],
    mail:send(RoleID, ?MAIL_WEDDING_ACCEPT, cfg_marriage:invite_accept(), Args).
