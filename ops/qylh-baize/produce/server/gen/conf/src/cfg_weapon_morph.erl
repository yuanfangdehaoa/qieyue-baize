% Automatically generated, do not edit
-module(cfg_weapon_morph).

-compile([export_all]).
-compile(nowarn_export_all).

-include("morph.hrl").

find(41000) -> #cfg_morph{
	id   = 41000,
	name = "默认男神兵",
	reqs = [{gender,1}],
	cost = []
};
find(42000) -> #cfg_morph{
	id   = 42000,
	name = "默认女神兵",
	reqs = [{gender,2}],
	cost = []
};
find(40001) -> #cfg_morph{
	id   = 40001,
	name = "含光雷电",
	reqs = [],
	cost = [{53101,1}]
};
find(40002) -> #cfg_morph{
	id   = 40002,
	name = "霜之哀伤",
	reqs = [],
	cost = [{53102,1}]
};
find(40003) -> #cfg_morph{
	id   = 40003,
	name = "血色黎明",
	reqs = [],
	cost = [{53103,1}]
};
find(40004) -> #cfg_morph{
	id   = 40004,
	name = "诸神黄昏",
	reqs = [],
	cost = [{53104,1}]
};
find(40005) -> #cfg_morph{
	id   = 40005,
	name = "七度空间",
	reqs = [],
	cost = [{53105,1}]
};
find(40006) -> #cfg_morph{
	id   = 40006,
	name = "钢铁之心",
	reqs = [],
	cost = [{53106,1}]
};
find(40007) -> #cfg_morph{
	id   = 40007,
	name = "贤者圣剑",
	reqs = [],
	cost = [{53107,1}]
};
find(40008) -> #cfg_morph{
	id   = 40008,
	name = "冥王暴杀",
	reqs = [],
	cost = [{53108,1}]
};
find(40009) -> #cfg_morph{
	id   = 40009,
	name = "辉洁灵光",
	reqs = [],
	cost = [{53119,1}]
};
find(40010) -> #cfg_morph{
	id   = 40010,
	name = "万圣夜魔",
	reqs = [],
	cost = [{53120,1}]
};
find(40011) -> #cfg_morph{
	id   = 40011,
	name = "黑岩之炽",
	reqs = [],
	cost = [{53121,1}]
};
find(40012) -> #cfg_morph{
	id   = 40012,
	name = "雷霆王者",
	reqs = [],
	cost = [{53122,1}]
};
find(40013) -> #cfg_morph{
	id   = 40013,
	name = "轰炸大鱿鱼",
	reqs = [],
	cost = [{53123,1}]
};
find(40014) -> #cfg_morph{
	id   = 40014,
	name = "铃兰飘香",
	reqs = [],
	cost = [{53124,1}]
};
find(40015) -> #cfg_morph{
	id   = 40015,
	name = "玄铁赤炎",
	reqs = [],
	cost = [{53125,1}]
};
find(40016) -> #cfg_morph{
	id   = 40016,
	name = "紫宸魂兵",
	reqs = [],
	cost = [{53126,1}]
};
find(40017) -> #cfg_morph{
	id   = 40017,
	name = "湛蓝冰语",
	reqs = [],
	cost = [{53127,1}]
};
find(_) -> undefined.

list() -> [40004,40008,40009,40010,41000,40002,40006,40007,40012,40015,40016,42000,40001,40011,40013,40014,40003,40005,40017].

res(41000) -> 10501;
res(42000) -> 10502;
res(40001) -> 10001;
res(40002) -> 10002;
res(40003) -> 10003;
res(40004) -> 10004;
res(40005) -> 10005;
res(40006) -> 10007;
res(40007) -> 10008;
res(40008) -> 10009;
res(40009) -> 10014;
res(40010) -> 10010;
res(40011) -> 10013;
res(40012) -> 10012;
res(40013) -> 10011;
res(40014) -> 10015;
res(40015) -> 10016;
res(40016) -> 10017;
res(40017) -> 10018;
res(_) -> 0.
