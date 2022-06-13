-module(scene_actor_30002).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=279, y=180},
		#p_coord{x=300, y=180},
		#p_coord{x=320, y=180},
		#p_coord{x=279, y=200},
		#p_coord{x=300, y=200},
		#p_coord{x=320, y=200},
		#p_coord{x=279, y=220},
		#p_coord{x=300, y=220},
		#p_coord{x=320, y=220},
		#p_coord{x=279, y=240},
		#p_coord{x=300, y=240},
		#p_coord{x=320, y=240}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=320, y=180},
		#p_coord{x=340, y=180},
		#p_coord{x=360, y=180},
		#p_coord{x=320, y=200},
		#p_coord{x=340, y=200},
		#p_coord{x=360, y=200},
		#p_coord{x=320, y=220},
		#p_coord{x=340, y=220},
		#p_coord{x=360, y=220},
		#p_coord{x=320, y=240},
		#p_coord{x=340, y=240},
		#p_coord{x=360, y=240}
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
