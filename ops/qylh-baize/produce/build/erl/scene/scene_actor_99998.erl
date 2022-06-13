-module(scene_actor_99998).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=4100, y=4220},
		#p_coord{x=4120, y=4220},
		#p_coord{x=4100, y=4240},
		#p_coord{x=4120, y=4240},
		#p_coord{x=4100, y=4260},
		#p_coord{x=4120, y=4260},
		#p_coord{x=4100, y=4279},
		#p_coord{x=4120, y=4279},
		#p_coord{x=4100, y=4300},
		#p_coord{x=4120, y=4300},
		#p_coord{x=4100, y=4320},
		#p_coord{x=4120, y=4320},
		#p_coord{x=4100, y=4340},
		#p_coord{x=4120, y=4340}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=4140, y=4200},
		#p_coord{x=4160, y=4200},
		#p_coord{x=4140, y=4220},
		#p_coord{x=4160, y=4220},
		#p_coord{x=4140, y=4240},
		#p_coord{x=4160, y=4240},
		#p_coord{x=4140, y=4260},
		#p_coord{x=4160, y=4260},
		#p_coord{x=4140, y=4279},
		#p_coord{x=4160, y=4279},
		#p_coord{x=4140, y=4300},
		#p_coord{x=4160, y=4300},
		#p_coord{x=4140, y=4320},
		#p_coord{x=4160, y=4320},
		#p_coord{x=4140, y=4340},
		#p_coord{x=4160, y=4340},
		#p_coord{x=4140, y=4360},
		#p_coord{x=4160, y=4360}
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
