-module(scene_actor_30410).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=2660, y=1260},
		#p_coord{x=2080, y=1319},
		#p_coord{x=2339, y=1340},
		#p_coord{x=2760, y=1380},
		#p_coord{x=2120, y=1419},
		#p_coord{x=1739, y=1460},
		#p_coord{x=2020, y=1480},
		#p_coord{x=3160, y=1480},
		#p_coord{x=2600, y=1500},
		#p_coord{x=3320, y=1519},
		#p_coord{x=1540, y=1560},
		#p_coord{x=2260, y=1560},
		#p_coord{x=2500, y=1600},
		#p_coord{x=3479, y=1600},
		#p_coord{x=1880, y=1660},
		#p_coord{x=3020, y=1680},
		#p_coord{x=2739, y=1700},
		#p_coord{x=2360, y=1739},
		#p_coord{x=2539, y=1739},
		#p_coord{x=2039, y=1780},
		#p_coord{x=3460, y=1780},
		#p_coord{x=1620, y=1820},
		#p_coord{x=2660, y=1820},
		#p_coord{x=3220, y=1880},
		#p_coord{x=2680, y=1900},
		#p_coord{x=2320, y=1939},
		#p_coord{x=1739, y=1960},
		#p_coord{x=3440, y=1960},
		#p_coord{x=2660, y=1980},
		#p_coord{x=3460, y=2000},
		#p_coord{x=3200, y=2039},
		#p_coord{x=2800, y=2080},
		#p_coord{x=1939, y=2100},
		#p_coord{x=2320, y=2160},
		#p_coord{x=2960, y=2200}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=2480, y=1280},
		#p_coord{x=2900, y=1280},
		#p_coord{x=2900, y=1300},
		#p_coord{x=3240, y=1400},
		#p_coord{x=2339, y=1440},
		#p_coord{x=2639, y=1440},
		#p_coord{x=2900, y=1460},
		#p_coord{x=3120, y=1600},
		#p_coord{x=2080, y=1620},
		#p_coord{x=1739, y=1660},
		#p_coord{x=3400, y=1680},
		#p_coord{x=2580, y=1739},
		#p_coord{x=3240, y=1739},
		#p_coord{x=1780, y=1820},
		#p_coord{x=2100, y=1820},
		#p_coord{x=2360, y=1860},
		#p_coord{x=3139, y=1880},
		#p_coord{x=3340, y=1900},
		#p_coord{x=2500, y=1920},
		#p_coord{x=1939, y=1960},
		#p_coord{x=3039, y=2020},
		#p_coord{x=2220, y=2039},
		#p_coord{x=2500, y=2039},
		#p_coord{x=2400, y=2100},
		#p_coord{x=3120, y=2100},
		#p_coord{x=2700, y=2200}
	].

%% 跳跃点
get_jump() ->
	[
	].

%% 安全区
get_safe() ->
	[
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
	].

%% 寻路点
get_waypoint() ->
	[
	].
