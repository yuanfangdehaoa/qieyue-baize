%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_coin_dungeai).

-include("btree.hrl").
-include("creep.hrl").
-include("dunge.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([update/1]).
-export([stat/1]).
-export([is_guard/1]).
-export([is_over/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
update(SceneSt) ->
	DungeSt = dunge_util:get_state(),
	#dunge_st{star=Star, opts=Opts, roles=[RoleID]} = DungeSt,
	% 更新金币
	{hook_drop, [_Defer, Drops]} = dunge_util:get_event(),

	AddCoin = lists:foldl(fun
		(Drop, Acc) ->
			case Drop#drop.id == ?ITEM_COIN of
				true  -> Acc + Drop#drop.num;
				false -> Acc
			end
	end, 0, Drops),
	Opts1 = ut_misc:maps_increase(guard_kill, 1, Opts),
	Opts2 = ut_misc:maps_increase(coin_gain, AddCoin, Opts1),
	% 更新评星
	[CntLim1, CntLim2] = cfg_dunge_coin:rating(SceneSt#scene_st.floor),
	Count = maps:get(guard_kill, Opts2),
	Star2 = if
		Count >= CntLim2 -> ?STAR2;
		Count >= CntLim1 -> ?STAR1;
		true -> 0
	end,
	DungeSt2 = DungeSt#dunge_st{star=Star2, opts=Opts2},
	dunge_util:set_state(DungeSt2),
	?_if(Star2 > Star, dunge_coin:send_info(RoleID, SceneSt)),
	?SUCCESS.

stat(SceneSt) ->
	% ?debug("--------------stat"),
	#scene_st{scene=SceneID, floor=FloorID} = SceneSt,
	DungeSt = dunge_util:get_state(),
	#dunge_st{clear=Clear, star=Star, opts=Opts, roles=[RoleID]} = DungeSt,
	FinStar = ?_if(Clear, Star bor 2#00000100, Star),
	dunge_util:set_state(DungeSt#dunge_st{star=FinStar}),
	role:route(RoleID, dunge_coin, update_star, [FloorID, FinStar]),
	?ucast(RoleID, #m_dunge_over_toc{
		stype = ?SCENE_STYPE_DUNGE_COIN,
		id    = SceneID,
		clear = Clear,
		stat  = #{
			"coin"  => maps:get(coin_gain, Opts, 0),
			"star"  => FinStar,
			"floor" => FloorID
		},
		count = DungeSt#dunge_st.kill
	}),
	?SUCCESS.

is_guard(_SceneSt) ->
	{hook_drop, [Actor, _]} = dunge_util:get_event(),
	Actor#actor.rarity == ?CREEP_RARITY_GUARD.

is_over(SceneSt) ->
	#dunge_st{opts=Opts} = dunge_util:get_state(),
	Count = maps:get(guard_kill, Opts, 0),
	% ?debug("is_over--------------:~w", [Count]),
	Count >= cfg_dunge_coin:count(SceneSt#scene_st.floor).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
