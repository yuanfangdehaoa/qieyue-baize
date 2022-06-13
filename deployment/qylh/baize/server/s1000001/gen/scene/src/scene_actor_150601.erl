-module(scene_actor_150601).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=260, y=260},
		#p_coord{x=279, y=260},
		#p_coord{x=260, y=279},
		#p_coord{x=279, y=279}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=300, y=260},
		#p_coord{x=320, y=260},
		#p_coord{x=300, y=279},
		#p_coord{x=320, y=279}
	].

%% 跳跃点
get_jump() ->
	[
	].

%% 安全区
get_safe() ->
	[
		{13, 15},
		{13, 16},
		{13, 17},
		{14, 15},
		{14, 16},
		{14, 17},
		{15, 15},
		{15, 16},
		{15, 17},
		{16, 15},
		{16, 16},
		{16, 17}
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
