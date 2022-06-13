% Automatically generated, do not edit
-module(cfg_guild_guard_rank).

-compile([export_all]).
-compile(nowarn_export_all).

find(Rank) when 1 =< Rank; Rank =< 1 -> [{90010019,4800,1}];
find(Rank) when 2 =< Rank; Rank =< 2 -> [{90010019,2200,1}];
find(Rank) when 3 =< Rank; Rank =< 3 -> [{90010019,2100,1}];
find(Rank) when 4 =< Rank; Rank =< 4 -> [{90010019,1950,1}];
find(Rank) when 5 =< Rank; Rank =< 5 -> [{90010019,1850,1}];
find(Rank) when 6 =< Rank; Rank =< 10 -> [{90010019,1750,1}];
find(Rank) when 11 =< Rank; Rank =< 20 -> [{90010019,1700,1}];
find(Rank) when 21 =< Rank; Rank =< 30 -> [{90010019,1650,1}];
find(Rank) when 31 =< Rank; Rank =< 60 -> [{90010019,1600,1}];
find(_) -> [].
