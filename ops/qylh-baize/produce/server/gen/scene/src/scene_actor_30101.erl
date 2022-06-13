-module(scene_actor_30101).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=1519, y=520},
		#p_coord{x=1519, y=540}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=1560, y=520},
		#p_coord{x=1540, y=540}
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
		{ 1002029,#p_coord{x=1057, y=377 } },
		{ 1002028,#p_coord{x=944, y=505 } },
		{ 1002027,#p_coord{x=992, y=651 } }
	].

%% 寻路点
get_waypoint() ->
	[
	].
