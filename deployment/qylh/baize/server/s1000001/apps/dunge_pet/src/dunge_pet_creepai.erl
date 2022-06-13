%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_pet_creepai).

-include("attr.hrl").
-include("btree.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([born/2]).
-export([guard/2]).
-export([walkto_cryst/2]).
-export([update_cryst/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
born(Actor, SceneSt) ->
	#actor{id=CreepID, aiargs=AIArgs} = Actor,
	Pos = proplists:get_value(pos, cfg_creep:aiargs(CreepID)),
	AIArgs2 = maps:put(pos, Pos, AIArgs),
	Actor2  = Actor#actor{aiargs=AIArgs2, center=self},
	creep_ai:born(Actor2, SceneSt).

guard(Actor, _SceneSt) ->
	% ?debug("~ts", ["查找最近的水晶"]),
	#dunge_st{opts=#{crypts:=Crypts}} = dunge_util:get_state(),
	case find_nearest_crypt(Crypts, Actor) of
		0 ->
			% ?debug("~ts", ["没有找到"]),
			?FAILURE;
		CryptID ->
			% ?debug("~ts:~w", ["找到水晶", CryptID]),
			scene_actor:set_actor(Actor#actor{enemy=CryptID}),
			?SUCCESS
	end.

walkto_cryst(Actor, SceneSt) ->
	#dunge_st{opts=#{crypts:=Crypts}} = dunge_util:get_state(),
	case Crypts == [] of
		true  ->
			?FAILURE;
		false ->
			Pos = maps:get(pos, Actor#actor.aiargs),
			CryptID = lists:nth(min(Pos, length(Crypts)), Crypts),
			% ?debug("~ts ~w", ["准备走向水晶", CryptID]),
			case scene_actor:get_actor(CryptID) of
				?nil  ->
					% ?debug("~ts", ["水晶不存在了"]),
					?FAILURE;
				Crypt ->
					do_walkto(Actor, Crypt, SceneSt)
			end
	end.

update_cryst(Actor, _SceneSt) ->
	#dunge_st{roles=Roles} = dunge_util:get_state(),
	#actor{uid=ActorID, attr=Attr} = Actor,
	?bcast(Roles, #m_actor_updatehp_toc{
		uid   = ActorID,
		hp    = ?_attr(Attr,?ATTR_HP),
		hpmax = ?_attr(Attr,?ATTR_HPMAX)
	}),
	?SUCCESS.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
find_nearest_crypt([CryptID | T], Actor) ->
	case scene_actor:get_actor(CryptID) of
		?nil  ->
			find_nearest_crypt(T, Actor);
		Crypt ->
			case scene_util:is_nearby(Actor, Crypt, Actor#actor.atkrad) of
				true  -> Crypt#actor.uid;
				false -> find_nearest_crypt(T, Actor)
			end
	end;
find_nearest_crypt([], _Actor) ->
	0.

do_walkto(Actor, Crypt, SceneSt) ->
	#actor{coord=Coord, atkrad=AtkRad} = Actor,
	#actor{uid=CryptID, coord=Dest} = Crypt,
	case scene_util:is_nearby(Coord, Dest, AtkRad) of
		true  ->
			% ?debug("~ts", ["在水晶附近了111"]),
			scene_actor:set_actor(Actor#actor{enemy=CryptID}),
			?SUCCESS;
		false ->
			% 尝试走向自己那一路的水晶
			do_walkto2(Actor, Crypt, SceneSt)
	end.

do_walkto2(Actor, Crypt, SceneSt) ->
	#actor{atkrad=AtkRad, coord=Coord1} = Actor,
	#actor{uid=CryptID, coord=Coord2} = Crypt,
	Dist = scene_util:calc_distance(Coord1, Coord2),
	Move = min(300, Dist-AtkRad),
	Dest = creep_aipath:dest(towards, Actor, Coord2, {move,Move}, SceneSt),
	% ?debug("~ts ~w", ["走向水晶", {Actor#actor.coord, Dest}]),
	case creep_aipath:find(Actor, Dest, SceneSt) of
		?FAILURE ->
			% 找不到路，尝试走向中路水晶，以避免怪物一动不动
			% ?debug("~ts", ["找不到路"]),
			do_walkto3(Actor, SceneSt);
		?SUCCESS ->
			% ?debug("~ts ~w", ["在水晶附近了222", {?tile(Actor#actor.coord), ?tile(Dest)}]),
			scene_actor:set_actor(Actor#actor{enemy=CryptID}),
			?SUCCESS;
		?RUNNING ->
			Actor2 = scene_actor:get_actor(Actor#actor.uid),
			creep_ai:move(Actor2, SceneSt)
	end.

do_walkto3(Actor, SceneSt) ->
	Crypts = cfg_creep_born:find(SceneSt#scene_st.scene),
	Crypt  = lists:nth(2, Crypts),
	Coord2 = #p_coord{
		x = element(2, Crypt),
		y = element(3, Crypt)
	},
	#actor{uid=ActorID, atkrad=AtkRad, coord=Coord1} = Actor,
	case scene_util:is_nearby(Coord1, Coord2, 20) of
		true  ->
			% ?debug("~ts", ["在中心点附近了"]),
			?FAILURE;
		false ->
			Dist = scene_util:calc_distance(Coord1, Coord2),
			Move = min(300, Dist-AtkRad),
			Dest = creep_aipath:dest(
				towards, Actor, Coord2, {move,Move}, SceneSt
			),
			% ?debug("~ts ~w", ["走向中心点", Dest]),
			case creep_aipath:find(Actor, Dest, SceneSt) of
				?RUNNING ->
					Actor2 = scene_actor:get_actor(ActorID),
					creep_ai:move(Actor2, SceneSt);
				_ ->
					?FAILURE
			end
	end.
