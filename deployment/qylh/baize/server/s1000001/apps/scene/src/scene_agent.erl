%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(scene_agent).

-behaviour(gen_server).

-include("buff.hrl").
-include("creep.hrl").
-include("dunge.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/4]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link(SceneID, RoomID, LineID, Opts) ->
    RegName = scene_util:reg_name(SceneID, RoomID, LineID),
    Args    = {SceneID, RoomID, LineID, Opts},
    gen_server:start_link({local, RegName}, ?MODULE, Args, []).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({SceneID, RoomID, LineID, Opts}) ->
    process_flag(trap_exit, true),
    SceneSt = init_state(SceneID, RoomID, LineID, Opts),
    scene_util:set_state(SceneSt),
    do_init(SceneID),
    % 这里需要先跑一下ai，否则hook_init事件无法触发
    ?_if(?is_dunge_scene(SceneSt), dunge_agent:loop()),
    scene_hook:hook_init(SceneSt),
    erlang:send(self(), loop_millis),
    erlang:send(self(), loop_seconds),
    {ok, SceneSt#scene_st{state=?SCENE_STATE_NORMAL}}.

handle_call({get_actids, Type}, _From, SceneSt) ->
    ActIDs = scene_actor:get_actids(Type),
    {reply, ActIDs, SceneSt};

handle_call({get_actids, Type, Coord}, _From, SceneSt) ->
    ActIDs = scene_actor:get_actids(Type, Coord),
    {reply, ActIDs, SceneSt};

handle_call({get_actors, Type}, _From, SceneSt) ->
    ActIDs = scene_actor:get_actids(Type),
    Actors = [scene_actor:get_actor(ActID) || ActID <- ActIDs],
    {reply, Actors, SceneSt};

handle_call({get_actors, Type, Coord}, _From, SceneSt) ->
    ActIDs = scene_actor:get_actids(Type, Coord),
    Actors = [scene_actor:get_actor(ActID) || ActID <- ActIDs],
    {reply, Actors, SceneSt};

handle_call({get_actor, ActorID}, _From, SceneSt) ->
    Reply = case scene_actor:get_actor(ActorID) of
        ?nil  -> ?err(?ERR_SCENE_NO_ACTOR);
        Actor -> {ok, Actor}
    end,
    {reply, Reply, SceneSt};

handle_call(Req, From, SceneSt) ->
    ?try_handle_call(do_handle_call(Req, From, SceneSt), SceneSt).

%% 战斗
handle_cast({fight, Attack=#attack{atker=AtkID}}, SceneSt) ->
    try
        fight_attack:start(Attack, SceneSt)
    catch
        throw:{error, Errno, Args} ->
            ?ucast(AtkID, #m_game_error_toc{errno=Errno, args=Args}),
            {noreply, SceneSt};
        error:{badmatch, {error, Errno, Args}} ->
            ?ucast(AtkID, #m_game_error_toc{errno=Errno, args=Args}),
            {noreply, SceneSt};
        Class:Reason:Stacktrace ->
            ?stacktrace(Class, Reason, Stacktrace),
            {noreply, SceneSt}
    end,
    {noreply, SceneSt};

handle_cast(Msg, SceneSt) ->
    ?try_handle_cast(do_handle_cast(Msg, SceneSt), SceneSt).

handle_info(Info, SceneSt) ->
    ?try_handle_info(do_handle_info(Info, SceneSt), SceneSt).

terminate(Reason, SceneSt) ->
    #scene_st{scene=SceneID, room=RoomID, line=LineID} = SceneSt,
    ?debug(
        "scene terminate: SceneID:~w RoomID:~w LineID:~w Reason:~p",
        [SceneID, RoomID, LineID, Reason]
    ),
    dunge_agent:loop_events(),
    scene_util:kickout(SceneSt),
    scene_hook:hook_destroy(SceneSt),
    ?terminate(Reason),
    ok.

code_change(_OldVsn, SceneSt, _Extra) ->
    {ok, SceneSt}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%% 切换场景
do_handle_call({change, NewSpid, RoleID, Coord, Opts}, _From, SceneSt) ->
    Actor = scene_actor:get_actor(RoleID),
    ?_check(Actor /= ?nil, ?ERR_SCENE_NO_ACTOR),
    {ok, Actor1} = scene_role:pre_leave(Actor, SceneSt),
    Coord2 = ?_if(Coord == ?nil, Actor1#actor.coord, Coord),
    Actor2 = Actor1#actor{coord=Coord2},
    {ok, Actor3, Actors} = gen_server:call(NewSpid, {enter, Actor2, Opts}, 200),
    scene_role:post_leave(Actor, SceneSt),
    {reply, {ok, Actor3, Actors}, SceneSt};

%% 进入场景
do_handle_call({enter, Actor, Opts}, _From, SceneSt) ->
    IsTimeout = SceneSt#scene_st.state == ?SCENE_STATE_TIMEOUT,
    ?_check(not IsTimeout, ?ERR_SCENE_NOT_EXIST),
    scene_hook:pre_enter(Actor, SceneSt),
    {ok, Actor2} = scene_role:enter(Actor, Opts, SceneSt),
    scene_actor:set_actor(Actor2),
    ActIDs = scene_util:get_bc_actids(all, Actor#actor.coord),
    Actors = [scene_actor:get_actor(ID)
        || ID <- ActIDs, ID /= Actor#actor.uid],
    gen_server:cast(self(), {hook_enter, Actor2}),
    #scene_st{scene=SceneID, room=RoomID, line=LineID} = SceneSt,
    scene_manager:hook_enter(SceneID, RoomID, LineID),
    {reply, {ok, Actor2, Actors}, SceneSt};

%% 离开场景
do_handle_call({leave, RoleID}, _From, SceneSt) ->
    Reply = scene_role:leave(RoleID, SceneSt),
    {reply, Reply, SceneSt};

%% 玩家重登
do_handle_call({relogin, RoleID}, _From, SceneSt) ->
    Actor  = scene_actor:get_actor(RoleID),
    ActIDs = scene_util:get_bc_actids(all, Actor#actor.coord),
    Actors = [scene_actor:get_actor(ID) || ID <- ActIDs, ID /= RoleID],
    case ?is_dunge_scene(SceneSt) of
        true  -> scene_hook:hook_relogin(Actor, SceneSt);
        false -> ignore
    end,
    {reply, {ok, Actor, Actors}, SceneSt};

%% 复活
do_handle_call({revive, RoleID, Type}, _From, SceneSt) ->
    Actor = scene_actor:get_actor(RoleID),
    ?_check(?is_death(Actor#actor.state), ?ERR_FIGHT_NOT_DEAD),
    fight_revive:revive(Actor, Type, SceneSt),
    {reply, ok, SceneSt};

%% 采集开始
do_handle_call({coll_start, RoleID, CollID}, _From, SceneSt) ->
    Actor = scene_actor:get_actor(RoleID),
    Coll  = scene_actor:get_actor(CollID),
    ?_check(Coll /= ?nil, ?ERR_FIGHT_NO_COLLECT),
    ok = fight_util:check_action(Actor),
    ?_check(Coll#actor.kind == ?CREEP_KIND_COLLECT, ?ERR_FIGHT_NOT_COLLECT),
    ?_check(scene_util:is_nearby(Actor, Coll), ?ERR_COLLECT_TOO_FAR),
    scene_hook:pre_collect(Actor, Coll, SceneSt),
    case Coll#actor.rarity == ?CREEP_RARITY_COLL of
        true  ->
            ?_check(not ?is_occupy(Coll#actor.state), ?ERR_FIGHT_COLLECTTED),
            #cfg_creep{collect=Last} = cfg_creep:find(Coll#actor.id),
            buff_util:add_buffs(Coll, [{?BUFF_ID_OCCUPY, #{last=>Last*1000}}]);
        false ->
            ignore
    end,
    scene_actor:coll_start(Actor, CollID),
    creep_agent:event(Coll, start_coll, ?nil),
    {reply, {ok, Coll#actor.id}, SceneSt};

%% 完成采集
do_handle_call({coll_compl, RoleID, CollID}, _From, SceneSt) ->
    Actor = scene_actor:get_actor(RoleID),
    ?_check(?is_collect(Actor#actor.state), ?ERR_COLLECT_NOT_START),
    scene_actor:coll_stop(Actor, false),
    Coll  = scene_actor:get_actor(CollID),
    ?_check(Coll /= ?nil, ?ERR_FIGHT_NO_COLLECT),
    ?_check(scene_util:is_nearby(Actor, Coll), ?ERR_COLLECT_TOO_FAR),
    Coll1 = buff_util:del_buffs(Coll, [?BUFF_ID_OCCUPY]),
    Coll2 = Coll1#actor{killer=RoleID},
    scene_actor:set_actor(Coll2),
    creep_agent:event(Coll, hook_coll, ?nil),
    scene_hook:finish_collect(Actor, Coll, SceneSt),
    {reply, ok, SceneSt};

%% 拾取
do_handle_call({pickup, RoleID, DropID}, _From, SceneSt) ->
    Drop = scene_actor:get_actor(DropID),
    ?_check(Drop /= ?nil, ?ERR_FIGHT_NO_DROP),
    #actor{coord=Coord1, type=Type, belong=Belong, exargs=ExArgs} = Drop,
    ?_check(Type == ?ACTOR_TYPE_DROP, ?ERR_FIGHT_NOT_DROP),
    NowSecs = ut_time:seconds(),
    Unlock  = maps:get(unlock, ExArgs, 0),
    IsOwner = Belong == [] orelse NowSecs > Unlock orelse lists:member(RoleID, Belong),
    ?_check(IsOwner, ?ERR_DROP_NOT_OWNER),
    Actor = #actor{coord=Coord2} = scene_actor:get_actor(RoleID),
    scene_hook:pre_pickup(Actor, Drop, SceneSt),
    ok    = fight_util:check_action(Actor),
    ?_check(scene_util:is_nearby(Coord1, Coord2, 500), ?ERR_DROP_TOO_FAR),
    fight_timer:del_task({DropID, creep_drop, remove}),
    scene_grid:leave(Drop, SceneSt),
    scene_actor:del_actor(DropID),
    ?bcast(
        scene_actor:get_actids(?ACTOR_TYPE_ROLE, Coord2),
        RoleID,
        #m_scene_update_toc{del=[DropID]}
    ),
    {reply, ok, SceneSt};

%% 路由转发
do_handle_call({sync_route, Func}, _From, SceneSt) ->
    Reply = if
        is_function(Func, 0) ->
            Func();
        is_function(Func, 1) ->
            Func(SceneSt);
        true ->
            ?err(?ERR_GAME_SYS_ERROR)
    end,
    {reply, Reply, SceneSt};
do_handle_call({sync_route, Mod, Fun}, _From, SceneSt) ->
    Reply = Mod:Fun(SceneSt),
    {reply, Reply, SceneSt};
do_handle_call({sync_route, Mod, Fun, Args}, _From, SceneSt) ->
    Reply = Mod:Fun(Args, SceneSt),
    {reply, Reply, SceneSt};

do_handle_call({stop, Reason}, _From, SceneSt) ->
    {stop, Reason, ok, SceneSt};

do_handle_call(Req, _From, SceneSt) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, SceneSt}.


do_handle_cast({hook_enter, Actor}, SceneSt) ->
    scene_hook:hook_enter(Actor, SceneSt),
    {noreply, SceneSt};

%% 行走
do_handle_cast({walk, RoleID, Dir, Dest, State}, SceneSt) ->
    Actor = scene_actor:get_actor(RoleID),
    scene_actor:set_actor(Actor#actor{dest=Dest, dir=Dir}),
    ?bcast(
        scene_util:get_bc_roles(Actor),
        RoleID,
        #m_scene_dest_toc{uid=RoleID, dest=Dest, dir=Dir, state=State}
    ),
    {noreply, SceneSt};

%% 移动
do_handle_cast({move, RoleID, Coord}, SceneSt) ->
    Actor  = scene_actor:get_actor(RoleID),
    scene_grid:move(Actor, Coord, SceneSt),
    Actor2 = Actor#actor{coord=Coord},
    scene_actor:set_actor(Actor2),
    {noreply, SceneSt};

%% 瞬移
do_handle_cast({tele, RoleID, Coord}, SceneSt) ->
    Actor  = scene_actor:get_actor(RoleID),
    scene_grid:move(Actor, Coord, SceneSt),
    Actor2 = Actor#actor{coord=Coord, dest=Coord},
    scene_actor:set_actor(Actor2),
    {noreply, SceneSt};

%% 冲刺
do_handle_cast({rush, RoleID, Dest}, SceneSt) ->
    Actor = scene_actor:get_actor(RoleID),
    scene_actor:rush(Actor, Dest, SceneSt),
    {noreply, SceneSt};

%% 跳跃
do_handle_cast({jump, RoleID, Dest, Type}, SceneSt) ->
    Actor = #actor{coord=Coord} = scene_actor:get_actor(RoleID),
    scene_grid:move(Actor, Dest, SceneSt),
    scene_actor:set_actor(Actor#actor{coord=Dest, dest=Coord}),
    ?bcast(
        scene_util:get_bc_roles(Actor),
        #m_scene_jump_toc{start=Coord, dest=Dest, type=Type, uid=RoleID}
    ),
    {noreply, SceneSt};

%% 切换 PK 模式
do_handle_cast({chpk, RoleID, PKMode}, SceneSt) ->
    Actor  = scene_actor:get_actor(RoleID),
    Actor2 = Actor#actor{pkmode=PKMode},
    scene_actor:set_actor(Actor2),
    {noreply, SceneSt};

%% 更新 actor
do_handle_cast({update_actor, RoleID, Update}, SceneSt) ->
    Actor = scene_actor:get_actor(RoleID),
    {Actor2, Toc} = scene_actor:update_actor(Update, Actor),
    scene_actor:set_actor(Actor2),
    case Toc =/= #m_actor_update_toc{} of
        true  ->
            ?bcast(
                scene_actor:get_actids(?ACTOR_TYPE_ROLE, Actor#actor.coord),
                RoleID,
                Toc#m_actor_update_toc{uid=RoleID}
            );
        false ->
            ignore
    end,
    {noreply, SceneSt};

%% 中断采集
do_handle_cast({coll_break, RoleID, CollID}, SceneSt) ->
    case scene_actor:get_actor(RoleID) of
        ?nil  -> ignore;
        Actor ->
            scene_actor:coll_stop(Actor, true),
            Coll = scene_actor:get_actor(CollID),
            Coll /= ?nil andalso creep_agent:event(Coll, break_coll, ?nil)
    end,
    {noreply, SceneSt};

%% 新增 buff
do_handle_cast({add_buffs, ActorID, BuffIDs}, SceneSt) ->
    Actor = scene_actor:get_actor(ActorID),
    ?_if(Actor /= ?nil, buff_util:add_buffs(Actor, BuffIDs)),
    {noreply, SceneSt};

%% 删除 buff
do_handle_cast({del_buffs, ActorID, BuffIDs}, SceneSt) ->
    Actor = scene_actor:get_actor(ActorID),
    ?_if(Actor /= ?nil, buff_util:del_buffs(Actor, BuffIDs)),
    {noreply, SceneSt};

do_handle_cast(kickout, SceneSt) ->
    scene_util:kickout(SceneSt),
    {noreply, SceneSt};

do_handle_cast({bcast, Toc}, SceneSt) ->
    scene_util:bc_to_scene(Toc),
    {noreply, SceneSt};

do_handle_cast({offline, RoleID}, SceneSt) ->
    case dunge_util:get_state() of
        #dunge_st{over=true} ->
            {stop, normal, SceneSt};
        _ ->
            case scene_actor:get_actor(RoleID) of
                Actor when ?is_death(Actor#actor.state) ->
                    fight_revive:revive(Actor, ?REVIVE_TYPE_SAFE, SceneSt);
                _ ->
                    ignore
            end,
            {noreply, SceneSt}
    end;

%% 重复创建，如果是副本，且此时场景中没有玩家，则销毁，避免玩家长时间进不了副本
do_handle_cast(already_started, SceneSt) ->
    case ?is_dunge_scene(SceneSt) andalso scene_actor:nobody() of
        true  -> {stop, {shutdown, repeat_create}, SceneSt};
        false -> {noreply, SceneSt}
    end;

%% 重新计算怪物属性
do_handle_cast({reload, CreepIDs}, SceneSt) ->
    ActIDs = scene_actor:get_actids(?ACTOR_TYPE_CREEP),
    lists:foreach(fun
        (ActorID) ->
            case scene_actor:get_actor(ActorID) of
                Actor when not ?is_death(Actor#actor.state) ->
                    case lists:member(Actor#actor.id, CreepIDs) of
                        true  ->
                            InitAttr = creep_attr:calc(Actor, SceneSt),
                            Actor1 = Actor#actor{initattr=InitAttr, attr=InitAttr},
                            Actor2 = scene_actor:recalc_attr(Actor1),
                            scene_actor:set_actor(Actor2);
                        false ->
                            ignore
                    end;
                _ ->
                    ignore
            end
    end, ActIDs),
    {noreply, SceneSt};

%% 清除已死亡的怪物
do_handle_cast({clear, Killer}, SceneSt) ->
    [case ?is_creep(Actor) andalso ?is_death(Actor#actor.state) of
        true  -> creep_ai:die(Actor#actor{killer=Killer}, true, SceneSt);
        false -> ignore
    end || {{k_actor,_}, Actor} <- get()],
    {noreply, SceneSt};

do_handle_cast(Msg, SceneSt) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, SceneSt}.


do_handle_info(loop_millis, SceneSt) ->
    erlang:send_after(?LOOP_MILLIS, self(), loop_millis),
    buff_timer:loop(),
    case ?is_dunge_scene(SceneSt) of
        true  -> dunge_agent:loop_events();
        false -> ignore
    end,
    case (?is_field_scene(SceneSt) orelse SceneSt#scene_st.scene == 30381) andalso scene_actor:nobody() of
        true  -> ignore;
        false -> creep_agent:loop(SceneSt)
    end,
    {noreply, SceneSt};

do_handle_info(loop_seconds, SceneSt) ->
    erlang:send_after(timer:seconds(1), self(), loop_seconds),
    fight_timer:loop(),
    ?_if(?is_dunge_scene(SceneSt), dunge_agent:loop()),
    scene_hook:hook_loopsec(ut_time:seconds(), SceneSt),
    {noreply, SceneSt};

%% 路由转发
do_handle_info({route, Mod, Fun}, SceneSt) ->
    case Mod:Fun(SceneSt) of
        {stop, _, _} = Res ->
            Res;
        _ ->
            {noreply, SceneSt}
    end;
do_handle_info({route, Mod, Fun, Args}, SceneSt) ->
    case Mod:Fun(Args, SceneSt) of
        {stop, _, _} = Res ->
            Res;
        _ ->
            {noreply, SceneSt}
    end;

%% 波数超时
do_handle_info(waveout, SceneSt) ->
    scene_hook:hook_waveout(SceneSt),
    {noreply, SceneSt};

%% 副本超时
do_handle_info(timeout, SceneSt) ->
    scene_hook:hook_timeout(SceneSt),
    erlang:send_after(timer:seconds(30), self(), {stop, normal}),
    {noreply, SceneSt#scene_st{state=?SCENE_STATE_TIMEOUT}};

%% 副本开始
do_handle_info(start, SceneSt) ->
    scene_hook:hook_start(SceneSt),
    {noreply, SceneSt};

%% 副本结束
do_handle_info({over, RoleID}, SceneSt) ->
    scene_hook:hook_over(RoleID, SceneSt),
    {noreply, SceneSt};

%% 关闭场景
do_handle_info({stop, Reason}, SceneSt) ->
    {stop, Reason, SceneSt};

do_handle_info(Info, SceneSt) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, SceneSt}.


do_init(SceneID) ->
    scene_grid:init(SceneID),
    scene_actor:set_actids(#{}),
    scene_team:init(),
    buff_timer:init(),
    fight_timer:init(),
    creep_agent:init(SceneID).

init_state(SceneID, RoomID, LineID, Opts) ->
    #cfg_scene{type=Type, stype=SType} = cfg_scene:find(SceneID),
    SceneSt1 = #scene_st{
        scene = SceneID,
        type  = Type,
        stype = SType,
        room  = RoomID,
        line  = LineID,
        dunge = maps:get(dunge, Opts, 0),
        floor = maps:get(floor, Opts, 0),
        opts  = Opts
    },
    SceneSt2 = case Type == ?SCENE_TYPE_DUNGE of
        true  -> dunge_agent:init(SceneSt1);
        false -> SceneSt1
    end,
    SceneSt3 = SceneSt2#scene_st{
        stime = maps:get(stime, Opts, SceneSt2#scene_st.stime),
        etime = maps:get(etime, Opts, SceneSt2#scene_st.etime)
    },
    #scene_st{stime=STime, etime=ETime} = SceneSt3,
    case is_integer(STime) andalso is_integer(ETime) of
        true  ->
            Last = ETime - STime,
            ?_if(Last > 0, erlang:send_after(timer:seconds(Last), self(), timeout));
        false ->
            ignore
    end,
    SceneSt3.
