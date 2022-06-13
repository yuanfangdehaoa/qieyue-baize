% Automatically generated, do not edit
-module(cfg_guild_house_kill).

-compile([export_all]).
-compile(nowarn_export_all).

-include("guild_house.hrl").

point(Duration) when Duration >= 0 andalso Duration =< 240 -> "S";
point(Duration) when Duration >= 241 andalso Duration =< 300 -> "A";
point(Duration) when Duration >= 301 andalso Duration =< 360 -> "B";
point(Duration) when Duration >= 361 andalso Duration =< 9999 -> "C";
point(_) -> undefined.
