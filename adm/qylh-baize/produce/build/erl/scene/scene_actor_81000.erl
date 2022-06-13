-module(scene_actor_81000).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=4260, y=1580},
		#p_coord{x=1040, y=4420}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=4279, y=1560},
		#p_coord{x=1060, y=4400}
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
		{ 20702011,#p_coord{x=881, y=2037 } },
		{ 20702012,#p_coord{x=3854, y=4131 } },
		{ 20702013,#p_coord{x=2707, y=3089 } }
	].

%% 寻路点
get_waypoint() ->
	[
	].
