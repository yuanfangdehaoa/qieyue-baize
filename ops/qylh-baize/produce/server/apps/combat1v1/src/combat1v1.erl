%% @author rong
%% @doc 巅峰1v1处理本服玩家数据，只在游戏服启动
-module(combat1v1).

-include("game.hrl").
-include("activity.hrl").
-include("scene.hrl").
-include("combat1v1.hrl").
-include("enum.hrl").
-include("attr.hrl").
-include("proto.hrl").
-include("item.hrl").

-export([hook_start/2, hook_stop/2, hook_post/2]).
-export([get_entry/3, pre_enter/3]).
-export([prepare/2, clear_buff/1, wait_timeout/1]).
-export([hook_init/1, hook_enter/2, hook_role_dead/3, hook_creep_dead/3,
    hook_leave/2, hook_timeout/1]).

-record(result, {winner, loser}).

hook_start(?SERVER_TYPE_LOCAL, ActID) ->
    ?debug("=======start ~w", [ActID]),
    combat1v1_server:activity_start(ActID),
    combat1v1_matcher:activity_start(ActID),
    combat1v1_settle:activity_start(ActID);
hook_start(?SERVER_TYPE_CROSS, ActID) ->
    ?debug("=======start ~w", [ActID]),
    combat1v1_matcher:activity_start(ActID),
    combat1v1_settle:activity_start(ActID);
hook_start(_, _) ->
    ignore.

hook_stop(?SERVER_TYPE_LOCAL, ActID) ->
    ?debug("=======stop ~w", [ActID]),
    combat1v1_matcher:activity_stop(ActID),
    combat1v1_server:activity_stop(ActID),
    combat1v1_settle:activity_stop(ActID);
hook_stop(?SERVER_TYPE_CROSS, ActID) ->
    ?debug("=======stop ~w", [ActID]),
    combat1v1_matcher:activity_stop(ActID),
    combat1v1_settle:activity_stop(ActID);
hook_stop(_, _) ->
    ignore.

hook_post(?SERVER_TYPE_LOCAL, ActID) ->
    ?debug("=======post ~w", [ActID]),
    combat1v1_server:activity_post(ActID),
    combat1v1_settle:activity_post(ActID);
hook_post(?SERVER_TYPE_CROSS, ActID) ->
    ?debug("=======post ~w", [ActID]),
    combat1v1_settle:activity_post(ActID);
hook_post(_, _) ->
    ignore.


% 获得入口参数
get_entry(_ActID, SceneID, RoleSt) ->
    #{room := RoomID, index := Index} = combat1v1_util:get_entry_opts(RoleSt),
    Born = scene_config:born(SceneID),
    #{
        room  => RoomID,
        coord => lists:nth(Index, Born),
        opts  => #{bctype => ?BCTYPE_SCENE}
    }.

pre_enter(_SceneID, _Args, RoleSt) ->
    role_skill:refresh(RoleSt).

% 玩家加载完地图，通知副本已经准备好
prepare(RoleID, SceneSt) ->
    send_prepare(RoleID, SceneSt),
    case get_result() of
        ?nil ->
            % 如果人不齐，不用推送battle_start
            Wait = get_wait(),
            IsAllIn = fun(W) -> lists:all(fun(I) -> I end, maps:values(W)) end,
            case IsAllIn(Wait) of
                false ->
                    Wait2 = maps:put(RoleID, true, Wait),
                    update_wait(Wait2),
                    case IsAllIn(Wait2) of
                        true ->
                            PTime = ut_time:seconds() + cfg_combat1v1:prep(),
                            ETime = ut_time:seconds() + cfg_combat1v1:last(),
                            erlang:put({?MODULE, time}, {PTime, ETime}),
                            [?ucast(RID, #m_combat1v1_battle_start_toc{
                                ptime=PTime, etime=ETime})
                            || RID <- maps:keys(Wait2)],

                            erlang:send_after(timer:seconds(cfg_combat1v1:last()),
                                self(), timeout),

                            erlang:send_after(timer:seconds(cfg_combat1v1:prep()+1),
                                self(), {route, ?MODULE, clear_buff}),

                            start_robot(SceneSt);
                        false ->
                            % 第一个玩 家请求后就开始等待其他玩家
                            erlang:send_after(timer:seconds(cfg_combat1v1:wait()),
                                self(), {route, ?MODULE, wait_timeout})
                    end;
                true ->
                    {PTime, ETime} = erlang:get({?MODULE, time}),
                    ?ucast(RoleID, #m_combat1v1_battle_start_toc{ptime=PTime, etime=ETime})
            end;
        _ ->
            ignore
    end.

clear_buff(_SceneSt) ->
    Wait = get_wait(),
    [begin
        Actor = scene_actor:get_actor(RID),
        buff_util:del_buffs(Actor, [cfg_combat1v1:buff()])
    end || RID <- maps:keys(Wait)].

% 剩下的玩家太久没进入，直接判定为负
wait_timeout(SceneSt) ->
    Wait = get_wait(),
    case lists:all(fun(I) -> I end, maps:values(Wait)) of
        true ->
            ignore;
        false ->
            {WaitRoleID, _} = lists:keyfind(false, 2, maps:to_list(Wait)),
            Attacker = get_attacker(SceneSt),
            Defender = get_defender(SceneSt),
            if
                WaitRoleID == Attacker#match_role.role_id ->
                    save_result(Defender, Attacker, wait_timeout, SceneSt);
                true ->
                    save_result(Attacker, Defender, wait_timeout, SceneSt)
            end
    end.

%%-----------------------------------------------
%% scene_hook 回调函数
%%-----------------------------------------------
hook_init(SceneSt) ->
    set_wait(SceneSt).

hook_enter(Actor, SceneSt) ->
    combat1v1_robot:summon(Actor, SceneSt),
    buff_util:add_buffs(Actor, [cfg_combat1v1:buff()]).

hook_role_dead(Atker, _Defer, SceneSt) ->
    case get_result() of
        ?nil ->
            Attacker = get_attacker(SceneSt),
            Defender = get_defender(SceneSt),
            if
                Atker#actor.uid == Attacker#match_role.role_id ->
                    save_result(Attacker, Defender, role_dead, SceneSt);
                true ->
                    save_result(Defender, Attacker, role_dead, SceneSt)
            end;
        _ ->
            ignore
    end.

hook_creep_dead(_Atker, _Defer, SceneSt) ->
    case get_result() of
        ?nil ->
            save_result(get_attacker(SceneSt), get_defender(SceneSt), creep_dead, SceneSt);
        _ ->
            ignore
    end.

hook_leave(Actor, SceneSt) ->
    case get_result() of
        ?nil ->
            Attacker = get_attacker(SceneSt),
            Defender = get_defender(SceneSt),
            if
                Actor#actor.uid == Attacker#match_role.role_id ->
                    save_result(Defender, Attacker, leave, SceneSt);
                true ->
                    save_result(Attacker, Defender, leave, SceneSt)
            end;
        _ ->
            ignore
    end,
    % 当场景最后一个人离开后，立即销毁
    case length(scene_actor:get_actids(?ACTOR_TYPE_ROLE)) == 0 of
        true ->
            ?debug("stop combat1v1 fb", []),
            erlang:send(self(), {stop, normal});
        false ->
            ignore
    end.

hook_timeout(SceneSt) ->
    case get_result() of
        ?nil ->
            Attacker = get_attacker(SceneSt),
            Defender = get_defender(SceneSt),
            AttActor = scene_actor:get_actor(Attacker#match_role.role_id),
            DefActor = scene_actor:get_actor(Defender#match_role.role_id),
            IsAttWin = case {AttActor, DefActor} of
                {_, ?nil} ->
                    true;
                {?nil, _} ->
                    false;
                _ ->
                    AttHp = ?_attr(AttActor#actor.attr, ?ATTR_HP),
                    AttHpMax = ?_attr(AttActor#actor.attr, ?ATTR_HPMAX),
                    DefHp = ?_attr(DefActor#actor.attr, ?ATTR_HP),
                    DefHpMax = ?_attr(DefActor#actor.attr, ?ATTR_HPMAX),
                    if
                        AttHp / AttHpMax > DefHp / DefHpMax -> true;
                        AttHp / AttHpMax == DefHp / DefHpMax -> AttHp > DefHp;
                        true -> false
                    end
            end,
            if
                IsAttWin ->
                    save_result(Attacker, Defender, timeout, SceneSt);
                true ->
                    save_result(Defender, Attacker, timeout, SceneSt)
            end;
        _ ->
            ignore
    end.

%%-----------------------------------------------
%% Internal function
%%-----------------------------------------------

get_result() ->
    erlang:get({?MODULE, result}).

save_result(Winner, Loser, Reason, SceneSt) ->
    ?debug("combat1v1 result win: ~w, lose: ~w, reason: ~w",
        [Winner#match_role.role_id, Loser#match_role.role_id, Reason]),
    erlang:put({?MODULE, result}, #result{winner=Winner, loser=Loser}),
    stop_robot(SceneSt),
    erlang:send_after(timer:seconds(cfg_combat1v1:stat_cd() + 3), self(), {stop, normal}),
    GradeConf = combat1v1_util:grade_conf(),
    #cfg_combat1v1_grade{win_score=WinScore, win_reward=WinReward, win_merit=WinMerit}
        = GradeConf:find(Winner#match_role.grade),
    #cfg_combat1v1_grade{lose_score=LoseScore, lose_reward=LoseReward, lose_merit=LoseMerit}
        = GradeConf:find(Loser#match_role.grade),
    Winner#match_role.type == ?ACTOR_TYPE_ROLE andalso
        upload_role_win_result(Winner, WinScore, WinReward, WinMerit),
    Loser#match_role.type == ?ACTOR_TYPE_ROLE andalso
        upload_role_lose_result(Loser, LoseScore, LoseReward, LoseMerit).

start_robot(SceneSt) ->
    Defender = get_defender(SceneSt),
    case scene_actor:get_actor(Defender#match_role.role_id) of
        #actor{type=?ACTOR_TYPE_ROBOT} = Actor ->
            creep_agent:event(Actor, hook_scene_start, ?nil);
        _ ->
            ignore
    end.

stop_robot(SceneSt) ->
    Defender = get_defender(SceneSt),
    case scene_actor:get_actor(Defender#match_role.role_id) of
        #actor{type=?ACTOR_TYPE_ROBOT} = Actor ->
            creep_agent:event(Actor, hook_scene_over, ?nil);
        _ ->
            ignore
    end.

get_defender(SceneSt) ->
    #scene_st{opts=Opts} = SceneSt,
    maps:get(defender, Opts).

get_attacker(SceneSt) ->
    #scene_st{opts=Opts} = SceneSt,
    maps:get(attacker, Opts).

upload_role_win_result(MatchRole, ChgScore, Rewards, ChgMerit) ->
    upload_role_result(MatchRole, true, ChgScore, Rewards, ChgMerit).

upload_role_lose_result(MatchRole, ChgScore, Rewards, ChgMerit) ->
    upload_role_result(MatchRole, false, ChgScore, Rewards, ChgMerit).

upload_role_result(MatchRole, IsWin, ChgScore, Rewards0, ChgMerit) ->
    #match_role{role_id=RoleID, level=Level, score=Score, today_join=Join} = MatchRole,
    ?debug("upload role : ~w ~w ~w", [RoleID, IsWin, ChgScore]),
    Score2 = max(0, Score + ChgScore),
    GradeConf = combat1v1_util:grade_conf(),
    Grade2 = GradeConf:grade(Score2),
    LimitConf = combat1v1_util:limit_conf(),
    #cfg_combat1v1_limit{has_reward=HasReward} = LimitConf:find(Join),
    Rewards = if
        HasReward ->
            game_util:transform_gain(Level, Rewards0);
        true -> []
    end,

    RewardMap = maps:from_list(lists:map(fun
        ({K, V, _}) -> {K, V};
        (I) -> I
    end, Rewards)),
    ?ucast(RoleID, #m_combat1v1_battle_result_toc{
        is_win  = IsWin,
        grade   = Grade2,
        score   = Score2,
        chg     = ChgScore,
        rewards = RewardMap
    }),
    combat1v1_server:upload_result(RoleID, IsWin, Grade2, Score2, ChgMerit),
    HasReward andalso role:route(RoleID, combat1v1_handler, battle_result, Rewards).

% 记录需要等待的玩家
set_wait(SceneSt) ->
    #match_role{role_id=AtkID, type=AtkType} = get_attacker(SceneSt),
    #match_role{role_id=DefID, type=DefType} = get_defender(SceneSt),
    Wait = lists:foldl(fun({RoleID, Type}, Wait0) ->
        if
            Type == ?ACTOR_TYPE_ROLE -> maps:put(RoleID, false, Wait0);
            true -> Wait0
        end
    end, #{}, [{AtkID, AtkType}, {DefID, DefType}]),
    erlang:put({?MODULE, wait}, Wait).

get_wait() ->
    erlang:get({?MODULE, wait}).

update_wait(Wait) ->
    erlang:put({?MODULE, wait}, Wait).

send_prepare(RoleID, SceneSt) ->
    Attacker = get_attacker(SceneSt),
    Defender = get_defender(SceneSt),
    {OID, Pos} = if
        RoleID == Attacker#match_role.role_id ->
            {Defender#match_role.role_id, 1};
        true ->
            {Attacker#match_role.role_id, 2}
    end,
    ?ucast(RoleID, #m_combat1v1_battle_prepare_toc{opponent=OID, pos=Pos}).
