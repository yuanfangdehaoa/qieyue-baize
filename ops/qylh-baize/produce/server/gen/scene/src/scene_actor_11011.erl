-module(scene_actor_11011).

-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%% 传送点
get_portal(110111) ->
	{#p_coord{x=1206,y=1464},11009,#p_coord{x=3915,y=7500}};
get_portal(_) ->
	undefined.

%% 出生点
get_born() ->
	[
		#p_coord{x=1380, y=1519},
		#p_coord{x=1400, y=1519},
		#p_coord{x=1380, y=1540},
		#p_coord{x=1400, y=1540}
	].

%% 复活点
get_reborn() ->
	[
		#p_coord{x=1419, y=1519},
		#p_coord{x=1440, y=1519},
		#p_coord{x=1419, y=1540},
		#p_coord{x=1440, y=1540}
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
		{ 2102,#p_coord{x=3350, y=3584 } },
		{ 2101,#p_coord{x=1518, y=2229 } },
		{ 2105,#p_coord{x=9150, y=5725 } },
		{ 2104,#p_coord{x=7698, y=2445 } },
		{ 2103,#p_coord{x=5179, y=4509 } },
		{ 2106,#p_coord{x=1409, y=5527 } }
	].

%% 怪物列表
get_creeps() ->
	[
		{ 1101101,#p_coord{x=5108, y=1318 } },
		{ 1101101,#p_coord{x=4886, y=1436 } },
		{ 1101101,#p_coord{x=4884, y=1157 } },
		{ 1101101,#p_coord{x=5359, y=1126 } },
		{ 1101101,#p_coord{x=5306, y=1450 } },
		{ 1101101,#p_coord{x=5102, y=1613 } },
		{ 1101101,#p_coord{x=5106, y=953 } },
		{ 1101101,#p_coord{x=4674, y=1640 } },
		{ 1101101,#p_coord{x=4693, y=1297 } },
		{ 1101101,#p_coord{x=4613, y=1009 } },
		{ 1101101,#p_coord{x=5577, y=1637 } },
		{ 1101101,#p_coord{x=5479, y=1326 } },
		{ 1101101,#p_coord{x=5661, y=1010 } },
		{ 1101102,#p_coord{x=1455, y=3525 } },
		{ 1101102,#p_coord{x=1165, y=3531 } },
		{ 1101102,#p_coord{x=1837, y=3504 } },
		{ 1101102,#p_coord{x=1309, y=3647 } },
		{ 1101102,#p_coord{x=1664, y=3633 } },
		{ 1101102,#p_coord{x=1296, y=3381 } },
		{ 1101102,#p_coord{x=1705, y=3368 } },
		{ 1101102,#p_coord{x=1052, y=3275 } },
		{ 1101102,#p_coord{x=1497, y=3272 } },
		{ 1101102,#p_coord{x=1885, y=3263 } },
		{ 1101102,#p_coord{x=1089, y=3840 } },
		{ 1101102,#p_coord{x=1450, y=3806 } },
		{ 1101102,#p_coord{x=1845, y=3781 } },
		{ 1101103,#p_coord{x=5181, y=3550 } },
		{ 1101103,#p_coord{x=4845, y=3536 } },
		{ 1101103,#p_coord{x=5554, y=3541 } },
		{ 1101103,#p_coord{x=4850, y=3343 } },
		{ 1101103,#p_coord{x=5222, y=3315 } },
		{ 1101103,#p_coord{x=5559, y=3325 } },
		{ 1101103,#p_coord{x=4840, y=3765 } },
		{ 1101103,#p_coord{x=5174, y=3793 } },
		{ 1101103,#p_coord{x=5534, y=3768 } },
		{ 1101103,#p_coord{x=4886, y=3137 } },
		{ 1101103,#p_coord{x=5222, y=3118 } },
		{ 1101103,#p_coord{x=5561, y=3147 } },
		{ 1101103,#p_coord{x=4625, y=3368 } },
		{ 1101103,#p_coord{x=4631, y=3611 } },
		{ 1101103,#p_coord{x=5749, y=3672 } },
		{ 1101103,#p_coord{x=5763, y=3475 } },
		{ 1101104,#p_coord{x=8830, y=3495 } },
		{ 1101104,#p_coord{x=8476, y=3506 } },
		{ 1101104,#p_coord{x=9106, y=3499 } },
		{ 1101104,#p_coord{x=8459, y=3709 } },
		{ 1101104,#p_coord{x=8795, y=3711 } },
		{ 1101104,#p_coord{x=9095, y=3722 } },
		{ 1101104,#p_coord{x=8641, y=3627 } },
		{ 1101104,#p_coord{x=8958, y=3634 } },
		{ 1101104,#p_coord{x=8634, y=3343 } },
		{ 1101104,#p_coord{x=8998, y=3354 } },
		{ 1101104,#p_coord{x=8379, y=3170 } },
		{ 1101104,#p_coord{x=8825, y=3216 } },
		{ 1101104,#p_coord{x=9227, y=3204 } },
		{ 1101104,#p_coord{x=8572, y=3063 } },
		{ 1101104,#p_coord{x=8994, y=3095 } },
		{ 1101105,#p_coord{x=5136, y=5493 } },
		{ 1101105,#p_coord{x=4899, y=5325 } },
		{ 1101105,#p_coord{x=5370, y=5306 } },
		{ 1101105,#p_coord{x=4661, y=5481 } },
		{ 1101105,#p_coord{x=5513, y=5465 } },
		{ 1101105,#p_coord{x=4904, y=5643 } },
		{ 1101105,#p_coord{x=5286, y=5650 } },
		{ 1101105,#p_coord{x=4472, y=5656 } },
		{ 1101105,#p_coord{x=4499, y=5300 } },
		{ 1101105,#p_coord{x=5618, y=5283 } },
		{ 1101105,#p_coord{x=5645, y=5677 } },
		{ 1101105,#p_coord{x=5109, y=5811 } },
		{ 1101105,#p_coord{x=4734, y=5809 } },
		{ 1101105,#p_coord{x=4736, y=5259 } },
		{ 1101105,#p_coord{x=5161, y=5229 } }
	].

%% 寻路点
get_waypoint() ->
	[
	].