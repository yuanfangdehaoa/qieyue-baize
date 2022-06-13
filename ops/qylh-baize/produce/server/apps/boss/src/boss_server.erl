%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(boss_server).

-behaviour(gen_server).

-include("boss.hrl").
-include("buff.hrl").
-include("cluster.hrl").
-include("creep.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("item.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("msgno.hrl").
-include("proto.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([get_bosses/1]).
-export([get_boss/1]).
-export([care_boss/3]).
-export([summon_boss/1]).

-export([hook_enter/2]).
-export([pre_leave/2]).
-export([hook_leave/2]).
-export([hook_fight/4]).
-export([hook_drop/3]).
-export([hook_creep_dead/3]).
-export([hook_role_dead/3]).
-export([hook_dead_notify/3]).
-export([hook_pickup/3]).
-export([hook_kickout/2]).
-export([hook_revive/3]).
-export([get_drops/2]).
-export([pre_pickup/3]).
-export([pre_collect/3]).
-export([finish_collect/3]).

-export([kickout/2]).
-export([add_anger/2]).
-export([red_tired/2]).
-export([get_tired/2, get_tired/3]).
-export([max_tired/2]).
-export([is_tired/2]).
-export([hook_ready/1]).
-export([hook_start/1]).

-export([do_summon3/1]).
-export([do_summon5/1]).

-define(SERVER, ?MODULE).

-record(state, {init=false}).

-define(ETS_BOSS, ets_boss).

-define(in_world(SceneSt), SceneSt#scene_st.stype == ?SCENE_STYPE_BOSS_WORLD).
-define(in_home(SceneSt), SceneSt#scene_st.stype == ?SCENE_STYPE_BOSS_HOME).
-define(in_wild(SceneSt), SceneSt#scene_st.stype == ?SCENE_STYPE_BOSS_WILD).
-define(in_pet(SceneSt), SceneSt#scene_st.stype == ?SCENE_STYPE_BOSS_PET).
-define(in_beast(SceneSt), SceneSt#scene_st.stype == ?SCENE_STYPE_BOSS_BEAST).
-define(in_notired(SceneSt), SceneSt#scene_st.stype == ?SCENE_STYPE_BOSS_NOTIRED).
-define(in_fissure(SceneSt), SceneSt#scene_st.stype == ?SCENE_STYPE_BOSS_FISSURE).

-define(FISSURE_TREASURE, 21001010).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

hook_ready(_ActID) ->
	?notify(?MSG_TIMERIFT_START, []).

hook_start(_ActID) ->
	?notify(?MSG_TIMERIFT_TREASURE, []).

get_bosses(Type) ->
	case is_cross_boss_type(Type) andalso cluster:is_local() of
		true  -> rpc_call_cross(get_bosses, [Type]);
		false -> do_get_bosses(Type)
	end.

get_boss(BossID) ->
	case is_cross_boss_id(BossID) andalso cluster:is_local() of
		true  -> rpc_call_cross(get_boss, [BossID]);
		false -> do_get_boss(BossID)
	end.

care_boss(RoleID, BossID, Op) ->
	Msg = {care, Op, BossID, RoleID},
	case is_cross_boss_id(BossID) andalso cluster:is_local() of
		true  -> gen_cast_cross(Msg);
		false -> gen_server:cast(?SERVER, Msg)
	end.

summon_boss(BossID) ->
	Msg = {summon, BossID},
	case is_cross_boss_id(BossID) andalso cluster:is_local() of
		true  -> gen_cast_cross(Msg);
		false -> gen_server:cast(?SERVER, Msg)
	end.


hook_enter(Actor, SceneSt) when ?in_wild(SceneSt); ?in_pet(SceneSt); ?in_fissure(SceneSt) ->
	#scene_st{stype=SType} = SceneSt,
	?_if(
		?in_wild(SceneSt) orelse ?in_pet(SceneSt),
    	role_event:event(Actor#actor.uid, ?EVENT_DUNGE_ENTER, {SType, 0, 0})
	),
	Interval = cfg_game:boss_anger_interval(),
	fight_timer:add_task(
		{Actor#actor.uid,?MODULE,anger}, 0, Interval, ?MODULE, add_anger
	);
hook_enter(_Actor, _SceneSt) ->
	ok.

pre_leave(Actor, _SceneSt) ->
	Actor2 = leave_wild(Actor),
	scene_actor:set_actor(Actor2).

hook_leave(Actor, SceneSt) when ?in_wild(SceneSt); ?in_pet(SceneSt); ?in_fissure(SceneSt) ->
	fight_timer:del_task({Actor#actor.uid, ?MODULE, kickout}),
	fight_timer:del_task({Actor#actor.uid, ?MODULE, anger});
hook_leave(_Actor, _SceneSt) ->
	ok.

hook_creep_dead(Atker, Defer, SceneSt) when ?is_boss(Defer) ->
	#cfg_boss{id=BossID, type=Type, weak=WeakCD} = cfg_boss:find(Defer#actor.id),
	Reborn  = when_to_reborn(BossID),
	NowSec  = ut_time:seconds(),
	RebSec  = NowSec + Reborn,
	WeakSec = ?_if(?in_pet(SceneSt), NowSec+WeakCD, 0),
	Num = case ets:lookup(?ETS_BOSS, BossID) of
					[#boss{num = Num0}] ->
						max(0, Num0 - 1);
					_ ->
						0
				end,
	scene_util:bc_to_scene(#m_boss_info_toc{
		id   = BossID,
		type = Type,
		born = RebSec,
		weak = WeakSec,
		num  = Num
	}),
	gen_server:cast(?SERVER, {dead, BossID, NowSec, Reborn, Atker}),
	?_if(
		Type == ?BOSS_TYPE_SPATIOTEMPORAL,
		gen_server:cast(?SERVER, {fissure_fix_boss_dead, BossID})
	),
	hook_boss_dead(Atker, Defer, SceneSt);
hook_creep_dead(Atker, Defer, SceneSt) ->
	hook_creep_dead2(Atker, Defer, SceneSt).

hook_role_dead(Atker, Defer, SceneSt) ->
	hook_role_dead2(Atker, Defer, SceneSt).

hook_dead_notify(Atker, Defer, SceneSt) when ?in_world(SceneSt); ?in_beast(SceneSt) ->
	BuffID = case ?in_world(SceneSt) of
		true  -> ?BUFF_ID_WORLD_BOSS_DEAD_TIRED;
		false -> ?BUFF_ID_BEAST_BOSS_DEAD_TIRED
	end,
	#cfg_buff{group=Group} = cfg_buff:find(BuffID),
	TiredBuff = maps:get(Group, Defer#actor.buffs, ?nil),
	case TiredBuff == ?nil orelse TiredBuff#p_buff.value < 5 of
		true  ->
			fight_dead:notify(?DEAD_TYPE_NORM, Atker, Defer, SceneSt);
		false ->
			fight_dead:notify(?DEAD_TYPE_TIRED, Atker, Defer, SceneSt),
			fight_revive:auto(Defer, cfg_game:revive_tired(), SceneSt)
	end;
hook_dead_notify(Atker, Defer, SceneSt) ->
	fight_dead:notify(Atker, Defer, SceneSt).


hook_pickup(Drop, Item, RoleSt) ->
	#cfg_item{notify=IsNotify} = cfg_item:find(Drop#drop.id),
	case IsNotify of
		true  ->
			#role_st{role=RoleID, scene=SceneID, spid=ScenePid} = RoleSt,
			RoleInfo = role_data:get(?DB_ROLE_INFO),
			#role_info{id=RoleID, name=RoleName0} = RoleInfo,
			case scene_util:is_local(SceneID) of
				true  ->
					CacheID  = item_cache:add_cache(Item),
					RoleName = RoleName0;
				false ->
					CacheID  = cluster:rpc_call_center(item_cache, add_cache, [Item]),
					ServerID = game_uid:suid2ssid(),
					RoleName = lists:concat(["s", ServerID, ".", RoleName0])
			end,
			#cfg_creep{name=BossName} = cfg_creep:find(Drop#drop.creep),
			Dropped = #p_dropped{
				time        = ut_time:seconds(),
				scene       = SceneID,
				picker_id   = RoleID,
				picker_name = RoleName,
				boss        = BossName,
				item_id     = Drop#drop.id,
				cache_id    = CacheID
			},
			CfgScene  = cfg_scene:find(SceneID),
			#cfg_scene{kind=SceneKind, stype=SceneSType, name=SceneName} = CfgScene,
			DropLogID = if
				SceneSType == ?SCENE_STYPE_BOSS_PET ->
					1;
				SceneKind == ?SCENE_KIND_CROSS,
				(SceneSType == ?SCENE_STYPE_BOSS_BEAST orelse SceneSType == ?SCENE_STYPE_BOSS_FISSURE) ->
					3;
				true ->
					2
			end,
			RoleIDs = case scene_util:is_local(SceneID) of
				true  ->
					game_logger:add_log({boss_drop_log,DropLogID}, Dropped),
					online_server:get_roles();
				false ->
					cluster:rpc_cast_cross(
						?CROSS_RULE_24_8,
						game_logger,
						add_log,
						[{boss_drop_log,DropLogID}, Dropped]
					),
					game_role:get_scene_roles(ScenePid)
			end,
			?notify(
				RoleIDs,
				?MSG_BOSS_DROP,
				[
					{role,RoleID,RoleName},
					SceneName,
					BossName,
					{pitem, #{CacheID=>(Drop#drop.id)}}
				]
			);
		false ->
			ok
	end.

hook_kickout(Actor, _RoleSt) ->
	leave_wild(Actor).

hook_revive(Actor, _Type, SceneSt) when ?in_home(SceneSt) ->
	scene_util:kickout([Actor#actor.uid], SceneSt);
hook_revive(_Actor, _Type, _SceneSt) ->
	ok.

kickout({ActorID, _, _}, SceneSt) ->
	case scene_actor:get_actor(ActorID) of
		?nil -> ignore;
		_    -> scene_util:kickout([ActorID], SceneSt)
	end.

%% 增加蛮荒/宠物boss怒气值
add_anger({ActorID, _, _}, SceneSt) ->
	case scene_actor:get_actor(ActorID) of
		?nil  ->
			ignore;
		Actor ->
			Increase = cfg_game:boss_anger_increase(),
			do_add_anger(Actor, Increase, SceneSt)
	end.

%% 减少世界boss疲劳值
red_tired({RoleID, BuffID, RedTired}, _SceneSt) ->
	case scene_actor:get_actor(RoleID) of
		?nil  ->

			ignore;
		Actor ->
			CurTired = buff_util:get_value(Actor, BuffID),
			?debug("red_tired-----------------------:~w", [{CurTired, max(0, CurTired-RedTired)}]),
			?_check(CurTired > 0, ?ERR_ITEM_NOT_TIRED),
			do_add_tired1(Actor, BuffID, max(0, CurTired-RedTired))
	end,
	ok.


get_drops(Actor, _SceneSt) ->
	maps:get(boss_drop, Actor#actor.exargs, []).


%% 只有在 Boss 场景才能调用
get_tired(Actor, SceneSt) ->
	BuffID = case SceneSt#scene_st.stype of
		?SCENE_STYPE_BOSS_WORLD ->
			?BUFF_ID_WORLD_BOSS_KILL_TIRED;
		?SCENE_STYPE_BOSS_BEAST ->
			?BUFF_ID_BEAST_BOSS_KILL_TIRED;
		?SCENE_STYPE_BOSS_FISSURE ->
			?BUFF_ID_FISSURE_BOSS_TIRED;
		_ ->
			0
	end,
	case BuffID == 0 of
		true  -> 0;
		false -> buff_util:get_value(Actor, BuffID)
	end.

get_tired(Actor, BuffID, _SceneSt) ->
	case cfg_buff:find(BuffID) of
		#cfg_buff{group=Group} ->
			TiredBuff = maps:get(Group, Actor#actor.buffs, ?nil),
			?_if(TiredBuff == ?nil, 0, TiredBuff#p_buff.value);
		_ ->
			0
	end.

max_tired(_Actor, ?SCENE_STYPE_BOSS_WORLD) ->
	cfg_game:boss_tired();
max_tired(_Actor, ?SCENE_STYPE_BOSS_BEAST) ->
	cfg_game:beast_tired();
max_tired(Actor, ?SCENE_STYPE_BOSS_FISSURE) ->
	cfg_vip_rights:find(?VIP_RIGHTS_FISSURE_TIRED, Actor#actor.viplv, 0);
max_tired(_, _) ->
	0.

is_tired(Actor, SceneSt) ->
	#scene_st{scene=SceneID, stype=SType} = SceneSt,
	if
		SType == ?SCENE_STYPE_BOSS_WORLD;
		SType == ?SCENE_STYPE_BOSS_BEAST;
		SType == ?SCENE_STYPE_BOSS_FISSURE ->
			get_tired(Actor, SceneSt) >= max_tired(Actor, SType);
		SType == ?SCENE_STYPE_BOSS_HOME ->
			#cfg_scene_cost{free=FreeConds} = cfg_scene:cost(SceneID),
			case proplists:get_value(vip, FreeConds, 0) < 6 of
				true  ->
					Vigor = buff_util:get_value(Actor, ?BUFF_ID_HOME_BOSS_VIGOR),
					Vigor >= 100;
				false ->
					false
			end;
		true ->
			false
	end.

pre_pickup(Actor, Drop, SceneSt) ->
    #drop{tired=TiredInfo} = maps:get(drop, Drop#actor.exargs),
    BuffID = case SceneSt#scene_st.stype of
		?SCENE_STYPE_BOSS_WORLD ->
			?BUFF_ID_WORLD_BOSS_KILL_TIRED;
		?SCENE_STYPE_BOSS_BEAST ->
			?BUFF_ID_BEAST_BOSS_KILL_TIRED;
		_ ->
			0
	end,
	case BuffID > 0 of
		true  ->
			MaxTired = max_tired(Actor, SceneSt#scene_st.stype),
			TheTired = case TiredInfo == ?nil of
			    true  ->
			    	buff_util:get_value(Actor, BuffID);
			    false ->
			        case proplists:get_value(Actor#actor.uid, TiredInfo, ?nil) of
			            ?nil  -> buff_util:get_value(Actor, BuffID);
			            Tired -> Tired
			        end
			end,
			?_check(TheTired < MaxTired, ?ERR_DROP_MAX_TIRED);
		false ->
			ok
	end.

pre_collect(Actor, Coll, _SceneSt) ->
	#cfg_creep{opts=CollType} = cfg_creep:find(Coll#actor.id),
	case CollType of
		coll1  ->
			CurTired = buff_util:get_value(Actor, ?BUFF_ID_BEAST_BOSS_COLL_TIRED),
			MaxTired = cfg_game:beast_collect(),
			?_check(CurTired < MaxTired, ?ERR_COLLECT_TIRED);
		coll2 ->
			CurTired = buff_util:get_value(Actor, ?BUFF_ID_BEAST_BOSS_COLL2_TIRED),
			MaxTired = cfg_game:beast_collect2(),
			?_check(CurTired < MaxTired, ?ERR_COLLECT_TIRED);
		_ ->
			ok
	end.

%%finish_collect(_Actor, Coll, _SceneSt) when Coll#actor.id == ?FISSURE_TREASURE ->
%%	gen_server:cast(?SERVER, fissure_treasure_killed);
%%finish_collect(_Actor, _Coll, _SceneSt) ->
%%	ignore.
finish_collect(_Actor, Coll, _SceneSt) ->
	case cfg_boss:find(Coll#actor.id) of
		#cfg_boss{type = ?BOSS_TYPE_SPATIOTEMPORAL, group = 1} ->
			gen_server:cast(?SERVER, {fissure_treasure_killed, Coll#actor.id});
		_ ->
			igore
	end.


%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	process_flag(trap_exit, true),
	ets:new(?ETS_BOSS, [named_table, {keypos, #boss.id}]),
	{ok, #state{init=false}}.

handle_call(Req, From, State) ->
	?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(started, State) ->
	case State#state.init of
		true  ->
			ignore;
		false ->
			BossKind = case game_env:get_type() of
				?SERVER_TYPE_LOCAL -> ?BOSS_KIND_LOCAL;
				?SERVER_TYPE_CROSS -> ?BOSS_KIND_CROSS
			end,
			BossKill = game_misc:read(boss_kill, #{}),
			lists:foreach(fun
				(BossID) ->
					try
						init_boss(BossID, BossKill)
					catch
						Class:Reason:Stacktrace ->
							?error("BossID, Class, Reason, Stacktrace ： ~p~n", [{BossID, Class, Reason, Stacktrace}])
					end
			end, cfg_boss:all(BossKind)),
			loop_check()
	end,
	{noreply, State#state{init=true}};

handle_cast(Msg, State) ->
	?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
	?try_handle_cast(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
	BossKill = lists:foldl(fun
		(Boss, Acc) ->
			#boss{id=BossID, kill=Times} = Boss,
			maps:put(BossID, Times, Acc)
	end, #{}, ets:tab2list(?ETS_BOSS)),
	game_misc:write(boss_kill, BossKill, true),
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call({summon, BossID}, _From, State) ->
	case ets:lookup(?ETS_BOSS, BossID) of
		[Boss] ->
			?_check(Boss#boss.born > 0, ?ERR_BOSS_NOT_DEAD),
			summon_boss(Boss),
			{reply, ok, State};
		[] ->
			{reply, ?err(?ERR_BOSS_NOT_FOUND), State}
	end;

do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.

do_handle_cast({fissure_treasure_killed, BossId}, State) ->
	case ets:lookup(?ETS_BOSS, BossId) of
		[Coll] ->
			ets:insert(?ETS_BOSS, Coll#boss{kill=Coll#boss.kill+1});
		[] ->
			ignore
	end,
	{noreply, State};

%% 击杀 Boss
do_handle_cast({dead, BossID0, NowSec, Reborn, Atker}, State) ->
	CfgBoss = cfg_boss:find(BossID0),
	#cfg_boss{qual=Qual, type=Type} = CfgBoss,
	BossID = case Type == ?BOSS_TYPE_SPATIOTEMPORAL2  of
		true  ->
			%% 获取同层隐藏boss第一个id
			boss_coord_out(BossID0),
			get_fissure_first_high_boss(BossID0);
%%			20901011;
		false -> BossID0
	end,
	case ets:lookup(?ETS_BOSS, BossID) of
		[Boss] ->
%%			Coord  = case Coord0 of
%%				{X,Y} when is_integer(X) ->
%%					#p_coord{x=X, y=Y};
%%				_ ->
%%					{X2,Y2} = element(1, Coord0),
%%					#p_coord{x=X2, y=Y2}
%%			end,
%%			#cfg_creep{level=Level} = cfg_creep:find(BossID),
			RebSec = NowSec + Reborn,
%%			Name2  = io_lib:format("~w~ts ~ts", [Level, cfg_lang:find(level), Name]),
%%			Opts   = #{name=>Name2, exargs=>#{"boss_reborn"=>RebSec}},
%%			[Tomb] = creep:sync_add(SceneID, 0, 1, [{1099999,Coord,Opts}]),
			KLog   = #p_killed{
				time    = NowSec,
				killer  = Atker#actor.name,
				quality = Qual
			},
			Klogs2 = [KLog | Boss#boss.klog],
			Kill2  = Boss#boss.kill + 1,
			Boss2  = Boss#boss{born=RebSec, klog=Klogs2, kill=Kill2},
			ets:insert(?ETS_BOSS, Boss2),
			%% 数量减1
			gen_server:cast(?SERVER, {update_num, BossID0});

%%			case ets:lookup(?ETS_BOSS, BossID0) of
%%				[BB] ->
%%					ets:insert(?ETS_BOSS, BB#boss{num = max(0, BB#boss.num - 1)});
%%				_ ->
%%					skip
%%			end;

		[] ->
			ignore
	end,
	{noreply, State};

%% 关注 Boss
do_handle_cast({care, 1, BossID, RoleID}, State) ->
	case ets:lookup(?ETS_BOSS, BossID) of
		[Boss] ->
			case lists:member(RoleID, Boss#boss.care) of
				true  ->
					ignore;
				false ->
					Care2 = [RoleID | Boss#boss.care],
					ets:insert(?ETS_BOSS, Boss#boss{care=Care2})
			end;
		[] ->
			ignore
	end,
	{noreply, State};

%% 取消关注
do_handle_cast({care, 2, BossID, RoleID}, State) ->
	case ets:lookup(?ETS_BOSS, BossID) of
		[Boss] ->
			Care2 = lists:delete(RoleID, Boss#boss.care),
			ets:insert(?ETS_BOSS, Boss#boss{care=Care2});
		[] ->
			ignore
	end,
	{noreply, State};

do_handle_cast({weakcd, ScenePid, BossID, WeakCD}, State) ->
	case ets:lookup(?ETS_BOSS, BossID) of
		[Boss] ->
			WeakSec = ut_time:seconds() + WeakCD,
			ets:insert(?ETS_BOSS, Boss#boss{weak=WeakSec}),
			scene:bcast(ScenePid, #m_boss_info_toc{
				id   = BossID,
				type = Boss#boss.type,
				born = Boss#boss.born,
				weak = WeakSec,
				num  = Boss#boss.num
			});
		[] ->
			ignore
	end,
	{noreply, State};

%% 提升品质
do_handle_cast({evolve, ScenePid, BossID, IsDeath}, State) ->
	case ets:lookup(?ETS_BOSS, BossID) of
		[Boss] ->
			?debug("evolve-------------:~w", [{BossID, IsDeath}]),
			NextID = case cfg_boss:next(BossID) of
				0 -> BossID;
				N -> N
			end,
			ets:delete(?ETS_BOSS, BossID),
			CfgBoss = cfg_boss:find(BossID),
					#cfg_boss{name=Name, weak=WeakCD, floor=Floor} = CfgBoss,
					Boss2 = Boss#boss{id=NextID, weak=ut_time:seconds()+WeakCD},
			case IsDeath of
				true  ->
					ets:insert(?ETS_BOSS, Boss2);
				false ->
					do_summon(Boss2),
					ets:insert(?ETS_BOSS, Boss2#boss{born=0, tomb=0})
			end,
			scene:bcast(ScenePid, #m_boss_change_toc{
				oldid = BossID,
				newid = NextID
			}),
			#cfg_boss{qual=Qual} = cfg_boss:find(NextID),
			?notify(?MSG_BOSS_EVOLVE, [
				Floor,
				Name,
				{color,cfg_lang:find({color,Qual}),Qual}
			]);
		[] ->
			ignore
	end,
	{noreply, State};

%% 降低品质
do_handle_cast({weaken, ScenePid, BossID}, State) ->
	case ets:lookup(?ETS_BOSS, BossID) of
		[Boss] ->
			ets:delete(?ETS_BOSS, BossID),
			PrevID = cfg_boss:prev(BossID),
			Boss2  = Boss#boss{id=PrevID},
			do_summon(Boss2),
			ets:insert(?ETS_BOSS, Boss2#boss{born=0, tomb=0}),
			scene:bcast(ScenePid, #m_boss_change_toc{
				oldid = BossID,
				newid = PrevID
			});
		[] ->
			ignore
	end,
	{noreply, State};

do_handle_cast({update_num, BossID}, State) ->
	ets:update_counter(?ETS_BOSS, BossID, {#boss.num,-1}),
	{noreply, State};

do_handle_cast({update_num_add, BossID}, State) ->
	ets:update_counter(?ETS_BOSS, BossID, {#boss.num, 1}),
	{noreply, State};


% 时空裂缝固定boss死亡，会触发两件事情，一是刷新特殊宝箱（类似精粹宝箱什么的，应该加一个标识的字段来区分获取id？），二是刷新隐藏boss（达到条件即可刷新，事实上应该在ets_boss上保存数据的做法比较好）
do_handle_cast({fissure_fix_boss_dead, BossID}, State) ->
	case ets:lookup(?ETS_BOSS, BossID) of
		[Boss] ->
			ets:insert(?ETS_BOSS, Boss#boss{num=0}),
			% 刷新大宝箱
			TeasureId = get_fissure_treasure_by_boss(BossID),
			case ets:lookup(?ETS_BOSS, TeasureId) of
				[Coll] ->
%%					CfgColl = #cfg_boss{num=Max} = cfg_boss:find(Coll#boss.id),
					CfgColl = #cfg_boss{} = cfg_boss:find(Coll#boss.id),
					#cfg_boss{coord=Coords} = cfg_boss:find(BossID),
%%					case Coll#boss.kill >= Max of
%%						true  ->
%%							ignore;
%%						false ->
							Reborn = when_to_reborn(Coll#boss.id),
							RebornSec = ut_time:seconds() + Reborn,
							CoordList = tl(tuple_to_list(Coords)),
							{X, Y} = ut_rand:choose(CoordList),
							do_summon4(Coll, CfgColl, #p_coord{x=X, y=Y}, #{etime=>RebornSec}),
							ets:insert(?ETS_BOSS, Coll#boss{num=Coll#boss.num+1});
%%					end;
				_ ->
					ignore
			end,
			% 刷新隐藏boss
			lists:foreach(fun
				({ID, Reqs}) ->
					case lists:member(BossID, Reqs) of
						true  ->
							%% 直接就是判断了死亡的boss在条件列表里就做下面的刷新了
							case ets:lookup(?ETS_BOSS, ID) of
								[B] when B#boss.num == 0 ->
									TemK = {boss_refresh_con, ID},
									Lcon = case erlang:get(TemK) of
										undefined ->
											[];
										Lcon0 ->
											Lcon0
									end,
									Lcon2 = [BossID|lists:delete(BossID, Lcon)],
									case erlang:length(Reqs) == erlang:length(Lcon2) of
										true ->
											erlang:erase(TemK),


%%									Refresh = lists:all(fun
%%										(ID2) ->
%%											case ets:lookup(?ETS_BOSS, ID2) of
%%												[B2] -> B2#boss.num == 0;
%%												[] -> true
%%											end
%%									end, Reqs),
									case true of
										true  ->
											CfgBoss = #cfg_boss{coord=Coords2, name=_BossName} = cfg_boss:find(ID),
											CoordList2 =
												if
													is_integer(erlang:element(1,Coords2))->
														[Coords2];
													true ->
														tuple_to_list(Coords2)
												end
											 ,
											CoordList3 = get_valid_coord_list(CoordList2),
											{X2,Y2} = ut_rand:choose(CoordList3),
											boss_coord_in(ID, {X2,Y2}),
											do_summon4(B, CfgBoss, #p_coord{x=X2, y=Y2}, #{}),
											ets:insert(?ETS_BOSS, B#boss{num=1}),
											#cfg_boss{scene=SceneID} = cfg_boss:find(ID),
											scene:bcast(SceneID, #m_boss_info_toc{
												id   = ID,
												type = B#boss.type,
												born = B#boss.born,
												weak = 0,
												num  = 1
											}),
											cluster:notify(
												?CROSS_RULE_24_8,
												?MSG_TIMERIFT_HIDE_BOSS,
												[
%%													BossName
												]
											);
										false ->
											ignore
									end;
										false ->
											erlang:put(TemK, Lcon2)
											end;
								_ ->
									ignore
							end;
						false ->
							ignore
					end
			end, cfg_game:fissure_refresh_boss());
		[] ->
			ignore
	end,
	{noreply, State};

% 时空裂缝普通宝箱
do_handle_cast({refresh_fissure_coll, coll1}, State) ->
	{noreply, State};

do_handle_cast({gm_summon, BossID}, State) ->
	[Boss] = ets:lookup(?ETS_BOSS, BossID),
	do_summon(Boss),
	{noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.


do_handle_info(check, State) ->
	loop_check(),
	ets:safe_fixtable(?ETS_BOSS, true),
    check_summon(ets:first(?ETS_BOSS), ut_time:seconds()),
    ets:safe_fixtable(?ETS_BOSS, false),
	{noreply, State};

do_handle_info({refresh, SummonFun, BossID}, State) ->
	[Boss] = ets:lookup(?ETS_BOSS, BossID),
	Boss2  = ?MODULE:SummonFun(Boss),
	ets:insert(?ETS_BOSS, Boss2),
	#cfg_boss{scene=SceneID} = cfg_boss:find(BossID),
	scene:bcast(SceneID, #m_boss_info_toc{
		id   = BossID,
		type = Boss2#boss.type,
		born = Boss2#boss.born,
		weak = 0,
		num  = Boss2#boss.num
	}),
	{noreply, State};

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.

-define(BOSS_COORD_VALID_KEY, boss_coord_valid).
boss_coord_in(BossID, Coord) ->
	L = case erlang:get(?BOSS_COORD_VALID_KEY) of
		undefined ->
			[];
		L0 ->
			L0
	end,
	L2 = lists:keydelete(BossID, 1, L),
	erlang:put(?BOSS_COORD_VALID_KEY, [{BossID, Coord}|L2]).

boss_coord_out(BossID) ->
	L = case erlang:get(?BOSS_COORD_VALID_KEY) of
				undefined ->
					[];
				L0 ->
					L0
			end,
	L2 = lists:keydelete(BossID, 1, L),
	erlang:put(?BOSS_COORD_VALID_KEY, L2).

get_valid_coord_list(CoordList) ->
	L = case erlang:get(?BOSS_COORD_VALID_KEY) of
				undefined ->
					[];
				L0 ->
					L0
			end,
	lists:foldl(fun({_, Coord}, Acc) ->
								 lists:delete(Coord, Acc)
							end, CoordList, L).

init_boss(BossID, BossKill) ->
	#cfg_boss{type=Type, qual=Qual, group=Group, floor=Floor} = cfg_boss:find(BossID),
	Kill = maps:get(BossID, BossKill, 0),
	Boss = #boss{id=BossID, type=Type, kill=Kill, floor=Floor, group=Group},
	case Qual =< ?COLOR_GREEN of
		true  ->
			?debug("-----------------------:~w", [BossID]),
			Boss2 = do_summon(Boss),
			ets:insert(?ETS_BOSS, Boss2);
		false when Type == ?BOSS_TYPE_SPATIOTEMPORAL2 ->
			ets:insert(?ETS_BOSS, Boss);
		false ->
			ignore
	end.

loop_check() ->
	erlang:send_after(timer:seconds(1), self(), check).

check_summon('$end_of_table', _NowSec) ->
	ok;
check_summon(BossID, NowSec) ->
	[Boss = #boss{type=Type, born=Born}] = ets:lookup(?ETS_BOSS, BossID),
	case Type of
		?BOSS_TYPE_SPATIOTEMPORAL2 ->
			skip;
		_ ->
			case Boss#boss.born - NowSec == 60 of
				true  -> ?bcast(Boss#boss.care, #m_boss_remind_toc{id=BossID});
				false -> ignore
			end,
			#cfg_creep{rarity=Rarity} = cfg_creep:find(BossID),
			case Rarity == ?CREEP_RARITY_BOSS andalso Born > 0 andalso NowSec >= Born of
				true  ->
					% 删除墓碑
					#cfg_boss{scene=SceneID} = cfg_boss:find(Boss#boss.id),
					creep:del(SceneID, 0, 1, Boss#boss.tomb),
					do_summon(Boss),
					ets:insert(?ETS_BOSS, Boss#boss{born=0, tomb=0}),

					case Type == ?BOSS_TYPE_PET of
						true  ->
							ignore;
						false ->
							#cfg_boss{name=BossName, scene=SceneID} = cfg_boss:find(BossID),
							#cfg_scene{name=SceneName} = cfg_scene:find(SceneID),
							case cluster:is_local() of
								true  ->
									SubID = case Type of
														?BOSS_TYPE_WORLD -> 1;
														?BOSS_TYPE_HOME  -> 2;
														?BOSS_TYPE_WILD  -> 3;
														?BOSS_TYPE_BEAST -> 13;
														?BOSS_TYPE_BEAST_CROSS -> 12;
														_ -> 0
													end,
									Panel = lists:flatten(io_lib:format("160@1@1@~w@~w", [SubID, BossID])),
									?notify(?MSG_BOSS_BORN, [BossName, SceneName, {"panel",Panel}]);
								false ->
									ignore
							end
					end;
				false ->
					ignore
			end
	end,
	check_summon(ets:next(?ETS_BOSS, BossID), NowSec).

do_summon(Boss) ->
	#cfg_creep{rarity=Rarity} = cfg_creep:find(Boss#boss.id),
	case Rarity == ?CREEP_RARITY_BOSS of
		true  ->
			do_summon2(Boss);
		false ->
			case cfg_boss:find(Boss#boss.id) of
				#cfg_boss{type = ?BOSS_TYPE_SPATIOTEMPORAL, group = 1} ->
					do_summon5(Boss);
				_ ->
					do_summon3(Boss)
			end
%%			case Boss#boss.id == ?FISSURE_TREASURE of
%%				true  ->
%%					do_summon5(Boss);
%%				false ->
%%					do_summon3(Boss)
%%			end
	end.

%% 生成Boss
do_summon2(Boss) when Boss#boss.type == ?BOSS_TYPE_SPATIOTEMPORAL ->
	CfgBoss = #cfg_boss{coord=Coords} = cfg_boss:find(Boss#boss.id),
	{X,Y} = element(1, Coords),
	do_summon4(Boss, CfgBoss, #p_coord{x=X, y=Y}, #{}),
	Boss#boss{num=1};
do_summon2(Boss) when Boss#boss.type == ?BOSS_TYPE_SPATIOTEMPORAL2 ->
	CfgBoss = #cfg_boss{coord=Coords} = cfg_boss:find(Boss#boss.id),
	{X,Y} = ut_rand:choose(tuple_to_list(Coords)),
	do_summon4(Boss, CfgBoss, #p_coord{x=X, y=Y}, #{}),
	Boss#boss{num=1};
do_summon2(Boss) ->
	CfgBoss = #cfg_boss{coord={X,Y}} = cfg_boss:find(Boss#boss.id),
	do_summon4(Boss, CfgBoss, #p_coord{x=X, y=Y}, #{}),
	Boss.

%% 生成异兽岛守卫、水晶，时空裂缝普通宝箱
do_summon3(Boss) ->
	CfgBoss = #cfg_boss{num=Num, coord=Coords} = cfg_boss:find(Boss#boss.id),
	Reborn  = when_to_reborn(Boss#boss.id),
	CoordList = ut_rand:choose(tuple_to_list(Coords), Num, false),
	RebornSec = ut_time:seconds() + Reborn,
	lists:foreach(fun
		({X,Y}) ->
			do_summon4(Boss, CfgBoss, #p_coord{x=X, y=Y}, #{etime=>RebornSec})
	end, CoordList),
	erlang:send_after(timer:seconds(Reborn), self(), {refresh, do_summon3, Boss#boss.id}),
	Boss#boss{born=RebornSec, num=Num}.

%% 生成时空裂缝精粹宝箱
do_summon5(Boss) ->
	CfgBoss = #cfg_boss{coord=Coords} = cfg_boss:find(Boss#boss.id),
	Reborn  = when_to_reborn(Boss#boss.id),
	CoordList = tuple_to_list(Coords),
	RebornSec = ut_time:seconds() + Reborn,
	lists:foreach(fun
		({X,Y}) ->
			do_summon4(Boss, CfgBoss, #p_coord{x=X, y=Y}, #{etime=>RebornSec})
	end, CoordList),
	erlang:send_after(timer:seconds(Reborn), self(), {refresh, do_summon5, Boss#boss.id}),
	Boss#boss{born=RebornSec, num=length(CoordList)}.

do_summon4(Boss, CfgBoss, Coord, Opts) ->
	#cfg_boss{scene=SceneID, reward=Reward} = CfgBoss,
	DropID = what_to_drop(Reward, Boss#boss.kill),
	Opts1  = case DropID > 0 of
		true  -> #{exargs=>#{boss_drop=>[{DropID,1}]}};
		false -> #{}
	end,
	Opts2  = maps:merge(Opts1, Opts),
	creep:add(SceneID, 0, 1, [{Boss#boss.id, Coord, Opts2}]).

when_to_reborn(BossID) ->
	#cfg_boss{reborn=Reborn, type=Type} = cfg_boss:find(BossID),
	if
		Type == ?BOSS_TYPE_SPATIOTEMPORAL ->
			max(60, activity:stime(12010) - ut_time:seconds());
		Type == ?BOSS_TYPE_SPATIOTEMPORAL2 ->
			0;
		true ->
			WorldLv = world_level:get_level(),
			when_to_reborn2(Reborn, WorldLv)
	end.

when_to_reborn2([{Min,Max,Secs} | T], WorldLv) ->
	case Min =< WorldLv andalso WorldLv =< Max of
		true  -> Secs;
		false -> when_to_reborn2(T, WorldLv)
	end.

what_to_drop([{Min,Max,DropID} | T], Killed) ->
	case Min =< Killed andalso Killed =< Max of
		true  -> DropID;
		false -> what_to_drop(T, Killed)
	end;
what_to_drop([], _) ->
	0.

hook_fight(_Atker, Defer, _DmgVal, _SceneSt) when ?is_boss(Defer), ?is_death(Defer#actor.state) ->
	Defer2 = boss_ai:change_belong(Defer),
	scene_actor:set_actor(Defer2);
hook_fight(_Atker, _Defer, _DmgVal, _SceneSt) ->
	ok.

% 世界 Boss
hook_drop(Defer, _Drops, SceneSt) when ?in_world(SceneSt);
									   ?in_home(SceneSt);
									   ?in_beast(SceneSt);
									   ?in_wild(SceneSt);
									   ?in_pet(SceneSt);
									   ?in_fissure(SceneSt) ->
	TeamID = maps:get("belong_team", Defer#actor.exargs, 0),
	RoleID = maps:get("belong_role", Defer#actor.exargs, 0),
	#cfg_creep{opts=AddVal} = cfg_creep:find(Defer#actor.id),
	case TeamID > 0 of
		true  ->
			#actor{id=CreepID, born=Coord} = Defer,
			#cfg_creep{guard=Guard} = cfg_creep:find(CreepID),
			lists:foreach(fun
				(MembID) ->
					Memb = scene_actor:get_actor(MembID),
					case
						Memb /= ?nil andalso
						scene_util:is_nearby(Memb#actor.coord, Coord, Guard)
					of
					 	true  ->
					 		if
					 			?in_world(SceneSt); ?in_beast(SceneSt) ->
					 				do_add_tired(Memb, 1, SceneSt);
					 			?in_wild(SceneSt); ?in_pet(SceneSt) ->
					 				do_add_anger(Memb, AddVal, SceneSt);
					 			?in_fissure(SceneSt) ->
					 				do_add_tired(Memb, 1, SceneSt),
					 				Memb2 = scene_actor:get_actor(MembID),
					 				do_add_anger(Memb2, AddVal, SceneSt);
					 			?in_home(SceneSt), is_integer(AddVal) ->
					 				do_add_vigor(Memb, AddVal, SceneSt);
					 			true ->
					 				ignore
					 		end;
					 	false ->
					 		ignore
					end
			end, scene_team:get_membs(TeamID));
		false ->
			case scene_actor:get_actor(RoleID) of
				?nil  ->
					ignore;
				Actor ->
					if
						?in_world(SceneSt); ?in_beast(SceneSt) ->
							do_add_tired(Actor, 1, SceneSt);
						?in_wild(SceneSt); ?in_pet(SceneSt) ->
							do_add_anger(Actor, AddVal, SceneSt);
						?in_fissure(SceneSt) ->
			 				do_add_tired(Actor, 1, SceneSt),
			 				Actor2 = scene_actor:get_actor(RoleID),
			 				do_add_anger(Actor2, AddVal, SceneSt);
						?in_home(SceneSt), is_integer(AddVal) ->
							do_add_vigor(Actor, AddVal, SceneSt);
						true ->
							ignore
					end
			end
	end;
hook_drop(Defer, Drops, SceneSt) when ?in_notired(SceneSt) ->
	case ?is_boss(Defer) andalso cfg_boss_attend:has_reward(Defer#actor.id) of
		true ->
			Threats = fight_threat:sort(hybrid, Defer#actor.threat),
            SortRoles0 = lists:sublist(Threats, 10),
            SortRoles1 = lists:zip(SortRoles0, lists:seq(1, length(SortRoles0))),
            lists:foreach(fun({{SortID, _}, Rank}) ->
            	Atkers = case SortID of
            		{role, RoleID} ->
		            	case scene_actor:get_actor(RoleID) of
		            		?nil  -> [];
		            		Atker ->
		            			[Atker]
		            	end;
		            {team, TeamID} ->
		            	TeamInfo = team_server:get_team(TeamID),
						Ids = team_server:get_team_member_ids(TeamInfo),
		            	lists:foldl(fun(RID, Acc) ->
		            		case scene_actor:get_actor(RID) of
			            		?nil  -> Acc;
			            		Atker ->
			            			[Atker|Acc]
			            	end
		            	end, [], Ids)
		        end,
		        [case creep_drop:check_drop(Atker, Defer, SceneSt) of
    				true ->
    					case cfg_boss_attend:find(Defer#actor.id, Rank) of
			            	Rewards when Rewards =/= [] ->
			            		role:cast(Atker#actor.pid, {drop_item, Defer, Drops, true}),
				            	mail:send(Atker#actor.uid, ?MAIL_BOSS_ATTEND, Rewards,
				            		[Defer#actor.name, Rank]);
				            _ ->
				            	ignore
				        end;
		           	false ->
		           		ignore
		        end || Atker <- Atkers]
            end, SortRoles1);
        _ ->
            ignore
    end;
hook_drop(_Actor, _Drops, _SceneSt) ->
	ignore.

% 宠物 Boss
hook_boss_dead(_Atker, Defer, SceneSt) when ?in_pet(SceneSt) ->
	#cfg_boss{group=Group, floor=Floor, qual=Qual} = cfg_boss:find(Defer#actor.id),

	LivingBosses = lists:filtermap(fun
		({{k_actor,ActorID}, Actor}) ->
			case ?is_boss(Actor) andalso ActorID /= Defer#actor.uid of
				true  ->
					#cfg_boss{group=Group2} = cfg_boss:find(Actor#actor.id),
					case Group2 == Group of
						true  -> {true, Actor};
						false -> false
					end;
				false ->
					false
			end;
		(_) ->
			false
	end, get()),

	CurBosses = ets:match_object(?ETS_BOSS,
		#boss{type=?BOSS_TYPE_PET, group=Group, floor=Floor, _='_'}
	),

	CanImprove = lists:filtermap(fun
		(#boss{id=BossID}) ->
			#cfg_boss{group=Group2, qual=Qual2} = cfg_boss:find(BossID),
			case lists:keyfind(BossID, #actor.id, LivingBosses) of
				false ->
					case Qual2 < ?COLOR_PINK of
						true  -> {true, {BossID, 100}};
						false -> false
					end;
				Actor ->
					#{?ATTR_HP:=Hp, ?ATTR_HPMAX:=HpMax} = Actor#actor.attr,
					#cfg_boss{group=Group2, qual=Qual2} = cfg_boss:find(BossID),
					case Qual2 < ?COLOR_PINK andalso Hp >= HpMax of
						true  -> {true, {Actor, 100}};
						false -> false
					end
			end
	end, CurBosses),

	WtList  = case Qual < ?COLOR_PINK of
		true  -> [{Defer,100} | CanImprove];
		false -> CanImprove
	end,
	Improve = case WtList == [] of
		true  -> [];
		false -> ut_rand:weight(WtList, min(2,length(WtList)), false)
	end,

	lists:foreach(fun
		(Actor) when is_record(Actor, actor) ->
			#actor{id=BossID, state=State} = Actor,
			?_if(not ?is_death(State), creep_agent:del(Actor, SceneSt)),
			gen_server:cast(?SERVER, {evolve, self(), BossID, ?is_death(State)});
		(BossID) ->
			gen_server:cast(?SERVER, {evolve, self(), BossID, true})
	end, Improve);
hook_boss_dead(_Atker, _Defer, _SceneSt) ->
	ignore.


hook_role_dead2(_Atker, Defer, SceneSt) when ?in_world(SceneSt); ?in_beast(SceneSt) ->
	% 死亡疲劳 buff
	BuffID = case ?in_world(SceneSt) of
		true  -> ?BUFF_ID_WORLD_BOSS_DEAD_TIRED;
		false -> ?BUFF_ID_BEAST_BOSS_DEAD_TIRED
	end,
	#cfg_buff{group=Group} = cfg_buff:find(BuffID),
	TiredBuff = maps:get(Group, Defer#actor.buffs, ?nil),
	case TiredBuff == ?nil orelse TiredBuff#p_buff.value < 5 of
		true  -> buff_util:add_buffs(Defer, [BuffID]);
		false -> ignore
	end;
hook_role_dead2(_Atker, Defer, SceneSt) when ?in_wild(SceneSt); ?in_pet(SceneSt) ->
	do_add_anger(Defer, cfg_game:boss_anger_kill(), SceneSt);
hook_role_dead2(_Atker, Defer, SceneSt) when ?in_fissure(SceneSt) ->
	do_add_anger(Defer, 20, SceneSt);
hook_role_dead2(_Atker, _Defer, _SceneSt) ->
	ignore.


hook_creep_dead2(Atker, Defer, SceneSt) when ?in_wild(SceneSt); ?in_pet(SceneSt) ->
	#cfg_creep{opts=AngerAdd} = cfg_creep:find(Defer#actor.id),
	do_add_anger(Atker, AngerAdd, SceneSt);
hook_creep_dead2(Atker, Defer, SceneSt) when ?in_fissure(SceneSt) ->
	[Boss] = ets:lookup(?ETS_BOSS, Defer#actor.id),
	scene_util:bc_to_scene(#m_boss_info_toc{
		id   = Boss#boss.id,
		type = Boss#boss.type,
		born = Boss#boss.born,
		num  = Boss#boss.num - 1
	}),
	gen_server:cast(?SERVER, {update_num, Defer#actor.id}),
	#cfg_creep{opts=AngerAdd} = cfg_creep:find(Defer#actor.id),
	do_add_anger(Atker, AngerAdd, SceneSt);
hook_creep_dead2(Atker, Defer, SceneSt) when ?in_beast(SceneSt) ->
	[Boss] = ets:lookup(?ETS_BOSS, Defer#actor.id),
	scene_util:bc_to_scene(#m_boss_info_toc{
		id   = Boss#boss.id,
		type = Boss#boss.type,
		born = Boss#boss.born,
		num  = Boss#boss.num - 1
	}),
	gen_server:cast(?SERVER, {update_num, Defer#actor.id}),
	?_if(?is_coll(Defer), do_add_coll(Atker, Defer, SceneSt));
hook_creep_dead2(_Atker, _Defer, _SceneSt) ->
	ok.

%% 增加采集次数
do_add_coll(Atker, Defer, _SceneSt) ->
	#cfg_creep{opts=CollType} = cfg_creep:find(Defer#actor.id),
	{MaxTimes, BuffID} =
		case CollType == coll1 of
		true  ->
			{cfg_game:beast_collect(), ?BUFF_ID_BEAST_BOSS_COLL_TIRED};
		false ->
			{cfg_game:beast_collect2(), ?BUFF_ID_BEAST_BOSS_COLL2_TIRED}
	end,
	case buff_util:get_buff(Atker, BuffID) of
		?nil ->
			do_add_coll1(Atker, BuffID, 1, MaxTimes);
		Buff ->
			#p_buff{value=Times, etime=ETime1} = Buff,
			ETime2 = ut_time:midnight(),
			case ETime1 == ETime2 of
				true  ->
					case Times >= MaxTimes of
						true  -> ignore;
						false -> do_add_coll2(Atker, BuffID, Times+1, MaxTimes, ETime2)
					end;
				false ->
					do_add_coll2(Atker, BuffID, 1, MaxTimes, ETime2)
			end
	end.

do_add_coll1(Actor, BuffID, Times, MaxTimes) ->
	ETime = ut_time:midnight(),
	do_add_coll2(Actor, BuffID, Times, MaxTimes, ETime).

do_add_coll2(Actor, BuffID, Times, MaxTimes, ETime) ->
	Opts = #{value=>Times, etime=>ETime},
	buff_util:add_buffs(Actor, [{BuffID, Opts}]),
	?notify(Actor#actor.uid, ?MSG_BEAST_COLLECT, [Times, MaxTimes]).


%% 增加疲劳值
do_add_tired(Actor, TiredAdd, SceneSt) ->
	BuffID = if
		?in_world(SceneSt) ->
			?BUFF_ID_WORLD_BOSS_KILL_TIRED;
		?in_fissure(SceneSt) ->
			?BUFF_ID_FISSURE_BOSS_TIRED;
		true ->
			?BUFF_ID_BEAST_BOSS_KILL_TIRED
	end,
	case buff_util:get_buff(Actor, BuffID) of
		?nil ->
			do_add_tired1(Actor, BuffID, TiredAdd);
		Buff ->
			#p_buff{value=Tired, etime=ETime1} = Buff,
			ETime2 = ut_time:midnight(),
			case ETime1 == ETime2 of
				true  ->
					case Tired >= max_tired(Actor, SceneSt#scene_st.stype) of
						true  -> ignore;
						false -> do_add_tired2(Actor, BuffID, Tired+TiredAdd, ETime2)
					end;
				false ->
					do_add_tired2(Actor, BuffID, TiredAdd, ETime2)
			end

	end.

do_add_tired1(Actor, BuffID, Tired) ->
	ETime = ut_time:midnight(),
	do_add_tired2(Actor, BuffID, Tired, ETime).

do_add_tired2(Actor, BuffID, Tired, ETime) ->
	?debug(
		"do_add_tired2--------------:~w", [
		{Actor#actor.uid, Actor#actor.team, scene_team:get_membs(Actor#actor.team), BuffID, Tired, ut_time:seconds_to_datetime(ETime)}
	]),
	Opts = #{value=>Tired, etime=>ETime, cover=>true},
	buff_util:add_buffs(Actor, [{BuffID, Opts}]).


%% 增加愤怒值
do_add_anger(Actor, AngerAdd, _SceneSt) ->
	#actor{uid=ActorID, exargs=ExArgs} = Actor,
	Anger  = maps:get(boss_anger, ExArgs, 0),
	Anger2 = Anger + AngerAdd,
	case Anger2 >= 100 of
		true when Anger >= 100 ->
			ignore;
		true  ->
			ExArgs2  = maps:put(boss_anger, Anger2, ExArgs),
			KickTime = cfg_game:boss_anger_kickout(),
			fight_timer:add_task(
				{ActorID, ?MODULE, kickout}, KickTime, ?MODULE, kickout
			),
			KickCD  = ut_time:seconds() + KickTime,
			ExArgs3 = maps:put(boss_kickcd, KickCD, ExArgs2),
			scene_actor:set_actor(Actor#actor{exargs=ExArgs3}),
			?ucast(ActorID, #m_boss_anger_toc{anger=Anger2, kickcd=KickCD});
		false ->
			ExArgs2 = maps:put(boss_anger, Anger2, ExArgs),
			scene_actor:set_actor(Actor#actor{exargs=ExArgs2}),
			?ucast(ActorID, #m_boss_anger_toc{anger=Anger2, kickcd=0})
	end.


%% 增加精力值
do_add_vigor(Actor, VigorAdd, _SceneSt) ->
	BuffID = ?BUFF_ID_HOME_BOSS_VIGOR,
	case buff_util:get_buff(Actor, BuffID) of
		?nil ->
			do_add_vigor1(Actor, BuffID, VigorAdd);
		Buff ->
			#p_buff{value=Vigor, etime=ETime1} = Buff,
			ETime2 = calc_vigor_etime(),
			case ETime1 == ETime2 of
				true  ->
					case Vigor >= 100 of
						true  -> ignore;
						false -> do_add_vigor2(Actor, BuffID, Vigor+VigorAdd, ETime2)
					end;
				false ->
					do_add_vigor2(Actor, BuffID, VigorAdd, ETime2)
			end
	end.

do_add_vigor1(Actor, BuffID, Vigor) ->
	ETime = calc_vigor_etime(),
	do_add_vigor2(Actor, BuffID, Vigor, ETime).

do_add_vigor2(Actor, BuffID, Vigor, ETime) ->
	Opts = #{value=>Vigor, etime=>ETime, cover=>true},
	buff_util:add_buffs(Actor, [{BuffID, Opts}]).


calc_vigor_etime() ->
	{Date, {Hour,_,_}} = ut_time:datetime(),
	calc_vigor_etime1(Date, Hour, [0,8,16]).

calc_vigor_etime1(Date, Hour, ResetHours=[H|_]) ->
	case calc_vigor_etime2(Hour, ResetHours) of
		expired -> ut_time:midnight() + H * 60 * 60;
		RstHour -> ut_time:datetime_to_seconds({Date,{RstHour,0,0}})
	end.

calc_vigor_etime2(_Hour, []) ->
	expired;
calc_vigor_etime2(Hour, [H | T]) ->
	case Hour < H of
		true  -> H;
		false -> calc_vigor_etime2(Hour, T)
	end.


leave_wild(Actor) ->
	Actor#actor{
		exargs = maps:without([boss_anger, boss_kickcd], Actor#actor.exargs)
	}.


is_cross_boss_type(Type) ->
	cfg_boss:kind(Type) == ?BOSS_KIND_CROSS.

is_cross_boss_id(BossID) ->
	#cfg_boss{kind=Kind} = cfg_boss:find(BossID),
	Kind == ?BOSS_KIND_CROSS.

rpc_call_cross(Fun, Args) ->
	cluster:rpc_call_cross(?CROSS_RULE_24_8, ?MODULE, Fun, Args).

gen_cast_cross(Msg) ->
	cluster:gen_cast_cross(?CROSS_RULE_24_8, ?SERVER, Msg).

do_get_boss(BossID) ->
	case ets:lookup(?ETS_BOSS, BossID) of
		[Boss] ->
			{ok, Boss};
		[] ->
			?err(?ERR_BOSS_NOT_FOUND)
	end.

do_get_bosses(?BOSS_TYPE_SPATIOTEMPORAL) ->
	[Boss || Boss <- ets:tab2list(?ETS_BOSS), Boss#boss.type == ?BOSS_TYPE_SPATIOTEMPORAL orelse Boss#boss.type == ?BOSS_TYPE_SPATIOTEMPORAL2];
do_get_bosses(Type) ->
	[Boss || Boss <- ets:tab2list(?ETS_BOSS), Boss#boss.type == Type].

% get_fissure_colls(Type) ->
% 	ok. 

-define(PROC_DICT_KEY_FISSURE_TREASURE(Floor), {fissure_treasure, Floor}).
-define(PROC_DICT_KEY_FISSURE_HIGHBOSS(Floor), {fissure_highboss, Floor}).

get_fissure_treasure_by_boss(BossID) ->
	#cfg_boss{floor = Floor} = cfg_boss:find(BossID),
	get_fissure_treasure_by_floor(Floor).

get_fissure_treasure_by_floor(Floor) ->
	case erlang:get(?PROC_DICT_KEY_FISSURE_TREASURE(Floor)) of
		Id when is_integer(Id) andalso Id > 0 ->
			Id;
		_ ->
			BossIds = cfg_boss:all(?BOSS_KIND_LOCAL) ++ cfg_boss:all(?BOSS_KIND_CROSS),
			Id = get_fissure_treasure_by_floor(Floor, BossIds),
			erlang:put(?PROC_DICT_KEY_FISSURE_TREASURE(Floor), Id),
			Id
	end.

get_fissure_treasure_by_floor(Floor, [BossId|BossIds]) ->
	case cfg_boss:find(BossId) of
		#cfg_boss{type = ?BOSS_TYPE_SPATIOTEMPORAL, floor = Floor, group = 1} ->
			BossId;
		_ ->
			get_fissure_treasure_by_floor(Floor, BossIds)
	end;

get_fissure_treasure_by_floor(_Floor, []) ->
	0.

get_fissure_first_high_boss(BossId0) ->
	#cfg_boss{floor = Floor} = cfg_boss:find(BossId0),
	case erlang:get(?PROC_DICT_KEY_FISSURE_HIGHBOSS(Floor)) of
		Id when is_integer(Id) andalso Id > 0 ->
			Id;
		_ ->
			BossIds = cfg_boss:all(?BOSS_KIND_LOCAL) ++ cfg_boss:all(?BOSS_KIND_CROSS),
			Fun =
				fun(BossId, Acc) ->
					case cfg_boss:find(BossId) of
						#cfg_boss{type = ?BOSS_TYPE_SPATIOTEMPORAL2, floor = Floor} ->
							if
								Acc == 0 ->
									BossId;
								Acc > BossId ->
									BossId;
								true ->
									Acc
							end ;
						_ ->
							Acc
					end
				end,
			Id = lists:foldl(Fun, 0, BossIds),
			erlang:put(?PROC_DICT_KEY_FISSURE_HIGHBOSS(Floor), Id),
			Id
	end.

%%-compile([export_all]).
%%-compile(nowarn_export_all).
