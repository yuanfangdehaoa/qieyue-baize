% Automatically generated, do not edit
-module(cfg_rank).

-compile([export_all]).
-compile(nowarn_export_all).

-include("rank.hrl").

%% "等级榜"
find(1001) -> #cfg_rank{
	id        = 1001,
    mode      = server,
	type      = 1,
	size      = 100,
	page_size = 30,
	limen     = 110,
	event     = 1,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "战力榜"
find(1002) -> #cfg_rank{
	id        = 1002,
    mode      = server,
	type      = 1,
	size      = 200,
	page_size = 30,
	limen     = 5000,
	event     = 12,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "坐骑"
find(1003) -> #cfg_rank{
	id        = 1003,
    mode      = server,
	type      = 1,
	size      = 100,
	page_size = 30,
	limen     = 20,
	event     = 17,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "副手"
find(1004) -> #cfg_rank{
	id        = 1004,
    mode      = server,
	type      = 1,
	size      = 100,
	page_size = 30,
	limen     = 20,
	event     = 17,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "魔法卡"
find(1005) -> #cfg_rank{
	id        = 1005,
    mode      = server,
	type      = 1,
	size      = 100,
	page_size = 30,
	limen     = 3000,
	event     = 23,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "宠物总战力"
find(1006) -> #cfg_rank{
	id        = 1006,
    mode      = server,
	type      = 1,
	size      = 100,
	page_size = 30,
	limen     = 3000,
	event     = 69,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "神灵总战力"
find(1007) -> #cfg_rank{
	id        = 1007,
    mode      = server,
	type      = 1,
	size      = 100,
	page_size = 30,
	limen     = 3000,
	event     = 72,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "挂机效率"
find(1008) -> #cfg_rank{
	id        = 1008,
    mode      = server,
	type      = 1,
	size      = 100,
	page_size = 30,
	limen     = 10000,
	event     = 0,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "答题榜"
find(1010) -> #cfg_rank{
	id        = 1010,
    mode      = server,
	type      = 3,
	size      = 100,
	page_size = 30,
	limen     = 0,
	event     = 0,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "竞技场"
find(1011) -> #cfg_rank{
	id        = 1011,
    mode      = server,
	type      = 3,
	size      = 100,
	page_size = 5,
	limen     = 0,
	event     = 0,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "巅峰1v1"
find(1012) -> #cfg_rank{
	id        = 1012,
    mode      = server,
	type      = 3,
	size      = 50,
	page_size = 5,
	limen     = 0,
	event     = 0,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "勇者圣坛"
find(1013) -> #cfg_rank{
	id        = 1013,
    mode      = server,
	type      = 3,
	size      = 100,
	page_size = 5,
	limen     = 0,
	event     = 0,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "宠物战力榜"
find(1014) -> #cfg_rank{
	id        = 1014,
    mode      = server,
	type      = 2,
	size      = 100,
	page_size = 30,
	limen     = 200000,
	event     = 69,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "守卫公会"
find(1015) -> #cfg_rank{
	id        = 1015,
    mode      = server,
	type      = 3,
	size      = 100,
	page_size = 5,
	limen     = 0,
	event     = 0,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "神灵战力"
find(1016) -> #cfg_rank{
	id        = 1016,
    mode      = server,
	type      = 2,
	size      = 100,
	page_size = 30,
	limen     = 100000,
	event     = 72,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "子女点赞榜"
find(1017) -> #cfg_rank{
	id        = 1017,
    mode      = server,
	type      = 3,
	size      = 30,
	page_size = 30,
	limen     = 1,
	event     = 0,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "图鉴战力"
find(1018) -> #cfg_rank{
	id        = 1018,
    mode      = server,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 125000,
	event     = 80,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "子女战力"
find(1019) -> #cfg_rank{
	id        = 1019,
    mode      = server,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 70000,
	event     = 83,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "子女战力"
find(1020) -> #cfg_rank{
	id        = 1020,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 80000,
	event     = 83,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "开服等级"
find(110501) -> #cfg_rank{
	id        = 110501,
    mode      = server,
	type      = 2,
	size      = 30,
	page_size = 30,
	limen     = 200,
	event     = 1,
	actid     = 110501,
	copy      = 1001,
	rank_limen = []
};
%% "开服坐骑"
find(110502) -> #cfg_rank{
	id        = 110502,
    mode      = server,
	type      = 2,
	size      = 30,
	page_size = 30,
	limen     = 35,
	event     = 17,
	actid     = 110502,
	copy      = 1003,
	rank_limen = []
};
%% "开服副手"
find(110503) -> #cfg_rank{
	id        = 110503,
    mode      = server,
	type      = 2,
	size      = 30,
	page_size = 30,
	limen     = 35,
	event     = 17,
	actid     = 110503,
	copy      = 1004,
	rank_limen = []
};
%% "开服魔法卡"
find(110504) -> #cfg_rank{
	id        = 110504,
    mode      = server,
	type      = 2,
	size      = 30,
	page_size = 30,
	limen     = 60000,
	event     = 23,
	actid     = 110504,
	copy      = 1005,
	rank_limen = []
};
%% "开服充值"
find(110505) -> #cfg_rank{
	id        = 110505,
    mode      = server,
	type      = 2,
	size      = 30,
	page_size = 30,
	limen     = 15000,
	event     = 16,
	actid     = 110505,
	copy      = 0,
	rank_limen = []
};
%% "开服战力"
find(110506) -> #cfg_rank{
	id        = 110506,
    mode      = server,
	type      = 2,
	size      = 30,
	page_size = 30,
	limen     = 1200000,
	event     = 12,
	actid     = 110506,
	copy      = 1002,
	rank_limen = []
};
%% "宠物总战力"
find(130101) -> #cfg_rank{
	id        = 130101,
    mode      = server,
	type      = 2,
	size      = 30,
	page_size = 30,
	limen     = 200000,
	event     = 69,
	actid     = 130101,
	copy      = 1014,
	rank_limen = []
};
%% "神灵总战力"
find(150101) -> #cfg_rank{
	id        = 150101,
    mode      = server,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 100000,
	event     = 72,
	actid     = 150101,
	copy      = 1016,
	rank_limen = []
};
%% "图鉴总战力"
find(174001) -> #cfg_rank{
	id        = 174001,
    mode      = server,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 125000,
	event     = 80,
	actid     = 174000,
	copy      = 1018,
	rank_limen = []
};
%% "子女总战力"
find(175001) -> #cfg_rank{
	id        = 175001,
    mode      = server,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 70000,
	event     = 83,
	actid     = 174000,
	copy      = 0,
	rank_limen = []
};
%% "子女总战力"
find(175002) -> #cfg_rank{
	id        = 175002,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 80000,
	event     = 83,
	actid     = 174000,
	copy      = 0,
	rank_limen = []
};
%% "巅峰1v1（跨服）"
find(2012) -> #cfg_rank{
	id        = 2012,
    mode      = cross,
	type      = 3,
	size      = 50,
	page_size = 5,
	limen     = 0,
	event     = 0,
	actid     = 0,
	copy      = 0,
	rank_limen = []
};
%% "合服魂卡"
find(180501) -> #cfg_rank{
	id        = 180501,
    mode      = server,
	type      = 2,
	size      = 30,
	page_size = 30,
	limen     = 300000,
	event     = 23,
	actid     = 180501,
	copy      = 1005,
	rank_limen = []
};
%% "合服圣痕"
find(180502) -> #cfg_rank{
	id        = 180502,
    mode      = server,
	type      = 2,
	size      = 30,
	page_size = 30,
	limen     = 300000,
	event     = 86,
	actid     = 180502,
	copy      = 0,
	rank_limen = []
};
%% "合服机甲"
find(180503) -> #cfg_rank{
	id        = 180503,
    mode      = server,
	type      = 2,
	size      = 30,
	page_size = 30,
	limen     = 300000,
	event     = 87,
	actid     = 180503,
	copy      = 0,
	rank_limen = []
};
%% "合服异兽"
find(180504) -> #cfg_rank{
	id        = 180504,
    mode      = server,
	type      = 2,
	size      = 30,
	page_size = 30,
	limen     = 300000,
	event     = 88,
	actid     = 180504,
	copy      = 0,
	rank_limen = []
};
%% "合服消费"
find(180505) -> #cfg_rank{
	id        = 180505,
    mode      = server,
	type      = 2,
	size      = 30,
	page_size = 30,
	limen     = 3000,
	event     = 43,
	actid     = 180505,
	copy      = 0,
	rank_limen = []
};
%% "合服充值"
find(180506) -> #cfg_rank{
	id        = 180506,
    mode      = server,
	type      = 2,
	size      = 30,
	page_size = 30,
	limen     = 3000,
	event     = 16,
	actid     = 180506,
	copy      = 0,
	rank_limen = []
};
%% "限时冲榜所需积分"
find(100003) -> #cfg_rank{
	id        = 100003,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 15,
	event     = 48,
	actid     = 100003,
	copy      = 0,
	rank_limen = [{1,1,300}, {2,2,180}, {3,3,160}, {4,5,130}, {6,10,100}, {11,20,80}, {21,30,50}, {31,40,30}, {41,50,15}]
};
%% "限时冲榜所需积分"
find(100013) -> #cfg_rank{
	id        = 100013,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 20,
	event     = 48,
	actid     = 100013,
	copy      = 0,
	rank_limen = [{1,1,500}, {2,2,400}, {3,3,300}, {4,5,130}, {6,10,100}, {11,20,80}, {21,30,50}, {31,40,30}, {41,50,20}]
};
%% "限时冲榜所需积分"
find(100015) -> #cfg_rank{
	id        = 100015,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 20,
	event     = 48,
	actid     = 100015,
	copy      = 0,
	rank_limen = [{1,1,400}, {2,2,300}, {3,3,200}, {4,5,130}, {6,10,100}, {11,20,80}, {21,30,50}, {31,40,30}, {41,50,20}]
};
%% "限时冲榜所需积分"
find(100017) -> #cfg_rank{
	id        = 100017,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 15,
	event     = 48,
	actid     = 100017,
	copy      = 0,
	rank_limen = [{1,1,300}, {2,2,180}, {3,3,160}, {4,5,130}, {6,10,100}, {11,20,80}, {21,30,50}, {31,40,30}, {41,50,15}]
};
%% "限时冲榜所需积分"
find(100019) -> #cfg_rank{
	id        = 100019,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 15,
	event     = 48,
	actid     = 100019,
	copy      = 0,
	rank_limen = [{1,1,300}, {2,2,180}, {3,3,160}, {4,5,130}, {6,10,100}, {11,20,80}, {21,30,50}, {31,40,30}, {41,50,15}]
};
%% "限时冲榜所需积分"
find(100021) -> #cfg_rank{
	id        = 100021,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 15,
	event     = 48,
	actid     = 100021,
	copy      = 0,
	rank_limen = [{1,1,300}, {2,2,180}, {3,3,160}, {4,5,130}, {6,10,100}, {11,20,80}, {21,30,50}, {31,40,30}, {41,50,15}]
};
%% "限时冲榜所需积分"
find(100023) -> #cfg_rank{
	id        = 100023,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 15,
	event     = 48,
	actid     = 100023,
	copy      = 0,
	rank_limen = [{1,1,300}, {2,2,180}, {3,3,160}, {4,5,130}, {6,10,100}, {11,20,80}, {21,30,50}, {31,40,30}, {41,50,15}]
};
%% "限时冲榜所需积分"
find(100025) -> #cfg_rank{
	id        = 100025,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 15,
	event     = 48,
	actid     = 100025,
	copy      = 0,
	rank_limen = [{1,1,300}, {2,2,180}, {3,3,160}, {4,5,130}, {6,10,100}, {11,20,80}, {21,30,50}, {31,40,30}, {41,50,15}]
};
%% "限时冲榜所需积分"
find(100027) -> #cfg_rank{
	id        = 100027,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 15,
	event     = 48,
	actid     = 100027,
	copy      = 0,
	rank_limen = [{1,1,300}, {2,2,180}, {3,3,160}, {4,5,130}, {6,10,100}, {11,20,80}, {21,30,50}, {31,40,30}, {41,50,15}]
};
%% "限时冲榜所需积分"
find(100029) -> #cfg_rank{
	id        = 100029,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 15,
	event     = 48,
	actid     = 100029,
	copy      = 0,
	rank_limen = [{1,1,300}, {2,2,180}, {3,3,160}, {4,5,130}, {6,10,100}, {11,20,80}, {21,30,50}, {31,40,30}, {41,50,15}]
};
%% "限时冲榜所需积分"
find(110031) -> #cfg_rank{
	id        = 110031,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 15,
	event     = 48,
	actid     = 110031,
	copy      = 0,
	rank_limen = [{1,1,300}, {2,2,180}, {3,3,160}, {4,5,130}, {6,10,100}, {11,20,80}, {21,30,50}, {31,40,30}, {41,50,15}]
};
%% "限时冲榜所需积分"
find(110033) -> #cfg_rank{
	id        = 110033,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 15,
	event     = 48,
	actid     = 110033,
	copy      = 0,
	rank_limen = [{1,1,300}, {2,2,180}, {3,3,160}, {4,5,130}, {6,10,100}, {11,20,80}, {21,30,50}, {31,40,30}, {41,50,15}]
};
%% "限时冲榜所需积分"
find(110035) -> #cfg_rank{
	id        = 110035,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 15,
	event     = 48,
	actid     = 110035,
	copy      = 0,
	rank_limen = [{1,1,300}, {2,2,180}, {3,3,160}, {4,5,130}, {6,10,100}, {11,20,80}, {21,30,50}, {31,40,30}, {41,50,15}]
};
%% "限时冲榜所需积分"
find(110037) -> #cfg_rank{
	id        = 110037,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 15,
	event     = 48,
	actid     = 110037,
	copy      = 0,
	rank_limen = [{1,1,300}, {2,2,180}, {3,3,160}, {4,5,130}, {6,10,100}, {11,20,80}, {21,30,50}, {31,40,30}, {41,50,15}]
};
%% "限时冲榜所需积分"
find(110039) -> #cfg_rank{
	id        = 110039,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 15,
	event     = 48,
	actid     = 110039,
	copy      = 0,
	rank_limen = [{1,1,300}, {2,2,180}, {3,3,160}, {4,5,130}, {6,10,100}, {11,20,80}, {21,30,50}, {31,40,30}, {41,50,15}]
};
%% "限时冲榜所需积分"
find(110041) -> #cfg_rank{
	id        = 110041,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 15,
	event     = 48,
	actid     = 110041,
	copy      = 0,
	rank_limen = [{1,1,300}, {2,2,180}, {3,3,160}, {4,5,130}, {6,10,100}, {11,20,80}, {21,30,50}, {31,40,30}, {41,50,15}]
};
%% "限时冲榜所需积分"
find(110043) -> #cfg_rank{
	id        = 110043,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 20,
	event     = 48,
	actid     = 110043,
	copy      = 0,
	rank_limen = [{1,1,500}, {2,2,400}, {3,3,300}, {4,5,130}, {6,10,100}, {11,20,80}, {21,30,50}, {31,40,30}, {41,50,20}]
};
%% "限时冲榜所需积分"
find(110045) -> #cfg_rank{
	id        = 110045,
    mode      = cross,
	type      = 2,
	size      = 50,
	page_size = 30,
	limen     = 15,
	event     = 48,
	actid     = 110045,
	copy      = 0,
	rank_limen = [{1,1,300}, {2,2,180}, {3,3,160}, {4,5,130}, {6,10,100}, {11,20,80}, {21,30,50}, {31,40,30}, {41,50,15}]
};
find(_) -> undefined.

all() -> [100015,1007,110502,180501,1010,174001,1002,100017,100029,130101,175001,110037,110041,1003,1012,100019,100023,175002,100025,110031,1015,110505,180504,1006,1018,1020,110504,100003,1004,1008,1014,110501,100021,150101,180505,100027,110033,1017,110506,2012,180502,180506,110035,110503,1005,1013,180503,1016,110039,110043,1001,100013,110045,1011,1019].


local() -> [130101,1010,1013,110503,1018,110501,180505,110505,150101,180503,1003,1017,1019,175001,180504,1002,1008,1012,1004,1011,1015,180502,1005,1014,1016,110504,180506,1001,1007,110502,180501,1006,110506,174001].



cross() -> [110033,110037,110039,1020,100025,100027,100023,110043,2012,100017,100019,110035,110041,110045,175002,100003,100015,110031,100013,100021,100029].


events() -> [{80, undefined, 174001},{48, undefined, 100019},{0, undefined, 1010},{72, undefined, 1016},{17, 1, 110502},{16, undefined, 110505},{0, undefined, 1008},{23, undefined, 110504},{72, undefined, 150101},{48, undefined, 100017},{48, undefined, 110039},{17, 5, 1004},{69, undefined, 1006},{0, undefined, 1013},{69, undefined, 1014},{83, undefined, 1020},{48, undefined, 110031},{43, undefined, 180505},{69, undefined, 130101},{48, undefined, 100013},{48, undefined, 100027},{12, undefined, 1002},{48, undefined, 100003},{48, undefined, 100029},{48, undefined, 110045},{0, undefined, 1015},{83, undefined, 1019},{83, undefined, 175001},{48, undefined, 110037},{0, undefined, 1012},{23, undefined, 1005},{86, undefined, 180502},{87, undefined, 180503},{48, undefined, 110041},{1, undefined, 1001},{0, undefined, 1011},{12, undefined, 110506},{23, undefined, 180501},{16, undefined, 180506},{48, undefined, 100021},{48, undefined, 100025},{48, undefined, 110043},{48, undefined, 100023},{72, undefined, 1007},{0, undefined, 1017},{17, 1, 1003},{1, undefined, 110501},{83, undefined, 175002},{0, undefined, 2012},{48, undefined, 100015},{80, undefined, 1018},{17, 5, 110503},{88, undefined, 180504},{48, undefined, 110033},{48, undefined, 110035}].
