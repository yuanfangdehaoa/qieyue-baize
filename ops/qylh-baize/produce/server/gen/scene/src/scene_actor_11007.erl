-module(scene_actor_11007).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(110076) ->
	{#p_coord{x=1469,y=413},11005,#p_coord{x=10466,y=7540}};
get_portal(110079) ->
	{#p_coord{x=5883,y=3113},11006,#p_coord{x=1237,y=287}};
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=1500, y=720},
		#p_coord{x=1519, y=720},
		#p_coord{x=1540, y=720},
		#p_coord{x=1560, y=720},
		#p_coord{x=1480, y=740},
		#p_coord{x=1500, y=740},
		#p_coord{x=1519, y=740},
		#p_coord{x=1540, y=740},
		#p_coord{x=1560, y=740},
		#p_coord{x=1480, y=759},
		#p_coord{x=1500, y=759},
		#p_coord{x=1519, y=759},
		#p_coord{x=1540, y=759},
		#p_coord{x=1560, y=759},
		#p_coord{x=1500, y=780},
		#p_coord{x=1519, y=780},
		#p_coord{x=1540, y=780},
		#p_coord{x=1560, y=780},
		#p_coord{x=1580, y=780}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=1460, y=740},
		#p_coord{x=1480, y=740},
		#p_coord{x=1500, y=740},
		#p_coord{x=1480, y=759},
		#p_coord{x=1500, y=759},
		#p_coord{x=1480, y=780},
		#p_coord{x=1500, y=780},
		#p_coord{x=1500, y=800}
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
		#p_coord{x=4360, y=580},
		#p_coord{x=5340, y=680},
		#p_coord{x=4000, y=759},
		#p_coord{x=6279, y=900},
		#p_coord{x=4420, y=940},
		#p_coord{x=6720, y=960},
		#p_coord{x=5060, y=1000},
		#p_coord{x=5079, y=1000},
		#p_coord{x=5860, y=1040},
		#p_coord{x=6959, y=1080},
		#p_coord{x=4040, y=1219},
		#p_coord{x=7100, y=1260},
		#p_coord{x=6320, y=1280},
		#p_coord{x=4620, y=1360},
		#p_coord{x=7280, y=1519},
		#p_coord{x=3460, y=1540},
		#p_coord{x=4900, y=1600},
		#p_coord{x=3160, y=1680},
		#p_coord{x=7680, y=2039},
		#p_coord{x=3460, y=2160},
		#p_coord{x=3479, y=2160},
		#p_coord{x=1560, y=2200},
		#p_coord{x=3800, y=2220},
		#p_coord{x=6800, y=2360},
		#p_coord{x=4600, y=2460},
		#p_coord{x=7100, y=2520},
		#p_coord{x=4040, y=2539},
		#p_coord{x=2260, y=2600},
		#p_coord{x=7640, y=2739},
		#p_coord{x=4440, y=2760},
		#p_coord{x=1540, y=2939},
		#p_coord{x=3679, y=2939},
		#p_coord{x=6079, y=3139},
		#p_coord{x=7740, y=3300},
		#p_coord{x=3840, y=3320},
		#p_coord{x=800, y=3340},
		#p_coord{x=3060, y=3379},
		#p_coord{x=540, y=3600},
		#p_coord{x=2220, y=3740},
		#p_coord{x=7559, y=3740},
		#p_coord{x=2839, y=3779},
		#p_coord{x=7120, y=4220},
		#p_coord{x=6120, y=4720}
	].

%% NPC 列表
get_npcs() ->
	[
		{ 1701,#p_coord{x=1264, y=1077 } },
		{ 1702,#p_coord{x=3315, y=3356 } },
		{ 1703,#p_coord{x=5670, y=846 } },
		{ 1704,#p_coord{x=471, y=3153 } },
		{ 1705,#p_coord{x=3263, y=1921 } },
		{ 1706,#p_coord{x=5604, y=4725 } }
	].

%% 怪物列表
get_creeps() ->
	[
		{ 1100701,#p_coord{x=818, y=1707 } },
		{ 1100701,#p_coord{x=557, y=1809 } },
		{ 1100701,#p_coord{x=886, y=1946 } },
		{ 1100701,#p_coord{x=1035, y=1920 } },
		{ 1100701,#p_coord{x=1009, y=1787 } },
		{ 1100701,#p_coord{x=951, y=1501 } },
		{ 1100701,#p_coord{x=648, y=1489 } },
		{ 1100701,#p_coord{x=345, y=1665 } },
		{ 1100705,#p_coord{x=6590, y=3586 } },
		{ 1100705,#p_coord{x=6550, y=3454 } },
		{ 1100705,#p_coord{x=6843, y=3490 } },
		{ 1100705,#p_coord{x=6816, y=3665 } },
		{ 1100705,#p_coord{x=6598, y=3816 } },
		{ 1100705,#p_coord{x=6388, y=3691 } },
		{ 1100705,#p_coord{x=6315, y=3506 } },
		{ 1100705,#p_coord{x=6395, y=3316 } },
		{ 1100705,#p_coord{x=7019, y=3661 } },
		{ 1100705,#p_coord{x=6950, y=3865 } },
		{ 1100705,#p_coord{x=6493, y=3293 } },
		{ 1100702,#p_coord{x=1478, y=3818 } },
		{ 1100702,#p_coord{x=1214, y=3618 } },
		{ 1100702,#p_coord{x=1543, y=3606 } },
		{ 1100702,#p_coord{x=1067, y=3802 } },
		{ 1100702,#p_coord{x=1157, y=4049 } },
		{ 1100702,#p_coord{x=980, y=4111 } },
		{ 1100702,#p_coord{x=1242, y=4295 } },
		{ 1100702,#p_coord{x=1538, y=4216 } },
		{ 1100702,#p_coord{x=1472, y=4018 } },
		{ 1100702,#p_coord{x=1852, y=4166 } },
		{ 1100702,#p_coord{x=1762, y=3909 } },
		{ 1100702,#p_coord{x=1753, y=3713 } },
		{ 1100702,#p_coord{x=2136, y=3886 } },
		{ 1100707,#p_coord{x=7466, y=1862 } },
		{ 1100707,#p_coord{x=7387, y=1664 } },
		{ 1100707,#p_coord{x=7680, y=1763 } },
		{ 1100707,#p_coord{x=7252, y=2121 } },
		{ 1100707,#p_coord{x=7673, y=2329 } },
		{ 1100707,#p_coord{x=6487, y=2088 } },
		{ 1100707,#p_coord{x=6437, y=1925 } },
		{ 1100707,#p_coord{x=7137, y=2230 } },
		{ 1100707,#p_coord{x=7316, y=2418 } },
		{ 1100707,#p_coord{x=7700, y=2079 } },
		{ 1100707,#p_coord{x=6322, y=1402 } },
		{ 1100706,#p_coord{x=7140, y=4679 } },
		{ 1100706,#p_coord{x=6973, y=4538 } },
		{ 1100706,#p_coord{x=7159, y=4424 } },
		{ 1100706,#p_coord{x=7343, y=4559 } },
		{ 1100706,#p_coord{x=7545, y=4688 } },
		{ 1100706,#p_coord{x=7305, y=4927 } },
		{ 1100706,#p_coord{x=6884, y=4886 } },
		{ 1100706,#p_coord{x=6708, y=4761 } },
		{ 1100706,#p_coord{x=6655, y=4495 } },
		{ 1100706,#p_coord{x=7697, y=4840 } },
		{ 1100704,#p_coord{x=4988, y=2130 } },
		{ 1100704,#p_coord{x=5024, y=2244 } },
		{ 1100704,#p_coord{x=4811, y=2179 } },
		{ 1100704,#p_coord{x=4879, y=2021 } },
		{ 1100704,#p_coord{x=4715, y=1987 } },
		{ 1100704,#p_coord{x=4841, y=1888 } },
		{ 1100704,#p_coord{x=5027, y=1910 } },
		{ 1100704,#p_coord{x=5090, y=2015 } },
		{ 1100704,#p_coord{x=5181, y=1875 } },
		{ 1100704,#p_coord{x=5309, y=2028 } },
		{ 1100704,#p_coord{x=5136, y=2126 } },
		{ 1100704,#p_coord{x=5249, y=2156 } },
		{ 1100704,#p_coord{x=5225, y=2293 } },
		{ 1100701,#p_coord{x=1139, y=1647 } },
		{ 1100708,#p_coord{x=7204, y=3034 } }
	].

%% 寻路点
get_waypoint() ->
	[
	].