%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.5.1

-ifndef(pb_1143_actpay).
-define(pb_1143_actpay, true).

-define(pb_1143_actpay_gpb_version, "4.5.1").

-ifndef('M_ACTPAY_INFO_TOS_PB_H').
-define('M_ACTPAY_INFO_TOS_PB_H', true).
-record(m_actpay_info_tos,
        {
        }).
-endif.

-ifndef('M_ACTPAY_INFO_TOC_PB_H').
-define('M_ACTPAY_INFO_TOC_PB_H', true).
-record(m_actpay_info_toc,
        {acts = []              :: [pb_1143_actpay:p_actpay()] | undefined % = 1
        }).
-endif.

-ifndef('M_ACTPAY_REWARD_TOS_PB_H').
-define('M_ACTPAY_REWARD_TOS_PB_H', true).
-record(m_actpay_reward_tos,
        {act_id                 :: integer(),       % = 1, 32 bits
         day                    :: integer()        % = 2, 32 bits
        }).
-endif.

-ifndef('M_ACTPAY_REWARD_TOC_PB_H').
-define('M_ACTPAY_REWARD_TOC_PB_H', true).
-record(m_actpay_reward_toc,
        {act_id                 :: integer(),       % = 1, 32 bits
         day                    :: integer()        % = 2, 32 bits
        }).
-endif.

-ifndef('P_ACTPAY_PB_H').
-define('P_ACTPAY_PB_H', true).
-record(p_actpay,
        {act_id                 :: integer(),       % = 1, 32 bits
         day                    :: integer(),       % = 2, 32 bits
         fetch = []             :: [integer()] | undefined % = 3, 32 bits
        }).
-endif.

-endif.
