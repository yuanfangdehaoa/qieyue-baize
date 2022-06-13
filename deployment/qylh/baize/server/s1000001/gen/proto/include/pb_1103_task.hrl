%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.5.1

-ifndef(pb_1103_task).
-define(pb_1103_task, true).

-define(pb_1103_task_gpb_version, "4.5.1").

-ifndef('M_TASK_LIST_TOS_PB_H').
-define('M_TASK_LIST_TOS_PB_H', true).
-record(m_task_list_tos,
        {
        }).
-endif.

-ifndef('M_TASK_LIST_TOC_PB_H').
-define('M_TASK_LIST_TOC_PB_H', true).
-record(m_task_list_toc,
        {tasks = []             :: [pb_1103_task:p_task()] | undefined, % = 1
         next                   :: integer()        % = 2, 32 bits
        }).
-endif.

-ifndef('M_TASK_ACCEPT_TOS_PB_H').
-define('M_TASK_ACCEPT_TOS_PB_H', true).
-record(m_task_accept_tos,
        {task_id                :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_TASK_ACCEPT_TOC_PB_H').
-define('M_TASK_ACCEPT_TOC_PB_H', true).
-record(m_task_accept_toc,
        {task                   :: pb_1103_task:p_task() % = 1
        }).
-endif.

-ifndef('M_TASK_SUBMIT_TOS_PB_H').
-define('M_TASK_SUBMIT_TOS_PB_H', true).
-record(m_task_submit_tos,
        {task_id                :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_TASK_SUBMIT_TOC_PB_H').
-define('M_TASK_SUBMIT_TOC_PB_H', true).
-record(m_task_submit_toc,
        {task_id                :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_TASK_QUICK_TOS_PB_H').
-define('M_TASK_QUICK_TOS_PB_H', true).
-record(m_task_quick_tos,
        {task_id                :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_TASK_QUICK_TOC_PB_H').
-define('M_TASK_QUICK_TOC_PB_H', true).
-record(m_task_quick_toc,
        {task_id                :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_TASK_UPDATE_TOC_PB_H').
-define('M_TASK_UPDATE_TOC_PB_H', true).
-record(m_task_update_toc,
        {add = []               :: [pb_1103_task:p_task()] | undefined, % = 1
         chg = []               :: [pb_1103_task:p_task()] | undefined, % = 2
         del = []               :: [integer()] | undefined, % = 3, 32 bits
         next                   :: integer() | undefined % = 4, 32 bits
        }).
-endif.

-ifndef('M_TASK_REWARD_TOS_PB_H').
-define('M_TASK_REWARD_TOS_PB_H', true).
-record(m_task_reward_tos,
        {chapter                :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_TASK_REWARD_TOC_PB_H').
-define('M_TASK_REWARD_TOC_PB_H', true).
-record(m_task_reward_toc,
        {
        }).
-endif.

-ifndef('P_TASK_PB_H').
-define('P_TASK_PB_H', true).
-record(p_task,
        {id                     :: integer(),       % = 1, 32 bits
         prog                   :: integer(),       % = 2, 32 bits
         count                  :: integer(),       % = 3, 32 bits
         state                  :: integer(),       % = 4, 32 bits
         etime                  :: integer(),       % = 5, 32 bits
         goal = []              :: [pb_1103_task:p_task_goal()] | undefined % = 6
        }).
-endif.

-ifndef('P_TASK_GOAL_PB_H').
-define('P_TASK_GOAL_PB_H', true).
-record(p_task_goal,
        {event                  :: integer(),       % = 1, 32 bits
         target                 :: integer(),       % = 2, 32 bits
         amount                 :: integer(),       % = 3, 32 bits
         scene                  :: integer(),       % = 4, 32 bits
         findway                :: boolean() | 0 | 1 % = 5
        }).
-endif.

-endif.
