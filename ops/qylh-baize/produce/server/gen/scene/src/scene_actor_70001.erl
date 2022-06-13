-module(scene_actor_70001).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=240, y=80},
		#p_coord{x=260, y=80},
		#p_coord{x=279, y=80},
		#p_coord{x=220, y=100},
		#p_coord{x=240, y=100},
		#p_coord{x=260, y=100},
		#p_coord{x=279, y=100},
		#p_coord{x=220, y=120},
		#p_coord{x=240, y=120},
		#p_coord{x=260, y=120},
		#p_coord{x=279, y=120},
		#p_coord{x=220, y=139},
		#p_coord{x=240, y=139},
		#p_coord{x=260, y=139}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=279, y=60},
		#p_coord{x=300, y=60},
		#p_coord{x=320, y=60},
		#p_coord{x=279, y=80},
		#p_coord{x=300, y=80},
		#p_coord{x=320, y=80},
		#p_coord{x=279, y=100},
		#p_coord{x=300, y=100},
		#p_coord{x=320, y=100},
		#p_coord{x=279, y=120},
		#p_coord{x=300, y=120},
		#p_coord{x=320, y=120},
		#p_coord{x=279, y=139},
		#p_coord{x=300, y=139},
		#p_coord{x=320, y=139}
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
