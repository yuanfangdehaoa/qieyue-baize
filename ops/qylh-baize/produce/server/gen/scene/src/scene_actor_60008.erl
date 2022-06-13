-module(scene_actor_60008).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=1500, y=1219}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=1500, y=1200}
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
		{ 6000806,#p_coord{x=1031, y=1243 } }
	].

%% 寻路点
get_waypoint() ->
	[
	].
