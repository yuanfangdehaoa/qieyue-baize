%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.5.1

-ifndef(pb_1115_weekly).
-define(pb_1115_weekly, true).

-define(pb_1115_weekly_gpb_version, "4.5.1").

-ifndef('M_WEEKLY_INFO_TOS_PB_H').
-define('M_WEEKLY_INFO_TOS_PB_H', true).
-record(m_weekly_info_tos,
        {
        }).
-endif.

-ifndef('M_WEEKLY_INFO_TOC_PB_H').
-define('M_WEEKLY_INFO_TOC_PB_H', true).
-record(m_weekly_info_toc,
        {list = []              :: [pb_1115_weekly:p_weekly()] | undefined, % = 1
         rewarded = []          :: [integer()] | undefined, % = 2, 32 bits
         total                  :: integer()        % = 3, 32 bits
        }).
-endif.

-ifndef('M_WEEKLY_UPDATE_TOC_PB_H').
-define('M_WEEKLY_UPDATE_TOC_PB_H', true).
-record(m_weekly_update_toc,
        {weekly                 :: pb_1115_weekly:p_weekly() % = 1
        }).
-endif.

-ifndef('M_WEEKLY_FINISH_TOS_PB_H').
-define('M_WEEKLY_FINISH_TOS_PB_H', true).
-record(m_weekly_finish_tos,
        {id                     :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_WEEKLY_FINISH_TOC_PB_H').
-define('M_WEEKLY_FINISH_TOC_PB_H', true).
-record(m_weekly_finish_toc,
        {weekly                 :: pb_1115_weekly:p_weekly(), % = 1
         total                  :: integer()        % = 2, 32 bits
        }).
-endif.

-ifndef('M_WEEKLY_REWARD_TOS_PB_H').
-define('M_WEEKLY_REWARD_TOS_PB_H', true).
-record(m_weekly_reward_tos,
        {id                     :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_WEEKLY_REWARD_TOC_PB_H').
-define('M_WEEKLY_REWARD_TOC_PB_H', true).
-record(m_weekly_reward_toc,
        {id                     :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('P_WEEKLY_PB_H').
-define('P_WEEKLY_PB_H', true).
-record(p_weekly,
        {id                     :: integer(),       % = 1, 32 bits
         progress               :: integer(),       % = 2, 32 bits
         rewarded               :: boolean() | 0 | 1 % = 3
        }).
-endif.

-endif.
