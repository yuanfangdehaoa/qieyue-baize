-module(scene_actor_30403).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=1380, y=960},
		#p_coord{x=1400, y=960}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=1380, y=940},
		#p_coord{x=1400, y=940},
		#p_coord{x=1419, y=940}
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
