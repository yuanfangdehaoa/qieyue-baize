% Automatically generated, do not edit
-module(cfg_guild_question_score).

-compile([export_all]).
-compile(nowarn_export_all).

-include("guild_house.hrl").

score(Rank) when Rank >= 1 andalso Rank =< 1 -> 100;
score(Rank) when Rank >= 2 andalso Rank =< 2 -> 90;
score(Rank) when Rank >= 3 andalso Rank =< 3 -> 80;
score(Rank) when Rank >= 4 andalso Rank =< 4 -> 75;
score(Rank) when Rank >= 5 andalso Rank =< 5 -> 70;
score(Rank) when Rank >= 6 andalso Rank =< 6 -> 65;
score(Rank) when Rank >= 7 andalso Rank =< 7 -> 60;
score(Rank) when Rank >= 8 andalso Rank =< 8 -> 55;
score(Rank) when Rank >= 9 andalso Rank =< 9 -> 50;
score(Rank) when Rank >= 10 andalso Rank =< 10 -> 45;
score(Rank) when Rank >= 11 andalso Rank =< 11 -> 40;
score(Rank) when Rank >= 12 andalso Rank =< 12 -> 35;
score(Rank) when Rank >= 13 andalso Rank =< 13 -> 30;
score(Rank) when Rank >= 14 andalso Rank =< 14 -> 25;
score(Rank) when Rank >= 15 andalso Rank =< 15 -> 20;
score(Rank) when Rank >= 16 andalso Rank =< 16 -> 15;
score(Rank) when Rank >= 17 andalso Rank =< 1000 -> 10;
score(_) -> 1.
