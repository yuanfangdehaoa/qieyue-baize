-module(scene_actor_20739).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=3900, y=580},
		#p_coord{x=3920, y=580},
		#p_coord{x=3940, y=580},
		#p_coord{x=3900, y=600},
		#p_coord{x=3920, y=600},
		#p_coord{x=3940, y=600},
		#p_coord{x=3900, y=620},
		#p_coord{x=3920, y=620},
		#p_coord{x=3940, y=620},
		#p_coord{x=3900, y=640},
		#p_coord{x=3920, y=640},
		#p_coord{x=3940, y=640}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=919, y=700},
		#p_coord{x=940, y=700},
		#p_coord{x=960, y=700},
		#p_coord{x=980, y=700},
		#p_coord{x=919, y=720},
		#p_coord{x=940, y=720},
		#p_coord{x=960, y=720},
		#p_coord{x=980, y=720},
		#p_coord{x=919, y=740},
		#p_coord{x=940, y=740},
		#p_coord{x=960, y=740},
		#p_coord{x=980, y=740},
		#p_coord{x=919, y=759},
		#p_coord{x=940, y=759},
		#p_coord{x=960, y=759},
		#p_coord{x=980, y=759}
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
		{ 20739001,#p_coord{x=2640, y=1845 } }
	].

%% 寻路点
get_waypoint() ->
	[
	].
