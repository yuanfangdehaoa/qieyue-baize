% Automatically generated, do not edit
-module(cfg_combat1v1_cross_limit).

-compile([export_all]).
-compile(nowarn_export_all).

-include("combat1v1.hrl").

find(Times) when Times >= 1, Times =< 10 -> #cfg_combat1v1_limit{buy=[], has_reward=true};
find(Times) when Times >= 11, Times =< 15 -> #cfg_combat1v1_limit{buy=[{90010004,500}], has_reward=true};
find(_) -> undefined.

max() -> 15.


max_free() -> 10.
