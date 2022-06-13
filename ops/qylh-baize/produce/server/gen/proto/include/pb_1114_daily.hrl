%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.5.1

-ifndef(pb_1114_daily).
-define(pb_1114_daily, true).

-define(pb_1114_daily_gpb_version, "4.5.1").

-ifndef('M_DAILY_INFO_TOS_PB_H').
-define('M_DAILY_INFO_TOS_PB_H', true).
-record(m_daily_info_tos,
        {
        }).
-endif.

-ifndef('M_DAILY_INFO_TOC_PB_H').
-define('M_DAILY_INFO_TOC_PB_H', true).
-record(m_daily_info_toc,
        {list = []              :: [pb_1114_daily:p_daily()] | undefined, % = 1
         rewarded = []          :: [integer()] | undefined, % = 2, 32 bits
         total                  :: integer()        % = 3, 32 bits
        }).
-endif.

-ifndef('M_DAILY_UPDATE_TOC_PB_H').
-define('M_DAILY_UPDATE_TOC_PB_H', true).
-record(m_daily_update_toc,
        {daily                  :: pb_1114_daily:p_daily(), % = 1
         total                  :: integer()        % = 2, 32 bits
        }).
-endif.

-ifndef('M_DAILY_REWARD_TOS_PB_H').
-define('M_DAILY_REWARD_TOS_PB_H', true).
-record(m_daily_reward_tos,
        {id                     :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_DAILY_REWARD_TOC_PB_H').
-define('M_DAILY_REWARD_TOC_PB_H', true).
-record(m_daily_reward_toc,
        {id                     :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_DAILY_ILLUSION_TOS_PB_H').
-define('M_DAILY_ILLUSION_TOS_PB_H', true).
-record(m_daily_illusion_tos,
        {
        }).
-endif.

-ifndef('M_DAILY_ILLUSION_TOC_PB_H').
-define('M_DAILY_ILLUSION_TOC_PB_H', true).
-record(m_daily_illusion_toc,
        {level                  :: integer(),       % = 1, 32 bits
         exp                    :: integer(),       % = 2, 32 bits
         show_id                :: integer(),       % = 3, 32 bits
         show                   :: boolean() | 0 | 1 % = 4
        }).
-endif.

-ifndef('M_DAILY_ILLUSION_UPGRADE_TOS_PB_H').
-define('M_DAILY_ILLUSION_UPGRADE_TOS_PB_H', true).
-record(m_daily_illusion_upgrade_tos,
        {
        }).
-endif.

-ifndef('M_DAILY_ILLUSION_UPGRADE_TOC_PB_H').
-define('M_DAILY_ILLUSION_UPGRADE_TOC_PB_H', true).
-record(m_daily_illusion_upgrade_toc,
        {level                  :: integer(),       % = 1, 32 bits
         exp                    :: integer(),       % = 2, 32 bits
         show_id                :: integer()        % = 3, 32 bits
        }).
-endif.

-ifndef('M_DAILY_ILLUSION_SHOW_TOS_PB_H').
-define('M_DAILY_ILLUSION_SHOW_TOS_PB_H', true).
-record(m_daily_illusion_show_tos,
        {show                   :: boolean() | 0 | 1 % = 1
        }).
-endif.

-ifndef('M_DAILY_ILLUSION_SHOW_TOC_PB_H').
-define('M_DAILY_ILLUSION_SHOW_TOC_PB_H', true).
-record(m_daily_illusion_show_toc,
        {
        }).
-endif.

-ifndef('M_DAILY_ILLUSION_SELECT_TOS_PB_H').
-define('M_DAILY_ILLUSION_SELECT_TOS_PB_H', true).
-record(m_daily_illusion_select_tos,
        {show_id                :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_DAILY_ILLUSION_SELECT_TOC_PB_H').
-define('M_DAILY_ILLUSION_SELECT_TOC_PB_H', true).
-record(m_daily_illusion_select_toc,
        {show_id                :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('P_DAILY_PB_H').
-define('P_DAILY_PB_H', true).
-record(p_daily,
        {id                     :: integer(),       % = 1, 32 bits
         progress               :: integer()        % = 2, 32 bits
        }).
-endif.

-endif.
