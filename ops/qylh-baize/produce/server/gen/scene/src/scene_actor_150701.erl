-module(scene_actor_150701).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=559, y=640},
		#p_coord{x=580, y=640},
		#p_coord{x=600, y=640},
		#p_coord{x=620, y=640},
		#p_coord{x=559, y=659},
		#p_coord{x=580, y=659},
		#p_coord{x=600, y=659},
		#p_coord{x=620, y=659},
		#p_coord{x=559, y=680},
		#p_coord{x=580, y=680},
		#p_coord{x=600, y=680},
		#p_coord{x=620, y=680},
		#p_coord{x=559, y=700},
		#p_coord{x=580, y=700},
		#p_coord{x=600, y=700},
		#p_coord{x=620, y=700}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=659, y=640},
		#p_coord{x=680, y=640},
		#p_coord{x=700, y=640},
		#p_coord{x=720, y=640},
		#p_coord{x=659, y=659},
		#p_coord{x=680, y=659},
		#p_coord{x=700, y=659},
		#p_coord{x=720, y=659},
		#p_coord{x=659, y=680},
		#p_coord{x=680, y=680},
		#p_coord{x=700, y=680},
		#p_coord{x=720, y=680},
		#p_coord{x=659, y=700},
		#p_coord{x=680, y=700},
		#p_coord{x=700, y=700},
		#p_coord{x=720, y=700}
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
