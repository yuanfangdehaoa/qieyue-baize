%% @author rong
%% @doc
-module(combat1v1_matcher).

-behaviour(gen_server).

-include("game.hrl").
-include("errno.hrl").
-include("combat1v1.hrl").
-include("role.hrl").
-include("proto.hrl").
-include("enum.hrl").

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/0]).
-export([hook_logout/1]).
-export([join/1, cancel/1, match_succ/1, match_succ/2]).
-export([activity_start/1, activity_stop/1]).
-export([test_match/0]).

-define(SERVER, ?MODULE).
-define(STAGE_0, 0). % 排名 local前10， cross前30的特殊阶段
-define(STAGE_1, 1).
-define(STAGE_2, 2).
-define(STAGE_3, 3).
-define(STAGE_4, 4).

-define(INTERVAL, 10).

-record(state, {roles = #{}}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

hook_logout(RoleSt) ->
    cancel(RoleSt#role_st.role).

join(MatchRole) ->
    case combat1v1_util:mode() of
        ?MODE_LOCAL ->
            gen_server:call(?SERVER, {join, MatchRole});
        ?MODE_CROSS ->
            cluster:gen_call_cross(?CROSS_RULE_24_8, ?SERVER, {join,MatchRole})
    end.

cancel(RoleID) ->
    case combat1v1_util:mode() of
        ?MODE_LOCAL ->
            gen_server:cast(?SERVER, {cancel, RoleID});
        ?MODE_CROSS ->
            cluster:gen_cast_cross(?CROSS_RULE_24_8, ?SERVER, {cancel,RoleID})
    end.

activity_start(ActID) ->
    gen_server:cast(?SERVER, {activity_start, ActID}).

activity_stop(ActID) ->
    gen_server:cast(?SERVER, {activity_stop, ActID}).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({}) ->
    erlang:send_after(timer:seconds(1), self(), loop),
    {ok, #state{}}.

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
do_handle_call({join, MatchRole}, _From, State) ->
    case need_rookie_protect(MatchRole) of
        true ->
            erlang:send_after(timer:seconds(ut_rand:random(3, 5)),
                self(), {match_succ, MatchRole}),
            {reply, ok, State};
        false ->
            join(MatchRole, State)
    end;

do_handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

do_handle_cast({cancel, RoleID}, State) ->
    case get_role(RoleID) of
        ?nil ->
            {noreply, State};
        Group ->
            del_role(RoleID),
            case maps:find(Group, State#state.roles) of
                {ok, List} ->
                    List2 = lists:keydelete(RoleID, #match_role.role_id, List),
                    Roles2 = maps:put(Group, List2, State#state.roles),
                    {noreply, State#state{roles=Roles2}};
                _ ->
                    {noreply, State}
            end
    end;

do_handle_cast({activity_start, _ActID}, State) ->
    {noreply, State};

% 活动结束，关闭匹配
do_handle_cast({activity_stop, _ActID}, State) ->
    maps:fold(fun(_Grade, List, Acc) ->
        [?ucast(R#match_role.role_id, #m_combat1v1_match_cancel_toc{}) || R <- List],
        Acc
    end, 0, State#state.roles),
    {noreply, State#state{roles=#{}}};

do_handle_cast(_Msg, State) ->
    {noreply, State}.

do_handle_info(loop, State) ->
    erlang:send_after(timer:seconds(1), self(), loop),
    State2 = match(State),
    State3 = shift_top(State2),
    State4 = add_stage(State3),
    State5 = match_robot(State4),
    {noreply, State5};

do_handle_info({match_succ, MatchRole}, State) ->
    ?debug("match robot ~w", [MatchRole#match_role.role_id]),
    match_succ(MatchRole),
    {noreply, State};

do_handle_info(_Msg, State) ->
    {noreply, State}.

% 匹配玩家
match(State) ->
    TopList = maps:get(top, State#state.roles, []),
    clear_prev_data(),
    Rest0 = match_1(TopList),
    Roles = maps:put(top, Rest0, State#state.roles),
    Roles2 = maps:fold(fun(Group, List, Acc) ->
        clear_prev_data(),
        Rest = match_1(List),
        maps:put(Group, Rest, Acc)
    end, Roles, Roles),
    State#state{roles=Roles2}.

test_match() ->
    List = [
        stage(#match_role{role_id=1, power=10000, grade=13}, 4)
        % stage(#match_role{role_id=2, power=13000}, 1),
        % stage(#match_role{role_id=3, power=9500}, 1),
        % stage(#match_role{role_id=4, power=12500}, 1),
        % stage(#match_role{role_id=5, power=9000}, 1),
        % stage(#match_role{role_id=6, power=8000}, 1)
    ],
    match_1(List).

match_1([]) ->
    get_nomatch();
match_1([H]) ->
    [H|get_nomatch()];
match_1([A, B|T]) ->
    match_2(A, [B|T]),
    Rest = erlang:erase({?MODULE, rest}),
    match_1(Rest).

match_2(A, []) ->
    append_nomatch(A);
match_2(A, [B|T]) ->
    if
        A#match_role.power =< B#match_role.max,
        A#match_role.power >= B#match_role.min,
        B#match_role.power =< A#match_role.max,
        B#match_role.power >= A#match_role.min ->
            del_role(A#match_role.role_id),
            del_role(B#match_role.role_id),
            ?debug("match succ ~w vs ~w ~n", [A#match_role.role_id, B#match_role.role_id]),
            spawn(?MODULE, match_succ, [A, B]),
            append_rest(T);
        true ->
            append_rest([B]),
            match_2(A, T)
    end.

clear_prev_data() ->
    erlang:erase({?MODULE, nomatch}),
    erlang:erase({?MODULE, rest}).

get_nomatch() ->
    case erlang:get({?MODULE, nomatch}) of
        ?nil -> [];
        L -> L
    end.

get_rest() ->
    case erlang:get({?MODULE, rest}) of
        ?nil -> [];
        L -> L
    end.

append_nomatch(M) ->
    erlang:put({?MODULE, nomatch}, [M|get_nomatch()]).

append_rest(L) when is_list(L) ->
    erlang:put({?MODULE, rest}, L ++ get_rest()).

% 高排名玩家没匹配成功，迁移至按段位匹配
shift_top(State) ->
    Now = ut_time:seconds(),
    List = maps:get(top, State#state.roles, []),
    {TopList, ShiftList} = lists:foldl(fun(MatchRole, {AccTop, AccRemove}) ->
        case Now - MatchRole#match_role.check >= ?INTERVAL of
            true ->
                {AccTop, [MatchRole|AccRemove]};
            false ->
                {[MatchRole|AccTop], AccRemove}
        end
    end, {[], []}, List),
    Roles2 = maps:put(top, TopList, State#state.roles),
    Roles3 = lists:foldl(fun(MatchRole0, AccRoles) ->
        Group = combat1v1_util:grade_group(MatchRole0#match_role.grade),
        MatchRole = stage(MatchRole0, ?STAGE_1),
        set_role(MatchRole0#match_role.role_id, Group),
        ut_misc:maps_append(Group, MatchRole, AccRoles)
    end, Roles2, ShiftList),
    State#state{roles=Roles3}.

% 切换到下一个检测阶段
add_stage(State) ->
    Now = ut_time:seconds(),
    Roles2 = maps:fold(fun(Group, List, Acc) ->
        List2 = lists:map(fun(MatchRole) ->
            case Now - MatchRole#match_role.check >= ?INTERVAL of
                true ->
                    case combat1v1_util:is_junior(MatchRole#match_role.grade) of
                        true ->
                            stage(MatchRole, ?STAGE_4);
                        false ->
                            stage(MatchRole, MatchRole#match_role.stage+1)
                    end;
                false ->
                    MatchRole
            end
        end, List),
        maps:put(Group, List2, Acc)
    end, State#state.roles, State#state.roles),
    State#state{roles=Roles2}.

% 阶段4匹配机器人
match_robot(State) ->
    Roles2 = maps:fold(fun(Group, List, Acc) ->
        List2 = lists:filtermap(fun(MatchRole) ->
            case MatchRole#match_role.stage of
                Stage when Stage >= 4 ->
                    del_role(MatchRole#match_role.role_id),
                    ?debug("match robot ~w", [MatchRole#match_role.role_id]),
                    spawn(?MODULE, match_succ, [MatchRole]),
                    false;
                _ ->
                    {true, MatchRole}
            end
        end, List),
        maps:put(Group, List2, Acc)
    end, State#state.roles, State#state.roles),
    State#state{roles=Roles2}.

% 匹配到玩家
match_succ(A, B) ->
    case combat1v1_util:activity() of
        ActID when ActID > 0 ->
            SceneID = combat1v1_util:scene(),
            RoomID = lists:concat([A#match_role.role_id, "." , B#match_role.role_id]),
            scene:create(SceneID, RoomID, #{attacker => A, defender => B}),
            [role:route(R#match_role.role_id, combat1v1_handler, match_succ, {SceneID, RoomID, Index})
                || {R, Index} <- [{A, 1}, {B, 2}]];
        _ ->
            [?ucast(R#match_role.role_id, #m_combat1v1_match_cancel_toc{})
                || R <- [A, B]]
    end.

% 匹配机器人
match_succ(A) ->
    case combat1v1_util:activity() of
        ActID when ActID > 0 ->
            SceneID = combat1v1_util:scene(),
            RoomID = A#match_role.role_id,
            RobotGrade = combat1v1_util:calc_grade_junior_lv(A#match_role.grade),
            scene:create(SceneID, RoomID, #{
                attacker => A,
                defender => #match_role{
                    role_id = ?SCENE_ROBOT_ID,
                    type    = ?ACTOR_TYPE_ROBOT,
                    grade   = RobotGrade
                },
                robot => A#match_role.role_id
            }),
            role:route(A#match_role.role_id, combat1v1_handler, match_succ, {SceneID, RoomID, 1});
        _ ->
            ?ucast(A#match_role.role_id, #m_combat1v1_match_cancel_toc{})
    end.

set_role(RoleID, Group) ->
    erlang:put({role, RoleID}, Group).

get_role(RoleID) ->
    erlang:get({role, RoleID}).

del_role(RoleID) ->
    erlang:erase({role, RoleID}).

stage(MatchRole, ?STAGE_0) ->
    MatchRole#match_role{
        stage   = ?STAGE_0,
        min     = 0,
        max     = 99999999999,
        check   = ut_time:seconds()
    };
stage(MatchRole, ?STAGE_1) ->
    MatchRole#match_role{
        stage   = ?STAGE_1,
        min     = trunc(MatchRole#match_role.power*0.8),
        max     = trunc(MatchRole#match_role.power*1.2),
        check   = ut_time:seconds()
    };
stage(MatchRole, ?STAGE_2) ->
    MatchRole#match_role{
        stage   = ?STAGE_2,
        min     = trunc(MatchRole#match_role.power*0.6),
        max     = trunc(MatchRole#match_role.power*1.4),
        check   = ut_time:seconds()
    };
stage(MatchRole, ?STAGE_3) ->
    MatchRole#match_role{
        stage   = ?STAGE_3,
        min     = 0,
        max     = 99999999999,
        check   = ut_time:seconds()
    };
stage(MatchRole, Stage) ->
    MatchRole#match_role{
        stage   = Stage,
        check   = ut_time:seconds()
    }.

can_join_top_stage(MatchRole) ->
    (MatchRole#match_role.mode == ?MODE_LOCAL andalso
        MatchRole#match_role.rank > 0 andalso
        MatchRole#match_role.rank =< 10)
    orelse
    (MatchRole#match_role.mode == ?MODE_CROSS andalso
        MatchRole#match_role.rank > 0 andalso
        MatchRole#match_role.rank =< 30).

need_rookie_protect(MatchRole) ->
    #match_role{keep_lose=KeepLose, join=Join} = MatchRole,
    (KeepLose >= 3 orelse Join < 3).

join(MatchRole0, State) ->
    #match_role{role_id=RoleID, grade=Grade} = MatchRole0,
    case get_role(RoleID) of
        ?nil ->
            case can_join_top_stage(MatchRole0) of
                true ->
                    Group = top,
                    MatchRole = stage(MatchRole0, ?STAGE_0);
                false ->
                    Group = combat1v1_util:grade_group(Grade),
                    MatchRole = stage(MatchRole0, ?STAGE_1)
            end,
            set_role(RoleID, Group),
            Roles2 = ut_misc:maps_append(Group, MatchRole, State#state.roles),
            {reply, ok, State#state{roles=Roles2}};
        _ ->
            {reply, ok, State}
    end.
