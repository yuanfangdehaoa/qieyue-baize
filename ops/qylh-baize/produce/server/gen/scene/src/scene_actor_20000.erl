-module(scene_actor_20000).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=5400, y=720},
		#p_coord{x=5420, y=720},
		#p_coord{x=5440, y=720},
		#p_coord{x=5460, y=720},
		#p_coord{x=5479, y=720},
		#p_coord{x=5500, y=720},
		#p_coord{x=5520, y=720},
		#p_coord{x=5400, y=740},
		#p_coord{x=5420, y=740},
		#p_coord{x=5440, y=740},
		#p_coord{x=5460, y=740},
		#p_coord{x=5479, y=740},
		#p_coord{x=5500, y=740},
		#p_coord{x=5520, y=740},
		#p_coord{x=5400, y=759},
		#p_coord{x=5420, y=759},
		#p_coord{x=5440, y=759},
		#p_coord{x=5460, y=759},
		#p_coord{x=5479, y=759},
		#p_coord{x=5500, y=759},
		#p_coord{x=5520, y=759},
		#p_coord{x=5400, y=780},
		#p_coord{x=5420, y=780},
		#p_coord{x=5440, y=780},
		#p_coord{x=5460, y=780},
		#p_coord{x=5479, y=780},
		#p_coord{x=5500, y=780},
		#p_coord{x=5520, y=780},
		#p_coord{x=5400, y=800},
		#p_coord{x=5420, y=800},
		#p_coord{x=5440, y=800},
		#p_coord{x=5460, y=800},
		#p_coord{x=5479, y=800},
		#p_coord{x=5500, y=800},
		#p_coord{x=5520, y=800},
		#p_coord{x=5400, y=819},
		#p_coord{x=5420, y=819},
		#p_coord{x=5440, y=819},
		#p_coord{x=5460, y=819},
		#p_coord{x=5479, y=819},
		#p_coord{x=5500, y=819},
		#p_coord{x=5520, y=819},
		#p_coord{x=5400, y=840},
		#p_coord{x=5420, y=840},
		#p_coord{x=5440, y=840},
		#p_coord{x=5460, y=840},
		#p_coord{x=5479, y=840},
		#p_coord{x=5500, y=840},
		#p_coord{x=5520, y=840},
		#p_coord{x=5400, y=860},
		#p_coord{x=5420, y=860},
		#p_coord{x=5440, y=860},
		#p_coord{x=5460, y=860},
		#p_coord{x=5479, y=860},
		#p_coord{x=5500, y=860},
		#p_coord{x=5520, y=860}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=5300, y=720},
		#p_coord{x=5320, y=720},
		#p_coord{x=5340, y=720},
		#p_coord{x=5360, y=720},
		#p_coord{x=5379, y=720},
		#p_coord{x=5400, y=720},
		#p_coord{x=5420, y=720},
		#p_coord{x=5300, y=740},
		#p_coord{x=5320, y=740},
		#p_coord{x=5340, y=740},
		#p_coord{x=5360, y=740},
		#p_coord{x=5379, y=740},
		#p_coord{x=5400, y=740},
		#p_coord{x=5420, y=740},
		#p_coord{x=5300, y=759},
		#p_coord{x=5320, y=759},
		#p_coord{x=5340, y=759},
		#p_coord{x=5360, y=759},
		#p_coord{x=5379, y=759},
		#p_coord{x=5400, y=759},
		#p_coord{x=5420, y=759},
		#p_coord{x=5300, y=780},
		#p_coord{x=5320, y=780},
		#p_coord{x=5340, y=780},
		#p_coord{x=5360, y=780},
		#p_coord{x=5379, y=780},
		#p_coord{x=5400, y=780},
		#p_coord{x=5420, y=780},
		#p_coord{x=5300, y=800},
		#p_coord{x=5320, y=800},
		#p_coord{x=5340, y=800},
		#p_coord{x=5360, y=800},
		#p_coord{x=5379, y=800},
		#p_coord{x=5400, y=800},
		#p_coord{x=5420, y=800},
		#p_coord{x=5300, y=819},
		#p_coord{x=5320, y=819},
		#p_coord{x=5340, y=819},
		#p_coord{x=5360, y=819},
		#p_coord{x=5379, y=819},
		#p_coord{x=5400, y=819},
		#p_coord{x=5420, y=819},
		#p_coord{x=5300, y=840},
		#p_coord{x=5320, y=840},
		#p_coord{x=5340, y=840},
		#p_coord{x=5360, y=840},
		#p_coord{x=5379, y=840},
		#p_coord{x=5400, y=840},
		#p_coord{x=5420, y=840},
		#p_coord{x=5300, y=860},
		#p_coord{x=5320, y=860},
		#p_coord{x=5340, y=860},
		#p_coord{x=5360, y=860},
		#p_coord{x=5379, y=860},
		#p_coord{x=5400, y=860},
		#p_coord{x=5420, y=860}
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
		{ 20000001,#p_coord{x=1838, y=1502 } },
		{ 20000002,#p_coord{x=4656, y=2646 } },
		{ 20000003,#p_coord{x=8323, y=2867 } },
		{ 20000004,#p_coord{x=988, y=3865 } },
		{ 20000005,#p_coord{x=2528, y=5493 } },
		{ 20000006,#p_coord{x=6122, y=5331 } }
	].

%% 寻路点
get_waypoint() ->
	[
	].
