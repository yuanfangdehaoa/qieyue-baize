% Automatically generated, do not edit
-module(cfg_warrior_reward).

-compile([export_all]).
-compile(nowarn_export_all).

-include("warrior.hrl").

gain(Rank) when Rank >= 1 andalso Rank =< 1 -> [{46120,1,1},{51000,18,1},{15067,3,1},{90010008,5000,1}];
gain(Rank) when Rank >= 2 andalso Rank =< 2 -> [{46121,1,1},{51000,16,1},{15067,2,1},{90010008,3000,1}];
gain(Rank) when Rank >= 3 andalso Rank =< 3 -> [{46122,1,1},{51000,16,1},{15067,2,1},{90010008,3000,1}];
gain(Rank) when Rank >= 4 andalso Rank =< 4 -> [{51000,16,1},{15067,2,1},{90010008,2000,1}];
gain(Rank) when Rank >= 5 andalso Rank =< 5 -> [{51000,16,1},{15067,2,1},{90010008,2000,1}];
gain(Rank) when Rank >= 6 andalso Rank =< 6 -> [{51000,16,1},{15067,2,1},{90010008,2000,1}];
gain(Rank) when Rank >= 7 andalso Rank =< 7 -> [{51000,16,1},{15067,2,1},{90010008,2000,1}];
gain(Rank) when Rank >= 8 andalso Rank =< 8 -> [{51000,16,1},{15067,2,1},{90010008,2000,1}];
gain(Rank) when Rank >= 9 andalso Rank =< 9 -> [{51000,16,1},{15067,2,1},{90010008,2000,1}];
gain(Rank) when Rank >= 10 andalso Rank =< 10 -> [{51000,16,1},{15067,2,1},{90010008,2000,1}];
gain(Rank) when Rank >= 11 andalso Rank =< 60 -> [{51000,15,1},{15067,2,1},{90010008,2000,1}];
gain(_) -> [].

cross_gain(Rank) when Rank >= 1 andalso Rank =< 1 -> [{46120,1,1},{51000,27,1},{15067,4,1},{90010008,7500,1}];
cross_gain(Rank) when Rank >= 2 andalso Rank =< 2 -> [{46121,1,1},{51000,24,1},{15067,3,1},{90010008,4500,1}];
cross_gain(Rank) when Rank >= 3 andalso Rank =< 3 -> [{46122,1,1},{51000,24,1},{15067,3,1},{90010008,4500,1}];
cross_gain(Rank) when Rank >= 4 andalso Rank =< 4 -> [{51000,24,1},{15067,3,1},{90010008,3000,1}];
cross_gain(Rank) when Rank >= 5 andalso Rank =< 5 -> [{51000,24,1},{15067,3,1},{90010008,3000,1}];
cross_gain(Rank) when Rank >= 6 andalso Rank =< 6 -> [{51000,24,1},{15067,3,1},{90010008,3000,1}];
cross_gain(Rank) when Rank >= 7 andalso Rank =< 7 -> [{51000,24,1},{15067,3,1},{90010008,3000,1}];
cross_gain(Rank) when Rank >= 8 andalso Rank =< 8 -> [{51000,24,1},{15067,3,1},{90010008,3000,1}];
cross_gain(Rank) when Rank >= 9 andalso Rank =< 9 -> [{51000,24,1},{15067,3,1},{90010008,3000,1}];
cross_gain(Rank) when Rank >= 10 andalso Rank =< 10 -> [{51000,24,1},{15067,3,1},{90010008,3000,1}];
cross_gain(Rank) when Rank >= 11 andalso Rank =< 60 -> [{51000,22,1},{15067,3,1},{90010008,3000,1}];
cross_gain(_) -> [].
