% Automatically generated, do not edit
-module(cfg_equip_suite_level).

-compile([export_all]).
-compile(nowarn_export_all).

-include("equip.hrl").

find(1) -> #cfg_equip_suite_level{
	level = 1,
	name  = "不朽",
	color = 5,
	star  = 1
};
find(2) -> #cfg_equip_suite_level{
	level = 2,
	name  = "光谕",
	color = 5,
	star  = 2
};
find(_) -> undefined.
