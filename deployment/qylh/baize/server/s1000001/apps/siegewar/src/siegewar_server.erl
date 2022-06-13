%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(siegewar_server).

-behaviour(gen_server).

-include("activity.hrl").
-include("attr.hrl").
-include("btree.hrl").
-include("creep.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("item.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("siegewar.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").
-include("table.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([get_worldlv/0]).
-export([post_divide/0]).
-export([hook_start/1, hook_start/2]).
-export([pre_enter/2]).
-export([get_entry/3]).
-export([hook_init/1]).
-export([hook_loopsec/2]).
-export([hook_born/2]).
-export([anger/2]).
-export([hook_creep_dead/3]).
-export([get_drops/2]).
-export([hook_drop/3]).
-export([calc_belong/1]).
-export([is_tired/2]).
-export([pre_pickup/3]).
-export([hook_pickup/3]).
-export([reset_score/1]).

-export([get_city_info/1]).
-export([get_boss_info/1]).
-export([send_damage_ranking/2]).
-export([send_boxinfo/2]).
-export([open_box/2]).

-export([belong_reward/3, belong_reward/2]).
-export([occupy_reward/3]).

-export([hook_chime/1]).
-export([set_creep_group/2]).
-export([get_divide_rule/0]).
-export([set_divide_rule/1]).
-export([reborn_notify/1]).
-export([get_tired/2]).

-define(SERVER, ?MODULE).

-define(ACT_REBORN, 11123).
-define(ACT_DIVIDE, 11122).

-record(state, {init, worldlv}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

get_worldlv() ->
	ServName = case cluster:is_local() of
		true  -> {?SERVER, cluster:get_cross(?CROSS_RULE_24_8)};
		false -> ?SERVER
	end,
	gen_server:call(ServName, get_worldlv).

post_divide() ->
	?debug("post_divide-----------"),
	gen_server:cast(?SERVER, divide).

hook_start(ActID) ->
	?debug("hook_start---------------------:~w", [ActID]),
	#cfg_activity{reqs=Reqs} = cfg_activity:find(ActID),
	Period = proplists:get_value(period, Reqs),
	case Period of
		reborn -> gen_server:cast(?SERVER, reborn);
		divide -> gen_server:cast(?SERVER, divide);
		_ -> ignore
	end,
	Nodes  = cluster:get_locals(?CROSS_RULE_24_8),
	Cities = ets:tab2list(?ETS_SIEGEWAR_CITY),
	lists:foreach(fun
		(Node) ->
			SceneIDs = [City#siegecity.scene ||
				City <- Cities,
				City#siegecity.owner == Node#cls_node.suid orelse
				lists:member(Node#cls_node.suid, City#siegecity.enter)
			],
			cluster:rpc_cast_node(
				Node#cls_node.name, ?MODULE, reborn_notify, [SceneIDs]
			)
	end, Nodes).

reborn_notify(SceneIDs) ->
	lists:foreach(fun
		(SceneID) ->
			#cfg_scene{name=SceneName} = cfg_scene:find(SceneID),
			?notify(?MSG_SIEGEWAR_REBORN, [SceneName])
	end, SceneIDs).

hook_start(?SERVER_TYPE_LOCAL, ActID) ->
	?debug("hook_start---------------------:~w", [ActID]),
	case get_divide_rule() == 0 of
		true  ->
			#cfg_activity{reqs=Reqs} = cfg_activity:find(ActID),
			case proplists:get_value(period, Reqs) == reborn of
				true  ->
					gen_server:cast(?SERVER, reborn),
					SceneIDs = cfg_siegewar_boss:scenes(0),
					reborn_notify(SceneIDs);
				false ->
					ignore
			end;
		false ->
			ignore
	end;
hook_start(_ServType, _ActID) ->
	ignore.

pre_enter(Actor, _SceneSt=#scene_st{scene=SceneID}) ->
	CityLv = cfg_siegewar_boss:level(SceneID),
	case CityLv of
		3 ->
			SceneIDs = cfg_siegewar_boss:scenes(2),
			CanEnter = lists:any(fun
				(SceneID2) ->
					case ets:lookup(?ETS_SIEGEWAR_CITY, SceneID2) of
						[City] ->
							City#siegecity.owner == Actor#actor.suid;
						[] ->
							false
					end
			end, SceneIDs),
			?_check(CanEnter, ?ERR_SIEGEWAR_NOT_OWNER);
		0 ->
			CanEnter = get_divide_rule() == 0,
			?_check(CanEnter, ?ERR_SIEGEWAR_NOT_OWNER);
		_ ->
			case ets:lookup(?ETS_SIEGEWAR_CITY, SceneID) of
				[#siegecity{enter=SUIDs}] ->
					CanEnter = lists:member(Actor#actor.suid, SUIDs),
					?_check(CanEnter, ?ERR_SIEGEWAR_NOT_OWNER);
				[] ->
					throw(?err(?ERR_SIEGEWAR_NO_CITY))
			end
	end.

get_entry(_ActID, SceneID, RoleSt) ->
	?debug("get_entry:~w", [RoleSt#role_st.guild]),
	case scene_util:is_local(SceneID) of
		true  ->
			GroupID = game_uid:guid2ssid(RoleSt#role_st.guild),
			#{opts => #{group=>GroupID}};
		false ->
			#{}
	end.

hook_init(_SceneSt) ->
	set_score_info(#{}),
	set_score_ranking([]).

hook_loopsec(Secs, _SceneSt) when Secs rem 3 == 0 ->
	ActorIDs = scene_actor:get_actids(?ACTOR_TYPE_CREEP),
	lists:foreach(fun
		(ActorID) ->
			Actor = scene_actor:get_actor(ActorID),
			?_if(
				is_record(Actor, actor) andalso ?is_siegeboss(Actor),
				update_damage_ranking(Actor)
			)
	end, ActorIDs);
hook_loopsec(_Secs, _SceneSt) ->
	ignore.


hook_born(Actor, _SceneSt) when ?is_siegeboss(Actor) ->
	set_damage_ranking(Actor#actor.id, []);
hook_born(_Actor, _SceneSt) ->
	ok.

% hook_fight(Atker, Defer, DmgVal, _SceneSt) when ?is_siegeboss(Defer), DmgVal > 0 ->
% 	#actor{uid=AtkUID, suid=AtkSUID} = Atker,
% 	#actor{id=BossID, attr=DefAttr} = Defer,
% 	HpMax  = ?_attr(DefAttr, ?ATTR_HPMAX),
% 	DmgPer = round((DmgVal / HpMax) * ?PER_10000),
% 	case cluster:is_local() of
% 		true  -> update_damage_info(BossID, AtkUID, DmgPer);
% 		false -> update_damage_info(BossID, AtkSUID, DmgPer)
% 	end;
% hook_fight(_Atker, _Defer, _DmgVal, _SceneSt) ->
% 	ok.

anger(Actor, SceneSt=#scene_st{scene=SceneID}) ->
	Result = creep_ai:anger(Actor, SceneSt),
	case Result == ?SUCCESS of
		true  ->
			#actor{id=BossID, name=BossName, attr=Attr} = Actor,
			HpPer = ?_attr(Attr,?ATTR_HP) / ?_attr(Attr,?ATTR_HPMAX),
			LowHp = case HpPer =< 0.3 of
				true  -> 30;
				false -> 70
			end,
			#cfg_scene{name=SceneName} = cfg_scene:find(SceneID),
			Args = [SceneName, BossName, LowHp, BossID],
			case cluster:is_local() of
				true  ->
					?notify(?MSG_SIEGEWAR_LOWHP, Args);
				false ->
					[City] = ets:lookup(?ETS_SIEGEWAR_CITY, SceneID),
					cluster:notify(City#siegecity.enter, ?MSG_SIEGEWAR_LOWHP, Args)
			end;
		false ->
			ignore
	end,
	Result.

%% 击杀boss
hook_creep_dead(Atker, Defer, SceneSt) when ?is_siegeboss(Defer) ->
	#actor{id=BossID, level=BossLv, name=BossName, born=Coord} = Defer,
	#scene_st{scene=SceneID} = SceneSt,
	#cfg_siegewar_boss{type=Type, score=Score} = cfg_siegewar_boss:find(BossID),

	[{FirstID, _DmgVal} | _] = fight_threat:sort(role, Defer#actor.threat),
	FirstAtker = case scene_actor:get_actor(FirstID) of
		?nil  -> Atker;
		First -> First
	end,
	#actor{uid=AtkUID, guild=AtkGuild, suid=AtkSUID} = FirstAtker,

	update_damage_ranking(Defer),
	{OwnerType, OwnerID} = case cluster:is_local() of
		true when AtkGuild == 0 ->
			{?OWNER_TYPE_ROLE, AtkUID};
		true  ->
			{?OWNER_TYPE_GUILD, AtkGuild};
		false ->
			{?OWNER_TYPE_SERVER, AtkSUID}
	end,

	?_if(Type == 3, set_bigboss_killer(OwnerType, OwnerID)),

	NewScore = update_score_info(OwnerType, OwnerID, Score, SceneSt),
	WinScore = cfg_game:siegewar_win_score(),
	update_score_ranking(),

	[#p_siegewar_damage{id=SUID} | _] = get_damage_ranking(Defer#actor.id),
	Owners = case cluster:is_local() of
		true  -> [];
		false -> [{SUID, FirstAtker#actor.uid, FirstAtker#actor.name}]
	end,

	CityLv = cfg_siegewar_boss:level(SceneID),
	Reborn = next_reborn(),
	case CityLv > 1 andalso Type == 3 of
		true  ->
			{X, Y} = cfg_siegewar_boss:box_coord(BossID),
			Creeps = [
				% 墓碑
				{1099999, Coord, #{
					name   => io_lib:format("~w~ts ~ts", [BossLv, cfg_lang:find(level), BossName]),
					exargs => #{"boss_reborn"=>Reborn, "killer"=>Atker#actor.suid}
				}},
				% 宝箱
				{1099998, #p_coord{x=X,y=Y}, #{
					owners => Owners,
					exargs => #{"boss_reborn"=>Reborn, "boss_id"=>Defer#actor.id}
				}}
			],
			[TombID, BoxID] = creep_agent:add(Creeps, SceneSt);
		false ->
			Creeps = [
				% 墓碑
				{1099999, Coord, #{
					name   => io_lib:format("~w~ts ~ts", [BossLv, cfg_lang:find(level), BossName]),
					exargs => #{"boss_reborn"=>Reborn, "killer"=>Atker#actor.suid}
				}}
			],
			[TombID] = creep_agent:add(Creeps, SceneSt),
			BoxID = 0
	end,

	Msg = {dead,SceneID,BossID,TombID,BoxID,Reborn,OwnerType,OwnerID,Score,Owners},
	gen_server:cast(?SERVER, Msg),

	?_if(NewScore >= WinScore, decide_owner(SceneSt#scene_st.scene, false)),

	scene_util:bc_to_scene(#m_siegewar_boss_update_toc{
		id   = BossID,
		born = Reborn,
		num  = 1
	}),

	?debug("score ranking: ~w", [get_score_ranking()]),

	ActorIDs = scene_actor:get_actids(?ACTOR_TYPE_CREEP),
	AnyBoss  = lists:any(fun
		(ActorID) ->
			case scene_actor:get_actor(ActorID) of
				?nil  -> false;
				Actor -> ?is_siegeboss(Actor)
			end
	end, ActorIDs),
	?_if(not AnyBoss, decide_owner(SceneID, false)),

	if
		CityLv == 0, FirstAtker#actor.guild > 0 ->
			#cfg_scene{name=SceneName} = cfg_scene:find(SceneID),
			?notify(
				?MSG_SIEGEWAR_KILL,
				[
					SceneName,
					BossName,
					FirstAtker#actor.gname,
					{role,FirstAtker#actor.uid,FirstAtker#actor.name},
					SceneName
				]
			);
		CityLv == 0 ->
			#cfg_scene{name=SceneName} = cfg_scene:find(SceneID),
			?notify(
				?MSG_SIEGEWAR_KILL2,
				[
					SceneName,
					BossName,
					{role,FirstAtker#actor.uid,FirstAtker#actor.name},
					SceneName
				]
			);
		CityLv == 2 ->
			[City] = ets:lookup(?ETS_SIEGEWAR_CITY, SceneID),
			#cfg_scene{name=SceneName} = cfg_scene:find(SceneID),
			cluster:notify(
				City#siegecity.enter,
				?MSG_SIEGEWAR_KILL,
				[
					SceneName,
					BossName,
					io_lib:format("~w", [game_uid:suid2ssid(FirstAtker#actor.suid)]),
					{role,FirstAtker#actor.uid,FirstAtker#actor.name},
					SceneName
				]
			);
		true ->
			ignore
	end;
hook_creep_dead(_Atker, _Defer, _SceneSt) ->
	ignore.

get_drops(Defer, SceneSt) ->
	#actor{id=BossID, level=CreepLv} = Defer,
	WorldLv = world_level:get_level(),
	Opdays  = case cluster:is_local() of
		true  ->
			game_env:get_opened_days();
		false ->
			[City]  = ets:lookup(?ETS_SIEGEWAR_CITY, SceneSt#scene_st.scene),
			get_min_opdays(City#siegecity.rule)
	end,
	{Drops, Rare1, Rare2} = cfg_siegewar_belong_reward:drop(BossID, Opdays),
	case CreepLv > WorldLv of
		true  -> Drops ++ Rare1;
		false -> Drops ++ Rare2
	end.

get_min_opdays(RuleID) ->
	SUIDs = [SUID || {SUID, RuleID2, _} <- ets:tab2list(?ETS_SIEGEWAR_RULE), RuleID == RuleID2],
	Nodes = cluster:get_locals(?CROSS_RULE_24_8),
	NodeList   = [Node || Node <- Nodes, lists:member(Node#cls_node.suid, SUIDs)],
	[Node | _] = lists:reverse(lists:keysort(#cls_node.otime, NodeList)),
	OpDate = ut_time:seconds_to_date(Node#cls_node.otime),
	abs(ut_time:diff_days(ut_time:today(), OpDate)) + 1.

hook_drop(Defer, _Drops, _SceneSt) ->
	[#p_siegewar_damage{id=SUID} | _] = get_damage_ranking(Defer#actor.id),
	?debug("-----------------hook_drop: ~w", [SUID]),
	#actor{id=BossID, belong=Belong} = Defer,
	lists:foreach(fun
		(RoleID) ->
			case scene_actor:get_actor(RoleID) of
			 	?nil  -> ignore;
			 	Actor -> do_add_tired(Actor, 1)
			end
	end, Belong),
	give_belong_reward(BossID, Belong, SUID).

calc_belong(Defer) ->
	[#p_siegewar_damage{id=ID, type=Type} | _] = get_damage_ranking(Defer#actor.id),
	RoleIDs = case Type of
		?OWNER_TYPE_ROLE   ->
			[ID];
		?OWNER_TYPE_GUILD  ->
			guild:get_membids(ID);
		?OWNER_TYPE_SERVER ->
			scene_actor:get_actids(?ACTOR_TYPE_ROLE)
	end,
	#cfg_creep{guard=Guard} = cfg_creep:find(Defer#actor.id),
	calc_belong2(RoleIDs, Type, ID, Defer, Guard, []).

is_tired(Actor, _SceneSt) ->
	Tired = buff_util:get_value(Actor, ?BUFF_ID_SIEGEBOSS_KILL_TIRED, 0),
	Tired >= cfg_game:siegeboss_tired().

pre_pickup(Actor, Drop, _SceneSt) ->
    #drop{tired=TiredInfo} = maps:get(drop, Drop#actor.exargs),
    BuffID = ?BUFF_ID_SIEGEBOSS_KILL_TIRED,
	MaxTired = cfg_game:siegeboss_tired(),
	TheTired = case TiredInfo == ?nil of
	    true  ->
	    	buff_util:get_value(Actor, BuffID);
	    false ->
	        case proplists:get_value(Actor#actor.uid, TiredInfo, ?nil) of
	            ?nil  -> buff_util:get_value(Actor, BuffID);
	            Tired -> Tired
	        end
	end,
	?_check(TheTired < MaxTired, ?ERR_DROP_MAX_TIRED).

hook_pickup(Drop, Item, RoleSt) ->
	#cfg_item{notify=IsNotify} = cfg_item:find(Drop#drop.id),
	?debug("hook_pickup-----------:~w", [{Item#p_item.id, IsNotify}]),
	case IsNotify of
		true  ->
			#role_st{role=RoleID, scene=SceneID} = RoleSt,
			RoleInfo = role_data:get(?DB_ROLE_INFO),
			#role_info{id=RoleID, name=RoleName0} = RoleInfo,
			IsLocal  = scene_util:is_local(SceneID),
			CacheID  = case IsLocal of
				true  -> item_cache:add_cache(Item);
				false -> cluster:rpc_call_center(item_cache, add_cache, [Item])
			end,
			ServerID = game_uid:suid2ssid(),
			RoleName = lists:concat(["s", ServerID, ".", RoleName0]),
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
			#cfg_scene{name=SceneName} = cfg_scene:find(SceneID),
			case IsLocal of
				true  ->
					game_logger:add_log(siegewar_drop_log, Dropped);
				false ->
					cluster:rpc_cast_cross(
						?CROSS_RULE_24_8,
						game_logger,
						add_log,
						[siegewar_drop_log, Dropped]
					)
			end,

			?notify(
				?MSG_SIEGEWAR_DROP,
				[
					{role,RoleID,RoleName},
					SceneName,
					BossName,
					{pitem, #{CacheID=>(Drop#drop.id)}}
				]
			);
		false ->
			ignore
	end.

reset_score(SceneSt) ->
	?debug("reset_score========================"),
	#scene_st{scene=SceneID} = SceneSt,
	decide_owner(SceneID, true),
	give_occupy_reward(SceneID, clr_occupant()),
	clr_bigboss_killer(),
	set_score_info(#{}),
	set_score_ranking([]).

get_city_info(SUID) ->
	case cluster:is_local() of
		true  ->
			{ok, 0, ets:tab2list(?ETS_SIEGEWAR_CITY)};
		false ->
			case ets:lookup(?ETS_SIEGEWAR_RULE, SUID) of
				[{_, RuleID, GroupID}] ->
					Cities = [City ||
						City <- ets:tab2list(?ETS_SIEGEWAR_CITY),
						City#siegecity.group == GroupID
					],
					{ok, RuleID, Cities};
				_ ->
					{ok, 0, []}
			end
	end.

get_boss_info(SceneID) ->
	[City] = ets:lookup(?ETS_SIEGEWAR_CITY, SceneID),
	Bosses = [B ||
		B <- ets:tab2list(?ETS_SIEGEWAR_BOSS),
		element(1,B#siegeboss.key) == SceneID
	],
	{ok, City, Bosses}.

send_damage_ranking({BossID, RoleID}, _SceneSt) ->
	?ucast(RoleID, #m_siegewar_damage_toc{
		boss    = BossID,
		ranking = get_damage_ranking(BossID)
	}).

send_boxinfo({RoleID,BoxID}, _SceneSt=#scene_st{scene=SceneID}) ->
	case scene_actor:get_actor(BoxID) of
		?nil ->
			ignore;
		Box  ->
			BossID = maps:get("boss_id", Box#actor.exargs),
			case ets:lookup(?ETS_SIEGEWAR_BOSS, {SceneID,BossID}) of
				[Boss] when Boss#siegeboss.box > 0->
					#siegeboss{owners=Owners, opened=Opened} = Boss,
					MaxTimes = cfg_siegewar_box_reward:max_times(BossID),
					Actor = scene_actor:get_actor(RoleID),
					?ucast(RoleID, #m_siegewar_boxinfo_toc{
						box_uid  = BoxID,
						summoner = [Name || {_,_,Name} <- Owners],
						suids    = [SUID || {SUID,_,_} <- Owners],
						can_open = can_open(Actor#actor.suid, Owners),
						remain   = MaxTimes - maps:get(RoleID, Opened, 0),
						boss_id  = BossID
					});
				_ ->
					ignore
			end
	end.

open_box({RoleID, SUID, BossID, Times1, Type, Reward}, SceneSt) ->
	#scene_st{scene=SceneID} = SceneSt,
	case ets:lookup(?ETS_SIEGEWAR_BOSS, {SceneID,BossID}) of
		[Boss] when Boss#siegeboss.box > 0 ->
			#siegeboss{owners=Owners, opened=Opened} = Boss,
			?_check(can_open(SUID, Owners), ?ERR_TIMEBOSS_NOT_SAME),
			Times2 = maps:get(RoleID, Opened, 0),
			MaxTimes = cfg_siegewar_box_reward:max_times(BossID),
			?_check(Times2 < MaxTimes, ?ERR_SIEGEWAR_MAX_BOXTIMES),
			% ?debug("---------------:~w", [Times2]),
			?_check(Times1 == Times2+1, ?ERR_GAME_BAD_ARGS),
			gen_server:cast(?SERVER, {open, RoleID, SceneID, BossID}),
			Reward1 = game_util:normalize_gain(RoleID, Reward),
			Reward2 = [{ID,N} || {ID,N,_} <- Reward1],
			?ucast(RoleID, #m_siegewar_boxopen_toc{
				type   = Type,
				reward = maps:from_list(Reward2)
			});
		_ ->
			?err(?ERR_GAME_BAD_ARGS)
	end.


belong_reward(BossID, RoleIDs, _WorldLv) ->
	% ?debug("belong_reward: ~w", [{BossID, RoleIDs, WorldLv}]),
	Opdays = game_env:get_opened_days(),
	Drops  = cfg_siegewar_belong_reward:find(BossID, Opdays),
	lists:foreach(fun
		(RoleID) ->
			{ok, #role_cache{level=RoleLv}} = role:get_cache(RoleID),
			Reward = creep_drop:calc(RoleLv, Drops),
			role:route(RoleID, ?MODULE, belong_reward, Reward)
	end, RoleIDs).

belong_reward(Reward, RoleSt) ->
	?debug("belong_reward: ~w", [{Reward}]),
	role_bag:gain(Reward, ?LOG_SIEGEWAR_BELONG_REWARD, RoleSt).

occupy_reward(SceneID, _WorldLv, Occupant) ->
	Opdays = game_env:get_opened_days(),
	Drops  = cfg_siegewar_occupy_reward:find(Opdays),
	?debug("occupy_reward: ~w", [{SceneID, Opdays, Drops, get_occupant()}]),
	MinLv  = cfg_game:siegewar_occupy_reward(),
	MailID = ?MAIL_SIEGEWAR_OCCUPY_REWARD,
	#cfg_scene{name=SceneName} = cfg_scene:find(SceneID),
	{Title, FmtText} = cfg_mail:find(MailID),
	case Occupant of
		{?OWNER_TYPE_SERVER, _SUID} ->
			lists:foreach(fun
				(#role_info{id=RoleID, level=RoleLv}) when RoleLv >= MinLv ->
					Reward = creep_drop:calc(RoleLv, Drops),
					mail:send(
						RoleID,
						Title,
						io_lib:format(FmtText, [SceneName]),
						Reward
					);
				(_) ->
					ignore
			end, db:dirty_match_all(?DB_ROLE_INFO));
		{Type, ID} ->
			RoleIDs = case Type of
				?OWNER_TYPE_ROLE  -> [ID];
				?OWNER_TYPE_GUILD -> guild:get_membids(ID)
			end,
			lists:foreach(fun
				(RoleID) ->
					{ok, #role_cache{level=RoleLv}} = role:get_cache(RoleID),
					case RoleLv >= MinLv of
						true  ->
							Reward = creep_drop:calc(RoleLv, Drops),
							mail:send(
								RoleID,
								Title,
								io_lib:format(FmtText, [SceneName]),
								Reward
							);
						false ->
							ignore
					end
			end, RoleIDs);
		_ ->
			ignore
	end.

hook_chime(0) ->
	catch [scene:kickout(SceneID) || SceneID <- cfg_siegewar_boss:scenes(3)],
	gen_server:cast(?SERVER, midnight);
hook_chime(_) ->
	ignore.

set_creep_group(GroupID, _SceneSt) ->
	?debug("set_creep_group: ~w", [GroupID]),
	ActorIDs = scene_actor:get_actids(?ACTOR_TYPE_CREEP),
	lists:foreach(fun
		(ActorID) ->
			case scene_actor:get_actor(ActorID) of
				?nil  -> ignore;
				Actor -> scene_actor:set_actor(Actor#actor{group=GroupID})
			end
	end, ActorIDs).

get_divide_rule() ->
	game_misc:read(siegewar_divide_rule, 0).

set_divide_rule(RuleID) ->
	game_misc:write(siegewar_divide_rule, RuleID).

get_tired(Actor, _SceneSt) ->
	buff_util:get_value(Actor, ?BUFF_ID_SIEGEBOSS_KILL_TIRED).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	ets:new(?ETS_SIEGEWAR_CITY, [named_table, public, {keypos,#siegecity.scene}]),
	ets:new(?ETS_SIEGEWAR_BOSS, [named_table, public, {keypos,#siegeboss.key}]),
	ets:new(?ETS_SIEGEWAR_RULE, [named_table, public]),
	{ok, #state{init=false}}.

handle_call(get_worldlv, _From, State) ->
	{reply, State#state.worldlv, State};

handle_call(Req, From, State) ->
	?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(started, State) ->
	IsLocal  = cluster:is_local(),
	SceneIDs = case IsLocal of
		true  ->
			cfg_siegewar_boss:scenes(0);
		false ->
			cfg_siegewar_boss:scenes(1) ++
			cfg_siegewar_boss:scenes(2) ++
			cfg_siegewar_boss:scenes(3)
	end,
	lists:foreach(fun
		(SceneID) ->
			?debug("create scene: ~w", [SceneID]),
			scene:create(SceneID)
	end, SceneIDs),

	case State#state.init of
		true  -> ignore;
		false -> [do_init(BossID) || BossID <- cfg_siegewar_boss:bosses()]
	end,

	?_if(IsLocal, siegewar_divide:divide_local()),

	{noreply, State#state{init=true}};


handle_cast(Msg, State) ->
	?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
	?try_handle_cast(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.

do_handle_cast({occupy, SceneID, Type, Owner, IsTemp}, State) ->
	[City] = ets:lookup(?ETS_SIEGEWAR_CITY, SceneID),
	CityLv = cfg_siegewar_boss:level(SceneID),
	case CityLv == 0 orelse City#siegecity.owner == 0 orelse City#siegecity.temp of
		true  ->
			case cluster:is_local() of
				true  ->
					ignore;
				false ->
					ets:insert(?ETS_SIEGEWAR_CITY, City#siegecity{
						owner = Owner,
						temp  = IsTemp
					})
			end,
			#cfg_scene{name=SceneName} = cfg_scene:find(SceneID),
			case Type of
				?OWNER_TYPE_ROLE   ->
					{ok, Cache} = role:get_cache(Owner),
					GuildName = guild:get_name(City#siegecity.owner),
					?notify(
						?MSG_SIEGEWAR_OCCUPY2,
						[
							Cache#role_cache.name,
							maps:get({Type,Owner}, City#siegecity.score, 0),
							?_if(GuildName == "", SceneName, GuildName)
						]
					);
				?OWNER_TYPE_GUILD  ->
					GuildName = guild:get_name(City#siegecity.owner),
					?notify(
						?MSG_SIEGEWAR_OCCUPY,
						[
							guild:get_name(Owner),
							maps:get({Type,Owner}, City#siegecity.score, 0),
							?_if(GuildName == "", SceneName, GuildName)
						]
					);
				?OWNER_TYPE_SERVER ->
					cluster:notify(
						City#siegecity.enter,
						?MSG_SIEGEWAR_OCCUPY,
						[
							Owner,
							maps:get({Type,Owner}, City#siegecity.score, 0),
							SceneName
						]
					)
			end;
		false ->
			ignore
	end,
	{noreply, State};

do_handle_cast({dead,SceneID,BossID,TombID,BoxID,Reborn,OwnerType,OwnerID,ScoreAdd,Owners}, State) ->
	ets:update_element(?ETS_SIEGEWAR_BOSS, {SceneID,BossID}, [
		{#siegeboss.born, Reborn},
		{#siegeboss.tomb, TombID},
		{#siegeboss.box, BoxID},
		{#siegeboss.owners, Owners}
	]),
	[City] = ets:lookup(?ETS_SIEGEWAR_CITY, SceneID),
	ets:insert(?ETS_SIEGEWAR_CITY, City#siegecity{
		boss  = City#siegecity.boss - 1,
		score = ut_misc:maps_increase({OwnerType,OwnerID}, ScoreAdd, City#siegecity.score)
	}),
	{noreply, State};

do_handle_cast(reborn, State) ->
	Bosses = ets:tab2list(?ETS_SIEGEWAR_BOSS),
	lists:foreach(fun
		(Boss) ->
			?_if(Boss#siegeboss.tomb > 0, do_reborn(Boss))
	end, Bosses),

	Cities = ets:tab2list(?ETS_SIEGEWAR_CITY),
	lists:foreach(fun
		(City) ->
			#siegecity{owner=Owner, scene=SceneID, score=ScoreInfo} = City,
			Score  = maps:get({?OWNER_TYPE_SERVER,Owner}, ScoreInfo, 0),
			Temp   = cluster:is_cross() andalso Score > 0,
			Owner2 = ?_if(Temp orelse Owner > 0, Owner, 0),
			?debug("1111111111111111111: ~w", [{SceneID, Owner, Score}]),
			ets:insert(?ETS_SIEGEWAR_CITY, City#siegecity{
				owner = Owner2,
				temp  = Temp,
				boss  = length(cfg_siegewar_boss:bosses(SceneID)),
				score = #{}
			}),
			ScenePid = scene:get_pid(SceneID, 0),
			scene:route(ScenePid, ?MODULE, reset_score)
	end, Cities),
	{noreply, State};

do_handle_cast({open, RoleID, SceneID, BossID}, State) ->
	case ets:lookup(?ETS_SIEGEWAR_BOSS, {SceneID,BossID}) of
		[Boss=#siegeboss{opened=Opened}] ->
			ets:insert(?ETS_SIEGEWAR_BOSS, Boss#siegeboss{
				opened = ut_misc:maps_increase(RoleID, 1, Opened)
			});
		[] ->
			ignore
	end,
	{noreply, State};

do_handle_cast(divide, State) ->
	WorldLv = world_level:get_level(),
	siegewar_divide:divide_cross(),
	{noreply, State#state{worldlv=WorldLv}};

do_handle_cast(midnight, State) ->
	case cluster:is_local() of
		true  ->
			siegewar_divide:divide_local();
		false ->
			case siegewar_divide:is_8group() of
				true  -> ignore;
				false -> siegewar_divide:divide_cross()
			end
	end,
	{noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.


do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.


do_init(BossID) ->
	CfgBoss = #cfg_siegewar_boss{level=CityLv} = cfg_siegewar_boss:find(BossID),
	case cluster:is_local() of
		true when CityLv == 0 ->
			do_summon(CfgBoss, true);
		false when CityLv > 0 ->
			do_summon(CfgBoss, true);
		_ ->
			ignore
	end.

do_reborn(Boss) ->
	#siegeboss{key={SceneID,_}, boss=BossID, tomb=TombID} = Boss,
	?debug("do_reborn---------------------:~w", [BossID]),
	% 删除墓碑
	creep:del(SceneID, 0, ?MAIN_LINE, [TombID]),
	% 召唤boss
	CfgBoss = cfg_siegewar_boss:find(BossID),
	do_summon(CfgBoss, false).

do_summon(CfgBoss, IsInit) ->
	#cfg_siegewar_boss{id=BossID, scene=SceneID, coord={X,Y}, attr=Attr} = CfgBoss,
	{AttrID, AttCoef, DefCoef} = Attr,
	Opts = case (not IsInit) andalso cluster:is_local() of
		true  ->
			[City] = ets:lookup(?ETS_SIEGEWAR_CITY, SceneID),
			#{group=>City#siegecity.group};
		false ->
			#{}
	end,
	creep:add(SceneID, 0, ?MAIN_LINE, [{BossID,X,Y,AttrID,worldlv,AttCoef,DefCoef,Opts}]),
	ets:insert(?ETS_SIEGEWAR_BOSS, #siegeboss{key={SceneID,BossID}, boss=BossID}),
	?_if(
		not IsInit andalso ets:member(?ETS_SIEGEWAR_CITY, SceneID),
		ets:update_counter(?ETS_SIEGEWAR_CITY, SceneID, {#siegecity.boss,1})
	).

next_reborn() ->
	activity:stime(?ACT_REBORN).

% -define(k_damage_info, {damage_info, BossID}).
% get_damage_info(BossID) ->
% 	get(?k_damage_info).

% set_damage_info(BossID, DmgInfo) ->
% 	put(?k_damage_info, DmgInfo).

% update_damage_info(BossID, ID, PerAdd) ->
% 	DmgInfo  = get_damage_info(BossID),
% 	OldPer   = maps:get(ID, DmgInfo, 0),
% 	NewPer   = OldPer + PerAdd,
% 	DmgInfo2 = maps:put(ID, NewPer, DmgInfo),
% 	% ?debug("update_damage_info: ~w", [DmgInfo2]),
% 	set_damage_info(BossID, DmgInfo2).

-define(k_damage_ranking, {damage_ranking, BossID}).
get_damage_ranking(BossID) ->
	get(?k_damage_ranking).

set_damage_ranking(BossID, Ranking) ->
	put(?k_damage_ranking, Ranking).

update_damage_ranking(Boss) ->
	#cfg_creep{guard=Guard} = cfg_creep:find(Boss#actor.id),
	HpMax   = ?_attr(Boss#actor.attr, ?ATTR_HPMAX),
	DmgInfo = case cluster:is_local() of
		true  ->
			maps:fold(fun
				(RoleID, DmgVal, Acc) ->
					case scene_actor:get_actor(RoleID) of
						?nil  ->
							Acc;
						Actor ->
							case scene_util:is_nearby(Actor, Boss, Guard) of
								true  ->
									#actor{name=RoleName, guild=GuildID, gname=GuildName} = Actor,
									Key = case GuildID == 0 of
										true  -> {?OWNER_TYPE_ROLE,RoleID,RoleName};
										false -> {?OWNER_TYPE_GUILD,GuildID,GuildName}
									end,
									Per = round((DmgVal/HpMax)*?PER_10000),
									ut_misc:maps_increase(Key, Per, Acc);
								false ->
									Acc
							end

					end
			end, #{}, Boss#actor.threat);
		false ->
			maps:fold(fun
				(RoleID, DmgVal, Acc) ->
					case scene_actor:get_actor(RoleID) of
						?nil  ->
							Acc;
						Actor ->
							case scene_util:is_nearby(Actor, Boss, Guard) of
								true  ->
									Per = round((DmgVal/HpMax)*?PER_10000),
									ut_misc:maps_increase(Actor#actor.suid, Per, Acc);
								false ->
									Acc
							end
					end
			end, #{}, Boss#actor.threat)
	end,
	DmgList = lists:keysort(2, maps:to_list(DmgInfo)),
	{_, Ranking} = lists:foldl(fun
		({{Type,ID,Name}, Dmg}, {AccRank, AccRanking}) ->
			RankItem = #p_siegewar_damage{
				id     = ID,
				damage = Dmg,
				rank   = AccRank,
				type   = Type,
				name   = Name
			},
			{AccRank-1, [RankItem | AccRanking]};
		({ID, Dmg}, {AccRank, AccRanking}) ->
			RankItem = #p_siegewar_damage{
				id     = ID,
				damage = Dmg,
				rank   = AccRank,
				type   = ?OWNER_TYPE_SERVER,
				name   = ""
			},
			{AccRank-1, [RankItem | AccRanking]}
	end, {length(DmgList), []}, DmgList),
	% ?debug("update_damage_ranking: ~w", [{Actor#actor.id, Ranking}]),
	set_damage_ranking(Boss#actor.id, Ranking).

-define(k_score_info, score_info).
get_score_info() ->
	get(?k_score_info).

set_score_info(ScoreInfo) ->
	put(?k_score_info, ScoreInfo).

update_score_info(Type, ID, ScoreAdd, _SceneSt) ->
	ScoreInfo  = get_score_info(),
	OldScore   = maps:get({Type,ID}, ScoreInfo, 0),
	NewScore   = OldScore + ScoreAdd,
	ScoreInfo2 = maps:put({Type,ID}, NewScore, ScoreInfo),
	% ?debug("update_score_info: ~w", [ScoreInfo2]),
	set_score_info(ScoreInfo2),
	NewScore.


-define(k_score_ranking, score_ranking).
get_score_ranking() ->
	get(?k_score_ranking).

set_score_ranking(Ranking) ->
	put(?k_score_ranking, Ranking).

update_score_ranking() ->
	ScoreInfo = get_score_info(),
	Ranking   = lists:sort(fun
		({{Type1,ID1}, Score1}, {{Type2,ID2}, Score2}) ->
			case Score1 == Score2 of
				true  ->
					case get_bigboss_killer() of
						{Type3, ID3} ->
							if
								Type1 == Type3, ID1 == ID3 ->
									true;
								Type2 == Type3, ID2 == ID3 ->
									true;
								true ->
									false
							end;
						_ ->
							ID1 > ID2
					end;
				false ->
					Score1 > Score2
			end
	end, maps:to_list(ScoreInfo)),
	set_score_ranking(Ranking).

decide_owner(SceneID, IsTemp) ->
	case decide_owner2(SceneID) of
		{Type, ID} ->
			set_occupant(Type, ID),
			gen_server:cast(?SERVER, {occupy,SceneID,Type,ID,IsTemp});
		_ ->
			ignore
	end.

decide_owner2(SceneID) ->
	case get_occupant() == ?nil of
		true  ->
			CityLv = cfg_siegewar_boss:level(SceneID),
			case CityLv < 3 andalso get_score_ranking() of
				[{{Type, ID}, _} | _] ->
					{Type, ID};
				_ ->
					?nil
			end;
		false ->
			?nil
	end.

calc_belong2([RoleID | T], Type, Owner, Defer, Guard, Belong) ->
	case scene_actor:get_actor(RoleID) of
		?nil  ->
			calc_belong2(T, Type, Owner, Defer, Guard, Belong);
		Actor ->
			IsOwner  = case Type == ?OWNER_TYPE_SERVER of
				true  -> Actor#actor.suid == Owner;
				false -> true
			end,
			IsBelong = IsOwner andalso scene_util:is_nearby(Defer, Actor, Guard),
			case IsBelong of
				true  ->
					calc_belong2(T, Type, Owner, Defer, Guard, [RoleID | Belong]);
				false ->
					calc_belong2(T, Type, Owner, Defer, Guard, Belong)
			end
	end;
calc_belong2([], _Type, _Owner, _Defer, _Guard, Belong) ->
	Belong.

%% 增加疲劳值
do_add_tired(Actor, TiredAdd) ->
	BuffID = ?BUFF_ID_SIEGEBOSS_KILL_TIRED,
	case buff_util:get_buff(Actor, BuffID) of
		?nil ->
			do_add_tired1(Actor, BuffID, TiredAdd);
		Buff ->
			#p_buff{value=Tired, etime=ETime1} = Buff,
			ETime2 = ut_time:midnight(),
			case ETime1 == ETime2 of
				true  ->
					case Tired >= cfg_game:siegeboss_tired() of
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
	?debug("do_add_tired2--------------:~w", [{BuffID, Tired, ut_time:seconds_to_datetime(ETime)}]),
	Opts = #{value=>Tired, etime=>ETime, cover=>true},
	buff_util:add_buffs(Actor, [{BuffID, Opts}]).

give_belong_reward(BossID, Belong, SUID) ->
	WorldLv = world_level:get_level(),
	case cluster:is_local() of
		true  ->
			belong_reward(BossID, Belong, WorldLv);
		false ->
			cluster:rpc_cast_node(SUID, ?MODULE, belong_reward, [BossID,Belong,WorldLv])
	end.

give_occupy_reward(SceneID, Occupant) ->
	WorldLv = world_level:get_level(),
	case cluster:is_local() of
		true  ->
			occupy_reward(SceneID, WorldLv, Occupant);
		false ->
			case Occupant of
				{_, SUID} ->
					cluster:rpc_cast_node(
						SUID, ?MODULE, occupy_reward, [SceneID,WorldLv,Occupant]
					);
				_ ->
					ignore
			end
	end.

can_open(SUID, Owners) ->
	lists:keymember(SUID, 1, Owners).

-define(k_occupant, {?MODULE,occupant}).
get_occupant() ->
	get(?k_occupant).

set_occupant(Type, Owner) ->
	put(?k_occupant, {Type, Owner}).

clr_occupant() ->
	erase(?k_occupant).

-define(k_bigboss_killer, {?MODULE,bigboss_killer}).
get_bigboss_killer() ->
	get(?k_bigboss_killer).

set_bigboss_killer(Type, ID) ->
	put(?k_bigboss_killer, {Type, ID}).

clr_bigboss_killer() ->
	erase(?k_bigboss_killer).
