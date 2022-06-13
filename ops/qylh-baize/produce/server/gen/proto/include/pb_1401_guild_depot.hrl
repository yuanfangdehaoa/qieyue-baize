%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.5.1

-ifndef(pb_1401_guild_depot).
-define(pb_1401_guild_depot, true).

-define(pb_1401_guild_depot_gpb_version, "4.5.1").

-ifndef('M_GUILD_DEPOT_INFO_TOS_PB_H').
-define('M_GUILD_DEPOT_INFO_TOS_PB_H', true).
-record(m_guild_depot_info_tos,
        {
        }).
-endif.

-ifndef('M_GUILD_DEPOT_INFO_TOC_PB_H').
-define('M_GUILD_DEPOT_INFO_TOC_PB_H', true).
-record(m_guild_depot_info_toc,
        {score                  :: integer(),       % = 1, 32 bits
         items = []             :: [pb_1401_guild_depot:p_item_base()] | undefined, % = 2
         logs = []              :: [pb_1401_guild_depot:p_donate_log()] | undefined % = 3
        }).
-endif.

-ifndef('M_GUILD_DEPOT_DETAIL_TOS_PB_H').
-define('M_GUILD_DEPOT_DETAIL_TOS_PB_H', true).
-record(m_guild_depot_detail_tos,
        {uid                    :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_GUILD_DEPOT_DETAIL_TOC_PB_H').
-define('M_GUILD_DEPOT_DETAIL_TOC_PB_H', true).
-record(m_guild_depot_detail_toc,
        {item                   :: pb_1401_guild_depot:p_item() % = 1
        }).
-endif.

-ifndef('M_GUILD_DEPOT_DONATE_TOS_PB_H').
-define('M_GUILD_DEPOT_DONATE_TOS_PB_H', true).
-record(m_guild_depot_donate_tos,
        {uid                    :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_GUILD_DEPOT_DONATE_TOC_PB_H').
-define('M_GUILD_DEPOT_DONATE_TOC_PB_H', true).
-record(m_guild_depot_donate_toc,
        {role_id                :: non_neg_integer(), % = 1, 32 bits
         role_name              :: iolist(),        % = 2
         item                   :: pb_1401_guild_depot:p_item(), % = 3
         score                  :: integer(),       % = 4, 32 bits
         time                   :: integer()        % = 5, 32 bits
        }).
-endif.

-ifndef('M_GUILD_DEPOT_EXCH_TOS_PB_H').
-define('M_GUILD_DEPOT_EXCH_TOS_PB_H', true).
-record(m_guild_depot_exch_tos,
        {uid                    :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_GUILD_DEPOT_EXCH_TOC_PB_H').
-define('M_GUILD_DEPOT_EXCH_TOC_PB_H', true).
-record(m_guild_depot_exch_toc,
        {role_id                :: non_neg_integer(), % = 1, 32 bits
         role_name              :: iolist(),        % = 2
         item                   :: pb_1401_guild_depot:p_item(), % = 3
         score                  :: integer(),       % = 4, 32 bits
         time                   :: integer()        % = 5, 32 bits
        }).
-endif.

-ifndef('M_GUILD_DEPOT_BUY_TOS_PB_H').
-define('M_GUILD_DEPOT_BUY_TOS_PB_H', true).
-record(m_guild_depot_buy_tos,
        {item_id                :: integer(),       % = 1, 32 bits
         num                    :: integer()        % = 2, 32 bits
        }).
-endif.

-ifndef('M_GUILD_DEPOT_BUY_TOC_PB_H').
-define('M_GUILD_DEPOT_BUY_TOC_PB_H', true).
-record(m_guild_depot_buy_toc,
        {role_id                :: non_neg_integer(), % = 1, 32 bits
         role_name              :: iolist(),        % = 2
         item                   :: pb_1401_guild_depot:p_item(), % = 3
         score                  :: integer(),       % = 4, 32 bits
         time                   :: integer()        % = 5, 32 bits
        }).
-endif.

-ifndef('M_GUILD_DEPOT_DESTROY_TOS_PB_H').
-define('M_GUILD_DEPOT_DESTROY_TOS_PB_H', true).
-record(m_guild_depot_destroy_tos,
        {uids = []              :: [integer()] | undefined % = 1, 32 bits
        }).
-endif.

-ifndef('M_GUILD_DEPOT_DESTROY_TOC_PB_H').
-define('M_GUILD_DEPOT_DESTROY_TOC_PB_H', true).
-record(m_guild_depot_destroy_toc,
        {uids = []              :: [integer()] | undefined % = 1, 32 bits
        }).
-endif.

-ifndef('P_DONATE_LOG_PB_H').
-define('P_DONATE_LOG_PB_H', true).
-record(p_donate_log,
        {type                   :: integer(),       % = 1, 32 bits
         role_id                :: non_neg_integer(), % = 2, 32 bits
         role_name              :: iolist(),        % = 3
         item                   :: pb_1401_guild_depot:p_item(), % = 4
         score                  :: integer(),       % = 5, 32 bits
         time                   :: integer()        % = 6, 32 bits
        }).
-endif.

-ifndef('P_ROLE_BASE_PB_H').
-define('P_ROLE_BASE_PB_H', true).
-record(p_role_base,
        {id                     :: non_neg_integer(), % = 1, 32 bits
         name                   :: iolist(),        % = 2
         career                 :: integer(),       % = 3, 32 bits
         gender                 :: integer(),       % = 4, 32 bits
         level                  :: integer(),       % = 5, 32 bits
         viplv                  :: integer(),       % = 6, 32 bits
         power                  :: integer(),       % = 7, 32 bits
         figure = #{}           :: #{iolist() := pb_1401_guild_depot:p_aspect()} | undefined, % = 8
         guild                  :: non_neg_integer(), % = 9, 32 bits
         gname                  :: iolist(),        % = 10
         charm                  :: integer(),       % = 11, 32 bits
         wake                   :: integer(),       % = 12, 32 bits
         gpost                  :: integer(),       % = 13, 32 bits
         marry                  :: integer(),       % = 14, 32 bits
         mname                  :: iolist(),        % = 15
         mtype                  :: integer(),       % = 16, 32 bits
         icon                   :: pb_1401_guild_depot:p_icon() | undefined, % = 17
         suid                   :: integer(),       % = 18, 32 bits
         zoneid                 :: integer(),       % = 19, 32 bits
         team                   :: non_neg_integer() % = 20, 32 bits
        }).
-endif.

-ifndef('P_ASPECT_PB_H').
-define('P_ASPECT_PB_H', true).
-record(p_aspect,
        {model                  :: integer() | undefined, % = 1, 32 bits
         skin                   :: integer() | undefined, % = 2, 32 bits
         show                   :: boolean() | 0 | 1 | undefined % = 3
        }).
-endif.

-ifndef('P_ATTR_PB_H').
-define('P_ATTR_PB_H', true).
-record(p_attr,
        {hp = 0                 :: integer() | undefined, % = 1, 32 bits
         hpmax = 0              :: integer() | undefined, % = 2, 32 bits
         speed = 0              :: integer() | undefined, % = 3, 32 bits
         att = 0                :: integer() | undefined, % = 4, 32 bits
         def = 0                :: integer() | undefined, % = 5, 32 bits
         wreck = 0              :: integer() | undefined, % = 6, 32 bits
         hit = 0                :: integer() | undefined, % = 7, 32 bits
         miss = 0               :: integer() | undefined, % = 8, 32 bits
         crit = 0               :: integer() | undefined, % = 9, 32 bits
         tough = 0              :: integer() | undefined, % = 10, 32 bits
         holy_att = 0           :: integer() | undefined, % = 11, 32 bits
         holy_def = 0           :: integer() | undefined, % = 12, 32 bits
         abs_att = 0            :: integer() | undefined, % = 13, 32 bits
         abs_miss = 0           :: integer() | undefined, % = 14, 32 bits
         dmg_amp = 0            :: integer() | undefined, % = 15, 32 bits
         dmg_red = 0            :: integer() | undefined, % = 16, 32 bits
         hit_pro = 0            :: integer() | undefined, % = 17, 32 bits
         miss_pro = 0           :: integer() | undefined, % = 18, 32 bits
         armor_pro = 0          :: integer() | undefined, % = 19, 32 bits
         armor_str = 0          :: integer() | undefined, % = 20, 32 bits
         block_pro = 0          :: integer() | undefined, % = 21, 32 bits
         block_str = 0          :: integer() | undefined, % = 22, 32 bits
         crit_pro = 0           :: integer() | undefined, % = 23, 32 bits
         crit_res = 0           :: integer() | undefined, % = 24, 32 bits
         heart_pro = 0          :: integer() | undefined, % = 25, 32 bits
         heart_res = 0          :: integer() | undefined, % = 26, 32 bits
         crit_dmg = 0           :: integer() | undefined, % = 27, 32 bits
         crit_red = 0           :: integer() | undefined, % = 28, 32 bits
         heart_dmg = 0          :: integer() | undefined, % = 29, 32 bits
         heart_red = 0          :: integer() | undefined, % = 30, 32 bits
         skill_amp = 0          :: integer() | undefined, % = 31, 32 bits
         skill_red = 0          :: integer() | undefined, % = 32, 32 bits
         thump_pro = 0          :: integer() | undefined, % = 33, 32 bits
         weak_pro = 0           :: integer() | undefined, % = 34, 32 bits
         skill_att_power = 0    :: integer() | undefined, % = 35, 32 bits
         skill_def_power = 0    :: integer() | undefined, % = 36, 32 bits
         hew_amp = 0            :: integer() | undefined, % = 37, 32 bits
         block_red = 0          :: integer() | undefined, % = 38, 32 bits
         boss_amp = 0           :: integer() | undefined, % = 39, 32 bits
         creep_amp = 0          :: integer() | undefined, % = 40, 32 bits
         pvp_red = 0            :: integer() | undefined, % = 41, 32 bits
         pvp_armor_pro = 0      :: integer() | undefined, % = 42, 32 bits
         pvp_armor_str = 0      :: integer() | undefined, % = 43, 32 bits
         exp_per = 0            :: integer() | undefined, % = 44, 32 bits
         gold_drop = 0          :: integer() | undefined, % = 45, 32 bits
         item_drop = 0          :: integer() | undefined, % = 46, 32 bits
         equip_def = 0          :: integer() | undefined, % = 47, 32 bits
         equip_hpmax = 0        :: integer() | undefined, % = 48, 32 bits
         equip_att = 0          :: integer() | undefined, % = 49, 32 bits
         power = 0              :: integer() | undefined, % = 50, 32 bits
         all_gp = 0             :: integer() | undefined, % = 51, 32 bits
         hpmax_gp = 0           :: integer() | undefined, % = 52, 32 bits
         att_gp = 0             :: integer() | undefined, % = 53, 32 bits
         def_gp = 0             :: integer() | undefined, % = 54, 32 bits
         wreck_gp = 0           :: integer() | undefined, % = 55, 32 bits
         hit_gp = 0             :: integer() | undefined, % = 56, 32 bits
         miss_gp = 0            :: integer() | undefined, % = 57, 32 bits
         crit_gp = 0            :: integer() | undefined, % = 58, 32 bits
         tough_gp = 0           :: integer() | undefined, % = 59, 32 bits
         holy_att_gp = 0        :: integer() | undefined, % = 60, 32 bits
         holy_def_gp = 0        :: integer() | undefined, % = 61, 32 bits
         hpmax_bp = 0           :: integer() | undefined, % = 62, 32 bits
         att_bp = 0             :: integer() | undefined, % = 63, 32 bits
         def_bp = 0             :: integer() | undefined, % = 64, 32 bits
         wreck_bp = 0           :: integer() | undefined % = 65, 32 bits
        }).
-endif.

-ifndef('P_ITEM_BASE_PB_H').
-define('P_ITEM_BASE_PB_H', true).
-record(p_item_base,
        {uid                    :: integer(),       % = 1, 32 bits
         id                     :: integer(),       % = 2, 32 bits
         num                    :: integer(),       % = 3, 32 bits
         bag                    :: integer(),       % = 4, 32 bits
         bind                   :: boolean() | 0 | 1, % = 5
         etime                  :: integer(),       % = 6, 32 bits
         gender                 :: integer(),       % = 7, 32 bits
         score                  :: integer() | undefined, % = 8, 32 bits
         extra                  :: integer() | undefined, % = 9, 32 bits
         misc = #{}             :: #{iolist() := integer()} | undefined % = 10
        }).
-endif.

-ifndef('P_ITEM_PB_H').
-define('P_ITEM_PB_H', true).
-record(p_item,
        {uid                    :: integer(),       % = 1, 32 bits
         id                     :: integer(),       % = 2, 32 bits
         num                    :: integer(),       % = 3, 32 bits
         bag                    :: integer(),       % = 4, 32 bits
         bind                   :: boolean() | 0 | 1, % = 5
         etime                  :: integer(),       % = 6, 32 bits
         gender                 :: integer(),       % = 7, 32 bits
         score                  :: integer() | undefined, % = 8, 32 bits
         equip                  :: pb_1401_guild_depot:p_equip() | undefined, % = 9
         pet                    :: pb_1401_guild_depot:p_pet() | undefined, % = 10
         extra                  :: integer() | undefined % = 11, 32 bits
        }).
-endif.

-ifndef('P_EQUIP_PB_H').
-define('P_EQUIP_PB_H', true).
-record(p_equip,
        {base                   :: pb_1401_guild_depot:p_attr(), % = 1
         rare1                  :: pb_1401_guild_depot:p_attr() | undefined, % = 2
         rare2                  :: pb_1401_guild_depot:p_attr() | undefined, % = 3
         rare3                  :: pb_1401_guild_depot:p_attr() | undefined, % = 4
         marriage               :: pb_1401_guild_depot:p_marriage() | undefined, % = 5
         stren_phase            :: integer(),       % = 6, 32 bits
         stren_lv               :: integer(),       % = 7, 32 bits
         stones = #{}           :: #{integer() := integer()} | undefined, % = 8
         power                  :: integer(),       % = 9, 32 bits
         cast                   :: integer() | undefined, % = 10, 32 bits
         refine = []            :: [pb_1401_guild_depot:p_refine()] | undefined, % = 11
         suite = #{}            :: #{integer() := integer()} | undefined, % = 12
         combine = []           :: [pb_1401_guild_depot:p_item()] | undefined % = 13
        }).
-endif.

-ifndef('P_PET_PB_H').
-define('P_PET_PB_H', true).
-record(p_pet,
        {base                   :: pb_1401_guild_depot:p_attr(), % = 1
         rare1                  :: pb_1401_guild_depot:p_attr() | undefined, % = 2
         rare2                  :: pb_1401_guild_depot:p_attr() | undefined, % = 3
         rare3                  :: pb_1401_guild_depot:p_attr() | undefined, % = 4
         cross                  :: integer(),       % = 5, 32 bits
         strong = #{}           :: #{integer() := integer()} | undefined, % = 6
         power                  :: integer()        % = 7, 32 bits
        }).
-endif.

-ifndef('P_MARRIAGE_PB_H').
-define('P_MARRIAGE_PB_H', true).
-record(p_marriage,
        {husband_id             :: non_neg_integer() | undefined, % = 1, 32 bits
         husband                :: iolist() | undefined, % = 2
         wife_id                :: non_neg_integer() | undefined, % = 3, 32 bits
         wife                   :: iolist() | undefined, % = 4
         rare                   :: pb_1401_guild_depot:p_attr() | undefined % = 5
        }).
-endif.

-ifndef('P_REFINE_PB_H').
-define('P_REFINE_PB_H', true).
-record(p_refine,
        {attr                   :: integer(),       % = 1, 32 bits
         value                  :: integer(),       % = 2, 32 bits
         min                    :: integer(),       % = 3, 32 bits
         max                    :: integer(),       % = 4, 32 bits
         color                  :: integer()        % = 5, 32 bits
        }).
-endif.

-ifndef('P_ACTOR_PB_H').
-define('P_ACTOR_PB_H', true).
-record(p_actor,
        {uid                    :: non_neg_integer(), % = 1, 32 bits
         name                   :: iolist(),        % = 2
         type                   :: integer(),       % = 3, 32 bits
         coord                  :: pb_1401_guild_depot:p_coord(), % = 4
         state                  :: integer(),       % = 5, 32 bits
         stargs = #{}           :: #{integer() := iolist()} | undefined, % = 6
         role                   :: pb_1401_guild_depot:p_role() | undefined, % = 7
         creep                  :: pb_1401_guild_depot:p_creep() | undefined, % = 8
         drop                   :: pb_1401_guild_depot:p_drop() | undefined % = 9
        }).
-endif.

-ifndef('P_ROLE_PB_H').
-define('P_ROLE_PB_H', true).
-record(p_role,
        {career                 :: integer(),       % = 1, 32 bits
         gender                 :: integer(),       % = 2, 32 bits
         level                  :: integer(),       % = 3, 32 bits
         viplv                  :: integer(),       % = 4, 32 bits
         figure = #{}           :: #{iolist() := pb_1401_guild_depot:p_aspect()} | undefined, % = 5
         suid                   :: integer(),       % = 6, 32 bits
         guild                  :: non_neg_integer(), % = 7, 32 bits
         gname                  :: iolist(),        % = 8
         hp                     :: integer(),       % = 9, 32 bits
         hpmax                  :: integer(),       % = 10, 32 bits
         speed                  :: integer(),       % = 11, 32 bits
         buffs = []             :: [pb_1401_guild_depot:p_buff()] | undefined, % = 12
         power                  :: integer(),       % = 13, 32 bits
         pkmode                 :: integer(),       % = 14, 32 bits
         crime                  :: integer(),       % = 15, 32 bits
         dir                    :: float() | integer() | infinity | '-infinity' | nan, % = 16
         dest                   :: pb_1401_guild_depot:p_coord(), % = 17
         group                  :: integer(),       % = 18, 32 bits
         team                   :: non_neg_integer(), % = 19, 32 bits
         marry                  :: integer(),       % = 20, 32 bits
         mname                  :: iolist(),        % = 21
         mtype                  :: integer(),       % = 22, 32 bits
         zoneid                 :: integer(),       % = 23, 32 bits
         ext = #{}              :: #{iolist() := integer()} | undefined, % = 24
         icon                   :: pb_1401_guild_depot:p_icon() | undefined % = 25
        }).
-endif.

-ifndef('P_CREEP_PB_H').
-define('P_CREEP_PB_H', true).
-record(p_creep,
        {id                     :: integer(),       % = 1, 32 bits
         owner                  :: non_neg_integer(), % = 2, 32 bits
         hp                     :: integer(),       % = 3, 32 bits
         hpmax                  :: integer(),       % = 4, 32 bits
         speed                  :: integer(),       % = 5, 32 bits
         buffs = []             :: [pb_1401_guild_depot:p_buff()] | undefined, % = 6
         dir                    :: integer(),       % = 7, 32 bits
         dest                   :: pb_1401_guild_depot:p_coord(), % = 8
         group                  :: integer(),       % = 9, 32 bits
         level                  :: integer(),       % = 10, 32 bits
         ext = #{}              :: #{iolist() := non_neg_integer()} | undefined % = 11
        }).
-endif.

-ifndef('P_NPC_PB_H').
-define('P_NPC_PB_H', true).
-record(p_npc,
        {id                     :: integer(),       % = 1, 32 bits
         coord                  :: pb_1401_guild_depot:p_coord() % = 2
        }).
-endif.

-ifndef('P_DROP_PB_H').
-define('P_DROP_PB_H', true).
-record(p_drop,
        {id                     :: integer(),       % = 1, 32 bits
         num                    :: integer(),       % = 2, 32 bits
         mode                   :: integer() | undefined, % = 3, 32 bits
         from                   :: non_neg_integer() | undefined, % = 4, 32 bits
         coord                  :: pb_1401_guild_depot:p_coord() | undefined, % = 5
         belong = []            :: [non_neg_integer()] | undefined, % = 6, 32 bits
         unlock                 :: integer() | undefined % = 7, 32 bits
        }).
-endif.

-ifndef('P_BUFF_PB_H').
-define('P_BUFF_PB_H', true).
-record(p_buff,
        {id                     :: integer(),       % = 1, 32 bits
         type                   :: integer(),       % = 2, 32 bits
         origin                 :: integer(),       % = 3, 32 bits
         value                  :: integer(),       % = 4, 32 bits
         eff                    :: integer(),       % = 5, 32 bits
         etime                  :: integer(),       % = 6, 32 bits
         group                  :: integer(),       % = 7, 32 bits
         attrs = []             :: [integer()] | undefined % = 8, 32 bits
        }).
-endif.

-ifndef('P_COORD_PB_H').
-define('P_COORD_PB_H', true).
-record(p_coord,
        {x                      :: float() | integer() | infinity | '-infinity' | nan, % = 1
         y                      :: float() | integer() | infinity | '-infinity' | nan % = 2
        }).
-endif.

-ifndef('P_ICON_PB_H').
-define('P_ICON_PB_H', true).
-record(p_icon,
        {pic                    :: iolist(),        % = 1
         md5                    :: iolist(),        % = 2
         frame                  :: integer(),       % = 3, 32 bits
         bubble                 :: integer()        % = 4, 32 bits
        }).
-endif.

-ifndef('P_RANKING_PB_H').
-define('P_RANKING_PB_H', true).
-record(p_ranking,
        {base                   :: pb_1401_guild_depot:p_role_base() | undefined, % = 1
         rank                   :: integer(),       % = 2, 32 bits
         sort                   :: integer(),       % = 3, 32 bits
         data = #{}             :: #{iolist() := integer()} | undefined % = 4
        }).
-endif.

-ifndef('P_DROPPED_PB_H').
-define('P_DROPPED_PB_H', true).
-record(p_dropped,
        {time                   :: integer(),       % = 1, 32 bits
         scene                  :: integer(),       % = 2, 32 bits
         picker_id              :: non_neg_integer(), % = 3, 32 bits
         picker_name            :: iolist(),        % = 4
         boss                   :: iolist(),        % = 5
         item_id                :: integer(),       % = 6, 32 bits
         cache_id               :: integer()        % = 7, 32 bits
        }).
-endif.

-endif.
