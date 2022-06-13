-module(scene_actor_20731).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=3920, y=559},
		#p_coord{x=3940, y=559},
		#p_coord{x=3960, y=559},
		#p_coord{x=3920, y=580},
		#p_coord{x=3940, y=580},
		#p_coord{x=3960, y=580},
		#p_coord{x=3920, y=600},
		#p_coord{x=3940, y=600},
		#p_coord{x=3960, y=600},
		#p_coord{x=3920, y=620},
		#p_coord{x=3940, y=620},
		#p_coord{x=3960, y=620},
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

%% 复活点
get_reborn() ->
	[
		#p_coord{x=3920, y=580},
		#p_coord{x=3940, y=580},
		#p_coord{x=3960, y=580},
		#p_coord{x=3920, y=600},
		#p_coord{x=3940, y=600},
		#p_coord{x=3960, y=600},
		#p_coord{x=3920, y=620},
		#p_coord{x=3940, y=620},
		#p_coord{x=3960, y=620},
		#p_coord{x=3920, y=640},
		#p_coord{x=3940, y=640},
		#p_coord{x=3960, y=640},
		#p_coord{x=900, y=700},
		#p_coord{x=919, y=700},
		#p_coord{x=940, y=700},
		#p_coord{x=960, y=700},
		#p_coord{x=900, y=720},
		#p_coord{x=919, y=720},
		#p_coord{x=940, y=720},
		#p_coord{x=960, y=720},
		#p_coord{x=900, y=740},
		#p_coord{x=919, y=740},
		#p_coord{x=940, y=740},
		#p_coord{x=960, y=740},
		#p_coord{x=900, y=759},
		#p_coord{x=919, y=759},
		#p_coord{x=940, y=759},
		#p_coord{x=960, y=759}
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
		{ 20731001,#p_coord{x=2645, y=1789 } }
	].

%% 寻路点
get_waypoint() ->
	[
	].
