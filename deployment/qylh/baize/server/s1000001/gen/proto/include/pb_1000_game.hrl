%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.5.1

-ifndef(pb_1000_game).
-define(pb_1000_game, true).

-define(pb_1000_game_gpb_version, "4.5.1").

-ifndef('M_GAME_CHEAT_TOS_PB_H').
-define('M_GAME_CHEAT_TOS_PB_H', true).
-record(m_game_cheat_tos,
        {cmd                    :: iolist()         % = 1
        }).
-endif.

-ifndef('M_GAME_ERROR_TOC_PB_H').
-define('M_GAME_ERROR_TOC_PB_H', true).
-record(m_game_error_toc,
        {errno                  :: integer(),       % = 1, 32 bits
         args = []              :: [iolist()] | undefined % = 2
        }).
-endif.

-ifndef('M_GAME_HEART_TOS_PB_H').
-define('M_GAME_HEART_TOS_PB_H', true).
-record(m_game_heart_tos,
        {
        }).
-endif.

-ifndef('M_GAME_HEART_TOC_PB_H').
-define('M_GAME_HEART_TOC_PB_H', true).
-record(m_game_heart_toc,
        {
        }).
-endif.

-ifndef('M_GAME_SETTING_TOS_PB_H').
-define('M_GAME_SETTING_TOS_PB_H', true).
-record(m_game_setting_tos,
        {
        }).
-endif.

-ifndef('M_GAME_SETTING_TOC_PB_H').
-define('M_GAME_SETTING_TOC_PB_H', true).
-record(m_game_setting_toc,
        {setting = #{}          :: #{integer() := integer()} | undefined % = 1
        }).
-endif.

-ifndef('M_GAME_SETUP_TOS_PB_H').
-define('M_GAME_SETUP_TOS_PB_H', true).
-record(m_game_setup_tos,
        {setting = #{}          :: #{integer() := integer()} | undefined % = 1
        }).
-endif.

-ifndef('M_GAME_TIME_TOS_PB_H').
-define('M_GAME_TIME_TOS_PB_H', true).
-record(m_game_time_tos,
        {
        }).
-endif.

-ifndef('M_GAME_TIME_TOC_PB_H').
-define('M_GAME_TIME_TOC_PB_H', true).
-record(m_game_time_toc,
        {time                   :: non_neg_integer(), % = 1, 32 bits
         tz                     :: integer()        % = 2, 32 bits
        }).
-endif.

-ifndef('M_GAME_NOTIFY_TOC_PB_H').
-define('M_GAME_NOTIFY_TOC_PB_H', true).
-record(m_game_notify_toc,
        {msgno                  :: integer(),       % = 1, 32 bits
         args = []              :: [pb_1000_game:p_msgno()] | undefined % = 2
        }).
-endif.

-ifndef('M_GAME_SYSLIST_TOS_PB_H').
-define('M_GAME_SYSLIST_TOS_PB_H', true).
-record(m_game_syslist_tos,
        {
        }).
-endif.

-ifndef('M_GAME_SYSLIST_TOC_PB_H').
-define('M_GAME_SYSLIST_TOC_PB_H', true).
-record(m_game_syslist_toc,
        {syslist = []           :: [iolist()] | undefined % = 1
        }).
-endif.

-ifndef('M_GAME_SYSOPEN_TOC_PB_H').
-define('M_GAME_SYSOPEN_TOC_PB_H', true).
-record(m_game_sysopen_toc,
        {sysid                  :: iolist()         % = 1
        }).
-endif.

-ifndef('M_GAME_PAYINFO_TOS_PB_H').
-define('M_GAME_PAYINFO_TOS_PB_H', true).
-record(m_game_payinfo_tos,
        {goods_id               :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_GAME_PAYINFO_TOC_PB_H').
-define('M_GAME_PAYINFO_TOC_PB_H', true).
-record(m_game_payinfo_toc,
        {goods_id               :: integer(),       % = 1, 32 bits
         order_id               :: iolist(),        % = 2
         pay_back               :: iolist()         % = 3
        }).
-endif.

-ifndef('M_GAME_PAYSUCC_TOC_PB_H').
-define('M_GAME_PAYSUCC_TOC_PB_H', true).
-record(m_game_paysucc_toc,
        {gain = #{}             :: #{integer() := integer()} | undefined, % = 1
         app_order              :: iolist(),        % = 2
         sdk_order              :: iolist()         % = 3
        }).
-endif.

-ifndef('M_GAME_CLIENTTIME_TOS_PB_H').
-define('M_GAME_CLIENTTIME_TOS_PB_H', true).
-record(m_game_clienttime_tos,
        {time                   :: non_neg_integer() % = 1, 32 bits
        }).
-endif.

-ifndef('M_GAME_WORLDLV_TOS_PB_H').
-define('M_GAME_WORLDLV_TOS_PB_H', true).
-record(m_game_worldlv_tos,
        {
        }).
-endif.

-ifndef('M_GAME_WORLDLV_TOC_PB_H').
-define('M_GAME_WORLDLV_TOC_PB_H', true).
-record(m_game_worldlv_toc,
        {level                  :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_GAME_HOTCONFIG_TOC_PB_H').
-define('M_GAME_HOTCONFIG_TOC_PB_H', true).
-record(m_game_hotconfig_toc,
        {config                 :: iolist()         % = 1
        }).
-endif.

-ifndef('M_GAME_MARQUEE_TOS_PB_H').
-define('M_GAME_MARQUEE_TOS_PB_H', true).
-record(m_game_marquee_tos,
        {
        }).
-endif.

-ifndef('M_GAME_MARQUEE_TOC_PB_H').
-define('M_GAME_MARQUEE_TOC_PB_H', true).
-record(m_game_marquee_toc,
        {list = []              :: [pb_1000_game:p_marquee()] | undefined % = 1
        }).
-endif.

-ifndef('M_GAME_MARQUEE_UPDATE_TOC_PB_H').
-define('M_GAME_MARQUEE_UPDATE_TOC_PB_H', true).
-record(m_game_marquee_update_toc,
        {add                    :: pb_1000_game:p_marquee() | undefined, % = 1
         del                    :: integer() | undefined % = 2, 32 bits
        }).
-endif.

-ifndef('M_GAME_SUSPEND_TOS_PB_H').
-define('M_GAME_SUSPEND_TOS_PB_H', true).
-record(m_game_suspend_tos,
        {
        }).
-endif.

-ifndef('M_GAME_AWAKE_TOS_PB_H').
-define('M_GAME_AWAKE_TOS_PB_H', true).
-record(m_game_awake_tos,
        {
        }).
-endif.

-ifndef('M_GAME_PAYLIST_TOS_PB_H').
-define('M_GAME_PAYLIST_TOS_PB_H', true).
-record(m_game_paylist_tos,
        {
        }).
-endif.

-ifndef('M_GAME_PAYLIST_TOC_PB_H').
-define('M_GAME_PAYLIST_TOC_PB_H', true).
-record(m_game_paylist_toc,
        {paid = []              :: [integer()] | undefined % = 1, 32 bits
        }).
-endif.

-ifndef('M_GAME_CLIENTERROR_TOS_PB_H').
-define('M_GAME_CLIENTERROR_TOS_PB_H', true).
-record(m_game_clienterror_tos,
        {error                  :: iolist()         % = 1
        }).
-endif.

-ifndef('M_GAME_NEWBIE_SCENE_TOS_PB_H').
-define('M_GAME_NEWBIE_SCENE_TOS_PB_H', true).
-record(m_game_newbie_scene_tos,
        {
        }).
-endif.

-ifndef('M_GAME_NEWBIE_SCENE_TOC_PB_H').
-define('M_GAME_NEWBIE_SCENE_TOC_PB_H', true).
-record(m_game_newbie_scene_toc,
        {res_id                 :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_GAME_PAYTIMES_TOS_PB_H').
-define('M_GAME_PAYTIMES_TOS_PB_H', true).
-record(m_game_paytimes_tos,
        {
        }).
-endif.

-ifndef('M_GAME_PAYTIMES_TOC_PB_H').
-define('M_GAME_PAYTIMES_TOC_PB_H', true).
-record(m_game_paytimes_toc,
        {times = #{}            :: #{integer() := integer()} | undefined % = 1
        }).
-endif.

-ifndef('P_MARQUEE_PB_H').
-define('P_MARQUEE_PB_H', true).
-record(p_marquee,
        {id                     :: integer(),       % = 1, 32 bits
         type                   :: integer() | undefined, % = 2, 32 bits
         start_time             :: integer(),       % = 3, 32 bits
         end_time               :: integer(),       % = 4, 32 bits
         content                :: iolist(),        % = 5
         interval               :: integer(),       % = 6, 32 bits
         ext = #{}              :: #{iolist() := integer()} | undefined % = 7
        }).
-endif.

-ifndef('P_MSGNO_PB_H').
-define('P_MSGNO_PB_H', true).
-record(p_msgno,
        {props = #{}            :: #{iolist() := iolist()} | undefined, % = 1
         items = #{}            :: #{integer() := integer()} | undefined, % = 2
         pitems = #{}           :: #{integer() := integer()} | undefined % = 3
        }).
-endif.

-endif.