-module(scene_actor_11314).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=4140, y=919},
		#p_coord{x=4160, y=919},
		#p_coord{x=4179, y=919},
		#p_coord{x=4140, y=940},
		#p_coord{x=4160, y=940},
		#p_coord{x=4179, y=940},
		#p_coord{x=4140, y=960},
		#p_coord{x=4160, y=960},
		#p_coord{x=4179, y=960},
		#p_coord{x=4140, y=980},
		#p_coord{x=4160, y=980},
		#p_coord{x=4179, y=980}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=4179, y=919},
		#p_coord{x=4200, y=919},
		#p_coord{x=4220, y=919},
		#p_coord{x=4179, y=940},
		#p_coord{x=4200, y=940},
		#p_coord{x=4220, y=940},
		#p_coord{x=4179, y=960},
		#p_coord{x=4200, y=960},
		#p_coord{x=4220, y=960},
		#p_coord{x=4179, y=980},
		#p_coord{x=4200, y=980},
		#p_coord{x=4220, y=980}
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
