%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.5.1

-ifndef(pb_1107_mount).
-define(pb_1107_mount, true).

-define(pb_1107_mount_gpb_version, "4.5.1").

-ifndef('M_MOUNT_INFO_TOS_PB_H').
-define('M_MOUNT_INFO_TOS_PB_H', true).
-record(m_mount_info_tos,
        {type                   :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_MOUNT_INFO_TOC_PB_H').
-define('M_MOUNT_INFO_TOC_PB_H', true).
-record(m_mount_info_toc,
        {type                   :: integer(),       % = 1, 32 bits
         order                  :: integer(),       % = 2, 32 bits
         level                  :: integer(),       % = 3, 32 bits
         exp                    :: integer(),       % = 4, 32 bits
         train = #{}            :: #{integer() := integer()} | undefined, % = 5
         figure                 :: integer()        % = 6, 32 bits
        }).
-endif.

-ifndef('M_MOUNT_UPGRADE_TOS_PB_H').
-define('M_MOUNT_UPGRADE_TOS_PB_H', true).
-record(m_mount_upgrade_tos,
        {type                   :: integer(),       % = 1, 32 bits
         item_id                :: integer()        % = 2, 32 bits
        }).
-endif.

-ifndef('M_MOUNT_UPGRADE_TOC_PB_H').
-define('M_MOUNT_UPGRADE_TOC_PB_H', true).
-record(m_mount_upgrade_toc,
        {type                   :: integer(),       % = 1, 32 bits
         order                  :: integer(),       % = 2, 32 bits
         level                  :: integer(),       % = 3, 32 bits
         exp                    :: integer()        % = 4, 32 bits
        }).
-endif.

-ifndef('M_MOUNT_TRAIN_TOS_PB_H').
-define('M_MOUNT_TRAIN_TOS_PB_H', true).
-record(m_mount_train_tos,
        {type                   :: integer(),       % = 1, 32 bits
         item_id                :: integer()        % = 2, 32 bits
        }).
-endif.

-ifndef('M_MOUNT_TRAIN_TOC_PB_H').
-define('M_MOUNT_TRAIN_TOC_PB_H', true).
-record(m_mount_train_toc,
        {type                   :: integer(),       % = 1, 32 bits
         item_id                :: integer(),       % = 2, 32 bits
         num                    :: integer()        % = 3, 32 bits
        }).
-endif.

-ifndef('M_MOUNT_FIGURE_TOS_PB_H').
-define('M_MOUNT_FIGURE_TOS_PB_H', true).
-record(m_mount_figure_tos,
        {type                   :: integer(),       % = 1, 32 bits
         order                  :: integer()        % = 2, 32 bits
        }).
-endif.

-ifndef('M_MOUNT_FIGURE_TOC_PB_H').
-define('M_MOUNT_FIGURE_TOC_PB_H', true).
-record(m_mount_figure_toc,
        {type                   :: integer(),       % = 1, 32 bits
         order                  :: integer(),       % = 2, 32 bits
         res                    :: integer()        % = 3, 32 bits
        }).
-endif.

-ifndef('M_MOUNT_RIDE_TOS_PB_H').
-define('M_MOUNT_RIDE_TOS_PB_H', true).
-record(m_mount_ride_tos,
        {type                   :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_MOUNT_RIDE_TOC_PB_H').
-define('M_MOUNT_RIDE_TOC_PB_H', true).
-record(m_mount_ride_toc,
        {type                   :: integer()        % = 1, 32 bits
        }).
-endif.

-endif.