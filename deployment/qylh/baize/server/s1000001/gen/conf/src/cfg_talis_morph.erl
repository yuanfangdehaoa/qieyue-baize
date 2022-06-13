% Automatically generated, do not edit
-module(cfg_talis_morph).

-compile([export_all]).
-compile(nowarn_export_all).

-include("morph.hrl").

find(30000) -> #cfg_morph{
	id   = 30000,
	name = "默认法宝",
	reqs = [],
	cost = []
};
find(30001) -> #cfg_morph{
	id   = 30001,
	name = "异星魔仆",
	reqs = [{wake,1}],
	cost = [{52101,1}]
};
find(30002) -> #cfg_morph{
	id   = 30002,
	name = "远古光核",
	reqs = [{wake,2}],
	cost = [{52102,1}]
};
find(30003) -> #cfg_morph{
	id   = 30003,
	name = "魔龙宝珠",
	reqs = [{wake,3}],
	cost = [{52103,1}]
};
find(30004) -> #cfg_morph{
	id   = 30004,
	name = "通晓水晶",
	reqs = [{wake,4}],
	cost = [{52104,1}]
};
find(30005) -> #cfg_morph{
	id   = 30005,
	name = "时之沙漏",
	reqs = [{wake,1}],
	cost = [{52105,1}]
};
find(30006) -> #cfg_morph{
	id   = 30006,
	name = "钢铁之魂",
	reqs = [{wake,1}],
	cost = [{52106,1}]
};
find(30007) -> #cfg_morph{
	id   = 30007,
	name = "炎龙",
	reqs = [{wake,1}],
	cost = [{52107,1}]
};
find(30008) -> #cfg_morph{
	id   = 30008,
	name = "轮回星愿",
	reqs = [{wake,1}],
	cost = [{52108,1}]
};
find(30009) -> #cfg_morph{
	id   = 30009,
	name = "法老面具",
	reqs = [{wake,1}],
	cost = [{52109,1}]
};
find(30010) -> #cfg_morph{
	id   = 30010,
	name = "黎明之光",
	reqs = [{wake,5}],
	cost = [{52110,1}]
};
find(30011) -> #cfg_morph{
	id   = 30011,
	name = "魔法陀螺",
	reqs = [{wake,1}],
	cost = [{52111,1}]
};
find(30012) -> #cfg_morph{
	id   = 30012,
	name = "翡翠灵台",
	reqs = [{wake,1}],
	cost = [{52112,1}]
};
find(30013) -> #cfg_morph{
	id   = 30013,
	name = "点翠团扇",
	reqs = [{wake,1}],
	cost = [{52113,1}]
};
find(30014) -> #cfg_morph{
	id   = 30014,
	name = "神后金盏",
	reqs = [{wake,6}],
	cost = [{52120,1}]
};
find(_) -> undefined.

list() -> [30004,30006,30007,30009,30013,30000,30003,30014,30008,30011,30001,30005,30012,30002,30010].

res(30000) -> 10000;
res(30001) -> 10001;
res(30002) -> 10002;
res(30003) -> 10003;
res(30004) -> 10004;
res(30005) -> 10005;
res(30006) -> 10006;
res(30007) -> 10008;
res(30008) -> 10007;
res(30009) -> 10009;
res(30010) -> 10010;
res(30011) -> 10011;
res(30012) -> 10012;
res(30013) -> 10013;
res(30014) -> 10015;
res(_) -> 0.
