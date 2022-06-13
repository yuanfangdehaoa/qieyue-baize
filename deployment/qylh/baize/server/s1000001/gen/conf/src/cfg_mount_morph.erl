% Automatically generated, do not edit
-module(cfg_mount_morph).

-compile([export_all]).
-compile(nowarn_export_all).

-include("morph.hrl").

find(30000) -> #cfg_morph{
	id    = 30000,
	name  = "旅行狮鹫",
	reqs  = [],
	cost  = [{50101,1}],
	speed = 75,
	msgno = 11081002
};
find(30001) -> #cfg_morph{
	id    = 30001,
	name  = "冰霜巨龙",
	reqs  = [],
	cost  = [{50102,1}],
	speed = 30,
	msgno = 11081002
};
find(30002) -> #cfg_morph{
	id    = 30002,
	name  = "驯鹿号",
	reqs  = [],
	cost  = [{50103,1}],
	speed = 75,
	msgno = 11081002
};
find(30003) -> #cfg_morph{
	id    = 30003,
	name  = "混沌巨像",
	reqs  = [],
	cost  = [{50104,1}],
	speed = 75,
	msgno = 11081002
};
find(30004) -> #cfg_morph{
	id    = 30004,
	name  = "黄金雄狮",
	reqs  = [],
	cost  = [{50105,1}],
	speed = 75,
	msgno = 11081002
};
find(30005) -> #cfg_morph{
	id    = 30005,
	name  = "力矩号",
	reqs  = [],
	cost  = [{50106,1}],
	speed = 75,
	msgno = 11081002
};
find(30006) -> #cfg_morph{
	id    = 30006,
	name  = "超离子号",
	reqs  = [],
	cost  = [{50107,1}],
	speed = 75,
	msgno = 11081002
};
find(30007) -> #cfg_morph{
	id    = 30007,
	name  = "亚特拉斯号",
	reqs  = [],
	cost  = [{50108,1}],
	speed = 75,
	msgno = 11081002
};
find(30008) -> #cfg_morph{
	id    = 30008,
	name  = "钢铁之驹",
	reqs  = [],
	cost  = [{50109,1}],
	speed = 75,
	msgno = 11081002
};
find(30009) -> #cfg_morph{
	id    = 30009,
	name  = "皇室小象",
	reqs  = [],
	cost  = [{50110,1}],
	speed = 75,
	msgno = 11081002
};
find(30010) -> #cfg_morph{
	id    = 30010,
	name  = "九尾狐",
	reqs  = [],
	cost  = [{50111,1}],
	speed = 75,
	msgno = 11081002
};
find(30011) -> #cfg_morph{
	id    = 30011,
	name  = "小迷橙",
	reqs  = [],
	cost  = [{50112,1}],
	speed = 75,
	msgno = 11081002
};
find(30012) -> #cfg_morph{
	id    = 30012,
	name  = "卓雅麋鹿",
	reqs  = [],
	cost  = [{50113,1}],
	speed = 75,
	msgno = 11081002
};
find(30013) -> #cfg_morph{
	id    = 30013,
	name  = "深海之鲲",
	reqs  = [],
	cost  = [{50114,1}],
	speed = 75,
	msgno = 11081002
};
find(_) -> undefined.

list() -> [30000,30005,30008,30011,30001,30002,30003,30007,30012,30006,30013,30004,30009,30010].

res(30000) -> 20001;
res(30001) -> 20002;
res(30002) -> 30001;
res(30003) -> 20003;
res(30004) -> 20004;
res(30005) -> 30002;
res(30006) -> 30003;
res(30007) -> 30004;
res(30008) -> 10010;
res(30009) -> 20005;
res(30010) -> 20007;
res(30011) -> 10012;
res(30012) -> 10011;
res(30013) -> 20008;
res(_) -> 0.
