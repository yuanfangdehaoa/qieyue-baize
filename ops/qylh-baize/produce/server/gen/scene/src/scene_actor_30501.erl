-module(scene_actor_30501).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(0) ->
	{#p_coord{x=3354,y=1781},0,#p_coord{x=0,y=0}};
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=2339, y=1019},
		#p_coord{x=2360, y=1019},
		#p_coord{x=2339, y=1040},
		#p_coord{x=2360, y=1040}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=2400, y=1019},
		#p_coord{x=2420, y=1019},
		#p_coord{x=2400, y=1040},
		#p_coord{x=2420, y=1040}
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
