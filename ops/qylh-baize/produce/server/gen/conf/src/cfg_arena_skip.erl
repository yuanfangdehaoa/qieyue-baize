% Automatically generated, do not edit
-module(cfg_arena_skip).

-compile([export_all]).
-compile(nowarn_export_all).

find(Power) when Power >= -999, Power < -0.1 -> 10000;
find(Power) when Power >= -0.1, Power < 0 -> 9500;
find(Power) when Power >= 0, Power < 0.1 -> 500;
find(Power) when Power >= 0.1, Power < 1 -> 0;
find(_) -> undefined.
