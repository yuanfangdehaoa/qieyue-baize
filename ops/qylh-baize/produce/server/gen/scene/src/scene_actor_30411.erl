-module(scene_actor_30411).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=1019, y=1260},
		#p_coord{x=2580, y=2000}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=1019, y=1240},
		#p_coord{x=2600, y=2000}
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
