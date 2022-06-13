% Automatically generated, do not edit
-module(cfg_world_level).

-compile([export_all]).
-compile(nowarn_export_all).

find(DiffLv) when -999 =< DiffLv, DiffLv =< -151 -> 24000;
find(DiffLv) when -150 =< DiffLv, DiffLv =< -101 -> 20000;
find(DiffLv) when -100 =< DiffLv, DiffLv =< -81 -> 15000;
find(DiffLv) when -80 =< DiffLv, DiffLv =< -61 -> 11500;
find(DiffLv) when -60 =< DiffLv, DiffLv =< -51 -> 9000;
find(DiffLv) when -50 =< DiffLv, DiffLv =< -41 -> 7000;
find(DiffLv) when -40 =< DiffLv, DiffLv =< -31 -> 5000;
find(DiffLv) when -30 =< DiffLv, DiffLv =< -21 -> 3000;
find(DiffLv) when -20 =< DiffLv, DiffLv =< 999 -> 0;
find(_) -> 0.
