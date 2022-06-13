% Automatically generated, do not edit
-module(cfg_arena_suppress).

-compile([export_all]).
-compile(nowarn_export_all).

find(Power) when Power >= -999, Power < -0.1 -> [301310001];
find(Power) when Power >= -0.1, Power < 0 -> [301310002];
find(Power) when Power >= 0, Power < 0.1 -> [301310003];
find(Power) when Power >= 0.1, Power < 1 -> [301310004];
find(_) -> undefined.
