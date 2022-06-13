% Automatically generated, do not edit
-module(cfg_vip_invest).

-compile([export_all]).
-compile(nowarn_export_all).


find(1, 1) -> [{90010003,34000}];
find(1, 2) -> [{90010003,64000}];
find(1, 3) -> [{90010003,94000}];
find(2, 1) -> [{90010003,44000}];
find(2, 2) -> [{90010003,94000}];
find(2, 3) -> [{90010003,144000}];
find(3, 1) -> [];
find(4, 1) -> [];
find(_, _) -> undefined.

max_type() -> 4.

max_grade() -> 3.