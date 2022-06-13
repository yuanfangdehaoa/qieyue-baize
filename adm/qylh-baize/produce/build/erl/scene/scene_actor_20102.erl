-module(scene_actor_20102).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=2520, y=1180},
		#p_coord{x=2539, y=1180},
		#p_coord{x=2520, y=1200},
		#p_coord{x=2539, y=1200}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=2520, y=1180},
		#p_coord{x=2539, y=1180},
		#p_coord{x=2520, y=1200},
		#p_coord{x=2539, y=1200}
	].

%% 跳跃点
get_jump() ->
	[
	].

%% 安全区
get_safe() ->
	[
		{114, 55},
		{114, 56},
		{114, 57},
		{114, 58},
		{114, 59},
		{115, 55},
		{115, 56},
		{115, 57},
		{115, 58},
		{115, 59},
		{115, 60},
		{116, 54},
		{116, 55},
		{116, 56},
		{116, 57},
		{116, 58},
		{116, 59},
		{116, 60},
		{116, 61},
		{116, 62},
		{117, 54},
		{117, 55},
		{117, 56},
		{117, 57},
		{117, 58},
		{117, 59},
		{117, 60},
		{117, 61},
		{117, 62},
		{118, 53},
		{118, 54},
		{118, 55},
		{118, 56},
		{118, 57},
		{118, 58},
		{118, 59},
		{118, 60},
		{118, 61},
		{118, 62},
		{119, 53},
		{119, 54},
		{119, 55},
		{119, 56},
		{119, 57},
		{119, 58},
		{119, 59},
		{119, 60},
		{119, 61},
		{119, 62},
		{120, 53},
		{120, 54},
		{120, 55},
		{120, 56},
		{120, 57},
		{120, 58},
		{120, 59},
		{120, 60},
		{120, 61},
		{120, 62},
		{120, 63},
		{121, 52},
		{121, 53},
		{121, 54},
		{121, 55},
		{121, 56},
		{121, 57},
		{121, 58},
		{121, 59},
		{121, 60},
		{121, 61},
		{121, 62},
		{121, 63},
		{121, 64},
		{122, 52},
		{122, 53},
		{122, 54},
		{122, 55},
		{122, 56},
		{122, 57},
		{122, 58},
		{122, 59},
		{122, 60},
		{122, 61},
		{122, 62},
		{122, 63},
		{122, 64},
		{123, 52},
		{123, 53},
		{123, 54},
		{123, 55},
		{123, 56},
		{123, 57},
		{123, 58},
		{123, 59},
		{123, 60},
		{123, 61},
		{123, 62},
		{123, 63},
		{123, 64},
		{123, 65},
		{124, 52},
		{124, 53},
		{124, 54},
		{124, 55},
		{124, 56},
		{124, 57},
		{124, 58},
		{124, 59},
		{124, 60},
		{124, 61},
		{124, 62},
		{124, 63},
		{124, 64},
		{124, 65},
		{125, 52},
		{125, 53},
		{125, 54},
		{125, 55},
		{125, 56},
		{125, 57},
		{125, 58},
		{125, 59},
		{125, 60},
		{125, 61},
		{125, 62},
		{125, 63},
		{125, 64},
		{125, 65},
		{126, 52},
		{126, 53},
		{126, 54},
		{126, 55},
		{126, 56},
		{126, 57},
		{126, 58},
		{126, 59},
		{126, 60},
		{126, 61},
		{126, 62},
		{126, 63},
		{126, 64},
		{126, 65},
		{127, 52},
		{127, 53},
		{127, 54},
		{127, 55},
		{127, 56},
		{127, 57},
		{127, 58},
		{127, 59},
		{127, 60},
		{127, 61},
		{127, 62},
		{127, 63},
		{127, 64},
		{127, 65},
		{128, 52},
		{128, 53},
		{128, 54},
		{128, 55},
		{128, 56},
		{128, 57},
		{128, 58},
		{128, 59},
		{128, 60},
		{128, 61},
		{128, 62},
		{128, 63},
		{128, 64},
		{128, 65},
		{129, 52},
		{129, 53},
		{129, 54},
		{129, 55},
		{129, 56},
		{129, 57},
		{129, 58},
		{129, 59},
		{129, 60},
		{129, 61},
		{129, 62},
		{129, 63},
		{129, 64},
		{129, 65},
		{130, 52},
		{130, 53},
		{130, 54},
		{130, 55},
		{130, 56},
		{130, 57},
		{130, 58},
		{130, 59},
		{130, 60},
		{130, 61},
		{130, 62},
		{130, 63},
		{130, 64},
		{130, 65},
		{131, 52},
		{131, 53},
		{131, 54},
		{131, 55},
		{131, 56},
		{131, 57},
		{131, 58},
		{131, 59},
		{131, 60},
		{131, 61},
		{131, 62},
		{131, 63},
		{131, 64},
		{131, 65},
		{132, 55},
		{132, 56},
		{132, 57},
		{132, 58},
		{132, 59},
		{132, 60},
		{132, 61},
		{132, 62},
		{132, 63},
		{132, 64},
		{132, 65},
		{133, 55},
		{133, 56},
		{133, 57},
		{133, 58},
		{133, 59},
		{133, 60},
		{133, 61},
		{133, 62},
		{133, 63},
		{133, 64},
		{133, 65},
		{134, 55},
		{134, 56},
		{134, 57},
		{134, 58},
		{134, 59},
		{134, 60},
		{134, 61},
		{134, 62},
		{134, 63},
		{134, 64},
		{134, 65},
		{135, 57},
		{135, 58},
		{135, 59},
		{135, 60},
		{135, 61},
		{135, 62},
		{135, 63},
		{135, 64},
		{135, 65},
		{136, 57},
		{136, 58},
		{136, 59},
		{136, 60},
		{136, 61},
		{136, 62},
		{136, 63},
		{136, 64},
		{137, 57},
		{137, 58},
		{137, 59},
		{137, 60},
		{137, 61},
		{137, 62},
		{138, 57},
		{138, 58},
		{138, 59},
		{138, 60},
		{138, 61},
		{138, 62},
		{139, 58},
		{139, 59},
		{139, 60},
		{139, 61},
		{139, 62},
		{140, 59},
		{140, 60}
	].

%% 寻宝区
get_hunt() ->
	[
	].

%% NPC 列表
get_npcs() ->
	[
	].

%% 怪物列表
get_creeps() ->
	[
		{ 20102001,#p_coord{x=5202, y=2329 } },
		{ 20102002,#p_coord{x=2215, y=2277 } },
		{ 20102003,#p_coord{x=3950, y=3325 } },
		{ 20102004,#p_coord{x=2054, y=4138 } },
		{ 20102005,#p_coord{x=5790, y=4375 } },
		{ 20102006,#p_coord{x=3768, y=5241 } }
	].

%% 寻路点
get_waypoint() ->
	[
	].
