% Automatically generated, do not edit
-module(cfg_bag).

-compile([export_all]).
-compile(nowarn_export_all).

-include("bag.hrl").

find(101) -> #cfg_bag{
	id   = 101,
	name = "背包",
	type = 1,
	cap  = 300,
	open = 200,
	cost = [{11000,2}]
};
find(102) -> #cfg_bag{
	id   = 102,
	name = "圣痕背包",
	type = 1,
	cap  = 200,
	open = 200,
	cost = [{undefined}]
};
find(103) -> #cfg_bag{
	id   = 103,
	name = "魂卡背包",
	type = 1,
	cap  = 300,
	open = 300,
	cost = [{undefined}]
};
find(104) -> #cfg_bag{
	id   = 104,
	name = "异兽背包",
	type = 1,
	cap  = 200,
	open = 200,
	cost = [{undefined}]
};
find(105) -> #cfg_bag{
	id   = 105,
	name = "宠物背包",
	type = 1,
	cap  = 200,
	open = 200,
	cost = [{undefined}]
};
find(106) -> #cfg_bag{
	id   = 106,
	name = "子女背包",
	type = 1,
	cap  = 200,
	open = 200,
	cost = [{undefined}]
};
find(107) -> #cfg_bag{
	id   = 107,
	name = "图鉴背包",
	type = 1,
	cap  = 203,
	open = 203,
	cost = [{undefined}]
};
find(108) -> #cfg_bag{
	id   = 108,
	name = "神灵背包",
	type = 1,
	cap  = 200,
	open = 200,
	cost = [{undefined}]
};
find(109) -> #cfg_bag{
	id   = 109,
	name = "机甲背包",
	type = 1,
	cap  = 200,
	open = 200,
	cost = [{undefined}]
};
find(110) -> #cfg_bag{
	id   = 110,
	name = "宠物装备背包",
	type = 1,
	cap  = 200,
	open = 200,
	cost = [{undefined}]
};
find(401) -> #cfg_bag{
	id   = 401,
	name = "神器背包",
	type = 4,
	cap  = 500,
	open = 500,
	cost = [{undefined}]
};
find(201) -> #cfg_bag{
	id   = 201,
	name = "仓库",
	type = 2,
	cap  = 204,
	open = 96,
	cost = [{11000,2}]
};
find(202) -> #cfg_bag{
	id   = 202,
	name = "寻宝仓库",
	type = 2,
	cap  = 200,
	open = 200,
	cost = [{undefined}]
};
find(301) -> #cfg_bag{
	id   = 301,
	name = "异兽穿戴背包",
	type = 3,
	cap  = 200,
	open = 200,
	cost = [{undefined}]
};
find(302) -> #cfg_bag{
	id   = 302,
	name = "装备背包",
	type = 3,
	cap  = 60,
	open = 60,
	cost = [{undefined}]
};
find(303) -> #cfg_bag{
	id   = 303,
	name = "宠物助战背包",
	type = 3,
	cap  = 60,
	open = 60,
	cost = [{undefined}]
};
find(304) -> #cfg_bag{
	id   = 304,
	name = "魂卡穿戴背包",
	type = 3,
	cap  = 60,
	open = 60,
	cost = [{undefined}]
};
find(305) -> #cfg_bag{
	id   = 305,
	name = "圣痕穿戴背包",
	type = 3,
	cap  = 200,
	open = 200,
	cost = [{undefined}]
};
find(306) -> #cfg_bag{
	id   = 306,
	name = "子女穿戴背包",
	type = 3,
	cap  = 60,
	open = 60,
	cost = [{undefined}]
};
find(308) -> #cfg_bag{
	id   = 308,
	name = "神灵穿戴背包",
	type = 3,
	cap  = 60,
	open = 60,
	cost = [{undefined}]
};
find(309) -> #cfg_bag{
	id   = 309,
	name = "机甲穿戴背包",
	type = 3,
	cap  = 60,
	open = 60,
	cost = [{undefined}]
};
find(310) -> #cfg_bag{
	id   = 310,
	name = "宠物装备穿戴背包",
	type = 3,
	cap  = 60,
	open = 60,
	cost = [{undefined}]
};
find(402) -> #cfg_bag{
	id   = 402,
	name = "图腾背包",
	type = 1,
	cap  = 200,
	open = 200,
	cost = [{undefined}]
};
find(403) -> #cfg_bag{
	id   = 403,
	name = "图腾穿戴背包",
	type = 3,
	cap  = 200,
	open = 200,
	cost = [{undefined}]
};
find(_) -> undefined.

bags() -> [108,109,302,306,308,310,101,102,402,110,401,305,103,107,106,202,201,301,303,304,309,403,104,105].
