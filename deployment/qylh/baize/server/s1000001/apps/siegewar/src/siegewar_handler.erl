%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(siegewar_handler).

-include("game.hrl").
-include("role.hrl").
-include("siegewar.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/3]).
-export([add_medal/2]).
-export([hook_reset/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 城市信息
handle(?SIEGEWAR_CITY, _Tos, RoleSt) ->
	#role_st{role=RoleID, guild=GuildID} = RoleSt,
	SUID = game_env:get_suid(),
	RoleSiegeWar = role_data:get(?DB_ROLE_SIEGEWAR),
	{ok, RuleID, Cities} = case siegewar_server:get_divide_rule() of
		0 -> siegewar_server:get_city_info(SUID);
		_ -> call_cross(siegewar_server, get_city_info, [SUID])
	end,
	ScoreKey = case RuleID of
		0 when GuildID == 0 ->
			{?OWNER_TYPE_ROLE, RoleID};
		0 ->
			{?OWNER_TYPE_GUILD, GuildID};
		_ ->
			{?OWNER_TYPE_SERVER, SUID}
	end,
	Link = lists:foldl(fun
		(City, Acc) ->
			#siegecity{scene=SceneID, enter=CanEnter} = City,
			CityLv = cfg_siegewar_boss:level(SceneID),
			case CityLv == 2 andalso lists:member(SUID, CanEnter) of
				true  -> [SceneID | Acc];
				false -> Acc
			end
	end, [], Cities),
	?ucast(#m_siegewar_city_toc{
		cities = [#p_siegewar_city{
			scene = City#siegecity.scene,
			suid  = City#siegecity.owner,
			boss  = City#siegecity.boss,
			score = maps:get(ScoreKey, City#siegecity.score, 0),
			level = cfg_siegewar_boss:level(City#siegecity.scene),
			temp  = City#siegecity.temp,
			name  = case RuleID of
				0 ->
					case City#siegecity.owner > 0 of
						true  -> guild:get_name(City#siegecity.owner);
						false -> "无归属"
					end;
				_ -> ?nil
			end
		} || City <- lists:keysort(#siegecity.scene, Cities)],
		medal = RoleSiegeWar#role_siegewar.medal,
		fetch = RoleSiegeWar#role_siegewar.fetch,
		rule  = RuleID,
		link  = Link
	});

%% boss信息
handle(?SIEGEWAR_BOSS, Tos, RoleSt) ->
	#m_siegewar_boss_tos{scene=SceneID} = Tos,
	{ok, City, Bosses} = case siegewar_server:get_divide_rule() of
		0 -> siegewar_server:get_boss_info(SceneID);
		_ -> call_cross(siegewar_server, get_boss_info, [SceneID])
	end,
	ScoreList = maps:fold(fun
		({Type, ID}, Score, Acc) ->
			Name = case Type of
				?OWNER_TYPE_ROLE   ->
					{ok, Cache} = role:get_cache(ID),
					Cache#role_cache.name;
				?OWNER_TYPE_GUILD  ->
					guild:get_name(ID);
				?OWNER_TYPE_SERVER ->
					""
			end,
			[#p_siegewar_score{
				id    = ID,
				name  = Name,
				type  = Type,
				score = Score
			} | Acc]
	end, [], City#siegecity.score),
	?ucast(#m_siegewar_boss_toc{
		scene  = SceneID,
		bosses = [#p_siegewar_boss{
			id   = Boss#siegeboss.boss,
			born = Boss#siegeboss.born
		} || Boss <- Bosses],
		suid   = City#siegecity.owner,
		score  = ScoreList
	});

%% 伤害排名
handle(?SIEGEWAR_DAMAGE, Tos, RoleSt) ->
	case in_siegewar_scene(RoleSt) of
		true  ->
			#role_st{spid=ScenePid, role=RoleID, scene=SceneID2} = RoleSt,
			#m_siegewar_damage_tos{boss=BossID} = Tos,
			#cfg_siegewar_boss{scene=SceneID1} = cfg_siegewar_boss:find(BossID),
			?_check(SceneID1 == SceneID2, ?ERR_GAME_BAD_ARGS),
			scene:route(ScenePid, siegewar_server, send_damage_ranking, {BossID,RoleID});
		false ->
			ignore
	end;

%% 掉落记录
handle(?SIEGEWAR_DROPPED, _Tos, RoleSt) ->
	Logs = case siegewar_server:get_divide_rule() of
		0 ->
			game_logger:get_logs(siegewar_drop_log);
		_ ->
			cluster:rpc_call_cross(
				?CROSS_RULE_24_8, game_logger, get_logs, [siegewar_drop_log]
			)
	end,
	?ucast(#m_siegewar_dropped_toc{logs=lists:reverse(Logs)});

%% 领取勋章奖励
handle(?SIEGEWAR_MEDAL_FETCH, Tos, RoleSt) ->
	#m_siegewar_medal_fetch_tos{medal=Medal} = Tos,
	RoleSiegeWar = role_data:get(?DB_ROLE_SIEGEWAR),
	#role_siegewar{medal=CurMedal, fetch=Fetch} = RoleSiegeWar,
	?_check(not lists:member(Medal, Fetch), ?ERR_SIEGEWAR_HAD_FETCH),
	% WorldLv = case siegewar_server:get_divide_rule() of
	% 	0 -> world_level:get_level();
	% 	_ -> siegewar_server:get_worldlv()
	% end,
	Opdays = game_env:get_opened_days(),
	Gain   = cfg_siegewar_medal_reward:find(Medal, Opdays),
	?_check(Gain /= [], ?ERR_GAME_BAD_ARGS),
	?_check(CurMedal >= Medal, ?ERR_SIEGEWAR_MEDAL_NOT_ENOUGH),
	role_bag:gain(Gain, ?LOG_SIEGEWAR_FETCH_MEDAL, RoleSt),
	role_data:set(RoleSiegeWar#role_siegewar{fetch=[Medal | Fetch]}),
	?ucast(#m_siegewar_medal_fetch_toc{medal=Medal});

%% 购买勋章
handle(?SIEGEWAR_MEDAL_BUY, _Tos, RoleSt) ->
	#role_siegewar{medal=CurMedal} = role_data:get(?DB_ROLE_SIEGEWAR),
	MaxMedal = cfg_siegewar_medal_reward:max(),
	?_check(CurMedal >= 750, ?ERR_GAME_BAD_ARGS),
	?_check(CurMedal < MaxMedal, ?ERR_GAME_BAD_ARGS),
	NeedGold = ut_math:ceil((MaxMedal - CurMedal) / 5),
	Cost = [{?ITEM_GOLD, NeedGold}],
	Gain = [{?ITEM_MEDAL, MaxMedal - CurMedal}],
	role_bag:deal(Cost, Gain, ?LOG_SIEGEWAR_BUY_MEDAL, RoleSt),
	?ucast(#m_siegewar_medal_buy_toc{});

%% 宝箱信息
handle(?SIEGEWAR_BOXINFO, Tos, RoleSt) ->
	case in_siegewar_scene(RoleSt) of
		true  ->
			#m_siegewar_boxinfo_tos{box_uid=BoxID} = Tos,
			#role_st{spid=ScenePid, role=RoleID} = RoleSt,
			scene:route(ScenePid, siegewar_server, send_boxinfo, {RoleID,BoxID});
		false ->
			ignore
	end;

%% 宝箱开启
handle(?SIEGEWAR_BOXOPEN, Tos, RoleSt) ->
	case in_siegewar_scene(RoleSt) of
		true  ->
			#role_st{spid=ScenePid, role=RoleID} = RoleSt,
			#m_siegewar_boxopen_tos{type=Type, boss=BossID, times=Times} = Tos,
			Opdays = game_env:get_opened_days(),
			CfgBox = cfg_siegewar_box_reward:find(BossID, Type, Times, Opdays),
			#cfg_siegewar_box{reqs=Reqs, cost=Cost, reward=DropList} = CfgBox,
			check_open_reqs(Reqs),
			#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
			Gain = creep_drop:calc(RoleLv, DropList),
			SUID = game_env:get_suid(),
			Args = {RoleID, SUID, BossID, Times, Type, Gain},
			Succ = fun() ->
				ok = scene:sync_route(ScenePid, siegewar_server, open_box, Args)
			end,
			role_bag:deal(Cost, Gain, ?LOG_SIEGEWAR_OPENBOX, Succ, RoleSt);
		false ->
			ignore
	end.


add_medal(MedalAdd, _RoleSt) ->
	RoleSiegeWar = #role_siegewar{medal=CurMedal} = role_data:get(?DB_ROLE_SIEGEWAR),
	role_data:set(RoleSiegeWar#role_siegewar{medal=CurMedal+MedalAdd}).

hook_reset(_NowDoW, _NowHour, _RoleSt) ->
	RoleSiegeWar = role_data:get(?DB_ROLE_SIEGEWAR),
	role_data:set(RoleSiegeWar#role_siegewar{medal=0, fetch=[]}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
in_siegewar_scene(RoleSt) ->
	RoleSt#role_st.stype == ?SCENE_STYPE_SIEGEWAR.

call_cross(M, F, A) ->
	cluster:rpc_call_cross(?CROSS_RULE_24_8, M, F, A).

check_open_reqs([{vip, CfgVip} | T]) ->
	VipLv = role_vip:get_level(),
	?_check(VipLv >= CfgVip, ?ERR_VIP_NOT_ENOUGH),
	check_open_reqs(T);
check_open_reqs([]) ->
	ok.
