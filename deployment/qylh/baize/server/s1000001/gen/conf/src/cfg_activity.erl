% Automatically generated, do not edit
-module(cfg_activity).

-compile([export_all]).
-compile(nowarn_export_all).

-include("activity.hrl").

find(10101) -> #cfg_activity{
    id    = 10101,
    name  = "极地穿越（双倍）",
    group = 101,
    type  = 1,
    level = 130,
    reqs  = [],
    cycle = daily,
    days  = [],
    pre   = 0,
    time  = [{{16,00,00},{16,30,00}}, {{21,30,00},{22,00,00}}],
    post  = 0,
    scene = 0,
    msgno = 160001
};
find(10111) -> #cfg_activity{
    id    = 10111,
    name  = "乱斗战场",
    group = 103,
    type  = 1,
    level = 115,
    reqs  = [{opdays,1,7}],
    cycle = weekly,
    days  = [2,4,6],
    pre   = 27600,
    time  = [{{20,00,00},{20,20,00}}],
    post  = 0,
    scene = 30311,
    msgno = 160001
};
find(10112) -> #cfg_activity{
    id    = 10112,
    name  = "乱斗战场（跨服）",
    group = 103,
    type  = 2,
    level = 115,
    reqs  = [{opdays, 8}],
    cycle = weekly,
    days  = [2,4,6],
    pre   = 27600,
    time  = [{{20,00,00},{20,20,00}}],
    post  = 0,
    scene = 30312,
    msgno = 160001
};
find(10121) -> #cfg_activity{
    id    = 10121,
    name  = "甜美糖果屋",
    group = 104,
    type  = 1,
    level = 130,
    reqs  = [{opdays,1,7}],
    cycle = daily,
    days  = [],
    pre   = 43200,
    time  = [{{12,00,00},{12,20,00}}],
    post  = 0,
    scene = 30341,
    msgno = 160001
};
find(10122) -> #cfg_activity{
    id    = 10122,
    name  = "甜美糖果屋（跨服）",
    group = 104,
    type  = 2,
    level = 130,
    reqs  = [{opdays, 8}],
    cycle = daily,
    days  = [],
    pre   = 43200,
    time  = [{{12,00,00},{12,20,00}}],
    post  = 0,
    scene = 30342,
    msgno = 160001
};
find(10124) -> #cfg_activity{
    id    = 10124,
    name  = "婚礼",
    group = 107,
    type  = 1,
    level = 130,
    reqs  = [appointment],
    cycle = daily,
    days  = [],
    pre   = 900,
    time  = [{{00,00,00},{00,15,00}}, {{01,00,00},{01,15,00}}, {{02,00,00},{02,15,00}}, {{03,00,00},{03,15,00}}, {{04,00,00},{04,15,00}}, {{05,00,00},{05,15,00}}, {{06,00,00},{06,15,00}}, {{07,00,00},{07,15,00}}, {{08,00,00},{08,15,00}}, {{09,00,00},{09,15,00}}, {{10,00,00},{10,15,00}}, {{11,00,00},{11,15,00}}, {{12,00,00},{12,15,00}}, {{13,00,00},{13,15,00}}, {{14,00,00},{14,15,00}}, {{15,00,00},{15,15,00}}, {{16,00,00},{16,15,00}}, {{17,00,00},{17,15,00}}, {{18,00,00},{18,15,00}}, {{19,00,00},{19,15,00}}, {{20,00,00},{20,15,00}}, {{21,00,00},{21,15,00}}, {{22,00,00},{22,15,00}}, {{23,00,00},{23,15,00}}],
    post  = 0,
    scene = 11314,
    msgno = 160001
};
find(10125) -> #cfg_activity{
    id    = 10125,
    name  = "巅峰1V1",
    group = 108,
    type  = 1,
    level = 140,
    reqs  = [{mode,local},{opdays, 3}],
    cycle = weekly,
    days  = [1,3,5],
    pre   = 600,
    time  = [{{21,00,00},{21,30,00}}],
    post  = 360,
    scene = 30372,
    msgno = 160001
};
find(10126) -> #cfg_activity{
    id    = 10126,
    name  = "巅峰1V1（跨服）",
    group = 108,
    type  = 2,
    level = 140,
    reqs  = [{mode,cross},{opdays, 3}],
    cycle = weekly,
    days  = [1,3,5],
    pre   = 600,
    time  = [{{21,00,00},{21,30,00}}],
    post  = 360,
    scene = 30373,
    msgno = 160001
};
find(10201) -> #cfg_activity{
    id    = 10201,
    name  = "公会大战",
    group = 102,
    type  = 1,
    level = 140,
    reqs  = [{opdays, 8}],
    cycle = weekly,
    days  = [7],
    pre   = 900,
    time  = [{{21,00,00},{21,20,00}}],
    post  = 0,
    scene = 30301,
    msgno = 160201
};
find(10202) -> #cfg_activity{
    id    = 10202,
    name  = "公会大战",
    group = 102,
    type  = 1,
    level = 140,
    reqs  = [{opdays, 8}],
    cycle = weekly,
    days  = [7],
    pre   = 180,
    time  = [{{21,25,00},{21,45,00}}],
    post  = 60,
    scene = 30301,
    msgno = 160202
};
find(10203) -> #cfg_activity{
    id    = 10203,
    name  = "公会大战（开服）",
    group = 102,
    type  = 1,
    level = 140,
    reqs  = [],
    cycle = opdays,
    days  = [3,7],
    pre   = 900,
    time  = [{{21,00,00},{21,20,00}}],
    post  = 0,
    scene = 30301,
    msgno = 160201
};
find(10204) -> #cfg_activity{
    id    = 10204,
    name  = "公会大战（开服）",
    group = 102,
    type  = 1,
    level = 140,
    reqs  = [],
    cycle = opdays,
    days  = [3,7],
    pre   = 295,
    time  = [{{21,25,00},{21,45,00}}],
    post  = 60,
    scene = 30301,
    msgno = 160202
};
find(10211) -> #cfg_activity{
    id    = 10211,
    name  = "公会盛会",
    group = 105,
    type  = 1,
    level = 130,
    reqs  = [],
    cycle = weekly,
    days  = [1,3,5],
    pre   = 600,
    time  = [{{20,30,00},{20,50,00}}],
    post  = 0,
    scene = 30361,
    msgno = 160001
};
find(10221) -> #cfg_activity{
    id    = 10221,
    name  = "守卫公会",
    group = 106,
    type  = 1,
    level = 130,
    reqs  = [{opdays, 2}],
    cycle = weekly,
    days  = [2,4,6],
    pre   = 600,
    time  = [{{20,30,00},{21,00,00}}],
    post  = 0,
    scene = 30381,
    msgno = 160001
};
find(10231) -> #cfg_activity{
    id    = 10231,
    name  = "勇者圣坛",
    group = 109,
    type  = 1,
    level = 130,
    reqs  = [{opdays,1,7}],
    cycle = weekly,
    days  = [1,3,5],
    pre   = 27600,
    time  = [{{20,00,00},{20,20,00}}],
    post  = 0,
    scene = 30391,
    msgno = 160001
};
find(10232) -> #cfg_activity{
    id    = 10232,
    name  = "勇者圣坛（跨服）",
    group = 109,
    type  = 2,
    level = 130,
    reqs  = [{opdays, 8}],
    cycle = weekly,
    days  = [1,3,5],
    pre   = 27600,
    time  = [{{20,00,00},{20,20,00}}],
    post  = 0,
    scene = 30393,
    msgno = 160001
};
find(11011) -> #cfg_activity{
    id    = 11011,
    name  = "钻石擂台报名（单服）",
    group = 110,
    type  = 1,
    level = 115,
    reqs  = [{period,1},{opdays,1,2}],
    cycle = opdays,
    days  = [],
    pre   = 300,
    time  = [{{1,{00,00,00}},{2,{18,50,00}},{2,{18,50,00}}}],
    post  = 2430,
    scene = 0,
    msgno = 160001
};
find(11012) -> #cfg_activity{
    id    = 11012,
    name  = "钻石擂台海选（单服）",
    group = 110,
    type  = 1,
    level = 115,
    reqs  = [{period,2},{opdays,1,2},{battle,30411}],
    cycle = opdays,
    days  = [2],
    pre   = 600,
    time  = [{{19,00,00},{19,17,20}}],
    post  = 990,
    scene = 30410,
    msgno = 160001
};
find(11013) -> #cfg_activity{
    id    = 11013,
    name  = "钻石擂台争霸赛（单服）",
    group = 110,
    type  = 1,
    level = 115,
    reqs  = [{period,3},{opdays,1,2},{battle,30411}],
    cycle = opdays,
    days  = [2],
    pre   = 10,
    time  = [{{19,17,40},{19,32,30}}],
    post  = 30,
    scene = 30410,
    msgno = 160001
};
find(11017) -> #cfg_activity{
    id    = 11017,
    name  = "钻石擂台报名（单服）",
    group = 110,
    type  = 1,
    level = 115,
    reqs  = [{period,1},{opdays,3,6}],
    cycle = weekly,
    days  = [],
    pre   = 300,
    time  = [{{6,{00,00,00}},{7,{18,50,00}},{7,{18,50,00}}}],
    post  = 2430,
    scene = 0,
    msgno = 160001
};
find(11018) -> #cfg_activity{
    id    = 11018,
    name  = "钻石擂台海选（单服）",
    group = 110,
    type  = 1,
    level = 115,
    reqs  = [{period,2},{opdays,3,6},{battle,30411}],
    cycle = weekly,
    days  = [7],
    pre   = 600,
    time  = [{{19,00,00},{19,17,20}}],
    post  = 990,
    scene = 30410,
    msgno = 160001
};
find(11019) -> #cfg_activity{
    id    = 11019,
    name  = "钻石擂台争霸赛（单服）",
    group = 110,
    type  = 1,
    level = 115,
    reqs  = [{period,3},{opdays,3,6},{battle,30411}],
    cycle = weekly,
    days  = [7],
    pre   = 10,
    time  = [{{19,17,40},{19,32,30}}],
    post  = 30,
    scene = 30410,
    msgno = 160001
};
find(11014) -> #cfg_activity{
    id    = 11014,
    name  = "钻石擂台报名（跨服）",
    group = 110,
    type  = 2,
    level = 115,
    reqs  = [{period,1},{opdays,7}],
    cycle = weekly,
    days  = [],
    pre   = 300,
    time  = [{{6,{00,00,00}},{7,{18,50,00}},{7,{18,50,00}}}],
    post  = 2430,
    scene = 0,
    msgno = 160001
};
find(11015) -> #cfg_activity{
    id    = 11015,
    name  = "钻石擂台海选（跨服）",
    group = 110,
    type  = 2,
    level = 115,
    reqs  = [{period,2},{opdays,7},{battle,30413}],
    cycle = weekly,
    days  = [7],
    pre   = 600,
    time  = [{{19,00,00},{19,17,20}}],
    post  = 990,
    scene = 30412,
    msgno = 160001
};
find(11016) -> #cfg_activity{
    id    = 11016,
    name  = "钻石擂台争霸赛（跨服）",
    group = 110,
    type  = 2,
    level = 115,
    reqs  = [{period,3},{opdays,7},{battle,30413}],
    cycle = weekly,
    days  = [7],
    pre   = 10,
    time  = [{{19,17,40},{19,32,30}}],
    post  = 30,
    scene = 30412,
    msgno = 160001
};
find(11101) -> #cfg_activity{
    id    = 11101,
    name  = "跨服首领",
    group = 111,
    type  = 2,
    level = 213,
    reqs  = [{opdays, 3}],
    cycle = weekly,
    days  = [2,4,6,7],
    pre   = 1800,
    time  = [{{14,00,00},{14,30,00}}, {{18,00,00},{18,30,00}}, {{21,00,00},{21,30,00}}],
    post  = 0,
    scene = 0,
    msgno = 0
};
find(11102) -> #cfg_activity{
    id    = 11102,
    name  = "跨服首领",
    group = 111,
    type  = 2,
    level = 213,
    reqs  = [{opdays, 3}],
    cycle = weekly,
    days  = [2,4,6,7],
    pre   = 1800,
    time  = [{14,0,0}, {18,0,0}, {21,0,0}],
    post  = 0,
    scene = 0,
    msgno = 0
};
find(11111) -> #cfg_activity{
    id    = 11111,
    name  = "机甲竞速",
    group = 112,
    type  = 1,
    level = 75,
    reqs  = [],
    cycle = daily,
    days  = [],
    pre   = 1800,
    time  = [{{11,40,00},{12,00,00}}, {{15,40,00},{16,00,00}}, {{18,30,00},{18,50,00}}],
    post  = 0,
    scene = 90001,
    msgno = 160001
};
find(11121) -> #cfg_activity{
    id    = 11121,
    name  = "夺城战首领刷新",
    group = 113,
    type  = 2,
    level = 300,
    reqs  = [],
    cycle = daily,
    days  = [],
    pre   = 1800,
    time  = [{{11,00,00},{11,30,00}}, {{15,20,00},{15,50,00}}, {{19,00,00},{19,30,00}}],
    post  = 0,
    scene = 0,
    msgno = 0
};
find(11123) -> #cfg_activity{
    id    = 11123,
    name  = "夺城战首领刷新",
    group = 113,
    type  = 2,
    level = 300,
    reqs  = [{period, reborn}],
    cycle = daily,
    days  = [],
    pre   = 1800,
    time  = [{11,00,00},{15,20,00},{19,00,00}],
    post  = 0,
    scene = 0,
    msgno = 0
};
find(11122) -> #cfg_activity{
    id    = 11122,
    name  = "夺城战城市刷新",
    group = 113,
    type  = 2,
    level = 300,
    reqs  = [{period, divide}],
    cycle = daily,
    days  = [],
    pre   = 1800,
    time  = [{0,0,0}],
    post  = 0,
    scene = 0,
    msgno = 0
};
find(12000) -> #cfg_activity{
    id    = 12000,
    name  = "星之王座",
    group = 114,
    type  = 2,
    level = 390,
    reqs  = [{opdays, 20}],
    cycle = weekly,
    days  = [2,4,6],
    pre   = 1800,
    time  = [{{21,30,00},{21,50,00}}],
    post  = 0,
    scene = 0,
    msgno = 160001
};
find(12001) -> #cfg_activity{
    id    = 12001,
    name  = "跨服公会战(分配）",
    group = 115,
    type  = 2,
    level = 300,
    reqs  = [{period, divide},{opdays,20},{mod,guild_crosswar}],
    cycle = weekly,
    days  = [],
    pre   = 0,
    time  = [{{4,{00,00,00}},{5,{23,59,59}},{5,{23,59,59}}}],
    post  = 0,
    scene = 81000,
    msgno = 160001
};
find(12002) -> #cfg_activity{
    id    = 12002,
    name  = "跨服公会战（预约）",
    group = 115,
    type  = 2,
    level = 300,
    reqs  = [{period, book},{opdays,20},{mod,guild_crosswar}],
    cycle = weekly,
    days  = [],
    pre   = 0,
    time  = [{{6,{3,00,00}},{7,{3,00,00}},{7,{3,00,00}}}],
    post  = 0,
    scene = 81000,
    msgno = 160001
};
find(12003) -> #cfg_activity{
    id    = 12003,
    name  = "跨服公会战（对决）",
    group = 115,
    type  = 2,
    level = 300,
    reqs  = [{period, battle},{opdays,20},{mod,guild_crosswar}],
    cycle = weekly,
    days  = [7],
    pre   = 0,
    time  = [{{20,00,00},{20,15,00}},{{20,16,00},{20,31,00}}],
    post  = 0,
    scene = 81000,
    msgno = 0
};
find(20000) -> #cfg_activity{
    id    = 20000,
    name  = "跨服分组",
    group = 200,
    type  = 3,
    level = 0,
    reqs  = [{cross,1024008}],
    cycle = monthly,
    days  = [1],
    pre   = 600,
    time  = [{{00,00,00},{01,00,00}}],
    post  = 0,
    scene = 30391,
    msgno = 0
};
find(12010) -> #cfg_activity{
    id    = 12010,
    name  = "时空裂缝",
    group = 116,
    type  = 2,
    level = 410,
    reqs  = [],
    cycle = daily,
    days  = [],
    pre   = 0,
    time  = [{0,0,0}, {1,0,0}, {9,0,0}, {11,0,0}, {13,0,0}, {15,0,0}, {17,0,0}, {19,0,0}, {21,0,0}, {23,0,0}],
    post  = 0,
    scene = 20901,
    msgno = 160001
};
find(12011) -> #cfg_activity{
    id    = 12011,
    name  = "时空裂缝2层",
    group = 116,
    type  = 2,
    level = 490,
    reqs  = [],
    cycle = daily,
    days  = [],
    pre   = 0,
    time  = [{0,0,0}, {1,0,0}, {9,0,0}, {11,0,0}, {13,0,0}, {15,0,0}, {17,0,0}, {19,0,0}, {21,0,0}, {23,0,0}],
    post  = 0,
    scene = 20902,
    msgno = 0
};
find(_) -> undefined.

all(130) -> [10221,10231,10232,10101,10121,10122,10124,10211];
all(115) -> [10112,11011,11019,11014,11016,10111,11012,11013,11017,11018,11015];
all(140) -> [10125,10126,10201,10202,10203,10204];
all(213) -> [11101,11102];
all(75) -> [11111];
all(300) -> [12003,11121,11123,11122,12001,12002];
all(390) -> [12000];
all(0) -> [20000];
all(410) -> [12010];
all(490) -> [12011];
all(_) -> [].

all() -> [11102,12002,10101,10111,10125,11018,20000,10202,10232,11013,12003,10204,10211,11014,11121,10122,11123,12001,12011,11101,11111,12000,10201,10221,11019,11015,10112,10231,11012,11016,11122,12010,10126,10203,11011,11017,10121,10124].

group(101) -> [10101];
group(103) -> [10111,10112];
group(104) -> [10121,10122];
group(107) -> [10124];
group(108) -> [10125,10126];
group(102) -> [10201,10202,10203,10204];
group(105) -> [10211];
group(106) -> [10221];
group(109) -> [10231,10232];
group(110) -> [11011,11012,11013,11014,11015,11016,11017,11018,11019];
group(111) -> [11101,11102];
group(112) -> [11111];
group(113) -> [11121,11122,11123];
group(114) -> [12000];
group(115) -> [12001,12002,12003];
group(200) -> [20000];
group(116) -> [12010,12011];
group(_) -> [].

group(101, 1) -> [10101];
group(103, 1) -> [10111];
group(103, 2) -> [10112];
group(104, 1) -> [10121];
group(104, 2) -> [10122];
group(107, 1) -> [10124];
group(108, 1) -> [10125];
group(108, 2) -> [10126];
group(102, 1) -> [10201,10202,10203,10204];
group(105, 1) -> [10211];
group(106, 1) -> [10221];
group(109, 1) -> [10231];
group(109, 2) -> [10232];
group(110, 1) -> [11011,11012,11013,11017,11018,11019];
group(110, 2) -> [11014,11015,11016];
group(111, 2) -> [11101,11102];
group(112, 1) -> [11111];
group(113, 2) -> [11121,11122,11123];
group(114, 2) -> [12000];
group(115, 2) -> [12001,12002,12003];
group(200, 3) -> [20000];
group(116, 2) -> [12010,12011];
group(_, _) -> [].
