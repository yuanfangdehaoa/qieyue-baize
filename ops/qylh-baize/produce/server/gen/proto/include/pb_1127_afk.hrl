%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.5.1

-ifndef(pb_1127_afk).
-define(pb_1127_afk, true).

-define(pb_1127_afk_gpb_version, "4.5.1").

-ifndef('M_AFK_INFO_TOS_PB_H').
-define('M_AFK_INFO_TOS_PB_H', true).
-record(m_afk_info_tos,
        {
        }).
-endif.

-ifndef('M_AFK_INFO_TOC_PB_H').
-define('M_AFK_INFO_TOC_PB_H', true).
-record(m_afk_info_toc,
        {time                   :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_AFK_SETTLE_TOC_PB_H').
-define('M_AFK_SETTLE_TOC_PB_H', true).
-record(m_afk_settle_toc,
        {afk_time               :: integer(),       % = 1, 32 bits
         rewards = #{}          :: #{integer() := integer()} | undefined, % = 2
         smelt_old              :: integer(),       % = 3, 32 bits
         smelt_new              :: integer(),       % = 4, 32 bits
         smelts = #{}           :: #{integer() := integer()} | undefined % = 5
        }).
-endif.

-endif.