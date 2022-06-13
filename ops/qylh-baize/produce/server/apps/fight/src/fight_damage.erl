%%%===================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%===================================================================

-module(fight_damage).

-include("attr.hrl").
-include("creep.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("fight.hrl").
-include("pet.hrl").
-include("scene.hrl").
-include("skill.hrl").
-include("enum.hrl").
-include("msgno.hrl").
-include("proto.hrl").

%% API
-export([calc/2]).
-export([calc_fix_damage/1]).
-export([calc_base_damage/3]).

-define(is_pvp(Atker, Defer),
    (?is_role(Atker) andalso ?is_role(Defer)) orelse
    (?is_role(Atker) andalso ?is_robot(Defer)) orelse
    (?is_robot(Atker) andalso ?is_role(Defer))
).

%%%-------------------------------------------------------------------
%%% API Functions
%%%-------------------------------------------------------------------
calc(Fight, Attack=#attack{unit=Unit}) ->
	Damage = case calc_fix_damage(Fight#fight.defer) of
		0 ->
			Atker = calc_attr(Fight#fight.atker, Fight#fight.atk_attr),
			Defer = calc_attr(Fight#fight.defer, Fight#fight.def_attr),
			DmgType = calc_damage_type(Atker, Defer, Attack),
			case DmgType == ?DAMAGE_MISS of
				true  ->
					fight_util:damage(Defer, Unit, DmgType, 0);
				false ->
					DmgVal = calc_damage(Atker, Defer, Attack, DmgType),
					fight_util:damage(Defer, Unit, DmgType, DmgVal)
			end;
		N ->
			fight_util:damage(Fight#fight.defer, Unit, ?DAMAGE_BLOOD, N)
	end,
	conv_damage_type(Damage).

%%%-------------------------------------------------------------------
%%% Internal Functions
%%%-------------------------------------------------------------------
calc_attr(Actor, TmpAttr) ->
	Actor#actor{attr=mod_attr:add(Actor#actor.attr, TmpAttr)}.

%% 是否固定伤害
calc_fix_damage(Defer) ->
	case ?is_creep(Defer) of
		true  ->
			CfgCreep = cfg_creep:find(Defer#actor.id),
			CfgCreep#cfg_creep.injure;
		false ->
			0
	end.

%% 计算伤害类型
calc_damage_type(Atker, Defer, Attack) ->
	#skill{is_hit=IsHit, is_hew=IsHew} = Attack#attack.skill,
	RandNum1 = ut_rand:random(1, ?PER_10000),
	MissProb = case IsHit of
		true  ->
			0;
		false ->
			AbsMiss = ?_attr(Defer#actor.attr, ?ATTR_ABS_MISS),
			case (not IsHew) andalso RandNum1 =< AbsMiss of
				true  -> ?PER_10000;
				false -> calc_miss_prob(Atker, Defer)
			end
	end,
	case RandNum1 =< MissProb of
		true  ->
			?DAMAGE_MISS;
		false ->
			CritProb = calc_crit_prob(Atker, Defer),
			DmgType1 = case RandNum1 =< CritProb+MissProb of
				true  -> ?DAMAGE_CRIT;
				false -> ?DAMAGE_BLOOD
			end,

			RandNum2  = ut_rand:random(1, ?PER_10000),
			HeartProb = calc_heart_prob(Atker, Defer),
			DmgType2  = case RandNum2 =< HeartProb of
				true  ->
					?DAMAGE_HEART;
				false ->
					BlockProb = calc_block_prob(Atker, Defer),
					case RandNum2 =< BlockProb+HeartProb of
						true  -> ?DAMAGE_BLOCK;
						false -> ?DAMAGE_BLOOD
					end
			end,

			case {DmgType1, DmgType2} of
				{?DAMAGE_CRIT, ?DAMAGE_HEART} ->
					?DAMAGE_CRIT_HEART;
				{?DAMAGE_CRIT, ?DAMAGE_BLOCK} ->
					?DAMAGE_CRIT_BLOCK;
				{?DAMAGE_BLOOD, DmgType2} ->
					DmgType2;
				{DmgType1, ?DAMAGE_BLOOD} ->
					DmgType1
			end
	end.


%% 真实闪避几率
calc_miss_prob(Atker, Defer) ->
	Hit     = ?_attr(Atker#actor.attr, ?ATTR_HIT),
	HitPro  = ?_attr(Atker#actor.attr, ?ATTR_HIT_PRO),
	Miss    = ?_attr(Defer#actor.attr, ?ATTR_MISS),
	MissPro = ?_attr(Defer#actor.attr, ?ATTR_MISS_PRO),
	case Hit == 0 andalso Miss == 0 of
		true  ->
			max(0, MissPro-HitPro);
		false ->
			RealMissProb = Miss/(Hit+Miss+5000)*0.15*?PER_10000
				+ MissPro
				- HitPro,
			max(100, RealMissProb)
	end.

%% 真实暴击几率
calc_crit_prob(Atker, Defer) ->
	Crit    = ?_attr(Atker#actor.attr, ?ATTR_CRIT),
	CritPro = ?_attr(Atker#actor.attr, ?ATTR_CRIT_PRO),
	Tough   = ?_attr(Defer#actor.attr, ?ATTR_TOUGH),
	CritRes = ?_attr(Defer#actor.attr, ?ATTR_CRIT_RES),
	case Crit == 0 andalso Tough == 0 of
		true  ->
			max(0, CritPro-CritRes);
		false ->
			RealCritProb = Crit/(Tough*1.5+Crit+2000)*0.22*?PER_10000
				- 400
				+ CritPro
				- CritRes,
			max(100, RealCritProb)
	end.

%% 真实会心几率
calc_heart_prob(Atker, Defer) ->
	HeartPro = ?_attr(Atker#actor.attr, ?ATTR_HEART_PRO),
	HeartRes = ?_attr(Defer#actor.attr, ?ATTR_HEART_RES),
	max(0, HeartPro-HeartRes).

%% 真实格挡几率
calc_block_prob(Atker, Defer) ->
	BlockStr = ?_attr(Atker#actor.attr, ?ATTR_BLOCK_STR),
	BlockPro = ?_attr(Defer#actor.attr, ?ATTR_BLOCK_PRO),
	max(0, BlockPro-BlockStr).

%% 伤害计算
calc_damage(Atker, Defer, Attack, DmgType) ->
	% 基础伤害
	BaseDmg  = calc_base_damage(Atker, Defer, Attack),
	% 技能伤害
	SkillDmg = calc_skill_damage(Atker, Defer, Attack, BaseDmg),
	% 类型伤害
	TypeDmg  = calc_type_damage(Atker, Defer, SkillDmg, DmgType),
	% 最终伤害
	FinalDmg = calc_final_damage(Atker, Defer, TypeDmg),
	% 伤害系数
	DmgCoef  = calc_damage_coef(Atker, Defer, Attack),
	% 状态伤害
	StateDmg = calc_state_damage(Atker, Defer, Attack, DmgType, BaseDmg),
	% 其他伤害
	OtherDmg = calc_other_damage(Atker, Defer, Attack),


	AtkAbsAtt = ?_attr(Atker#actor.attr, ?ATTR_ABS_ATT),

	DefHpMax  = ?_attr(Defer#actor.attr, ?ATTR_HPMAX),

	FinalDmg1 = FinalDmg * DmgCoef + StateDmg + OtherDmg,
	FinalDmg2 = case ut_rand:random(1, ?PER_10000) =< AtkAbsAtt of
		true  -> FinalDmg1 * 2;
		false -> FinalDmg1
	end,
	SceneSt = scene_util:get_state(),
	FinalDmg3 = if
		% 乱斗战场，人打怪
		?is_role(Atker), ?is_creep(Defer),
		SceneSt#scene_st.stype == ?SCENE_STYPE_MELEEWAR ->
			MaxDmg = DefHpMax * ?_per(cfg_game:meleewar_max_damage()),
			min(FinalDmg2, MaxDmg);
		% 夺城战，人打怪
		?is_role(Atker), ?is_siegeboss(Defer),
		SceneSt#scene_st.stype == ?SCENE_STYPE_SIEGEWAR ->
			MaxDmg = DefHpMax * ?_per(cfg_game:siegeboss_max_blood()),
			min(FinalDmg2, MaxDmg);
		true ->
			FinalDmg2
	end,

	% ?debug(
	% 	"SkillID=~w, "
	% 	"BaseDmg=~w, "
	% 	"SkillDmg=~w, "
	% 	"TypeDmg=~w, "
	% 	"FinalDmg=~w, "
	% 	"DmgCoef=~w, "
	% 	"StateDmg=~w, "
	% 	"OtherDmg=~w, "
	% 	"FinalDmg1=~w, "
	% 	"FinalDmg2=~w, "
	% 	"FinalDmg3=~w, ",
	% 	[
	% 		Attack#attack.skill#skill.id,
	% 		BaseDmg,
	% 		SkillDmg,
	% 		TypeDmg,
	% 		FinalDmg,
	% 		DmgCoef,
	% 		StateDmg,
	% 		OtherDmg,
	% 		FinalDmg1,
	% 		FinalDmg2,
	% 		FinalDmg3
	% ]),

	#attack{skill=Skill} = Attack,
	FinalDmg4 = case Skill#skill.group == ?SKILL_GROUP_ANGER of
		true  -> FinalDmg3 * 0.5;
		false -> FinalDmg3
	end,

	FinalDmg5 = case Atker#actor.uid == 180000700000002084 of
		true  -> FinalDmg4 * 0.2;
		false -> FinalDmg4
	end,

	% 伤害
	max(1, round(FinalDmg5)).

%% 基础伤害
calc_base_damage(Atker, Defer, _Attack) ->
	Att      = ?_attr(Atker#actor.attr, ?ATTR_ATT),
	Wreck    = ?_attr(Atker#actor.attr, ?ATTR_WRECK),
	DmgAmp   = ?_attr(Atker#actor.attr, ?ATTR_DMG_AMP),
	ArmorStr = ?_attr(Atker#actor.attr, ?ATTR_ARMOR_STR),

	Def      = ?_attr(Defer#actor.attr, ?ATTR_DEF),
	DmgRed   = ?_attr(Defer#actor.attr, ?ATTR_DMG_RED),
	% 额外伤害
	ExtraDmg = calc_extra_dmg(Atker, Defer),
	% 守护增益
	GuardAmp = calc_guard_amp(Atker, Defer),
	% PvP系数
	PvPCoef  = calc_pvp_coef(Atker, Defer),

	% 基础伤害
	case Wreck >= Def of
		true  ->
			(Att+Wreck-Def+ExtraDmg)
			* (1+?_per(DmgAmp)+0.45*?_per(ArmorStr))
			* (1-?_per(DmgRed))
			* PvPCoef
			* (1-0.9*GuardAmp/(1+GuardAmp));
		false ->
			(Att*(0.5+0.5*max(Wreck,1)/Def)+ExtraDmg)
			* (1+?_per(DmgAmp)+0.45*?_per(ArmorStr))
			* (1-?_per(DmgRed))
			* PvPCoef
			* (1-0.9*GuardAmp/(1+GuardAmp))
	end.

% 额外伤害
calc_extra_dmg(Atker, Defer) ->
	HolyAtt = ?_attr(Atker#actor.attr, ?ATTR_HOLY_ATT),
	HolyDef = ?_attr(Defer#actor.attr, ?ATTR_HOLY_DEF),
	max(0, HolyAtt-HolyDef).

% 守护增益
calc_guard_amp(Atker, Defer) ->
	CritPro  = ?_attr(Atker#actor.attr, ?ATTR_CRIT_PRO),
	HeartPro = ?_attr(Atker#actor.attr, ?ATTR_HEART_PRO),
	CritRes  = ?_attr(Defer#actor.attr, ?ATTR_CRIT_RES),
	HeartRes = ?_attr(Defer#actor.attr, ?ATTR_HEART_RES),
	% 暴击溢出
	CritOver  = max(0, ?_per(CritRes-CritPro)),
	% 会心溢出
	HeartOver = max(0, ?_per(HeartRes-HeartPro)),
	(CritOver+0.5*HeartOver) / (1+CritOver+0.5*HeartOver).

% PvP系数
calc_pvp_coef(Atker, Defer) ->
	case ?is_pvp(Atker, Defer) of
		true  ->
			1 - ?_attrper(Defer#actor.attr, ?ATTR_PVP_RED);
		false ->
			1
	end.

%% 技能伤害
calc_skill_damage(Atker, Defer, Attack, BaseDmg) ->
	#skill{is_hew=IsHew, amp=FixAmp} = Attack#attack.skill,
	SkillAmp = ?_attr(Atker#actor.attr, ?ATTR_SKILL_AMP),
	HewAmp   = ?_attr(Atker#actor.attr, ?ATTR_HEW_AMP),
	SkillRed = ?_attr(Defer#actor.attr, ?ATTR_SKILL_RED),
	case IsHew of
		true  ->
			BaseDmg*?_per(FixAmp+HewAmp);
		false ->
			max(1, BaseDmg*max(0, ?_per(FixAmp+SkillAmp-SkillRed)))
	end.

%% 类型伤害
calc_type_damage(Atker, Defer, SkillDmg, DmgType) ->
	#actor{attr=AtkAttr} = Atker,
	#actor{attr=DefAttr} = Defer,
	Coef = if
		DmgType == ?DAMAGE_CRIT_HEART ->
			type_damage_coef(?DAMAGE_CRIT, AtkAttr, DefAttr)
			* type_damage_coef(?DAMAGE_HEART, AtkAttr, DefAttr);
		DmgType == ?DAMAGE_CRIT_BLOCK ->
			type_damage_coef(?DAMAGE_CRIT, AtkAttr, DefAttr)
			* type_damage_coef(?DAMAGE_BLOCK, AtkAttr, DefAttr);
		true ->
			type_damage_coef(DmgType, AtkAttr, DefAttr)
	end,
	SkillDmg * Coef.

type_damage_coef(?DAMAGE_CRIT, AtkAttr, DefAttr) ->
	max(1.35, ?_per(?_attr(AtkAttr,?ATTR_CRIT_DMG)-?_attr(DefAttr,?ATTR_CRIT_RED)));
type_damage_coef(?DAMAGE_HEART, AtkAttr, DefAttr) ->
	max(1.30, ?_per(?_attr(AtkAttr,?ATTR_HEART_DMG)-?_attr(DefAttr,?ATTR_HEART_RED)));
type_damage_coef(?DAMAGE_BLOCK, _AtkAttr, DefAttr) ->
	0.66 - ?_attrper(DefAttr,?ATTR_BLOCK_RED);
type_damage_coef(_DmgType, _AtkAttr, _DefAttr) ->
	1.

%% 最终伤害
calc_final_damage(Atker, Defer, TypeDmg) ->
	RandDmg = TypeDmg * ?_per(ut_rand:random(9000, 11000)),
	if
		?is_pvp(Atker, Defer) ->
			RandDmg * 0.5;
		?is_role(Atker), ?is_creep(Defer) ->
			CreepAmp = ?_attr(Atker#actor.attr, ?ATTR_CREEP_AMP),
			BossAmp  = ?_attr(Atker#actor.attr, ?ATTR_BOSS_AMP),
			case ?is_boss(Defer) of
				true  ->
					RandDmg * (1+?_per(CreepAmp)+?_per(BossAmp));
				false ->
					RandDmg * (1+?_per(CreepAmp))
			end;
		true ->
			RandDmg
	end.

%% 伤害系数
calc_damage_coef(_Atker, _Defer, Attack = #attack{unit=?ATTACK_UNIT_PET}) ->
	case proplists:get_value(pet, Attack#attack.opts) of
		?nil -> 0;
		Pet  -> ?_per((cfg_pet:find(Pet#p_item.id))#cfg_pet.atk * 2)
	end;
calc_damage_coef(Atker, Defer, Attack) ->
	#actor{level=AtkLv, power=AtkPower, team=AtkTeam, rarity=AtkRare} = Atker,
	#actor{level=DefLv, power=DefPower, team=DefTeam, rarity=DefRare} = Defer,
	if
		% 机甲试练,人打怪
		Atker#actor.scene == 150701, ?is_role(Atker), ?is_creep(Defer) ->
			#scene_st{dunge=DungeID} = scene_util:get_state(),
			#cfg_dunge{power=RecPower} = cfg_dunge:find(DungeID),
			TeamPower = case AtkTeam > 0 of
				true  -> calc_team_power(AtkTeam);
				false -> AtkPower
			end,
			DiffPower = (TeamPower - RecPower) / RecPower,
			?_per(cfg_power_suppress:role_2_creep(DefRare, DiffPower));
		% 机甲试练,怪打人
		Atker#actor.scene == 150701, ?is_creep(Atker), ?is_role(Defer) ->
			#scene_st{dunge=DungeID} = scene_util:get_state(),
			#cfg_dunge{power=RecPower} = cfg_dunge:find(DungeID),
			TeamPower = case DefTeam > 0 of
				true  -> calc_team_power(DefTeam);
				false -> DefPower
			end,
			DiffPower = (TeamPower - RecPower) / RecPower,
			?_per(cfg_power_suppress:creep_2_role(AtkRare, DiffPower));
		% 人打人，副目标伤害*30%
		?is_pvp(Atker, Defer) ->
			?_if(Defer#actor.uid == Attack#attack.major, 1, 0.3);
		% 人打怪，等级压制
		?is_role(Atker), ?is_creep(Defer) ->
			?_per(cfg_level_suppress:role_2_creep(DefRare, DefLv-AtkLv));
		% 怪打人，等级压制
		?is_creep(Atker), ?is_role(Defer) ->
			?_per(cfg_level_suppress:creep_2_role(AtkRare, AtkLv-DefLv));
		true ->
			1
	end.

calc_team_power(TeamID) ->
	MembIDs = scene_team:get_membs(TeamID),
	Members = [scene_actor:get_actor(MembID) || MembID <- MembIDs],
	lists:sum([Actor#actor.power || Actor <- Members]).

conv_damage_type(Damage) when Damage#damage.type == ?DAMAGE_CRIT_BLOCK ->
	Damage#damage{type=?DAMAGE_CRIT};
conv_damage_type(Damage) when Damage#damage.type == ?DAMAGE_CRIT_HEART ->
	Damage#damage{type=?DAMAGE_CRIT};
conv_damage_type(Damage) ->
	Damage.

calc_state_damage(Atker, Defer, Attack, DmgType, BaseDmg) when ?is_silent(Defer#actor.state) ->
	#skill{effect=Effects} = Attack#attack.skill,
	case lists:keyfind(silent_damage, 1, Effects) of
		false ->
			0;
		{silent_damage, defer, Coef} ->
			#actor{attr=AtkAttr} = Atker,
			#actor{attr=DefAttr, buffs=DefBuffs} = Defer,
			BuffList = maps:values(DefBuffs),
			case lists:keymember(?BUFF_EFFECT_SILENT, #p_buff.eff, BuffList) of
				false ->
					0;
				true when DmgType == ?DAMAGE_HEART ->
					BaseDmg
					* ?_per(Coef)
					* type_damage_coef(?DAMAGE_HEART, AtkAttr, DefAttr);
				true when DmgType == ?DAMAGE_BLOCK ->
					BaseDmg
					* ?_per(Coef)
					/ type_damage_coef(?DAMAGE_BLOCK, AtkAttr, DefAttr);
				true ->
					BaseDmg * ?_per(Coef)
			end
	end;
calc_state_damage(_Atker, _Defer, _Attack, _DmgType, _BaseDmg) ->
	0.

calc_other_damage(_Atker, _Defer, Attack = #attack{unit=?ATTACK_UNIT_PET}) ->
	case proplists:get_value(pet, Attack#attack.opts) of
		?nil -> 0;
		Pet  -> ?_attr((Pet#p_item.pet)#p_pet.base, ?ATTR_ATT)
	end;
calc_other_damage(_Atker, _Defer, _Attack) ->
	0.
