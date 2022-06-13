-module(scene_actor_20701).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=880, y=740},
		#p_coord{x=900, y=740},
		#p_coord{x=880, y=759},
		#p_coord{x=900, y=759},
		#p_coord{x=900, y=780},
		#p_coord{x=919, y=780},
		#p_coord{x=4640, y=780},
		#p_coord{x=4660, y=780},
		#p_coord{x=900, y=800},
		#p_coord{x=919, y=800},
		#p_coord{x=4640, y=800},
		#p_coord{x=4660, y=800},
		#p_coord{x=860, y=819},
		#p_coord{x=880, y=819},
		#p_coord{x=4679, y=819},
		#p_coord{x=4700, y=819},
		#p_coord{x=860, y=840},
		#p_coord{x=880, y=840},
		#p_coord{x=4640, y=840},
		#p_coord{x=4660, y=840},
		#p_coord{x=4679, y=840},
		#p_coord{x=4700, y=840},
		#p_coord{x=4640, y=860},
		#p_coord{x=4660, y=860}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=840, y=780},
		#p_coord{x=860, y=780},
		#p_coord{x=4600, y=780},
		#p_coord{x=4620, y=780},
		#p_coord{x=840, y=800},
		#p_coord{x=860, y=800},
		#p_coord{x=4600, y=800},
		#p_coord{x=4620, y=800},
		#p_coord{x=4560, y=819},
		#p_coord{x=4579, y=819},
		#p_coord{x=4600, y=819},
		#p_coord{x=4620, y=819},
		#p_coord{x=4560, y=840},
		#p_coord{x=4579, y=840},
		#p_coord{x=4600, y=840},
		#p_coord{x=4620, y=840}
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
		{ 20701001,#p_coord{x=2880, y=1865 } }
	].

%% 寻路点
get_waypoint() ->
	[
	].
