%% @author rong
%% @doc
-module(wedding_manager).

-behaviour(gen_server).

-include("game.hrl").
-include("table.hrl").
-include("errno.hrl").
-include("wedding.hrl").
-include("enum.hrl").
-include("proto.hrl").

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/0]).
-export([hook_chime/1, book/3]).
-export([gm_clear/0]).

-define(SERVER, ?MODULE).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

hook_chime(0) ->
    gen_server:cast(?SERVER, chime);
hook_chime(_) ->
    ignore.

book(StartTime, EndTime, Couple) ->
    gen_server:call(?SERVER, {book, StartTime, EndTime, Couple}).

gm_clear() ->
    gen_server:cast(?SERVER, gm_clear).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({}) ->
    process_flag(trap_exit, true),
    wedding_ets:init(),
    erlang:send_after(timer:minutes(15), self(), persist),
    {ok, undefined}.

handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(persist, State) ->
    erlang:send_after(timer:minutes(15), self(), persist),
    persist(),
    {noreply, State};

handle_info(Info, State) ->
    ?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
    persist(),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call({book, StartTime, EndTime, Couple}, _From, State) ->
    ?_check(wedding_ets:get(StartTime, EndTime) == no_book, ?ERR_WEDDING_ALREADY_BOOK),
    ?_check(ut_time:seconds() < StartTime, ?ERR_WEDDING_BOOK_OVERTIME),
    Wedding = #wedding{time={StartTime, EndTime}, couple=Couple},
    wedding_ets:set(Wedding),
    marriage_manager:book(StartTime, EndTime, Couple),
    start_agent(Wedding),
    [mail:send(RoleID, ?MAIL_WEDDING_APPOINTMNET, cfg_marriage:appointment_reward(),
        [ut_time:seconds_to_string(StartTime)]) || RoleID <- Couple],
    [role:is_online(RoleID) andalso
        ?ucast(RoleID, #m_wedding_appointment_book_toc{}) || RoleID <- Couple],
    {reply, ok, State};

do_handle_call(Req, _From, State) ->
    ?error("unhandle cast: ~p", [Req]),
    {reply, {error, unknown_call}, State}.

do_handle_cast(chime, State) ->
    % 正常来说当天0点时，今天所有的婚礼应该已经完成了
    [erlang:exit(Pid, kill) || #wedding_idx{pid=Pid} <- wedding_ets:all_idx()],
    wedding_ets:clear(),
    {noreply, State};

do_handle_cast(gm_clear, State) ->
    scene:destroy(wedding_util:scene()),
    do_handle_cast(chime, State),
    marriage_manager:clear_all_wtime(),
    {noreply, State};

do_handle_cast(started, State) ->
    [start_agent(Wedding) || Wedding <- db:dirty_match_all(?DB_WEDDING)],
    {noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.

start_agent(Wedding) ->
    case check_status(Wedding) of
        ok ->
            {ok, Pid} = wedding_agent_sup:start_agent(Wedding),
            wedding_ets:set(Wedding),
            wedding_ets:set_idx(#wedding_idx{time=Wedding#wedding.time, pid=Pid});
        compensate ->
            % 补偿的婚礼，需要在今天的预约里也清除
            #wedding{time=WTime, couple=Couple} = Wedding,
            ?debug("compensate ~w", [WTime]),
            wedding_ets:del(WTime),
            wedding_ets:del_idx(WTime),
            marriage_manager:compensate_wedding(Couple),
            [mail:send(RoleID, ?MAIL_WEDDING_COMPENSATE) || RoleID <- Couple];
        _ ->
            ignore
    end.

check_status(#wedding{finish=true}) ->
    finish;
check_status(Wedding) ->
    % 特殊情况处理
    % 当服务器维护期间，婚礼时间已到或者已过了的预约通通补偿玩家次数
    % 邮件通知他们，再重新预约
    Now = ut_time:seconds(),
    Pre = wedding_util:pre(),
    #wedding{time={StartTime, EndTime}} = Wedding,
    case Now >= StartTime - Pre andalso EndTime >= Now of
        true ->
            if
                Now >= StartTime ->
                    % 维护时婚礼已开始
                    compensate;
                true ->
                    ok
            end;
        false ->
            case Now < StartTime - Pre of
                true ->
                    % 还未开始
                    ok;
                false ->
                    % 维护时婚礼已过
                    compensate
            end
    end.

persist() ->
    [db:dirty_write(?DB_WEDDING, R) || R <- wedding_ets:all()].
