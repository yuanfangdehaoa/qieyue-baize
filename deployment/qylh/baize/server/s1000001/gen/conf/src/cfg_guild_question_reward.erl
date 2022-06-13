% Automatically generated, do not edit
-module(cfg_guild_question_reward).

-compile([export_all]).
-compile(nowarn_export_all).

-include("guild_house.hrl").

reward(Rank) when Rank >= 1 andalso Rank =< 1 -> [{46019,1,1},{11152,2,1},{11151,1,1},{90010011,5000,1}];
reward(Rank) when Rank >= 2 andalso Rank =< 2 -> [{46020,1,1},{11152,1,1},{11151,1,1},{90010011,5000,1}];
reward(Rank) when Rank >= 3 andalso Rank =< 3 -> [{46021,1,1},{11152,1,1},{11151,1,1},{90010011,4000,1}];
reward(Rank) when Rank >= 4 andalso Rank =< 4 -> [{11151,1,1},{11150,1,1},{90010011,4000,1}];
reward(Rank) when Rank >= 5 andalso Rank =< 5 -> [{11151,1,1},{11150,1,1},{90010011,3000,1}];
reward(Rank) when Rank >= 6 andalso Rank =< 10 -> [{11150,1,1},{90010011,3000,1}];
reward(Rank) when Rank >= 11 andalso Rank =< 999 -> [{90010011,3000,1}];
reward(_) -> [].
