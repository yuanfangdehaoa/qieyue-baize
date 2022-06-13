-module(scene_actor_20721).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=680, y=420},
		#p_coord{x=700, y=420},
		#p_coord{x=720, y=420},
		#p_coord{x=740, y=420},
		#p_coord{x=680, y=440},
		#p_coord{x=700, y=440},
		#p_coord{x=720, y=440},
		#p_coord{x=740, y=440},
		#p_coord{x=680, y=459},
		#p_coord{x=700, y=459},
		#p_coord{x=720, y=459},
		#p_coord{x=740, y=459},
		#p_coord{x=680, y=480},
		#p_coord{x=700, y=480},
		#p_coord{x=720, y=480},
		#p_coord{x=740, y=480},
		#p_coord{x=3820, y=559},
		#p_coord{x=3840, y=559},
		#p_coord{x=3860, y=559},
		#p_coord{x=3820, y=580},
		#p_coord{x=3840, y=580},
		#p_coord{x=3860, y=580},
		#p_coord{x=3820, y=600},
		#p_coord{x=3840, y=600},
		#p_coord{x=3860, y=600},
		#p_coord{x=3820, y=620},
		#p_coord{x=3840, y=620},
		#p_coord{x=3860, y=620}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=600, y=420},
		#p_coord{x=620, y=420},
		#p_coord{x=640, y=420},
		#p_coord{x=659, y=420},
		#p_coord{x=600, y=440},
		#p_coord{x=620, y=440},
		#p_coord{x=640, y=440},
		#p_coord{x=659, y=440},
		#p_coord{x=600, y=459},
		#p_coord{x=620, y=459},
		#p_coord{x=640, y=459},
		#p_coord{x=659, y=459},
		#p_coord{x=600, y=480},
		#p_coord{x=620, y=480},
		#p_coord{x=640, y=480},
		#p_coord{x=659, y=480},
		#p_coord{x=3760, y=559},
		#p_coord{x=3779, y=559},
		#p_coord{x=3800, y=559},
		#p_coord{x=3760, y=580},
		#p_coord{x=3779, y=580},
		#p_coord{x=3800, y=580},
		#p_coord{x=3760, y=600},
		#p_coord{x=3779, y=600},
		#p_coord{x=3800, y=600},
		#p_coord{x=3760, y=620},
		#p_coord{x=3779, y=620},
		#p_coord{x=3800, y=620}
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
		{ 20721001,#p_coord{x=2113, y=1782 } }
	].

%% 寻路点
get_waypoint() ->
	[
	].
