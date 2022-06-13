%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(throne_server).

-behaviour(gen_server).

-include("attr.hrl").
-include("creep.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("item.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("throne.hrl").
-include("enum.hrl").
-include("errno.hrl").
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
-export([hook_init/1]).
-export([hook_enter/2]).
-export([hook_leave/2]).
-export([hook_loopsec/2]).
-export([hook_creep_dead/3]).
-export([calc_belong/1]).
-export([pre_enter/2]).
-export([hook_pickup/3]).
-export([pickup_notify/2]).
-export([unlock_notify/2]).

-export([hook_start/1]).
-export([hook_stop/1]).

-export([is_unlock/2]).
-export([get_panel/0]).
-export([get_bosses/0]).
-export([get_entry/3]).
-export([send_damage_ranking/2]).
-export([send_score_ranking/2]).
-export([send_unlock_info/2]).

-define(SERVER, ?MODULE).
-record(state, {roles}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

get_panel() ->
	{ok, State} = gen_server:call(?SERVER, get_state),
	Scores = ets:tab2list(?ETS_THRONE_SCORE),
	{ok, State#state.roles, Scores}.
get_bosses() ->
	WorldLv = world_level:get_level(),
	Bosses  = ets:tab2list(?ETS_THRONE_BOSS),
	{ok, WorldLv, Bosses}.

is_unlock(Scores, MySUID) ->
	lists:any(fun
		({{SUID,_}, Score}) ->
			SUID == MySUID andalso Score >= cfg_game:throne_unlock_score()
	end, Scores).

get_entry(_ActID, SceneID, _RoleSt) ->
	#{scene => SceneID}.

hook_start(ActID) ->
	?debug("hook_start---------------------:~w", [ActID]),
	gen_server:cast(?SERVER, start).

hook_stop(ActID) ->
	?debug("hook_stop---------------------:~w", [ActID]),
	gen_server:cast(?SERVER, stop).

pre_enter(Actor, _SceneSt=#scene_st{scene=SceneID}) ->
	#cfg_scene{reqs=Reqs} = cfg_scene:find(SceneID),
	ScoreLim = proplists:get_value(score, Reqs, 0),
	case ScoreLim > 0 of
		true  ->
			Scores = ets:tab2list(?ETS_THRONE_SCORE),
			Unlock = is_unlock(Scores, Actor#actor.suid),
			?_check(Unlock, ?ERR_THRONE_SCENE_LOCKED);
		false ->
			ok
	end.

hook_init(SceneSt) ->
	set_score_ranking(SceneSt#scene_st.scene, []).

hook_enter(_Actor, SceneSt) ->
	gen_server:cast(?SERVER, {role_enter, SceneSt#scene_st.scene}).

hook_leave(_Actor, SceneSt) ->
	gen_server:cast(?SERVER, {role_leave, SceneSt#scene_st.scene}).

hook_loopsec(Secs, _SceneSt) when Secs rem 3 == 0 ->
	ActorIDs = scene_actor:get_actids(?ACTOR_TYPE_CREEP),
	lists:foreach(fun
		(ActorID) ->
			Actor = scene_actor:get_actor(ActorID),
			?_if(
				is_record(Actor, actor) andalso ?is_throneboss(Actor),
				update_damage_ranking(Actor)
			)
	end, ActorIDs);
hook_loopsec(_Secs, _SceneSt) ->
	ignore.

%% 击杀boss
hook_creep_dead(Atker, Defer, SceneSt) when ?is_throneboss(Defer) ->
	#actor{suid=SUID, uid=AtkerUID, name=AtkerName} = Atker,
	#actor{id=BossID, level=BossLv, name=BossName, born=Coord} = Defer,
	#cfg_throne_boss{score=Score, reborn=RebornSecs} = cfg_throne_boss:find(BossID),

	update_damage_ranking(Defer),
	update_score_ranking(SUID, Score, SceneSt#scene_st.scene),

	Reborn = ut_time:seconds() + RebornSecs,

	Creeps = [
		% 墓碑
		{1099999, Coord, #{
			name   => io_lib:format("~w~ts ~ts", [BossLv, cfg_lang:find(level), BossName]),
			exargs => #{"boss_reborn"=>Reborn, "killer"=>SUID}
		}}
	],
	[TombID] = creep_agent:add(Creeps, SceneSt),

	ets:update_element(?ETS_THRONE_BOSS, BossID, [
		{#throneboss.born, Reborn},
		{#throneboss.tomb, TombID}
	]),

	case Score > 0 of
		true  ->
			Key = {SUID,SceneSt#scene_st.scene},
			NewScore = ets:update_counter(?ETS_THRONE_SCORE, Key, {2,Score}, {Key,0}),
			case NewScore >= cfg_game:throne_unlock_score() of
				true  ->
					lists:foreach(fun
						(SceneID) ->
							#cfg_scene{reqs=Reqs} = cfg_scene:find(SceneID),
							?_if(
								not proplists:is_defined(score, Reqs),
								scene:route(SceneID, ?MODULE, unlock_notify, SUID)
							)
					end, cfg_throne_boss:scenes()),
					cluster:notify(
						?CROSS_RULE_24_8,
						?MSG_THRONE_UNLOCK,
						[SUID]
					);
				false ->
					ignore
			end;
		false ->
			ignore
	end,

	#cfg_scene{name=SceneName} = cfg_scene:find(SceneSt#scene_st.scene),
	case Score > 0 of
		true  ->
			cluster:notify(
				?CROSS_RULE_24_8,
				?MSG_THRONE_KILL,
				[SUID, {role,AtkerUID,AtkerName}, SceneName, BossName, Score]
			);
		false ->
			cluster:notify(
				?CROSS_RULE_24_8,
				?MSG_THRONE_KILL2,
				[SUID, {role,AtkerUID,AtkerName}, SceneName, BossName]
			)
	end,

	scene_util:bc_to_scene(#m_throne_boss_update_toc{
		id   = BossID,
		born = Reborn
	});
hook_creep_dead(_Atker, _Defer, _SceneSt) ->
	ignore.


unlock_notify(SUID, _SceneSt) ->
	RoleIDs = lists:filter(fun
		(RoleID) ->
			case scene_actor:get_actor(RoleID) of
				?nil  -> false;
				Actor -> Actor#actor.suid == SUID
			end
	end, scene_actor:get_actids(?ACTOR_TYPE_ROLE)),
	?bcast(RoleIDs, #m_throne_is_unlock_toc{unlock=true}),
	ok.


hook_pickup(Drop, Item, RoleSt) ->
	#cfg_item{notify=IsNotify} = cfg_item:find(Drop#drop.id),
	case IsNotify of
		true  ->
			CacheID  = cluster:rpc_call_center(item_cache, add_cache, [Item]),
			#role_st{role=RoleID, scene=SceneID, spid=ScenePid} = RoleSt,
			RoleInfo = role_data:get(?DB_ROLE_INFO),
			#role_info{id=RoleID, name=RoleName} = RoleInfo,
			#cfg_scene{name=SceneName} = cfg_scene:find(SceneID),
			#cfg_creep{name=BossName} = cfg_creep:find(Drop#drop.creep),
			Args = [
				game_uid:suid2ssid(),
				{role,RoleID,RoleName},
				SceneName,
				BossName,
				{pitem, #{CacheID=>(Drop#drop.id)}}
			],
			Dropped = #p_dropped{
				time        = ut_time:seconds(),
				scene       = SceneID,
				picker_id   = RoleID,
				picker_name = RoleName,
				boss        = BossName,
				item_id     = Drop#drop.id,
				cache_id    = CacheID
			},
			scene:route(ScenePid, ?MODULE, pickup_notify, {Dropped,Args});
		false ->
			ignore
	end.

pickup_notify({Dropped,Args}, _SceneSt) ->
	cluster:notify(?CROSS_RULE_24_8, ?MSG_THRONE_DROP, Args),
	game_logger:add_log({boss_drop_log,3}, Dropped).


calc_belong(Defer) ->
	[#p_throne_damage{id=KillSUID} | _] = get_damage_ranking(Defer#actor.id),
	RoleIDs = scene_actor:get_actids(?ACTOR_TYPE_ROLE),
	lists:filter(fun
		(RoleID) ->
			case scene_actor:get_actor(RoleID) of
				?nil  -> false;
				Actor -> cluster:is_same(Actor#actor.suid, KillSUID)
			end
	end, RoleIDs).


send_damage_ranking({BossID, RoleID}, _SceneSt) ->
	Ranking = get_damage_ranking(BossID),
	?ucast(RoleID, #m_throne_damage_toc{boss_id=BossID, ranking=Ranking}).

send_score_ranking(RoleID, SceneSt) ->
	Ranking = get_score_ranking(SceneSt#scene_st.scene),
	?ucast(RoleID, #m_throne_score_toc{ranking=Ranking}).

send_unlock_info({RoleID, SUID}, _SceneSt) ->
	Scores = ets:tab2list(?ETS_THRONE_SCORE),
	Unlock = is_unlock(Scores, SUID),
	?ucast(RoleID, #m_throne_is_unlock_toc{unlock=Unlock}).


%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	ets:new(?ETS_THRONE_BOSS, [named_table, public, {keypos,#throneboss.id}]),
	ets:new(?ETS_THRONE_SCORE, [named_table, public]),
	{ok, #state{roles=#{}}}.

handle_call(Req, From, State) ->
	?try_handle_call(do_handle_call(Req, From, State), State).

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
do_handle_call(get_state, _From, State) ->
	{reply, {ok, State}, State};

do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.


do_handle_cast({role_enter, SceneID}, State=#state{roles=Roles}) ->
	Roles2 = ut_misc:maps_increase(SceneID, 1, Roles),
	{noreply, State#state{roles=Roles2}};

do_handle_cast({role_leave, SceneID}, State=#state{roles=Roles}) ->
	OldNum = maps:get(SceneID, Roles, 0),
	NewNum = max(0, OldNum-1),
	Roles2 = maps:put(SceneID, NewNum, Roles),
	{noreply, State#state{roles=Roles2}};

do_handle_cast(start, State) ->
	SceneIDs = cfg_throne_boss:scenes(),
	lists:foreach(fun
		(SceneID) ->
			scene:create(SceneID)
	end, SceneIDs),

	BossIDs = cfg_throne_boss:bosses(),
	lists:foreach(fun
		(BossID) ->
			do_summon(BossID)
	end, BossIDs),

	loop_check(),

	{noreply, State};

do_handle_cast(stop, State) ->
	SceneIDs = cfg_throne_boss:scenes(),
	lists:foreach(fun
		(SceneID) ->
			scene:destroy(SceneID)
	end, SceneIDs),
	ets:delete_all_objects(?ETS_THRONE_BOSS),
	ets:delete_all_objects(?ETS_THRONE_SCORE),
	{noreply, State#state{roles=#{}}};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.


do_handle_info(check, State) ->
	loop_check(),
	ets:safe_fixtable(?ETS_THRONE_BOSS, true),
    do_check(ets:first(?ETS_THRONE_BOSS), ut_time:seconds()),
    ets:safe_fixtable(?ETS_THRONE_BOSS, false),
	{noreply, State};

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.

do_summon(BossID) ->
	Config = cfg_throne_boss:find(BossID),
	#cfg_throne_boss{scene=SceneID, coord={X,Y}, attr={AttrID,AttCoef,DefCoef}} = Config,
	creep:add(SceneID, 0, ?MAIN_LINE, [{BossID,X,Y,AttrID,worldlv,AttCoef,DefCoef,#{}}]),
	ets:insert(?ETS_THRONE_BOSS, #throneboss{id=BossID}).


update_damage_ranking(Boss) ->
	#cfg_creep{guard=Guard} = cfg_creep:find(Boss#actor.id),
	HpMax   = ?_attr(Boss#actor.attr, ?ATTR_HPMAX),
	DmgInfo = maps:fold(fun
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
	end, #{}, Boss#actor.threat),

	DmgList = lists:keysort(2, maps:to_list(DmgInfo)),
	{_, Ranking} = lists:foldl(fun
		({ID, Dmg}, {AccRank, AccRanking}) ->
			RankItem = #p_throne_damage{
				id     = ID,
				damage = Dmg,
				rank   = AccRank
			},
			{AccRank-1, [RankItem | AccRanking]}
	end, {length(DmgList), []}, DmgList),
	% ?debug("update_damage_ranking: ~w", [{Actor#actor.id, Ranking}]),
	set_damage_ranking(Boss#actor.id, Ranking).

-define(k_damage_ranking, {throne_damage_ranking, BossID}).
get_damage_ranking(BossID) ->
	case get(?k_damage_ranking) of
		?nil -> [];
		List -> List
	end.

set_damage_ranking(BossID, Ranking) ->
	put(?k_damage_ranking, Ranking).


update_score_ranking(SUID, Score, SceneID) ->
	ScoreList  = get_score_ranking(SceneID),
	ScoreList1 = case lists:keytake(SUID, #p_throne_score.id, ScoreList) of
		false ->
			[#p_throne_score{id=SUID, score=Score} | ScoreList];
		{value, RankItem, T} ->
			#p_throne_score{score=OldScore} = RankItem,
			[RankItem#p_throne_score{score=OldScore+Score} | T]
	end,

	ScoreList2 = lists:keysort(#p_throne_score.score, ScoreList1),
	{_, Ranking} = lists:foldl(fun
		(RankItem, {AccRank, AccRanking}) ->
			RankItem2 = RankItem#p_throne_score{rank=AccRank},
			{AccRank-1, [RankItem2 | AccRanking]}
	end, {length(ScoreList2), []}, ScoreList2),

	set_score_ranking(SceneID, Ranking).



-define(k_score_ranking, {throne_score_ranking,SceneID}).
get_score_ranking(SceneID) ->
	case get(?k_score_ranking) of
		?nil -> [];
		List -> List
	end.

set_score_ranking(SceneID, Ranking) ->
	put(?k_score_ranking, Ranking).


loop_check() ->
	erlang:send_after(timer:seconds(1), self(), check).

do_check('$end_of_table', _NowSec) ->
	ok;
do_check(BossID, NowSec) ->
	[Boss] = ets:lookup(?ETS_THRONE_BOSS, BossID),
	#throneboss{id=BossID, born=Born, tomb=TombID} = Boss,
	case Born > 0 andalso NowSec >= Born of
		true  ->
			% 删除墓碑
			#cfg_throne_boss{scene=SceneID} = cfg_throne_boss:find(BossID),
			?_if(TombID > 0, creep:del(SceneID, 0, 1, TombID)),
			do_summon(BossID);
		false ->
			ignore
	end,
	do_check(ets:next(?ETS_THRONE_BOSS, BossID), NowSec).

