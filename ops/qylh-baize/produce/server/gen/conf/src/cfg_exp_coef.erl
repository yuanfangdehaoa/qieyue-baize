% Automatically generated, do not edit
-module(cfg_exp_coef).

-compile([export_all]).
-compile(nowarn_export_all).

find(DiffLv) when 100 =< DiffLv, DiffLv =< 500 -> 0;
find(DiffLv) when 50 =< DiffLv, DiffLv =< 99 -> 3000;
find(DiffLv) when -29 =< DiffLv, DiffLv =< 49 -> 10000;
find(DiffLv) when -50 =< DiffLv, DiffLv =< -30 -> 9000;
find(DiffLv) when -300 =< DiffLv, DiffLv =< -51 -> 5000;
find(_) ->
	10000.