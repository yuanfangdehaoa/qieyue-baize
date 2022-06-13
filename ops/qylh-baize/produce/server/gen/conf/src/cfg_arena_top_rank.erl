% Automatically generated, do not edit
-module(cfg_arena_top_rank).

-compile([export_all]).
-compile(nowarn_export_all).

find(Rank) when Rank >= 1, Rank =< 1 -> [{14013,10},{90010005,500000}];
find(Rank) when Rank >= 2, Rank =< 2 -> [{14013,8},{90010005,400000}];
find(Rank) when Rank >= 3, Rank =< 3 -> [{14013,6},{90010005,300000}];
find(Rank) when Rank >= 4, Rank =< 10 -> [{14013,4},{90010005,200000}];
find(_) -> undefined.
