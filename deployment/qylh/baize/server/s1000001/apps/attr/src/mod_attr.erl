%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(mod_attr).

-include("attr.hrl").
-include("game.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([add/2]).
-export([sum/1]).
-export([del/2]).
-export([rep/3]).
-export([set/2]).
-export([power/1, power/2]).
-export([to_map/1]).
-export([to_list/1]).
-export([p_attr/1]).
-export([calc_dmg_red/1]).
-export([calc_pvp_red/1]).
-export([calc_global_pro/1, calc_global_pro/2]).
-export([calc_part_pro/1, calc_part_pro/2]).
-export([global_pro_attrs/0]).
-export([part_pro_attrs/0]).

-type attrs() :: attrmaps() | [attrlist()].
-type attrmaps() :: #{Code :: integer() => Val :: integer()}.
-type attrlist() :: {Code :: integer(), Val :: integer()}.

-define(_round(Val),
	case Val == ?nil of
		true  -> ?nil;
		false -> round(Val)
	end).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%%-----------------------------------------------
%% @doc 加属性
-spec add(attrs(), attrs()) ->
	attrmaps().
%%-----------------------------------------------
add(OldAttr, AddAttr) ->
	do_op(OldAttr, AddAttr, '+').


%%-----------------------------------------------
%% @doc 属性求和
-spec sum([attrs()]) ->
	attrmaps().
%%-----------------------------------------------
sum(AttrList) ->
	lists:foldl(fun
		(Attr, Acc) ->
			do_op(Acc, Attr, '+')
	end, #{}, AttrList).


%%-----------------------------------------------
%% @doc 减属性
-spec del(attrs(), attrs()) ->
	attrmaps().
%%-----------------------------------------------
del(OldAttr, DelAttr) ->
	do_op(OldAttr, DelAttr, '-').


%%-----------------------------------------------
%% @doc 替换属性
-spec rep(attrs(), attrs(), attrs()) ->
	attrmaps().
%%-----------------------------------------------
rep(OldAttr, DelAttr, RepAttr) ->
	do_op(do_op(OldAttr, DelAttr, '-'), RepAttr, '+').


%%-----------------------------------------------
%% @doc 设置属性
-spec set(attrs(), attrlist()) ->
	attrmaps().
%%-----------------------------------------------
set(OldAttr, SetAttr) ->
	to_map2(OldAttr, SetAttr).


%%-----------------------------------------------
%% @doc 计算战力
-spec power(attrs()) ->
	integer().
%%-----------------------------------------------
power(?nil) ->
	0;
power(Attr) ->
	% 输出侧战力
	Power1 = ?MODULE:power(Attr, damage),
	% 生存侧战力
	Power2 = ?MODULE:power(Attr, survive),
	ut_math:floor(Power1 + Power2).

%% 输出侧战力
power(Attr, damage) ->
	Power = (
		(
			  ?_attr(Attr,?ATTR_ATT) * cfg_attr_type:coef(?ATTR_ATT)
			+ ?_attr(Attr,?ATTR_WRECK) * cfg_attr_type:coef(?ATTR_WRECK)
			+ ?_attr(Attr,?ATTR_HOLY_ATT) * cfg_attr_type:coef(?ATTR_HOLY_ATT)
			+ ?_attr(Attr,?ATTR_HIT) * cfg_attr_type:coef(?ATTR_HIT)
			+ ?_attr(Attr,?ATTR_CRIT) * cfg_attr_type:coef(?ATTR_CRIT)
		)
		* (1 + 0.22 * ?_attrper(Attr,?ATTR_SKILL_AMP))
		+ ?_attr(Attr,?ATTR_SKILL_ATT_POWER)
	)
	* (1 + ?_attrper(Attr,?ATTR_CRIT_PRO) * (?_attrper(Attr,?ATTR_CRIT_DMG) - 1))
	* (
  		  1
  		+ ?_attrper(Attr,?ATTR_HEART_PRO) * (?_attrper(Attr,?ATTR_HEART_DMG) - 1)
  		+ ?_attrper(Attr,?ATTR_BLOCK_STR) * 0.25
  	)
	* (1 + ?_attrper(Attr,?ATTR_DMG_AMP) + ?_attrper(Attr,?ATTR_ARMOR_STR) * 0.45)
	* (1 + ?_attrper(Attr,?ATTR_ABS_ATT)),
	ut_math:floor(Power);
%% 生存侧战力
power(Attr, survive) ->
	Power = (
		(
			  ?_attr(Attr,?ATTR_HPMAX) * cfg_attr_type:coef(?ATTR_HPMAX)
			+ ?_attr(Attr,?ATTR_DEF) * cfg_attr_type:coef(?ATTR_DEF)
			+ ?_attr(Attr,?ATTR_HOLY_DEF) * cfg_attr_type:coef(?ATTR_HOLY_DEF)
			+ ?_attr(Attr,?ATTR_MISS) * cfg_attr_type:coef(?ATTR_MISS)
			+ ?_attr(Attr,?ATTR_TOUGH) * cfg_attr_type:coef(?ATTR_TOUGH)
		)
		* (1 + 0.22 * ?_attrper(Attr,?ATTR_SKILL_RED))
		+ ?_attr(Attr,?ATTR_SKILL_DEF_POWER)
	)
	* (1 + ?_attrper(Attr,?ATTR_CRIT_RES))
	* (1 / (1 - ?_attrper(Attr,?ATTR_DMG_RED)))
	* (1 / (1 - ?_attrper(Attr,?ATTR_MISS_PRO)))
	* (
		  1
		+ ?_attrper(Attr,?ATTR_BLOCK_PRO) * (0.34 + ?_attrper(Attr,?ATTR_BLOCK_RED))
		+ ?_attrper(Attr,?ATTR_HEART_RES) * 0.5
	)
	* (1 / (1 - ?_attrper(Attr,?ATTR_ABS_MISS)))
	* (1 + (?_attrper(Attr,?ATTR_MECHA_SHIELD) * 0.12)),
	% * (1 / (1 - ?_attrper(Attr,?ATTR_ARMOR_PRO)/(1+?_attrper(Attr,?ATTR_ARMOR_PRO)))),
	ut_math:floor(Power).


%%-----------------------------------------------
-spec to_map(attrlist()) ->
	attrmaps().
%%-----------------------------------------------
to_map(Attrs) when is_list(Attrs) ->
	to_map2(#{}, Attrs);
to_map(Attr) when is_map(Attr) ->
	Attr.


%%-----------------------------------------------
%% @doc 将 p_attr{} 转换为属性列表
-spec to_list(attrmaps()) ->
	attrlist().
%%-----------------------------------------------
to_list(Attr) when is_map(Attr) ->
	maps:to_list(Attr);
to_list(Attrs) when is_list(Attrs) ->
	Attrs.


p_attr(Attr) ->
	#p_attr{
		hp              = ?_round(?_attr(Attr,?ATTR_HP,?nil)),
		hpmax           = ?_round(?_attr(Attr,?ATTR_HPMAX,?nil)),
		speed           = ?_round(?_attr(Attr,?ATTR_SPEED,?nil)),
		att             = ?_round(?_attr(Attr,?ATTR_ATT,?nil)),
		def             = ?_round(?_attr(Attr,?ATTR_DEF,?nil)),
		wreck           = ?_round(?_attr(Attr,?ATTR_WRECK,?nil)),
		hit             = ?_round(?_attr(Attr,?ATTR_HIT,?nil)),
		miss            = ?_round(?_attr(Attr,?ATTR_MISS,?nil)),
		crit            = ?_round(?_attr(Attr,?ATTR_CRIT,?nil)),
		tough           = ?_round(?_attr(Attr,?ATTR_TOUGH,?nil)),
		holy_att        = ?_round(?_attr(Attr,?ATTR_HOLY_ATT,?nil)),
		holy_def        = ?_round(?_attr(Attr,?ATTR_HOLY_DEF,?nil)),
		abs_att         = ?_round(?_attr(Attr,?ATTR_ABS_ATT,?nil)),
		abs_miss        = ?_round(?_attr(Attr,?ATTR_ABS_MISS,?nil)),
		dmg_amp         = ?_round(?_attr(Attr,?ATTR_DMG_AMP,?nil)),
		dmg_red         = ?_round(?_attr(Attr,?ATTR_DMG_RED,?nil)),
		hit_pro         = ?_round(?_attr(Attr,?ATTR_HIT_PRO,?nil)),
		miss_pro        = ?_round(?_attr(Attr,?ATTR_MISS_PRO,?nil)),
		armor_pro       = ?_round(?_attr(Attr,?ATTR_ARMOR_PRO,?nil)),
		armor_str       = ?_round(?_attr(Attr,?ATTR_ARMOR_STR,?nil)),
		block_pro       = ?_round(?_attr(Attr,?ATTR_BLOCK_PRO,?nil)),
		block_str       = ?_round(?_attr(Attr,?ATTR_BLOCK_STR,?nil)),
		crit_pro        = ?_round(?_attr(Attr,?ATTR_CRIT_PRO,?nil)),
		crit_res        = ?_round(?_attr(Attr,?ATTR_CRIT_RES,?nil)),
		heart_pro       = ?_round(?_attr(Attr,?ATTR_HEART_PRO,?nil)),
		heart_res       = ?_round(?_attr(Attr,?ATTR_HEART_RES,?nil)),
		crit_dmg        = ?_round(?_attr(Attr,?ATTR_CRIT_DMG,?nil)),
		heart_dmg       = ?_round(?_attr(Attr,?ATTR_HEART_DMG,?nil)),
		skill_amp       = ?_round(?_attr(Attr,?ATTR_SKILL_AMP,?nil)),
		skill_red       = ?_round(?_attr(Attr,?ATTR_SKILL_RED,?nil)),
		thump_pro       = ?_round(?_attr(Attr,?ATTR_THUMP_PRO,?nil)),
		weak_pro        = ?_round(?_attr(Attr,?ATTR_WEAK_PRO,?nil)),
		skill_att_power = ?_round(?_attr(Attr,?ATTR_SKILL_ATT_POWER,?nil)),
		skill_def_power = ?_round(?_attr(Attr,?ATTR_SKILL_DEF_POWER,?nil)),
		exp_per         = ?_round(?_attr(Attr,?ATTR_EXP_PER,?nil)),
		gold_drop       = ?_round(?_attr(Attr,?ATTR_GOLD_DROP,?nil)),
		item_drop       = ?_round(?_attr(Attr,?ATTR_ITEM_DROP,?nil)),
		equip_def       = ?_round(?_attr(Attr,?ATTR_EQUIP_DEF,?nil)),
		equip_hpmax     = ?_round(?_attr(Attr,?ATTR_EQUIP_HPMAX,?nil)),
		equip_att       = ?_round(?_attr(Attr,?ATTR_EQUIP_ATT,?nil)),
		all_gp          = ?_round(?_attr(Attr,?ATTR_ALL_GP,?nil)),
		hpmax_gp        = ?_round(?_attr(Attr,?ATTR_HPMAX_GP,?nil)),
		att_gp          = ?_round(?_attr(Attr,?ATTR_ATT_GP,?nil)),
		def_gp          = ?_round(?_attr(Attr,?ATTR_DEF_GP,?nil)),
		wreck_gp        = ?_round(?_attr(Attr,?ATTR_WRECK_GP,?nil)),
		hit_gp          = ?_round(?_attr(Attr,?ATTR_HIT_GP,?nil)),
		miss_gp         = ?_round(?_attr(Attr,?ATTR_MISS_GP,?nil)),
		crit_gp         = ?_round(?_attr(Attr,?ATTR_CRIT_GP,?nil)),
		tough_gp        = ?_round(?_attr(Attr,?ATTR_TOUGH_GP,?nil)),
		holy_att_gp     = ?_round(?_attr(Attr,?ATTR_HOLY_ATT_GP,?nil)),
		holy_def_gp     = ?_round(?_attr(Attr,?ATTR_HOLY_DEF_GP,?nil)),
		hpmax_bp        = ?_round(?_attr(Attr,?ATTR_HPMAX_BP,?nil)),
		att_bp          = ?_round(?_attr(Attr,?ATTR_ATT_BP,?nil)),
		def_bp          = ?_round(?_attr(Attr,?ATTR_DEF_BP,?nil)),
		wreck_bp        = ?_round(?_attr(Attr,?ATTR_WRECK_BP,?nil))
	}.

calc_dmg_red(Attr) when is_map(Attr) ->
	ArmorPro = ?_attr(Attr, ?ATTR_ARMOR_PRO, 0),
	DmgReds  = ?_attr(Attr, ?ATTR_DMG_RED_S, []),
	ToDmgRed = ?PER_10000 * (?_per(ArmorPro) / (1 + ?_per(ArmorPro))),
	do_calc_dmg_red([ToDmgRed | DmgReds]);
calc_dmg_red(DmgReds) ->
	do_calc_dmg_red(DmgReds).

calc_pvp_red(Attr) when is_map(Attr) ->
	PvPArmorPro = ?_attr(Attr, ?ATTR_PVP_ARMOR_PRO, 0),
	PvPReds  = ?_attr(Attr, ?ATTR_PVP_RED_S, []),
	ToPvPRed = ?PER_10000 * (?_per(PvPArmorPro) / (1 + ?_per(PvPArmorPro))),
	do_calc_pvp_red([ToPvPRed | PvPReds]);
calc_pvp_red(PvPReds) ->
	do_calc_pvp_red(PvPReds).


calc_global_pro(Attr) ->
	calc_global_pro(Attr, 1).

calc_global_pro(Attr0, Init) ->
	Attr = mod_attr:to_map(Attr0),
	Attr#{
		?ATTR_SPEED    => round(?_attr(Attr,?ATTR_SPEED) * (1+?_attrper(Attr,?ATTR_SPEED_GP))),
		?ATTR_HPMAX    => round(calc_gp(Init, Attr, ?ATTR_HPMAX, ?ATTR_HPMAX_GP)),
		?ATTR_ATT      => calc_gp(Init, Attr, ?ATTR_ATT, ?ATTR_ATT_GP),
		?ATTR_DEF      => calc_gp(Init, Attr, ?ATTR_DEF, ?ATTR_DEF_GP),
		?ATTR_WRECK    => calc_gp(Init, Attr, ?ATTR_WRECK, ?ATTR_WRECK_GP),
		?ATTR_HIT      => calc_gp(Init, Attr, ?ATTR_HIT, ?ATTR_HIT_GP),
		?ATTR_MISS     => calc_gp(Init, Attr, ?ATTR_MISS, ?ATTR_MISS_GP),
		?ATTR_CRIT     => calc_gp(Init, Attr, ?ATTR_CRIT, ?ATTR_CRIT_GP),
		?ATTR_TOUGH    => calc_gp(Init, Attr, ?ATTR_TOUGH, ?ATTR_TOUGH_GP),
		?ATTR_HOLY_ATT => calc_gp(Init, Attr, ?ATTR_HOLY_ATT, ?ATTR_HOLY_ATT_GP),
		?ATTR_HOLY_DEF => calc_gp(Init, Attr, ?ATTR_HOLY_DEF, ?ATTR_HOLY_DEF_GP)
	}.

calc_part_pro(Attr) ->
	calc_part_pro(Attr, 1).

calc_part_pro(Attr0, Init) ->
	Attr1 = mod_attr:to_map(Attr0),
	Attr2 = Attr1#{
		?ATTR_HPMAX    => calc_pp(Init, Attr1, ?ATTR_HPMAX, ?ATTR_HPMAX_PP),
		?ATTR_ATT      => calc_pp(Init, Attr1, ?ATTR_ATT, ?ATTR_ATT_PP),
		?ATTR_DEF      => calc_pp(Init, Attr1, ?ATTR_DEF, ?ATTR_DEF_PP),
		?ATTR_WRECK    => calc_pp(Init, Attr1, ?ATTR_WRECK, ?ATTR_WRECK_PP),
		?ATTR_HIT      => calc_pp(Init, Attr1, ?ATTR_HIT, ?ATTR_HIT_PP),
		?ATTR_MISS     => calc_pp(Init, Attr1, ?ATTR_MISS, ?ATTR_MISS_PP),
		?ATTR_CRIT     => calc_pp(Init, Attr1, ?ATTR_CRIT, ?ATTR_CRIT_PP),
		?ATTR_TOUGH    => calc_pp(Init, Attr1, ?ATTR_TOUGH, ?ATTR_TOUGH_PP),
		?ATTR_HOLY_ATT => calc_pp(Init, Attr1, ?ATTR_HOLY_ATT, ?ATTR_HOLY_ATT_PP),
		?ATTR_HOLY_DEF => calc_pp(Init, Attr1, ?ATTR_HOLY_DEF, ?ATTR_HOLY_DEF_PP)
	},
	maps:without(part_pro_attrs(), Attr2).

global_pro_attrs() ->
	[
		?ATTR_ALL_GP,
		?ATTR_SPEED_GP,
		?ATTR_HPMAX_GP,
		?ATTR_ATT_GP,
		?ATTR_DEF_GP,
		?ATTR_WRECK_GP,
		?ATTR_HIT_GP,
		?ATTR_MISS_GP,
		?ATTR_CRIT_GP,
		?ATTR_TOUGH_GP,
		?ATTR_HOLY_ATT_GP,
		?ATTR_HOLY_DEF_GP
	].

part_pro_attrs() ->
	[
		?ATTR_ALL_PP,
		?ATTR_HPMAX_PP,
		?ATTR_ATT_PP,
		?ATTR_DEF_PP,
		?ATTR_WRECK_PP,
		?ATTR_HIT_PP,
		?ATTR_MISS_PP,
		?ATTR_CRIT_PP,
		?ATTR_TOUGH_PP,
		?ATTR_HOLY_ATT_PP,
		?ATTR_HOLY_DEF_PP
	].

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
to_map2(Attr, Attrs) ->
	Attr2 = lists:foldl(fun
		({Code, Val}, Acc) ->
			Val2 = conv(Code, Val),
			maps:put(Code, Val2, Acc)
	end, Attr, Attrs),
	DmgRed = calc_dmg_red(?_attr(Attr2, ?ATTR_DMG_RED_S, [])),
	PvpRed = calc_pvp_red(?_attr(Attr2, ?ATTR_PVP_RED_S, [])),
	Attr3 = maps:put(?ATTR_DMG_RED, DmgRed, Attr2),
	Attr4 = maps:put(?ATTR_PVP_RED, PvpRed, Attr3),
	Attr4.

conv(?ATTR_DMG_RED_S, Val) ->
	[Val];
conv(?ATTR_PVP_RED_S, Val) ->
	[Val];
conv(_Code, Val) ->
	Val.

do_op(Attr1_0, Attr2_0, Op) ->
	Attr1 = to_map(Attr1_0),
	Attr2 = to_map(Attr2_0),
	Codes = maps:keys(maps:merge(Attr1, Attr2)),
	lists:foldl(fun
		(Code, Acc) ->
			Val = if
				Code == ?ATTR_DMG_RED_S, Op == '+' ->
					?_attr(Attr1, Code, []) ++ ?_attr(Attr2, Code, []);
				Code == ?ATTR_DMG_RED_S, Op == '-' ->
					?_attr(Attr1, Code, []) -- ?_attr(Attr2, Code, []);
				Code == ?ATTR_PVP_RED_S, Op == '+' ->
					?_attr(Attr1, Code, []) ++ ?_attr(Attr2, Code, []);
				Code == ?ATTR_PVP_RED_S, Op == '-' ->
					?_attr(Attr1, Code, []) -- ?_attr(Attr2, Code, []);
				Op == '+' ->
					?_attr(Attr1, Code, 0) + ?_attr(Attr2, Code, 0);
				Op == '-' ->
					?_attr(Attr1, Code, 0) - ?_attr(Attr2, Code, 0)
			end,
			maps:put(Code, Val, Acc)
	end, #{}, Codes).


do_calc_dmg_red(DmgReds) ->
	DmgRed = lists:foldl(fun
		(Val, Acc) ->
			Acc * (1 - ?_per(Val))
	end, 1, DmgReds),
	?PER_10000 - DmgRed * ?PER_10000.

do_calc_pvp_red(PvPReds) ->
	PvRed = lists:foldl(fun
		(Val, Acc) ->
			Acc * (1 - ?_per(Val))
	end, 1, PvPReds),
	?PER_10000 - PvRed * ?PER_10000.

calc_gp(Init, Attr, Code, CodeGP) ->
	?_attr(Attr,Code) * (Init + ?_attrper(Attr,?ATTR_ALL_GP) + ?_attrper(Attr,CodeGP)).

calc_pp(Init, Attr, Code, CodePP) ->
	?_attr(Attr,Code) * (Init + ?_attrper(Attr,?ATTR_ALL_PP) + ?_attrper(Attr,CodePP)).
