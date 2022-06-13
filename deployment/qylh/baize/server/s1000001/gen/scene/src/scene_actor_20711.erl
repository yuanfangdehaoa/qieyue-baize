-module(scene_actor_20711).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=3000, y=440},
		#p_coord{x=3020, y=440},
		#p_coord{x=3039, y=440},
		#p_coord{x=3000, y=459},
		#p_coord{x=3020, y=459},
		#p_coord{x=3039, y=459},
		#p_coord{x=3000, y=480},
		#p_coord{x=3020, y=480},
		#p_coord{x=3039, y=480},
		#p_coord{x=3000, y=500},
		#p_coord{x=3020, y=500},
		#p_coord{x=3039, y=500},
		#p_coord{x=620, y=580},
		#p_coord{x=640, y=580},
		#p_coord{x=659, y=580},
		#p_coord{x=680, y=580},
		#p_coord{x=620, y=600},
		#p_coord{x=640, y=600},
		#p_coord{x=659, y=600},
		#p_coord{x=680, y=600},
		#p_coord{x=620, y=620},
		#p_coord{x=640, y=620},
		#p_coord{x=659, y=620},
		#p_coord{x=680, y=620},
		#p_coord{x=620, y=640},
		#p_coord{x=640, y=640},
		#p_coord{x=659, y=640},
		#p_coord{x=680, y=640}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=3039, y=459},
		#p_coord{x=3060, y=459},
		#p_coord{x=3080, y=459},
		#p_coord{x=3039, y=480},
		#p_coord{x=3060, y=480},
		#p_coord{x=3080, y=480},
		#p_coord{x=3039, y=500},
		#p_coord{x=3060, y=500},
		#p_coord{x=3080, y=500},
		#p_coord{x=3039, y=520},
		#p_coord{x=3060, y=520},
		#p_coord{x=3080, y=520},
		#p_coord{x=659, y=580},
		#p_coord{x=680, y=580},
		#p_coord{x=700, y=580},
		#p_coord{x=720, y=580},
		#p_coord{x=659, y=600},
		#p_coord{x=680, y=600},
		#p_coord{x=700, y=600},
		#p_coord{x=720, y=600},
		#p_coord{x=659, y=620},
		#p_coord{x=680, y=620},
		#p_coord{x=700, y=620},
		#p_coord{x=720, y=620},
		#p_coord{x=659, y=640},
		#p_coord{x=680, y=640},
		#p_coord{x=700, y=640},
		#p_coord{x=720, y=640},
		#p_coord{x=659, y=659},
		#p_coord{x=680, y=659},
		#p_coord{x=700, y=659},
		#p_coord{x=720, y=659}
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
		{ 20711001,#p_coord{x=2547, y=1682 } }
	].

%% 寻路点
get_waypoint() ->
	[
	].
