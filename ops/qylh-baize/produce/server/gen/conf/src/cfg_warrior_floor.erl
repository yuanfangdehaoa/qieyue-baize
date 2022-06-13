% Automatically generated, do not edit
-module(cfg_warrior_floor).

-compile([export_all]).
-compile(nowarn_export_all).

-include("warrior.hrl").

find(1) -> #cfg_warrior_floor{
	floor          = 1,
	kill_target    = 3,
	gain           = [{90010018,1881,1},{51000,5,1}],
	cross_gain     = [{90010018,2822,1},{51000,7,1}],
	is_down        = false,
	prob           = 0,
	score          = [2,1],
	kill_num       = [2,1],
	scene_id       = [{10231,30391},{10232,30393}]
};
find(2) -> #cfg_warrior_floor{
	floor          = 2,
	kill_target    = 5,
	gain           = [{90010018,1881,1},{51000,6,1}],
	cross_gain     = [{90010018,2822,1},{51000,9,1}],
	is_down        = false,
	prob           = 0,
	score          = [2,1],
	kill_num       = [2,1],
	scene_id       = [{10231,30391},{10232,30393}]
};
find(3) -> #cfg_warrior_floor{
	floor          = 3,
	kill_target    = 6,
	gain           = [{90010018,3763,1},{51000,7,1}],
	cross_gain     = [{90010018,5644,1},{51000,10,1}],
	is_down        = false,
	prob           = 0,
	score          = [4,2],
	kill_num       = [2,1],
	scene_id       = [{10231,30391},{10232,30393}]
};
find(4) -> #cfg_warrior_floor{
	floor          = 4,
	kill_target    = 8,
	gain           = [{90010018,3763,1},{51000,9,1}],
	cross_gain     = [{90010018,5644,1},{51000,13,1}],
	is_down        = false,
	prob           = 0,
	score          = [4,2],
	kill_num       = [2,1],
	scene_id       = [{10231,30391},{10232,30393}]
};
find(5) -> #cfg_warrior_floor{
	floor          = 5,
	kill_target    = 10,
	gain           = [{90010018,5644,1},{51001,2,1},{15067,2,1}],
	cross_gain     = [{90010018,8467,1},{51001,3,1},{15067,3,1}],
	is_down        = false,
	prob           = 0,
	score          = [6,3],
	kill_num       = [2,1],
	scene_id       = [{10231,30391},{10232,30393}]
};
find(6) -> #cfg_warrior_floor{
	floor          = 6,
	kill_target    = 13,
	gain           = [{90010018,5644,1},{51001,3,1},{15067,3,1}],
	cross_gain     = [{90010018,8467,1},{51001,4,1},{15067,4,1}],
	is_down        = false,
	prob           = 0,
	score          = [6,3],
	kill_num       = [2,1],
	scene_id       = [{10231,30391},{10232,30393}]
};
find(7) -> #cfg_warrior_floor{
	floor          = 7,
	kill_target    = 0,
	gain           = [{90010018,9411,1},{51001,4,1},{15067,3,1}],
	cross_gain     = [{90010018,14115,1},{51001,6,1},{15067,4,1}],
	is_down        = true,
	prob           = 2000,
	score          = [10,5],
	kill_num       = [2,1],
	scene_id       = [{10231,30392},{10232,30394}]
};
find(_) -> undefined.

floors() -> [5,6,7,1,2,3,4].
