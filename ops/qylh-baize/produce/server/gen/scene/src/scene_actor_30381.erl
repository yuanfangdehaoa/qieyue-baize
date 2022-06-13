-module(scene_actor_30381).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=459, y=1200},
		#p_coord{x=480, y=1200},
		#p_coord{x=500, y=1200},
		#p_coord{x=520, y=1200},
		#p_coord{x=459, y=1219},
		#p_coord{x=480, y=1219},
		#p_coord{x=500, y=1219},
		#p_coord{x=520, y=1219},
		#p_coord{x=1440, y=1219},
		#p_coord{x=1460, y=1219},
		#p_coord{x=1480, y=1219},
		#p_coord{x=1500, y=1219},
		#p_coord{x=459, y=1240},
		#p_coord{x=480, y=1240},
		#p_coord{x=500, y=1240},
		#p_coord{x=520, y=1240},
		#p_coord{x=1440, y=1240},
		#p_coord{x=1460, y=1240},
		#p_coord{x=1480, y=1240},
		#p_coord{x=1500, y=1240},
		#p_coord{x=459, y=1260},
		#p_coord{x=480, y=1260},
		#p_coord{x=500, y=1260},
		#p_coord{x=520, y=1260},
		#p_coord{x=1440, y=1260},
		#p_coord{x=1460, y=1260},
		#p_coord{x=1480, y=1260},
		#p_coord{x=1500, y=1260},
		#p_coord{x=1440, y=1280},
		#p_coord{x=1460, y=1280},
		#p_coord{x=1480, y=1280},
		#p_coord{x=1500, y=1280},
		#p_coord{x=1219, y=1360},
		#p_coord{x=740, y=1600},
		#p_coord{x=1180, y=1620},
		#p_coord{x=480, y=1700},
		#p_coord{x=500, y=1700},
		#p_coord{x=520, y=1700},
		#p_coord{x=540, y=1700},
		#p_coord{x=480, y=1720},
		#p_coord{x=500, y=1720},
		#p_coord{x=520, y=1720},
		#p_coord{x=540, y=1720},
		#p_coord{x=480, y=1739},
		#p_coord{x=500, y=1739},
		#p_coord{x=520, y=1739},
		#p_coord{x=540, y=1739}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=500, y=1200},
		#p_coord{x=520, y=1200},
		#p_coord{x=540, y=1200},
		#p_coord{x=559, y=1200},
		#p_coord{x=500, y=1219},
		#p_coord{x=520, y=1219},
		#p_coord{x=540, y=1219},
		#p_coord{x=559, y=1219},
		#p_coord{x=1419, y=1219},
		#p_coord{x=1440, y=1219},
		#p_coord{x=1460, y=1219},
		#p_coord{x=1480, y=1219},
		#p_coord{x=500, y=1240},
		#p_coord{x=520, y=1240},
		#p_coord{x=540, y=1240},
		#p_coord{x=559, y=1240},
		#p_coord{x=1419, y=1240},
		#p_coord{x=1440, y=1240},
		#p_coord{x=1460, y=1240},
		#p_coord{x=1480, y=1240},
		#p_coord{x=500, y=1260},
		#p_coord{x=520, y=1260},
		#p_coord{x=540, y=1260},
		#p_coord{x=559, y=1260},
		#p_coord{x=1419, y=1260},
		#p_coord{x=1440, y=1260},
		#p_coord{x=1460, y=1260},
		#p_coord{x=1480, y=1260},
		#p_coord{x=1419, y=1280},
		#p_coord{x=1440, y=1280},
		#p_coord{x=1460, y=1280},
		#p_coord{x=1480, y=1280},
		#p_coord{x=1419, y=1300},
		#p_coord{x=1440, y=1300},
		#p_coord{x=1460, y=1300},
		#p_coord{x=1480, y=1300},
		#p_coord{x=1240, y=1340},
		#p_coord{x=1219, y=1540},
		#p_coord{x=700, y=1600},
		#p_coord{x=520, y=1700},
		#p_coord{x=540, y=1700},
		#p_coord{x=559, y=1700},
		#p_coord{x=580, y=1700},
		#p_coord{x=520, y=1720},
		#p_coord{x=540, y=1720},
		#p_coord{x=559, y=1720},
		#p_coord{x=580, y=1720},
		#p_coord{x=520, y=1739},
		#p_coord{x=540, y=1739},
		#p_coord{x=559, y=1739},
		#p_coord{x=580, y=1739}
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
