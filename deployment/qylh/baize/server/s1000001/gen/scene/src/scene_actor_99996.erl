-module(scene_actor_99996).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=1920, y=620},
		#p_coord{x=1939, y=620},
		#p_coord{x=1960, y=620},
		#p_coord{x=1900, y=640},
		#p_coord{x=1920, y=640},
		#p_coord{x=1939, y=640},
		#p_coord{x=1960, y=640},
		#p_coord{x=1900, y=659},
		#p_coord{x=1920, y=659},
		#p_coord{x=1939, y=659},
		#p_coord{x=1960, y=659},
		#p_coord{x=1900, y=680},
		#p_coord{x=1920, y=680},
		#p_coord{x=1939, y=680},
		#p_coord{x=1960, y=680},
		#p_coord{x=1900, y=700},
		#p_coord{x=1920, y=700},
		#p_coord{x=1939, y=700},
		#p_coord{x=1960, y=700},
		#p_coord{x=1900, y=720},
		#p_coord{x=1920, y=720},
		#p_coord{x=1939, y=720},
		#p_coord{x=1900, y=740},
		#p_coord{x=1920, y=740},
		#p_coord{x=1939, y=740}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=1839, y=620},
		#p_coord{x=1860, y=620},
		#p_coord{x=1880, y=620},
		#p_coord{x=1839, y=640},
		#p_coord{x=1860, y=640},
		#p_coord{x=1880, y=640},
		#p_coord{x=1839, y=659},
		#p_coord{x=1860, y=659},
		#p_coord{x=1880, y=659},
		#p_coord{x=1839, y=680},
		#p_coord{x=1860, y=680},
		#p_coord{x=1880, y=680},
		#p_coord{x=1839, y=700},
		#p_coord{x=1860, y=700},
		#p_coord{x=1880, y=700},
		#p_coord{x=1839, y=720},
		#p_coord{x=1860, y=720},
		#p_coord{x=1880, y=720},
		#p_coord{x=1839, y=740},
		#p_coord{x=1860, y=740},
		#p_coord{x=1880, y=740},
		#p_coord{x=1839, y=759},
		#p_coord{x=1860, y=759},
		#p_coord{x=1880, y=759}
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
