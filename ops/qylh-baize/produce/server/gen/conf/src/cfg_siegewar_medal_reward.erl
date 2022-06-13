% Automatically generated, do not edit
-module(cfg_siegewar_medal_reward).

-compile([export_all]).
-compile(nowarn_export_all).

find(150, Level) when Level >= 1, Level =< 999 -> [{15272,1,1}];
find(400, Level) when Level >= 1, Level =< 999 -> [{57002,2,1}];
find(750, Level) when Level >= 1, Level =< 999 -> [{90001,1,1}];
find(1250, Level) when Level >= 1, Level =< 999 -> [{57201,1,1}];
find(_, _) -> [].

max() -> 1250.
