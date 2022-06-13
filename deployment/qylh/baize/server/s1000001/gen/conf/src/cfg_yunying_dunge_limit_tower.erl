% Automatically generated, do not edit
-module(cfg_yunying_dunge_limit_tower).

-compile([export_all]).
-compile(nowarn_export_all).

-include("yunying.hrl").

find(170101, 1) -> #cfg_yunying_dunge_limit_tower{dunge = 30701, assist = false};
find(170101, 2) -> #cfg_yunying_dunge_limit_tower{dunge = 30702, assist = false};
find(170101, 3) -> #cfg_yunying_dunge_limit_tower{dunge = 30703, assist = false};
find(170101, 4) -> #cfg_yunying_dunge_limit_tower{dunge = 30704, assist = false};
find(170101, 5) -> #cfg_yunying_dunge_limit_tower{dunge = 30705, assist = false};
find(170101, 6) -> #cfg_yunying_dunge_limit_tower{dunge = 30706, assist = false};
find(170101, 7) -> #cfg_yunying_dunge_limit_tower{dunge = 30707, assist = false};
find(170101, 8) -> #cfg_yunying_dunge_limit_tower{dunge = 30708, assist = false};
find(170101, 9) -> #cfg_yunying_dunge_limit_tower{dunge = 30709, assist = false};
find(170101, 10) -> #cfg_yunying_dunge_limit_tower{dunge = 30710, assist = true};
find(170101, 11) -> #cfg_yunying_dunge_limit_tower{dunge = 30711, assist = true};
find(170101, 12) -> #cfg_yunying_dunge_limit_tower{dunge = 30712, assist = true};
find(170101, 13) -> #cfg_yunying_dunge_limit_tower{dunge = 30713, assist = true};
find(170101, 14) -> #cfg_yunying_dunge_limit_tower{dunge = 30714, assist = true};
find(170101, 15) -> #cfg_yunying_dunge_limit_tower{dunge = 30715, assist = true};
find(170100, 1) -> #cfg_yunying_dunge_limit_tower{dunge = 30801, assist = false};
find(170100, 2) -> #cfg_yunying_dunge_limit_tower{dunge = 30802, assist = false};
find(170100, 3) -> #cfg_yunying_dunge_limit_tower{dunge = 30803, assist = false};
find(170100, 4) -> #cfg_yunying_dunge_limit_tower{dunge = 30804, assist = false};
find(170100, 5) -> #cfg_yunying_dunge_limit_tower{dunge = 30805, assist = false};
find(170100, 6) -> #cfg_yunying_dunge_limit_tower{dunge = 30806, assist = false};
find(170100, 7) -> #cfg_yunying_dunge_limit_tower{dunge = 30807, assist = false};
find(170100, 8) -> #cfg_yunying_dunge_limit_tower{dunge = 30808, assist = false};
find(170100, 9) -> #cfg_yunying_dunge_limit_tower{dunge = 30809, assist = false};
find(170100, 10) -> #cfg_yunying_dunge_limit_tower{dunge = 30810, assist = true};
find(170100, 11) -> #cfg_yunying_dunge_limit_tower{dunge = 30811, assist = true};
find(170100, 12) -> #cfg_yunying_dunge_limit_tower{dunge = 30812, assist = true};
find(170100, 13) -> #cfg_yunying_dunge_limit_tower{dunge = 30813, assist = true};
find(170100, 14) -> #cfg_yunying_dunge_limit_tower{dunge = 30814, assist = true};
find(170100, 15) -> #cfg_yunying_dunge_limit_tower{dunge = 30815, assist = true};
find(_, _) -> undefined.

max_floor(170101) -> 15;
max_floor(170100) -> 15;
max_floor(_) -> 0.

floor(30701) -> 1;
floor(30702) -> 2;
floor(30703) -> 3;
floor(30704) -> 4;
floor(30705) -> 5;
floor(30706) -> 6;
floor(30707) -> 7;
floor(30708) -> 8;
floor(30709) -> 9;
floor(30710) -> 10;
floor(30711) -> 11;
floor(30712) -> 12;
floor(30713) -> 13;
floor(30714) -> 14;
floor(30715) -> 15;
floor(30801) -> 1;
floor(30802) -> 2;
floor(30803) -> 3;
floor(30804) -> 4;
floor(30805) -> 5;
floor(30806) -> 6;
floor(30807) -> 7;
floor(30808) -> 8;
floor(30809) -> 9;
floor(30810) -> 10;
floor(30811) -> 11;
floor(30812) -> 12;
floor(30813) -> 13;
floor(30814) -> 14;
floor(30815) -> 15;
floor(_) -> undefined.

act_ids() -> [170101,170100].

is_open(170101, 30701) -> true;
is_open(170101, 30702) -> true;
is_open(170101, 30703) -> true;
is_open(170101, 30704) -> true;
is_open(170101, 30705) -> true;
is_open(170101, 30706) -> true;
is_open(170101, 30707) -> true;
is_open(170101, 30708) -> true;
is_open(170101, 30709) -> true;
is_open(170101, 30710) -> true;
is_open(170101, 30711) -> true;
is_open(170101, 30712) -> true;
is_open(170101, 30713) -> true;
is_open(170101, 30714) -> true;
is_open(170101, 30715) -> true;
is_open(170100, 30801) -> true;
is_open(170100, 30802) -> true;
is_open(170100, 30803) -> true;
is_open(170100, 30804) -> true;
is_open(170100, 30805) -> true;
is_open(170100, 30806) -> true;
is_open(170100, 30807) -> true;
is_open(170100, 30808) -> true;
is_open(170100, 30809) -> true;
is_open(170100, 30810) -> true;
is_open(170100, 30811) -> true;
is_open(170100, 30812) -> true;
is_open(170100, 30813) -> true;
is_open(170100, 30814) -> true;
is_open(170100, 30815) -> true;
is_open(_, _) -> false.
