%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.5.1

-ifndef(pb_1403_guild_house).
-define(pb_1403_guild_house, true).

-define(pb_1403_guild_house_gpb_version, "4.5.1").

-ifndef('M_GUILD_HOUSE_QUESTION_TOS_PB_H').
-define('M_GUILD_HOUSE_QUESTION_TOS_PB_H', true).
-record(m_guild_house_question_tos,
        {
        }).
-endif.

-ifndef('M_GUILD_HOUSE_QUESTION_TOC_PB_H').
-define('M_GUILD_HOUSE_QUESTION_TOC_PB_H', true).
-record(m_guild_house_question_toc,
        {id                     :: integer(),       % = 1, 32 bits
         num                    :: integer(),       % = 2, 32 bits
         end_time               :: integer(),       % = 3, 32 bits
         score                  :: integer() | undefined % = 4, 32 bits
        }).
-endif.

-ifndef('M_GUILD_HOUSE_ANSWER_TOS_PB_H').
-define('M_GUILD_HOUSE_ANSWER_TOS_PB_H', true).
-record(m_guild_house_answer_tos,
        {answer                 :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_GUILD_HOUSE_ANSWER_TOC_PB_H').
-define('M_GUILD_HOUSE_ANSWER_TOC_PB_H', true).
-record(m_guild_house_answer_toc,
        {is_right               :: boolean() | 0 | 1 | undefined, % = 1
         score                  :: integer() | undefined, % = 2, 32 bits
         answer                 :: integer() | undefined % = 3, 32 bits
        }).
-endif.

-ifndef('M_GUILD_HOUSE_CALLBOSS_TOS_PB_H').
-define('M_GUILD_HOUSE_CALLBOSS_TOS_PB_H', true).
-record(m_guild_house_callboss_tos,
        {id                     :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_GUILD_HOUSE_CALLBOSS_TOC_PB_H').
-define('M_GUILD_HOUSE_CALLBOSS_TOC_PB_H', true).
-record(m_guild_house_callboss_toc,
        {
        }).
-endif.

-ifndef('M_GUILD_HOUSE_EXP_TOC_PB_H').
-define('M_GUILD_HOUSE_EXP_TOC_PB_H', true).
-record(m_guild_house_exp_toc,
        {exp                    :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_GUILD_QUESTION_FIRST_TOC_PB_H').
-define('M_GUILD_QUESTION_FIRST_TOC_PB_H', true).
-record(m_guild_question_first_toc,
        {name                   :: iolist()         % = 1
        }).
-endif.

-ifndef('M_GUILD_QUESTION_RESULT_TOC_PB_H').
-define('M_GUILD_QUESTION_RESULT_TOC_PB_H', true).
-record(m_guild_question_result_toc,
        {rank                   :: integer(),       % = 1, 32 bits
         score                  :: integer(),       % = 2, 32 bits
         rewards = #{}          :: #{integer() := integer()} | undefined % = 3
        }).
-endif.

-ifndef('M_GUILD_HOUSE_SCORE_TOS_PB_H').
-define('M_GUILD_HOUSE_SCORE_TOS_PB_H', true).
-record(m_guild_house_score_tos,
        {
        }).
-endif.

-ifndef('M_GUILD_HOUSE_SCORE_TOC_PB_H').
-define('M_GUILD_HOUSE_SCORE_TOC_PB_H', true).
-record(m_guild_house_score_toc,
        {score                  :: integer()        % = 2, 32 bits
        }).
-endif.

-ifndef('M_GUILD_HOUSE_BOSS_TIME_TOS_PB_H').
-define('M_GUILD_HOUSE_BOSS_TIME_TOS_PB_H', true).
-record(m_guild_house_boss_time_tos,
        {
        }).
-endif.

-ifndef('M_GUILD_HOUSE_CALLBOSS_BC_TOC_PB_H').
-define('M_GUILD_HOUSE_CALLBOSS_BC_TOC_PB_H', true).
-record(m_guild_house_callboss_bc_toc,
        {start_time             :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_GUILD_HOUSE_BOSS_FINISH_TOC_PB_H').
-define('M_GUILD_HOUSE_BOSS_FINISH_TOC_PB_H', true).
-record(m_guild_house_boss_finish_toc,
        {
        }).
-endif.

-endif.