%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(creep_ai).

-include("attr.hrl").
-include("btree.hrl").
-include("creep.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("skill.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("msgno.hrl").

%% API
-export([run/2]).
-export([sleep/2, sleep/3]).
-export([born/2, born/3]).
-export([die/2, die/3]).
-export([drop/2]).
-export([reborn/2, reborn/3]).
-export([disappear/2]).
-export([move/2, move/3]).
-export([guard/2]).
-export([goback/2]).
-export([patrol/2]).
-export([pursue/2, pursue/3]).
-export([escape/2]).
-export([prepare/2]).
-export([attack/2, attack/3, attack/4]).
-export([heal/2]).
-export([fission/2]).
-export([buff/3]).
-export([alarm/3]).
-export([anger/2]).
-export([calm/2]).
-export([can_reborn/2]).
-export([can_attack/2]).
-export([rush/4]).
-export([clear_sleep/2]).
-export([find_in_threat/2]).

%% 两个坐标小于这个值时视为同一点
-define(OFFSET, 20).

-define(STEP, 3).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
run({creep_ai, ActorID}, [Mod, Fun | Args]) ->
    SceneSt = scene_util:get_state(),
    case scene_actor:get_actor(ActorID) of
        ?nil  ->
            ?FAILURE;
        Actor ->
            Actor2 = case Actor#actor.rarity == ?CREEP_RARITY_COMM of
                true  ->
                    Prior2 = Actor#actor.prior - 1,
                    Actor1 = Actor#actor{prior=?_if(Prior2 =< 0, ?MAX_PRIOR, Prior2)},
                    scene_actor:set_actor(Actor1),
                    Actor1;
                false ->
                    Actor
            end,
            apply(Mod, Fun, [Actor2 | Args] ++ [SceneSt])
    end.



%% 休眠
%% Millis : 休眠时长
sleep(Actor, SceneSt) ->
    Millis = maps:get(sleep, Actor#actor.aiargs),
    do_sleep(Actor, Millis, SceneSt).

sleep(Actor, Millis, SceneSt) ->
    % ?debug("~ts", ["休眠"]),
    do_sleep(Actor, Millis, SceneSt).


%% 出生
%% Delay : 延迟出生时间
born(Actor, SceneSt) ->
    case maps:find(delay, Actor#actor.aiargs) of
        {ok, Delay} ->
            born(Actor, Delay, SceneSt);
        error ->
            do_born(Actor, SceneSt)
    end.

born(Actor, Delay, SceneSt) ->
    case do_sleep(Actor, Delay, SceneSt) of
        ?RUNNING -> ?RUNNING;
        ?SUCCESS -> do_born(Actor, SceneSt)
    end.


%% 死亡
%% IsClear : 是否由后端删除
die(Actor, SceneSt) ->
    die(Actor, false, SceneSt).

die(Actor, IsClear, SceneSt) ->
    case IsClear orelse ?is_coll(Actor) of
        true  ->
            Notify = maps:get(die_notify, Actor#actor.exargs, true),
            case Notify of
                true  -> scene_grid:leave(Actor, SceneSt);
                false -> scene_grid:leave(Actor)
            end;
        false ->
            scene_grid:leave(Actor)
    end,

    case scene_actor:get_actor(Actor#actor.killer) of
        ?nil   ->
            ignore;
        Killer ->
            case not ?is_role(Killer) andalso Killer#actor.owner > 0 of
                true  ->
                    case scene_actor:get_actor(Killer#actor.owner) of
                        ?nil  ->
                            scene_hook:hook_creep_dead(Killer, Actor, SceneSt),
                            creep_drop:drop(Killer, Actor, SceneSt),
                            catch log_api:log_boss_dead(Killer, Actor);
                        Owner ->
                            scene_hook:hook_creep_dead(Owner, Actor, SceneSt),
                            creep_drop:drop(Owner, Actor, SceneSt),
                            catch log_api:log_boss_dead(Killer, Actor)
                    end;
                false ->
                    scene_hook:hook_creep_dead(Killer, Actor, SceneSt),
                    creep_drop:drop(Killer, Actor, SceneSt),
                    catch log_api:log_boss_dead(Killer, Actor)
            end
    end,

    case scene_actor:get_actor(Actor#actor.uid) of
        ?nil   ->
            ignore;
        Actor2 ->
            buff_timer:del(Actor2),
            creep_agent:event(Actor2, hook_dead, ?nil)
    end,

    ?SUCCESS.

%% 掉落
drop(Actor, SceneSt) ->
    case scene_actor:get_actor(Actor#actor.killer) of
        ?nil   ->
            ignore;
        Killer ->
            scene_hook:hook_creep_dead(Killer, Actor, SceneSt),
            creep_drop:drop(Killer, Actor, SceneSt)
    end.


%% 重生
%% Millis : 重生间隔
reborn(Actor, SceneSt) ->
    Millis = maps:get(reborn, Actor#actor.aiargs),
    reborn(Actor, Millis, SceneSt).

reborn(Actor, Millis, SceneSt) ->
    case do_sleep(Actor, Millis, SceneSt) of
        ?RUNNING ->
            ?RUNNING;
        ?SUCCESS ->
            ?_if(?is_faker(Actor), ?bcast(
                scene_util:get_bc_roles(Actor),
                #m_scene_update_toc{del=[Actor#actor.uid]}
            )),
            do_del_creep(Actor),
            ActorID = scene_actor:get_autoid(),
            AIID    = creep_util:gen_ai(Actor#actor.id),
            Actor2  = Actor#actor{uid=ActorID, aiid=AIID},
            scene_actor:set_actor(Actor2),
            ?_if(AIID > 0, creep_agent:add_ai(Actor2)),
            ?SUCCESS
    end.


%% 消失
disappear(Actor, SceneSt) ->
    % ?debug(?is_faker(Actor), "~ts", ["消失"]),
    do_del_creep(Actor),
    scene_hook:hook_disappear(Actor, SceneSt),
    ?SUCCESS.


%% 移动
%% Step : 移动步数
move(Actor, SceneSt) ->
    try_move(Actor, ?STEP, SceneSt).

move(Actor, Step, SceneSt) ->
    try_move(Actor, Step, SceneSt).


%% 警戒
guard(Actor, SceneSt) ->
    Actor2 = find_enemy(Actor, SceneSt),
    scene_actor:set_actor(Actor2),
    case Actor2#actor.enemy == 0 of
        true  ->
            % ?debug(Actor#actor.id == 60000, "~ts ~w", ["警戒，没有敌人", Actor#actor.uid]),
            ?FAILURE;
        false ->
            % ?debug(Actor#actor.id == 60000, "~ts:~w ~w", ["警戒，有敌人", Actor#actor.uid, Actor2#actor.enemy]),
            ?SUCCESS
    end.


%% 巡逻
patrol(Actor, SceneSt) ->
    case try_move(Actor, SceneSt) of
        ?FAILURE ->
            % ?debug(Actor#actor.id == 11314002, "1111111", []),
            do_patrol(Actor, SceneSt);
        Result   ->
            % ?debug(Actor#actor.id == 11314002, "2222222:~w", [Result]),
            Result
    end.


%% 返回出生点
goback(Actor, SceneSt) ->
    case try_move(Actor, SceneSt) of
        ?FAILURE ->
            % ?debug(Actor#actor.id == 20201002, "~ts", ["返回出生点"]),
            do_goback(Actor, SceneSt);
        Result   ->
            Result
    end.


%% 追击
%% Enemy : #actor, 指定敌人
pursue(Actor, SceneSt) ->
    % ?debug(Actor#actor.id == 60000, "~ts", ["追击"]),
    case scene_actor:get_actor(Actor#actor.enemy) of
        ?nil  ->
            % ?debug("~ts", ["追击，敌人不存在"]),
            ?FAILURE;
        Enemy ->
            pursue(Actor, Enemy, SceneSt)
    end.

pursue(Actor, Enemy, SceneSt) ->
    case try_move(Actor, SceneSt) of
        ?FAILURE ->
            case scene_util:is_nearby(Actor, Enemy, Actor#actor.atkrad) of
                true  ->
                    ?SUCCESS;
                false ->
                    do_pursue(Actor, Enemy, SceneSt)
            end;
        Result   ->
            Result
    end.


%% 逃跑
escape(Actor, SceneSt) ->
    case try_move(Actor, SceneSt) of
        ?FAILURE ->
            do_escape(Actor, SceneSt);
        Result   ->
            Result
    end.


%% 准备攻击
prepare(Actor, _SceneSt) ->
    SkillID = creep_aiattack:prepare(Actor),
    case SkillID == 0 of
        true  ->
            % ?debug(Actor#actor.id == 60000, "~ts", ["准备攻击, 技能冷却中"]),
            ?FAILURE;
        false ->
            #cfg_creep{volume=Volume} = cfg_creep:find(Actor#actor.id),
            #cfg_skill_level{dist=Dist} = cfg_skill_level:find(SkillID, 1),
            AtkRad = Volume + max(0, Dist + Actor#actor.offset),
            Actor2 = Actor#actor{skill=SkillID, atkrad=AtkRad},
            scene_actor:set_actor(Actor2),
            % ?debug(Actor#actor.id == 60000, "~ts ~w", ["准备攻击", Actor2#actor.coord]),
            ?SUCCESS
    end.


%% 攻击
attack(Actor, SceneSt) ->
    try_attack(Actor, Actor#actor.skill, SceneSt).

attack(Actor, SkillID, SceneSt) ->
    try_attack(Actor, SkillID, SceneSt).

attack(Actor, SkillID, Enemy, SceneSt) ->
    creep_aiattack:attack(Actor, Enemy, SkillID, SceneSt).


%% 回血
heal(Actor, _SceneSt) ->
    % ?debug("~ts", ["回血"]),
    #actor{uid=ActorID, id=CreepID, attr=Attr, coord=Coord} = Actor,
    #cfg_creep{heal=Heal} = cfg_creep:find(CreepID),
    Hp    = ?_attr(Attr, ?ATTR_HP),
    HpMax = ?_attr(Attr, ?ATTR_HPMAX),
    case Hp < HpMax of
        true  ->
            Resume = round(HpMax * ?_per(Heal)),
            NewHp  = round( min(HpMax, Hp+Resume) ),
            Attr2  = ?_setattr(Attr, ?ATTR_HP, NewHp),
            Actor2 = Actor#actor{attr=Attr2},
            scene_actor:set_actor(Actor2),
            creep_agent:event(Actor2, hook_heal, Resume),
            scene_util:bc_to_grid(Coord, #m_actor_update_toc{
                uid   = ActorID,
                upint = #{"hp"=>NewHp}
            }),
            ?SUCCESS;
        false ->
            ?FAILURE
    end.


%% 分裂
fission(Actor, SceneSt = #scene_st{scene=SceneID}) ->
    #actor{id=CreepID, coord=Coord1=#p_coord{x=X, y=Y}} = Actor,
    case cfg_creep:aiargs(CreepID) of
        ?nil ->
            ?FAILURE;
        Args ->
            % ?debug("~ts:~w", ["分裂", CreepID]),
            Opts = #{
                exargs => #{
                    "fission_id" => Actor#actor.uid,
                    "fission_x"  => ut_math:floor(X),
                    "fission_y"  => ut_math:floor(Y)
                }
            },
            Creeps = lists:map(fun
                ({FissionID, OffsetX, OffsetY}) ->
                    Coord2 = #p_coord{x=X+OffsetX, y=Y+OffsetY},
                    case scene_util:walkable(SceneID, Coord2) of
                        true  -> {FissionID, Coord2, Opts};
                        false -> {FissionID, Coord1, Opts}
                    end
            end, Args),
            creep_agent:add(Creeps, SceneSt),
            ?SUCCESS
    end.


%% 加buff
buff(Actor, BuffID, _SceneSt) ->
    % ?debug("~ts:~w", ["加buff", {Actor#actor.uid, BuffID}]),
    do_add_buff(Actor, [BuffID]).


%% 预警
alarm(Actor, BuffID, _SceneSt) ->
    % ?debug("~ts", ["预警"]),
    do_add_buff(Actor, [BuffID]).


%% 愤怒
anger(Actor, SceneSt) ->
    case ?is_death(Actor#actor.state) orelse ?is_shield(Actor#actor.state) of
        true  ->
            ?FAILURE;
        false ->
            #actor{uid=ActorID, id=CreepID, attr=Attr} = Actor,
            {hook_injure, {_,DmgVal,NewHp}} = creep_util:get_event(ActorID),
            OldHp  = NewHp + DmgVal,
            HpMax  = ?_attr(Attr, ?ATTR_HPMAX),
            AIArgs = cfg_creep:aiargs(CreepID),
            case do_anger(AIArgs, OldHp, NewHp, HpMax) of
                ?nil ->
                    ?FAILURE;
                {skill, SkillID} ->
                    % ?debug("~ts:~w", ["愤怒skill", SkillID]),
                    creep_aiattack:attack(Actor, ?nil, SkillID, SceneSt);
                {buff, BuffID} when is_integer(BuffID) ->
                    % ?debug("~ts:~w", ["愤怒buff", BuffID]),
                    do_add_buff(Actor, [BuffID]);
                {buff, BuffIDs} when is_list(BuffIDs) ->
                    do_add_buff(Actor, BuffIDs)
            end
    end.


%% 冷静
calm(Actor, SceneSt) ->
    case ?is_death(Actor#actor.state) of
        true  ->
            ?FAILURE;
        false ->
            #actor{uid=ActorID, id=CreepID, attr=Attr} = Actor,
            {hook_heal, Resume} = creep_util:get_event(ActorID),
            CurHp  = ?_attr(Attr, ?ATTR_HP),
            HpMax  = ?_attr(Attr, ?ATTR_HPMAX),
            OldHp  = CurHp - Resume,
            AIArgs = cfg_creep:aiargs(CreepID),
            case do_calm(AIArgs, OldHp, CurHp, HpMax) of
                {buff, BuffID} when is_integer(BuffID) ->
                    % ?debug("~ts:~w", ["冷静buff", BuffID]),
                    do_del_buff(Actor, [BuffID], SceneSt);
                {buff, BuffIDs} when is_list(BuffIDs) ->
                    do_del_buff(Actor, BuffIDs, SceneSt);
                _ ->
                    ?FAILURE
            end
    end.


can_reborn(Actor, _SceneSt) ->
    Millis = maps:get(reborn, Actor#actor.aiargs, 0),
    Millis > 0.

can_attack(Actor, _SceneSt) ->
    case scene_actor:get_actor(Actor#actor.enemy) of
        ?nil  -> false;
        Enemy -> scene_util:is_nearby(Actor, Enemy, Actor#actor.atkrad)
    end.

%% 冲刺
rush(Actor, Mod, Fun, SceneSt) when is_atom(Mod), is_atom(Fun) ->
    {X, Y} = Mod:Fun(SceneSt),
    rush(Actor, X, Y, SceneSt);
rush(Actor, X, Y, SceneSt) when is_integer(X), is_integer(Y) ->
    Dest = #p_coord{x=X, y=Y},
    scene_actor:rush(Actor, Dest, SceneSt),
    ?SUCCESS.

clear_sleep(Actor, _SceneSt) ->
    Actor2 = Actor#actor{
        aidata = maps:remove(sleep, Actor#actor.aidata)
    },
    scene_actor:set_actor(Actor2),
    ?SUCCESS.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_sleep(Actor, Millis, _SceneSt) ->
    #actor{aidata=AIData} = Actor,
    case maps:find(sleep, AIData) of
        {ok, N} when N =< 0 ->
            AIData2 = maps:remove(sleep, AIData),
            scene_actor:set_actor(Actor#actor{aidata=AIData2}),
            ?SUCCESS;
        {ok, N} ->
            % ?debug(Actor#actor.aiid == 130002, "sleep:~w", [N]),
            AIData2 = maps:put(sleep, N-?LOOP_MILLIS, AIData),
            scene_actor:set_actor(Actor#actor{aidata=AIData2}),
            ?RUNNING;
        error ->
            AIData2 = maps:put(sleep, Millis, AIData),
            scene_actor:set_actor(Actor#actor{aidata=AIData2}),
            ?RUNNING
    end.

do_born(Actor, SceneSt) ->
    % ?debug(Actor#actor.aiid == 130001, "~ts:~w", ["出生", Actor#actor.uid]),
    InitAttr = creep_attr:calc(Actor, SceneSt),
    Actor2 = Actor#actor{
        name   = Actor#actor.name,
        state  = ?ACTOR_STATE_NORMAL,
        coord  = Actor#actor.born,
        dest   = Actor#actor.born,
        initattr = InitAttr,
        attr   = InitAttr,
        offset = ut_rand:choose([-50, -30, 0, 30, 50]),
        atkcd  = 0,
        aidata = #{},
        threat = #{},
        enemy  = 0,
        killer = 0,
        endcds = #{}
    },
    scene_actor:set_actor(Actor2),
    scene_grid:enter(Actor2, SceneSt),
    scene_hook:hook_born(Actor2, SceneSt),
    ?SUCCESS.

try_move(Actor, SceneSt) ->
    try_move(Actor, ?STEP, SceneSt).

try_move(Actor, Step, SceneSt) ->
    #actor{aidata=AIData, attr=Attr} = Actor,
    Speed = ?_attr(Attr, ?ATTR_SPEED),
    case Speed > 0 andalso maps:is_key(path, AIData) of
        true  ->
            AIData2 = case maps:is_key(step, AIData) of
                true  -> AIData;
                false -> maps:put(step, Step, AIData)
            end,
            Actor2 = Actor#actor{aidata=AIData2},
            do_move(Actor2, SceneSt);
        false ->
            % ?debug(Actor#actor.id == 11314002, "444444:~w", [Speed]),
            ?FAILURE
    end.

do_move(Actor, SceneSt) ->
    #actor{attr=Attr, coord=Coord1, aidata=AIData} = Actor,
    Path  = maps:get(path, AIData),
    Step  = maps:get(step, AIData),
    Speed = ?_attr(Attr, ?ATTR_SPEED),
    if
        Path == [] ->
            AIData2 = maps:remove(path, AIData),
            scene_actor:set_actor(Actor#actor{aidata=AIData2}),
            ?SUCCESS;
        ?is_death(Actor#actor.state);
        ?is_dizzy(Actor#actor.state);
        ?is_silent(Actor#actor.state);
        ?is_chaos(Actor#actor.state);
        ?is_immob(Actor#actor.state);
        ?is_palsy(Actor#actor.state);
        Speed == 0 ->
            AIData2 = maps:remove(path, AIData),
            scene_actor:set_actor(Actor#actor{aidata=AIData2}),
            ?FAILURE;
        true ->
            % 需要移动多少像素
            Move  = Speed * (?LOOP_MILLIS / 1000),
            {Coord2, Path2} = move_to(Path, Coord1, Move),
            scene_grid:move(Actor, Coord2, SceneSt),
            Step2 = Step - 1,
            case Step2 =< 0 orelse Path2 == [] of
                true  ->
                    AIData2 = maps:without([path,step], AIData),
                    Actor2  = Actor#actor{coord=Coord2, aidata=AIData2},
                    scene_actor:set_actor(Actor2),
                    ?SUCCESS;
                false ->
                    AIData1 = maps:put(step, Step2, AIData),
                    AIData2 = maps:put(path, Path2, AIData1),
                    Actor2  = Actor#actor{coord=Coord2, aidata=AIData2},
                    scene_actor:set_actor(Actor2),
                    ?RUNNING
            end
    end.

move_to([Coord2 | T] = Path, Coord1, Move) ->
    Dist = scene_util:calc_distance(Coord1, Coord2),
    if
        Dist =< 3 ->
            {Coord2, T};
        Move >= Dist ->
            move_to(T, Coord2, Move-Dist);
        Move < Dist ->
            #p_coord{x=X1, y=Y1} = Coord1,
            #p_coord{x=X2, y=Y2} = Coord2,
            X3 = X1 + (X2 - X1) * Move / Dist,
            Y3 = Y1 + (Y2 - Y1) * Move / Dist,
            {#p_coord{x=X3, y=Y3}, Path}
    end;
move_to([], Coord1, _Dist) ->
    {Coord1, []}.

find_enemy(Actor, SceneSt) ->
    Actor1 = find_in_threat(Actor, SceneSt),
    case Actor1#actor.enemy == 0 of
        true  ->
            #cfg_creep{type=Type} = cfg_creep:find(Actor#actor.id),
            Actor2 = case Type of
                ?CREEP_TYPE_ACTIVE  ->
                    find_in_sight(Actor1, SceneSt);
                ?CREEP_TYPE_PASSIVE ->
                    Actor1
            end,
            % ?debug(Actor#actor.id == 30201001, "~w", [Actor2#actor.enemy]),
            Actor2;
        false ->
            Actor1
    end.

find_in_threat(Actor, SceneSt) ->
    #cfg_creep{guard=Guard} = cfg_creep:find(Actor#actor.id),
    Enemies0 = fight_threat:sort(role, Actor#actor.threat),
    {Actor2, Enemies} = lists:foldl(fun
        ({EnemyID, _}, {AccActor, AccEnemies}) ->
            case scene_actor:get_actor(EnemyID) of
                ?nil  ->
                    AccActor2 = fight_threat:lose(AccActor, EnemyID),
                    {AccActor2, AccEnemies};
                Enemy ->
                    case is_nearby(Actor, Enemy, Guard, SceneSt) of
                        true  ->
                            {AccActor, [EnemyID | AccEnemies]};
                        false ->
                            AccActor2 = fight_threat:lose(AccActor, EnemyID),
                            {AccActor2, AccEnemies}
                    end
            end
    end, {Actor, []}, Enemies0),
    find_in_list(lists:reverse(Enemies), Actor2, SceneSt).

is_nearby(Actor, Enemy, Guard, SceneSt) ->
    scene == guard_area(Actor, SceneSt) orelse
    scene_util:is_nearby(get_center(Actor), Enemy#actor.coord, Guard).

find_in_sight(Actor, SceneSt) ->
    EnemyType = maps:get(enemy_type, Actor#actor.aiargs, ?ACTOR_TYPE_ROLE),
    GuardArea = guard_area(Actor, SceneSt),
    Enemies0  = case GuardArea == scene of
        true  -> scene_actor:get_actids(EnemyType);
        false -> scene_actor:get_actids(EnemyType, get_center(Actor))
    end,
    Enemies1 = lists:sort(Enemies0),
    % ?debug(Actor#actor.id == 30201001, "~w", [Enemies]),
    Actor1 = find_in_list(Enemies1, Actor, SceneSt),
    case Actor1#actor.enemy == 0 andalso EnemyType == ?ACTOR_TYPE_ROLE of
        true  ->
            Enemies2 = case GuardArea == scene of
                true  -> scene_actor:get_actids(?ACTOR_TYPE_ROBOT);
                false -> scene_actor:get_actids(?ACTOR_TYPE_ROBOT, get_center(Actor))
            end,
            find_in_list(Enemies2, Actor, SceneSt);
        false ->
            Actor1
    end.

guard_area(Actor, SceneSt) ->
    case ?is_dunge_scene(SceneSt) orelse ?is_act_scene(SceneSt) of
        true  ->
            #cfg_creep{guardarea=GuardArea} = cfg_creep:find(Actor#actor.id),
            GuardArea;
        false ->
            grid
    end.

find_in_list(Enemies, Actor, SceneSt) ->
    #cfg_creep{guard=Guard} = cfg_creep:find(Actor#actor.id),
    find_in_list2(Enemies, Actor, Guard, SceneSt).

find_in_list2([EnemyID | T], Actor, Guard, SceneSt) ->
    case EnemyID /= Actor#actor.uid andalso scene_actor:get_actor(EnemyID) of
        Enemy when is_record(Enemy, actor), (not (?is_coll(Enemy) orelse ?is_tomb(Enemy))) ->
            % ?debug(Actor#actor.id == 30201001, "2222222222222:~w", [{Coord1, Enemy#actor.coord, Guard}]),
            case is_nearby(Actor, Enemy, Guard, SceneSt) of
                true  ->
                    case fight_filter:check_injure(Actor, Enemy, SceneSt) of
                        ok -> Actor#actor{enemy=EnemyID};
                        _  -> find_in_list2(T, Actor, Guard, SceneSt)
                    end;
                false ->
                    Actor2 = fight_threat:lose(Actor, EnemyID),
                    find_in_list2(T, Actor2, Guard, SceneSt)
            end;
        _ ->
            Actor2 = fight_threat:lose(Actor, EnemyID),
            find_in_list2(T, Actor2, Guard, SceneSt)
    end;
find_in_list2([], Actor, _Guard, _SceneSt) ->
    Actor#actor{enemy=0}.

do_patrol(Actor, SceneSt) ->
    #actor{id=CreepID, born=Born, coord=Coord} = Actor,
    #cfg_creep{patrol=Patrol} = cfg_creep:find(CreepID),
    Dest = case scene_util:is_nearby(Born, Coord, Patrol) of
        true  ->
            % ?debug(Actor#actor.id == 11314002, "~ts", ["巡逻，随处走"]),
            creep_aipath:dest(around, Actor, ?nil, min(300, Patrol), SceneSt);
        false ->
            % ?debug(Actor#actor.id == 11314002, "~ts", ["巡逻，回出生点"]),
            Born
    end,
    Result = creep_aipath:find(Actor, Dest, SceneSt),
    % ?debug(Actor#actor.id == 11314002, "~w", [{Dest, Result}]),
    Result.

do_goback(Actor, SceneSt) ->
    #actor{born=Born, coord=Coord} = Actor,
    case scene_util:is_nearby(Born, Coord, ?OFFSET) of
        true  ->
            % ?debug(Actor#actor.id == 20201002, "~ts", ["返回成功"]),
            ?SUCCESS;
        false ->
            % ?debug(Actor#actor.id == 20201002, "~ts", ["返回寻路"]),
            creep_aipath:find(Actor, Born, SceneSt)
    end.

do_pursue(Actor, Enemy, SceneSt) ->
    #actor{id=CreepID, atkrad=AtkRad} = Actor,
    #actor{coord=Coord2} = Enemy,
    #cfg_creep{pursue=Pursue} = cfg_creep:find(CreepID),
    case scene == guard_area(Actor, SceneSt) orelse
         scene_util:is_nearby(get_center(Actor), Coord2, Pursue)
    of
        true  ->
            Dest = creep_aipath:dest(
                towards, Actor, Coord2, {offset,AtkRad}, SceneSt
            ),
            % ?debug(Actor#actor.id == 60000, "~ts ~w", ["追击", Dest]),
            creep_aipath:find(Actor, Dest, SceneSt);
        false ->
            % ?debug(Actor#actor.id == 60000, "~ts", ["追击，不在追击范围内"]),
            ?FAILURE
    end.

do_escape(Actor, SceneSt) ->
    case scene_actor:get_actor(Actor#actor.enemy) of
        ?nil  ->
            % ?debug("~ts", ["逃跑，敌人不存在"]),
            ?SUCCESS;
        Enemy ->
            % ?debug("~ts", ["逃跑，寻路"]),
            #actor{coord=Coord2} = Enemy,
            Dest = creep_aipath:dest(away, Actor, Coord2, 300, SceneSt),
            creep_aipath:find(Actor, Dest, SceneSt)
    end.

try_attack(Actor, SkillID, SceneSt) ->
    #actor{enemy=EnemyID, atkrad=AtkRad} = Actor,
    case scene_actor:get_actor(EnemyID) of
        ?nil  ->
            % ?debug(Actor#actor.id == 60000, "~ts", ["攻击，敌人不存在"]),
            ?FAILURE;
        Enemy ->
            case scene_util:is_nearby(Actor, Enemy, AtkRad+2*?OFFSET) of
                true  ->
                    % ?debug(Actor#actor.id == 60000, "~ts", ["攻击"]),
                    creep_aiattack:attack(Actor, Enemy, SkillID, SceneSt);
                false ->
                    % ?debug(Actor#actor.id == 60000, "~ts ~w", ["不在攻击范围", {scene_util:calc_distance(Actor#actor.coord, Enemy#actor.coord), AtkRad}]),
                    ?FAILURE
            end
    end.

do_anger([{HpPer, Type, Action} | T], OldHp, CurHp, MaxHp) ->
    TrigHp = MaxHp * ?_per(HpPer),
    % ?debug("do_anger---------------:~w", [{CurHp, TrigHp, OldHp, CurHp < TrigHp andalso TrigHp =< OldHp}]),
    case CurHp < TrigHp andalso TrigHp =< OldHp of
        true  -> {Type, Action};
        false -> do_anger(T, OldHp, CurHp, MaxHp)
    end;
do_anger([], _OldHp, _CurHp, _MaxHp) ->
    ?nil.

do_calm([{HpPer, Type, Action} | T], OldHp, CurHp, MaxHp) ->
    TrigHp = MaxHp * ?_per(HpPer),
    case OldHp < TrigHp andalso TrigHp =< CurHp of
        true  -> {Type, Action};
        false -> do_calm(T, OldHp, CurHp, MaxHp)
    end;
do_calm([], _OldHp, _CurHp, _MaxHp) ->
    ?nil.

do_add_buff(Actor, BuffIDs) ->
    buff_util:add_buffs(Actor, BuffIDs),
    ?SUCCESS.

do_del_buff(Actor, BuffIDs, _SceneSt) ->
    buff_util:del_buffs(Actor, BuffIDs),
    ?SUCCESS.

do_del_creep(Actor) ->
    scene_actor:del_actor(Actor#actor.uid),
    creep_agent:del_ai(Actor#actor.uid),
    creep_util:del_event(Actor#actor.uid).

get_center(Actor) ->
    case Actor#actor.center of
        born -> Actor#actor.born;
        self -> Actor#actor.coord
    end.
