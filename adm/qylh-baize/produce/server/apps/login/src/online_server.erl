%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(online_server).

-behaviour(gen_server).

-include("game.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("table.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([hook_login/1]).
-export([hook_logout/1]).
-export([hook_reset/3]).
-export([get_total_time/1]).
-export([get_today_time/1]).
-export([get_roles/0]).
-export([get_num/0]).
-export([is_online/1]).

-define(SERVER, ?MODULE).

-define(ETS_ONLINE, ets_online).

-define(LOOP_INTERVAL, 1).

-record(state, {time, stat}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

hook_login(#role_st{role=RoleID, user=User}) ->
    Online = case db:dirty_read(?DB_ROLE_ONLINE, RoleID) of
        [R] -> R;
        []  -> #role_online{id=RoleID, today=0, total=0}
    end,
    #game_user{chan_id=ChanID, gamechan=GameChan} = User,
    gen_server:cast(?SERVER, {login, Online, ChanID, GameChan}).

hook_logout(#role_st{role=RoleID, user=User}=RoleSt) ->
    log_api:update_online_time(RoleSt),
    #game_user{chan_id=ChanID, gamechan=GameChan} = User,
    gen_server:cast(?SERVER, {logout, RoleID, ChanID, GameChan}).

hook_reset(_DoW, _Hour, #role_st{role=RoleID}) ->
    gen_server:cast(?SERVER, {reset, RoleID}).

%% 获取总在线时长
get_total_time(RoleID) ->
    case ets:lookup(?ETS_ONLINE, RoleID) of
        [R] -> R#role_online.total;
        []  -> 0
    end.

%% 获取今日在线时长
get_today_time(RoleID) ->
    case ets:lookup(?ETS_ONLINE, RoleID) of
        [R] -> R#role_online.today;
        []  -> 0
    end.

%% 获取当前在线玩家
get_roles() ->
    [R#role_online.id || R <- ets:tab2list(?ETS_ONLINE)].

%% 获取当前在线人数
get_num() ->
    ets:info(?ETS_ONLINE, size).

%% 当前是否存在
is_online(RoleID) ->
    ets:member(?ETS_ONLINE, RoleID).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
    process_flag(trap_exit, true),
    ets:new(?ETS_ONLINE, [named_table, {keypos, #role_online.id}]),
    ?_if(cluster:is_local(), loop_time()),
    {ok, #state{time=ut_time:time(), stat=#{}}}.


handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.


handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
    ?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
    lists:foreach(fun
        (Online) ->
            db:dirty_write(?DB_ROLE_ONLINE, Online)
    end, ets:tab2list(?ETS_ONLINE)),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_cast({login, Online, ChanID, GameChan}, State = #state{stat=Stat}) ->
    case ets:member(?ETS_ONLINE, Online#role_online.id) of
        true  ->
            {noreply, State};
        false ->
            ets:insert(?ETS_ONLINE, Online),
            {noreply, State#state{
                stat = ut_misc:maps_increase({ChanID,GameChan}, 1, Stat)
            }}
    end;

do_handle_cast({logout, RoleID, ChanID, GameChan}, State = #state{stat=Stat}) ->
    case ets:lookup(?ETS_ONLINE, RoleID) of
        [R] ->
            ets:delete(?ETS_ONLINE, RoleID),
            db:dirty_write(?DB_ROLE_ONLINE, R),
            {noreply, State#state{
                stat = ut_misc:maps_increase({ChanID,GameChan}, -1, Stat)
            }};
        []  ->
            {noreply, State}
    end;

do_handle_cast({reset, RoleID}, State) ->
    case ets:lookup(?ETS_ONLINE, RoleID) of
        [R] ->
            ets:insert(?ETS_ONLINE, R#role_online{today=0});
        []  ->
            case db:dirty_read(?DB_ROLE_ONLINE, RoleID) of
                [R] ->
                    db:dirty_write(?DB_ROLE_ONLINE, R#role_online{today=0});
                []  ->
                    ignore
            end
    end,
    {noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.


do_handle_info(loop_time, State) ->
    loop_time(),
    {H1, M1, _} = State#state.time,
    {H2, M2, _} = Time = ut_time:time(),

    case H2 /= H1 of
        true  ->
            lists:foreach(fun
                (RolePid) ->
                    role:cast(RolePid, chime)
            end, game_role:get_alive_roles()),
            ets:safe_fixtable(?ETS_ONLINE, true),
            hook_chime(ets:first(?ETS_ONLINE), H2),
            ets:safe_fixtable(?ETS_ONLINE, false);
        false ->
            ignore
    end,
    case M2 /= M1 of
        true  ->
            OnlineNum = get_num(),
            log_api:log_online_num(OnlineNum),
            case M2 rem 5 == 0 of
                true  ->
                    log_junhai:log_online(State#state.stat);
                false ->
                    ignore
            end;
        false ->
            ignore
    end,
    ets:safe_fixtable(?ETS_ONLINE, true),
    add_time( ets:first(?ETS_ONLINE) ),
    ets:safe_fixtable(?ETS_ONLINE, false),
    {noreply, State#state{time=Time}};

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.


loop_time() ->
    erlang:send_after(timer:seconds(?LOOP_INTERVAL), self(), loop_time).

add_time('$end_of_table') ->
    ok;
add_time(RoleID) ->
    [Online] = ets:lookup(?ETS_ONLINE, RoleID),
    Online2  = Online#role_online{
        today = Online#role_online.today + ?LOOP_INTERVAL,
        total = Online#role_online.total + ?LOOP_INTERVAL
    },
    ets:insert(?ETS_ONLINE, Online2),
    add_time( ets:next(?ETS_ONLINE, RoleID) ).

hook_chime('$end_of_table', _Hour) ->
    ok;
hook_chime(RoleID, Hour) ->
    ?_if(Hour == 0, reset_time(RoleID)),
    hook_chime(ets:next(?ETS_ONLINE, RoleID), Hour).

reset_time(RoleID) ->
    [Online] = ets:lookup(?ETS_ONLINE, RoleID),
    Online2  = Online#role_online{today = 0},
    ets:insert(?ETS_ONLINE, Online2).
