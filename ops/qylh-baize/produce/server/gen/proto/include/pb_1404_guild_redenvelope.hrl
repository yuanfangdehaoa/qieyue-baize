%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.5.1

-ifndef(pb_1404_guild_redenvelope).
-define(pb_1404_guild_redenvelope, true).

-define(pb_1404_guild_redenvelope_gpb_version, "4.5.1").

-ifndef('M_GUILD_REDENVELOPE_LIST_TOS_PB_H').
-define('M_GUILD_REDENVELOPE_LIST_TOS_PB_H', true).
-record(m_guild_redenvelope_list_tos,
        {
        }).
-endif.

-ifndef('M_GUILD_REDENVELOPE_LIST_TOC_PB_H').
-define('M_GUILD_REDENVELOPE_LIST_TOC_PB_H', true).
-record(m_guild_redenvelope_list_toc,
        {redenvelopes = []      :: [pb_1404_guild_redenvelope:p_redenvelope()] | undefined, % = 1
         guild_redenvelopes = [] :: [pb_1404_guild_redenvelope:p_redenvelope()] | undefined % = 2
        }).
-endif.

-ifndef('M_GUILD_REDENVELOPE_SEND_TOS_PB_H').
-define('M_GUILD_REDENVELOPE_SEND_TOS_PB_H', true).
-record(m_guild_redenvelope_send_tos,
        {num                    :: integer(),       % = 1, 32 bits
         uid                    :: non_neg_integer() | undefined, % = 2, 32 bits
         id                     :: integer(),       % = 3, 32 bits
         money                  :: integer() | undefined, % = 4, 32 bits
         desc                   :: iolist() | undefined % = 5
        }).
-endif.

-ifndef('M_GUILD_REDENVELOPE_SEND_TOC_PB_H').
-define('M_GUILD_REDENVELOPE_SEND_TOC_PB_H', true).
-record(m_guild_redenvelope_send_toc,
        {uid                    :: non_neg_integer() % = 1, 32 bits
        }).
-endif.

-ifndef('M_GUILD_REDENVELOPE_SNATCH_TOS_PB_H').
-define('M_GUILD_REDENVELOPE_SNATCH_TOS_PB_H', true).
-record(m_guild_redenvelope_snatch_tos,
        {uid                    :: non_neg_integer() % = 1, 32 bits
        }).
-endif.

-ifndef('M_GUILD_REDENVELOPE_SNATCH_TOC_PB_H').
-define('M_GUILD_REDENVELOPE_SNATCH_TOC_PB_H', true).
-record(m_guild_redenvelope_snatch_toc,
        {uid                    :: non_neg_integer() % = 1, 32 bits
        }).
-endif.

-ifndef('M_GUILD_REDENVELOPE_RECORD_TOS_PB_H').
-define('M_GUILD_REDENVELOPE_RECORD_TOS_PB_H', true).
-record(m_guild_redenvelope_record_tos,
        {
        }).
-endif.

-ifndef('M_GUILD_REDENVELOPE_RECORD_TOC_PB_H').
-define('M_GUILD_REDENVELOPE_RECORD_TOC_PB_H', true).
-record(m_guild_redenvelope_record_toc,
        {records = []           :: [pb_1404_guild_redenvelope:p_redenvelope_record()] | undefined % = 1
        }).
-endif.

-ifndef('M_GUILD_REDENVELOPE_UPDATE_TOC_PB_H').
-define('M_GUILD_REDENVELOPE_UPDATE_TOC_PB_H', true).
-record(m_guild_redenvelope_update_toc,
        {redenvelope            :: pb_1404_guild_redenvelope:p_redenvelope() % = 1
        }).
-endif.

-ifndef('P_REDENVELOPE_PB_H').
-define('P_REDENVELOPE_PB_H', true).
-record(p_redenvelope,
        {uid                    :: non_neg_integer(), % = 1, 32 bits
         id                     :: integer(),       % = 2, 32 bits
         role                   :: pb_1404_guild_redenvelope:p_rn_role(), % = 3
         num                    :: integer(),       % = 4, 32 bits
         money = #{}            :: #{integer() := integer()} | undefined, % = 5
         gots = []              :: [pb_1404_guild_redenvelope:p_redenvelope_got()] | undefined, % = 6
         time                   :: integer(),       % = 7, 32 bits
         state                  :: integer(),       % = 8, 32 bits
         desc                   :: iolist() | undefined % = 9
        }).
-endif.

-ifndef('P_REDENVELOPE_GOT_PB_H').
-define('P_REDENVELOPE_GOT_PB_H', true).
-record(p_redenvelope_got,
        {role                   :: pb_1404_guild_redenvelope:p_rn_role(), % = 1
         money                  :: integer(),       % = 2, 32 bits
         time                   :: integer()        % = 3, 32 bits
        }).
-endif.

-ifndef('P_REDENVELOPE_RECORD_PB_H').
-define('P_REDENVELOPE_RECORD_PB_H', true).
-record(p_redenvelope_record,
        {role_name              :: iolist(),        % = 1
         id                     :: integer(),       % = 2, 32 bits
         money = #{}            :: #{integer() := integer()} | undefined, % = 3
         time                   :: integer()        % = 4, 32 bits
        }).
-endif.

-ifndef('P_RN_ROLE_PB_H').
-define('P_RN_ROLE_PB_H', true).
-record(p_rn_role,
        {id                     :: non_neg_integer(), % = 1, 32 bits
         name                   :: iolist(),        % = 2
         gender                 :: integer()        % = 3, 32 bits
        }).
-endif.

-endif.