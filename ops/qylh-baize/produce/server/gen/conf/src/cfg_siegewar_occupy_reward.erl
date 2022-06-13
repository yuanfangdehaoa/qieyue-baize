% Automatically generated, do not edit
-module(cfg_siegewar_occupy_reward).

-compile([export_all]).
-compile(nowarn_export_all).

find(Level) when Level >= 1, Level =< 9999 -> [{60,1}];
find(_) -> [].
