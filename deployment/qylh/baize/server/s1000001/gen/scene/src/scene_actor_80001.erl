-module(scene_actor_80001).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=5060, y=1540},
		#p_coord{x=2460, y=1600},
		#p_coord{x=3740, y=1820}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=5100, y=1540},
		#p_coord{x=2480, y=1620},
		#p_coord{x=3779, y=1820}
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
