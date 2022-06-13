% Automatically generated, do not edit
-module(cfg_cgw_creep).

-compile([export_all]).
-compile(nowarn_export_all).

find(20702011, WorldLv) when WorldLv >= 1, WorldLv =< 9999 -> {100001, 10000, 1.08e+07};
find(20702012, WorldLv) when WorldLv >= 1, WorldLv =< 9999 -> {100001, 10000, 1.08e+07};
find(20702013, WorldLv) when WorldLv >= 1, WorldLv =< 9999 -> {100001, 10000, 3.24e+07};
find(_, _) -> undefined.
