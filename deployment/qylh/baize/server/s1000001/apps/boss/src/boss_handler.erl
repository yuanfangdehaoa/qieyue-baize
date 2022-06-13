%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(boss_handler).

-include("boss.hrl").
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
-export([damage_rank/2]).
-export([hook_upgrade/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% boss列表
handle(?BOSS_LIST, Tos, RoleSt) ->
	#m_boss_list_tos{type=Type, floor=Floor} = Tos,
	#role_st{role=RoleID} = RoleSt,
	Bosses = lists:map(fun
		(Boss) ->
			#p_boss{
				id   = Boss#boss.id,
				born = Boss#boss.born,
				care = lists:member(RoleID, Boss#boss.care),
				weak = Boss#boss.weak,
				num  = Boss#boss.num
			}
	end, boss_server:get_bosses(Type)),
	SType = case Type of
		?BOSS_TYPE_WORLD -> ?SCENE_STYPE_BOSS_WORLD;
		?BOSS_TYPE_HOME  -> ?SCENE_STYPE_BOSS_HOME;
		?BOSS_TYPE_WILD  -> ?SCENE_STYPE_BOSS_WILD;
		?BOSS_TYPE_PET   -> ?SCENE_STYPE_BOSS_PET;
		?BOSS_TYPE_BEAST -> ?SCENE_STYPE_BOSS_BEAST;
		?BOSS_TYPE_BEAST_CROSS -> ?SCENE_STYPE_BOSS_BEAST;
		?BOSS_TYPE_SPATIOTEMPORAL -> ?SCENE_STYPE_BOSS_FISSURE
	end,
	Num = case cfg_boss:scene(Type, Floor) of
		?nil  ->
			0;
		Scene ->
			{ok, Lines} = scene_manager:get_lines(Scene, 0),
			maps:fold(fun
				(_, Line, Acc) ->
					Acc + Line#line.num
			end, 0, Lines)
	end,
	MaxTimes = dunge_util:max_boss_times(SType),
	?ucast(#m_boss_list_toc{
		type        = Type,
		bosses      = Bosses,
		tired       = 0,
		enter       = role_count:get_scene_enter(SType),
		num         = Num,
		max_times   = MaxTimes,
		beast_tired = 0,
		beast_coll  = 0,
		beast_coll2 = 0
	});

%% 关注boss
handle(?BOSS_CARE, Tos, RoleSt) ->
	#m_boss_care_tos{id=BossID, op=Op, type=Type} = Tos,
	#role_st{role=RoleID} = RoleSt,
	boss_server:care_boss(RoleID, BossID, Op),
	?ucast(#m_boss_care_toc{id=BossID, op=Op, type=Type});

%% 击杀记录
handle(?BOSS_KILLED, Tos, RoleSt) ->
	#m_boss_killed_tos{id=BossID} = Tos,
	{ok, Boss} = boss_server:get_boss(BossID),
	?ucast(#m_boss_killed_toc{id=BossID, logs=Boss#boss.klog});

%% 掉落记录
handle(?BOSS_DROPPED, Tos, RoleSt) ->
	#m_boss_dropped_tos{type=Type} = Tos,
	DLogs  = case Type == 3 of
		true  ->
			cluster:rpc_call_cross(
				?CROSS_RULE_24_8,
				game_logger,
				get_logs,
				[{boss_drop_log,Type}]
			);
		false ->
			game_logger:get_logs({boss_drop_log,Type})
	end,
	DLogs2 = lists:reverse(DLogs),
	?ucast(#m_boss_dropped_toc{type=Type, logs=DLogs2});

%% 愤怒值
handle(?BOSS_ANGER, _Tos, RoleSt) ->
	#role_st{role=RoleID, spid=ScenePid, stype=SType} = RoleSt,
	IsValid = SType == ?SCENE_STYPE_BOSS_WILD
	   orelse SType == ?SCENE_STYPE_BOSS_PET
	   orelse SType == ?SCENE_STYPE_BOSS_FISSURE,
	?_check(IsValid, ?ERR_BOSS_NOT_INWILD),
	{ok, Actor} = scene:get_actor(ScenePid, RoleID),
	?ucast(#m_boss_anger_toc{
		anger  = maps:get(boss_anger, Actor#actor.exargs, 0),
		kickcd = maps:get(boss_kickcd, Actor#actor.exargs, 0)
	});

%% 手动刷新
handle(?BOSS_REFRESH, Tos, RoleSt) ->
	#role_st{type=Type, scene=SceneID1} = RoleSt,
	?_check(Type == ?SCENE_TYPE_BOSS, ?ERR_BOSS_NOT_INBOSS),
	#m_boss_refresh_tos{id=BossID} = Tos,
	#cfg_boss{scene=SceneID2} = cfg_boss:find(BossID),
	?_check(SceneID1 == SceneID2, ?ERR_GAME_BAD_ARGS),
	Succ = fun() -> ok = boss_server:summon_boss(BossID) end,
	role_bag:cost([{11100, 1}], ?LOG_BOSS_REFRESH, Succ, RoleSt);

handle(?BOSS_DAMAGE_RANK, Tos, RoleSt) ->
	#role_st{role=RoleID, team=TeamID, type=Type, spid=SPid} = RoleSt,
	?_check(Type == ?SCENE_TYPE_BOSS, ?ERR_BOSS_NOT_INBOSS),
	#m_boss_damage_rank_tos{id=BossID} = Tos,
    scene:route(SPid, ?MODULE, damage_rank, {RoleID, TeamID, BossID});

%% 请求支援
handle(?BOSS_SOS, _Tos, RoleSt) ->
	#role_st{
		role=RoleID, guild=GuildID, gpid=GuildPid,
		scene=SceneID, coord=Coord
	} = RoleSt,
	% ?_check(Type == ?SCENE_TYPE_BOSS, ?ERR_BOSS_NOT_INBOSS),
	?_check(GuildID > 0, ?ERR_GUILD_NOT_JOIN),
	RoleBase = role:get_base(RoleID),
	MembIDs  = game_role:get_guild_roles(GuildPid),
	lists:foreach(fun
		(MembID) ->
			?ucast(MembID, #m_boss_sos_toc{
				role     = RoleBase,
				scene_id = SceneID,
				x        = Coord#p_coord.x,
				y        = Coord#p_coord.y
			})
	end, MembIDs).

damage_rank({RoleID, TeamID, BossID}, _SceneSt) ->
	case scene_actor:get_actor(BossID) of
		?nil ->
			ignore;
		Actor ->
			case ?is_boss(Actor) of
				true ->
					Threats = fight_threat:sort(hybrid, Actor#actor.threat),
		            {_, SortRoles0} = lists:foldl(fun({SortID, Damage}, {Rank, Acc}) ->
		            	{Rank+1, [{SortID, Damage, Rank}|Acc]}
		            end, {1, []}, Threats),
					SortRoles = lists:reverse(SortRoles0),
		            RankList  = lists:map(fun({SortID, Damage, Rank}) ->
		            	case SortID of
		            		{role, RID} ->
		            			IsTeam = false,
		            			Captain = RID,
				            	{ok, #role_cache{name=Name}} = role:get_cache(RID);
				            {team, TID} ->
				            	IsTeam = true,
				            	Captain = team_server:get_captain(TID),
				            	{ok, #role_cache{name=Name}} = role:get_cache(Captain)
				        end,
		            	#p_boss_damage_rank{
							rank = Rank, is_team = IsTeam,
							captain = Captain, name = Name, damage  = Damage
		            	}
		            end, lists:sublist(SortRoles, 10)),
		            FID = ?_if(TeamID > 0, {team,TeamID}, {role,RoleID}),
		            case lists:keyfind(FID, 1, SortRoles) of
		            	{_, MyDamage, MyRank} ->
		            		ok;
		            	_ ->
		            		MyDamage = 0,
		            		MyRank = 0
		            end,
					?ucast(RoleID, #m_boss_damage_rank_toc{
						ranks=RankList, my_rank=MyRank, my_damage=MyDamage});
		        _ ->
		            ignore
		    end
	end.

hook_upgrade(NewLv, _RoleSt=#role_st{role=RoleID}) ->
	AutoCare = cfg_boss:auto_care(NewLv),
	lists:foreach(fun
		(BossID) ->
			boss_server:care_boss(RoleID, BossID, 1)
	end, AutoCare),

	AutoCancel = cfg_boss:auto_cancel(),
	lists:foreach(fun
		({BossID, Level}) ->
			?_if(Level =< NewLv, boss_server:care_boss(RoleID, BossID, 2))
	end, AutoCancel).


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
