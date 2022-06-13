% Automatically generated, do not edit
-module(cfg_wing_morph).

-compile([export_all]).
-compile(nowarn_export_all).

-include("morph.hrl").

find(21000) -> #cfg_morph{
	id   = 21000,
	name = "默认男翅膀",
	reqs = [{gender,1}],
	cost = []
};
find(21001) -> #cfg_morph{
	id   = 21001,
	name = "泰坦光羽",
	reqs = [{gender,1},{wake,1}],
	cost = [{51101,1}]
};
find(21002) -> #cfg_morph{
	id   = 21002,
	name = "仙林幽羽",
	reqs = [{gender,1},{wake,2}],
	cost = [{51102,1}]
};
find(21003) -> #cfg_morph{
	id   = 21003,
	name = "凝羽魔翼",
	reqs = [{gender,1},{wake,3}],
	cost = [{51103,1}]
};
find(21004) -> #cfg_morph{
	id   = 21004,
	name = "魔鸢巨翼",
	reqs = [{gender,1},{wake,4}],
	cost = [{51104,1}]
};
find(21005) -> #cfg_morph{
	id   = 21005,
	name = "圣灵羽翼",
	reqs = [{gender,1},{wake,5}],
	cost = [{51105,1}]
};
find(21006) -> #cfg_morph{
	id   = 21006,
	name = "马赫动力",
	reqs = [{gender,1},{wake,1}],
	cost = [{51106,1}]
};
find(21007) -> #cfg_morph{
	id   = 21007,
	name = "钢铁之羽",
	reqs = [{gender,1},{wake,1}],
	cost = [{51107,1}]
};
find(21008) -> #cfg_morph{
	id   = 21008,
	name = "胡萝卜邦妮",
	reqs = [{gender,1},{wake,1}],
	cost = [{51208,1}]
};
find(21009) -> #cfg_morph{
	id   = 21009,
	name = "灵光之翼",
	reqs = [{gender,1},{wake,1}],
	cost = [{51109,1}]
};
find(21010) -> #cfg_morph{
	id   = 21010,
	name = "黑白煞羽",
	reqs = [{gender,1},{wake,1}],
	cost = [{51110,1}]
};
find(21011) -> #cfg_morph{
	id   = 21011,
	name = "流樱化羽",
	reqs = [{gender,1},{wake,1}],
	cost = [{51111,1}]
};
find(21012) -> #cfg_morph{
	id   = 21012,
	name = "夜王蝠翼",
	reqs = [{gender,1},{wake,1}],
	cost = [{51112,1}]
};
find(21013) -> #cfg_morph{
	id   = 21013,
	name = "丹鸟之羽",
	reqs = [{gender,1},{wake,1}],
	cost = [{51113,1}]
};
find(21014) -> #cfg_morph{
	id   = 21014,
	name = "蒲英仙羽",
	reqs = [{gender,1},{wake,1}],
	cost = [{51114,1}]
};
find(21015) -> #cfg_morph{
	id   = 21015,
	name = "暗鸦之鸣",
	reqs = [{gender,1},{wake,6}],
	cost = [{51118,1}]
};
find(22000) -> #cfg_morph{
	id   = 22000,
	name = "默认女翅膀",
	reqs = [{gender,2}],
	cost = []
};
find(22001) -> #cfg_morph{
	id   = 22001,
	name = "泰坦光羽",
	reqs = [{gender,2},{wake,1}],
	cost = [{51101,1}]
};
find(22002) -> #cfg_morph{
	id   = 22002,
	name = "仙林幽羽",
	reqs = [{gender,2},{wake,2}],
	cost = [{51102,1}]
};
find(22003) -> #cfg_morph{
	id   = 22003,
	name = "凝羽魔翼",
	reqs = [{gender,2},{wake,3}],
	cost = [{51103,1}]
};
find(22004) -> #cfg_morph{
	id   = 22004,
	name = "魔鸢巨翼",
	reqs = [{gender,2},{wake,4}],
	cost = [{51104,1}]
};
find(22005) -> #cfg_morph{
	id   = 22005,
	name = "圣灵羽翼",
	reqs = [{gender,2},{wake,5}],
	cost = [{51105,1}]
};
find(22006) -> #cfg_morph{
	id   = 22006,
	name = "马赫动力",
	reqs = [{gender,2},{wake,1}],
	cost = [{51106,1}]
};
find(22007) -> #cfg_morph{
	id   = 22007,
	name = "钢铁之羽",
	reqs = [{gender,2},{wake,1}],
	cost = [{51107,1}]
};
find(22008) -> #cfg_morph{
	id   = 22008,
	name = "胡萝卜邦妮",
	reqs = [{gender,2},{wake,1}],
	cost = [{51208,1}]
};
find(22009) -> #cfg_morph{
	id   = 22009,
	name = "灵光之翼",
	reqs = [{gender,2},{wake,1}],
	cost = [{51109,1}]
};
find(22010) -> #cfg_morph{
	id   = 22010,
	name = "黑白煞羽",
	reqs = [{gender,2},{wake,1}],
	cost = [{51110,1}]
};
find(22011) -> #cfg_morph{
	id   = 22011,
	name = "流樱化羽",
	reqs = [{gender,2},{wake,1}],
	cost = [{51111,1}]
};
find(22012) -> #cfg_morph{
	id   = 22012,
	name = "夜王蝠翼",
	reqs = [{gender,2},{wake,1}],
	cost = [{51112,1}]
};
find(22013) -> #cfg_morph{
	id   = 22013,
	name = "丹鸟之羽",
	reqs = [{gender,2},{wake,1}],
	cost = [{51113,1}]
};
find(22014) -> #cfg_morph{
	id   = 22014,
	name = "蒲英仙羽",
	reqs = [{gender,2},{wake,1}],
	cost = [{51114,1}]
};
find(22015) -> #cfg_morph{
	id   = 22015,
	name = "暗鸦之鸣",
	reqs = [{gender,2},{wake,6}],
	cost = [{51118,1}]
};
find(_) -> undefined.

list() -> [21002,21003,21011,22000,22001,22003,22005,21001,22006,22009,22012,22013,22015,21008,21010,22002,21000,21005,21006,22004,22014,21004,21007,22008,21012,21013,21014,21015,22011,21009,22007,22010].

res(21000) -> 10000;
res(21001) -> 11001;
res(21002) -> 11002;
res(21003) -> 11006;
res(21004) -> 11003;
res(21005) -> 11004;
res(21006) -> 11005;
res(21007) -> 11008;
res(21008) -> 11010;
res(21009) -> 11009;
res(21010) -> 11007;
res(21011) -> 11011;
res(21012) -> 11012;
res(21013) -> 11013;
res(21014) -> 11014;
res(21015) -> 11015;
res(22000) -> 10000;
res(22001) -> 12001;
res(22002) -> 12002;
res(22003) -> 12006;
res(22004) -> 12003;
res(22005) -> 12004;
res(22006) -> 12005;
res(22007) -> 12008;
res(22008) -> 12010;
res(22009) -> 12009;
res(22010) -> 12007;
res(22011) -> 12011;
res(22012) -> 12012;
res(22013) -> 12013;
res(22014) -> 12014;
res(22015) -> 12015;
res(_) -> 0.
