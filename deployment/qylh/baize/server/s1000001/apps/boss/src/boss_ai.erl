%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(boss_ai).

-include("boss.hrl").
-include("btree.hrl").
-include("creep.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([can_heal/2]).
-export([can_weaken/2]).
-export([weaken_cd/1]).
-export([weaken_stop/2]).
-export([weaken/2]).
-export([change_belong/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
can_heal(Actor, _SceneSt) ->
	#cfg_creep{guard=Guard} = cfg_creep:find(Actor#actor.id),
	RoleIDs = scene_actor:get_actids(?ACTOR_TYPE_ROLE, Actor#actor.coord),
	lists:all(fun
		(RoleID) ->
			case scene_actor:get_actor(RoleID) of
				?nil -> true;
				Role -> not scene_util:is_nearby(Actor, Role, Guard)
			end
	end, RoleIDs).

can_weaken(Actor, _SceneSt) ->
	#actor{id=BossID, state=State, attr=Attr} = Actor,
	#cfg_boss{qual=Qual} = cfg_boss:find(BossID),
	#{?ATTR_HP:=Hp, ?ATTR_HPMAX:=HpMax} = Attr,
	(not ?is_death(State)) andalso Qual > ?COLOR_GREEN andalso Hp >= HpMax.

weaken_cd({_, ActorID}) ->
	#actor{id=BossID, spid=ScenePid} = scene_actor:get_actor(ActorID),
	#cfg_boss{weak=WeakCD} = cfg_boss:find(BossID),
	?debug("WeakCD--------------:~w", [BossID]),
	gen_server:cast(boss_server, {weakcd, ScenePid, BossID, WeakCD}),
	WeakCD * 1000 div ?LOOP_MILLIS.

weaken_stop(Actor, _SceneSt) ->
	?debug("weaken_stop--------------:~w", [Actor#actor.id]),
	scene_util:bc_to_scene(#m_boss_weakstop_toc{id=Actor#actor.id}),
	?SUCCESS.

weaken(Actor, _SceneSt) ->
	?debug("weaken--------------:~w", [Actor#actor.id]),
	gen_server:cast(boss_server, {weaken, self(), Actor#actor.id}),
	?SUCCESS.


%% 改变归属
change_belong(Actor) ->
	#actor{uid=ActorID, coord=Coord, threat=Threat0, exargs=ExArgs} = Actor,

    #cfg_creep{guard=Guard} = cfg_creep:find(Actor#actor.id),

	Threat2 = maps:filter(fun
		(EnemyID, _) ->
			case scene_actor:get_actor(EnemyID) of
				?nil  -> false;
				Enemy -> scene_util:is_nearby(Actor, Enemy, Guard+50)
			end
	end, Threat0),

	BelongRole1 = maps:get("belong_role", ExArgs, 0),
	BelongTeam1 = maps:get("belong_team", ExArgs, 0),

	case fight_threat:sort(team, Threat2) of
		[] ->
			BelongRole2 = fight_threat:highest(role, Threat2),
			BelongTeam2 = 0;
		[{TeamID, _DmgVal}|_] ->
			% ?debug(Actor#actor.id==20001001, "aaaaaaa:~w", [{scene_team:get_membs(TeamID)}]),
			TeamThreat   = maps:with(scene_team:get_membs(TeamID), Threat2),
			% 队伍中伤害最高的玩家
			HighestRole1 = fight_threat:highest(role, TeamThreat),
			% 伤害最高的玩家
			HighestRole2 = fight_threat:highest(role, Threat2),
			case HighestRole1 == HighestRole2 of
				true  ->
					BelongRole2 = HighestRole1,
					BelongTeam2 = TeamID;
				false ->
					BelongRole2 = HighestRole2,
					BelongTeam2 = 0
			end

	end,

	case BelongRole1 /= BelongRole2 orelse BelongTeam1 /= BelongTeam2 of
		true  ->
			Update = #{
				"ext.belong_role" => ut_conv:to_list(BelongRole2),
				"ext.belong_team" => ut_conv:to_list(BelongTeam2)
			},
			% ?debug(Actor#actor.id==20001001, "change_belong:~p", [Update]),
			Toc = #m_actor_update_toc{uid=ActorID, upstr=Update},
			scene_util:bc_to_grid(Coord, Toc);
		false ->
			ok
	end,

	ExArgs2 = maps:merge(
		ExArgs,
		#{"belong_role"=>BelongRole2, "belong_team"=>BelongTeam2}
	),
	Actor#actor{threat=Threat2, exargs=ExArgs2}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
