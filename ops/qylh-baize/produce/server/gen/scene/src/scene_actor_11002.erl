-module(scene_actor_11002).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(110023) ->
	{#p_coord{x=2244,y=5018},11003,#p_coord{x=9122,y=2139}};
get_portal(110021) ->
	{#p_coord{x=6595,y=569},11001,#p_coord{x=8940,y=1340}};
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=6320, y=740},
		#p_coord{x=6340, y=740},
		#p_coord{x=6360, y=740},
		#p_coord{x=6320, y=759},
		#p_coord{x=6340, y=759},
		#p_coord{x=6360, y=759},
		#p_coord{x=6320, y=780},
		#p_coord{x=6340, y=780}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=6260, y=740},
		#p_coord{x=6279, y=740},
		#p_coord{x=6300, y=740},
		#p_coord{x=6260, y=759},
		#p_coord{x=6279, y=759},
		#p_coord{x=6300, y=759},
		#p_coord{x=6260, y=780},
		#p_coord{x=6279, y=780},
		#p_coord{x=6300, y=780},
		#p_coord{x=6279, y=800},
		#p_coord{x=6300, y=800}
	].

%% 跳跃点
get_jump() ->
	[
		#p_coord{x=6926, y=3247},
		#p_coord{x=6916, y=4095},
		#p_coord{x=2528, y=3014},
		#p_coord{x=2953, y=2710}
	].

%% 安全区
get_safe() ->
	[
	].

%% 寻宝区
get_hunt() ->
	[
		#p_coord{x=4860, y=580},
		#p_coord{x=3840, y=680},
		#p_coord{x=3100, y=759},
		#p_coord{x=2520, y=960},
		#p_coord{x=3340, y=960},
		#p_coord{x=4360, y=960},
		#p_coord{x=3340, y=980},
		#p_coord{x=1980, y=1140},
		#p_coord{x=2780, y=1180},
		#p_coord{x=2120, y=1500},
		#p_coord{x=1400, y=1620},
		#p_coord{x=1419, y=1620},
		#p_coord{x=1440, y=1620},
		#p_coord{x=3139, y=2220},
		#p_coord{x=260, y=2760},
		#p_coord{x=6600, y=2760},
		#p_coord{x=3240, y=2800},
		#p_coord{x=3260, y=2800},
		#p_coord{x=5560, y=2920},
		#p_coord{x=880, y=2980},
		#p_coord{x=2160, y=3479},
		#p_coord{x=919, y=3600},
		#p_coord{x=3540, y=4840},
		#p_coord{x=4879, y=4940},
		#p_coord{x=2620, y=4979}
	].

%% NPC 列表
get_npcs() ->
	[
		{ 1200,#p_coord{x=6009, y=596 } },
		{ 1201,#p_coord{x=3180, y=839 } },
		{ 1202,#p_coord{x=1725, y=1561 } },
		{ 1205,#p_coord{x=5643, y=2740 } },
		{ 1206,#p_coord{x=6601, y=2905 } },
		{ 1207,#p_coord{x=5161, y=4593 } },
		{ 1203,#p_coord{x=1052, y=3343 } },
		{ 1208,#p_coord{x=2907, y=4720 } },
		{ 1204,#p_coord{x=3345, y=2881 } }
	].

%% 怪物列表
get_creeps() ->
	[
		{ 1100204,#p_coord{x=6258, y=4233 } },
		{ 1100205,#p_coord{x=6106, y=3130 } },
		{ 1100205,#p_coord{x=6100, y=3120 } },
		{ 1100207,#p_coord{x=3000, y=4554 } },
		{ 1100201,#p_coord{x=2086, y=1053 } },
		{ 1100210,#p_coord{x=2248, y=1065 } },
		{ 1100211,#p_coord{x=2251, y=961 } },
		{ 1100209,#p_coord{x=1569, y=3908 } },
		{ 1100203,#p_coord{x=3765, y=2852 } },
		{ 1100203,#p_coord{x=3775, y=2555 } },
		{ 1100203,#p_coord{x=3800, y=2307 } },
		{ 1100203,#p_coord{x=4043, y=2704 } },
		{ 1100203,#p_coord{x=4052, y=2482 } },
		{ 1100203,#p_coord{x=4290, y=2909 } },
		{ 1100203,#p_coord{x=4288, y=2615 } },
		{ 1100203,#p_coord{x=4329, y=2415 } },
		{ 1100208,#p_coord{x=3963, y=5397 } },
		{ 1100208,#p_coord{x=4327, y=5377 } },
		{ 1100208,#p_coord{x=3815, y=5584 } },
		{ 1100208,#p_coord{x=3636, y=5418 } },
		{ 1100208,#p_coord{x=3813, y=5231 } },
		{ 1100208,#p_coord{x=4152, y=5608 } },
		{ 1100208,#p_coord{x=4174, y=5225 } },
		{ 1100208,#p_coord{x=4565, y=5234 } },
		{ 1100200,#p_coord{x=4977, y=1202 } },
		{ 1100200,#p_coord{x=5165, y=1414 } },
		{ 1100200,#p_coord{x=5413, y=1146 } },
		{ 1100200,#p_coord{x=5233, y=994 } },
		{ 1100200,#p_coord{x=4815, y=1367 } },
		{ 1100200,#p_coord{x=5545, y=1401 } },
		{ 1100200,#p_coord{x=5593, y=1044 } },
		{ 1100200,#p_coord{x=4818, y=1047 } },
		{ 1100202,#p_coord{x=1215, y=2364 } },
		{ 1100202,#p_coord{x=1234, y=2120 } },
		{ 1100202,#p_coord{x=950, y=2110 } },
		{ 1100202,#p_coord{x=921, y=2354 } },
		{ 1100202,#p_coord{x=907, y=2593 } },
		{ 1100202,#p_coord{x=1193, y=2609 } },
		{ 1100202,#p_coord{x=1476, y=2613 } },
		{ 1100202,#p_coord{x=1497, y=2378 } },
		{ 1100202,#p_coord{x=1505, y=2130 } },
		{ 1100200,#p_coord{x=4633, y=1210 } },
		{ 1100203,#p_coord{x=4481, y=2781 } },
		{ 1100208,#p_coord{x=4486, y=5600 } }
	].

%% 寻路点
get_waypoint() ->
	[
	].
