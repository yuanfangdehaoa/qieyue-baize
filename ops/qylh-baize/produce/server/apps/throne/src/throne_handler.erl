%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(throne_handler).

-include("game.hrl").
-include("role.hrl").
-include("throne.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([handle/3]).

-define(in_throne(RoleSt),
	RoleSt#role_st.stype == ?SCENE_STYPE_THRONE
).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
handle(?THRONE_PANEL, _Tos, RoleSt) ->
	{ok, Roles, Scores} = cluster:rpc_call_cross(
		?CROSS_RULE_24_8, throne_server, get_panel, []
	),
	Unlock = throne_server:is_unlock(Scores, game_env:get_suid()),
	?ucast(#m_throne_panel_toc{roles=Roles, unlock=Unlock});

handle(?THRONE_BOSS, _Tos, RoleSt) ->
	case ?in_throne(RoleSt) of
		true  ->
			{ok, WorldLv, Bosses} = cluster:rpc_call_cross(
				?CROSS_RULE_24_8, throne_server, get_bosses, []
			),
			Bosses2 = lists:filtermap(fun
				(Boss) ->
					#cfg_throne_boss{scene=SceneID} = cfg_throne_boss:find(Boss#throneboss.id),
					case RoleSt#role_st.scene == SceneID of
						true  -> {true, p_throne_boss(WorldLv, Boss)};
						false -> false
					end
			end, Bosses),
			?ucast(#m_throne_boss_toc{bosses=Bosses2});
		false ->
			ignore
	end;

handle(?THRONE_DAMAGE, Tos, RoleSt) ->
	case ?in_throne(RoleSt) of
		true  ->
			#m_throne_damage_tos{boss_id=BossID} = Tos,
			#role_st{spid=ScenePid, role=RoleID} = RoleSt,
			scene:route(ScenePid, throne_server, send_damage_ranking, {BossID,RoleID});
		false ->
			ignore
	end;

handle(?THRONE_SCORE, _Tos, RoleSt) ->
	case ?in_throne(RoleSt) of
		true  ->
			#role_st{spid=ScenePid, role=RoleID} = RoleSt,
			scene:route(ScenePid, throne_server, send_score_ranking, RoleID);
		false ->
			ignore
	end;

handle(?THRONE_IS_UNLOCK, _Tos, RoleSt) ->
	case ?in_throne(RoleSt) of
		true  ->
			#role_st{spid=ScenePid, role=RoleID} = RoleSt,
			SUID = game_env:get_suid(),
			scene:route(ScenePid, throne_server, send_unlock_info, {RoleID,SUID});
		false ->
			ignore
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
p_throne_boss(WorldLv, Boss) ->
	#p_throne_boss{
		id    = Boss#throneboss.id,
		born  = Boss#throneboss.born,
		level = WorldLv
	}.
