% Automatically generated, do not edit
-module(cfg_baby).

-compile([export_all]).
-compile(nowarn_export_all).

-include("baby.hrl").

find(1) -> #cfg_baby{
	gender     = 1,
	name       = "男宝宝",
	reqs       = 60,
	play_gain  = [{90010005,200000}],
	play_count = 3,
	growitem   = 13134,
	id         = 1001
};
find(2) -> #cfg_baby{
	gender     = 2,
	name       = "女宝宝",
	reqs       = 120,
	play_gain  = [{90010005,300000}],
	play_count = 3,
	growitem   = 13135,
	id         = 2001
};
find(_) -> undefined.

