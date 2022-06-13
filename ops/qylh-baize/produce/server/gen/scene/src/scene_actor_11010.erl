-module(scene_actor_11010).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(110101) ->
	{#p_coord{x=5652,y=926},11006,#p_coord{x=3925,y=6300}};
get_portal(110102) ->
	{#p_coord{x=1419,y=919},11008,#p_coord{x=5909,y=160}};
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=5340, y=1000},
		#p_coord{x=5360, y=1000},
		#p_coord{x=5300, y=1019},
		#p_coord{x=5320, y=1019},
		#p_coord{x=5340, y=1019},
		#p_coord{x=5360, y=1019},
		#p_coord{x=5300, y=1040},
		#p_coord{x=5320, y=1040},
		#p_coord{x=5340, y=1040},
		#p_coord{x=5360, y=1040},
		#p_coord{x=5300, y=1060},
		#p_coord{x=5320, y=1060}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=5360, y=1040},
		#p_coord{x=5379, y=1040},
		#p_coord{x=5400, y=1040},
		#p_coord{x=5340, y=1060},
		#p_coord{x=5360, y=1060},
		#p_coord{x=5379, y=1060},
		#p_coord{x=5400, y=1060},
		#p_coord{x=5320, y=1080},
		#p_coord{x=5340, y=1080},
		#p_coord{x=5360, y=1080},
		#p_coord{x=5379, y=1080},
		#p_coord{x=5320, y=1100},
		#p_coord{x=5340, y=1100},
		#p_coord{x=5360, y=1100}
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
		#p_coord{x=2120, y=1380},
		#p_coord{x=2520, y=1639},
		#p_coord{x=4279, y=1860},
		#p_coord{x=5079, y=2839},
		#p_coord{x=5460, y=3080},
		#p_coord{x=2339, y=3220},
		#p_coord{x=7259, y=3579},
		#p_coord{x=5679, y=3840},
		#p_coord{x=680, y=4100},
		#p_coord{x=640, y=4520},
		#p_coord{x=5860, y=5800},
		#p_coord{x=5879, y=5800},
		#p_coord{x=5900, y=5800},
		#p_coord{x=5920, y=5820},
		#p_coord{x=6200, y=5979},
		#p_coord{x=3440, y=6559},
		#p_coord{x=5979, y=6600},
		#p_coord{x=3800, y=6640}
	].

%% NPC 列表
get_npcs() ->
	[
		{ 2001,#p_coord{x=4734, y=2161 } },
		{ 2002,#p_coord{x=5320, y=4038 } },
		{ 2003,#p_coord{x=7269, y=6527 } },
		{ 2004,#p_coord{x=4274, y=7191 } },
		{ 2005,#p_coord{x=609, y=4833 } },
		{ 2006,#p_coord{x=2439, y=3441 } }
	].

%% 怪物列表
get_creeps() ->
	[
		{ 1101001,#p_coord{x=3681, y=2140 } },
		{ 1101001,#p_coord{x=4020, y=2321 } },
		{ 1101001,#p_coord{x=3568, y=1762 } },
		{ 1101001,#p_coord{x=3900, y=1887 } },
		{ 1101001,#p_coord{x=4206, y=2071 } },
		{ 1101001,#p_coord{x=3800, y=2537 } },
		{ 1101001,#p_coord{x=3395, y=2442 } },
		{ 1101001,#p_coord{x=3017, y=2196 } },
		{ 1101001,#p_coord{x=3340, y=2213 } },
		{ 1101001,#p_coord{x=3615, y=1955 } },
		{ 1101002,#p_coord{x=6644, y=3622 } },
		{ 1101002,#p_coord{x=6191, y=3579 } },
		{ 1101002,#p_coord{x=6708, y=3399 } },
		{ 1101002,#p_coord{x=6127, y=3838 } },
		{ 1101002,#p_coord{x=7126, y=3399 } },
		{ 1101002,#p_coord{x=6462, y=3902 } },
		{ 1101002,#p_coord{x=7009, y=3631 } },
		{ 1101002,#p_coord{x=6829, y=3897 } },
		{ 1101002,#p_coord{x=6313, y=3343 } },
		{ 1101002,#p_coord{x=7204, y=3854 } },
		{ 1101002,#p_coord{x=7281, y=3622 } },
		{ 1101003,#p_coord{x=4404, y=4897 } },
		{ 1101003,#p_coord{x=4166, y=4674 } },
		{ 1101003,#p_coord{x=4477, y=4458 } },
		{ 1101003,#p_coord{x=4791, y=4652 } },
		{ 1101003,#p_coord{x=4877, y=4984 } },
		{ 1101003,#p_coord{x=4193, y=5109 } },
		{ 1101003,#p_coord{x=3909, y=4825 } },
		{ 1101003,#p_coord{x=4706, y=5195 } },
		{ 1101003,#p_coord{x=4327, y=5431 } },
		{ 1101003,#p_coord{x=4624, y=5397 } },
		{ 1101003,#p_coord{x=4499, y=4674 } },
		{ 1101004,#p_coord{x=5477, y=6987 } },
		{ 1101004,#p_coord{x=5472, y=7258 } },
		{ 1101004,#p_coord{x=5472, y=6766 } },
		{ 1101004,#p_coord{x=5213, y=7000 } },
		{ 1101004,#p_coord{x=5688, y=7026 } },
		{ 1101004,#p_coord{x=5240, y=7254 } },
		{ 1101004,#p_coord{x=5222, y=6745 } },
		{ 1101004,#p_coord{x=5054, y=7145 } },
		{ 1101004,#p_coord{x=5054, y=6887 } },
		{ 1101004,#p_coord{x=5700, y=6766 } },
		{ 1101004,#p_coord{x=5679, y=7297 } },
		{ 1101004,#p_coord{x=4868, y=7038 } },
		{ 1101005,#p_coord{x=2198, y=6022 } },
		{ 1101005,#p_coord{x=2646, y=5802 } },
		{ 1101005,#p_coord{x=1823, y=6211 } },
		{ 1101005,#p_coord{x=3038, y=5647 } },
		{ 1101005,#p_coord{x=2293, y=6293 } },
		{ 1101005,#p_coord{x=2578, y=6147 } },
		{ 1101005,#p_coord{x=3038, y=5979 } },
		{ 1101005,#p_coord{x=1745, y=5949 } },
		{ 1101005,#p_coord{x=2538, y=5547 } },
		{ 1101005,#p_coord{x=1820, y=5745 } },
		{ 1101005,#p_coord{x=2168, y=5500 } },
		{ 1101005,#p_coord{x=2177, y=5815 } },
		{ 1101006,#p_coord{x=1620, y=3511 } },
		{ 1101006,#p_coord{x=1586, y=3200 } },
		{ 1101006,#p_coord{x=2047, y=3286 } },
		{ 1101006,#p_coord{x=2129, y=3545 } },
		{ 1101006,#p_coord{x=1788, y=3790 } },
		{ 1101006,#p_coord{x=1242, y=3713 } },
		{ 1101006,#p_coord{x=1035, y=3468 } },
		{ 1101006,#p_coord{x=1255, y=3252 } },
		{ 1101006,#p_coord{x=2095, y=3738 } },
		{ 1101006,#p_coord{x=1488, y=3936 } },
		{ 1101006,#p_coord{x=819, y=3618 } }
	].

%% 寻路点
get_waypoint() ->
	[
	].
