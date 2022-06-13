% Automatically generated, do not edit
-module(cfg_guildwar_role_reward).

-compile([export_all]).
-compile(nowarn_export_all).

find(1, Rank) when 1 =< Rank andalso Rank =< 1 -> [{90010011,92000}];
find(1, Rank) when 2 =< Rank andalso Rank =< 4 -> [{90010011,82000}];
find(1, Rank) when 5 =< Rank andalso Rank =< 10 -> [{90010011,72000}];
find(1, Rank) when 11 =< Rank andalso Rank =< 60 -> [{90010011,62000}];
find(2, Rank) when 1 =< Rank andalso Rank =< 1 -> [{90010011,84000}];
find(2, Rank) when 2 =< Rank andalso Rank =< 4 -> [{90010011,75000}];
find(2, Rank) when 5 =< Rank andalso Rank =< 10 -> [{90010011,65000}];
find(2, Rank) when 11 =< Rank andalso Rank =< 60 -> [{90010011,57000}];
find(3, Rank) when 1 =< Rank andalso Rank =< 1 -> [{90010011,76000}];
find(3, Rank) when 2 =< Rank andalso Rank =< 4 -> [{90010011,68000}];
find(3, Rank) when 5 =< Rank andalso Rank =< 10 -> [{90010011,58000}];
find(3, Rank) when 11 =< Rank andalso Rank =< 60 -> [{90010011,52000}];
find(4, Rank) when 1 =< Rank andalso Rank =< 1 -> [{90010011,68000}];
find(4, Rank) when 2 =< Rank andalso Rank =< 4 -> [{90010011,61000}];
find(4, Rank) when 5 =< Rank andalso Rank =< 10 -> [{90010011,51000}];
find(4, Rank) when 11 =< Rank andalso Rank =< 60 -> [{90010011,47000}];
find(5, Rank) when 1 =< Rank andalso Rank =< 1 -> [{90010011,60000}];
find(5, Rank) when 2 =< Rank andalso Rank =< 4 -> [{90010011,54000}];
find(5, Rank) when 5 =< Rank andalso Rank =< 10 -> [{90010011,44000}];
find(5, Rank) when 11 =< Rank andalso Rank =< 60 -> [{90010011,42000}];
find(_, _) -> [].
