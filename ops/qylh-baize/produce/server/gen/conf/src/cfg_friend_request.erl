% Automatically generated, do not edit
-module(cfg_friend_request).

-compile([export_all]).
-compile(nowarn_export_all).

find(Level) when Level >= 1, Level =< 60 -> 20;
find(Level) when Level >= 61, Level =< 120 -> 25;
find(Level) when Level >= 121, Level =< 180 -> 30;
find(Level) when Level >= 181, Level =< 240 -> 35;
find(Level) when Level >= 241, Level =< 300 -> 40;
find(Level) when Level >= 301, Level =< 360 -> 45;
find(Level) when Level >= 361, Level =< 420 -> 50;
find(Level) when Level >= 421, Level =< 480 -> 55;
find(Level) when Level >= 481, Level =< 540 -> 60;
find(Level) when Level >= 541, Level =< 600 -> 65;
find(_) -> 0.

max() -> 65.
