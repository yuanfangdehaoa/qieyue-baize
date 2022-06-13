-module(scene_actor_11003).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(110034) ->
	{#p_coord{x=9333,y=4254},11004,#p_coord{x=6559,y=500}};
get_portal(110035) ->
	{#p_coord{x=3129,y=782},11005,#p_coord{x=2706,y=1340}};
get_portal(110032) ->
	{#p_coord{x=9122,y=2254},11002,#p_coord{x=2244,y=4900}};
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=8359, y=2620}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=8340, y=2620}
	].

%% 跳跃点
get_jump() ->
	[
		#p_coord{x=8969, y=4647},
		#p_coord{x=8472, y=5308}
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
		{ 1305,#p_coord{x=6008, y=4620 } },
		{ 1304,#p_coord{x=3060, y=5663 } },
		{ 1303,#p_coord{x=2795, y=2289 } },
		{ 1308,#p_coord{x=5450, y=848 } },
		{ 1311,#p_coord{x=1887, y=1348 } },
		{ 1302,#p_coord{x=1887, y=3186 } },
		{ 1307,#p_coord{x=7458, y=5506 } },
		{ 1310,#p_coord{x=5847, y=6683 } },
		{ 1309,#p_coord{x=7327, y=3270 } },
		{ 1300,#p_coord{x=5284, y=3193 } },
		{ 1313,#p_coord{x=6890, y=4340 } },
		{ 1301,#p_coord{x=4097, y=3752 } },
		{ 1306,#p_coord{x=4525, y=4429 } }
	].

%% 怪物列表
get_creeps() ->
	[
		{ 1100301,#p_coord{x=1856, y=2798 } },
		{ 1100302,#p_coord{x=5575, y=6568 } },
		{ 1100303,#p_coord{x=9302, y=4531 } },
		{ 1100303,#p_coord{x=9647, y=6656 } },
		{ 1100305,#p_coord{x=5709, y=6870 } },
		{ 1100304,#p_coord{x=5690, y=3984 } },
		{ 1100301,#p_coord{x=2604, y=3218 } }
	].

%% 寻路点
get_waypoint() ->
	[
	].
