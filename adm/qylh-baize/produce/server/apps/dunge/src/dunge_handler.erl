%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_handler).

-include("dunge.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("ranking.hrl").
-include("faker.hrl").
-include("task.hrl").

%% API
-export([handle/3]).
-export([match_succ/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 副本面板信息
handle(?DUNGE_PANEL, Tos, RoleSt) ->
    #m_dunge_panel_tos{stype=SType} = Tos,
    Mod = scene_router:route(?SCENE_TYPE_DUNGE, SType),
    Mod:handle(?DUNGE_PANEL, RoleSt);

%% 进入下一关
handle(?DUNGE_ENTER, Tos, RoleSt) when Tos#m_dunge_enter_tos.next == true ->
    Opts = #{dunge:=DungeID, floor:=FloorID} = dunge_util:get_next(RoleSt),
    #role_st{spid=ScenePid, stype=SType} = RoleSt,
    DungeSt = scene:sync_route(ScenePid, fun() -> dunge_util:get_state() end),
    ?_check(DungeSt#dunge_st.clear, ?ERR_DUNGE_NOT_CLEAR_PRE),
    Entry  = dunge_util:get_entry(Opts, RoleSt),
    Entry2 = Entry#entry{dunge=DungeID, floor=FloorID},
    Opts2  = #{entry=>Entry2},
    check_enter(SType, DungeID, Opts2, RoleSt),
    scene_change:change(?SCENE_CHANGE_DUNGE, Entry#entry.scene, Opts2, RoleSt);

%% 进入副本
handle(?DUNGE_ENTER, Tos, RoleSt) ->
    #m_dunge_enter_tos{stype=SType, id=DungeID, floor=FloorID, merge=Merge, args=Args} = Tos,
    Opts1 = #{stype=>SType, dunge=>DungeID, floor=>FloorID},
    Entry = dunge_util:get_entry(Opts1, RoleSt),
    Opts2 = #{entry=>Entry, merge_times=>Merge,
        task_id => maps:get("task_id", Args, 0)},
    #entry{stype=SType2, dunge=DungeID2, scene=SceneID2} = Entry,
    check_enter(SType2, DungeID2, Opts2, RoleSt),
    scene_change:change(?SCENE_CHANGE_DUNGE, SceneID2, Opts2, RoleSt);

%% 副本信息
handle(?DUNGE_INFO, _Tos, RoleSt) ->
    ensure_in_dunge(RoleSt),
    #role_st{spid=ScenePid, type=Type, stype=SType, role=RoleID} = RoleSt,
    Mod = scene_router:route(Type, SType),
    ?_if(Mod /= ?nil, scene:route(ScenePid, Mod, send_info, RoleID));

%% 副本开始
handle(?DUNGE_START, _Tos, RoleSt) ->
    erlang:send(RoleSt#role_st.spid, start);

%% 副本鼓舞
handle(?DUNGE_INSPIRE, Tos, RoleSt) ->
    ensure_in_dunge(RoleSt),
    #role_st{spid=ScenePid, stype=SType} = RoleSt,
    #m_dunge_inspire_tos{type=InspType} = Tos,
    Mod = scene_router:route(?SCENE_TYPE_DUNGE, SType),
    Msg = {?DUNGE_INSPIRE, get, InspType},
    {ok, RestTimes, Cost} = scene:sync_route(ScenePid, Mod, handle, Msg),
    ?_check(RestTimes > 0, ?ERR_DUNGE_INSPIRE_MAX),
    role_bag:cost(Cost, ?LOG_DUNGE_INSPIRE, RoleSt),
    scene:route(ScenePid, Mod, handle, {?DUNGE_INSPIRE, do, InspType}),
    role_event:event(?EVENT_DUNGE_INSPIRE),
    ?ucast(#m_dunge_inspire_toc{type=InspType});

%% 结束副本
handle(?DUNGE_OVER, _Tos, RoleSt) ->
    ensure_in_dunge(RoleSt),
    #cfg_dunge{type=Type} = cfg_dunge:find(RoleSt#role_st.dunge),
    ?_check(Type /= ?DUNGE_TYPE_GUILD, ?ERR_GAME_BAD_ARGS),
    #role_st{spid=ScenePid, role=RoleID} = RoleSt,
    erlang:send(ScenePid, {over, RoleID});

%% 购买次数
handle(?DUNGE_BUYTIMES, Tos, RoleSt) ->
    #m_dunge_buytimes_tos{stype=SType} = Tos,
    Mod = scene_router:route(?SCENE_TYPE_DUNGE, SType),
    case Mod == ?nil of
        true  ->
            do_buy(SType, RoleSt);
        false ->
            code:ensure_loaded(Mod),
            case erlang:function_exported(Mod, buy_times, 2) of
                true ->
                    Mod:buy_times(SType, RoleSt);
                false ->
                    do_buy(SType, RoleSt)
            end
    end;

%% 清除CD
handle(?DUNGE_CLEARCD, Tos, RoleSt) ->
    #m_dunge_clearcd_tos{stype=SType} = Tos,
    RoleDunge = #role_dunge{enter=Enter} = role_data:get(?DB_ROLE_DUNGE),
    LastTime = maps:get(SType, Enter, 0),
    NowTime  = ut_time:seconds(),
    #cfg_dunge_enter{cd=EnterCD, clrcd=ClrCost} = cfg_dunge:enter(SType),
    ?_check(NowTime - LastTime < EnterCD, ?ERR_DUNGE_NO_CD),
    role_bag:cost(ClrCost, ?LOG_DUNGE_CLEAR_CD, RoleSt),
    role_data:set(RoleDunge#role_dunge{enter=maps:remove(SType, Enter)}),
    ?ucast(#m_dunge_clearcd_toc{stype=SType});

%% 扫荡
handle(?DUNGE_SWEEP, Tos, RoleSt) ->
    #m_dunge_sweep_tos{stype=SType, floor=FloorID, args=Args} = Tos,
    RoleDunge = role_data:get(?DB_ROLE_DUNGE),
    check_sweep(SType, RoleDunge, FloorID),
    Mod = scene_router:route(?SCENE_TYPE_DUNGE, SType),
    case Mod:handle({?DUNGE_SWEEP, FloorID, Args}, RoleSt) of
        {times, Times} ->
            [role_event:event(?EVENT_DUNGE_ENTER, {SType, 0, 0}) || _ <- lists:seq(1, Times)],
            log_api:log_dunge(0, SType, ?DUNGE_OP_SWEEP, Times, RoleSt);
        _ ->
            role_event:event(?EVENT_DUNGE_ENTER, {SType, 0, 0}),
            log_api:log_dunge(0, SType, ?DUNGE_OP_SWEEP, 1, RoleSt)
    end,
    role_count:add_scene_sweep(SType);

%% 领取奖励
handle(?DUNGE_FETCH, Tos, RoleSt) ->
    #m_dunge_fetch_tos{stype=SType, type=Type} = Tos,
    Mod = scene_router:route(?SCENE_TYPE_DUNGE, SType),
    Mod:handle({?DUNGE_FETCH, Type}, RoleSt);

%% 抽奖信息
handle(?DUNGE_LOTOINFO, Tos, RoleSt) ->
    #m_dunge_lotoinfo_tos{stype=SType} = Tos,
    Mod = scene_router:route(?SCENE_TYPE_DUNGE, SType),
    Mod:handle(?DUNGE_LOTOINFO, RoleSt);

%% 抽奖
handle(?DUNGE_LOTO, Tos, RoleSt) ->
    #m_dunge_loto_tos{stype=SType} = Tos,
    Mod = scene_router:route(?SCENE_TYPE_DUNGE, SType),
    Mod:handle(?DUNGE_LOTO, RoleSt);

handle(?DUNGE_MOUNT_PANEL, _Tos, RoleSt) ->
    dunge_mount:handle(?DUNGE_MOUNT_PANEL, RoleSt);

handle(?DUNGE_QUESTION_ANSWER, Tos, RoleSt) ->
    ensure_in_dunge(RoleSt),
    #m_dunge_question_answer_tos{stype=SType, answer=Answer} = Tos,
    Mod = scene_router:route(?SCENE_TYPE_DUNGE, SType),
    Mod:handle({?DUNGE_QUESTION_ANSWER, SType, Answer}, RoleSt);

handle(?DUNGE_BUY_TIMES_ASK, Tos, RoleSt) ->
    #m_dunge_buy_times_ask_tos{stype=SType} = Tos,
    Mod = scene_router:route(?SCENE_TYPE_DUNGE, SType),
    Mod:handle({?DUNGE_BUY_TIMES_ASK, SType}, RoleSt);

handle(?DUNGE_SOUL_PANEL, _Tos, RoleSt) ->
    dunge_soul:handle(?DUNGE_SOUL_PANEL, RoleSt);

handle(?DUNGE_SOUL_SELECT, Tos, RoleSt) ->
    dunge_soul:handle({?DUNGE_SOUL_SELECT, Tos}, RoleSt);

handle(?DUNGE_SOUL_START, _Tos, RoleSt) ->
    dunge_soul:handle(?DUNGE_SOUL_START, RoleSt);

handle(?DUNGE_SOUL_SUMMON, Tos, RoleSt) ->
    dunge_soul:handle({?DUNGE_SOUL_SUMMON, Tos}, RoleSt);

handle(?DUNGE_MATCH_START, Tos, RoleSt) ->
    #m_dunge_match_start_tos{stype=SType, task_id=TaskID} = Tos,
    ?_if(TaskID == 0, check_enter_times(SType)),
    ?ucast(#m_dunge_match_start_toc{stype=SType, task_id=TaskID}),
    if
        TaskID > 0 ->
            Sec = 3;
        true ->
            Sec = ut_rand:random(1, 10)
    end,
    Timer = erlang:send_after(timer:seconds(Sec), self(),
        {'$gen_cast', {route, ?MODULE, match_succ}}),
    erlang:put({?MODULE, timer}, Timer);

handle(?DUNGE_MATCH_STOP, Tos, RoleSt) ->
    #m_dunge_match_stop_tos{stype=SType} = Tos,
    case erlang:erase({?MODULE, timer}) of
        TimerRef when is_reference(TimerRef) ->
            erlang:cancel_timer(TimerRef);
        _ ->
            ignore
    end,
    ?ucast(#m_dunge_match_stop_toc{stype=SType});

handle(?DUNGE_RACE_RESULT, Tos, RoleSt) ->
    ensure_in_dunge(RoleSt),
    dunge_race:handle({?DUNGE_RACE_RESULT, Tos}, RoleSt).

match_succ(RoleSt) ->
    erlang:erase({?MODULE, timer}),
    TopList = rank:get_toplist(?RANK_ID_POWER, 50),
    Roles = case TopList of
        _ when length(TopList) >= 3 ->
            TopList1 = lists:keydelete(RoleSt#role_st.role, #rankitem.id, TopList),
            [role:get_base(RID) || #rankitem{id=RID} <- ut_rand:choose(TopList1, 2, false)];
        _ ->
            [Base || #faker{base=Base} <- faker:random(2, false)]
    end,
    ?ucast(#m_dunge_match_succ_toc{roles=Roles}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_enter(SType = ?SCENE_STYPE_DUNGE_MOUNT, DungeID, _Opts, _RoleSt) ->
    Star = dunge_util:get_star(SType, DungeID),
    ?_check(Star < 3, ?ERR_DUNGE_MOUNT_MAX_STAR);
check_enter(?SCENE_STYPE_DUNGE_RACE, _DungeID, Opts, _RoleSt) ->
    case maps:get(task_id, Opts, 0) of
        0 ->
            %% 如果玩家不是通过任务进来的，判断进入次数？
            ?_check(dunge_race:check_enter_times(), ?ERR_SCENE_MAX_TIMES),
            ActID = 11111,
            ?_check(activity:is_start(ActID), ?ERR_SCENE_NO_ACTIVITY);
        TaskID ->
            %% 检查玩家身上是否有该任务且该任务的目标事件是进入机甲场景
            CheckTask =
                case role_task:is_accept(TaskID) of
                    true ->
                        case cfg_task:find(TaskID) of
                            #cfg_task{goals = [Goal|_]} ->
                                erlang:element(1, Goal) == ?EVENT_DUNGE_ENTER andalso erlang:element(2, Goal) == ?SCENE_STYPE_DUNGE_RACE;
                            _ ->
                                false
                        end;
                    false ->
                        false
                end,
            ?_check(CheckTask, ?ERR_TASK_NOT_ACCEPT),
            %% 这里为了容错再给多3次机会，能跑到这里来的肯定是恶意的
            ?_check(dunge_race:check_enter_times(3), ?ERR_SCENE_MAX_TIMES),
            ok
    end;
check_enter(_SType, _DungeID, _Opts, _RoleSt) ->
    ok.

ensure_in_dunge(RoleSt) ->
    ?_check(RoleSt#role_st.type == ?SCENE_TYPE_DUNGE, ?ERR_DUNGE_NOT_IN).

check_sweep(SType = ?SCENE_STYPE_DUNGE_MOUNT, RoleDunge, _FloorID) ->
    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
    VipLv = role_vip:get_level(),
    Power = role_util:get_power(),
    {PowerLim, VipLvLim, RoleLvLim} = cfg_dunge_mount_sweep:find(RoleLv),
    CanSweep = (Power >= PowerLim) orelse
        (VipLv >= VipLvLim andalso RoleLv >= RoleLvLim),
    ?_check(CanSweep, ?ERR_DUNGE_MOUNT_SWEEP_LIMIT),
    #role_dunge{star=AllStar} = RoleDunge,
    StarInfo = maps:get(SType, AllStar, #{}),
    AllClear = lists:all(fun
        (DungeID) ->
            maps:get(DungeID, StarInfo, 0) == ?STAR3
    end, cfg_dunge:dunge(SType)),
    ?_check(not AllClear, ?ERR_DUNGE_MOUNT_SWEEP_CLEAR);
check_sweep(SType, RoleDunge, FloorID) ->
    check_enter_times(SType),
    check_sweep_times(SType),
    #cfg_dunge_sweep{reqs=Reqs} = cfg_dunge:sweep(SType),
    check_sweep_reqs(Reqs, RoleDunge, SType, FloorID),
    ok.

check_enter_times(SType) ->
    #cfg_dunge_enter{times=MaxTimes} = cfg_dunge:enter(SType),
    case MaxTimes > 0 of
        true  ->
            RestTimes = dunge_util:rest_times(SType),
            ?_check(RestTimes > 0, ?ERR_SCENE_MAX_TIMES);
        false ->
            ok
    end.

check_sweep_times(SType) ->
    #cfg_dunge_sweep{times=MaxTimes} = cfg_dunge:sweep(SType),
    Times = role_count:get_scene_sweep(SType),
    IsMaX = MaxTimes > 0 andalso Times >= MaxTimes,
    ?_check(not IsMaX, ?ERR_DUNGE_MAX_SWEEP_TIMES).

check_sweep_reqs([{star, NeedStar} | T], RoleDunge, SType, FloorID)
when SType == ?SCENE_STYPE_DUNGE_COIN ->
    Star = dunge_util:get_star(SType, FloorID, RoleDunge),
    ?_check(Star >= NeedStar, ?ERR_DUNGE_STAR_LIMIT),
    check_sweep_reqs(T, RoleDunge, SType, FloorID);
check_sweep_reqs([{star, NeedStar} | T], RoleDunge, SType, FloorID) ->
    CurStar  = maps:get(SType, RoleDunge#role_dunge.star, 0),
    CurStar2 = dunge_util:normal_star(CurStar),
    ?_check(CurStar2 >= NeedStar, ?ERR_DUNGE_STAR_LIMIT),
    check_sweep_reqs(T, RoleDunge, SType, FloorID);
check_sweep_reqs([{level, NeedLevel} | T], RoleDunge, SType, FloorID) ->
    #role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
    ?_check(Level >= NeedLevel, ?ERR_DUNGE_LEVEL_LIMIT),
    check_sweep_reqs(T, RoleDunge, SType, FloorID);
check_sweep_reqs([], _RoleDunge, _SType, _FloorID) ->
    ok.

get_max_buytimes(SType) ->
    VipLv  = role_vip:get_level(),
    Rights = case SType of
        ?SCENE_STYPE_DUNGE_EXP   -> ?VIP_RIGHTS_DUNGE_EXP_BUY;
        ?SCENE_STYPE_DUNGE_COIN  -> ?VIP_RIGHTS_DUNGE_COIN_BUY;
        ?SCENE_STYPE_DUNGE_PET   -> ?VIP_RIGHTS_DUNGE_PET_BUY;
        ?SCENE_STYPE_DUNGE_EQUIP -> ?VIP_RIGHTS_DUNGE_EQUIP_BUY;
        ?SCENE_STYPE_DUNGE_SOUL  -> ?VIP_RIGHTS_DUNGE_SOUL
    end,
    cfg_vip_rights:find(Rights, VipLv, 0).

do_buy(SType, RoleSt) ->
    CurBuyTimes = role_count:get_scene_buy(SType),
    MaxBuyTimes = get_max_buytimes(SType),
    ?_check(CurBuyTimes < MaxBuyTimes, ?ERR_DUNGE_MAX_BUY_TIMES),
    #cfg_dunge_enter{buy=BuyCost} = cfg_dunge:enter(SType),
    role_bag:cost(BuyCost, ?LOG_DUNGE_BUY_ENTER, RoleSt),
    role_count:add_scene_buy(SType),
    ?ucast(#m_dunge_buytimes_toc{stype=SType}),
    log_api:log_dunge(0, SType, ?DUNGE_OP_BUY_TIMES, 1, RoleSt).
