% Automatically generated, do not edit
-module(cfg_arena_rank).

-compile([export_all]).
-compile(nowarn_export_all).

find(Rank) when Rank >= 1, Rank =< 1 -> [{90010008,15000},{90010005,3000000}];
find(Rank) when Rank >= 2, Rank =< 3 -> [{90010008,13000},{90010005,3000000}];
find(Rank) when Rank >= 4, Rank =< 10 -> [{90010008,11000},{90010005,2500000}];
find(Rank) when Rank >= 11, Rank =< 20 -> [{90010008,10000},{90010005,2000000}];
find(Rank) when Rank >= 21, Rank =< 50 -> [{90010008,8000},{90010005,1500000}];
find(Rank) when Rank >= 51, Rank =< 100 -> [{90010008,7000},{90010005,1000000}];
find(Rank) when Rank >= 101, Rank =< 9999 -> [{90010008,5000},{90010005,1000000}];
find(_) -> undefined.
