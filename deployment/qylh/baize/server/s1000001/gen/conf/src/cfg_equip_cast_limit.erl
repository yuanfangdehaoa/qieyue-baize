% Automatically generated, do not edit
-module(cfg_equip_cast_limit).

-compile([export_all]).
-compile(nowarn_export_all).

-include("equip.hrl").

max_level(1, 1, 0) -> 0;
max_level(1, 3, 0) -> 0;
max_level(1, 3, 1) -> 0;
max_level(1, 4, 0) -> 0;
max_level(1, 4, 1) -> 0;
max_level(1, 5, 0) -> 0;
max_level(1, 5, 1) -> 0;
max_level(1, 5, 2) -> 0;
max_level(1, 6, 1) -> 0;
max_level(1, 6, 2) -> 0;
max_level(1, 6, 3) -> 0;
max_level(1, 7, 3) -> 0;
max_level(1, 7, 4) -> 0;
max_level(2, 1, 0) -> 0;
max_level(2, 3, 0) -> 0;
max_level(2, 3, 1) -> 0;
max_level(2, 4, 0) -> 0;
max_level(2, 4, 1) -> 0;
max_level(2, 5, 0) -> 0;
max_level(2, 5, 1) -> 0;
max_level(2, 5, 2) -> 0;
max_level(2, 6, 1) -> 0;
max_level(2, 6, 2) -> 0;
max_level(2, 6, 3) -> 0;
max_level(2, 7, 3) -> 0;
max_level(2, 7, 4) -> 0;
max_level(3, 1, 0) -> 0;
max_level(3, 3, 0) -> 0;
max_level(3, 3, 1) -> 0;
max_level(3, 4, 0) -> 0;
max_level(3, 4, 1) -> 0;
max_level(3, 5, 0) -> 0;
max_level(3, 5, 1) -> 0;
max_level(3, 5, 2) -> 0;
max_level(3, 6, 1) -> 0;
max_level(3, 6, 2) -> 0;
max_level(3, 6, 3) -> 0;
max_level(3, 7, 3) -> 0;
max_level(3, 7, 4) -> 0;
max_level(4, 1, 0) -> 0;
max_level(4, 3, 0) -> 0;
max_level(4, 3, 1) -> 0;
max_level(4, 4, 0) -> 0;
max_level(4, 4, 1) -> 0;
max_level(4, 5, 0) -> 0;
max_level(4, 5, 1) -> 0;
max_level(4, 5, 2) -> 0;
max_level(4, 6, 1) -> 0;
max_level(4, 6, 2) -> 0;
max_level(4, 6, 3) -> 0;
max_level(4, 7, 3) -> 0;
max_level(4, 7, 4) -> 0;
max_level(5, 1, 0) -> 1;
max_level(5, 3, 0) -> 1;
max_level(5, 3, 1) -> 1;
max_level(5, 4, 0) -> 1;
max_level(5, 4, 1) -> 1;
max_level(5, 5, 0) -> 1;
max_level(5, 5, 1) -> 1;
max_level(5, 5, 2) -> 1;
max_level(5, 6, 1) -> 1;
max_level(5, 6, 2) -> 1;
max_level(5, 6, 3) -> 1;
max_level(5, 7, 3) -> 1;
max_level(5, 7, 4) -> 1;
max_level(6, 1, 0) -> 2;
max_level(6, 3, 0) -> 2;
max_level(6, 3, 1) -> 2;
max_level(6, 4, 0) -> 2;
max_level(6, 4, 1) -> 2;
max_level(6, 5, 0) -> 3;
max_level(6, 5, 1) -> 3;
max_level(6, 5, 2) -> 3;
max_level(6, 6, 1) -> 3;
max_level(6, 6, 2) -> 3;
max_level(6, 6, 3) -> 3;
max_level(6, 7, 3) -> 3;
max_level(6, 7, 4) -> 3;
max_level(7, 1, 0) -> 2;
max_level(7, 3, 0) -> 2;
max_level(7, 3, 1) -> 2;
max_level(7, 4, 0) -> 2;
max_level(7, 4, 1) -> 2;
max_level(7, 5, 0) -> 4;
max_level(7, 5, 1) -> 4;
max_level(7, 5, 2) -> 4;
max_level(7, 6, 1) -> 5;
max_level(7, 6, 2) -> 5;
max_level(7, 6, 3) -> 5;
max_level(7, 7, 3) -> 5;
max_level(7, 7, 4) -> 5;
max_level(8, 1, 0) -> 2;
max_level(8, 3, 0) -> 2;
max_level(8, 3, 1) -> 2;
max_level(8, 4, 0) -> 2;
max_level(8, 4, 1) -> 2;
max_level(8, 5, 0) -> 4;
max_level(8, 5, 1) -> 4;
max_level(8, 5, 2) -> 4;
max_level(8, 6, 1) -> 5;
max_level(8, 6, 2) -> 7;
max_level(8, 6, 3) -> 7;
max_level(8, 7, 3) -> 7;
max_level(8, 7, 4) -> 7;
max_level(9, 1, 0) -> 2;
max_level(9, 3, 0) -> 2;
max_level(9, 3, 1) -> 2;
max_level(9, 4, 0) -> 2;
max_level(9, 4, 1) -> 2;
max_level(9, 5, 0) -> 4;
max_level(9, 5, 1) -> 4;
max_level(9, 5, 2) -> 4;
max_level(9, 6, 1) -> 5;
max_level(9, 6, 2) -> 9;
max_level(9, 6, 3) -> 9;
max_level(9, 7, 3) -> 9;
max_level(9, 7, 4) -> 9;
max_level(10, 1, 0) -> 2;
max_level(10, 3, 0) -> 2;
max_level(10, 3, 1) -> 2;
max_level(10, 4, 0) -> 2;
max_level(10, 4, 1) -> 2;
max_level(10, 5, 0) -> 4;
max_level(10, 5, 1) -> 4;
max_level(10, 5, 2) -> 4;
max_level(10, 6, 1) -> 5;
max_level(10, 6, 2) -> 11;
max_level(10, 6, 3) -> 11;
max_level(10, 7, 3) -> 11;
max_level(10, 7, 4) -> 11;
max_level(11, 1, 0) -> 2;
max_level(11, 3, 0) -> 2;
max_level(11, 3, 1) -> 2;
max_level(11, 4, 0) -> 2;
max_level(11, 4, 1) -> 2;
max_level(11, 5, 0) -> 4;
max_level(11, 5, 1) -> 4;
max_level(11, 5, 2) -> 4;
max_level(11, 6, 1) -> 5;
max_level(11, 6, 2) -> 13;
max_level(11, 6, 3) -> 13;
max_level(11, 7, 3) -> 13;
max_level(11, 7, 4) -> 13;
max_level(12, 1, 0) -> 2;
max_level(12, 3, 0) -> 2;
max_level(12, 3, 1) -> 2;
max_level(12, 4, 0) -> 2;
max_level(12, 4, 1) -> 2;
max_level(12, 5, 0) -> 4;
max_level(12, 5, 1) -> 4;
max_level(12, 5, 2) -> 4;
max_level(12, 6, 1) -> 5;
max_level(12, 6, 2) -> 15;
max_level(12, 6, 3) -> 15;
max_level(12, 7, 3) -> 15;
max_level(12, 7, 4) -> 15;
max_level(13, 1, 0) -> 2;
max_level(13, 3, 0) -> 2;
max_level(13, 3, 1) -> 2;
max_level(13, 4, 0) -> 2;
max_level(13, 4, 1) -> 2;
max_level(13, 5, 0) -> 4;
max_level(13, 5, 1) -> 4;
max_level(13, 5, 2) -> 4;
max_level(13, 6, 1) -> 5;
max_level(13, 6, 2) -> 19;
max_level(13, 6, 3) -> 19;
max_level(13, 7, 3) -> 19;
max_level(13, 7, 4) -> 19;
max_level(14, 1, 0) -> 2;
max_level(14, 3, 0) -> 2;
max_level(14, 3, 1) -> 2;
max_level(14, 4, 0) -> 2;
max_level(14, 4, 1) -> 2;
max_level(14, 5, 0) -> 4;
max_level(14, 5, 1) -> 4;
max_level(14, 5, 2) -> 4;
max_level(14, 6, 1) -> 5;
max_level(14, 6, 2) -> 23;
max_level(14, 6, 3) -> 23;
max_level(14, 7, 3) -> 23;
max_level(14, 7, 4) -> 23;
max_level(15, 1, 0) -> 2;
max_level(15, 3, 0) -> 2;
max_level(15, 3, 1) -> 2;
max_level(15, 4, 0) -> 2;
max_level(15, 4, 1) -> 2;
max_level(15, 5, 0) -> 4;
max_level(15, 5, 1) -> 4;
max_level(15, 5, 2) -> 4;
max_level(15, 6, 1) -> 5;
max_level(15, 6, 2) -> 27;
max_level(15, 6, 3) -> 27;
max_level(15, 7, 3) -> 27;
max_level(15, 7, 4) -> 27;
max_level(16, 1, 0) -> 2;
max_level(16, 3, 0) -> 2;
max_level(16, 3, 1) -> 2;
max_level(16, 4, 0) -> 2;
max_level(16, 4, 1) -> 2;
max_level(16, 5, 0) -> 4;
max_level(16, 5, 1) -> 4;
max_level(16, 5, 2) -> 4;
max_level(16, 6, 1) -> 5;
max_level(16, 6, 2) -> 27;
max_level(16, 6, 3) -> 27;
max_level(16, 7, 3) -> 27;
max_level(16, 7, 4) -> 27;
max_level(_, _, _) -> 0.



