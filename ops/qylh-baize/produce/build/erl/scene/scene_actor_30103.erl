-module(scene_actor_30103).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=480, y=320},
		#p_coord{x=500, y=320}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=500, y=279},
		#p_coord{x=500, y=300}
	].

%% 跳跃点
get_jump() ->
	[
	].

%% 安全区
get_safe() ->
	[
		{24, 13},
		{24, 14},
		{24, 15}
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
