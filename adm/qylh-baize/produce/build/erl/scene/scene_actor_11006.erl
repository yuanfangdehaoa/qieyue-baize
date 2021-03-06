-module(scene_actor_11006).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(110067) ->
	{#p_coord{x=3925,y=6416},11010,#p_coord{x=5652,y=819}};
get_portal(110065) ->
	{#p_coord{x=931,y=160},11007,#p_coord{x=6276,y=3146}};
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=1360, y=379},
		#p_coord{x=1380, y=379},
		#p_coord{x=1400, y=379},
		#p_coord{x=1419, y=379},
		#p_coord{x=1360, y=400},
		#p_coord{x=1380, y=400},
		#p_coord{x=1400, y=400},
		#p_coord{x=1419, y=400},
		#p_coord{x=1360, y=420},
		#p_coord{x=1380, y=420},
		#p_coord{x=1400, y=420},
		#p_coord{x=1419, y=420},
		#p_coord{x=1360, y=440},
		#p_coord{x=1380, y=440},
		#p_coord{x=1400, y=440},
		#p_coord{x=1419, y=440}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=1280, y=400},
		#p_coord{x=1300, y=400},
		#p_coord{x=1319, y=400},
		#p_coord{x=1340, y=400},
		#p_coord{x=1280, y=420},
		#p_coord{x=1300, y=420},
		#p_coord{x=1319, y=420},
		#p_coord{x=1340, y=420},
		#p_coord{x=1280, y=440},
		#p_coord{x=1300, y=440},
		#p_coord{x=1319, y=440},
		#p_coord{x=1340, y=440},
		#p_coord{x=1280, y=459},
		#p_coord{x=1300, y=459},
		#p_coord{x=1319, y=459},
		#p_coord{x=1340, y=459}
	].

%% 跳跃点
get_jump() ->
	[
		#p_coord{x=7273, y=2648},
		#p_coord{x=7587, y=3690}
	].

%% 安全区
get_safe() ->
	[
	].

%% 寻宝区
get_hunt() ->
	[
		#p_coord{x=3479, y=819},
		#p_coord{x=5179, y=1180},
		#p_coord{x=4160, y=1280},
		#p_coord{x=5460, y=1760},
		#p_coord{x=2060, y=3400},
		#p_coord{x=4020, y=3420},
		#p_coord{x=3320, y=3500},
		#p_coord{x=5279, y=4060},
		#p_coord{x=4560, y=4079},
		#p_coord{x=1820, y=4220},
		#p_coord{x=7500, y=4220},
		#p_coord{x=5860, y=4720},
		#p_coord{x=1980, y=4960},
		#p_coord{x=960, y=5020},
		#p_coord{x=3560, y=6100}
	].

%% NPC 列表
get_npcs() ->
	[
		{ 1601,#p_coord{x=4234, y=1026 } },
		{ 1602,#p_coord{x=4313, y=3750 } },
		{ 1603,#p_coord{x=819, y=5381 } },
		{ 1604,#p_coord{x=1334, y=590 } },
		{ 1605,#p_coord{x=7029, y=4413 } }
	].

%% 怪物列表
get_creeps() ->
	[
		{ 1100607,#p_coord{x=7462, y=1670 } },
		{ 1100608,#p_coord{x=4972, y=4050 } },
		{ 1100601,#p_coord{x=1865, y=834 } },
		{ 1100601,#p_coord{x=2352, y=551 } },
		{ 1100601,#p_coord{x=2086, y=1135 } },
		{ 1100601,#p_coord{x=2527, y=906 } },
		{ 1100601,#p_coord{x=3062, y=626 } },
		{ 1100601,#p_coord{x=2565, y=1252 } },
		{ 1100601,#p_coord{x=3147, y=964 } },
		{ 1100602,#p_coord{x=6220, y=2186 } },
		{ 1100602,#p_coord{x=5666, y=2188 } },
		{ 1100602,#p_coord{x=5970, y=2040 } },
		{ 1100602,#p_coord{x=6325, y=1882 } },
		{ 1100602,#p_coord{x=6581, y=2028 } },
		{ 1100602,#p_coord{x=6841, y=2270 } },
		{ 1100602,#p_coord{x=6538, y=2464 } },
		{ 1100602,#p_coord{x=6286, y=2612 } },
		{ 1100602,#p_coord{x=5956, y=2438 } },
		{ 1100603,#p_coord{x=6844, y=5099 } },
		{ 1100603,#p_coord{x=6913, y=5409 } },
		{ 1100603,#p_coord{x=7276, y=4868 } },
		{ 1100603,#p_coord{x=6766, y=4779 } },
		{ 1100603,#p_coord{x=6291, y=5056 } },
		{ 1100604,#p_coord{x=2961, y=2862 } },
		{ 1100604,#p_coord{x=2661, y=3004 } },
		{ 1100604,#p_coord{x=2879, y=3274 } },
		{ 1100604,#p_coord{x=3178, y=3087 } },
		{ 1100604,#p_coord{x=3424, y=2846 } },
		{ 1100604,#p_coord{x=2145, y=2978 } },
		{ 1100604,#p_coord{x=2517, y=2804 } },
		{ 1100604,#p_coord{x=2805, y=2584 } },
		{ 1100605,#p_coord{x=872, y=4115 } },
		{ 1100605,#p_coord{x=846, y=3702 } },
		{ 1100605,#p_coord{x=1406, y=4052 } },
		{ 1100605,#p_coord{x=401, y=3943 } },
		{ 1100605,#p_coord{x=1343, y=4354 } },
		{ 1100605,#p_coord{x=459, y=4340 } },
		{ 1100605,#p_coord{x=927, y=4533 } },
		{ 1100606,#p_coord{x=2577, y=5454 } },
		{ 1100606,#p_coord{x=2073, y=5400 } },
		{ 1100606,#p_coord{x=2692, y=5138 } },
		{ 1100606,#p_coord{x=2455, y=5770 } },
		{ 1100606,#p_coord{x=3250, y=5375 } },
		{ 1100606,#p_coord{x=3026, y=5718 } },
		{ 1100606,#p_coord{x=2943, y=6049 } },
		{ 1100606,#p_coord{x=3672, y=5679 } },
		{ 1100602,#p_coord{x=6259, y=2423 } },
		{ 1100603,#p_coord{x=6465, y=4874 } },
		{ 1100603,#p_coord{x=6609, y=5204 } },
		{ 1100603,#p_coord{x=7081, y=5186 } },
		{ 1100603,#p_coord{x=7366, y=5156 } },
		{ 1100604,#p_coord{x=2556, y=3200 } },
		{ 1100604,#p_coord{x=3112, y=2654 } },
		{ 1100605,#p_coord{x=291, y=4134 } },
		{ 1100606,#p_coord{x=2977, y=5472 } }
	].

%% 寻路点
get_waypoint() ->
	[
	].
