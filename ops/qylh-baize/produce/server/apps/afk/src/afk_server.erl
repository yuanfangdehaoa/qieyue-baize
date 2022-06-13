%% @author rong
%% @doc
-module(afk_server).

-include_lib("stdlib/include/ms_transform.hrl").
-include("enum.hrl").
-include("scene.hrl").
-include("table.hrl").
-include("game.hrl").
-include("afk.hrl").
-include("role.hrl").

-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/0]).
-export([login/1, logout/4]).
-export([add_new_robot/1]).

-define(SERVER, ?MODULE).

-record(state, {roles = []}).

-record(afk_robot, {role_id, start_time, end_time, active=false}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

login(RoleSt) ->
    afk_robot:update_role_pos(RoleSt),
    gen_server:cast(?SERVER, {login, RoleSt#role_st.role}).

logout(RoleID, Logout, EscortTime, AFKTime) ->
    StartTime = max(Logout + cfg_game:afk_logout(), EscortTime),
    gen_server:cast(?SERVER, {logout, RoleID, StartTime, AFKTime}).

% 同一挂机点，补充新的机器人
add_new_robot(CreepID) ->
    gen_server:cast(?SERVER, {add_new_robot, CreepID}).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({}) ->
    ets:new(?ETS_ROBOT, [named_table, {keypos, #robot.role_id}, public]),
    erlang:send(self(), loop),
    {ok, #state{roles = []}}.

handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Msg, State) ->
    ?try_handle_info(do_handle_info(Msg, State), State).

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
loop() ->
    erlang:send_after(1000, self(), loop).

do_handle_cast({login, RoleID}, State) ->
    #state{roles = Roles} = State,
    afk_robot:del_robot(RoleID),
    {noreply, State#state{roles=lists:keydelete(RoleID, #afk_robot.role_id, Roles)}};

do_handle_cast({logout, RoleID, StarTime, AFKTime}, State) ->
    #state{roles = Roles} = State,
    AfkRobot = #afk_robot{
        role_id    = RoleID,
        start_time = StarTime,
        end_time   = StarTime + AFKTime
    },
    {noreply, State#state{roles=[AfkRobot|Roles]}};

do_handle_cast(started, State) ->
    MS = ets:fun2ms(fun(E) when E#role_afk.time > 0 -> E end),
    RoleAfks = db:dirty_select(?DB_ROLE_AFK, MS),
    Roles = lists:map(fun(#role_afk{id=RoleID, time=AFKTime}) ->
        [#role_info{logout=Logout}] = db:dirty_read(?DB_ROLE_INFO, RoleID),
        [#role_escort{end_time=EscortTime}] = db:dirty_read(?DB_ROLE_ESCORT, RoleID),
        StarTime = max(Logout + cfg_game:afk_logout(), EscortTime),
        #afk_robot{
            role_id    = RoleID,
            start_time = StarTime,
            end_time   = StarTime + AFKTime
        }
    end, RoleAfks),
    {noreply, State#state{roles = Roles}};

do_handle_cast({add_new_robot, CreepID}, State) ->
    afk_robot:add_new_robot(CreepID),
    {noreply, State}.

do_handle_info(loop, State) ->
    #state{roles = Roles} = State,
    loop(),
    Now = ut_time:seconds(),
    Roles2 = lists:filtermap(fun(AfkRobot) ->
        #afk_robot{role_id=RoleID, start_time=StartTime,
            end_time=EndTime, active=Active} = AfkRobot,
        % 服务器重启时，玩家挂机时间已完，也走一遍加机器人流程
        % 以便玩家上线可以读取挂机点
        if
            Now >= StartTime, not Active ->
                afk_robot:enter(RoleID, EndTime),
                {true, AfkRobot#afk_robot{active = true}};
            Now >= EndTime ->
                afk_robot:timeout(RoleID),
                false;
            true ->
                {true, AfkRobot}
        end
    end, Roles),
    {noreply, State#state{roles = Roles2}}.
