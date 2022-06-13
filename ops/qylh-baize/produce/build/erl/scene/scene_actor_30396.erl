-module(scene_actor_30396).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=1060, y=1960},
		#p_coord{x=1080, y=1960},
		#p_coord{x=6340, y=1960},
		#p_coord{x=6360, y=1960},
		#p_coord{x=1060, y=1980},
		#p_coord{x=1080, y=1980},
		#p_coord{x=6340, y=1980},
		#p_coord{x=6360, y=1980},
		#p_coord{x=1000, y=4660},
		#p_coord{x=1019, y=4660},
		#p_coord{x=1000, y=4679},
		#p_coord{x=1019, y=4679},
		#p_coord{x=6500, y=4700},
		#p_coord{x=6520, y=4700},
		#p_coord{x=6500, y=4720},
		#p_coord{x=6520, y=4720}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=1119, y=1960},
		#p_coord{x=1140, y=1960},
		#p_coord{x=6379, y=1960},
		#p_coord{x=6400, y=1960},
		#p_coord{x=1119, y=1980},
		#p_coord{x=1140, y=1980},
		#p_coord{x=6379, y=1980},
		#p_coord{x=6400, y=1980},
		#p_coord{x=1060, y=4660},
		#p_coord{x=1080, y=4660},
		#p_coord{x=1060, y=4679},
		#p_coord{x=1080, y=4679},
		#p_coord{x=6540, y=4700},
		#p_coord{x=6559, y=4700},
		#p_coord{x=6540, y=4720},
		#p_coord{x=6559, y=4720}
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
