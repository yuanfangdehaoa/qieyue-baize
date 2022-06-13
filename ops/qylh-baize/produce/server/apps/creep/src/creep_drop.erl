%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(creep_drop).

-include("attr.hrl").
-include("boss.hrl").
-include("creep.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("item.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([drop/3]).
-export([calc/2]).
-export([exp/4]).
-export([drop_remove/2]).
-export([check_drop/3]).

-define(AROUND, [
	cfg_game:drop_round1(),
	cfg_game:drop_round2(),
	cfg_game:drop_round3(),
	cfg_game:drop_round4(),
	cfg_game:drop_round5()
]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
drop(Atker, Defer, SceneSt=#scene_st{type=Type}) when ?is_role(Atker); ?is_faker(Atker) ->
	CfgCreep = cfg_creep:find(Defer#actor.id),
	case check_drop(Atker, Defer, SceneSt) of
		true  ->
			Belong = calc_belong(Atker, Defer, CfgCreep, SceneSt),
			Drops0 = get_drops(Defer, CfgCreep, SceneSt, true),
			Drops1 = case Type == ?SCENE_TYPE_FIELD andalso ?is_decay(Atker#actor.state) of
				true  -> [D || D <- Drops0, ut_rand:random(1, ?PER_10000) =< 5000];
				false -> Drops0
			end,
			Drops2  = do_calc2(Drops1, Atker#actor.level, []),
			Drops3  = filter_drops(Drops2, Atker, Defer, Belong, SceneSt),
			ExpDrop = drop_exp(Atker, Defer, CfgCreep, SceneSt),
			do_drop(Atker, Defer, CfgCreep, ExpDrop, Drops3, Belong, SceneSt),
			Defer#actor{belong=Belong};
		false ->
			do_drop(Atker, Defer, CfgCreep, #{}, [], [Atker#actor.uid], SceneSt),
			Defer#actor{belong=[]}
	end;
drop(_Atker, Defer, _SceneSt) ->
	Defer.

calc(AtkLv, CfgCreep) when is_record(CfgCreep, cfg_creep) ->
	SceneSt = scene_util:get_state(),
	do_calc(AtkLv, ?nil, CfgCreep, SceneSt, false);
calc(AtkLv, DropList) when is_list(DropList) ->
	do_calc2(DropList, AtkLv, []).

exp(CreepID, AttrID, CreepLv, RoleSt) when is_record(RoleSt, role_st) ->
	#role_st{spid=ScenePid, role=RoleID} = RoleSt,
	{ok, Actor} = scene:get_actor(ScenePid, RoleID),
	calc_exp_in_role(CreepID, AttrID, CreepLv, Actor);
exp(CreepID, AttrID, CreepLv, Actor) ->
	calc_exp_in_role(CreepID, AttrID, CreepLv, Actor).


%% 移除掉落
drop_remove({ActorID, _, _}, SceneSt) ->
	case scene_actor:get_actor(ActorID) of
		?nil  ->
			ignore;
		Actor ->
			scene_grid:leave(Actor, SceneSt),
			scene_actor:del_actor(ActorID)
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_drop(Atker, Defer, _SceneSt) when ?is_boss(Defer) ->
	#cfg_boss{type=Type, droplv=DropLv} = cfg_boss:find(Defer#actor.id),
	Limit = cfg_game:boss_drop_limit(),
	case lists:member(Type, Limit) of
		true  -> Atker#actor.level - Defer#actor.level < DropLv;
		false -> true
	end;
check_drop(_Atker, _Defer, _SceneSt) ->
	true.

get_drops(Defer, CfgCreep, SceneSt, IfCalcRare) ->
	#cfg_creep{drops=DropList1} = CfgCreep,
	DropList2 = get_act_drops(CfgCreep),
	DropList3 = ?_if(Defer == ?nil, [], scene_hook:get_drops(Defer, SceneSt)),
	DropList4 = ?_if(IfCalcRare, get_rare_drops(CfgCreep), []),
	DropList1 ++ DropList2 ++ DropList3 ++ DropList4.

do_calc(AtkerLv, Defer, CfgCreep, SceneSt, IfCalcRare) ->
	DropList = get_drops(Defer, CfgCreep, SceneSt, IfCalcRare),
	do_calc2(DropList, AtkerLv, []).

%% 活动掉落列表
get_act_drops(CfgCreep) ->
	List = cfg_drop_activity:find(CfgCreep#cfg_creep.rarity),
	get_act_drops2(List, CfgCreep, []).

get_act_drops2([{ActID, Reqs, DropList} | T], CfgCreep, Acc) ->
	case yunying:is_start(ActID) andalso check_act_reqs(Reqs, CfgCreep) of
		true  -> get_act_drops2(T, CfgCreep, DropList ++ Acc);
		false -> get_act_drops2(T, CfgCreep, Acc)
	end;
get_act_drops2([], _CfgCreep, Acc) ->
	Acc.

check_act_reqs([{boss_type, TypeList} | T], CfgCreep) ->
	case cfg_boss:find(CfgCreep#cfg_creep.id) of
		#cfg_boss{type=Type} ->
			case lists:member(Type, TypeList) of
				true  -> check_act_reqs(T, CfgCreep);
				false -> false
			end;
		_ ->
			false
	end;
check_act_reqs([{scene_type, TypeList} | T], CfgCreep) ->
	#cfg_scene{type=SceneType} = cfg_scene:find(CfgCreep#cfg_creep.scene),
	case lists:member(SceneType, TypeList) of
		true  -> check_act_reqs(T, CfgCreep);
		false -> false
	end;
check_act_reqs([{scene_stype, STypeList} | T], CfgCreep) ->
	#cfg_scene{stype=SceneSType} = cfg_scene:find(CfgCreep#cfg_creep.scene),
	case lists:member(SceneSType, STypeList) of
		true  -> check_act_reqs(T, CfgCreep);
		false -> false
	end;
check_act_reqs([{level, CreepLv} | T], CfgCreep) ->
	case CfgCreep#cfg_creep.level >= CreepLv of
		true  -> check_act_reqs(T, CfgCreep);
		false -> false
	end;
check_act_reqs([], _CfgCreep) ->
	true.

%% 珍稀掉落
get_rare_drops(CfgCreep) ->
	#cfg_creep{level=CreepLv, rare1=RareDrops1, rare2=RareDrops2} = CfgCreep,
	WorldLv = world_level:get_level(),
	if
		WorldLv < CreepLv  ->
			RareDrops1;
		WorldLv >= CreepLv ->
			RareDrops2
	end.

do_calc2([{DropID, Num} | T], AtkerLv, Acc) ->
	CfgDrop = cfg_drop:find(DropID, AtkerLv),
	Acc2    = do_calc3(Num, CfgDrop, Acc),
	do_calc2(T, AtkerLv, Acc2);
do_calc2([], _AtkerLv, Acc) ->
	Acc.

do_calc3(0, _CfgDrop, Acc) ->
	Acc;
do_calc3(_, ?nil, Acc) ->
	Acc;
do_calc3(Num, CfgDrop, Acc) ->
	#cfg_drop{rule=Rule, drop=DropInfo} = CfgDrop,
	Items = do_calc4(Rule, DropInfo),
	do_calc3(Num-1, CfgDrop, Items ++ Acc).

do_calc4(?DROP_RULE_FIXED, Items) ->
	Items;
do_calc4(?DROP_RULE_WEIGHT, [{Amount, Repeat, WtList}]) ->
	drop_with_weight(WtList, Amount, Repeat);
do_calc4(?DROP_RULE_RANDOM, PropList) ->
	drop_with_prob(PropList, []).

drop_with_weight(WtList, Amount, Repeat) ->
	List = ut_rand:weight(WtList, Amount, Repeat),
	lists:flatten(List).

drop_with_prob([], Acc) ->
	Acc;
drop_with_prob([{Items, Prob} | T], Acc) ->
	case ut_rand:random(1, ?PER_10000) =< Prob of
		true  -> drop_with_prob(T, lists:flatten(Items, Acc));
		false -> drop_with_prob(T, Acc)
	end.

do_drop(Atker, Defer, CfgCreep, ExpDrop, Drops, Belong, SceneSt=#scene_st{stype=SType}) ->
	Drops1 = calc_coord(Drops, Defer#actor.coord, SceneSt),
	drop_item(Atker, Defer, CfgCreep, Drops1, Belong, SceneSt),
	#actor{id=CreepID, rarity=Rarity, threat=Threat} = Defer,
	case ?is_boss(Defer) of
		true when SType =/= ?SCENE_STYPE_BOSS_NOTIRED ->
			lists:foreach(fun
				(RoleID) ->
					role:cast(RoleID, {kill_creep, CreepID, Rarity})
			end, Belong);
		_ ->
			RoleIDs = maps:keys(fight_threat:stat(role, Threat)),
			lists:foreach(fun
				(RoleID) ->
					role:cast(RoleID, {kill_creep, CreepID, Rarity})
			end, RoleIDs)
	end,

	case ?is_boss(Defer) of
		true  ->
			#actor{uid=RoleID, name=RoleName} = Atker,
			Action  = #{
				boss_id => CreepID,
				drops   => lists:map(fun
						(Drop) ->
							#{
								item_id  => Drop#drop.id,
								item_num => Drop#drop.num
							}
					end, Drops1)
			},
			role_logger:log(?ROLELOG_KILL_BOSS, Action, RoleID, RoleName);
		false ->
			ignore
	end,

	ExpAdd = maps:get(Atker#actor.uid, ExpDrop, 0),
	Drops2 = case ExpAdd > 0 of
		true  -> [#drop{id=?ITEM_EXP, num=ExpAdd} | Drops1];
		false -> Drops1
	end,
	?_if(
		Drops2 /= []
			orelse SType == ?SCENE_STYPE_BOSS_WORLD
			orelse SType == ?SCENE_STYPE_BOSS_BEAST
			orelse SType == ?SCENE_STYPE_BOSS_HOME
			orelse SType == ?SCENE_STYPE_GUILDGUARD,
		scene_hook:hook_drop(Defer#actor{belong=Belong}, Drops2, SceneSt)
	).

%% 掉落经验(直接发给玩家进程)
drop_exp(_Atker, Defer, CfgCreep, SceneSt) ->
	ThreatRole = if
		SceneSt#scene_st.stype == ?SCENE_STYPE_GUILDGUARD;
		SceneSt#scene_st.stype == ?SCENE_STYPE_DUNGE_SOUL ->
			HpMax   = ?_attr(Defer#actor.attr, ?ATTR_HPMAX),
			RoleIDs = scene_actor:get_actids(?ACTOR_TYPE_ROLE),
			maps:from_list([{RoleID,HpMax} || RoleID <- RoleIDs]);
		true ->
			fight_threat:stat(role, Defer#actor.threat)
	end,
	maps:fold(fun
		(RoleID, Damage, Acc) ->
			case scene_actor:get_actor(RoleID) of
				?nil  ->
					Acc;
				Actor ->
					{ExpAdd, Coef} = calc_exp(
						Actor, Damage, Defer, CfgCreep, SceneSt
					),
					case ExpAdd > 0 of
						true  ->
							role:cast(RoleID, {drop_exp, ExpAdd, Coef}),
							scene_hook:hook_drop_exp(Actor, ExpAdd, SceneSt),
							maps:put(RoleID, ExpAdd, Acc);
						false ->
							Acc
					end
			end
	end, #{}, ThreatRole).

% 玩家获得的经验 = 怪物经验*等级比例系数
%	* (对该怪物造成的伤害/怪物总血量)
%	* (1+世界等级加成+经验药加成+经验符加成+组队加成+其他系统加成)
calc_exp(Atker, Damage, Defer, CfgCreep, SceneSt) ->
	#actor{level=AtkLv, attr=AtkAttr, team=TeamID} = Atker,
	TeamNum = length( scene_team:get_membs(TeamID) ),
	#actor{level=DefLv, attr=DefAttr, attrid=AttrID} = Defer,
	ExpBase = CfgCreep#cfg_creep.exp + cfg_creep_attr:exp(AttrID, DefLv),
	if
		ExpBase == 0 ->
			{0, 0};
		true ->
			LvCoef  = if
				SceneSt#scene_st.stype == ?SCENE_STYPE_GUILDGUARD ->
					?PER_10000;
				true ->
					cfg_exp_coef:find(AtkLv - DefLv)
			end,
			ExtCoef = world_level:exp_coef(AtkLv)
					+ ?_attr(AtkAttr, ?ATTR_EXP_PER)
					+ team_server:get_team_exp(TeamNum)
					+ scene_hook:get_expcoef(Atker, Defer, SceneSt),
			ExpAdd = max(1, ExpBase * ?_per(LvCoef))
				* min(1, (Damage / ?_attr(DefAttr, ?ATTR_HPMAX)))
				* (1 + ?_per(ExtCoef)),

			Times = dunge_util:merge_times(Atker),
			{ut_math:ceil(ExpAdd * Times), ExtCoef}
	end.

%% 掉落道具
drop_item(_Atker, Defer, CfgCreep, Drops, Belong, _SceneSt) ->
	case CfgCreep#cfg_creep.mode of
		?DROP_MODE_SCENE ->
			Actors = drop_to_scene(Drops, []),
			?_if(
				Actors /= [],
				?bcast(
				    scene_actor:get_actids(?ACTOR_TYPE_ROLE, Defer#actor.coord),
				    #m_scene_update_toc{add=scene_util:p_actor(Actors)}
				)
			);
		?DROP_MODE_DUMMY ->
			drop_item2(Belong, Defer, Drops, true);
		?DROP_MODE_DUMMY2 ->
			drop_item2(Belong, Defer, Drops, true);
		?DROP_MODE_BAG   ->
			drop_item2(Belong, Defer, Drops, false)
	end.

drop_item2(Belong, Defer, Drops, IsDummy) ->
	lists:foreach(fun
		(RoleID) ->
			case scene_actor:get_actor(RoleID) of
				Actor when is_record(Actor, actor) andalso is_pid(Actor#actor.pid) ->
					Times  = dunge_util:merge_times(Actor),
					Drops2 = [Drop#drop{num=Drop#drop.num*Times} || Drop <- Drops],
					role:cast(Actor#actor.pid, {drop_item, Defer, Drops2, IsDummy});
				_ ->
					ignore
			end
	end, Belong).

%% 计算掉落归属
calc_belong(Atker, Defer, CfgCreep, SceneSt) ->
	#actor{uid=ActorID, team=TeamID, guild=GuildID} = Atker,
	case CfgCreep#cfg_creep.belong of
		?DROP_BELONG_EVERY ->
			[];
		?DROP_BELONG_TEAM_LEADER ->
			[team:get_leader(TeamID)];
		?DROP_BELONG_TEAM_SHARE  ->
			game_role:get_team_roles(TeamID);
		?DROP_BELONG_TEAM_RANDOM ->
			[ut_rand:choose(game_role:get_team_roles(TeamID))];
		?DROP_BELONG_GUILD  ->
			game_role:get_guild_roles(GuildID);
		?DROP_BELONG_KILLER ->
			[ActorID];
		?DROP_BELONG_BOSS when ?is_timeboss(Defer) ->
			timeboss_server:calc_belong();
		?DROP_BELONG_BOSS when ?is_siegeboss(Defer) ->
			siegewar_server:calc_belong(Defer);
		?DROP_BELONG_BOSS when ?is_throneboss(Defer) ->
			throne_server:calc_belong(Defer);
		?DROP_BELONG_BOSS ->
			BelongTeam = maps:get("belong_team", Defer#actor.exargs, 0),
			BelongRole = maps:get("belong_role", Defer#actor.exargs, 0),
			case BelongTeam > 0 of
				true  ->
					calc_boss_belong(BelongTeam, Defer, SceneSt);
				false ->
					case BelongRole > 0 of
						true  -> [BelongRole];
						false -> [Atker#actor.uid]
					end
			end;
		?DROP_BELONG_TEAM_COPY->
			dunge_team:calc_belong()
	end.

calc_boss_belong(TeamID, Defer, SceneSt) ->
	#actor{id=CreepID, born=Coord} = Defer,
	#cfg_creep{guard=Guard} = cfg_creep:find(CreepID),
	lists:foldl(fun
		(RoleID, Acc) ->
			Actor = scene_actor:get_actor(RoleID),
			case
				Actor /= ?nil andalso
				scene_util:is_nearby(Actor#actor.coord, Coord, Guard) andalso
				(not boss_server:is_tired(Actor, SceneSt))
			of
			 	true  ->
			 		[RoleID | Acc];
			 	false ->
			 		Acc
			end
	end, [], scene_team:get_membs(TeamID)).

calc_tired(_KillerID, Belong, SceneSt=#scene_st{stype=SType}) when
SType == ?SCENE_STYPE_BOSS_WORLD;
SType == ?SCENE_STYPE_BOSS_FISSURE;
SType == ?SCENE_STYPE_BOSS_BEAST ->
	lists:filtermap(fun
		(BelongID) ->
			Belonger = scene_actor:get_actor(BelongID),
			case Belonger == ?nil of
				true  ->
					false;
				false ->
					Tired = boss_server:get_tired(Belonger, SceneSt),
					{true, {BelongID, Tired}}
			end
	end, Belong);
calc_tired(_KillerID, Belong, SceneSt=#scene_st{stype=SType}) when
SType == ?SCENE_STYPE_SIEGEWAR ->
	lists:filtermap(fun
		(BelongID) ->
			Belonger = scene_actor:get_actor(BelongID),
			case Belonger == ?nil of
				true  ->
					false;
				false ->
					Tired = siegewar_server:get_tired(Belonger, SceneSt),
					{true, {BelongID, Tired}}
			end
	end, Belong);
calc_tired(_KillerID, _Belong, _SceneSt) ->
	[].

calc_coord(Drops, Center, SceneSt) ->
	Drops2 = lists:sort(fun
		(#drop{id=ItemID1}, #drop{id=ItemID2}) ->
			#cfg_item{type=Type1} = cfg_item:find(ItemID1),
			#cfg_item{type=Type2} = cfg_item:find(ItemID2),
			if
				Type1 == ?ITEM_TYPE_MONEY ->
					false;
				Type2 == ?ITEM_TYPE_MONEY ->
					true;
				true ->
					ut_rand:choose([true, false])
			end
	end, Drops),
	calc_coord2(Drops2, Center, ?AROUND, SceneSt, []).

%% 铺满，直接放中心点
calc_coord2(T, Center, [], _SceneSt, Drops) ->
	[Drop#drop{coord=Center} || Drop <- T] ++ Drops;
calc_coord2([Drop | T], Center, Around, SceneSt, Drops) ->
	{Drop2, Around2} = calc_coord3(Around, Drop, Center, SceneSt),
	calc_coord2(T, Center, Around2, SceneSt, [Drop2 | Drops]);
calc_coord2([], _Center, _Around, _SceneSt, Drops) ->
	Drops.

calc_coord3([{MaxNum, CurNum, Coords} | T], Drop, Center, SceneSt) ->
	case Coords == [] orelse CurNum >= MaxNum of
		true  ->
			calc_coord3(T, Drop, Center, SceneSt);
		false ->
			Elem  = {OX,OY} = ut_rand:choose(Coords),
			Gap   = cfg_game:drop_gap(),
			Coord = #p_coord{
				x = Center#p_coord.x + OX * Gap,
				y = Center#p_coord.y + OY * Gap
			},
			Coords2 = lists:delete(Elem, Coords),
			case scene_util:walkable(SceneSt#scene_st.scene, Coord) of
				true  ->
					Around2 = [{MaxNum, CurNum+1, Coords2} | T],
					{Drop#drop{coord=Coord}, Around2};
				false ->
					Around2 = [{MaxNum, CurNum, Coords2} | T],
					calc_coord3(Around2, Drop, Center, SceneSt)
			end
	end;
%% 铺满，直接放中心点
calc_coord3([], Drop, Center, _SceneSt) ->
	{Drop#drop{coord=Center}, []}.

drop_to_scene([], Actors) ->
	Actors;
drop_to_scene([Drop | T], Actors) ->
	UnlockTime = case Drop#drop.belong == [] of
		true  -> 0;
		false -> cfg_game:drop_unlock()
	end,
	Actor = #actor{uid=ActorID} = init_actor(Drop, UnlockTime),
	scene_grid:enter(Actor),
	scene_actor:set_actor(Actor),
	RemoveTime = cfg_game:drop_remove(),
	fight_timer:add_task(
		{ActorID, ?MODULE, remove}, RemoveTime, ?MODULE, drop_remove
	),
	drop_to_scene(T, [Actor | Actors]).

init_actor(Drop, Unlock) ->
	Unlock2 = case Unlock == 0 of
		true  -> 0;
		false -> ut_time:seconds() + Unlock
	end,
	#actor{
		uid    = scene_actor:get_autoid(),
		id     = Drop#drop.id,
		name   = "",
		type   = ?ACTOR_TYPE_DROP,
		state  = ?ACTOR_STATE_NORMAL,
		bctype = ?BCTYPE_GRID,
		num    = Drop#drop.num,
		owner  = Drop#drop.owner,
		coord  = Drop#drop.coord,
		belong = Drop#drop.belong,
		killer = Drop#drop.killer,
		exargs = #{drop=>Drop, unlock=>Unlock2}
	}.

filter_drops(Drops, Atker, Defer, Belong, SceneSt) ->
	Opendays = game_env:get_opened_days(),
	DropRare = game_misc:read(drop_rare, #{}),
	{Drops2, DropRare2} = lists:foldl(fun
		(DropInfo, Acc={AccDrops, AccRare}) ->
			Drop = case DropInfo of
				{ItemID, Num} when is_integer(ItemID) ->
					#drop{id=ItemID, num=Num, opts=#{bind=>true}};
				{ItemIDs, Num} when is_list(ItemIDs) ->
					ItemID = lists:nth(Atker#actor.gender, ItemIDs),
					#drop{id=ItemID, num=Num, opts=#{bind=>true}};
				{ItemID, Num, Bind0} when is_integer(ItemID) ->
					Bind = item_util:calc_bind(Bind0),
					#drop{id=ItemID, num=Num, opts=#{bind=>Bind}};
				{ItemIDs, Num, Bind0} when is_list(ItemIDs) ->
					ItemID = lists:nth(Atker#actor.gender, ItemIDs),
					Bind   = item_util:calc_bind(Bind0),
					#drop{id=ItemID, num=Num, opts=#{bind=>Bind}}
			end,
			LimNum = cfg_drop_rare:find(ItemID, Opendays),
			CurNum = maps:get(ItemID, AccRare, 0),
			case LimNum == ?nil orelse CurNum < LimNum of
				true  ->
					DropNum = case LimNum == ?nil of
						true  -> Drop#drop.num;
						false -> min(Drop#drop.num, LimNum-CurNum)
					end,
					Drop2 = Drop#drop{
						num    = DropNum,
						owner  = Defer#actor.uid,
						creep  = Defer#actor.id,
						belong = Belong,
						killer = Atker#actor.uid,
						tired  = calc_tired(Atker#actor.uid, Belong, SceneSt)
					},
					AccDrops2 = [Drop2 | AccDrops],
					AccRare2  = case LimNum == ?nil of
						true  -> AccRare;
						false -> ut_misc:maps_increase(ItemID, DropNum, AccRare)
					end,
					{AccDrops2, AccRare2};
				false ->
					Acc
			end
	end, {[], DropRare}, Drops),
	game_misc:write(drop_rare, DropRare2),
	Drops2.

calc_exp_in_role(CreepID, AttrID, CreepLv, Actor) ->
	#actor{level=RoleLv, attr=Attr} = Actor,
	#cfg_creep{exp=CreepExp} = cfg_creep:find(CreepID),
	ExpBase = CreepExp + cfg_creep_attr:exp(AttrID, CreepLv),
	if
		ExpBase == 0 ->
			{0, 0};
		true ->
			LvCoef  = cfg_exp_coef:find(RoleLv - CreepLv),
			ExtCoef = world_level:exp_coef(RoleLv)
					+ ?_attr(Attr, ?ATTR_EXP_PER),
			ExpAdd = max(1, ExpBase * ?_per(LvCoef))
				* (1 + ?_per(ExtCoef)),
			{ut_math:ceil(ExpAdd), ExtCoef}
	end.
