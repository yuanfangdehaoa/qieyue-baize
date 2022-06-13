% Automatically generated, do not edit
-module(cfg_guildwar_add_score).

-compile([export_all]).
-compile(nowarn_export_all).

find(Time) when 1 =< Time andalso Time =< 10 -> 5;
find(Time) when 11 =< Time andalso Time =< 100 -> 10;
find(Time) when 101 =< Time andalso Time =< 1200 -> 15;
find(_) -> 0.