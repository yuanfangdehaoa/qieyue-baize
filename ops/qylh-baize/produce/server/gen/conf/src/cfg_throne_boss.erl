% Automatically generated, do not edit
-module(cfg_throne_boss).

-compile([export_all]).
-compile(nowarn_export_all).

-include("throne.hrl").

find(20601001) -> #cfg_throne_boss{
	id     = 20601001,
	name   = "魅蝎-青莲",
	scene  = 80101,
	coord  = {1050,3700},
	score  = 30,
	attr   = {20601000,100000,3000},
	reborn = 90
};
find(20601002) -> #cfg_throne_boss{
	id     = 20601002,
	name   = "魅蝎-嗜血",
	scene  = 80101,
	coord  = {1100,1950},
	score  = 30,
	attr   = {20601000,100000,3000},
	reborn = 90
};
find(20601003) -> #cfg_throne_boss{
	id     = 20601003,
	name   = "魅蝎-狂怒",
	scene  = 80101,
	coord  = {6250,3750},
	score  = 30,
	attr   = {20601000,100000,3000},
	reborn = 90
};
find(20601004) -> #cfg_throne_boss{
	id     = 20601004,
	name   = "魅蝎-暗影",
	scene  = 80101,
	coord  = {6250,1650},
	score  = 30,
	attr   = {20601000,100000,3000},
	reborn = 90
};
find(20601005) -> #cfg_throne_boss{
	id     = 20601005,
	name   = "魅蝎-守护",
	scene  = 80101,
	coord  = {3550,4400},
	score  = 30,
	attr   = {20601000,100000,3000},
	reborn = 90
};
find(20601006) -> #cfg_throne_boss{
	id     = 20601006,
	name   = "魅蝎-星语",
	scene  = 80101,
	coord  = {3500,1130},
	score  = 30,
	attr   = {20601000,100000,3000},
	reborn = 90
};
find(20602001) -> #cfg_throne_boss{
	id     = 20602001,
	name   = "魅蝎-青莲",
	scene  = 80102,
	coord  = {1050,3700},
	score  = 30,
	attr   = {20601000,100000,3000},
	reborn = 90
};
find(20602002) -> #cfg_throne_boss{
	id     = 20602002,
	name   = "魅蝎-嗜血",
	scene  = 80102,
	coord  = {1100,1950},
	score  = 30,
	attr   = {20601000,100000,3000},
	reborn = 90
};
find(20602003) -> #cfg_throne_boss{
	id     = 20602003,
	name   = "魅蝎-狂怒",
	scene  = 80102,
	coord  = {6250,3750},
	score  = 30,
	attr   = {20601000,100000,3000},
	reborn = 90
};
find(20602004) -> #cfg_throne_boss{
	id     = 20602004,
	name   = "魅蝎-暗影",
	scene  = 80102,
	coord  = {6250,1650},
	score  = 30,
	attr   = {20601000,100000,3000},
	reborn = 90
};
find(20602005) -> #cfg_throne_boss{
	id     = 20602005,
	name   = "魅蝎-守护",
	scene  = 80102,
	coord  = {3550,4400},
	score  = 30,
	attr   = {20601000,100000,3000},
	reborn = 90
};
find(20602006) -> #cfg_throne_boss{
	id     = 20602006,
	name   = "魅蝎-星语",
	scene  = 80102,
	coord  = {3500,1130},
	score  = 30,
	attr   = {20601000,100000,3000},
	reborn = 90
};
find(20602007) -> #cfg_throne_boss{
	id     = 20602007,
	name   = "北域苍龙",
	scene  = 80103,
	coord  = {1330,5620},
	score  = 0,
	attr   = {20601000,150000,5000},
	reborn = 180
};
find(20602008) -> #cfg_throne_boss{
	id     = 20602008,
	name   = "西域苍龙",
	scene  = 80103,
	coord  = {1390,1000},
	score  = 0,
	attr   = {20601000,150000,5000},
	reborn = 180
};
find(20602009) -> #cfg_throne_boss{
	id     = 20602009,
	name   = "东域苍龙",
	scene  = 80103,
	coord  = {8220,5620},
	score  = 0,
	attr   = {20601000,150000,5000},
	reborn = 180
};
find(20602010) -> #cfg_throne_boss{
	id     = 20602010,
	name   = "南域苍龙",
	scene  = 80103,
	coord  = {8220,1000},
	score  = 0,
	attr   = {20601000,150000,5000},
	reborn = 180
};
find(_) -> undefined.

scenes() -> [80101,80102,80103].

bosses() -> [20601006,20602001,20602005,20602006,20602007,20602008,20601001,20601005,20602002,20602010,20601002,20601003,20601004,20602003,20602004,20602009].
