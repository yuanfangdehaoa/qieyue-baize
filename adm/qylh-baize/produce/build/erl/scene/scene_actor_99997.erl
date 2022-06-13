-module(scene_actor_99997).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=919, y=1519},
		#p_coord{x=940, y=1519},
		#p_coord{x=960, y=1519},
		#p_coord{x=980, y=1519},
		#p_coord{x=880, y=1540},
		#p_coord{x=900, y=1540},
		#p_coord{x=919, y=1540},
		#p_coord{x=940, y=1540},
		#p_coord{x=960, y=1540},
		#p_coord{x=980, y=1540},
		#p_coord{x=860, y=1560},
		#p_coord{x=880, y=1560},
		#p_coord{x=900, y=1560},
		#p_coord{x=919, y=1560},
		#p_coord{x=940, y=1560},
		#p_coord{x=960, y=1560},
		#p_coord{x=980, y=1560},
		#p_coord{x=860, y=1580},
		#p_coord{x=880, y=1580},
		#p_coord{x=900, y=1580},
		#p_coord{x=919, y=1580},
		#p_coord{x=940, y=1580},
		#p_coord{x=960, y=1580},
		#p_coord{x=980, y=1580},
		#p_coord{x=860, y=1600},
		#p_coord{x=880, y=1600},
		#p_coord{x=900, y=1600},
		#p_coord{x=919, y=1600},
		#p_coord{x=940, y=1600},
		#p_coord{x=960, y=1600},
		#p_coord{x=980, y=1600},
		#p_coord{x=860, y=1620},
		#p_coord{x=880, y=1620},
		#p_coord{x=900, y=1620},
		#p_coord{x=919, y=1620},
		#p_coord{x=940, y=1620}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=960, y=1620},
		#p_coord{x=980, y=1620},
		#p_coord{x=1000, y=1620},
		#p_coord{x=1019, y=1620},
		#p_coord{x=1040, y=1620},
		#p_coord{x=1060, y=1620},
		#p_coord{x=860, y=1639},
		#p_coord{x=880, y=1639},
		#p_coord{x=900, y=1639},
		#p_coord{x=919, y=1639},
		#p_coord{x=940, y=1639},
		#p_coord{x=960, y=1639},
		#p_coord{x=980, y=1639},
		#p_coord{x=1000, y=1639},
		#p_coord{x=1019, y=1639},
		#p_coord{x=1040, y=1639},
		#p_coord{x=1060, y=1639},
		#p_coord{x=860, y=1660},
		#p_coord{x=880, y=1660},
		#p_coord{x=900, y=1660},
		#p_coord{x=919, y=1660},
		#p_coord{x=940, y=1660},
		#p_coord{x=960, y=1660},
		#p_coord{x=980, y=1660},
		#p_coord{x=1000, y=1660},
		#p_coord{x=1019, y=1660},
		#p_coord{x=1040, y=1660},
		#p_coord{x=1060, y=1660},
		#p_coord{x=860, y=1680},
		#p_coord{x=880, y=1680},
		#p_coord{x=900, y=1680},
		#p_coord{x=919, y=1680},
		#p_coord{x=940, y=1680},
		#p_coord{x=960, y=1680},
		#p_coord{x=980, y=1680},
		#p_coord{x=1000, y=1680},
		#p_coord{x=1019, y=1680},
		#p_coord{x=1040, y=1680},
		#p_coord{x=880, y=1700},
		#p_coord{x=900, y=1700},
		#p_coord{x=919, y=1700},
		#p_coord{x=940, y=1700},
		#p_coord{x=960, y=1700}
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
