%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.5.1

-ifndef(pb_1130_firstpay).
-define(pb_1130_firstpay, true).

-define(pb_1130_firstpay_gpb_version, "4.5.1").

-ifndef('M_FIRSTPAY_INFO_TOS_PB_H').
-define('M_FIRSTPAY_INFO_TOS_PB_H', true).
-record(m_firstpay_info_tos,
        {
        }).
-endif.

-ifndef('M_FIRSTPAY_INFO_TOC_PB_H').
-define('M_FIRSTPAY_INFO_TOC_PB_H', true).
-record(m_firstpay_info_toc,
        {is_payed               :: boolean() | 0 | 1, % = 1
         day                    :: integer(),       % = 2, 32 bits
         fetch = []             :: [integer()] | undefined % = 3, 32 bits
        }).
-endif.

-ifndef('M_FIRSTPAY_REWARD_TOS_PB_H').
-define('M_FIRSTPAY_REWARD_TOS_PB_H', true).
-record(m_firstpay_reward_tos,
        {day                    :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_FIRSTPAY_REWARD_TOC_PB_H').
-define('M_FIRSTPAY_REWARD_TOC_PB_H', true).
-record(m_firstpay_reward_toc,
        {
        }).
-endif.

-ifndef('M_FIRSTPAY_SUPERINFO_TOS_PB_H').
-define('M_FIRSTPAY_SUPERINFO_TOS_PB_H', true).
-record(m_firstpay_superinfo_tos,
        {
        }).
-endif.

-ifndef('M_FIRSTPAY_SUPERINFO_TOC_PB_H').
-define('M_FIRSTPAY_SUPERINFO_TOC_PB_H', true).
-record(m_firstpay_superinfo_toc,
        {pay_num                :: integer(),       % = 1, 32 bits
         is_fetch               :: boolean() | 0 | 1 % = 2
        }).
-endif.

-endif.
