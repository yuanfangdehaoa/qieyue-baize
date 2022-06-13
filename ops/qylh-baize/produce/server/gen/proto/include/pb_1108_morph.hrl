%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 4.5.1

-ifndef(pb_1108_morph).
-define(pb_1108_morph, true).

-define(pb_1108_morph_gpb_version, "4.5.1").

-ifndef('M_MORPH_LIST_TOS_PB_H').
-define('M_MORPH_LIST_TOS_PB_H', true).
-record(m_morph_list_tos,
        {type                   :: integer()        % = 1, 32 bits
        }).
-endif.

-ifndef('M_MORPH_LIST_TOC_PB_H').
-define('M_MORPH_LIST_TOC_PB_H', true).
-record(m_morph_list_toc,
        {type                   :: integer(),       % = 1, 32 bits
         morphs = []            :: [pb_1108_morph:p_morph()] | undefined, % = 2
         used_id                :: integer()        % = 3, 32 bits
        }).
-endif.

-ifndef('M_MORPH_ACTIVE_TOS_PB_H').
-define('M_MORPH_ACTIVE_TOS_PB_H', true).
-record(m_morph_active_tos,
        {type                   :: integer(),       % = 1, 32 bits
         id                     :: integer()        % = 2, 32 bits
        }).
-endif.

-ifndef('M_MORPH_ACTIVE_TOC_PB_H').
-define('M_MORPH_ACTIVE_TOC_PB_H', true).
-record(m_morph_active_toc,
        {type                   :: integer(),       % = 1, 32 bits
         id                     :: integer()        % = 2, 32 bits
        }).
-endif.

-ifndef('M_MORPH_UPSTAR_TOS_PB_H').
-define('M_MORPH_UPSTAR_TOS_PB_H', true).
-record(m_morph_upstar_tos,
        {type                   :: integer(),       % = 1, 32 bits
         id                     :: integer(),       % = 2, 32 bits
         item_id                :: integer() | undefined % = 3, 32 bits
        }).
-endif.

-ifndef('M_MORPH_UPSTAR_TOC_PB_H').
-define('M_MORPH_UPSTAR_TOC_PB_H', true).
-record(m_morph_upstar_toc,
        {type                   :: integer(),       % = 1, 32 bits
         morph                  :: pb_1108_morph:p_morph(), % = 2
         item_id                :: integer() | undefined % = 3, 32 bits
        }).
-endif.

-ifndef('M_MORPH_FIGURE_TOS_PB_H').
-define('M_MORPH_FIGURE_TOS_PB_H', true).
-record(m_morph_figure_tos,
        {type                   :: integer(),       % = 1, 32 bits
         id                     :: integer()        % = 2, 32 bits
        }).
-endif.

-ifndef('M_MORPH_FIGURE_TOC_PB_H').
-define('M_MORPH_FIGURE_TOC_PB_H', true).
-record(m_morph_figure_toc,
        {type                   :: integer(),       % = 1, 32 bits
         id                     :: integer(),       % = 2, 32 bits
         res                    :: integer()        % = 3, 32 bits
        }).
-endif.

-ifndef('P_MORPH_PB_H').
-define('P_MORPH_PB_H', true).
-record(p_morph,
        {id                     :: integer(),       % = 1, 32 bits
         star                   :: integer(),       % = 2, 32 bits
         exp                    :: integer() | undefined % = 3, 32 bits
        }).
-endif.

-endif.