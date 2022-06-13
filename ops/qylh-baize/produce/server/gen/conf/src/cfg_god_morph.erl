% Automatically generated, do not edit
-module(cfg_god_morph).

-compile([export_all]).
-compile(nowarn_export_all).

-include("morph.hrl").

find(60000) -> #cfg_morph{
    id    = 60000,
    color = 4,
    name  = "千冢锄甲卫",
    reqs  = [],
    cost  = []
};
find(60102) -> #cfg_morph{
    id    = 60102,
    color = 4,
    name  = "须佐武道灵",
    reqs  = [],
    cost  = []
};
find(60103) -> #cfg_morph{
    id    = 60103,
    color = 4,
    name  = "卜之星女巫",
    reqs  = [],
    cost  = []
};
find(60104) -> #cfg_morph{
    id    = 60104,
    color = 4,
    name  = "沙之海祭师",
    reqs  = [],
    cost  = []
};
find(60201) -> #cfg_morph{
    id    = 60201,
    color = 5,
    name  = "六翼寓言使",
    reqs  = [],
    cost  = []
};
find(60202) -> #cfg_morph{
    id    = 60202,
    color = 5,
    name  = "奥法光明王",
    reqs  = [],
    cost  = []
};
find(60203) -> #cfg_morph{
    id    = 60203,
    color = 5,
    name  = "魔灵双刀使",
    reqs  = [],
    cost  = []
};
find(60204) -> #cfg_morph{
    id    = 60204,
    color = 5,
    name  = "铠甲圣剑士",
    reqs  = [],
    cost  = []
};
find(60301) -> #cfg_morph{
    id    = 60301,
    color = 6,
    name  = "炎烈戮神将",
    reqs  = [],
    cost  = []
};
find(60302) -> #cfg_morph{
    id    = 60302,
    color = 6,
    name  = "超时空乐师",
    reqs  = [],
    cost  = []
};
find(60303) -> #cfg_morph{
    id    = 60303,
    color = 6,
    name  = "鲜血伯爵",
    reqs  = [],
    cost  = []
};
find(60401) -> #cfg_morph{
    id    = 60401,
    color = 7,
    name  = "粉色仙子",
    reqs  = [],
    cost  = []
};
find(60402) -> #cfg_morph{
    id    = 60402,
    color = 7,
    name  = "三枪双月王",
    reqs  = [],
    cost  = []
};
find(_) -> undefined.

list() -> [60103,60202,60203,60204,60301,60302,60303,60000,60402,60104,60201,60401,60102].

res(60000) -> 10000;
res(60102) -> 10002;
res(60103) -> 10009;
res(60104) -> 10008;
res(60201) -> 10004;
res(60202) -> 10001;
res(60203) -> 10006;
res(60204) -> 10007;
res(60301) -> 10005;
res(60302) -> 10003;
res(60303) -> 10010;
res(60401) -> 10011;
res(60402) -> 10012;
res(_) -> 0.
