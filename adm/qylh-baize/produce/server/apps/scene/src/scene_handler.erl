%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(scene_handler).

-include("dunge.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 切换场景
handle(?SCENE_CHANGE, Tos, RoleSt) ->
    #m_scene_change_tos{
        scene=SceneID, type=ChType, coord=Coord, portal=Portal, act_id=ActID
    } = Tos,
    Args = #{coord=>Coord, portal=>Portal, act_id=>ActID},
    scene_change:change(ChType, SceneID, Args, RoleSt);

%% 切换分线
handle(?SCENE_SWITCH, Tos, RoleSt) ->
    #role_st{
        scene=SceneID, room=RoomID, line=OldLID, spid=OldSPid,
        role=RoleID, state=State
    } = RoleSt,
    #m_scene_switch_tos{line=NewLID} = Tos,
    ?_check(NewLID /= OldLID, ?ERR_SCENE_SAME_LINE),
    CanSwitch = not (?is_mchunt(State) andalso NewLID /= ?MAIN_LINE),
    ?_check(CanSwitch, ?ERR_SCENE_MCHUNTING),
    {ok, Actor, Actors, Lines} =
        scene_manager:switch(SceneID, RoomID, NewLID, OldSPid, RoleID),
    fight_collect:break(RoleSt),
    RoleSt2 = RoleSt#role_st{
        spid  = Actor#actor.spid,
        line  = NewLID,
        coord = Actor#actor.coord
    },
    ?ucast(#m_scene_change_toc{
        scene   = SceneID,
        line    = NewLID,
        actor   = scene_util:p_actor(Actor),
        actors  = scene_util:p_actor(Actors),
        lines   = [scene_util:p_line(L) || L <- maps:values(Lines)],
        type    = 0,
        relogin = false
    }),
    {ok, RoleSt2};

%% 离开副本
handle(?SCENE_LEAVE, Tos, RoleSt) ->
    #role_st{scene=CurScene, jump=Jump} = RoleSt,
    ?debug("leave scene: ~w", [{RoleSt#role_st.role, CurScene, Jump}]),
    #cfg_scene{type=Type, stype=SType} = cfg_scene:find(CurScene),
    ?_check(check_can_leave(Type, SType), ?ERR_SCENE_NOTIN_DUNGE),
    #m_scene_leave_tos{mchunt=ToMcHunt} = Tos,
    case ToMcHunt of
        true  ->
            RoleMcHunt = role_data:get(?DB_ROLE_MCHUNT),
            #role_mchunt{scene=SceneID0} = RoleMcHunt,
            case SceneID0 == 0 of
                true  ->
                    #site{scene=SceneID, coord=Coord} = Jump;
                false ->
                    SceneID = SceneID0,
                    Coord   = scene_util:get_born(SceneID0)
            end;
        false when Jump == ?nil ->
            SceneID = cfg_game:capital(),
            Coord   = scene_util:get_born(SceneID);
        false ->
            #site{scene=SceneID, coord=Coord} = Jump
    end,
    {ok, RoleSt1} = scene_change:change(
        ?SCENE_CHANGE_LEAVE, SceneID, 0, Coord, [], #{}, RoleSt
    ),
    RoleSt2 = RoleSt1#role_st{jump=?nil},
    {ok, #m_scene_leave_toc{scene=SceneID}, RoleSt2};

%% 走向哪个点
handle(?SCENE_DEST, Tos, RoleSt) ->
    #m_scene_dest_tos{dest=Dest, dir=Dir, state=State} = Tos,
    #role_st{role=RoleID, spid=ScenePid} = RoleSt,
    scene:cast(ScenePid, {walk, RoleID, Dir, Dest, State});

%% 移动
handle(?SCENE_MOVE, Tos, RoleSt) ->
    #m_scene_move_tos{x=X, y=Y} = Tos,
    Coord = #p_coord{x=X, y=Y},
    check_move(Coord, RoleSt),
    #role_st{role=RoleID, spid=ScenePid} = RoleSt,
    scene:cast(ScenePid, {move, RoleID, Coord}),
    fight_collect:break(RoleSt),
    Toc = #m_scene_move_toc{x=X, y=Y},
    {ok, Toc, RoleSt#role_st{coord=Coord}};

%% 瞬移
handle(?SCENE_TELEPORT, Tos, RoleSt) ->
    #m_scene_teleport_tos{dest=Coord, type=Type} = Tos,
    check_teleport(Coord, Type, RoleSt),
    #role_st{role=RoleID, spid=ScenePid} = RoleSt,
    Succ = fun() -> scene:cast(ScenePid, {tele, RoleID, Coord}) end,
    Cost = scene_util:calc_fly_cost(),
    role_bag:cost(Cost, ?LOG_SCENE_TELE, Succ, RoleSt),
    fight_collect:break(RoleSt),
    Toc  = #m_scene_teleport_toc{uid=RoleID, type=Type, dest=Coord},
    {ok, Toc, RoleSt#role_st{coord=Coord}};

%% 冲刺
handle(?SCENE_RUSH, Tos, RoleSt) ->
    #m_scene_rush_tos{coord=Coord} = Tos,
    check_rush(Coord, RoleSt),
    #role_st{role=RoleID, spid=ScenePid} = RoleSt,
    scene:cast(ScenePid, {rush, RoleID, Coord}),
    fight_collect:break(RoleSt),
    {ok, RoleSt#role_st{coord=Coord}};

%% NPC 对话
handle(?SCENE_TALK, Tos, RoleSt) ->
    #m_scene_talk_tos{npc_id=NpcID, task_id=TaskID} = Tos,
    check_talk(NpcID, RoleSt),
    role_event:event(?EVENT_TALK, {NpcID, TaskID}),
    fight_collect:break(RoleSt),
    ?ucast(#m_scene_talk_toc{npc_id=NpcID, task_id=TaskID});

%% 跳跃
handle(?SCENE_JUMP, Tos, RoleSt) ->
    #m_scene_jump_tos{dest=Dest, type=Type} = Tos,
    #role_st{spid=ScenePid, role=RoleID} = RoleSt,
    check_jump(Dest, Type, RoleSt),
    scene:cast(ScenePid, {jump, RoleID, Dest, Type}),
    fight_collect:break(RoleSt),
    {ok, RoleSt#role_st{coord=Dest}};

handle(?ACTOR_ADD_BUFF, Tos, RoleSt) ->
    #m_actor_add_buff_tos{uid=ActorID, id=BuffID} = Tos,
    #role_st{spid=ScenePid, stype=SceneSType, scene=SceneID} = RoleSt,
    check_manu_operate(SceneSType, SceneID, BuffID),
    Opts = if
        % 怒气buff
        BuffID == 300410016 ->
            #{value=>cfg_game:max_anger(), cover=>true};
        true ->
            #{}
    end,
    case is_integer(ActorID) andalso ActorID > 0 of
        true  -> scene:cast(ScenePid, {add_buffs, ActorID, [{BuffID, Opts}]});
        false -> buff:add([{BuffID, Opts}], RoleSt)
    end;

handle(?ACTOR_DEL_BUFF, Tos, RoleSt) ->
    #m_actor_del_buff_tos{uid=ActorID, id=BuffID} = Tos,
    #role_st{spid=ScenePid, stype=SceneSType, scene=SceneID} = RoleSt,
    check_manu_operate(SceneSType, SceneID, BuffID),
    case is_integer(ActorID) andalso ActorID > 0 of
        true  -> scene:cast(ScenePid, {del_buffs, ActorID, [BuffID]});
        false -> buff:del([BuffID], RoleSt)
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_can_leave(?SCENE_TYPE_BOSS, _SType) ->
    true;
check_can_leave(?SCENE_TYPE_DUNGE, _SType) ->
    true;
check_can_leave(?SCENE_TYPE_ACT, _SType) ->
    true;
check_can_leave(_Type, _SType) ->
    false.

check_move(Coord, RoleSt) ->
    ensure_walkable(RoleSt#role_st.scene, Coord),
    % todo 检测速度
    ok.

check_teleport(Coord2, Type, RoleSt) ->
    #role_st{scene=SceneID, coord=_Coord1} = RoleSt,
    case Type of
        ?TELEPORT_SHOES ->
            #cfg_scene{tele=CanTele} = cfg_scene:find(SceneID),
            ?_check(CanTele, ?ERR_SCENE_CANNOT_TELE);
        _ ->
            throw(?err(?ERR_GAME_BAD_ARGS))
    end,
    ensure_walkable(SceneID, Coord2),
    ok.

check_rush(Coord2, RoleSt) ->
    #role_st{scene=SceneID, coord=Coord1} = RoleSt,
    Path = scene_path_stupid:find(SceneID, Coord1, Coord2),
    ?_check(Path /= false, ?ERR_FIGHT_BLOCKED),
    ok.

check_talk(NpcID, RoleSt) ->
    Npcs = scene_config:npcs(RoleSt#role_st.scene),
    ?_check(lists:keymember(NpcID, 1, Npcs), ?ERR_SCENE_NO_NPC).

check_jump(Dest, Type, RoleSt) ->
    #role_st{scene=SceneID, coord=Coord} = RoleSt,
    ensure_walkable(SceneID, Dest),
    case Type == ?JUMP_TYPE_NORMAL of
        true  -> ok;
        false -> ensure_jumpable(SceneID, Coord)
    end.

ensure_walkable(SceneID, Coord) ->
    ?_check(scene_util:walkable(SceneID, Coord), ?ERR_SCENE_UNWALKABLE).

ensure_jumpable(SceneID, Coord) ->
    ?_check(scene_config:jumpable(SceneID, Coord), ?ERR_SCENE_UNJUMPABLE).

check_manu_operate(SceneSType, SceneID, BuffID) ->
    CanManu = [
          {?SCENE_STYPE_CANDYROOM, 130150018}
        , {?SCENE_STYPE_DUNGE_NEWBIE_SUMMON, 220410003}
        , {?SCENE_STYPE_DUNGE_NEWBIE_ANGER, 300410016}
    ],
    IsValid = lists:member({SceneSType,BuffID}, CanManu)
        orelse lists:member({SceneID,BuffID}, CanManu),
    ?_check(IsValid, ?ERR_GAME_BAD_ARGS).
