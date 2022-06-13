% Automatically generated, do not edit
-module(cfg_scene).

-compile([export_all]).
-compile(nowarn_export_all).

-include("scene.hrl").

find(11001) -> #cfg_scene{
	id      = 11001,
	name    = "瓦伦萨",
	kind    = 1,
	type    = 2,
	stype   = 0,
	reqs    = [{level,1}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = false,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(11002) -> #cfg_scene{
	id      = 11002,
	name    = "墨里亚",
	kind    = 1,
	type    = 2,
	stype   = 0,
	reqs    = [{level,25}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = false,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(11003) -> #cfg_scene{
	id      = 11003,
	name    = "泰坦之城",
	kind    = 1,
	type    = 1,
	stype   = 0,
	reqs    = [{level,50}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = false,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(11004) -> #cfg_scene{
	id      = 11004,
	name    = "塔罗斯",
	kind    = 1,
	type    = 2,
	stype   = 0,
	reqs    = [{level,50}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = false,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(11005) -> #cfg_scene{
	id      = 11005,
	name    = "米德加尔特雪原",
	kind    = 1,
	type    = 2,
	stype   = 0,
	reqs    = [{level,100}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = false,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(11006) -> #cfg_scene{
	id      = 11006,
	name    = "遥远荒野",
	kind    = 1,
	type    = 2,
	stype   = 0,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = false,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(11007) -> #cfg_scene{
	id      = 11007,
	name    = "珊瑚海滩",
	kind    = 1,
	type    = 2,
	stype   = 0,
	reqs    = [{level,150}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = false,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(11008) -> #cfg_scene{
	id      = 11008,
	name    = "海底神殿",
	kind    = 1,
	type    = 2,
	stype   = 0,
	reqs    = [{level,300}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = false,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(11009) -> #cfg_scene{
	id      = 11009,
	name    = "天空之城",
	kind    = 1,
	type    = 2,
	stype   = 0,
	reqs    = [{level,350}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = false,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(11010) -> #cfg_scene{
	id      = 11010,
	name    = "神之遗迹",
	kind    = 1,
	type    = 2,
	stype   = 0,
	reqs    = [{level,250}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = false,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(11011) -> #cfg_scene{
	id      = 11011,
	name    = "精灵城堡",
	kind    = 1,
	type    = 2,
	stype   = 0,
	reqs    = [{level,400}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = false,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(11012) -> #cfg_scene{
	id      = 11012,
	name    = "神秘森林",
	kind    = 1,
	type    = 2,
	stype   = 0,
	reqs    = [{level,500}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = false,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(11013) -> #cfg_scene{
	id      = 11013,
	name    = "魔法机械城",
	kind    = 1,
	type    = 2,
	stype   = 0,
	reqs    = [{level,600}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = false,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(11314) -> #cfg_scene{
	id      = 11314,
	name    = "结婚场景",
	kind    = 1,
	type    = 5,
	stype   = 505,
	reqs    = [{level,1}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [0],
	mount   = true
};
find(20000) -> #cfg_scene{
	id      = 20000,
	name    = "无疲劳层",
	kind    = 1,
	type    = 4,
	stype   = 406,
	reqs    = [{level,90}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = true
};
find(20001) -> #cfg_scene{
	id      = 20001,
	name    = "地下深渊",
	kind    = 1,
	type    = 4,
	stype   = 401,
	reqs    = [{level,90}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20002) -> #cfg_scene{
	id      = 20002,
	name    = "火山盆地",
	kind    = 1,
	type    = 4,
	stype   = 401,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20003) -> #cfg_scene{
	id      = 20003,
	name    = "巨兽海沟",
	kind    = 1,
	type    = 4,
	stype   = 401,
	reqs    = [{level,240}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20004) -> #cfg_scene{
	id      = 20004,
	name    = "冰雪皇宫",
	kind    = 1,
	type    = 4,
	stype   = 401,
	reqs    = [{level,371}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20005) -> #cfg_scene{
	id      = 20005,
	name    = "冰雪皇宫",
	kind    = 1,
	type    = 4,
	stype   = 401,
	reqs    = [{level,500}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20006) -> #cfg_scene{
	id      = 20006,
	name    = "冰雪皇宫",
	kind    = 1,
	type    = 4,
	stype   = 401,
	reqs    = [{level,600}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20007) -> #cfg_scene{
	id      = 20007,
	name    = "冰雪皇宫",
	kind    = 1,
	type    = 4,
	stype   = 401,
	reqs    = [{level,700}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20100) -> #cfg_scene{
	id      = 20100,
	name    = "首领1层",
	kind    = 1,
	type    = 4,
	stype   = 402,
	reqs    = [{level,160}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [5,6],
	mount   = true
};
find(20101) -> #cfg_scene{
	id      = 20101,
	name    = "首领2层",
	kind    = 1,
	type    = 4,
	stype   = 402,
	reqs    = [{level,160}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [5,6],
	mount   = true
};
find(20102) -> #cfg_scene{
	id      = 20102,
	name    = "首领3层",
	kind    = 1,
	type    = 4,
	stype   = 402,
	reqs    = [{level,160}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [5,6],
	mount   = true
};
find(20103) -> #cfg_scene{
	id      = 20103,
	name    = "首领4层",
	kind    = 1,
	type    = 4,
	stype   = 402,
	reqs    = [{level,160}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [5,6],
	mount   = true
};
find(20104) -> #cfg_scene{
	id      = 20104,
	name    = "首领5层",
	kind    = 1,
	type    = 4,
	stype   = 402,
	reqs    = [{level,160}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [5,6],
	mount   = true
};
find(20105) -> #cfg_scene{
	id      = 20105,
	name    = "首领6层",
	kind    = 1,
	type    = 4,
	stype   = 402,
	reqs    = [{level,160}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [5,6],
	mount   = true
};
find(20106) -> #cfg_scene{
	id      = 20106,
	name    = "首领7层",
	kind    = 1,
	type    = 4,
	stype   = 402,
	reqs    = [{level,160}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [5,6],
	mount   = true
};
find(20201) -> #cfg_scene{
	id      = 20201,
	name    = "古代遗迹1层",
	kind    = 1,
	type    = 4,
	stype   = 403,
	reqs    = [{level,270}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20202) -> #cfg_scene{
	id      = 20202,
	name    = "古代遗迹2层",
	kind    = 1,
	type    = 4,
	stype   = 403,
	reqs    = [{level,371}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20203) -> #cfg_scene{
	id      = 20203,
	name    = "古代遗迹3层",
	kind    = 1,
	type    = 4,
	stype   = 403,
	reqs    = [{level,450}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20301) -> #cfg_scene{
	id      = 20301,
	name    = "魔兽城堡1层",
	kind    = 1,
	type    = 4,
	stype   = 404,
	reqs    = [{level,240},{opdays,4}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20302) -> #cfg_scene{
	id      = 20302,
	name    = "魔兽城堡2层",
	kind    = 1,
	type    = 4,
	stype   = 404,
	reqs    = [{level,385},{opdays,4}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20501) -> #cfg_scene{
	id      = 20501,
	name    = "幻之岛单服",
	kind    = 1,
	type    = 4,
	stype   = 405,
	reqs    = [{level,350}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20511) -> #cfg_scene{
	id      = 20511,
	name    = "幻之岛跨服1层",
	kind    = 2,
	type    = 4,
	stype   = 405,
	reqs    = [{level,371}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20512) -> #cfg_scene{
	id      = 20512,
	name    = "幻之岛跨服2层",
	kind    = 2,
	type    = 4,
	stype   = 405,
	reqs    = [{level,450}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20513) -> #cfg_scene{
	id      = 20513,
	name    = "幻之岛跨服3层",
	kind    = 2,
	type    = 4,
	stype   = 405,
	reqs    = [{level,520}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20701) -> #cfg_scene{
	id      = 20701,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20702) -> #cfg_scene{
	id      = 20702,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,220}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20711) -> #cfg_scene{
	id      = 20711,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,240}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20712) -> #cfg_scene{
	id      = 20712,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,260}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20721) -> #cfg_scene{
	id      = 20721,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,280}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20722) -> #cfg_scene{
	id      = 20722,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,300}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20731) -> #cfg_scene{
	id      = 20731,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,320}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20732) -> #cfg_scene{
	id      = 20732,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,340}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20733) -> #cfg_scene{
	id      = 20733,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,360}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20734) -> #cfg_scene{
	id      = 20734,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,380}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20735) -> #cfg_scene{
	id      = 20735,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,400}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20736) -> #cfg_scene{
	id      = 20736,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,420}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20737) -> #cfg_scene{
	id      = 20737,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,440}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20738) -> #cfg_scene{
	id      = 20738,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,460}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20739) -> #cfg_scene{
	id      = 20739,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,480}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20740) -> #cfg_scene{
	id      = 20740,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,500}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20741) -> #cfg_scene{
	id      = 20741,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,550}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20742) -> #cfg_scene{
	id      = 20742,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,600}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20743) -> #cfg_scene{
	id      = 20743,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,650}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20744) -> #cfg_scene{
	id      = 20744,
	name    = "跨服首领",
	kind    = 2,
	type    = 5,
	stype   = 510,
	reqs    = [{level,700}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(20801) -> #cfg_scene{
	id      = 20801,
	name    = "青铜驻地",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(20802) -> #cfg_scene{
	id      = 20802,
	name    = "青铜驻地",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(20803) -> #cfg_scene{
	id      = 20803,
	name    = "青铜驻地",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(20804) -> #cfg_scene{
	id      = 20804,
	name    = "青铜驻地",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(20805) -> #cfg_scene{
	id      = 20805,
	name    = "青铜驻地",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(20806) -> #cfg_scene{
	id      = 20806,
	name    = "青铜驻地",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(20807) -> #cfg_scene{
	id      = 20807,
	name    = "青铜驻地",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(20808) -> #cfg_scene{
	id      = 20808,
	name    = "青铜驻地",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(20811) -> #cfg_scene{
	id      = 20811,
	name    = "白银边城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20812) -> #cfg_scene{
	id      = 20812,
	name    = "白银边城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20813) -> #cfg_scene{
	id      = 20813,
	name    = "白银边城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20814) -> #cfg_scene{
	id      = 20814,
	name    = "白银边城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20815) -> #cfg_scene{
	id      = 20815,
	name    = "白银边城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20816) -> #cfg_scene{
	id      = 20816,
	name    = "白银边城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20817) -> #cfg_scene{
	id      = 20817,
	name    = "白银边城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20818) -> #cfg_scene{
	id      = 20818,
	name    = "白银边城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20821) -> #cfg_scene{
	id      = 20821,
	name    = "黄金都城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20822) -> #cfg_scene{
	id      = 20822,
	name    = "黄金都城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20823) -> #cfg_scene{
	id      = 20823,
	name    = "黄金都城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20824) -> #cfg_scene{
	id      = 20824,
	name    = "黄金都城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20825) -> #cfg_scene{
	id      = 20825,
	name    = "黄金都城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20826) -> #cfg_scene{
	id      = 20826,
	name    = "黄金都城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20827) -> #cfg_scene{
	id      = 20827,
	name    = "黄金都城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20828) -> #cfg_scene{
	id      = 20828,
	name    = "黄金都城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20831) -> #cfg_scene{
	id      = 20831,
	name    = "白银边城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20832) -> #cfg_scene{
	id      = 20832,
	name    = "白银边城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20833) -> #cfg_scene{
	id      = 20833,
	name    = "白银边城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20834) -> #cfg_scene{
	id      = 20834,
	name    = "白银边城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20835) -> #cfg_scene{
	id      = 20835,
	name    = "白银边城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20836) -> #cfg_scene{
	id      = 20836,
	name    = "白银边城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20837) -> #cfg_scene{
	id      = 20837,
	name    = "白银边城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20838) -> #cfg_scene{
	id      = 20838,
	name    = "白银边城",
	kind    = 2,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(20851) -> #cfg_scene{
	id      = 20851,
	name    = "黄金公会领地",
	kind    = 1,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20852) -> #cfg_scene{
	id      = 20852,
	name    = "白银公会领地",
	kind    = 1,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20853) -> #cfg_scene{
	id      = 20853,
	name    = "青铜公会领地",
	kind    = 1,
	type    = 5,
	stype   = 511,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(30001) -> #cfg_scene{
	id      = 30001,
	name    = "魔法塔",
	kind    = 1,
	type    = 3,
	stype   = 303,
	reqs    = [],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(30002) -> #cfg_scene{
	id      = 30002,
	name    = "魔法塔（暂时没用）",
	kind    = 1,
	type    = 3,
	stype   = 307,
	reqs    = [{level,150},{vip,4}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(30101) -> #cfg_scene{
	id      = 30101,
	name    = "经验副本",
	kind    = 1,
	type    = 3,
	stype   = 301,
	reqs    = [{level,105}],
	buffs   = [{131000001,[{worldlv,0,9999},{level,160}]},{131000002,[{worldlv,-10,-1},{level,160}]},{131000003,[{worldlv,-20,-11},{level,160}]},{131000004,[{worldlv,-30,-21},{level,160}]},{131000005,[{worldlv,-40,-31},{level,160}]},{131000006,[{worldlv,-50,-41},{level,160}]},{131000007,[{worldlv,-100,-51},{level,160}]},{131000008,[{worldlv,-150,-101},{level,160}]},{131000009,[{worldlv,-200,-151},{level,160}]},{131000010,[{worldlv,-9999,-201},{level,160}]}],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(30102) -> #cfg_scene{
	id      = 30102,
	name    = "贪婪洞窟",
	kind    = 1,
	type    = 3,
	stype   = 302,
	reqs    = [{level,115}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(30103) -> #cfg_scene{
	id      = 30103,
	name    = "情侣副本",
	kind    = 1,
	type    = 3,
	stype   = 313,
	reqs    = [{level,213}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [0],
	mount   = false
};
find(30201) -> #cfg_scene{
	id      = 30201,
	name    = "斗士之路",
	kind    = 1,
	type    = 3,
	stype   = 304,
	reqs    = [{level,100}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(30301) -> #cfg_scene{
	id      = 30301,
	name    = "公会争霸",
	kind    = 1,
	type    = 5,
	stype   = 501,
	reqs    = [{level,140}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 6,
	pkallow = [6],
	mount   = true
};
find(30311) -> #cfg_scene{
	id      = 30311,
	name    = "乱斗战场",
	kind    = 1,
	type    = 5,
	stype   = 502,
	reqs    = [{level,115}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 6,
	pkallow = [6],
	mount   = false
};
find(30312) -> #cfg_scene{
	id      = 30312,
	name    = "跨服乱斗战场",
	kind    = 2,
	type    = 5,
	stype   = 502,
	reqs    = [{level,115}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 6,
	pkallow = [6],
	mount   = false
};
find(30341) -> #cfg_scene{
	id      = 30341,
	name    = "甜美糖果屋",
	kind    = 1,
	type    = 5,
	stype   = 503,
	reqs    = [{level,130}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(30342) -> #cfg_scene{
	id      = 30342,
	name    = "跨服糖果屋",
	kind    = 2,
	type    = 5,
	stype   = 503,
	reqs    = [{level,130}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(30351) -> #cfg_scene{
	id      = 30351,
	name    = "个人首领",
	kind    = 1,
	type    = 3,
	stype   = 307,
	reqs    = [{level,165}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(30361) -> #cfg_scene{
	id      = 30361,
	name    = "公会盛会",
	kind    = 1,
	type    = 5,
	stype   = 504,
	reqs    = [{level,130}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = true
};
find(30371) -> #cfg_scene{
	id      = 30371,
	name    = "竞技场",
	kind    = 1,
	type    = 3,
	stype   = 309,
	reqs    = [{level,110}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = true,
	pkmode  = 6,
	pkallow = [6],
	mount   = false
};
find(30372) -> #cfg_scene{
	id      = 30372,
	name    = "巅峰1v1",
	kind    = 1,
	type    = 5,
	stype   = 506,
	reqs    = [{level,140}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 6,
	pkallow = [6],
	mount   = false
};
find(30373) -> #cfg_scene{
	id      = 30373,
	name    = "跨服巅峰1v1",
	kind    = 2,
	type    = 5,
	stype   = 506,
	reqs    = [{level,140}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 6,
	pkallow = [6],
	mount   = false
};
find(30381) -> #cfg_scene{
	id      = 30381,
	name    = "守卫公会",
	kind    = 1,
	type    = 3,
	stype   = 311,
	reqs    = [{level,130},{act,10221}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [5],
	mount   = true
};
find(30391) -> #cfg_scene{
	id      = 30391,
	name    = "勇者圣坛",
	kind    = 1,
	type    = 5,
	stype   = 507,
	reqs    = [{level,130}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 6,
	pkallow = [6],
	mount   = false
};
find(30392) -> #cfg_scene{
	id      = 30392,
	name    = "勇者圣坛顶层",
	kind    = 1,
	type    = 5,
	stype   = 507,
	reqs    = [{level,130}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 6,
	pkallow = [6],
	mount   = false
};
find(30393) -> #cfg_scene{
	id      = 30393,
	name    = "跨服勇者圣坛",
	kind    = 2,
	type    = 5,
	stype   = 507,
	reqs    = [{level,130}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 6,
	pkallow = [6],
	mount   = false
};
find(30394) -> #cfg_scene{
	id      = 30394,
	name    = "跨服勇者圣坛顶层",
	kind    = 2,
	type    = 5,
	stype   = 507,
	reqs    = [{level,130}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 6,
	pkallow = [6],
	mount   = false
};
find(30401) -> #cfg_scene{
	id      = 30401,
	name    = "龙",
	kind    = 1,
	type    = 3,
	stype   = 308,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(30402) -> #cfg_scene{
	id      = 30402,
	name    = "风",
	kind    = 1,
	type    = 3,
	stype   = 308,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(30403) -> #cfg_scene{
	id      = 30403,
	name    = "火",
	kind    = 1,
	type    = 3,
	stype   = 308,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(30404) -> #cfg_scene{
	id      = 30404,
	name    = "山",
	kind    = 1,
	type    = 3,
	stype   = 308,
	reqs    = [{level,200}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(30410) -> #cfg_scene{
	id      = 30410,
	name    = "钻石擂台",
	kind    = 1,
	type    = 5,
	stype   = 508,
	reqs    = [{level,100}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(30411) -> #cfg_scene{
	id      = 30411,
	name    = "钻石擂台",
	kind    = 1,
	type    = 5,
	stype   = 509,
	reqs    = [{level,100}],
	buffs   = [304100004,304100008],
	safe    = false,
	tele    = false,
	jump    = false,
	pkmode  = 6,
	pkallow = [6],
	mount   = false
};
find(30412) -> #cfg_scene{
	id      = 30412,
	name    = "钻石擂台",
	kind    = 2,
	type    = 5,
	stype   = 508,
	reqs    = [{level,100}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(30413) -> #cfg_scene{
	id      = 30413,
	name    = "钻石擂台",
	kind    = 2,
	type    = 5,
	stype   = 509,
	reqs    = [{level,100}],
	buffs   = [304100004,304100008],
	safe    = false,
	tele    = false,
	jump    = false,
	pkmode  = 6,
	pkallow = [6],
	mount   = false
};
find(30501) -> #cfg_scene{
	id      = 30501,
	name    = "圣痕秘境",
	kind    = 1,
	type    = 3,
	stype   = 315,
	reqs    = [{level,305}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(30601) -> #cfg_scene{
	id      = 30601,
	name    = "神灵之路",
	kind    = 1,
	type    = 3,
	stype   = 317,
	reqs    = [{level,230}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(60001) -> #cfg_scene{
	id      = 60001,
	name    = "蒸汽时代",
	kind    = 1,
	type    = 3,
	stype   = 306,
	reqs    = [],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(60002) -> #cfg_scene{
	id      = 60002,
	name    = "沙漠中心",
	kind    = 1,
	type    = 3,
	stype   = 306,
	reqs    = [],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(60003) -> #cfg_scene{
	id      = 60003,
	name    = "地狱烈焰",
	kind    = 1,
	type    = 3,
	stype   = 306,
	reqs    = [],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(60004) -> #cfg_scene{
	id      = 60004,
	name    = "捕捉幻灵",
	kind    = 1,
	type    = 3,
	stype   = 305,
	reqs    = [],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(60005) -> #cfg_scene{
	id      = 60005,
	name    = "击败恶魔领主",
	kind    = 1,
	type    = 3,
	stype   = 320,
	reqs    = [],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(60006) -> #cfg_scene{
	id      = 60006,
	name    = "世界BOSS",
	kind    = 1,
	type    = 3,
	stype   = 312,
	reqs    = [],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = true
};
find(60007) -> #cfg_scene{
	id      = 60007,
	name    = "霜毒蜘蛛来袭",
	kind    = 1,
	type    = 3,
	stype   = 305,
	reqs    = [],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(60008) -> #cfg_scene{
	id      = 60008,
	name    = "偷蛋贼来袭",
	kind    = 1,
	type    = 3,
	stype   = 305,
	reqs    = [],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(60009) -> #cfg_scene{
	id      = 60009,
	name    = "暴走的齿轮",
	kind    = 1,
	type    = 3,
	stype   = 318,
	reqs    = [],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(60010) -> #cfg_scene{
	id      = 60010,
	name    = "终焉之龙",
	kind    = 1,
	type    = 3,
	stype   = 305,
	reqs    = [],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(60011) -> #cfg_scene{
	id      = 60011,
	name    = "决战之时",
	kind    = 1,
	type    = 3,
	stype   = 305,
	reqs    = [],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(70001) -> #cfg_scene{
	id      = 70001,
	name    = "觉醒副本",
	kind    = 1,
	type    = 3,
	stype   = 305,
	reqs    = [],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(80001) -> #cfg_scene{
	id      = 80001,
	name    = "魔兽攻城",
	kind    = 1,
	type    = 3,
	stype   = 310,
	reqs    = [],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(90001) -> #cfg_scene{
	id      = 90001,
	name    = "机甲竞速",
	kind    = 1,
	type    = 3,
	stype   = 319,
	reqs    = [{level,75}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(80101) -> #cfg_scene{
	id      = 80101,
	name    = "暗星之间",
	kind    = 2,
	type    = 5,
	stype   = 512,
	reqs    = [{level,390}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(80102) -> #cfg_scene{
	id      = 80102,
	name    = "璨星之里",
	kind    = 2,
	type    = 5,
	stype   = 512,
	reqs    = [{level,390}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(80103) -> #cfg_scene{
	id      = 80103,
	name    = "珀加索斯",
	kind    = 2,
	type    = 5,
	stype   = 512,
	reqs    = [{score,100},{level,390}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 9,
	pkallow = [1,5,6,9,10],
	mount   = true
};
find(81000) -> #cfg_scene{
	id      = 81000,
	name    = "跨服公会战",
	kind    = 2,
	type    = 5,
	stype   = 513,
	reqs    = [{level,300}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [5],
	mount   = true
};
find(150601) -> #cfg_scene{
	id      = 150601,
	name    = "神灵之塔",
	kind    = 1,
	type    = 3,
	stype   = 314,
	reqs    = [{yyact,150601}],
	buffs   = [],
	safe    = true,
	tele    = false,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(150701) -> #cfg_scene{
	id      = 150701,
	name    = "机械试练",
	kind    = 1,
	type    = 3,
	stype   = 316,
	reqs    = [{level,90},{yyact,[170101,170100]}],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = true,
	pkmode  = 1,
	pkallow = [1],
	mount   = false
};
find(99999) -> #cfg_scene{
	id      = 99999,
	name    = "uwa测试地图",
	kind    = 1,
	type    = 2,
	stype   = 0,
	reqs    = [],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = false,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(99998) -> #cfg_scene{
	id      = 99998,
	name    = "uwa测试地图",
	kind    = 1,
	type    = 2,
	stype   = 0,
	reqs    = [],
	buffs   = [],
	safe    = true,
	tele    = true,
	jump    = false,
	pkmode  = 1,
	pkallow = [1,5,6],
	mount   = true
};
find(20901) -> #cfg_scene{
	id      = 20901,
	name    = "时空裂缝1层",
	kind    = 2,
	type    = 4,
	stype   = 409,
	reqs    = [{level,410}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(20902) -> #cfg_scene{
	id      = 20902,
	name    = "时空裂缝2层",
	kind    = 2,
	type    = 4,
	stype   = 409,
	reqs    = [{level,500}],
	buffs   = [],
	safe    = false,
	tele    = false,
	jump    = true,
	pkmode  = 5,
	pkallow = [1,5,6],
	mount   = true
};
find(_) -> undefined.

line(11001) -> #cfg_line{
	id   = 11001,
	soft = 50,
	hard = 300,
	max  = 80,
	keep = false
};
line(11002) -> #cfg_line{
	id   = 11002,
	soft = 50,
	hard = 300,
	max  = 80,
	keep = false
};
line(11003) -> #cfg_line{
	id   = 11003,
	soft = 50,
	hard = 300,
	max  = 80,
	keep = false
};
line(11004) -> #cfg_line{
	id   = 11004,
	soft = 50,
	hard = 300,
	max  = 80,
	keep = false
};
line(11005) -> #cfg_line{
	id   = 11005,
	soft = 50,
	hard = 300,
	max  = 80,
	keep = false
};
line(11006) -> #cfg_line{
	id   = 11006,
	soft = 50,
	hard = 300,
	max  = 80,
	keep = false
};
line(11007) -> #cfg_line{
	id   = 11007,
	soft = 50,
	hard = 300,
	max  = 80,
	keep = false
};
line(11008) -> #cfg_line{
	id   = 11008,
	soft = 50,
	hard = 300,
	max  = 80,
	keep = false
};
line(11009) -> #cfg_line{
	id   = 11009,
	soft = 50,
	hard = 300,
	max  = 80,
	keep = false
};
line(11010) -> #cfg_line{
	id   = 11010,
	soft = 50,
	hard = 300,
	max  = 80,
	keep = false
};
line(11011) -> #cfg_line{
	id   = 11011,
	soft = 50,
	hard = 300,
	max  = 80,
	keep = false
};
line(11012) -> #cfg_line{
	id   = 11012,
	soft = 50,
	hard = 300,
	max  = 80,
	keep = false
};
line(11013) -> #cfg_line{
	id   = 11013,
	soft = 50,
	hard = 300,
	max  = 80,
	keep = false
};
line(11314) -> #cfg_line{
	id   = 11314,
	soft = 100,
	hard = 100,
	max  = 0,
	keep = false
};
line(20000) -> #cfg_line{
	id   = 20000,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20001) -> #cfg_line{
	id   = 20001,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20002) -> #cfg_line{
	id   = 20002,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20003) -> #cfg_line{
	id   = 20003,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20004) -> #cfg_line{
	id   = 20004,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20005) -> #cfg_line{
	id   = 20005,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20006) -> #cfg_line{
	id   = 20006,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20007) -> #cfg_line{
	id   = 20007,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20100) -> #cfg_line{
	id   = 20100,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20101) -> #cfg_line{
	id   = 20101,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20102) -> #cfg_line{
	id   = 20102,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20103) -> #cfg_line{
	id   = 20103,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20104) -> #cfg_line{
	id   = 20104,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20105) -> #cfg_line{
	id   = 20105,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20106) -> #cfg_line{
	id   = 20106,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20201) -> #cfg_line{
	id   = 20201,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20202) -> #cfg_line{
	id   = 20202,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20203) -> #cfg_line{
	id   = 20203,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20301) -> #cfg_line{
	id   = 20301,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20302) -> #cfg_line{
	id   = 20302,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20501) -> #cfg_line{
	id   = 20501,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20511) -> #cfg_line{
	id   = 20511,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20512) -> #cfg_line{
	id   = 20512,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20513) -> #cfg_line{
	id   = 20513,
	soft = 300,
	hard = 300,
	max  = 1,
	keep = false
};
line(20701) -> #cfg_line{
	id   = 20701,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20702) -> #cfg_line{
	id   = 20702,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20711) -> #cfg_line{
	id   = 20711,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20712) -> #cfg_line{
	id   = 20712,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20721) -> #cfg_line{
	id   = 20721,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20722) -> #cfg_line{
	id   = 20722,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20731) -> #cfg_line{
	id   = 20731,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20732) -> #cfg_line{
	id   = 20732,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20733) -> #cfg_line{
	id   = 20733,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20734) -> #cfg_line{
	id   = 20734,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20735) -> #cfg_line{
	id   = 20735,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20736) -> #cfg_line{
	id   = 20736,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20737) -> #cfg_line{
	id   = 20737,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20738) -> #cfg_line{
	id   = 20738,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20739) -> #cfg_line{
	id   = 20739,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20740) -> #cfg_line{
	id   = 20740,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20741) -> #cfg_line{
	id   = 20741,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20742) -> #cfg_line{
	id   = 20742,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20743) -> #cfg_line{
	id   = 20743,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20744) -> #cfg_line{
	id   = 20744,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20801) -> #cfg_line{
	id   = 20801,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20802) -> #cfg_line{
	id   = 20802,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20803) -> #cfg_line{
	id   = 20803,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20804) -> #cfg_line{
	id   = 20804,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20805) -> #cfg_line{
	id   = 20805,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20806) -> #cfg_line{
	id   = 20806,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20807) -> #cfg_line{
	id   = 20807,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20808) -> #cfg_line{
	id   = 20808,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20811) -> #cfg_line{
	id   = 20811,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20812) -> #cfg_line{
	id   = 20812,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20813) -> #cfg_line{
	id   = 20813,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20814) -> #cfg_line{
	id   = 20814,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20815) -> #cfg_line{
	id   = 20815,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20816) -> #cfg_line{
	id   = 20816,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20817) -> #cfg_line{
	id   = 20817,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20818) -> #cfg_line{
	id   = 20818,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20821) -> #cfg_line{
	id   = 20821,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20822) -> #cfg_line{
	id   = 20822,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20823) -> #cfg_line{
	id   = 20823,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20824) -> #cfg_line{
	id   = 20824,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20825) -> #cfg_line{
	id   = 20825,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20826) -> #cfg_line{
	id   = 20826,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20827) -> #cfg_line{
	id   = 20827,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20828) -> #cfg_line{
	id   = 20828,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20831) -> #cfg_line{
	id   = 20831,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20832) -> #cfg_line{
	id   = 20832,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20833) -> #cfg_line{
	id   = 20833,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20834) -> #cfg_line{
	id   = 20834,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20835) -> #cfg_line{
	id   = 20835,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20836) -> #cfg_line{
	id   = 20836,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20837) -> #cfg_line{
	id   = 20837,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20838) -> #cfg_line{
	id   = 20838,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20851) -> #cfg_line{
	id   = 20851,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20852) -> #cfg_line{
	id   = 20852,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(20853) -> #cfg_line{
	id   = 20853,
	soft = 100,
	hard = 100,
	max  = 1,
	keep = false
};
line(30001) -> #cfg_line{
	id   = 30001,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(30002) -> #cfg_line{
	id   = 30002,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(30101) -> #cfg_line{
	id   = 30101,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(30102) -> #cfg_line{
	id   = 30102,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(30103) -> #cfg_line{
	id   = 30103,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(30201) -> #cfg_line{
	id   = 30201,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(30301) -> #cfg_line{
	id   = 30301,
	soft = 300,
	hard = 300,
	max  = 100,
	keep = false
};
line(30311) -> #cfg_line{
	id   = 30311,
	soft = 20,
	hard = 20,
	max  = 100,
	keep = true
};
line(30312) -> #cfg_line{
	id   = 30312,
	soft = 20,
	hard = 20,
	max  = 100,
	keep = true
};
line(30341) -> #cfg_line{
	id   = 30341,
	soft = 100,
	hard = 100,
	max  = 100,
	keep = true
};
line(30342) -> #cfg_line{
	id   = 30342,
	soft = 100,
	hard = 100,
	max  = 100,
	keep = true
};
line(30351) -> #cfg_line{
	id   = 30351,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(30361) -> #cfg_line{
	id   = 30361,
	soft = 100,
	hard = 100,
	max  = 2,
	keep = false
};
line(30371) -> #cfg_line{
	id   = 30371,
	soft = 100,
	hard = 100,
	max  = 2,
	keep = false
};
line(30372) -> #cfg_line{
	id   = 30372,
	soft = 100,
	hard = 100,
	max  = 2,
	keep = false
};
line(30373) -> #cfg_line{
	id   = 30373,
	soft = 100,
	hard = 100,
	max  = 2,
	keep = false
};
line(30381) -> #cfg_line{
	id   = 30381,
	soft = 100,
	hard = 100,
	max  = 2,
	keep = false
};
line(30391) -> #cfg_line{
	id   = 30391,
	soft = 20,
	hard = 20,
	max  = 100,
	keep = true
};
line(30392) -> #cfg_line{
	id   = 30392,
	soft = 20,
	hard = 20,
	max  = 100,
	keep = true
};
line(30393) -> #cfg_line{
	id   = 30393,
	soft = 20,
	hard = 20,
	max  = 100,
	keep = true
};
line(30394) -> #cfg_line{
	id   = 30394,
	soft = 20,
	hard = 20,
	max  = 100,
	keep = true
};
line(30401) -> #cfg_line{
	id   = 30401,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(30402) -> #cfg_line{
	id   = 30402,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(30403) -> #cfg_line{
	id   = 30403,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(30404) -> #cfg_line{
	id   = 30404,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(30410) -> #cfg_line{
	id   = 30410,
	soft = 32,
	hard = 32,
	max  = 100,
	keep = false
};
line(30411) -> #cfg_line{
	id   = 30411,
	soft = 32,
	hard = 32,
	max  = 100,
	keep = false
};
line(30412) -> #cfg_line{
	id   = 30412,
	soft = 32,
	hard = 32,
	max  = 100,
	keep = false
};
line(30413) -> #cfg_line{
	id   = 30413,
	soft = 32,
	hard = 32,
	max  = 100,
	keep = false
};
line(30501) -> #cfg_line{
	id   = 30501,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(30601) -> #cfg_line{
	id   = 30601,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(60001) -> #cfg_line{
	id   = 60001,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(60002) -> #cfg_line{
	id   = 60002,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(60003) -> #cfg_line{
	id   = 60003,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(60004) -> #cfg_line{
	id   = 60004,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(60005) -> #cfg_line{
	id   = 60005,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(60006) -> #cfg_line{
	id   = 60006,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(60007) -> #cfg_line{
	id   = 60007,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(60008) -> #cfg_line{
	id   = 60008,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(60009) -> #cfg_line{
	id   = 60009,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(60010) -> #cfg_line{
	id   = 60010,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(60011) -> #cfg_line{
	id   = 60011,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(70001) -> #cfg_line{
	id   = 70001,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(80001) -> #cfg_line{
	id   = 80001,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(90001) -> #cfg_line{
	id   = 90001,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(80101) -> #cfg_line{
	id   = 80101,
	soft = 800,
	hard = 800,
	max  = 1,
	keep = false
};
line(80102) -> #cfg_line{
	id   = 80102,
	soft = 800,
	hard = 800,
	max  = 1,
	keep = false
};
line(80103) -> #cfg_line{
	id   = 80103,
	soft = 800,
	hard = 800,
	max  = 1,
	keep = false
};
line(81000) -> #cfg_line{
	id   = 81000,
	soft = 800,
	hard = 800,
	max  = 1,
	keep = false
};
line(150601) -> #cfg_line{
	id   = 150601,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(150701) -> #cfg_line{
	id   = 150701,
	soft = 40,
	hard = 40,
	max  = 80,
	keep = false
};
line(99999) -> #cfg_line{
	id   = 99999,
	soft = 50,
	hard = 300,
	max  = 80,
	keep = false
};
line(99998) -> #cfg_line{
	id   = 99998,
	soft = 50,
	hard = 300,
	max  = 80,
	keep = false
};
line(20901) -> #cfg_line{
	id   = 20901,
	soft = 1000,
	hard = 1000,
	max  = 1,
	keep = false
};
line(20902) -> #cfg_line{
	id   = 20902,
	soft = 1000,
	hard = 1000,
	max  = 1,
	keep = false
};
line(_) -> undefined.

cost(11001) -> #cfg_scene_cost{
	id    = 11001,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(11002) -> #cfg_scene_cost{
	id    = 11002,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(11003) -> #cfg_scene_cost{
	id    = 11003,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(11004) -> #cfg_scene_cost{
	id    = 11004,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(11005) -> #cfg_scene_cost{
	id    = 11005,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(11006) -> #cfg_scene_cost{
	id    = 11006,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(11007) -> #cfg_scene_cost{
	id    = 11007,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(11008) -> #cfg_scene_cost{
	id    = 11008,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(11009) -> #cfg_scene_cost{
	id    = 11009,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(11010) -> #cfg_scene_cost{
	id    = 11010,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(11011) -> #cfg_scene_cost{
	id    = 11011,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(11012) -> #cfg_scene_cost{
	id    = 11012,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(11013) -> #cfg_scene_cost{
	id    = 11013,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(11314) -> #cfg_scene_cost{
	id    = 11314,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20000) -> #cfg_scene_cost{
	id    = 20000,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20001) -> #cfg_scene_cost{
	id    = 20001,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20002) -> #cfg_scene_cost{
	id    = 20002,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20003) -> #cfg_scene_cost{
	id    = 20003,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20004) -> #cfg_scene_cost{
	id    = 20004,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20005) -> #cfg_scene_cost{
	id    = 20005,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20006) -> #cfg_scene_cost{
	id    = 20006,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20007) -> #cfg_scene_cost{
	id    = 20007,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20100) -> #cfg_scene_cost{
	id    = 20100,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20101) -> #cfg_scene_cost{
	id    = 20101,
	type  = 0,
	cost  = [],
	free  = [],
	force = [{90010004,5000}]
};
cost(20102) -> #cfg_scene_cost{
	id    = 20102,
	type  = 0,
	cost  = [],
	free  = [],
	force = [{90010004,5000}]
};
cost(20103) -> #cfg_scene_cost{
	id    = 20103,
	type  = 0,
	cost  = [],
	free  = [],
	force = [{90010004,10000}]
};
cost(20104) -> #cfg_scene_cost{
	id    = 20104,
	type  = 0,
	cost  = [],
	free  = [],
	force = [{90010004,10000}]
};
cost(20105) -> #cfg_scene_cost{
	id    = 20105,
	type  = 0,
	cost  = [],
	free  = [],
	force = [{90010004,15000}]
};
cost(20106) -> #cfg_scene_cost{
	id    = 20106,
	type  = 0,
	cost  = [],
	free  = [],
	force = [{90010004,15000}]
};
cost(20201) -> #cfg_scene_cost{
	id    = 20201,
	type  = 1,
	cost  = [{1,1,[{10803,1}]},{2,2,[{10803,2}]},{3,3,[{10803,3}]},{4,4,[{10803,4}]},{5,5,[{10803,5}]},{6,6,[{10803,6}]},{7,7,[{10803,7}]},{8,8,[{10803,8}]},{9,99,[{10803,9}]}],
	free  = [],
	force = []
};
cost(20202) -> #cfg_scene_cost{
	id    = 20202,
	type  = 1,
	cost  = [{1,1,[{10803,1}]},{2,2,[{10803,2}]},{3,3,[{10803,3}]},{4,4,[{10803,4}]},{5,5,[{10803,5}]},{6,6,[{10803,6}]},{7,7,[{10803,7}]},{8,8,[{10803,8}]},{9,99,[{10803,9}]}],
	free  = [],
	force = []
};
cost(20203) -> #cfg_scene_cost{
	id    = 20203,
	type  = 1,
	cost  = [{1,1,[{10803,1}]},{2,2,[{10803,2}]},{3,3,[{10803,3}]},{4,4,[{10803,4}]},{5,5,[{10803,5}]},{6,6,[{10803,6}]},{7,7,[{10803,7}]},{8,8,[{10803,8}]},{9,99,[{10803,9}]}],
	free  = [],
	force = []
};
cost(20301) -> #cfg_scene_cost{
	id    = 20301,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20302) -> #cfg_scene_cost{
	id    = 20302,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20501) -> #cfg_scene_cost{
	id    = 20501,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20511) -> #cfg_scene_cost{
	id    = 20511,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20512) -> #cfg_scene_cost{
	id    = 20512,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20513) -> #cfg_scene_cost{
	id    = 20513,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20701) -> #cfg_scene_cost{
	id    = 20701,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20702) -> #cfg_scene_cost{
	id    = 20702,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20711) -> #cfg_scene_cost{
	id    = 20711,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20712) -> #cfg_scene_cost{
	id    = 20712,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20721) -> #cfg_scene_cost{
	id    = 20721,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20722) -> #cfg_scene_cost{
	id    = 20722,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20731) -> #cfg_scene_cost{
	id    = 20731,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20732) -> #cfg_scene_cost{
	id    = 20732,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20733) -> #cfg_scene_cost{
	id    = 20733,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20734) -> #cfg_scene_cost{
	id    = 20734,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20735) -> #cfg_scene_cost{
	id    = 20735,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20736) -> #cfg_scene_cost{
	id    = 20736,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20737) -> #cfg_scene_cost{
	id    = 20737,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20738) -> #cfg_scene_cost{
	id    = 20738,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20739) -> #cfg_scene_cost{
	id    = 20739,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20740) -> #cfg_scene_cost{
	id    = 20740,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20741) -> #cfg_scene_cost{
	id    = 20741,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20742) -> #cfg_scene_cost{
	id    = 20742,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20743) -> #cfg_scene_cost{
	id    = 20743,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20744) -> #cfg_scene_cost{
	id    = 20744,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20801) -> #cfg_scene_cost{
	id    = 20801,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20802) -> #cfg_scene_cost{
	id    = 20802,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20803) -> #cfg_scene_cost{
	id    = 20803,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20804) -> #cfg_scene_cost{
	id    = 20804,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20805) -> #cfg_scene_cost{
	id    = 20805,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20806) -> #cfg_scene_cost{
	id    = 20806,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20807) -> #cfg_scene_cost{
	id    = 20807,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20808) -> #cfg_scene_cost{
	id    = 20808,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20811) -> #cfg_scene_cost{
	id    = 20811,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20812) -> #cfg_scene_cost{
	id    = 20812,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20813) -> #cfg_scene_cost{
	id    = 20813,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20814) -> #cfg_scene_cost{
	id    = 20814,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20815) -> #cfg_scene_cost{
	id    = 20815,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20816) -> #cfg_scene_cost{
	id    = 20816,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20817) -> #cfg_scene_cost{
	id    = 20817,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20818) -> #cfg_scene_cost{
	id    = 20818,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20821) -> #cfg_scene_cost{
	id    = 20821,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20822) -> #cfg_scene_cost{
	id    = 20822,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20823) -> #cfg_scene_cost{
	id    = 20823,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20824) -> #cfg_scene_cost{
	id    = 20824,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20825) -> #cfg_scene_cost{
	id    = 20825,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20826) -> #cfg_scene_cost{
	id    = 20826,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20827) -> #cfg_scene_cost{
	id    = 20827,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20828) -> #cfg_scene_cost{
	id    = 20828,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20831) -> #cfg_scene_cost{
	id    = 20831,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20832) -> #cfg_scene_cost{
	id    = 20832,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20833) -> #cfg_scene_cost{
	id    = 20833,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20834) -> #cfg_scene_cost{
	id    = 20834,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20835) -> #cfg_scene_cost{
	id    = 20835,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20836) -> #cfg_scene_cost{
	id    = 20836,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20837) -> #cfg_scene_cost{
	id    = 20837,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20838) -> #cfg_scene_cost{
	id    = 20838,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20851) -> #cfg_scene_cost{
	id    = 20851,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20852) -> #cfg_scene_cost{
	id    = 20852,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20853) -> #cfg_scene_cost{
	id    = 20853,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30001) -> #cfg_scene_cost{
	id    = 30001,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30002) -> #cfg_scene_cost{
	id    = 30002,
	type  = 0,
	cost  = [{10806,2}],
	free  = [],
	force = []
};
cost(30101) -> #cfg_scene_cost{
	id    = 30101,
	type  = 0,
	cost  = [{10800,1}],
	free  = [],
	force = []
};
cost(30102) -> #cfg_scene_cost{
	id    = 30102,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30103) -> #cfg_scene_cost{
	id    = 30103,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30201) -> #cfg_scene_cost{
	id    = 30201,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30301) -> #cfg_scene_cost{
	id    = 30301,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30311) -> #cfg_scene_cost{
	id    = 30311,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30312) -> #cfg_scene_cost{
	id    = 30312,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30341) -> #cfg_scene_cost{
	id    = 30341,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30342) -> #cfg_scene_cost{
	id    = 30342,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30351) -> #cfg_scene_cost{
	id    = 30351,
	type  = 0,
	cost  = [{10806,2}],
	free  = [],
	force = []
};
cost(30361) -> #cfg_scene_cost{
	id    = 30361,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30371) -> #cfg_scene_cost{
	id    = 30371,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30372) -> #cfg_scene_cost{
	id    = 30372,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30373) -> #cfg_scene_cost{
	id    = 30373,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30381) -> #cfg_scene_cost{
	id    = 30381,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30391) -> #cfg_scene_cost{
	id    = 30391,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30392) -> #cfg_scene_cost{
	id    = 30392,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30393) -> #cfg_scene_cost{
	id    = 30393,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30394) -> #cfg_scene_cost{
	id    = 30394,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30401) -> #cfg_scene_cost{
	id    = 30401,
	type  = 1,
	cost  = [{1,1,[]},{2,999,[{90010004,2500}]}],
	free  = [],
	force = []
};
cost(30402) -> #cfg_scene_cost{
	id    = 30402,
	type  = 1,
	cost  = [{1,1,[]},{2,999,[{90010004,2500}]}],
	free  = [],
	force = []
};
cost(30403) -> #cfg_scene_cost{
	id    = 30403,
	type  = 1,
	cost  = [{1,1,[]},{2,999,[{90010004,2500}]}],
	free  = [],
	force = []
};
cost(30404) -> #cfg_scene_cost{
	id    = 30404,
	type  = 1,
	cost  = [{1,1,[]},{2,999,[{90010004,2500}]}],
	free  = [],
	force = []
};
cost(30410) -> #cfg_scene_cost{
	id    = 30410,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30411) -> #cfg_scene_cost{
	id    = 30411,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30412) -> #cfg_scene_cost{
	id    = 30412,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30413) -> #cfg_scene_cost{
	id    = 30413,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30501) -> #cfg_scene_cost{
	id    = 30501,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(30601) -> #cfg_scene_cost{
	id    = 30601,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(60001) -> #cfg_scene_cost{
	id    = 60001,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(60002) -> #cfg_scene_cost{
	id    = 60002,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(60003) -> #cfg_scene_cost{
	id    = 60003,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(60004) -> #cfg_scene_cost{
	id    = 60004,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(60005) -> #cfg_scene_cost{
	id    = 60005,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(60006) -> #cfg_scene_cost{
	id    = 60006,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(60007) -> #cfg_scene_cost{
	id    = 60007,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(60008) -> #cfg_scene_cost{
	id    = 60008,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(60009) -> #cfg_scene_cost{
	id    = 60009,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(60010) -> #cfg_scene_cost{
	id    = 60010,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(60011) -> #cfg_scene_cost{
	id    = 60011,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(70001) -> #cfg_scene_cost{
	id    = 70001,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(80001) -> #cfg_scene_cost{
	id    = 80001,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(90001) -> #cfg_scene_cost{
	id    = 90001,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(80101) -> #cfg_scene_cost{
	id    = 80101,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(80102) -> #cfg_scene_cost{
	id    = 80102,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(80103) -> #cfg_scene_cost{
	id    = 80103,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(81000) -> #cfg_scene_cost{
	id    = 81000,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(150601) -> #cfg_scene_cost{
	id    = 150601,
	type  = 1,
	cost  = [{1,1,[]},{2,3,[{90010003,2500}]}],
	free  = [],
	force = []
};
cost(150701) -> #cfg_scene_cost{
	id    = 150701,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(99999) -> #cfg_scene_cost{
	id    = 99999,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(99998) -> #cfg_scene_cost{
	id    = 99998,
	type  = 0,
	cost  = [],
	free  = [],
	force = []
};
cost(20901) -> #cfg_scene_cost{
	id    = 20901,
	type  = 1,
	cost  = [{1,1,[{10804,1}]},{2,2,[{10804,2}]},{3,3,[{10804,3}]},{4,4,[{10804,5}]},{5,5,[{10804,7}]},{6,6,[{10804,8}]}],
	free  = [],
	force = []
};
cost(20902) -> #cfg_scene_cost{
	id    = 20902,
	type  = 1,
	cost  = [{1,1,[{10804,1}]},{2,2,[{10804,2}]},{3,3,[{10804,3}]},{4,4,[{10804,5}]},{5,5,[{10804,7}]},{6,6,[{10804,8}]}],
	free  = [],
	force = []
};
cost(_) -> undefined.

revive(11001) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(11002) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(11003) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(11004) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(11005) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(11006) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(11007) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(11008) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(11009) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(11010) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(11011) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(11012) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(11013) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(11314) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(20000) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20001) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20002) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20003) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20004) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20005) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20006) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20007) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20100) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(20101) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(20102) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(20103) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(20104) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(20105) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(20106) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(20201) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(20202) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(20203) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(20301) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20302) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20501) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20511) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20512) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20513) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20701) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20702) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20711) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20712) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20721) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20722) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20731) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20732) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20733) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20734) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20735) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20736) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20737) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20738) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20739) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20740) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20741) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20742) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20743) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20744) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 10,
	cost   = [{90010004,300}]
};
revive(20801) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20802) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20803) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20804) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20805) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20806) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20807) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20808) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20811) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20812) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20813) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20814) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20815) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20816) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20817) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20818) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20821) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20822) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20823) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20824) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20825) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20826) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20827) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20828) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20831) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20832) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20833) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20834) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20835) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20836) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20837) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20838) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20851) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20852) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20853) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(30001) -> #cfg_revive{
	notify = false,
	manu   = false,
	type   = 2,
	time   = 0,
	cost   = []
};
revive(30002) -> #cfg_revive{
	notify = false,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(30101) -> #cfg_revive{
	notify = false,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(30102) -> #cfg_revive{
	notify = false,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(30103) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(30201) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(30301) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(30311) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(30312) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(30341) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 0,
	cost   = []
};
revive(30342) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 0,
	cost   = []
};
revive(30351) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(30361) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(30371) -> #cfg_revive{
	notify = false,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(30372) -> #cfg_revive{
	notify = false,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(30373) -> #cfg_revive{
	notify = false,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(30381) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(30391) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 5,
	cost   = [{90010004,300}]
};
revive(30392) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 5,
	cost   = [{90010004,300}]
};
revive(30393) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 5,
	cost   = [{90010004,300}]
};
revive(30394) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 5,
	cost   = [{90010004,300}]
};
revive(30401) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 10,
	cost   = []
};
revive(30402) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 10,
	cost   = []
};
revive(30403) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 10,
	cost   = []
};
revive(30404) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 10,
	cost   = []
};
revive(30410) -> #cfg_revive{
	notify = false,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(30411) -> #cfg_revive{
	notify = false,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(30412) -> #cfg_revive{
	notify = false,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(30413) -> #cfg_revive{
	notify = false,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(30501) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 10,
	cost   = []
};
revive(30601) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 10,
	cost   = []
};
revive(60001) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(60002) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(60003) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(60004) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(60005) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(60006) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(60007) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 3,
	cost   = []
};
revive(60008) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 3,
	cost   = []
};
revive(60009) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 3,
	cost   = []
};
revive(60010) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 3,
	cost   = []
};
revive(60011) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 3,
	cost   = []
};
revive(70001) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(80001) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(90001) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(80101) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(80102) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(80103) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(81000) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 2,
	time   = 5,
	cost   = []
};
revive(150601) -> #cfg_revive{
	notify = false,
	manu   = false,
	type   = 2,
	time   = 0,
	cost   = [ ]
};
revive(150701) -> #cfg_revive{
	notify = false,
	manu   = false,
	type   = 2,
	time   = 90,
	cost   = []
};
revive(99999) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(99998) -> #cfg_revive{
	notify = true,
	manu   = false,
	type   = 1,
	time   = 5,
	cost   = []
};
revive(20901) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(20902) -> #cfg_revive{
	notify = true,
	manu   = true,
	type   = 2,
	time   = 30,
	cost   = [{90010004,300}]
};
revive(_) -> undefined.

scenes(1, 2) -> [11009,11011,11001,11004,11008,11006,11010,99999,99998,11002,11012,11013,11005,11007];
scenes(1, 1) -> [11003];
scenes(1, 5) -> [20852,20853,30301,30391,30392,30372,30410,30411,11314,20851,30311,30341,30361];
scenes(1, 4) -> [20000,20003,20101,20102,20203,20302,20005,20007,20104,20105,20106,20001,20002,20100,20202,20301,20004,20006,20103,20201,20501];
scenes(2, 4) -> [20511,20512,20513,20901,20902];
scenes(2, 5) -> [20824,20838,80101,20734,20817,20744,20805,20806,20815,20735,20802,20821,30394,81000,20711,20814,20812,20816,30413,20741,20811,20826,30373,20702,20739,20722,20732,20813,20823,20828,30312,20701,20712,80103,20807,20808,20731,20736,20836,30342,20804,20832,20831,30412,20721,20818,20803,20738,20801,20743,20822,20825,20740,20742,20737,20827,20834,20837,30393,20733,20833,20835,80102];
scenes(1, 3) -> [60009,30402,60001,60002,60006,30403,60004,60007,60010,60011,30001,30103,30371,30501,30601,60005,60008,90001,30002,30404,70001,150601,30102,30401,60003,80001,150701,30101,30201,30351,30381];
scenes(_, _) -> [].

scenes() -> [30342,20007,20734,20828,20852,60007,81000,20003,20722,20803,30601,20712,150601,99999,20812,20832,30372,30501,20732,20101,20738,30341,80103,11005,11007,20100,20744,30002,30312,30412,20513,30103,30393,11009,20103,20203,30351,20807,20813,20817,20831,20834,30101,70001,80101,11004,20001,20102,20104,20105,20818,20837,30102,60002,11011,20006,20741,20822,30311,99998,11001,11012,20512,20701,20731,20825,20853,30392,30403,20002,20721,30361,30391,30404,80001,20901,20815,30394,60005,150701,20202,20836,20806,30373,60010,80102,20743,20826,20801,20902,20005,20833,30201,30411,20711,20733,20736,20742,20802,20814,60003,60008,20106,20823,11008,20301,20302,30402,20000,30371,11013,20004,20511,20824,20851,30381,60004,60006,20805,20808,20811,20827,20835,30001,11003,20201,20737,60011,11002,11010,20501,20735,20740,30410,11314,20804,20816,20838,30401,30413,11006,20702,90001,20739,20821,30301,60001,60009].

whole(11001) -> false;
whole(11002) -> false;
whole(11003) -> false;
whole(11004) -> false;
whole(11005) -> false;
whole(11006) -> false;
whole(11007) -> false;
whole(11008) -> false;
whole(11009) -> false;
whole(11010) -> false;
whole(11011) -> false;
whole(11012) -> false;
whole(11013) -> false;
whole(11314) -> false;
whole(20000) -> false;
whole(20001) -> false;
whole(20002) -> false;
whole(20003) -> false;
whole(20004) -> false;
whole(20005) -> false;
whole(20006) -> false;
whole(20007) -> false;
whole(20100) -> false;
whole(20101) -> false;
whole(20102) -> false;
whole(20103) -> false;
whole(20104) -> false;
whole(20105) -> false;
whole(20106) -> false;
whole(20201) -> false;
whole(20202) -> false;
whole(20203) -> false;
whole(20301) -> false;
whole(20302) -> false;
whole(20501) -> false;
whole(20511) -> false;
whole(20512) -> false;
whole(20513) -> false;
whole(20701) -> false;
whole(20702) -> false;
whole(20711) -> false;
whole(20712) -> false;
whole(20721) -> false;
whole(20722) -> false;
whole(20731) -> false;
whole(20732) -> false;
whole(20733) -> false;
whole(20734) -> false;
whole(20735) -> false;
whole(20736) -> false;
whole(20737) -> false;
whole(20738) -> false;
whole(20739) -> false;
whole(20740) -> false;
whole(20741) -> false;
whole(20742) -> false;
whole(20743) -> false;
whole(20744) -> false;
whole(20801) -> false;
whole(20802) -> false;
whole(20803) -> false;
whole(20804) -> false;
whole(20805) -> false;
whole(20806) -> false;
whole(20807) -> false;
whole(20808) -> false;
whole(20811) -> false;
whole(20812) -> false;
whole(20813) -> false;
whole(20814) -> false;
whole(20815) -> false;
whole(20816) -> false;
whole(20817) -> false;
whole(20818) -> false;
whole(20821) -> false;
whole(20822) -> false;
whole(20823) -> false;
whole(20824) -> false;
whole(20825) -> false;
whole(20826) -> false;
whole(20827) -> false;
whole(20828) -> false;
whole(20831) -> false;
whole(20832) -> false;
whole(20833) -> false;
whole(20834) -> false;
whole(20835) -> false;
whole(20836) -> false;
whole(20837) -> false;
whole(20838) -> false;
whole(20851) -> false;
whole(20852) -> false;
whole(20853) -> false;
whole(30001) -> false;
whole(30002) -> false;
whole(30101) -> false;
whole(30102) -> false;
whole(30103) -> false;
whole(30201) -> false;
whole(30301) -> true;
whole(30311) -> true;
whole(30312) -> true;
whole(30341) -> false;
whole(30342) -> false;
whole(30351) -> false;
whole(30361) -> false;
whole(30371) -> true;
whole(30372) -> true;
whole(30373) -> true;
whole(30381) -> false;
whole(30391) -> true;
whole(30392) -> true;
whole(30393) -> true;
whole(30394) -> true;
whole(30401) -> false;
whole(30402) -> false;
whole(30403) -> false;
whole(30404) -> false;
whole(30410) -> false;
whole(30411) -> true;
whole(30412) -> false;
whole(30413) -> true;
whole(30501) -> false;
whole(30601) -> false;
whole(60001) -> false;
whole(60002) -> false;
whole(60003) -> false;
whole(60004) -> false;
whole(60005) -> false;
whole(60006) -> false;
whole(60007) -> false;
whole(60008) -> false;
whole(60009) -> false;
whole(60010) -> false;
whole(60011) -> false;
whole(70001) -> false;
whole(80001) -> false;
whole(90001) -> false;
whole(80101) -> false;
whole(80102) -> false;
whole(80103) -> false;
whole(81000) -> false;
whole(150601) -> false;
whole(150701) -> false;
whole(99999) -> false;
whole(99998) -> false;
whole(20901) -> false;
whole(20902) -> false;
whole(_) -> false.


cluster(20511) -> 1024008;
cluster(20512) -> 1024008;
cluster(20513) -> 1024008;
cluster(20701) -> 1024008;
cluster(20702) -> 1024008;
cluster(20711) -> 1024008;
cluster(20712) -> 1024008;
cluster(20721) -> 1024008;
cluster(20722) -> 1024008;
cluster(20731) -> 1024008;
cluster(20732) -> 1024008;
cluster(20733) -> 1024008;
cluster(20734) -> 1024008;
cluster(20735) -> 1024008;
cluster(20736) -> 1024008;
cluster(20737) -> 1024008;
cluster(20738) -> 1024008;
cluster(20739) -> 1024008;
cluster(20740) -> 1024008;
cluster(20741) -> 1024008;
cluster(20742) -> 1024008;
cluster(20743) -> 1024008;
cluster(20744) -> 1024008;
cluster(20801) -> 1024008;
cluster(20802) -> 1024008;
cluster(20803) -> 1024008;
cluster(20804) -> 1024008;
cluster(20805) -> 1024008;
cluster(20806) -> 1024008;
cluster(20807) -> 1024008;
cluster(20808) -> 1024008;
cluster(20811) -> 1024008;
cluster(20812) -> 1024008;
cluster(20813) -> 1024008;
cluster(20814) -> 1024008;
cluster(20815) -> 1024008;
cluster(20816) -> 1024008;
cluster(20817) -> 1024008;
cluster(20818) -> 1024008;
cluster(20821) -> 1024008;
cluster(20822) -> 1024008;
cluster(20823) -> 1024008;
cluster(20824) -> 1024008;
cluster(20825) -> 1024008;
cluster(20826) -> 1024008;
cluster(20827) -> 1024008;
cluster(20828) -> 1024008;
cluster(20831) -> 1024008;
cluster(20832) -> 1024008;
cluster(20833) -> 1024008;
cluster(20834) -> 1024008;
cluster(20835) -> 1024008;
cluster(20836) -> 1024008;
cluster(20837) -> 1024008;
cluster(20838) -> 1024008;
cluster(30312) -> 1024008;
cluster(30342) -> 1024008;
cluster(30373) -> 1024008;
cluster(30393) -> 1024008;
cluster(30394) -> 1024008;
cluster(30412) -> 1024008;
cluster(30413) -> 1024008;
cluster(80101) -> 1024008;
cluster(80102) -> 1024008;
cluster(80103) -> 1024008;
cluster(81000) -> 1024008;
cluster(20901) -> 1024008;
cluster(20902) -> 1024008;
cluster(_) -> undefined.
