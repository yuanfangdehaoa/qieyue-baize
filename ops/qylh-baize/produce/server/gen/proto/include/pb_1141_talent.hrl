%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.5.1

-ifndef(pb_1141_talent).
-define(pb_1141_talent, true).

-define(pb_1141_talent_gpb_version, "4.5.1").

-ifndef('M_TALENT_INFO_TOS_PB_H').
-define('M_TALENT_INFO_TOS_PB_H', true).
-record(m_talent_info_tos,
        {
        }).
-endif.

-ifndef('M_TALENT_INFO_TOC_PB_H').
-define('M_TALENT_INFO_TOC_PB_H', true).
-record(m_talent_info_toc,
        {point                  :: integer(),       % = 1, 32 bits
         skills = #{}           :: #{integer() := integer()} | undefined % = 2
        }).
-endif.

-ifndef('M_TALENT_UPGRADE_TOS_PB_H').
-define('M_TALENT_UPGRADE_TOS_PB_H', true).
-record(m_talent_upgrade_tos,
        {id                     :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_TALENT_UPGRADE_TOC_PB_H').
-define('M_TALENT_UPGRADE_TOC_PB_H', true).
-record(m_talent_upgrade_toc,
        {id                     :: integer(),       % = 1, 32 bits
         point                  :: integer()        % = 2, 32 bits
        }).
-endif.

-ifndef('M_TALENT_RESET_TOS_PB_H').
-define('M_TALENT_RESET_TOS_PB_H', true).
-record(m_talent_reset_tos,
        {
        }).
-endif.

-ifndef('M_TALENT_RESET_TOC_PB_H').
-define('M_TALENT_RESET_TOC_PB_H', true).
-record(m_talent_reset_toc,
        {
        }).
-endif.

-ifndef('M_TALENT_POINT_TOC_PB_H').
-define('M_TALENT_POINT_TOC_PB_H', true).
-record(m_talent_point_toc,
        {point                  :: integer()        % = 1, 32 bits
        }).
-endif.

-endif.
