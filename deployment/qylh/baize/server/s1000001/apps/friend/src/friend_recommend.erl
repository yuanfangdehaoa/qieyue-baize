%%%=============================================================================
%%% @author rong
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(friend_recommend).

-behaviour(gen_server).

-include_lib("stdlib/include/ms_transform.hrl").
-include("table.hrl").
-include("friend.hrl").
-include("role.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([hook_login/1, hook_upgrade/2, recommend/1]).

-define(SERVER, ?MODULE).
-define(RECOMMEND_NUM, 4).
-define(MAX, 200). %保留最近登陆的200人

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

hook_login(RoleSt) ->
    #role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
    gen_server:cast(?SERVER, {add_role, RoleSt#role_st.role, Level, ut_time:seconds()}).

hook_upgrade(NewLv, RoleSt) ->
    gen_server:cast(?SERVER, {add_role, RoleSt#role_st.role, NewLv, ut_time:seconds()}).

recommend(RoleID) ->
    gen_server:call(?SERVER, {recommend, RoleID}).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
    SysID = cfg_sysopen:sysid(friend_handler),
    {_, NeedLv, _} = lists:keyfind(SysID, 1, cfg_sysopen:syslist()),
    MS = ets:fun2ms(fun(#role_info{id=RoleID, level=Level, login=LoginTime}) 
        when Level >= NeedLv -> {RoleID, LoginTime} end),
    RoleList = db:dirty_select(?DB_ROLE_INFO, MS),
    RoleList2 = lists:sublist(lists:sort(fun({_, T1}, {_, T2}) -> T1 > T2 end, RoleList), ?MAX),
    {ok, RoleList2}.

handle_call({recommend, RoleID}, _From, State) ->
    #friend{roles=Roles} = friend_server:get_info(RoleID),
    RoleList2 = lists:filter(fun({R, _}) ->
        R =/= RoleID andalso (not maps:is_key(R, Roles))
    end, State),
    RoleList3  = lists:sublist(ut_rand:shuffle(RoleList2), ?RECOMMEND_NUM),
    Recommends = [role:get_base(R) || {R, _} <- RoleList3],
    {reply, {ok, Recommends}, State};

handle_call(_Req, _From, State) ->
    {reply, {error, unknown_call}, State}.

handle_cast({add_role, RoleID, Level, Time}, State) ->
    SysID = cfg_sysopen:sysid(friend_handler),
    {_, NeedLv, _} = lists:keyfind(SysID, 1, cfg_sysopen:syslist()),
    case Level >= NeedLv of
        true ->
            State2 = lists:sublist([{RoleID, Time}| lists:keydelete(RoleID, 1, State)], ?MAX),
            {noreply, State2};
        false ->
            {noreply, State}
    end;

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
