%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.5.1

-ifndef(pb_1611_cross_guildwar).
-define(pb_1611_cross_guildwar, true).

-define(pb_1611_cross_guildwar_gpb_version, "4.5.1").

-ifndef('M_CGW_PANEL_TOS_PB_H').
-define('M_CGW_PANEL_TOS_PB_H', true).
-record(m_cgw_panel_tos,
        {
        }).
-endif.

-ifndef('M_CGW_PANEL_TOC_PB_H').
-define('M_CGW_PANEL_TOC_PB_H', true).
-record(m_cgw_panel_toc,
        {period                 :: integer(),       % = 1, 32 bits
         next                   :: integer()        % = 2, 32 bits
        }).
-endif.

-ifndef('M_CGW_GUILDS_TOS_PB_H').
-define('M_CGW_GUILDS_TOS_PB_H', true).
-record(m_cgw_guilds_tos,
        {
        }).
-endif.

-ifndef('M_CGW_GUILDS_TOC_PB_H').
-define('M_CGW_GUILDS_TOC_PB_H', true).
-record(m_cgw_guilds_toc,
        {guilds = []            :: [pb_1611_cross_guildwar:p_cgw_guild()] | undefined, % = 1
         my_rank                :: integer(),       % = 2, 32 bits
         my_score               :: integer(),       % = 3, 32 bits
         booktimes              :: integer(),       % = 4, 32 bits
         my_book                :: integer()        % = 5, 32 bits
        }).
-endif.

-ifndef('M_CGW_BOOK_TOS_PB_H').
-define('M_CGW_BOOK_TOS_PB_H', true).
-record(m_cgw_book_tos,
        {guild_id               :: non_neg_integer() % = 1, 32 bits
        }).
-endif.

-ifndef('M_CGW_BOOK_TOC_PB_H').
-define('M_CGW_BOOK_TOC_PB_H', true).
-record(m_cgw_book_toc,
        {guild_id               :: non_neg_integer() % = 1, 32 bits
        }).
-endif.

-ifndef('M_CGW_RANKING_TOS_PB_H').
-define('M_CGW_RANKING_TOS_PB_H', true).
-record(m_cgw_ranking_tos,
        {
        }).
-endif.

-ifndef('M_CGW_RANKING_TOC_PB_H').
-define('M_CGW_RANKING_TOC_PB_H', true).
-record(m_cgw_ranking_toc,
        {ranking = []           :: [pb_1611_cross_guildwar:p_cgw_rank()] | undefined % = 1
        }).
-endif.

-ifndef('M_CGW_MATCH_TOS_PB_H').
-define('M_CGW_MATCH_TOS_PB_H', true).
-record(m_cgw_match_tos,
        {
        }).
-endif.

-ifndef('M_CGW_MATCH_TOC_PB_H').
-define('M_CGW_MATCH_TOC_PB_H', true).
-record(m_cgw_match_toc,
        {round1 = []            :: [pb_1611_cross_guildwar:p_cgw_match()] | undefined, % = 1
         round2 = []            :: [pb_1611_cross_guildwar:p_cgw_match()] | undefined % = 2
        }).
-endif.

-ifndef('M_CGW_RESULT_TOC_PB_H').
-define('M_CGW_RESULT_TOC_PB_H', true).
-record(m_cgw_result_toc,
        {result                 :: boolean() | 0 | 1 % = 1
        }).
-endif.

-ifndef('P_CGW_GUILD_PB_H').
-define('P_CGW_GUILD_PB_H', true).
-record(p_cgw_guild,
        {id                     :: non_neg_integer(), % = 1, 32 bits
         name                   :: iolist(),        % = 2
         chief                  :: iolist(),        % = 3
         score                  :: integer(),       % = 4, 32 bits
         book                   :: non_neg_integer(), % = 6, 32 bits
         book_times             :: integer(),       % = 7, 32 bits
         book_time              :: integer(),       % = 8, 32 bits
         book_guild             :: iolist(),        % = 9
         book_score             :: integer()        % = 10, 32 bits
        }).
-endif.

-ifndef('P_CGW_RANK_PB_H').
-define('P_CGW_RANK_PB_H', true).
-record(p_cgw_rank,
        {id                     :: non_neg_integer(), % = 1, 32 bits
         name                   :: iolist(),        % = 2
         chief                  :: iolist(),        % = 3
         score                  :: integer(),       % = 4, 32 bits
         rank                   :: integer()        % = 5, 32 bits
        }).
-endif.

-ifndef('P_CGW_MATCH_PB_H').
-define('P_CGW_MATCH_PB_H', true).
-record(p_cgw_match,
        {atk_id                 :: non_neg_integer(), % = 1, 32 bits
         atk_name               :: iolist(),        % = 2
         def_id                 :: non_neg_integer(), % = 3, 32 bits
         def_name               :: iolist(),        % = 4
         winner                 :: non_neg_integer() % = 5, 32 bits
        }).
-endif.

-ifndef('P_CGW_RESULT_PB_H').
-define('P_CGW_RESULT_PB_H', true).
-record(p_cgw_result,
        {id                     :: non_neg_integer(), % = 1, 32 bits
         name                   :: iolist(),        % = 2
         rank                   :: integer(),       % = 3, 32 bits
         kill                   :: integer(),       % = 4, 32 bits
         score                  :: integer()        % = 5, 32 bits
        }).
-endif.

-endif.
