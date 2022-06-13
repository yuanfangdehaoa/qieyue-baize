% Automatically generated, do not edit
-module(cfg_offhand_morph).

-compile([export_all]).
-compile(nowarn_export_all).

-include("morph.hrl").

find(55002) -> #cfg_morph{
	id    = 55002,
	name  = "无限手套",
	reqs  = [],
	cost  = [{55002,1}],
	speed = 0,
	msgno = 11082002
};
find(55003) -> #cfg_morph{
	id    = 55003,
	name  = "谶言",
	reqs  = [],
	cost  = [{55003,1}],
	speed = 0,
	msgno = 11082002
};
find(55004) -> #cfg_morph{
	id    = 55004,
	name  = "幻影手套",
	reqs  = [],
	cost  = [{55004,1}],
	speed = 0,
	msgno = 11082002
};
find(55005) -> #cfg_morph{
	id    = 55005,
	name  = "钢铁侠",
	reqs  = [],
	cost  = [{55005,1}],
	speed = 0,
	msgno = 11082002
};
find(55010) -> #cfg_morph{
	id    = 55010,
	name  = "熊大爪",
	reqs  = [],
	cost  = [{55010,1}],
	speed = 0,
	msgno = 11082002
};
find(55011) -> #cfg_morph{
	id    = 55011,
	name  = "猫猫拳",
	reqs  = [],
	cost  = [{55011,1}],
	speed = 0,
	msgno = 11082002
};
find(_) -> undefined.

list() -> [55002,55003,55004,55005,55010,55011].

res(55002) -> 10008;
res(55003) -> 10007;
res(55004) -> 10011;
res(55005) -> 10012;
res(55010) -> 10016;
res(55011) -> 10014;
res(_) -> 0.

model(55002) -> [{1,91008},{2,92008}];
model(55003) -> [{1,91007},{2,92007}];
model(55004) -> [{1,91011},{2,92011}];
model(55005) -> [{1,91012},{2,92012}];
model(55010) -> [{1,91016},{2,92016}];
model(55011) -> [{1,91014},{2,92014}];
model(_) -> 0.
