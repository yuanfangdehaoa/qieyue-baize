%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_newbie_summon_creepai).

-include("attr.hrl").
-include("btree.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([is_over/2]).
-export([is_timeout/2]).
-export([init_bomb/2]).
-export([bomb/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
is_over(_Actor, _SceneSt) ->
	DungeSt = dunge_util:get_state(),
	% ?debug("is_over-----------------------:~w", [DungeSt#dunge_st.over]),
	DungeSt#dunge_st.over.

is_timeout(Actor, _SceneSt) ->
	% ?debug("--------------is_timeout"),
	ut_time:seconds() >= Actor#actor.etime.

init_bomb(Actor, _SceneSt) ->
	#actor{etime=ETime, exargs=ExArgs} = Actor,
	Actor2 = Actor#actor{
		exargs = ExArgs#{
			"disappear" => ETime,
			die_notify  => false
		}
	},
	scene_actor:set_actor(Actor2),
	?SUCCESS.

bomb(Actor, _SceneSt) ->
	% ?debug("bomb-----------------------"),
	#dunge_st{roles=[RoleID]} = dunge_util:get_state(),
	case scene_actor:get_actor(RoleID) of
		?nil ->
			ignore;
		Role ->
			#actor{attr=Attr} = Role,
			OldHp1 = ?_attr(Attr, ?ATTR_HP),
			DelHp1 = round(OldHp1 * 0.3),
			NewHp1 = max(1, OldHp1 - DelHp1),
			Attr1  = ?_setattr(Attr, ?ATTR_HP, NewHp1),
			scene_actor:set_actor(Role#actor{attr=Attr1}),
			% 通知玩家血量变化
			Damage1 = fight_util:damage(
				Role, ?ATTACK_UNIT_CREEP, ?DAMAGE_BLOOD, DelHp1
			),
			?ucast(RoleID, #m_fight_damage_toc{
				dmgs  = [fight_util:p_damage(Damage1)],
				coord = Actor#actor.coord
			}),

			% 通知炸弹怪爆炸
			OldHp2  = ?_attr(Actor#actor.attr, ?ATTR_HP),
			Attr2   = ?_setattr(Actor#actor.attr, ?ATTR_HP, 0),
			Actor2  = Actor#actor{attr=Attr2},
			Damage2 = fight_util:damage(
				Actor2, ?ATTACK_UNIT_ROLE, ?DAMAGE_BLOOD, OldHp2
			),
			?ucast(RoleID, #m_fight_damage_toc{
				dmgs  = [fight_util:p_damage(Damage2)],
				coord = Actor2#actor.coord
			})
	end,
	?SUCCESS.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
