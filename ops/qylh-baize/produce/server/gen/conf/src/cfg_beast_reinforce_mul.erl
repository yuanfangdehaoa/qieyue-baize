% Automatically generated, do not edit
-module(cfg_beast_reinforce_mul).

-compile([export_all]).
-compile(nowarn_export_all).

-include("beast.hrl").

find(Exp) when Exp >= 0, Exp =< 1000 -> [{90010003,500}];
find(Exp) when Exp >= 1001, Exp =< 5000 -> [{90010003,5000}];
find(Exp) when Exp >= 5001, Exp =< 99999999 -> [{90010003,10000}];
find(_) -> undefined.
