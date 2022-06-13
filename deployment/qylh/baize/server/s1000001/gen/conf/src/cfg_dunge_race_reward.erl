% Automatically generated, do not edit
-module(cfg_dunge_race_reward).

-compile([export_all]).
-compile(nowarn_export_all).

find(Level, 1) when Level >= 1, Level =< 999 -> [{90010018,3000},{90010005,200000},{51000,3}];
find(Level, 2) when Level >= 1, Level =< 999 -> [{90010018,2700},{90010005,180000},{51000,3}];
find(Level, 3) when Level >= 1, Level =< 999 -> [{90010018,2400},{90010005,160000},{51000,3}];
find(_, _) -> undefined.
