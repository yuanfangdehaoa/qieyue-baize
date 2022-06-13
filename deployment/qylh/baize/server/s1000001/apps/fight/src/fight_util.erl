%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(fight_util).

-include("attr.hrl").
-include("boss.hrl").
-include("creep.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("skill.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").

%% API
-export([check_action/1, check_action/2]).
-export([make_skill/2]).
-export([damage/4]).
-export([p_damage/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 是否可行动
check_action(Actor) ->
	check_action(Actor, true).

check_action(Actor, Controllable) ->
	if
		?is_death(Actor#actor.state) ->
			?err(?ERR_FIGHT_HAD_DEAD);
		Controllable ->
			if
				?is_silent(Actor#actor.state) ->
					?err(?ERR_FIGHT_HAD_SILENT);
				?is_chaos(Actor#actor.state) ->
					?err(?ERR_FIGHT_HAD_CHAOS);
				?is_immob(Actor#actor.state) ->
					?err(?ERR_FIGHT_HAD_IMMOB);
				?is_dizzy(Actor#actor.state) ->
					?err(?ERR_FIGHT_HAD_DIZZY);
				true ->
					ok
			end;
		true ->
			ok
	end.

make_skill(SkillID, SkillLv) ->
	CfgSkill = cfg_skill:find(SkillID),
	CfgLevel = cfg_skill_level:find(SkillID, SkillLv),
	#skill{
		id     = SkillID,
		level  = SkillLv,
		is_hew = CfgSkill#cfg_skill.is_hew,
		aim    = CfgSkill#cfg_skill.aim,
		is_hit = CfgSkill#cfg_skill.is_hit,
		cd     = CfgLevel#cfg_skill_level.cd,
		amp    = CfgLevel#cfg_skill_level.amp,
		area   = CfgLevel#cfg_skill_level.area,
		center = CfgLevel#cfg_skill_level.center,
		dist   = CfgLevel#cfg_skill_level.dist,
		radius = CfgLevel#cfg_skill_level.radius,
		cover  = CfgLevel#cfg_skill_level.cover,
		abuffs = CfgLevel#cfg_skill_level.abuffs,
		dbuffs = CfgLevel#cfg_skill_level.dbuffs,
		effect = CfgLevel#cfg_skill_level.effect,
		group  = CfgSkill#cfg_skill.group
	}.

damage(Actor, Unit, Type, Value) ->
    #damage{
		uid    = Actor#actor.uid,
		unit   = Unit,
		coord  = Actor#actor.coord,
		hp     = ?_attr(Actor#actor.attr, ?ATTR_HP),
		type   = Type,
		value  = round(Value),
		state  = Actor#actor.state,
		bctype = Actor#actor.bctype
    }.

p_damage(Damage) ->
    #p_damage{
		uid   = Damage#damage.uid,
		unit  = Damage#damage.unit,
		coord = Damage#damage.coord,
		hp    = Damage#damage.hp,
		type  = Damage#damage.type,
		value = Damage#damage.value,
		state = Damage#damage.state
    }.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------

