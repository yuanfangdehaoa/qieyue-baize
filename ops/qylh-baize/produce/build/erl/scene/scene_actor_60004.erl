-module(scene_actor_60004).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=2120, y=60},
		#p_coord{x=2139, y=60},
		#p_coord{x=2160, y=60},
		#p_coord{x=2180, y=60},
		#p_coord{x=2120, y=80},
		#p_coord{x=2139, y=80},
		#p_coord{x=2160, y=80},
		#p_coord{x=2180, y=80},
		#p_coord{x=2120, y=100},
		#p_coord{x=2139, y=100},
		#p_coord{x=2160, y=100},
		#p_coord{x=2180, y=100},
		#p_coord{x=2120, y=120},
		#p_coord{x=2139, y=120},
		#p_coord{x=2160, y=120},
		#p_coord{x=2180, y=120},
		#p_coord{x=2120, y=139},
		#p_coord{x=2139, y=139},
		#p_coord{x=2160, y=139},
		#p_coord{x=2180, y=139}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=2220, y=40},
		#p_coord{x=2239, y=40},
		#p_coord{x=2260, y=40},
		#p_coord{x=2180, y=60},
		#p_coord{x=2200, y=60},
		#p_coord{x=2220, y=60},
		#p_coord{x=2239, y=60},
		#p_coord{x=2260, y=60},
		#p_coord{x=2180, y=80},
		#p_coord{x=2200, y=80},
		#p_coord{x=2220, y=80},
		#p_coord{x=2239, y=80},
		#p_coord{x=2260, y=80},
		#p_coord{x=2180, y=100},
		#p_coord{x=2200, y=100},
		#p_coord{x=2220, y=100},
		#p_coord{x=2239, y=100},
		#p_coord{x=2260, y=100},
		#p_coord{x=2180, y=120},
		#p_coord{x=2200, y=120},
		#p_coord{x=2220, y=120},
		#p_coord{x=2239, y=120},
		#p_coord{x=2260, y=120},
		#p_coord{x=2180, y=139},
		#p_coord{x=2200, y=139},
		#p_coord{x=2220, y=139},
		#p_coord{x=2239, y=139}
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
