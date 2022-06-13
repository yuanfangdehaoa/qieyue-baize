% Automatically generated, do not edit
-module(cfg_baby_like_reward).

-compile([export_all]).
-compile(nowarn_export_all).

-include("baby.hrl").

reward(Rank) when Rank >= 1 andalso Rank =< 1 -> [{15215,1,1},{15219,1,1}];
reward(Rank) when Rank >= 2 andalso Rank =< 3 -> [{15216,1,1},{15219,1,1}];
reward(Rank) when Rank >= 4 andalso Rank =< 10 -> [{15219,1,1},{15217,1,1}];
reward(_) -> [].
