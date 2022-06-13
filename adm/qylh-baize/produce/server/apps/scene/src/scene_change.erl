%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(scene_change).

-include("activity.hrl").
-include("attr.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([change/4, change/7]).
-export([check_enter_reqs/3]).
-export([post_enter/7]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%%-----------------------------------------------
%% @doc 切换场景
-spec change(ChgType, SceneID, Args, RoleSt) -> Return when
    ChgType :: integer(),
    SceneID :: integer(),
    Args    :: map(),
    RoleSt  :: #role_st{},
    Return  :: {ok, NewRoleSt :: #role_st{}} | error().
%%-----------------------------------------------
change(ChgType, SceneID, Args, RoleSt) ->
	% 检查是否能够切换
    check_can_change(ChgType, SceneID, Args, RoleSt),
	% 根据切换类型检查
    check_change_by_type(ChgType, SceneID, Args, RoleSt),
    scene_hook:pre_enter(SceneID, Args, RoleSt),
    change_by_type(ChgType, SceneID, Args, RoleSt).


%%-----------------------------------------------
%% @doc 场景跳转，不做检查
-spec change(integer(), integer(), integer(), #p_coord{}, list(), map(), #role_st{}) ->
    {ok, #role_st{}} | error().
%%-----------------------------------------------
change(ChgType, SceneID, RoomID, Coord, ExtraCost, Opts, RoleSt) ->
    do_change(ChgType, SceneID, RoomID, Coord, ExtraCost, Opts, RoleSt).


post_enter(ChgType, SceneID, RoomID, Actor, Actors, Lines, RoleSt) ->
    RoleAttr = #role_attr{attr=Attr} = role_data:get(?DB_ROLE_ATTR),
    Attr2 = ?_setattr(Attr, ?ATTR_HP, ?_attr(Attr,?ATTR_HPMAX)),
    role_data:set(RoleAttr#role_attr{attr=Attr2}),

    fight_collect:break(RoleSt),

    team_server:hook_enter(Actor#actor.uid, SceneID),

    case ChgType == ?SCENE_CHANGE_DUNGE of
        true  ->
            Action  = #{
                src_scene => RoleSt#role_st.scene,
                src_room  => RoleSt#role_st.room,
                src_line  => RoleSt#role_st.line,
                dst_scene => SceneID,
                dst_room  => RoomID,
                dst_line  => Actor#actor.line,
                dunge_id  => Actor#actor.dunge,
                guild_id  => RoleSt#role_st.guild,
                team_id   => RoleSt#role_st.team
            },
            role_logger:log(?ROLELOG_DUNGE_ENTER, Action, RoleSt);
        false ->
            ignore
    end,

    ?ucast(#m_scene_change_toc{
        scene   = SceneID,
        line    = Actor#actor.line,
        actor   = scene_util:p_actor(Actor),
        actors  = scene_util:p_actor(Actors),
        lines   = [scene_util:p_line(L) || L <- maps:values(Lines)],
        type    = ChgType,
        relogin = false
    }),

    #cfg_scene{type=Type, stype=SType} = cfg_scene:find(SceneID),
    Line = maps:get(Actor#actor.line, Lines),
    {ok, RoleSt#role_st{
        spid  = Line#line.spid,
        scene = SceneID,
        room  = RoomID,
        dunge = Actor#actor.dunge,
        floor = Actor#actor.floor,
        line  = Actor#actor.line,
        type  = Type,
        stype = SType,
        coord = Actor#actor.coord,
        jump  = make_jump(SceneID, RoleSt)
    }}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_can_change(ChgType, NewScene, _Args, RoleSt) ->
    % 检查场景切换限制
	check_change_limit(ChgType, NewScene, RoleSt),
    % 检查场景进入条件
    #cfg_scene{reqs=Reqs} = cfg_scene:find(NewScene),
    check_enter_reqs(NewScene, Reqs, RoleSt).

check_change_limit(ChgType, NewScene, RoleSt) ->
	#role_st{type=CurType, stype=CurSType, state=RoleState} = RoleSt,
    #cfg_scene{type=NewType, stype=NewSType} = cfg_scene:find(NewScene),

	{ValidTypes, ValidChanges, InvalidStates} = cfg_scene_change:find(NewType),
    case CurSType == NewSType andalso CurSType == ?SCENE_STYPE_THRONE of
        true  ->
            ok;
        false ->
            ?_check(lists:member(CurType, ValidTypes), ?ERR_SCENE_CHANGE_FORBID)
    end,
    ?_check(lists:member(ChgType, ValidChanges), ?ERR_SCENE_CHANGE_FORBID),
    IsMutexState = lists:member(RoleState, InvalidStates),
    ?_check(not IsMutexState, ?ERR_SCENE_DOING_OTHER, [RoleState]),
    % 如果是副本，只有副本类型相同的才可以直接切换
    case
        ChgType == ?SCENE_CHANGE_DUNGE andalso CurType == ?SCENE_TYPE_DUNGE
    of
    	true  -> ?_check(CurSType == NewSType, ?ERR_SCENE_CHANGE_FORBID);
    	false -> ok
    end.

check_enter_reqs(SceneID, [{level, LvLim} | T], RoleSt) ->
    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
    ?_check(RoleLv >= LvLim, ?ERR_SCENE_LEVEL_LIMIT, [SceneID]),
    check_enter_reqs(SceneID, T, RoleSt);
check_enter_reqs(SceneID, [{vip, VipLim} | T], RoleSt) ->
    ?_check(role_vip:get_level() >= VipLim, ?ERR_SCENE_VIPLV_LIMIT, [SceneID]),
    check_enter_reqs(SceneID, T, RoleSt);
check_enter_reqs(SceneID, [{task, TaskID} | T], RoleSt) ->
    ?_check(role_task:is_accept(TaskID), ?ERR_SCENE_TASK_UNFINISH),
    check_enter_reqs(SceneID, T, RoleSt);
check_enter_reqs(SceneID, [{act, ActID} | T], RoleSt) ->
    ?_check(activity:is_start(ActID), ?ERR_SCENE_NO_ACTIVITY),
    check_enter_reqs(SceneID, T, RoleSt);
check_enter_reqs(SceneID, [{yyact, YYActIDs} | T], RoleSt) when is_list(YYActIDs) ->
    ?_check(lists:any(fun(YYActID) -> yunying:is_start(YYActID) end, YYActIDs), ?ERR_SCENE_NO_ACTIVITY),
    check_enter_reqs(SceneID, T, RoleSt);
check_enter_reqs(SceneID, [{yyact, YYActID} | T], RoleSt) when is_integer(YYActID) ->
    ?_check(yunying:is_start(YYActID), ?ERR_SCENE_NO_ACTIVITY),
    check_enter_reqs(SceneID, T, RoleSt);
check_enter_reqs(SceneID, [{opdays, MinOpdays} | T], RoleSt) ->
    OpDays = game_env:get_opened_days(),
    ?_check(OpDays >= MinOpdays, ?ERR_GAME_SYS_OPENED),
    check_enter_reqs(SceneID, T, RoleSt);
check_enter_reqs(SceneID, [_ | T], RoleSt) ->
    check_enter_reqs(SceneID, T, RoleSt);
check_enter_reqs(_SceneID, [], _RoleSt) ->
    ok.


%% 传送阵
check_change_by_type(?SCENE_CHANGE_PROTAL, _NewScene, Args, RoleSt) ->
	#role_st{scene=CurScene, coord=CurCoord} = RoleSt,
    PortalID = maps:get(portal, Args),
	case scene_config:portal(CurScene, PortalID) of
	    {PortalCoord, _, _} ->
	        ?_check(
	            scene_util:is_nearby(CurCoord, PortalCoord),
	            ?ERR_SCENE_NOT_PORTAL
	        );
	    ?nil ->
	        throw(?err(?ERR_SCENE_NO_PORTAL))
	end;
%% 瞬移
check_change_by_type(?SCENE_CHANGE_TELE, _NewScene, _Args, _RoleSt) ->
    ok;
%% 小飞鞋
check_change_by_type(?SCENE_CHANGE_SHOES, NewScene, Args, RoleSt) ->
    ?_check(not ?is_escort(RoleSt#role_st.state), ?ERR_SCENE_FORBID_SHOES),
	Coord = maps:get(coord, Args),
	?_check(is_record(Coord, p_coord), ?ERR_GAME_BAD_ARGS),
    ?_check(scene_util:walkable(NewScene, Coord), ?ERR_SCENE_UNWALKABLE);
%% Boss场景
check_change_by_type(?SCENE_CHANGE_BOSS, NewScene, _Args, _RoleSt) ->
    #cfg_scene{stype=NewSType} = cfg_scene:find(NewScene),
    check_boss_times(NewSType);
%% 活动场景
check_change_by_type(?SCENE_CHANGE_ACT, NewScene, Args, _RoleSt) ->
	ActID = maps:get(act_id, Args),
	?_check(is_integer(ActID), ?ERR_GAME_BAD_ARGS),
    #cfg_scene{stype=SType} = cfg_scene:find(NewScene),
    if
        SType == ?SCENE_STYPE_GUILDHOUSE;
        SType == ?SCENE_STYPE_TIMEBOSS;
        SType == ?SCENE_STYPE_SIEGEWAR ->
            ok;
        SType == ?SCENE_STYPE_COMPETE_PREPARE ->
            ?_check(not activity:is_stop(ActID), ?ERR_SCENE_NO_ACTIVITY);
        true ->
            ?_check(activity:is_start(ActID), ?ERR_SCENE_NO_ACTIVITY)
    end;
%% 副本场景
check_change_by_type(?SCENE_CHANGE_DUNGE, NewScene, Args, RoleSt) ->
	#entry{dunge=NewDunge, floor=NewFloor} = maps:get(entry, Args),
    #cfg_dunge{type=Type, stype=SType} = cfg_dunge:find(NewDunge),
    case Type of
        ?DUNGE_TYPE_TEAM  ->
            case SType of
                ?SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER ->
                    ok;
                _ ->
                    ?_check(RoleSt#role_st.team > 0, ?ERR_SCENE_NO_TEAM)
            end;
        ?DUNGE_TYPE_GUILD ->
            ?_check(RoleSt#role_st.guild > 0, ?ERR_SCENE_NO_GUILD);
        _ ->
            ok
    end,
    #cfg_scene{stype=NewSType} = cfg_scene:find(NewScene),
	check_dunge_times(NewSType, NewFloor, Args).

check_boss_times(SType) when SType == ?SCENE_STYPE_BOSS_WILD;
                             SType == ?SCENE_STYPE_BOSS_PET ->
    CurTimes = role_count:get_scene_enter(SType),
    MaxTimes = dunge_util:max_boss_times(SType),
    ?_check(CurTimes < MaxTimes, ?ERR_SCENE_MAX_TIMES);
check_boss_times(_) ->
    ok.

check_dunge_times(?SCENE_STYPE_DUNGE_ARENA, _FloorID, _Opts) ->
    ok;
check_dunge_times(?SCENE_STYPE_DUNGE_YUNYING_TOWER, FloorID, _Opts) when FloorID >= 2 ->
    ok;
check_dunge_times(SType, _FloorID, Opts) ->
    TaskID = maps:get(task_id, Opts, 0),
    if
        TaskID > 0 ->
            ok;
        true ->
            MaxTimes = dunge_util:max_times(SType),
        	case MaxTimes > 0 of
        		true  ->
                    RestTimes = dunge_util:rest_times(SType),
        		    ?_check(RestTimes > 0, ?ERR_SCENE_MAX_TIMES);
        		false ->
        			ok
        	end
    end.

change_by_type(ChgType = ?SCENE_CHANGE_PROTAL, NewScene, Args, RoleSt) ->
	#role_st{scene=OldScene} = RoleSt,
	PortalID = maps:get(portal, Args),
	{_, NewScene, NewCoord} = scene_config:portal(OldScene, PortalID),
	do_change(ChgType, NewScene, 0, NewCoord, [], #{}, RoleSt);
change_by_type(ChgType = ?SCENE_CHANGE_TELE, NewScene, Args, RoleSt) ->
    NewCoord = scene_util:get_born(NewScene),
    do_change(ChgType, NewScene, 0, NewCoord, [], Args, RoleSt);
change_by_type(ChgType = ?SCENE_CHANGE_SHOES, NewScene, Args, RoleSt) ->
	NewCoord = maps:get(coord, Args),
	FlyCost  = scene_util:calc_fly_cost(),
    do_change(ChgType, NewScene, 0, NewCoord, FlyCost, #{}, RoleSt);
change_by_type(ChgType = ?SCENE_CHANGE_BOSS, NewScene, _Args, RoleSt) ->
    NewCoord = scene_util:get_born(NewScene),
    {ok, RoleSt2} = do_change(ChgType, NewScene, 0, NewCoord, [], #{}, RoleSt),
    #cfg_scene{stype=SType} = cfg_scene:find(NewScene),
    role_count:add_scene_enter(SType),
    {ok, RoleSt2};
change_by_type(ChgType = ?SCENE_CHANGE_ACT, NewScene0, Args, RoleSt) ->
	ActID = maps:get(act_id, Args),
    Entry = activity_hook:get_entry(ActID, NewScene0, RoleSt),
    #entry{scene=NewScene, room=NewRoom, coord=NewCoord, opts=EnterOpts} = Entry,
    {ok, RoleSt2} = do_change(ChgType, NewScene, NewRoom, NewCoord, [], EnterOpts, RoleSt),
    #cfg_scene{stype=SType} = cfg_scene:find(NewScene),
    role_count:add_scene_enter(SType),
    #cfg_activity{group=ActGroup} = cfg_activity:find(ActID),
    role_event:event(?EVENT_ACTIVITY_JOIN, ActGroup),
    activity_stat:join(RoleSt#role_st.role, ActID),
    {ok, RoleSt2};
change_by_type(ChgType = ?SCENE_CHANGE_DUNGE, NewScene, Opts, RoleSt) ->
    Entry = maps:get(entry, Opts),
    Merge = maps:get(merge_times, Opts, 1),
    TaskID = maps:get(task_id, Opts, 0),

    #entry{
        stype=SType, dunge=DungeID, coord=Coord, room=RoomID, floor=FloorID
    } = Entry,

    {ok, MergeTimes, MergeCost} = dunge_util:calc_merge(NewScene, Merge),

    RoleDunge = #role_dunge{enter=Enter} = role_data:get(?DB_ROLE_DUNGE),
    NowTime = ut_time:seconds(),
    ClrCost = calc_clear_cost(SType, NowTime, maps:get(SType, Enter, 0)),

    Succ = fun() ->
        ensure_not_same(NewScene, RoomID, RoleSt),

        #cfg_dunge{type=DungeType} = cfg_dunge:find(DungeID),
        % 运营活动副本支持个人与组队方式进入
        case DungeType == ?DUNGE_TYPE_ROLE orelse DungeType == ?DUNGE_TYPE_TEAM of
            true  ->
                CreateOpts = scene_hook:create_opts(Entry, RoleSt),
                {ok, _} = scene:create(NewScene, RoomID, CreateOpts);
            false ->
                ignore
        end,
        EnterOpts  = scene_hook:enter_opts(Entry, RoleSt),
        EnterOpts2 = maps:merge(EnterOpts, #{merge_times=>MergeTimes}),

        {ok, RoleSt1} = do_change2(
            ChgType, NewScene, RoomID, Coord, EnterOpts2, RoleSt
        ),

        RoleDunge2 = RoleDunge#role_dunge{enter=maps:put(SType, NowTime, Enter)},
        role_data:set(RoleDunge2),

        if
            SType == ?SCENE_STYPE_DUNGE_MOUNT ->
                role_count:add_scene_enter(DungeID, MergeTimes);
            SType == ?SCENE_STYPE_DUNGE_ARENA ->
                % 竞技场次数自己管理
                ignore;
            SType == ?SCENE_STYPE_DUNGE_YUNYING_TOWER, FloorID >= 2 ->
                % 运营爬塔活动只计算第1层的次数
                ignore;
            TaskID > 0 ->
                case role_task:get_task(TaskID) of
                    error ->
                        role_count:add_scene_enter(SType, MergeTimes);
                    _ ->
                        % 通过任务进入的，不扣除次数
                        ignore
                end;
            true ->
                role_count:add_scene_enter(SType, MergeTimes)
        end,

        if
            SType == ?SCENE_STYPE_DUNGE_RACE ->
                dunge_race:add_enter_times();
            true ->
                ignore
        end,

        RoleSt1
    end,

    ExtraCost = ClrCost ++ MergeCost,
    {ok, RoleSt2} = cost_and_change(
        NewScene, DungeID, FloorID, MergeTimes, ExtraCost, Succ, RoleSt
    ),
    log_api:log_dunge(DungeID, SType, ?DUNGE_OP_ENTER, MergeTimes, RoleSt),
    SType == ?SCENE_STYPE_GUILDGUARD andalso activity_stat:join(RoleSt#role_st.role, 10221),
    {ok, RoleSt2}.

cost_and_change(SceneID, DungeID, FloorID, MergeTimes, ExtraCost, DealSucc, RoleSt) ->
    EnterCost = calc_enter_cost(SceneID, DungeID, FloorID, MergeTimes, RoleSt),
    ForceCost = calc_force_cost(SceneID, DungeID, FloorID, MergeTimes, RoleSt),
    Cost = EnterCost ++ ForceCost ++ ExtraCost,
    {ok, _, RoleSt2} = role_bag:cost(Cost, ?LOG_SCENE_ENTER, DealSucc, RoleSt),
    {ok, RoleSt2}.

do_change(ChgType, SceneID, RoomID, Coord, ExtraCost, Opts, RoleSt) ->
    Succ = fun() ->
        ensure_not_same(SceneID, RoomID, RoleSt),
        {ok, RoleSt2} = do_change2(ChgType, SceneID, RoomID, Coord, Opts, RoleSt),
        RoleSt2
    end,
    MergeTimes = maps:get(merge_times, Opts, 1),
    cost_and_change(SceneID, 0, 0, MergeTimes, ExtraCost, Succ, RoleSt).

calc_enter_cost(SceneID, DungeID, FloorID, MergeTimes, _RoleSt) ->
    #cfg_scene{stype=SceneSType} = cfg_scene:find(SceneID),
    #cfg_scene_cost{type=Type, cost=Cost} = cfg_scene:cost(SceneID),
    if
        SceneSType == ?SCENE_STYPE_DUNGE_YUNYING_TOWER, FloorID >= 2 ->
            [];
        SceneSType == ?SCENE_STYPE_DUNGE_MOUNT ->
            EnterTimes = role_count:get_scene_enter(DungeID),
            calc_cost_by_times(Cost, EnterTimes+1, MergeTimes, []);
        Type == ?SCENE_COST_FIXED ->
            role_bag:multiple(Cost, MergeTimes);
        Type == ?SCENE_COST_TIMES ->
            EnterTimes = role_count:get_scene_enter(SceneSType),
            calc_cost_by_times(Cost, EnterTimes+1, MergeTimes, [])
    end.

calc_cost_by_times(_CostInfo, _EnterTimes, 0, Acc) ->
    Acc;
calc_cost_by_times([], _EnterTimes, _MergeTimes, Acc) ->
    Acc;
calc_cost_by_times([{Min, Max, Cost} | T], EnterTimes, MergeTimes, Acc) ->
    case Min =< EnterTimes andalso EnterTimes =< Max of
        true  -> calc_cost_by_times(T, EnterTimes+1, MergeTimes-1, Cost++Acc);
        false -> calc_cost_by_times(T, EnterTimes, MergeTimes, Acc)
    end.

calc_force_cost(SceneID, _DungeID, _FloorID, MergeTimes, RoleSt) ->
    #cfg_scene_cost{free=Reqs, force=Cost} = cfg_scene:cost(SceneID),
    case check_can_free(Reqs, RoleSt) of
        true  -> [];
        false -> role_bag:multiple(Cost, MergeTimes)
    end.

check_can_free([{level, LvLim} | T], RoleSt) ->
    RoleInfo = role_data:get(?DB_ROLE_INFO),
    case RoleInfo#role_info.level >= LvLim of
        true  -> check_can_free(T, RoleSt);
        false -> false
    end;
check_can_free([{vip, VipLim} | T], RoleSt) ->
    case role_vip:get_level() >= VipLim of
        true  -> check_can_free(T, RoleSt);
        false -> false
    end;
check_can_free([], _RoleSt) ->
    true.

calc_clear_cost(SType, NowTime, LastTime) ->
    #cfg_dunge_enter{cd=EnterCD, clrcd=ClrCost} = cfg_dunge:enter(SType),
    ?_if(NowTime-LastTime >= EnterCD, [], ClrCost).

ensure_not_same(NewScene, NewRoom, RoleSt) ->
    #role_st{scene=OldScene, room=OldRoom} = RoleSt,
    IsSame = OldScene == NewScene andalso OldRoom == NewRoom,
    ?_check(not IsSame, ?ERR_SCENE_SAME_SCENE).

do_change2(ChgType, NewScene, NewRoom, NewCoord, Opts, RoleSt) ->
	#role_st{role=RoleID, spid=OldSPid, state=State} = RoleSt,
    NewLine = if
        ?is_mchunt(State) ->
            #role_mchunt{scene=HuntScene} = role_data:get(?DB_ROLE_MCHUNT),
            ?_if(NewScene == HuntScene, ?MAIN_LINE, 0);
        true ->
            0
    end,
    {ok, Actor, Actors, Lines} = scene_manager:change(
        NewScene, NewRoom, NewLine, OldSPid, RoleID, NewCoord, Opts
    ),
    post_enter(ChgType, NewScene, NewRoom, Actor, Actors, Lines, RoleSt).

make_jump(NewScene, RoleSt) ->
    #cfg_scene{type=NewType, stype=NewSType, jump=SetJump} = cfg_scene:find(NewScene),
    #role_st{
        scene=CurScene, type=CurType, stype=CurSType,
        room=CurRoom, coord=CurCoord0
    } = RoleSt,
    CurCoord = if
        % 新手蜘蛛副本
        NewScene == 60007 ->
            {X,Y} = cfg_game:newbie_60007(),
            #p_coord{x=X, y=Y};
        true ->
            CurCoord0
    end,
    Jump = #site{scene=CurScene, room=CurRoom, coord=CurCoord},
    case SetJump of
        true when CurScene == ?nil ->
            Jump;
        true when CurSType == ?SCENE_STYPE_COMPETE_BATTLE,
                  NewSType == ?SCENE_STYPE_COMPETE_PREPARE ->
            ?debug("make_jump111-----------------------~w", [RoleSt#role_st.jump]),
            RoleSt#role_st.jump;
        true ->
            ?_if(CurType == NewType, RoleSt#role_st.jump, Jump);
        false when NewSType == ?SCENE_STYPE_COMPETE_BATTLE ->
            ?debug("make_jump222-----------------------~w", [RoleSt#role_st.jump]),
            RoleSt#role_st.jump;
        false ->
            ?nil
    end.
