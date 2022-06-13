% Automatically generated, do not edit
-module(cfg_task).

-compile([export_all]).
-compile(nowarn_export_all).

-include("task.hrl").

find(1100101) -> #cfg_task{
	id     = 1100101,
	name   = "冒险启程(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,0}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100100,1,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,38,1},{[11010102,12010102],1,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1100201) -> #cfg_task{
	id     = 1100201,
	name   = "冒险启程(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1100101}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1100,0,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,58,1},{90010005,30000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1100301) -> #cfg_task{
	id     = 1100301,
	name   = "冒险启程(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1100201}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100101,3,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,60,1},{90010005,30000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1100302) -> #cfg_task{
	id     = 1100302,
	name   = "少女哀愁(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1100301}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1101,0,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,60,1},{90010005,30000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1100304) -> #cfg_task{
	id     = 1100304,
	name   = "少女哀愁(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1100302}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1101,0,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,60,1},{90010005,30000,1},{11002,1,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1100501) -> #cfg_task{
	id     = 1100501,
	name   = "正义化身(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1100304}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1102,0,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,422,1},{90010005,30000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1100502) -> #cfg_task{
	id     = 1100502,
	name   = "正义化身(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1100501}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1112,0,11001,1,[]},{9,60007,0,60007,1,[]}],
	cost   = [],
	gain   = [{90010002,430,1},{90010005,30000,1},{[11011003,12011003],1,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1100701) -> #cfg_task{
	id     = 1100701,
	name   = "正义化身(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1100502}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1112,0,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,486,1},{90010005,30000,1},{90010004,500,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1100801) -> #cfg_task{
	id     = 1100801,
	name   = "魔法手卷(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1100701}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1103,0,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,486,1},{90010005,30000,1},{90010004,500,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1100901) -> #cfg_task{
	id     = 1100901,
	name   = "魔法手卷(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1100801}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100104,1,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,672,1},{90010005,30000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1101001) -> #cfg_task{
	id     = 1101001,
	name   = "魔法手卷(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1100901}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1103,0,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,1265,1},{90010005,30000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1101201) -> #cfg_task{
	id     = 1101201,
	name   = "前方议论(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1101001}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1104,0,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,1275,1},{90010005,30000,1},{[11010803,12010803],1,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1101301) -> #cfg_task{
	id     = 1101301,
	name   = "前方议论(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1101201}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100105,3,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,1285,1},{90010005,30000,1},{[11010303,11010303],1,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1101401) -> #cfg_task{
	id     = 1101401,
	name   = "前方议论(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1101301}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1105,0,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,1300,1},{90010005,30000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1101402) -> #cfg_task{
	id     = 1101402,
	name   = "哆哆小鸡(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1101401}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100103,1,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,1300,1},{90010005,30000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1101501) -> #cfg_task{
	id     = 1101501,
	name   = "哆哆小鸡(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1101402}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1109,0,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,1300,1},{90010005,30000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1101502) -> #cfg_task{
	id     = 1101502,
	name   = "哆哆小鸡(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1101501}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1106,0,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,1300,1},{90010005,30000,1},{50000,5,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1101601) -> #cfg_task{
	id     = 1101601,
	name   = "层层追逐(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1101502}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100107,5,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,3120,1},{90010005,30000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1101701) -> #cfg_task{
	id     = 1101701,
	name   = "层层追逐(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1101601}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1107,0,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,3674,1},{90010005,30000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1101801) -> #cfg_task{
	id     = 1101801,
	name   = "层层追逐(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1101701}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100108,8,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,4506,1},{90010005,50000,1},{[11010903,12010903],1,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1101901) -> #cfg_task{
	id     = 1101901,
	name   = "危机重重(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1101801}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1108,0,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,7333,1},{90010005,50000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1102101) -> #cfg_task{
	id     = 1102101,
	name   = "危机重重(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1101901}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100111,1,11001,1,[]},{19,1100112,1,11001,1,[]},{19,1100113,1,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,8333,1},{90010005,50000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1102201) -> #cfg_task{
	id     = 1102201,
	name   = "危机重重(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1102101}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1108,0,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,9333,1},{90010005,50000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1102301) -> #cfg_task{
	id     = 1102301,
	name   = "危机重重(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1102201}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1108,0,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,14000,1},{90010005,50000,1},{[11020704,12020704],1,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1102401) -> #cfg_task{
	id     = 1102401,
	name   = "魔王史利丹",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1102301}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1111,0,11001,1,[]},{9,60005,0,60005,1,[]}],
	cost   = [],
	gain   = [{90010002,20000,1},{90010005,50000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1102601) -> #cfg_task{
	id     = 1102601,
	name   = "幕后黑手(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1102401}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1110,0,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,21000,1},{90010005,50000,1},{90010004,500,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1102602) -> #cfg_task{
	id     = 1102602,
	name   = "幕后黑手(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1102601}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1110,0,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,21000,1},{90010005,50000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1102701) -> #cfg_task{
	id     = 1102701,
	name   = "幕后黑手(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1102602}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1111,0,11001,1,[]}],
	cost   = [],
	gain   = [{90010002,22000,1},{90010005,50000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1102801) -> #cfg_task{
	id     = 1102801,
	name   = "幽灵气息(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1102701}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1200,0,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,22540,1},{90010005,50000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1102901) -> #cfg_task{
	id     = 1102901,
	name   = "幽灵气息(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1102801}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100200,8,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,22540,1},{90010005,50000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1103101) -> #cfg_task{
	id     = 1103101,
	name   = "净化蘑菇(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1102901}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1201,0,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,22540,1},{90010005,50000,1},{11001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1103201) -> #cfg_task{
	id     = 1103201,
	name   = "净化蘑菇(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1103101}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100201,1,11002,1,[]},{19,1100210,1,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,22540,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1103301) -> #cfg_task{
	id     = 1103301,
	name   = "净化蘑菇(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1103201}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1202,0,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,22540,1},{90010005,100000,1},{[11020104,12020104],1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1103302) -> #cfg_task{
	id     = 1103302,
	name   = "净化蘑菇(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1103301}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100202,8,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,22540,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1103401) -> #cfg_task{
	id     = 1103401,
	name   = "牧场遭袭(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1103302}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1203,0,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,22540,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1103402) -> #cfg_task{
	id     = 1103402,
	name   = "牧场遭袭(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1103401}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{9,60008,0,60008,1,[]}],
	cost   = [],
	gain   = [{90010002,22540,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1103403) -> #cfg_task{
	id     = 1103403,
	name   = "牧场遭袭(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1103402}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1203,0,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,22540,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1103404) -> #cfg_task{
	id     = 1103404,
	name   = "牧场遭袭(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1103403}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100209,1,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,22540,1},{90010005,100000,1},{40100503,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1103405) -> #cfg_task{
	id     = 1103405,
	name   = "言传身教(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1103404}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1204,0,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,25144,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1103501) -> #cfg_task{
	id     = 1103501,
	name   = "言传身教(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1103405}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1204,0,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,25144,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1103601) -> #cfg_task{
	id     = 1103601,
	name   = "言传身教(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1103501}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100203,10,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,56496,1},{90010005,100000,1},{90010004,500,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1103701) -> #cfg_task{
	id     = 1103701,
	name   = "精灵之羽(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1103601}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1205,0,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,63504,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1103801) -> #cfg_task{
	id     = 1103801,
	name   = "精灵之羽(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1103701}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100205,1,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,76980,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1104001) -> #cfg_task{
	id     = 1104001,
	name   = "精灵之羽(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1103801}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1206,0,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,86980,1},{90010005,100000,1},{51000,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1104201) -> #cfg_task{
	id     = 1104201,
	name   = "魔杖魔剑(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1104001}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100204,1,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,96980,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1104301) -> #cfg_task{
	id     = 1104301,
	name   = "魔杖魔剑(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1104201}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1207,0,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,106980,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1104302) -> #cfg_task{
	id     = 1104302,
	name   = "魔杖魔剑(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1104301}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1207,0,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,116980,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1104401) -> #cfg_task{
	id     = 1104401,
	name   = "魔杖魔剑(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1104302}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100208,10,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,126980,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1104501) -> #cfg_task{
	id     = 1104501,
	name   = "经验幻灵(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1104401}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1207,0,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,136980,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1104701) -> #cfg_task{
	id     = 1104701,
	name   = "经验幻灵(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1104501}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100207,1,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,146980,1},{90010005,100000,1},{90010004,500,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1104702) -> #cfg_task{
	id     = 1104702,
	name   = "经验幻灵(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1104701}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1208,0,11002,1,[]},{9,60004,0,60004,1,[]}],
	cost   = [],
	gain   = [{90010002,156980,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1105201) -> #cfg_task{
	id     = 1105201,
	name   = "经验幻灵(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1104702}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1208,0,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,263333,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1105301) -> #cfg_task{
	id     = 1105301,
	name   = "幻灵相伴(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1105201}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1208,0,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,273333,1},{90010005,100000,1},{11020147,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1105302) -> #cfg_task{
	id     = 1105302,
	name   = "幻灵相伴(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1105301}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1208,0,11002,1,[]}],
	cost   = [],
	gain   = [{90010002,283333,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1105401) -> #cfg_task{
	id     = 1105401,
	name   = "浮华背后(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1105302}, {level,40,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1309,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,283333,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1105402) -> #cfg_task{
	id     = 1105402,
	name   = "浮华背后(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1105401}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1309,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,293333,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1105403) -> #cfg_task{
	id     = 1105403,
	name   = "浮华背后(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1105402}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1300,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,303333,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1105501) -> #cfg_task{
	id     = 1105501,
	name   = "泰坦王城(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1105403}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1301,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,476400,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1105502) -> #cfg_task{
	id     = 1105502,
	name   = "泰坦王城(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1105501}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1301,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,486400,1},{90010005,100000,1},{[11030604,12030604],1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1105601) -> #cfg_task{
	id     = 1105601,
	name   = "泰坦王城(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1105502}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1306,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,496400,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1105602) -> #cfg_task{
	id     = 1105602,
	name   = "泰坦王城(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1105601}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1306,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,526400,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1105603) -> #cfg_task{
	id     = 1105603,
	name   = "真相调查(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1105602}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1304,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,681870,1},{90010005,100000,1},{[11030904,12030904],1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1105701) -> #cfg_task{
	id     = 1105701,
	name   = "真相调查(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1105603}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1302,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,691870,1},{90010005,100000,1},{[11030303,11030303],1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1105702) -> #cfg_task{
	id     = 1105702,
	name   = "真相调查(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1105701}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100301,1,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,701870,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1105801) -> #cfg_task{
	id     = 1105801,
	name   = "真相调查(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1105702}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1303,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,711870,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1105802) -> #cfg_task{
	id     = 1105802,
	name   = "疑团迷雾(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1105801}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1302,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1105901) -> #cfg_task{
	id     = 1105901,
	name   = "疑团迷雾(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1105802}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1306,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,955317,1},{90010005,150000,1},{10303,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1106001) -> #cfg_task{
	id     = 1106001,
	name   = "疑团迷雾(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1105901}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1306,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,955317,1},{90010005,150000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1106002) -> #cfg_task{
	id     = 1106002,
	name   = "疑团迷雾(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1106001}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1400,0,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,955317,1},{90010005,150000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1106101) -> #cfg_task{
	id     = 1106101,
	name   = "人鱼之泪(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1106002}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1408,0,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,955317,1},{90010005,150000,1},{90010004,500,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1106201) -> #cfg_task{
	id     = 1106201,
	name   = "人鱼之泪(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1106101}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100400,1,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,955317,1},{90010005,150000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1106202) -> #cfg_task{
	id     = 1106202,
	name   = "人鱼之泪(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1106201}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1408,0,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,955317,1},{90010005,150000,1},{49999998,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1106203) -> #cfg_task{
	id     = 1106203,
	name   = "人鱼之泪(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1106202}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1409,0,11004,1,[]},{9,60009,0,60009,1,[]}],
	cost   = [],
	gain   = [{90010002,955317,1},{90010005,150000,1},{[11030704,12030704],1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1106204) -> #cfg_task{
	id     = 1106204,
	name   = "天使之翼(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1106203}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100401,15,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,955317,1},{90010005,150000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1106205) -> #cfg_task{
	id     = 1106205,
	name   = "天使之翼(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1106204}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1402,0,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,1294500,1},{90010005,150000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1106206) -> #cfg_task{
	id     = 1106206,
	name   = "天使之翼(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1106205}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{5,13145,10,0,0,[]}],
	cost   = [{13145,10}],
	gain   = [{90010002,1294500,1},{90010005,150000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1106207) -> #cfg_task{
	id     = 1106207,
	name   = "天使之翼(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1106206}, {level,1,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1403,0,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,1294500,1},{90010005,150000,1},{51000,3,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1106208) -> #cfg_task{
	id     = 1106208,
	name   = "日常跑环(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1106207}, {level,60,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100403,15,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,1294500,1},{90010005,150000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1106210) -> #cfg_task{
	id     = 1106210,
	name   = "日常跑环(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1106208}, {level,60,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100404,1,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,1294500,1},{90010005,150000,1},{90010004,500,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1106211) -> #cfg_task{
	id     = 1106211,
	name   = "日常跑环(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1106210}, {level,60,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100405,15,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,1294500,1},{90010005,150000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1106500) -> #cfg_task{
	id     = 1106500,
	name   = "日常跑环(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1106211}, {level,60,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1404,0,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,1294500,1},{90010005,150000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1106501) -> #cfg_task{
	id     = 1106501,
	name   = "日常跑环(五)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1106500}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1404,0,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,1294500,1},{90010005,150000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1107001) -> #cfg_task{
	id     = 1107001,
	name   = "魔塔通天(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1106501}, {level,70,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1405,0,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,1294500,1},{90010005,150000,1},{90010004,500,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1107002) -> #cfg_task{
	id     = 1107002,
	name   = "魔塔通天(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1107001}, {level,70,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{90010002,4891825,1},{90010005,150000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1107003) -> #cfg_task{
	id     = 1107003,
	name   = "磁力装置(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1107002}, {level,70,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1404,0,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,9783650,1},{90010005,200000,1},{90010001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1107101) -> #cfg_task{
	id     = 1107101,
	name   = "磁力装置(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1107003}, {level,71,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1405,0,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,9783650,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1107201) -> #cfg_task{
	id     = 1107201,
	name   = "磁力装置(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1107101}, {level,72,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{5,13146,10,0,0,[]}],
	cost   = [{13146,10}],
	gain   = [{90010002,9783650,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1107301) -> #cfg_task{
	id     = 1107301,
	name   = "磁力装置(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1107201}, {level,73,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1406,0,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,9783650,1},{90010005,200000,1},{10800,5,1},{10015,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1107401) -> #cfg_task{
	id     = 1107401,
	name   = "魔王短信(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1107301}, {level,74,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100409,1,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,1762756,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1107402) -> #cfg_task{
	id     = 1107402,
	name   = "魔王短信(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1107401}, {level,74,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100407,20,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,1762756,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1107501) -> #cfg_task{
	id     = 1107501,
	name   = "机甲竞速(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1107402}, {level,75,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1411,0,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,9783650,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1107502) -> #cfg_task{
	id     = 1107502,
	name   = "机甲竞速(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1107501}, {level,75,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{10,319,1,0,0,[{link,1011,2,1107502}]}],
	cost   = [],
	gain   = [{90010002,9783650,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1108003) -> #cfg_task{
	id     = 1108003,
	name   = "机甲竞速(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1107502}, {level,75,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1411,0,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,1762756,1},{90010005,200000,1},{11106,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1108501) -> #cfg_task{
	id     = 1108501,
	name   = "轰龙秘宝(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1108003}, {level,85,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1410,0,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,1762756,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1108502) -> #cfg_task{
	id     = 1108502,
	name   = "轰龙秘宝(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1108501}, {level,85,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1410,0,11004,1,[]},{9,60011,0,60011,1,[]}],
	cost   = [],
	gain   = [{90010002,1762756,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1108503) -> #cfg_task{
	id     = 1108503,
	name   = "轰龙秘宝(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1108502}, {level,85,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1410,0,11004,1,[]},{19,1100412,1,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,1762756,1},{90010005,200000,1},{52000,3,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1108504) -> #cfg_task{
	id     = 1108504,
	name   = "轰龙秘宝(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1108503}, {level,85,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1411,0,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,1762756,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1109001) -> #cfg_task{
	id     = 1109001,
	name   = "世界首领(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1108504}, {level,90,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100411,20,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,1762756,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1109002) -> #cfg_task{
	id     = 1109002,
	name   = "世界首领(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1109001}, {level,90,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1407,0,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,1762756,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1109003) -> #cfg_task{
	id     = 1109003,
	name   = "世界首领(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1109002}, {level,90,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{9,312,0,60006,1,[{link,160,1}]}],
	cost   = [],
	gain   = [{90010002,1762756,1},{90010005,200000,1},{11101,1,1},{14014,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1109004) -> #cfg_task{
	id     = 1109004,
	name   = "雪原之路(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1109003}, {level,90,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100407,20,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,1762756,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1109005) -> #cfg_task{
	id     = 1109005,
	name   = "雪原之路(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1109004}, {level,90,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1407,0,11004,1,[]}],
	cost   = [],
	gain   = [{90010002,1762756,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1110001) -> #cfg_task{
	id     = 1110001,
	name   = "躺枪路人(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1109005}, {level,100,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100500,20,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1110002) -> #cfg_task{
	id     = 1110002,
	name   = "躺枪路人(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1110001}, {level,100,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1500,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1110003) -> #cfg_task{
	id     = 1110003,
	name   = "燃烬传说(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1110002}, {level,100,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{5,13147,15,0,0,[]}],
	cost   = [{13147,15}],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1110004) -> #cfg_task{
	id     = 1110004,
	name   = "燃烬传说(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1110003}, {level,100,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1500,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1110005) -> #cfg_task{
	id     = 1110005,
	name   = "燃烬传说(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1110004}, {level,100,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1500,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1},{55000,5,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1110006) -> #cfg_task{
	id     = 1110006,
	name   = "经验副本(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1110005}, {level,100,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1501,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1110501) -> #cfg_task{
	id     = 1110501,
	name   = "经验副本(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1110006}, {level,105,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100507,1,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,3861088,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1110502) -> #cfg_task{
	id     = 1110502,
	name   = "经验副本(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1110501}, {level,105,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100502,20,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,3861088,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1110503) -> #cfg_task{
	id     = 1110503,
	name   = "经验副本(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1110502}, {level,105,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1508,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,3861088,1},{90010005,200000,1},{10800,5,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1110504) -> #cfg_task{
	id     = 1110504,
	name   = "经验副本(五)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1110503}, {level,105,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{10,301,0,30101,1,[{link,150,1,1,2}]}],
	cost   = [],
	gain   = [{90010002,3861088,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1110505) -> #cfg_task{
	id     = 1110505,
	name   = "斗士之路(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1110504}, {level,105,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100508,1,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,3861088,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1111001) -> #cfg_task{
	id     = 1111001,
	name   = "斗士之路(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1110505}, {level,110,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1502,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1111002) -> #cfg_task{
	id     = 1111002,
	name   = "斗士之路(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1111001}, {level,110,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1508,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1111003) -> #cfg_task{
	id     = 1111003,
	name   = "斗士之路(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1111002}, {level,110,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1502,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,3861088,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1111004) -> #cfg_task{
	id     = 1111004,
	name   = "斗士之路(五)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1111003}, {level,110,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{10,304,0,30201,1,[{link,150,1,2,1}]}],
	cost   = [],
	gain   = [{90010002,3861088,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1111005) -> #cfg_task{
	id     = 1111005,
	name   = "吞噬装备(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1111004}, {level,110,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1502,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,3861088,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1111006) -> #cfg_task{
	id     = 1111006,
	name   = "吞噬装备(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1111005}, {level,110,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1504,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,3861088,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1111501) -> #cfg_task{
	id     = 1111501,
	name   = "镶嵌宝石(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1111006}, {level,115,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{5,13148,15,0,0,[]}],
	cost   = [{13148,15}],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1111502) -> #cfg_task{
	id     = 1111502,
	name   = "镶嵌宝石(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1111501}, {level,115,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1504,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1},{100033,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1111503) -> #cfg_task{
	id     = 1111503,
	name   = "荣誉之道(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1111502}, {level,115,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100506,25,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1111504) -> #cfg_task{
	id     = 1111504,
	name   = "荣誉之道(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1111503}, {level,115,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1503,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1111505) -> #cfg_task{
	id     = 1111505,
	name   = "头衔爵位(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1111504}, {level,115,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1505,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1111506) -> #cfg_task{
	id     = 1111506,
	name   = "头衔爵位(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1111505}, {level,115,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1505,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1112001) -> #cfg_task{
	id     = 1112001,
	name   = "头衔爵位(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1111506}, {level,120,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1505,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1112002) -> #cfg_task{
	id     = 1112002,
	name   = "雪域神兵(一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1112001}, {level,120,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1504,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1112003) -> #cfg_task{
	id     = 1112003,
	name   = "雪域神兵(二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1112002}, {level,120,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1507,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1112004) -> #cfg_task{
	id     = 1112004,
	name   = "雪域神兵(三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1112003}, {level,120,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1507,0,11005,1,[]},{9,60010,0,60010,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1112005) -> #cfg_task{
	id     = 1112005,
	name   = "雪域神兵(四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1112004}, {level,120,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100509,1,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1},{53000,5,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1112006) -> #cfg_task{
	id     = 1112006,
	name   = "雪域神兵(五）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1112005}, {level,120,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1507,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1112007) -> #cfg_task{
	id     = 1112007,
	name   = "风火山龙(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1112006}, {level,120,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1507,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1112008) -> #cfg_task{
	id     = 1112008,
	name   = "风火山龙(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1112007}, {level,120,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1507,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,6308373,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1113001) -> #cfg_task{
	id     = 1113001,
	name   = "飞行实验(一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1112008}, {level,130,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1507,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,23074272,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1113002) -> #cfg_task{
	id     = 1113002,
	name   = "飞行实验(二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1113001}, {level,130,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100505,30,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,23074272,1},{90010005,200000,1},{11140,5,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1113003) -> #cfg_task{
	id     = 1113003,
	name   = "飞行实验(三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1113002}, {level,130,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1506,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,23074272,1},{90010005,200000,1},{[11040825,12040825],4,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1113004) -> #cfg_task{
	id     = 1113004,
	name   = "飞行实验(四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1113003}, {level,130,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1505,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,23074272,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1114001) -> #cfg_task{
	id     = 1114001,
	name   = "贪婪宝藏(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1113004}, {level,140,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1509,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,35196907,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1114002) -> #cfg_task{
	id     = 1114002,
	name   = "贪婪宝藏(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1114001}, {level,140,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100510,30,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,35196907,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1114003) -> #cfg_task{
	id     = 1114003,
	name   = "贪婪宝藏(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1114002}, {level,140,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1509,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,35196907,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1114004) -> #cfg_task{
	id     = 1114004,
	name   = "贪婪宝藏(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1114003}, {level,140,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1509,0,11005,1,[]}],
	cost   = [],
	gain   = [{90010002,35196907,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1115001) -> #cfg_task{
	id     = 1115001,
	name   = "日夜思念(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1114004}, {level,150,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1701,0,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,53294344,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1115002) -> #cfg_task{
	id     = 1115002,
	name   = "日夜思念(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1115001}, {level,150,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100701,35,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,53294344,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1115003) -> #cfg_task{
	id     = 1115003,
	name   = "日夜思念(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1115002}, {level,150,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1701,0,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,53294344,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1115004) -> #cfg_task{
	id     = 1115004,
	name   = "日夜思念(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1115003}, {level,150,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100702,35,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,53294344,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1116001) -> #cfg_task{
	id     = 1116001,
	name   = "海底裂缝(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1115004}, {level,160,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1704,0,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,87957066,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1116002) -> #cfg_task{
	id     = 1116002,
	name   = "海底裂缝(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1116001}, {level,160,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100702,35,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,87957066,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1116003) -> #cfg_task{
	id     = 1116003,
	name   = "海底裂缝(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1116002}, {level,160,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1702,0,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,87957066,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1116004) -> #cfg_task{
	id     = 1116004,
	name   = "海底裂缝(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1116003}, {level,160,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100704,35,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,87957066,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1116005) -> #cfg_task{
	id     = 1116005,
	name   = "开启头衔(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1116004}, {level,165,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1705,0,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,87957066,1},{90010005,200000,1},{11120,3,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1116006) -> #cfg_task{
	id     = 1116006,
	name   = "开启头衔(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1116005}, {level,165,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1702,0,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,87957066,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1117001) -> #cfg_task{
	id     = 1117001,
	name   = "失踪皇后(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1116006}, {level,170,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1705,0,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,140118451,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1117002) -> #cfg_task{
	id     = 1117002,
	name   = "失踪皇后(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1117001}, {level,170,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100704,35,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,140118451,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1117003) -> #cfg_task{
	id     = 1117003,
	name   = "失踪皇后(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1117002}, {level,170,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1703,0,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,140118451,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1117004) -> #cfg_task{
	id     = 1117004,
	name   = "失踪皇后(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1117003}, {level,170,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100707,35,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,140118451,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1118001) -> #cfg_task{
	id     = 1118001,
	name   = "故乡的海(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1117004}, {level,180,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1303,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,218230225,1},{90010005,200000,1},{57101,8,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1118002) -> #cfg_task{
	id     = 1118002,
	name   = "故乡的海(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1118001}, {level,180,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1703,0,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,218230225,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1118003) -> #cfg_task{
	id     = 1118003,
	name   = "故乡的海(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1118002}, {level,180,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100708,1,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,218230225,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1118004) -> #cfg_task{
	id     = 1118004,
	name   = "魔兽攻城(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1118003}, {level,180,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100705,35,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,218230225,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1118005) -> #cfg_task{
	id     = 1118005,
	name   = "魔兽攻城(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1118004}, {level,180,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1705,0,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,218230225,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1119001) -> #cfg_task{
	id     = 1119001,
	name   = "恩怨难断(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1118005}, {level,190,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1705,0,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,334787788,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1119002) -> #cfg_task{
	id     = 1119002,
	name   = "恩怨难断(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1119001}, {level,190,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100705,35,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,334787788,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1119003) -> #cfg_task{
	id     = 1119003,
	name   = "恩怨难断(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1119002}, {level,190,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100706,35,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,334787788,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1119004) -> #cfg_task{
	id     = 1119004,
	name   = "恩怨难断(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1119003}, {level,190,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1706,0,11007,1,[]}],
	cost   = [],
	gain   = [{90010002,334787788,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1120001) -> #cfg_task{
	id     = 1120001,
	name   = "肯特大陆(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1119004}, {level,200,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1300,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,508362291,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1120002) -> #cfg_task{
	id     = 1120002,
	name   = "肯特大陆(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1120001}, {level,200,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1604,0,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,508362291,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1120003) -> #cfg_task{
	id     = 1120003,
	name   = "肯特大陆(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1120002}, {level,200,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100601,35,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,508362291,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1120004) -> #cfg_task{
	id     = 1120004,
	name   = "肯特大陆(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1120003}, {level,200,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1601,0,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,508362291,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1120005) -> #cfg_task{
	id     = 1120005,
	name   = "肯特大陆(五)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1120004}, {level,200,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100602,35,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,508362291,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1121001) -> #cfg_task{
	id     = 1121001,
	name   = "沙漠商队(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1120005}, {level,210,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1601,0,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,508362291,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1121002) -> #cfg_task{
	id     = 1121002,
	name   = "沙漠商队(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1121001}, {level,210,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100607,1,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,508362291,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1121003) -> #cfg_task{
	id     = 1121003,
	name   = "沙漠商队(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1121002}, {level,210,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1605,0,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,1100392591,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1121004) -> #cfg_task{
	id     = 1121004,
	name   = "沙漠商队(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1121003}, {level,210,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100603,35,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,1100392591,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1121005) -> #cfg_task{
	id     = 1121005,
	name   = "姻缘喜事(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1121004}, {level,213,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1301,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,1100392591,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1121006) -> #cfg_task{
	id     = 1121006,
	name   = "姻缘喜事(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1121005}, {level,213,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1301,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,1100392591,1},{90010005,200000,1},{11133,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1121007) -> #cfg_task{
	id     = 1121007,
	name   = "姻缘喜事(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1121006}, {level,213,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1310,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,1100392591,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1122001) -> #cfg_task{
	id     = 1122001,
	name   = "湮没文明(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1121007}, {level,220,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1605,0,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,1996890108,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1122002) -> #cfg_task{
	id     = 1122002,
	name   = "湮没文明(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1122001}, {level,220,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100608,1,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,1996890108,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1122003) -> #cfg_task{
	id     = 1122003,
	name   = "湮没文明(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1122002}, {level,220,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1602,0,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,1996890108,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1122004) -> #cfg_task{
	id     = 1122004,
	name   = "湮没文明(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1122003}, {level,220,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1602,0,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,1996890108,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1122005) -> #cfg_task{
	id     = 1122005,
	name   = "湮没文明(五)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1122004}, {level,220,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100604,35,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,1996890108,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1123001) -> #cfg_task{
	id     = 1123001,
	name   = "遗落传说(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1122005}, {level,230,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100604,35,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,3232421173,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1123002) -> #cfg_task{
	id     = 1123002,
	name   = "遗落传说(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1123001}, {level,230,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1603,0,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,3232421173,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1123003) -> #cfg_task{
	id     = 1123003,
	name   = "遗落传说(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1123002}, {level,230,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100605,35,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,3232421173,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1123004) -> #cfg_task{
	id     = 1123004,
	name   = "装备铸造(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1123003}, {level,230,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1603,0,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,3232421173,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1123005) -> #cfg_task{
	id     = 1123005,
	name   = "装备铸造(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1123004}, {level,230,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1602,0,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,5127999323,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1124001) -> #cfg_task{
	id     = 1124001,
	name   = "合成奥秘(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1123005}, {level,240,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1304,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,5127999323,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1124002) -> #cfg_task{
	id     = 1124002,
	name   = "合成奥秘(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1124001}, {level,240,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100606,35,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,5127999323,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1124003) -> #cfg_task{
	id     = 1124003,
	name   = "合成奥秘(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1124002}, {level,240,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1603,0,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,5127999323,1},{90010005,200000,1},{90010020,200,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1124004) -> #cfg_task{
	id     = 1124004,
	name   = "合成奥秘(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1124003}, {level,240,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100604,35,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,5127999323,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1124005) -> #cfg_task{
	id     = 1124005,
	name   = "合成奥秘(五)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1124004}, {level,240,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1602,0,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,5127999323,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1124006) -> #cfg_task{
	id     = 1124006,
	name   = "合成奥秘(六)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1124005}, {level,240,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100608,1,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,5127999323,1},{90010005,200000,1},{[11060825,12060825],4,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1124007) -> #cfg_task{
	id     = 1124007,
	name   = "合成奥秘(七)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1124006}, {level,240,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1602,0,11006,1,[]}],
	cost   = [],
	gain   = [{90010002,5127999323,1},{90010005,200000,1},{90010020,500,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1125001) -> #cfg_task{
	id     = 1125001,
	name   = "掌握线索（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1124007}, {level,250,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2001,0,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,7886522800,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1125002) -> #cfg_task{
	id     = 1125002,
	name   = "掌握线索（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1125001}, {level,250,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101001,40,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,7886522800,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1125003) -> #cfg_task{
	id     = 1125003,
	name   = "掌握线索（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1125002}, {level,250,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101002,40,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,7886522800,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1125004) -> #cfg_task{
	id     = 1125004,
	name   = "宠物融合(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1125003}, {level,250,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2006,0,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,7886522800,1},{90010005,200000,1},{40200503,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1125005) -> #cfg_task{
	id     = 1125005,
	name   = "宠物融合(五)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1125004}, {level,250,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2001,0,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,7886522800,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1126001) -> #cfg_task{
	id     = 1126001,
	name   = "魔法王子（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1125005}, {level,260,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101002,40,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,11750509801,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1126002) -> #cfg_task{
	id     = 1126002,
	name   = "魔法王子（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1126001}, {level,260,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2006,0,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,11750509801,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1126003) -> #cfg_task{
	id     = 1126003,
	name   = "魔法王子（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1126002}, {level,260,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101003,45,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,11750509801,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1126004) -> #cfg_task{
	id     = 1126004,
	name   = "魔法王子（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1126003}, {level,260,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2002,0,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,11750509801,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1126005) -> #cfg_task{
	id     = 1126005,
	name   = "装备套装(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1126004}, {level,260,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101002,45,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,11750509801,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1126006) -> #cfg_task{
	id     = 1126006,
	name   = "装备套装(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1126005}, {level,260,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2002,0,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,16892379286,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1126007) -> #cfg_task{
	id     = 1126007,
	name   = "装备套装(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1126006}, {level,260,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2001,0,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,16892379286,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1127001) -> #cfg_task{
	id     = 1127001,
	name   = "恶魔侵蚀（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1126007}, {level,270,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101003,45,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,16892379286,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1127002) -> #cfg_task{
	id     = 1127002,
	name   = "恶魔侵蚀（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1127001}, {level,270,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2005,0,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,16892379286,1},{90010005,200000,1},{10803,3,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1127003) -> #cfg_task{
	id     = 1127003,
	name   = "恶魔侵蚀（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1127002}, {level,270,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2006,0,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,16892379286,1},{90010005,200000,1},{13101,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1127004) -> #cfg_task{
	id     = 1127004,
	name   = "恶魔侵蚀（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1127003}, {level,270,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101004,45,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,16892379286,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1127005) -> #cfg_task{
	id     = 1127005,
	name   = "远古遗迹(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1127004}, {level,270,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2005,0,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,16892379286,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1127006) -> #cfg_task{
	id     = 1127006,
	name   = "远古遗迹(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1127005}, {level,270,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2006,0,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,16892379286,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1128001) -> #cfg_task{
	id     = 1128001,
	name   = "魔域迷路（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1127006}, {level,280,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101004,45,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,23589699073,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1128002) -> #cfg_task{
	id     = 1128002,
	name   = "魔域迷路（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1128001}, {level,280,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2004,0,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,23589699073,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1128003) -> #cfg_task{
	id     = 1128003,
	name   = "魔域迷路（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1128002}, {level,280,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101005,45,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,23589699073,1},{90010005,200000,1},{15152,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1128004) -> #cfg_task{
	id     = 1128004,
	name   = "魔域迷路（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1128003}, {level,280,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2004,0,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,23589699073,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1129001) -> #cfg_task{
	id     = 1129001,
	name   = "走向深渊（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1128004}, {level,290,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101005,45,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,32049937741,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1129002) -> #cfg_task{
	id     = 1129002,
	name   = "走向深渊（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1129001}, {level,290,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2003,0,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,32049937741,1},{90010005,200000,1},{13114,100,1},{13118,10,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1129003) -> #cfg_task{
	id     = 1129003,
	name   = "走向深渊（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1129002}, {level,290,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101006,50,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,32049937741,1},{90010005,200000,1},{13114,100,1},{13118,10,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1129004) -> #cfg_task{
	id     = 1129004,
	name   = "走向深渊（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1129003}, {level,290,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2003,0,11010,1,[]}],
	cost   = [],
	gain   = [{90010002,32049937741,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1130001) -> #cfg_task{
	id     = 1130001,
	name   = "深海神殿(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1129004}, {level,300,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1308,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,42498088678,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1130002) -> #cfg_task{
	id     = 1130002,
	name   = "深海神殿(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1130001}, {level,300,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1801,0,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,42498088678,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1130003) -> #cfg_task{
	id     = 1130003,
	name   = "深海神殿(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1130002}, {level,300,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100801,50,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,42498088678,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1130004) -> #cfg_task{
	id     = 1130004,
	name   = "深海神殿(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1130003}, {level,300,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100802,50,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,42498088678,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1130005) -> #cfg_task{
	id     = 1130005,
	name   = "深海神殿(五)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1130004}, {level,300,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1803,0,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,42498088678,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1131001) -> #cfg_task{
	id     = 1131001,
	name   = "奇人异事(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1130005}, {level,310,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1802,0,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,71288956800,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1131002) -> #cfg_task{
	id     = 1131002,
	name   = "奇人异事(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1131001}, {level,310,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100802,50,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,71288956800,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1131003) -> #cfg_task{
	id     = 1131003,
	name   = "奇人异事(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1131002}, {level,310,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1803,0,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,71288956800,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1131004) -> #cfg_task{
	id     = 1131004,
	name   = "奇人异事(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1131003}, {level,310,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100803,50,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,71288956800,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1131005) -> #cfg_task{
	id     = 1131005,
	name   = "奇人异事(五)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1131004}, {level,310,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1804,0,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,71288956800,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1132001) -> #cfg_task{
	id     = 1132001,
	name   = "精灵密语(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1131005}, {level,320,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1804,0,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,102759526400,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1132002) -> #cfg_task{
	id     = 1132002,
	name   = "精灵密语(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1132001}, {level,320,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100803,50,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,102759526400,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1132003) -> #cfg_task{
	id     = 1132003,
	name   = "精灵密语(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1132002}, {level,320,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1805,0,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,102759526400,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1132004) -> #cfg_task{
	id     = 1132004,
	name   = "精灵密语(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1132003}, {level,320,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100804,50,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,102759526400,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1133001) -> #cfg_task{
	id     = 1133001,
	name   = "珍珠商人(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1132004}, {level,330,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1805,0,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,138933737600,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1133002) -> #cfg_task{
	id     = 1133002,
	name   = "珍珠商人(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1133001}, {level,330,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100804,50,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,138933737600,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1133003) -> #cfg_task{
	id     = 1133003,
	name   = "珍珠商人(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1133002}, {level,330,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1806,0,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,138933737600,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1133004) -> #cfg_task{
	id     = 1133004,
	name   = "珍珠商人(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1133003}, {level,330,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,1100808,1,11008,1,[]},{19,1100809,1,11008,1,[]},{19,1100810,1,11008,1,[]},{19,1100811,1,11008,1,[]},{19,1100812,1,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,138933737600,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1133005) -> #cfg_task{
	id     = 1133005,
	name   = "珍珠商人(五)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1133004}, {level,330,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1806,0,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,138933737600,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1134001) -> #cfg_task{
	id     = 1134001,
	name   = "巅峰寓言(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1133005}, {level,340,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100803,50,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,189060019200,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1134002) -> #cfg_task{
	id     = 1134002,
	name   = "巅峰寓言(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1134001}, {level,340,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1804,0,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,189060019200,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1134003) -> #cfg_task{
	id     = 1134003,
	name   = "巅峰寓言(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1134002}, {level,340,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100805,50,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,189060019200,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1134004) -> #cfg_task{
	id     = 1134004,
	name   = "巅峰寓言(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1134003}, {level,340,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1805,0,11008,1,[]}],
	cost   = [],
	gain   = [{90010002,189060019200,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1135001) -> #cfg_task{
	id     = 1135001,
	name   = "天空神殿(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1134004}, {level,350,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1300,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,262386800000,1},{90010005,200000,1},{31031,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1135002) -> #cfg_task{
	id     = 1135002,
	name   = "天空神殿(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1135001}, {level,350,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1901,0,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,262386800000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1135003) -> #cfg_task{
	id     = 1135003,
	name   = "天空神殿(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1135002}, {level,350,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100901,50,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,262386800000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1135004) -> #cfg_task{
	id     = 1135004,
	name   = "天空神殿(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1135003}, {level,350,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100902,50,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,262386800000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1135005) -> #cfg_task{
	id     = 1135005,
	name   = "天空神殿(五)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1135004}, {level,350,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1902,0,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,262386800000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1136001) -> #cfg_task{
	id     = 1136001,
	name   = "抵御魔军(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1135005}, {level,360,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1901,0,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,368988800000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1136002) -> #cfg_task{
	id     = 1136002,
	name   = "抵御魔军(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1136001}, {level,360,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100902,50,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,368988800000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1136003) -> #cfg_task{
	id     = 1136003,
	name   = "抵御魔军(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1136002}, {level,360,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1902,0,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,368988800000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1136004) -> #cfg_task{
	id     = 1136004,
	name   = "抵御魔军(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1136003}, {level,360,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100901,50,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,368988800000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1136005) -> #cfg_task{
	id     = 1136005,
	name   = "抵御魔军(五)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1136004}, {level,360,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1903,0,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,368988800000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1137001) -> #cfg_task{
	id     = 1137001,
	name   = "步步深入(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1136005}, {level,370,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1903,0,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,515635574400,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1137002) -> #cfg_task{
	id     = 1137002,
	name   = "步步深入(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1137001}, {level,370,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100903,50,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,515635574400,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1137003) -> #cfg_task{
	id     = 1137003,
	name   = "步步深入(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1137002}, {level,370,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1904,0,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,515635574400,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1137004) -> #cfg_task{
	id     = 1137004,
	name   = "步步深入(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1137003}, {level,370,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100904,50,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,515635574400,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1138001) -> #cfg_task{
	id     = 1138001,
	name   = "地狱天堂(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1137004}, {level,380,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1904,0,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,626260480000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1138002) -> #cfg_task{
	id     = 1138002,
	name   = "地狱天堂(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1138001}, {level,380,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100903,50,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,626260480000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1138003) -> #cfg_task{
	id     = 1138003,
	name   = "地狱天堂(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1138002}, {level,380,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1905,0,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,626260480000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1138004) -> #cfg_task{
	id     = 1138004,
	name   = "幻之岛屿(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1138003}, {level,380,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100905,50,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,626260480000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1138005) -> #cfg_task{
	id     = 1138005,
	name   = "幻之岛屿(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1138004}, {level,380,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1905,0,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,626260480000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1138006) -> #cfg_task{
	id     = 1138006,
	name   = "幻之岛屿(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1138005}, {level,380,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1904,0,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,626260480000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1139001) -> #cfg_task{
	id     = 1139001,
	name   = "巅峰寓言(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1138006}, {level,390,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100904,50,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,825275715200,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1139002) -> #cfg_task{
	id     = 1139002,
	name   = "巅峰寓言(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1139001}, {level,390,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1904,0,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,825275715200,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1139003) -> #cfg_task{
	id     = 1139003,
	name   = "巅峰寓言(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1139002}, {level,390,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1100905,50,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,825275715200,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1139004) -> #cfg_task{
	id     = 1139004,
	name   = "巅峰寓言(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1139003}, {level,390,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1905,0,11009,1,[]}],
	cost   = [],
	gain   = [{90010002,825275715200,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1140001) -> #cfg_task{
	id     = 1140001,
	name   = "精灵城堡(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1139004}, {level,400,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1303,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,1063411200000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1140002) -> #cfg_task{
	id     = 1140002,
	name   = "精灵城堡(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1140001}, {level,400,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2101,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,1063411200000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1140003) -> #cfg_task{
	id     = 1140003,
	name   = "精灵城堡(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1140002}, {level,400,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101101,50,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,1063411200000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1140004) -> #cfg_task{
	id     = 1140004,
	name   = "精灵城堡(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1140003}, {level,400,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101102,50,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,1063411200000,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1141001) -> #cfg_task{
	id     = 1141001,
	name   = "女王秘密(一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1140004}, {level,410,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2102,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,1353785276800,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1141002) -> #cfg_task{
	id     = 1141002,
	name   = "女王秘密(二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1141001}, {level,410,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2101,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,1353785276800,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1141003) -> #cfg_task{
	id     = 1141003,
	name   = "女王秘密(三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1141002}, {level,410,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101102,50,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,1353785276800,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1141004) -> #cfg_task{
	id     = 1141004,
	name   = "女王秘密(四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1141003}, {level,410,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2101,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,1353785276800,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1142001) -> #cfg_task{
	id     = 1142001,
	name   = "远古试炼(一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1141004}, {level,420,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101103,50,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,1714799590400,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1142002) -> #cfg_task{
	id     = 1142002,
	name   = "远古试炼(二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1142001}, {level,420,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2103,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,1714799590400,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1142003) -> #cfg_task{
	id     = 1142003,
	name   = "远古试炼(三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1142002}, {level,420,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2103,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,1714799590400,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1142004) -> #cfg_task{
	id     = 1142004,
	name   = "远古试炼(四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1142003}, {level,420,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101103,50,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,1714799590400,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1143001) -> #cfg_task{
	id     = 1143001,
	name   = "遇见猫猫(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1142004}, {level,430,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2104,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,2164097785534,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1143002) -> #cfg_task{
	id     = 1143002,
	name   = "遇见猫猫(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1143001}, {level,430,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101104,50,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,2164097785534,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1143003) -> #cfg_task{
	id     = 1143003,
	name   = "遇见猫猫(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1143002}, {level,430,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2104,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,2164097785534,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1143004) -> #cfg_task{
	id     = 1143004,
	name   = "遇见猫猫(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1143003}, {level,430,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101103,50,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,2164097785534,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1144001) -> #cfg_task{
	id     = 1144001,
	name   = "人与精灵(一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1143004}, {level,440,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2105,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,2721163963129,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1144002) -> #cfg_task{
	id     = 1144002,
	name   = "人与精灵(二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1144001}, {level,440,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101105,50,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,2721163963129,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1144003) -> #cfg_task{
	id     = 1144003,
	name   = "人与精灵(三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1144002}, {level,440,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2105,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,2721163963129,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1144004) -> #cfg_task{
	id     = 1144004,
	name   = "人与精灵(四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1144003}, {level,440,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2104,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,2721163963129,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1145001) -> #cfg_task{
	id     = 1145001,
	name   = "共同御敌(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1144004}, {level,450,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101104,50,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,14120970932622,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1145002) -> #cfg_task{
	id     = 1145002,
	name   = "共同御敌(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1145001}, {level,450,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2104,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,14120970932622,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1145003) -> #cfg_task{
	id     = 1145003,
	name   = "共同御敌(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1145002}, {level,450,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101105,50,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,14120970932622,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1145004) -> #cfg_task{
	id     = 1145004,
	name   = "共同御敌(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1145003}, {level,450,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2105,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,14120970932622,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1146001) -> #cfg_task{
	id     = 1146001,
	name   = "守护领土(一)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1145004}, {level,460,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1303,0,11003,1,[]}],
	cost   = [],
	gain   = [{90010002,14624153118986,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1146002) -> #cfg_task{
	id     = 1146002,
	name   = "守护领土(二)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1146001}, {level,460,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2105,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,14624153118986,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1146003) -> #cfg_task{
	id     = 1146003,
	name   = "守护领土(三)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1146002}, {level,460,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101103,50,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,14624153118986,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1146004) -> #cfg_task{
	id     = 1146004,
	name   = "守护领土(四)",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1146003}, {level,460,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101105,50,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,14624153118986,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1147001) -> #cfg_task{
	id     = 1147001,
	name   = "精灵之力(一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1146004}, {level,470,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2102,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,18401711139412,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1147002) -> #cfg_task{
	id     = 1147002,
	name   = "精灵之力(二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1147001}, {level,470,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2101,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,18401711139412,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1147003) -> #cfg_task{
	id     = 1147003,
	name   = "精灵之力(三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1147002}, {level,470,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101102,50,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,18401711139412,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1147004) -> #cfg_task{
	id     = 1147004,
	name   = "精灵之力(四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1147003}, {level,470,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2101,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,18401711139412,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1148001) -> #cfg_task{
	id     = 1148001,
	name   = "大地精灵(一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1147004}, {level,480,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101103,50,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,22179269159838,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1148002) -> #cfg_task{
	id     = 1148002,
	name   = "大地精灵(二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1148001}, {level,480,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2106,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,22179269159838,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1148003) -> #cfg_task{
	id     = 1148003,
	name   = "大地精灵(三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1148002}, {level,480,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2105,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,22179269159838,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1148004) -> #cfg_task{
	id     = 1148004,
	name   = "大地精灵(四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1148003}, {level,480,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101103,50,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,22179269159838,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1149001) -> #cfg_task{
	id     = 1149001,
	name   = "发现精灵（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1148004}, {level,490,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2104,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,25956827180264,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1149002) -> #cfg_task{
	id     = 1149002,
	name   = "发现精灵（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1149001}, {level,490,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101104,50,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,25956827180264,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1149003) -> #cfg_task{
	id     = 1149003,
	name   = "发现精灵（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1149002}, {level,490,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2104,0,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,25956827180264,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1149004) -> #cfg_task{
	id     = 1149004,
	name   = "发现精灵（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1149003}, {level,490,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101103,50,11011,1,[]}],
	cost   = [],
	gain   = [{90010002,25956827180264,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150001) -> #cfg_task{
	id     = 1150001,
	name   = "我是勇士（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1149004}, {level,500,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2201,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150002) -> #cfg_task{
	id     = 1150002,
	name   = "我是勇士（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150001}, {level,500,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101201,50,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150003) -> #cfg_task{
	id     = 1150003,
	name   = "我是勇士（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150002}, {level,500,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2202,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150004) -> #cfg_task{
	id     = 1150004,
	name   = "我是勇士（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150003}, {level,500,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2203,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150005) -> #cfg_task{
	id     = 1150005,
	name   = "勇士任务（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150004}, {level,510,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2206,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150006) -> #cfg_task{
	id     = 1150006,
	name   = "勇士任务（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150005}, {level,510,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101202,50,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150007) -> #cfg_task{
	id     = 1150007,
	name   = "勇士任务（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150006}, {level,510,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2201,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150008) -> #cfg_task{
	id     = 1150008,
	name   = "勇士任务（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150007}, {level,510,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2206,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150009) -> #cfg_task{
	id     = 1150009,
	name   = "消灭深林护卫",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150008}, {level,520,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101203,50,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,33511943221116,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150010) -> #cfg_task{
	id     = 1150010,
	name   = "偶遇猫猫女",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150009}, {level,520,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2204,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,33511943221116,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150011) -> #cfg_task{
	id     = 1150011,
	name   = "保护猫猫女",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150010}, {level,520,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101205,50,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,33511943221116,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150012) -> #cfg_task{
	id     = 1150012,
	name   = "猫猫女的感谢",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150011}, {level,520,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2204,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,33511943221116,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150013) -> #cfg_task{
	id     = 1150013,
	name   = "拯救人族公主（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150012}, {level,530,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101202,50,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,33511943221116,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150014) -> #cfg_task{
	id     = 1150014,
	name   = "拯救人族公主（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150013}, {level,530,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2202,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,33511943221116,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150015) -> #cfg_task{
	id     = 1150015,
	name   = "拯救人族公主（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150014}, {level,530,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101203,50,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,33511943221116,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150016) -> #cfg_task{
	id     = 1150016,
	name   = "拯救人族公主（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150015}, {level,530,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2202,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,33511943221116,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150017) -> #cfg_task{
	id     = 1150017,
	name   = "精灵女王的求助（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150016}, {level,540,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2205,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150018) -> #cfg_task{
	id     = 1150018,
	name   = "精灵女王的求助（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150017}, {level,540,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101204,50,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150019) -> #cfg_task{
	id     = 1150019,
	name   = "精灵女王的求助（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150018}, {level,540,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2206,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150020) -> #cfg_task{
	id     = 1150020,
	name   = "精灵女王的求助（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150019}, {level,540,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2205,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150021) -> #cfg_task{
	id     = 1150021,
	name   = "消灭毒蝎子（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150020}, {level,550,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2203,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150022) -> #cfg_task{
	id     = 1150022,
	name   = "消灭毒蝎子（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150021}, {level,550,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101205,50,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150023) -> #cfg_task{
	id     = 1150023,
	name   = "消灭毒蝎子（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150022}, {level,550,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2203,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150024) -> #cfg_task{
	id     = 1150024,
	name   = "消灭毒蝎子（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150023}, {level,550,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2205,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150025) -> #cfg_task{
	id     = 1150025,
	name   = "消灭寒冰巨人（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150024}, {level,560,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2206,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150026) -> #cfg_task{
	id     = 1150026,
	name   = "消灭寒冰巨人（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150025}, {level,560,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101206,50,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150027) -> #cfg_task{
	id     = 1150027,
	name   = "消灭寒冰巨人（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150026}, {level,560,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2206,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150028) -> #cfg_task{
	id     = 1150028,
	name   = "消灭寒冰巨人（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150027}, {level,560,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2205,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150029) -> #cfg_task{
	id     = 1150029,
	name   = "消灭魔化怪物（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150028}, {level,570,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2206,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150030) -> #cfg_task{
	id     = 1150030,
	name   = "消灭魔化怪物（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150029}, {level,570,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101206,50,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150031) -> #cfg_task{
	id     = 1150031,
	name   = "消灭魔化怪物（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150030}, {level,570,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2206,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150032) -> #cfg_task{
	id     = 1150032,
	name   = "消灭魔化怪物（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150031}, {level,570,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2204,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150033) -> #cfg_task{
	id     = 1150033,
	name   = "巴特利的恳求（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150032}, {level,580,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2201,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150034) -> #cfg_task{
	id     = 1150034,
	name   = "巴特利的恳求（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150033}, {level,580,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101205,50,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150035) -> #cfg_task{
	id     = 1150035,
	name   = "巴特利的恳求（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150034}, {level,580,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2201,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150036) -> #cfg_task{
	id     = 1150036,
	name   = "巴特利的恳求（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150035}, {level,580,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2201,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150037) -> #cfg_task{
	id     = 1150037,
	name   = "人族公主的磨练（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150036}, {level,590,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2202,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150038) -> #cfg_task{
	id     = 1150038,
	name   = "人族公主的磨练（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150037}, {level,590,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101206,50,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150039) -> #cfg_task{
	id     = 1150039,
	name   = "人族公主的磨练（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150038}, {level,590,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2202,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150040) -> #cfg_task{
	id     = 1150040,
	name   = "人族公主的磨练（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150039}, {level,590,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2205,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150041) -> #cfg_task{
	id     = 1150041,
	name   = "猫猫女的危机（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150040}, {level,600,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2204,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150042) -> #cfg_task{
	id     = 1150042,
	name   = "猫猫女的危机（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150041}, {level,600,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101207,50,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150043) -> #cfg_task{
	id     = 1150043,
	name   = "猫猫女的危机（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150042}, {level,600,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2204,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1150044) -> #cfg_task{
	id     = 1150044,
	name   = "猫猫女的危机（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150043}, {level,600,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2205,0,11012,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151001) -> #cfg_task{
	id     = 1151001,
	name   = "魔法城探索（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1150044}, {level,610,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2301,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151002) -> #cfg_task{
	id     = 1151002,
	name   = "魔法城探索（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151001}, {level,610,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101301,50,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151003) -> #cfg_task{
	id     = 1151003,
	name   = "魔法城探索（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151002}, {level,610,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2302,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151004) -> #cfg_task{
	id     = 1151004,
	name   = "魔法城探索（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151003}, {level,610,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2303,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151005) -> #cfg_task{
	id     = 1151005,
	name   = "城主的邀请（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151004}, {level,620,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2306,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151006) -> #cfg_task{
	id     = 1151006,
	name   = "城主的邀请（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151005}, {level,620,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101302,50,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151007) -> #cfg_task{
	id     = 1151007,
	name   = "城主的邀请（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151006}, {level,620,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2301,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151008) -> #cfg_task{
	id     = 1151008,
	name   = "城主的邀请（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151007}, {level,620,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2306,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151009) -> #cfg_task{
	id     = 1151009,
	name   = "消灭熔岩毒蝎",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151008}, {level,630,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101303,50,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,33511943221116,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151010) -> #cfg_task{
	id     = 1151010,
	name   = "偶遇讨厌的喵",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151009}, {level,630,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2304,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,33511943221116,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151011) -> #cfg_task{
	id     = 1151011,
	name   = "保护讨厌的喵",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151010}, {level,630,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101305,50,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,33511943221116,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151012) -> #cfg_task{
	id     = 1151012,
	name   = "讨厌的喵的道歉",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151011}, {level,630,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2304,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,33511943221116,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151013) -> #cfg_task{
	id     = 1151013,
	name   = "拯救阿丽莎（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151012}, {level,640,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101304,50,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,33511943221116,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151014) -> #cfg_task{
	id     = 1151014,
	name   = "拯救阿丽莎（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151013}, {level,640,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2302,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,33511943221116,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151015) -> #cfg_task{
	id     = 1151015,
	name   = "拯救阿丽莎（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151014}, {level,640,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101303,50,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,33511943221116,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151016) -> #cfg_task{
	id     = 1151016,
	name   = "拯救阿丽莎（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151015}, {level,640,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2302,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,33511943221116,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151017) -> #cfg_task{
	id     = 1151017,
	name   = "耶梦加得的感谢（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151016}, {level,650,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2305,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151018) -> #cfg_task{
	id     = 1151018,
	name   = "耶梦加得的感谢（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151017}, {level,650,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101305,50,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151019) -> #cfg_task{
	id     = 1151019,
	name   = "耶梦加得的感谢（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151018}, {level,650,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2306,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151020) -> #cfg_task{
	id     = 1151020,
	name   = "耶梦加得的感谢（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151019}, {level,650,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2305,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151021) -> #cfg_task{
	id     = 1151021,
	name   = "消灭魔法弓卫（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151020}, {level,660,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2303,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151022) -> #cfg_task{
	id     = 1151022,
	name   = "消灭魔法弓卫（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151021}, {level,660,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101305,50,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151023) -> #cfg_task{
	id     = 1151023,
	name   = "消灭魔法弓卫（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151022}, {level,660,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2303,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151024) -> #cfg_task{
	id     = 1151024,
	name   = "消灭魔法弓卫（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151023}, {level,660,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2305,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151025) -> #cfg_task{
	id     = 1151025,
	name   = "消灭机械巫师（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151024}, {level,670,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2306,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151026) -> #cfg_task{
	id     = 1151026,
	name   = "消灭机械巫师（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151025}, {level,670,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101306,50,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151027) -> #cfg_task{
	id     = 1151027,
	name   = "消灭机械巫师（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151026}, {level,670,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2306,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151028) -> #cfg_task{
	id     = 1151028,
	name   = "消灭机械巫师（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151027}, {level,670,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2305,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151029) -> #cfg_task{
	id     = 1151029,
	name   = "消灭魔化守卫（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151028}, {level,680,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2306,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151030) -> #cfg_task{
	id     = 1151030,
	name   = "消灭魔化守卫（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151029}, {level,680,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101302,50,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151031) -> #cfg_task{
	id     = 1151031,
	name   = "消灭魔化守卫（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151030}, {level,680,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2306,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151032) -> #cfg_task{
	id     = 1151032,
	name   = "消灭魔化守卫（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151031}, {level,680,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2304,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151033) -> #cfg_task{
	id     = 1151033,
	name   = "哈里波波的恳求（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151032}, {level,690,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2301,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151034) -> #cfg_task{
	id     = 1151034,
	name   = "哈里波波的恳求（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151033}, {level,690,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101301,50,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151035) -> #cfg_task{
	id     = 1151035,
	name   = "哈里波波的恳求（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151034}, {level,690,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2301,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151036) -> #cfg_task{
	id     = 1151036,
	name   = "哈里波波的恳求（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151035}, {level,690,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2301,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151037) -> #cfg_task{
	id     = 1151037,
	name   = "阿丽莎的磨练（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151036}, {level,700,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2302,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151038) -> #cfg_task{
	id     = 1151038,
	name   = "阿丽莎的磨练（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151037}, {level,700,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101306,50,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151039) -> #cfg_task{
	id     = 1151039,
	name   = "阿丽莎的磨练（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151038}, {level,700,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2302,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151040) -> #cfg_task{
	id     = 1151040,
	name   = "阿丽莎的磨练（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151039}, {level,700,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2305,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151041) -> #cfg_task{
	id     = 1151041,
	name   = "讨厌的喵的委托（一）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151040}, {level,710,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2304,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151042) -> #cfg_task{
	id     = 1151042,
	name   = "讨厌的喵的委托（二）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151041}, {level,710,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,1101307,50,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151043) -> #cfg_task{
	id     = 1151043,
	name   = "讨厌的喵的委托（三）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151042}, {level,710,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2304,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(1151044) -> #cfg_task{
	id     = 1151044,
	name   = "讨厌的喵的委托（四）",
	type   = 1,
	group  = 0,
	reqs   = [{prev,1151043}, {level,710,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2305,0,11013,1,[]}],
	cost   = [],
	gain   = [{90010002,29734385200690,1},{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(920000) -> #cfg_task{
	id     = 920000,
	name   = "领取环任务",
	type   = 92,
	group  = 0,
	reqs   = [{prev,1106500}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1402,0,11004,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(900000) -> #cfg_task{
	id     = 900000,
	name   = "日常跑环",
	type   = 90,
	group  = 0,
	reqs   = [{prev,920000}, {level,65,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{7,3,20,0,0,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30001) -> #cfg_task{
	id     = 30001,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,920000}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,0,0,11003,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30002) -> #cfg_task{
	id     = 30002,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30001}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,0,0,11003,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30003) -> #cfg_task{
	id     = 30003,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30002}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{9,60001,0,60001,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30004) -> #cfg_task{
	id     = 30004,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30003}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,0,0,11003,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30005) -> #cfg_task{
	id     = 30005,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30004}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,0,0,11003,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30006) -> #cfg_task{
	id     = 30006,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30005}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,0,0,0,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30007) -> #cfg_task{
	id     = 30007,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30006}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,0,0,11003,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30008) -> #cfg_task{
	id     = 30008,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30007}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{9,60002,0,60002,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30009) -> #cfg_task{
	id     = 30009,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30008}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,0,0,11003,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30010) -> #cfg_task{
	id     = 30010,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30009}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,0,0,0,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30011) -> #cfg_task{
	id     = 30011,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30010}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,0,0,11003,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30012) -> #cfg_task{
	id     = 30012,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30011}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{9,60003,0,60003,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30013) -> #cfg_task{
	id     = 30013,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30012}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,0,0,11003,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30014) -> #cfg_task{
	id     = 30014,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30013}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,0,0,0,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30015) -> #cfg_task{
	id     = 30015,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30014}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,0,0,11003,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30016) -> #cfg_task{
	id     = 30016,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30015}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{9,60002,0,60002,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30017) -> #cfg_task{
	id     = 30017,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30016}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,0,0,11003,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30018) -> #cfg_task{
	id     = 30018,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30017}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,0,0,11003,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30019) -> #cfg_task{
	id     = 30019,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30018}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,0,0,11003,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(30020) -> #cfg_task{
	id     = 30020,
	name   = "环任务",
	type   = 3,
	group  = 0,
	reqs   = [{prev,30019}, {level,65,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{9,60001,0,60001,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(920001) -> #cfg_task{
	id     = 920001,
	name   = "领取异兽任务",
	type   = 95,
	group  = 0,
	reqs   = [{prev,0}, {level,350,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1306,0,11003,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(900001) -> #cfg_task{
	id     = 900001,
	name   = "异兽跑环",
	type   = 94,
	group  = 0,
	reqs   = [{prev,920001}, {level,350,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{7,8,10,0,0,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(40001) -> #cfg_task{
	id     = 40001,
	name   = "与帕拉姆对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,920001}, {level,350,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2050101,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40002) -> #cfg_task{
	id     = 40002,
	name   = "击败幻之守卫",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40001}, {level,350,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,15,2,0,1,[]}],
	cost   = [],
	gain   = [{30002,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40003) -> #cfg_task{
	id     = 40003,
	name   = "与波芙对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40002}, {level,350,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2050102,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40004) -> #cfg_task{
	id     = 40004,
	name   = "收集2个森之晶魄",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40003}, {level,350,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,20401202,2,0,1,[]}],
	cost   = [],
	gain   = [{30003,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40005) -> #cfg_task{
	id     = 40005,
	name   = "与普洛托对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40004}, {level,350,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2050103,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40006) -> #cfg_task{
	id     = 40006,
	name   = "与波芙对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40005}, {level,350,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2050102,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40007) -> #cfg_task{
	id     = 40007,
	name   = "击败幻之守卫",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40006}, {level,350,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,15,5,0,1,[]}],
	cost   = [],
	gain   = [{30002,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40008) -> #cfg_task{
	id     = 40008,
	name   = "与普洛托对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40007}, {level,350,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2050103,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40009) -> #cfg_task{
	id     = 40009,
	name   = "与帕拉姆对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40008}, {level,350,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2050101,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40010) -> #cfg_task{
	id     = 40010,
	name   = "收集5个森之晶魄",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40009}, {level,350,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,20401202,5,0,1,[]}],
	cost   = [],
	gain   = [{30003,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(920002) -> #cfg_task{
	id     = 920002,
	name   = "领取异兽任务",
	type   = 97,
	group  = 0,
	reqs   = [{prev,0}, {level,371,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1306,0,11003,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(900002) -> #cfg_task{
	id     = 900002,
	name   = "异兽跑环",
	type   = 96,
	group  = 0,
	reqs   = [{prev,920002}, {level,371,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{7,8,10,0,0,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(40011) -> #cfg_task{
	id     = 40011,
	name   = "与帕拉姆对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,920002}, {level,371,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2051101,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40012) -> #cfg_task{
	id     = 40012,
	name   = "击败幻之守卫",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40011}, {level,371,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,15,2,0,1,[]}],
	cost   = [],
	gain   = [{30002,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40013) -> #cfg_task{
	id     = 40013,
	name   = "与波芙对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40012}, {level,371,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2051102,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40014) -> #cfg_task{
	id     = 40014,
	name   = "收集2个森之晶魄",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40013}, {level,371,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,20501202,2,0,1,[]}],
	cost   = [],
	gain   = [{30003,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40015) -> #cfg_task{
	id     = 40015,
	name   = "与普洛托对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40014}, {level,371,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2051103,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40016) -> #cfg_task{
	id     = 40016,
	name   = "与波芙对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40015}, {level,371,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2051102,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40017) -> #cfg_task{
	id     = 40017,
	name   = "击败幻之守卫",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40016}, {level,371,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,15,5,0,1,[]}],
	cost   = [],
	gain   = [{30002,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40018) -> #cfg_task{
	id     = 40018,
	name   = "与普洛托对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40017}, {level,371,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2051103,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40019) -> #cfg_task{
	id     = 40019,
	name   = "与帕拉姆对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40018}, {level,371,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2051101,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40020) -> #cfg_task{
	id     = 40020,
	name   = "收集5个森之晶魄",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40019}, {level,371,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{19,20501202,5,0,1,[]}],
	cost   = [],
	gain   = [{30003,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(920003) -> #cfg_task{
	id     = 920003,
	name   = "领取异兽任务",
	type   = 97,
	group  = 0,
	reqs   = [{prev,0}, {level,450,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1306,0,11003,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(900003) -> #cfg_task{
	id     = 900003,
	name   = "异兽跑环",
	type   = 96,
	group  = 0,
	reqs   = [{prev,920003}, {level,450,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{7,8,10,0,0,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(40111) -> #cfg_task{
	id     = 40111,
	name   = "与帕拉姆对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,920003}, {level,450,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2051101,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40112) -> #cfg_task{
	id     = 40112,
	name   = "击败幻之守卫",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40111}, {level,450,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,15,2,0,1,[]}],
	cost   = [],
	gain   = [{30002,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40113) -> #cfg_task{
	id     = 40113,
	name   = "与波芙对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40112}, {level,450,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2051102,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40114) -> #cfg_task{
	id     = 40114,
	name   = "击败幻之守卫",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40113}, {level,450,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,15,2,0,1,[]}],
	cost   = [],
	gain   = [{30003,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40115) -> #cfg_task{
	id     = 40115,
	name   = "与普洛托对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40114}, {level,450,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2051101,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40116) -> #cfg_task{
	id     = 40116,
	name   = "与波芙对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40115}, {level,450,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2051102,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40117) -> #cfg_task{
	id     = 40117,
	name   = "击败幻之守卫",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40116}, {level,450,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,15,5,0,1,[]}],
	cost   = [],
	gain   = [{30002,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40118) -> #cfg_task{
	id     = 40118,
	name   = "与普洛托对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40117}, {level,450,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2051101,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40119) -> #cfg_task{
	id     = 40119,
	name   = "与帕拉姆对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40118}, {level,450,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2051102,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40120) -> #cfg_task{
	id     = 40120,
	name   = "击败幻之守卫",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40119}, {level,450,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,15,5,0,1,[]}],
	cost   = [],
	gain   = [{30003,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(920004) -> #cfg_task{
	id     = 920004,
	name   = "领取异兽任务",
	type   = 97,
	group  = 0,
	reqs   = [{prev,0}, {level,520,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1306,0,11003,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(900004) -> #cfg_task{
	id     = 900004,
	name   = "异兽跑环",
	type   = 96,
	group  = 0,
	reqs   = [{prev,920004}, {level,520,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{7,8,10,0,0,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(40211) -> #cfg_task{
	id     = 40211,
	name   = "与帕拉姆对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,920004}, {level,520,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2051301,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40212) -> #cfg_task{
	id     = 40212,
	name   = "击败幻之守卫",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40211}, {level,520,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,15,2,0,1,[]}],
	cost   = [],
	gain   = [{30002,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40213) -> #cfg_task{
	id     = 40213,
	name   = "与波芙对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40212}, {level,520,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2051302,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40214) -> #cfg_task{
	id     = 40214,
	name   = "击败幻之守卫",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40213}, {level,520,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,15,2,0,1,[]}],
	cost   = [],
	gain   = [{30003,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40215) -> #cfg_task{
	id     = 40215,
	name   = "与普洛托对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40214}, {level,520,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2051301,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40216) -> #cfg_task{
	id     = 40216,
	name   = "与波芙对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40215}, {level,520,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2051302,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40217) -> #cfg_task{
	id     = 40217,
	name   = "击败幻之守卫",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40216}, {level,520,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,15,5,0,1,[]}],
	cost   = [],
	gain   = [{30002,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40218) -> #cfg_task{
	id     = 40218,
	name   = "与普洛托对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40217}, {level,520,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2051301,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40219) -> #cfg_task{
	id     = 40219,
	name   = "与帕拉姆对话",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40218}, {level,520,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,2051302,0,0,1,[]}],
	cost   = [],
	gain   = [{30001,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(40220) -> #cfg_task{
	id     = 40220,
	name   = "击败幻之守卫",
	type   = 8,
	group  = 0,
	reqs   = [{prev,40219}, {level,520,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{3,15,5,0,1,[]}],
	cost   = [],
	gain   = [{30003,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(50000) -> #cfg_task{
	id     = 50000,
	name   = "战力达标",
	type   = 5,
	group  = 1,
	reqs   = [{prev,0}, {level,60,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{12,0,120000,0,0,[{link,590,1}]}],
	cost   = [],
	gain   = [{54110,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(50001) -> #cfg_task{
	id     = 50001,
	name   = "战力达标",
	type   = 5,
	group  = 1,
	reqs   = [{prev,0}, {level,60,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{12,0,240000,0,0,[{link,590,1}]}],
	cost   = [],
	gain   = [{54112,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,50000}]
};
find(50002) -> #cfg_task{
	id     = 50002,
	name   = "战力达标",
	type   = 5,
	group  = 1,
	reqs   = [{prev,0}, {level,60,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{12,0,360000,0,0,[{link,590,1}]}],
	cost   = [],
	gain   = [{54110,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,50001}]
};
find(50003) -> #cfg_task{
	id     = 50003,
	name   = "战力达标",
	type   = 5,
	group  = 1,
	reqs   = [{prev,0}, {level,140,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{12,0,480000,0,0,[{link,590,1}]}],
	cost   = [],
	gain   = [{54112,2,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,50002}]
};
find(50050) -> #cfg_task{
	id     = 50050,
	name   = "装备强化",
	type   = 5,
	group  = 2,
	reqs   = [{prev,0}, {level,1,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{13,0,3,0,0,[{phase,1},{level,5},{link,120,1}]}],
	cost   = [],
	gain   = [{90010005,400000,1},{90010004,5000,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1106503}]
};
find(50051) -> #cfg_task{
	id     = 50051,
	name   = "装备强化",
	type   = 5,
	group  = 2,
	reqs   = [{prev,0}, {level,1,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{13,0,5,0,0,[{phase,2},{level,5},{link,120,1}]}],
	cost   = [],
	gain   = [{90010005,400000,1},{90010004,5000,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,50050}]
};
find(51000) -> #cfg_task{
	id     = 51000,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,1107001}, {level,1,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,1},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18001,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1107001}]
};
find(51001) -> #cfg_task{
	id     = 51001,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,5},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18001,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51000}]
};
find(51002) -> #cfg_task{
	id     = 51002,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,8},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18002,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51001}]
};
find(51003) -> #cfg_task{
	id     = 51003,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,12},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18003,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51002}]
};
find(51004) -> #cfg_task{
	id     = 51004,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,16},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{10601,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51003}]
};
find(51005) -> #cfg_task{
	id     = 51005,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,20},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18004,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51004}]
};
find(51006) -> #cfg_task{
	id     = 51006,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,24},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18005,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51005}]
};
find(51007) -> #cfg_task{
	id     = 51007,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,28},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18006,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51006}]
};
find(51008) -> #cfg_task{
	id     = 51008,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,32},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18007,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51007}]
};
find(51009) -> #cfg_task{
	id     = 51009,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,36},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18008,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51008}]
};
find(51010) -> #cfg_task{
	id     = 51010,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,40},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18008,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51009}]
};
find(51011) -> #cfg_task{
	id     = 51011,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,44},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18009,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51010}]
};
find(51012) -> #cfg_task{
	id     = 51012,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,48},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18010,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51011}]
};
find(51013) -> #cfg_task{
	id     = 51013,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,52},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18011,1,1},{90010014,3,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51012}]
};
find(51014) -> #cfg_task{
	id     = 51014,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,56},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18012,1,1},{90010014,3,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51013}]
};
find(51015) -> #cfg_task{
	id     = 51015,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,60},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18012,1,1},{90010014,3,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51014}]
};
find(51016) -> #cfg_task{
	id     = 51016,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,64},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18013,1,1},{90010014,3,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51015}]
};
find(51017) -> #cfg_task{
	id     = 51017,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,68},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18014,1,1},{90010014,4,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51016}]
};
find(51018) -> #cfg_task{
	id     = 51018,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,72},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18015,1,1},{90010014,4,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51017}]
};
find(51019) -> #cfg_task{
	id     = 51019,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,76},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18016,1,1},{90010014,4,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51018}]
};
find(51020) -> #cfg_task{
	id     = 51020,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,80},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18016,1,1},{90010014,4,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51019}]
};
find(51021) -> #cfg_task{
	id     = 51021,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,84},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18017,1,1},{90010014,5,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51020}]
};
find(51022) -> #cfg_task{
	id     = 51022,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,88},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18018,1,1},{90010014,5,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51021}]
};
find(51023) -> #cfg_task{
	id     = 51023,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,92},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18019,1,1},{90010014,5,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51022}]
};
find(51024) -> #cfg_task{
	id     = 51024,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,96},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18020,1,1},{90010014,5,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51023}]
};
find(51025) -> #cfg_task{
	id     = 51025,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,100},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18020,1,1},{90010014,5,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51024}]
};
find(51026) -> #cfg_task{
	id     = 51026,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,104},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18021,1,1},{90010014,5,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51025}]
};
find(51027) -> #cfg_task{
	id     = 51027,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,108},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18022,1,1},{90010014,5,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51026}]
};
find(51028) -> #cfg_task{
	id     = 51028,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,112},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18023,1,1},{90010014,5,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51027}]
};
find(51029) -> #cfg_task{
	id     = 51029,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,116},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18024,1,1},{90010014,6,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51028}]
};
find(51030) -> #cfg_task{
	id     = 51030,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,120},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18024,1,1},{90010014,6,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51029}]
};
find(51031) -> #cfg_task{
	id     = 51031,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,124},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18025,1,1},{90010014,6,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51030}]
};
find(51032) -> #cfg_task{
	id     = 51032,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,128},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18026,1,1},{90010014,6,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51031}]
};
find(51033) -> #cfg_task{
	id     = 51033,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,132},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18027,1,1},{90010014,6,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51032}]
};
find(51034) -> #cfg_task{
	id     = 51034,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,136},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18028,1,1},{90010014,6,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51033}]
};
find(51035) -> #cfg_task{
	id     = 51035,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,140},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18028,1,1},{90010014,6,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51034}]
};
find(51036) -> #cfg_task{
	id     = 51036,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,144},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18029,1,1},{90010014,6,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51035}]
};
find(51037) -> #cfg_task{
	id     = 51037,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,148},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18030,1,1},{90010014,6,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51036}]
};
find(51038) -> #cfg_task{
	id     = 51038,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,152},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18031,1,1},{90010014,6,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51037}]
};
find(51039) -> #cfg_task{
	id     = 51039,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,156},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18032,1,1},{90010014,6,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51038}]
};
find(51040) -> #cfg_task{
	id     = 51040,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,160},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18032,1,1},{90010014,6,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51039}]
};
find(51041) -> #cfg_task{
	id     = 51041,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,164},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18033,1,1},{90010014,7,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51040}]
};
find(51042) -> #cfg_task{
	id     = 51042,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,168},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18034,1,1},{90010014,7,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51041}]
};
find(51043) -> #cfg_task{
	id     = 51043,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,172},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18035,1,1},{90010014,7,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51042}]
};
find(51044) -> #cfg_task{
	id     = 51044,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,176},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18036,1,1},{90010014,7,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51043}]
};
find(51045) -> #cfg_task{
	id     = 51045,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,180},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18036,1,1},{90010014,7,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51044}]
};
find(51046) -> #cfg_task{
	id     = 51046,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,184},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18037,1,1},{90010014,7,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51045}]
};
find(51047) -> #cfg_task{
	id     = 51047,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,188},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18038,1,1},{90010014,7,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51046}]
};
find(51048) -> #cfg_task{
	id     = 51048,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,192},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18039,1,1},{90010014,7,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51047}]
};
find(51049) -> #cfg_task{
	id     = 51049,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,196},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18040,1,1},{90010014,7,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51048}]
};
find(51050) -> #cfg_task{
	id     = 51050,
	name   = "魔法塔",
	type   = 5,
	group  = 3,
	reqs   = [{prev,0}, {level,70,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,303,1,30001,1,[{floor,200},{link,150,1,1,1}]}],
	cost   = [],
	gain   = [{18040,1,1},{90010014,7,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,51049}]
};
find(52051) -> #cfg_task{
	id     = 52051,
	name   = "经验副本",
	type   = 5,
	group  = 4,
	reqs   = [{prev,0}, {level,999,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{4,301,1,0,0,[{exp,10000000000},{link,150,1,1,2}]}],
	cost   = [],
	gain   = [{10015,1,1},{10800,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(52052) -> #cfg_task{
	id     = 52052,
	name   = "经验副本",
	type   = 5,
	group  = 4,
	reqs   = [{prev,0}, {level,999,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{4,301,1,0,0,[{exp,35000000000},{link,150,1,1,2}]}],
	cost   = [],
	gain   = [{10015,1,1},{10800,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(52100) -> #cfg_task{
	id     = 52100,
	name   = "击败4阶首领",
	type   = 5,
	group  = 5,
	reqs   = [{prev,1113001}, {level,999,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{3,3,1,0,0,[{level,130},{boss_type, 1},{link,160,1,1,1,20000001}]}],
	cost   = [],
	gain   = [{14014,5,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1113001}]
};
find(52151) -> #cfg_task{
	id     = 52151,
	name   = "日常活跃",
	type   = 5,
	group  = 6,
	reqs   = [{prev,1111506}, {level,115,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{25,1,130,0,0,[{link,270,1,1}]}],
	cost   = [],
	gain   = [{90010004,5000,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1111506}]
};
find(52203) -> #cfg_task{
	id     = 52203,
	name   = "通关斗士之路4层",
	type   = 5,
	group  = 7,
	reqs   = [{prev,0}, {level,230,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,304,0,30201,1,[{dunge,30204},{link,150,1,2,1}]}],
	cost   = [],
	gain   = [{14004,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(52204) -> #cfg_task{
	id     = 52204,
	name   = "通关斗士之路5层",
	type   = 5,
	group  = 7,
	reqs   = [{prev,0}, {level,280,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,304,0,30201,1,[{dunge,30205},{link,150,1,2,1}]}],
	cost   = [],
	gain   = [{14005,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,52203}]
};
find(52205) -> #cfg_task{
	id     = 52205,
	name   = "通关斗士之路6层",
	type   = 5,
	group  = 7,
	reqs   = [{prev,0}, {level,330,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,304,0,30201,1,[{dunge,30206},{link,150,1,2,1}]}],
	cost   = [],
	gain   = [{14006,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,52204}]
};
find(52350) -> #cfg_task{
	id     = 52350,
	name   = "好友",
	type   = 5,
	group  = 0,
	reqs   = [{prev,0}, {level,150,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{26,0,3,0,0,[{link,281,1}]}],
	cost   = [],
	gain   = [{11135,5,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(52400) -> #cfg_task{
	id     = 52400,
	name   = "市场",
	type   = 5,
	group  = 0,
	reqs   = [{prev,0}, {level,9999,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{30,0,1,0,0,[{link,250,1}]}],
	cost   = [],
	gain   = [{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(52450) -> #cfg_task{
	id     = 52450,
	name   = "加入公会",
	type   = 5,
	group  = 0,
	reqs   = [{prev,0}, {level,86,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{28,0,1,0,0,[{link,210,1}]}],
	cost   = [],
	gain   = [{11106,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(52600) -> #cfg_task{
	id     = 52600,
	name   = "公会仓库捐献",
	type   = 5,
	group  = 0,
	reqs   = [{prev,52100}, {level,120,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{31,0,1,0,0,[{link,210,1,3}]}],
	cost   = [],
	gain   = [{90010005,200000,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,52100}]
};
find(52650) -> #cfg_task{
	id     = 52650,
	name   = "宠物融合",
	type   = 5,
	group  = 0,
	reqs   = [{prev,1125004}, {level,1,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{33,6,1,0,0,[{link,860,1,4}]}],
	cost   = [],
	gain   = [{40100504,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1125004}]
};
find(52700) -> #cfg_task{
	id     = 52700,
	name   = "进阶副本风",
	type   = 5,
	group  = 9,
	reqs   = [{prev,1120002}, {level,200,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,308,1,30402,1,[{dunge,30401},{link,150,1,1,3}]}],
	cost   = [],
	gain   = [{55006,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(52701) -> #cfg_task{
	id     = 52701,
	name   = "进阶副本火",
	type   = 5,
	group  = 9,
	reqs   = [{prev,0}, {level,200,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{9,308,1,30403,1,[{dunge,30402},{link,150,1,1,3}]}],
	cost   = [],
	gain   = [{55008,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,52700}]
};
find(52751) -> #cfg_task{
	id     = 52751,
	name   = "魔兽攻城",
	type   = 5,
	group  = 0,
	reqs   = [{prev,1124005}, {level,240,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{10,310,2,0,0,[{link,150,1,2,2}]}],
	cost   = [],
	gain   = [{90010020,500,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1124005}]
};
find(52752) -> #cfg_task{
	id     = 52752,
	name   = "魔兽攻城",
	type   = 5,
	group  = 0,
	reqs   = [{prev,52751}, {level,290,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{10,310,1,80003,1,[{dunge,80003},{link,150,1,2,2}]}],
	cost   = [],
	gain   = [{15045,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,52751}]
};
find(52753) -> #cfg_task{
	id     = 52753,
	name   = "魔兽攻城",
	type   = 5,
	group  = 0,
	reqs   = [{prev,52752}, {level,350,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{10,310,1,80004,1,[{dunge,80004},{link,150,1,2,2}]}],
	cost   = [],
	gain   = [{15046,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,52752}]
};
find(52754) -> #cfg_task{
	id     = 52754,
	name   = "魔兽攻城",
	type   = 5,
	group  = 0,
	reqs   = [{prev,52753}, {level,410,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{10,310,1,80005,1,[{dunge,80005},{link,150,1,2,2}]}],
	cost   = [],
	gain   = [{15047,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,52753}]
};
find(52755) -> #cfg_task{
	id     = 52755,
	name   = "魔兽攻城",
	type   = 5,
	group  = 0,
	reqs   = [{prev,52754}, {level,470,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{10,310,1,80006,1,[{dunge,80006},{link,150,1,2,2}]}],
	cost   = [],
	gain   = [{15048,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,52754}]
};
find(52756) -> #cfg_task{
	id     = 52756,
	name   = "魔兽攻城",
	type   = 5,
	group  = 0,
	reqs   = [{prev,52755}, {level,520,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{10,310,1,80007,1,[{dunge,80007},{link,150,1,2,2}]}],
	cost   = [],
	gain   = [{15049,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,52755}]
};
find(52850) -> #cfg_task{
	id     = 52850,
	name   = "远古遗迹",
	type   = 5,
	group  = 0,
	reqs   = [{prev,1127005}, {level,260,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{3,3,1,0,0,[{level,260},{boss_type, 3},{link,160,1,1,3}]}],
	cost   = [],
	gain   = [{100050,10,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1127005}]
};
find(52851) -> #cfg_task{
	id     = 52851,
	name   = "魂卡寻宝",
	type   = 5,
	group  = 0,
	reqs   = [{prev,1113004}, {level,220,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{39,0,1,0,0,[{link,230,1}]}],
	cost   = [],
	gain   = [{100050,10,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(52901) -> #cfg_task{
	id     = 52901,
	name   = "扫荡电磁魔物",
	type   = 5,
	group  = 0,
	reqs   = [{prev,1106207}, {level,60,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{3,1100403,15,11004,1,[]}],
	cost   = [],
	gain   = [{[11030814,12030814],1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1106207}]
};
find(52902) -> #cfg_task{
	id     = 52902,
	name   = "扫荡电磁魔物",
	type   = 5,
	group  = 0,
	reqs   = [{prev,1109003}, {level,90,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{3,1100411,20,11004,1,[]}],
	cost   = [],
	gain   = [{[11040714,12040714],1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1109003}]
};
find(52904) -> #cfg_task{
	id     = 52904,
	name   = "扫荡雪原魔物",
	type   = 5,
	group  = 0,
	reqs   = [{prev,1110501}, {level,105,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{3,1100502,20,11005,1,[]}],
	cost   = [],
	gain   = [{[11040814,12040814],1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1110501}]
};
find(52905) -> #cfg_task{
	id     = 52905,
	name   = "扫荡雪原魔物",
	type   = 5,
	group  = 0,
	reqs   = [{prev,1111502}, {level,115,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{3,1100506,25,11005,1,[]}],
	cost   = [],
	gain   = [{[11050714,12050714],1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1111502}]
};
find(52906) -> #cfg_task{
	id     = 52906,
	name   = "扫荡雪原魔物",
	type   = 5,
	group  = 0,
	reqs   = [{prev,1113001}, {level,130,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{3,1100505,30,11005,1,[]}],
	cost   = [],
	gain   = [{[11050914,12050914],1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1113001}]
};
find(52909) -> #cfg_task{
	id     = 52909,
	name   = "扫荡海族魔物",
	type   = 5,
	group  = 0,
	reqs   = [{prev,1115003}, {level,150,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{3,1100702,35,11007,1,[]}],
	cost   = [],
	gain   = [{[11060714,12060714],1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1115003}]
};
find(52910) -> #cfg_task{
	id     = 52910,
	name   = "扫荡海族魔物",
	type   = 5,
	group  = 0,
	reqs   = [{prev,1117001}, {level,170,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{3,1100704,35,11007,1,[]}],
	cost   = [],
	gain   = [{[11060814,12060814],1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1117001}]
};
find(53200) -> #cfg_task{
	id     = 53200,
	name   = "乱斗战场",
	type   = 5,
	group  = 0,
	reqs   = [{prev,0}, {level,230,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{67,103,1,0,0,[{link,311,1}]}],
	cost   = [],
	gain   = [{52001,3,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(53201) -> #cfg_task{
	id     = 53201,
	name   = "晚宴明星",
	type   = 5,
	group  = 0,
	reqs   = [{prev,0}, {level,250,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{67,105,1,0,0,[{link,210,1,1}]}],
	cost   = [],
	gain   = [{10652,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(53202) -> #cfg_task{
	id     = 53202,
	name   = "全服制霸",
	type   = 5,
	group  = 0,
	reqs   = [{prev,0}, {level,240,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{67,102,1,0,0,[{link,210,1,5}]}],
	cost   = [],
	gain   = [{10652,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(53203) -> #cfg_task{
	id     = 53203,
	name   = "勇者圣坛",
	type   = 5,
	group  = 0,
	reqs   = [{prev,0}, {level,270,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{67,109,1,0,0,[{link,571,1}]}],
	cost   = [],
	gain   = [{51001,3,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(53204) -> #cfg_task{
	id     = 53204,
	name   = "巅峰1v1",
	type   = 5,
	group  = 0,
	reqs   = [{prev,0}, {level,260,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{67,108,1,0,0,[{link,570,1}]}],
	cost   = [],
	gain   = [{15067,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(54200) -> #cfg_task{
	id     = 54200,
	name   = "更好的装备",
	type   = 5,
	group  = 0,
	reqs   = [{prev,0}, {level,120,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{6,0,4,0,0,[{quality,5},{order,4},{link,[{160,1,1,1},{150,2,2,1},{210,3,3}]}]}],
	cost   = [],
	gain   = [{11040314,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(54201) -> #cfg_task{
	id     = 54201,
	name   = "更好的装备",
	type   = 5,
	group  = 0,
	reqs   = [{prev,0}, {level,150,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{6,0,5,0,0,[{quality,5},{order,5},{link,[{160,1,1,1},{160,5,1,2},{150,2,2,1},{210,3,3}]}]}],
	cost   = [],
	gain   = [{[11050215,12050215],1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,54200}]
};
find(54202) -> #cfg_task{
	id     = 54202,
	name   = "更好的装备",
	type   = 5,
	group  = 0,
	reqs   = [{prev,0}, {level,150,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{6,0,3,0,0,[{quality,6},{order,5},{link,[{160,1,1,1},{160,5,1,2},{150,2,2,1},{210,3,3}]}]}],
	cost   = [],
	gain   = [{[11050215,12050215],1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,54201}]
};
find(54203) -> #cfg_task{
	id     = 54203,
	name   = "更好的装备",
	type   = 5,
	group  = 0,
	reqs   = [{prev,0}, {level,180,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{6,0,3,0,0,[{quality,6},{order,6},{link,[{160,1,1,1},{160,5,1,2},{150,2,2,1},{210,3,3},{250,1}]}]}],
	cost   = [],
	gain   = [{11050315,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,54202}]
};
find(54204) -> #cfg_task{
	id     = 54204,
	name   = "更好的装备",
	type   = 5,
	group  = 0,
	reqs   = [{prev,0}, {level,240,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{24,1,1,0,0,[{quality,0},{level,0},{link,[{170,1,1,101,1},{160,1,1,1},{160,5,1,2},{250,1}]}]}],
	cost   = [],
	gain   = [{90010004,5000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(54301) -> #cfg_task{
	id     = 54301,
	name   = "装备洗练",
	type   = 5,
	group  = 10,
	reqs   = [{prev,1129002}, {level,1,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{73,0,5,0,0,[{link,120,4}]}],
	cost   = [],
	gain   = [{13118,5,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1129002}]
};
find(54302) -> #cfg_task{
	id     = 54302,
	name   = "装备洗练",
	type   = 5,
	group  = 10,
	reqs   = [{prev,0}, {level,250,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{73,4,1,0,0,[{link,120,4}]}],
	cost   = [],
	gain   = [{13115,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,54301}]
};
find(54303) -> #cfg_task{
	id     = 54303,
	name   = "装备洗练",
	type   = 5,
	group  = 10,
	reqs   = [{prev,0}, {level,250,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{73,5,1,0,0,[{link,120,4}]}],
	cost   = [],
	gain   = [{13116,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,54302}]
};
find(54401) -> #cfg_task{
	id     = 54401,
	name   = "装备铸造",
	type   = 5,
	group  = 11,
	reqs   = [{prev,0}, {level,1,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{74,1,1,0,0,[{link,120,1,1,5,5}]}],
	cost   = [],
	gain   = [{15151,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1128003}]
};
find(54501) -> #cfg_task{
	id     = 54501,
	name   = "异兽助战",
	type   = 5,
	group  = 12,
	reqs   = [{prev,1135001}, {level,1,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{75,1,1,0,0,[{link,300,1,1}]}],
	cost   = [],
	gain   = [{30002,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1135001}]
};
find(54502) -> #cfg_task{
	id     = 54502,
	name   = "异兽助战",
	type   = 5,
	group  = 12,
	reqs   = [{prev,0}, {level,350,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{75,4,1,0,0,[{link,300,1,1}]}],
	cost   = [],
	gain   = [{30002,2,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,54501}]
};
find(54503) -> #cfg_task{
	id     = 54503,
	name   = "异兽助战",
	type   = 5,
	group  = 12,
	reqs   = [{prev,0}, {level,350,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{75,8,1,0,0,[{link,300,1,1}]}],
	cost   = [],
	gain   = [{30002,3,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,54502}]
};
find(54504) -> #cfg_task{
	id     = 54504,
	name   = "经验副本",
	type   = 5,
	group  = 4,
	reqs   = [{prev,1110503}, {level,105,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{10,301,3,0,0,[{link,150,1,1,2}]}],
	cost   = [],
	gain   = [{10015,1,1},{10800,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1110503}]
};
find(54505) -> #cfg_task{
	id     = 54505,
	name   = "世界首领",
	type   = 5,
	group  = 4,
	reqs   = [{prev,0}, {level,145,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{3,3,3,0,0,[{level,90},{boss_type, 1},{link,160,1,1,1}]}],
	cost   = [],
	gain   = [{13135,3},{11128,5}],
	quick  = [],
	time   = 0,
	show   = []
};
find(54506) -> #cfg_task{
	id     = 54506,
	name   = "装备副本",
	type   = 5,
	group  = 4,
	reqs   = [{prev,1111003}, {level,100,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{10,304,2,0,0,[{link,150,1,2,1}]}],
	cost   = [],
	gain   = [{10015,1,1},{10800,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1111003}]
};
find(54507) -> #cfg_task{
	id     = 54507,
	name   = "竞技场",
	type   = 5,
	group  = 4,
	reqs   = [{prev,1111504}, {level,115,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{10,309,5,0,0,[{link,310,1,1}]}],
	cost   = [],
	gain   = [{10015,1,1},{10800,1,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,1111504}]
};
find(55101) -> #cfg_task{
	id     = 55101,
	name   = "经验副本",
	type   = 10,
	group  = 13,
	reqs   = [{prev,0}, {level,105,9999} | [{opdays,2}]],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{10,301,2,0,0,[{link,150,1,1,2}]}],
	cost   = [],
	gain   = [{10800,1,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(55201) -> #cfg_task{
	id     = 55201,
	name   = "竞技场",
	type   = 10,
	group  = 13,
	reqs   = [{prev,0}, {level,115,9999} | [{opdays,2}]],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{10,309,5,0,0,[{link,310,1,1}]}],
	cost   = [],
	gain   = [{10800,1,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,55101}]
};
find(55301) -> #cfg_task{
	id     = 55301,
	name   = "贪婪洞窟",
	type   = 10,
	group  = 13,
	reqs   = [{prev,0}, {level,220,9999} | [{opdays,2}]],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{10,302,2,0,0,[{link,150,1,1,4}]}],
	cost   = [],
	gain   = [{10000,1,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,55201}]
};
find(55401) -> #cfg_task{
	id     = 55401,
	name   = "装备副本",
	type   = 10,
	group  = 13,
	reqs   = [{prev,0}, {level,140,9999} | [{opdays,2}]],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{10,304,2,0,0,[{link,150,1,2,1}]}],
	cost   = [],
	gain   = [{10000,1,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,55301}]
};
find(55501) -> #cfg_task{
	id     = 55501,
	name   = "家园首领",
	type   = 10,
	group  = 13,
	reqs   = [{prev,0}, {level,140,9999} | [{opdays,2}]],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{3,3,1,0,0,[{level,90},{boss_type, 2},{link,160,1,1,2}]}],
	cost   = [],
	gain   = [{10000,1,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,55401}]
};
find(55601) -> #cfg_task{
	id     = 55601,
	name   = "魔兽城堡",
	type   = 10,
	group  = 13,
	reqs   = [{prev,0}, {level,240,9999} | [{opdays,4}]],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{3,3,1,0,0,[{level,10},{boss_type, 4},{link,160,1,3,1}]}],
	cost   = [],
	gain   = [{10000,1,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,55501}]
};
find(55701) -> #cfg_task{
	id     = 55701,
	name   = "远古遗迹",
	type   = 10,
	group  = 13,
	reqs   = [{prev,0}, {level,270,9999} | [{opdays,4}]],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{3,3,1,0,0,[{level,10},{boss_type, 3},{link,160,1,1,3}]}],
	cost   = [],
	gain   = [{10000,1,1},{90010005,100000,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,55601}]
};
find(930000) -> #cfg_task{
	id     = 930000,
	name   = "领取公会令",
	type   = 93,
	group  = 0,
	reqs   = [{prev,0}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{2,1306,0,11003,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(910000) -> #cfg_task{
	id     = 910000,
	name   = "公会令",
	type   = 91,
	group  = 0,
	reqs   = [{prev,930000}, {level,150,9999} | [guild]],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{7,4,40,0,0,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000001) -> #cfg_task{
	id     = 4000001,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,930000}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,1,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000002) -> #cfg_task{
	id     = 4000002,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000001}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,1,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000003) -> #cfg_task{
	id     = 4000003,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000002}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,1,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000004) -> #cfg_task{
	id     = 4000004,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000003}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,1,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000005) -> #cfg_task{
	id     = 4000005,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000004}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,1,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000006) -> #cfg_task{
	id     = 4000006,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000005}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,1,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000007) -> #cfg_task{
	id     = 4000007,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000006}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,1,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000008) -> #cfg_task{
	id     = 4000008,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000007}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,1,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000009) -> #cfg_task{
	id     = 4000009,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000008}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,1,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000010) -> #cfg_task{
	id     = 4000010,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000009}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,1,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000011) -> #cfg_task{
	id     = 4000011,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000010}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,2,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000012) -> #cfg_task{
	id     = 4000012,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000011}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,2,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000013) -> #cfg_task{
	id     = 4000013,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000012}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,2,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000014) -> #cfg_task{
	id     = 4000014,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000013}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,2,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000015) -> #cfg_task{
	id     = 4000015,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000014}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,2,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000016) -> #cfg_task{
	id     = 4000016,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000015}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,2,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000017) -> #cfg_task{
	id     = 4000017,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000016}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,2,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000018) -> #cfg_task{
	id     = 4000018,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000017}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,2,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000019) -> #cfg_task{
	id     = 4000019,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000018}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,2,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000020) -> #cfg_task{
	id     = 4000020,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000019}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,2,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000021) -> #cfg_task{
	id     = 4000021,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000020}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,3,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000022) -> #cfg_task{
	id     = 4000022,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000021}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,3,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000023) -> #cfg_task{
	id     = 4000023,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000022}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,3,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000024) -> #cfg_task{
	id     = 4000024,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000023}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,3,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000025) -> #cfg_task{
	id     = 4000025,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000024}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,3,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000026) -> #cfg_task{
	id     = 4000026,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000025}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,3,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000027) -> #cfg_task{
	id     = 4000027,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000026}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,3,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000028) -> #cfg_task{
	id     = 4000028,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000027}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,3,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000029) -> #cfg_task{
	id     = 4000029,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000028}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,3,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000030) -> #cfg_task{
	id     = 4000030,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000029}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,3,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000031) -> #cfg_task{
	id     = 4000031,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000030}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,4,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000032) -> #cfg_task{
	id     = 4000032,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000031}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,4,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000033) -> #cfg_task{
	id     = 4000033,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000032}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,4,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000034) -> #cfg_task{
	id     = 4000034,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000033}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,4,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000035) -> #cfg_task{
	id     = 4000035,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000034}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,4,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000036) -> #cfg_task{
	id     = 4000036,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000035}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,4,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000037) -> #cfg_task{
	id     = 4000037,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000036}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,4,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000038) -> #cfg_task{
	id     = 4000038,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000037}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,4,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000039) -> #cfg_task{
	id     = 4000039,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000038}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{81,0,0,4,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(4000040) -> #cfg_task{
	id     = 4000040,
	name   = "公会令",
	type   = 4,
	group  = 0,
	reqs   = [{prev,4000039}, {level,150,9999} | [guild]],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{82,0,0,4,1,[]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(60101) -> #cfg_task{
	id     = 60101,
	name   = "等级提升",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,150,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{1,0,150,0,1,[{link,150,1,1,2}]}],
	cost   = [],
	gain   = [{10015,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60102) -> #cfg_task{
	id     = 60102,
	name   = "魔法塔",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,150,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{9,303,8,30001,1,[]}],
	cost   = [],
	gain   = [{15067,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60103) -> #cfg_task{
	id     = 60103,
	name   = "魔物清扫",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,150,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{3,1100402,35,11004,1,[]}],
	cost   = [],
	gain   = [{11140,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60104) -> #cfg_task{
	id     = 60104,
	name   = "前辈的指导",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,150,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{2,1302,0,11003,1,[]}],
	cost   = [],
	gain   = [{10500,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60105) -> #cfg_task{
	id     = 60105,
	name   = "等级提升",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,160,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{1,0,160,0,1,[{link,150,1,1,2}]}],
	cost   = [],
	gain   = [{11120,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60106) -> #cfg_task{
	id     = 60106,
	name   = "国王的考验",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,160,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{2,1304,0,11003,1,[]}],
	cost   = [],
	gain   = [{11120,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60107) -> #cfg_task{
	id     = 60107,
	name   = "材料(离线/在线)",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,160,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{5,12001,20,0,0,[]}],
	cost   = [{12001,20}],
	gain   = [{11120,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60108) -> #cfg_task{
	id     = 60108,
	name   = "觉醒副本",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,160,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{9,70001,0,70001,1,[]}],
	cost   = [],
	gain   = [{46130,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60201) -> #cfg_task{
	id     = 60201,
	name   = "等级提升",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,220,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{1,0,220,0,1,[{link,150,1,1,2}]}],
	cost   = [],
	gain   = [{50000,5,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60202) -> #cfg_task{
	id     = 60202,
	name   = "前辈的指导",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,220,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{2,1302,0,11003,1,[]}],
	cost   = [],
	gain   = [{15067,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60203) -> #cfg_task{
	id     = 60203,
	name   = "魔物清扫",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,220,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{3,1100501,60,11005,1,[]}],
	cost   = [],
	gain   = [{54110,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60204) -> #cfg_task{
	id     = 60204,
	name   = "魔法塔",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,220,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{9,303,18,30001,1,[]}],
	cost   = [],
	gain   = [{11140,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60205) -> #cfg_task{
	id     = 60205,
	name   = "等级提升",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,230,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{1,0,230,0,1,[{link,150,1,1,2}]}],
	cost   = [],
	gain   = [{55000,5,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60206) -> #cfg_task{
	id     = 60206,
	name   = "国王的考验",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,230,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{2,1304,0,11003,1,[]}],
	cost   = [],
	gain   = [{15067,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60207) -> #cfg_task{
	id     = 60207,
	name   = "材料(离线/在线)",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,230,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{5,12002,20,0,0,[]}],
	cost   = [{12002,20}],
	gain   = [{11120,2,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60208) -> #cfg_task{
	id     = 60208,
	name   = "觉醒副本",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,230,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{9,70002,0,70001,1,[]}],
	cost   = [],
	gain   = [{55006,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60301) -> #cfg_task{
	id     = 60301,
	name   = "等级提升",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,280,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{1,0,280,0,1,[{link,150,1,1,2}]}],
	cost   = [],
	gain   = [{55402,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60302) -> #cfg_task{
	id     = 60302,
	name   = "贪婪洞窟",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,280,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{9,302,1,30102,1,[{floor,4},{link,150,1,1,4}]}],
	cost   = [],
	gain   = [{55402,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60303) -> #cfg_task{
	id     = 60303,
	name   = "前辈的指导",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,280,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{2,1302,0,11003,1,[]}],
	cost   = [],
	gain   = [{55402,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60304) -> #cfg_task{
	id     = 60304,
	name   = "材料(离线/在线)",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,280,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{5,12003,20,0,0,[]}],
	cost   = [{12003,20}],
	gain   = [{55402,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60305) -> #cfg_task{
	id     = 60305,
	name   = "材料(离线/在线)",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,280,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{5,12004,20,0,0,[]}],
	cost   = [{12004,20}],
	gain   = [{55402,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60306) -> #cfg_task{
	id     = 60306,
	name   = "魔法塔",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,280,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{9,303,32,30001,1,[]}],
	cost   = [],
	gain   = [{55402,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60307) -> #cfg_task{
	id     = 60307,
	name   = "魔兽攻城",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,280,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{10,310,1,80003,1,[{dunge,80003},{link,150,1,2,2,80003}]}],
	cost   = [],
	gain   = [{55402,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60308) -> #cfg_task{
	id     = 60308,
	name   = "觉醒副本",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,300,9999} | []],
	accept = false,
	submit = false,
	quest  = [],
	goals  = [{9,70003,0,70001,1,[]}],
	cost   = [],
	gain   = [{55402,1,1}],
	quick  = [],
	time   = 0,
	show   = []
};
find(60029) -> #cfg_task{
	id     = 60029,
	name   = "一次觉醒",
	type   = 6,
	group  = 0,
	reqs   = [{prev,0}, {level,150,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{15,1,0,11003,1,[{link,600,1}]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = []
};
find(60030) -> #cfg_task{
	id     = 60030,
	name   = "二次觉醒",
	type   = 6,
	group  = 0,
	reqs   = [{prev,60029}, {level,220,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{15,2,0,11003,1,[{link,600,1}]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = [{prev,60029}]
};
find(60031) -> #cfg_task{
	id     = 60031,
	name   = "三次觉醒",
	type   = 6,
	group  = 0,
	reqs   = [{prev,60030}, {level,280,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{15,3,0,11003,1,[{link,600,1}]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = [{prev,60030}]
};
find(60032) -> #cfg_task{
	id     = 60032,
	name   = "四次觉醒",
	type   = 6,
	group  = 0,
	reqs   = [{prev,60031}, {level,350,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{15,4,0,11003,1,[{link,600,1}]}],
	cost   = [],
	gain   = [{90010025,10,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,60031}]
};
find(60033) -> #cfg_task{
	id     = 60033,
	name   = "五次觉醒（一）",
	type   = 6,
	group  = 0,
	reqs   = [{prev,60032}, {level,500,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{15,4,0,11003,1,[{link,600,1}]}],
	cost   = [],
	gain   = [{90010025,10,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,60032}]
};
find(60034) -> #cfg_task{
	id     = 60034,
	name   = "五次觉醒（二）",
	type   = 6,
	group  = 0,
	reqs   = [{prev,60033}, {level,540,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{15,4,0,11003,1,[{link,600,1}]}],
	cost   = [],
	gain   = [{90010025,10,1}],
	quick  = [],
	time   = 0,
	show   = [{prev,60033}]
};
find(60035) -> #cfg_task{
	id     = 60035,
	name   = "六次觉醒（一）",
	type   = 6,
	group  = 0,
	reqs   = [{prev,60034}, {level,600,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{15,4,0,11003,1,[{link,600,1}]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = [{prev,60034}]
};
find(60036) -> #cfg_task{
	id     = 60036,
	name   = "六次觉醒（二）",
	type   = 6,
	group  = 0,
	reqs   = [{prev,60035}, {level,610,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{15,4,0,11003,1,[{link,600,1}]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = [{prev,60035}]
};
find(60037) -> #cfg_task{
	id     = 60037,
	name   = "六次觉醒（三）",
	type   = 6,
	group  = 0,
	reqs   = [{prev,60036}, {level,620,9999} | []],
	accept = true,
	submit = true,
	quest  = [],
	goals  = [{15,4,0,11003,1,[{link,600,1}]}],
	cost   = [],
	gain   = [],
	quick  = [],
	time   = 0,
	show   = [{prev,60036}]
};
find(90001) -> #cfg_task{
	id     = 90001,
	name   = "击杀首领之家首领3只",
	type   = 9,
	group  = 0,
	reqs   = [{prev,0}, {level,200,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{3,3,3,0,0,[{level,90},{boss_type, 2},{link,160,1,1,2}]}],
	cost   = [],
	gain   = [{13135,2},{11128,5}],
	quick  = [],
	time   = 0,
	show   = []
};
find(90002) -> #cfg_task{
	id     = 90002,
	name   = "击杀世界首领2只",
	type   = 9,
	group  = 0,
	reqs   = [{prev,0}, {level,200,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{3,3,2,0,0,[{level,90},{boss_type, 1},{link,160,1,1,1}]}],
	cost   = [],
	gain   = [{13135,3},{11128,5}],
	quick  = [],
	time   = 0,
	show   = []
};
find(90003) -> #cfg_task{
	id     = 90003,
	name   = "通关情侣副本2次",
	type   = 9,
	group  = 0,
	reqs   = [{prev,0}, {level,200,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{10,313,2,30103,1,[{link,1200,5}]}],
	cost   = [],
	gain   = [{13134,2},{11128,5}],
	quick  = [],
	time   = 0,
	show   = []
};
find(90004) -> #cfg_task{
	id     = 90004,
	name   = "日常活跃达到120",
	type   = 9,
	group  = 0,
	reqs   = [{prev,0}, {level,200,9999} | []],
	accept = true,
	submit = false,
	quest  = [],
	goals  = [{25,1,120,0,0,[{link,270,1,1}]}],
	cost   = [],
	gain   = [{13134,3},{11128,5}],
	quick  = [],
	time   = 0,
	show   = []
};
find(_) -> undefined.


trigger_by_level(5, Level) when Level >= 9999, Level =< 9999 -> [52400];
trigger_by_level(5, Level) when Level >= 999, Level =< 9999 -> [52052,52051,52100];
trigger_by_level(1, Level) when Level >= 710, Level =< 9999 -> [1151042,1151044,1151041,1151043];
trigger_by_level(1, Level) when Level >= 700, Level =< 9999 -> [1151037,1151040,1151039,1151038];
trigger_by_level(1, Level) when Level >= 690, Level =< 9999 -> [1151033,1151034,1151036,1151035];
trigger_by_level(1, Level) when Level >= 680, Level =< 9999 -> [1151030,1151029,1151031,1151032];
trigger_by_level(1, Level) when Level >= 670, Level =< 9999 -> [1151025,1151026,1151028,1151027];
trigger_by_level(1, Level) when Level >= 660, Level =< 9999 -> [1151021,1151024,1151022,1151023];
trigger_by_level(1, Level) when Level >= 650, Level =< 9999 -> [1151018,1151019,1151020,1151017];
trigger_by_level(1, Level) when Level >= 640, Level =< 9999 -> [1151016,1151014,1151015,1151013];
trigger_by_level(1, Level) when Level >= 630, Level =< 9999 -> [1151009,1151010,1151012,1151011];
trigger_by_level(6, Level) when Level >= 620, Level =< 9999 -> [60037];
trigger_by_level(1, Level) when Level >= 620, Level =< 9999 -> [1151006,1151005,1151008,1151007];
trigger_by_level(1, Level) when Level >= 610, Level =< 9999 -> [1151004,1151001,1151003,1151002];
trigger_by_level(6, Level) when Level >= 610, Level =< 9999 -> [60036];
trigger_by_level(1, Level) when Level >= 600, Level =< 9999 -> [1150042,1150043,1150041,1150044];
trigger_by_level(6, Level) when Level >= 600, Level =< 9999 -> [60035];
trigger_by_level(1, Level) when Level >= 590, Level =< 9999 -> [1150037,1150038,1150039,1150040];
trigger_by_level(1, Level) when Level >= 580, Level =< 9999 -> [1150034,1150035,1150033,1150036];
trigger_by_level(1, Level) when Level >= 570, Level =< 9999 -> [1150032,1150031,1150030,1150029];
trigger_by_level(1, Level) when Level >= 560, Level =< 9999 -> [1150025,1150028,1150027,1150026];
trigger_by_level(1, Level) when Level >= 550, Level =< 9999 -> [1150022,1150023,1150024,1150021];
trigger_by_level(1, Level) when Level >= 540, Level =< 9999 -> [1150020,1150017,1150019,1150018];
trigger_by_level(6, Level) when Level >= 540, Level =< 9999 -> [60034];
trigger_by_level(1, Level) when Level >= 530, Level =< 9999 -> [1150015,1150016,1150013,1150014];
trigger_by_level(8, Level) when Level >= 520, Level =< 9999 -> [40218,40215,40220,40214,40213,40219,40216,40212,40217,40211];
trigger_by_level(1, Level) when Level >= 520, Level =< 9999 -> [1150011,1150010,1150012,1150009];
trigger_by_level(5, Level) when Level >= 520, Level =< 9999 -> [52756];
trigger_by_level(96, Level) when Level >= 520, Level =< 9999 -> [900004];
trigger_by_level(97, Level) when Level >= 520, Level =< 9999 -> [920004];
trigger_by_level(1, Level) when Level >= 510, Level =< 9999 -> [1150007,1150005,1150008,1150006];
trigger_by_level(1, Level) when Level >= 500, Level =< 9999 -> [1150001,1150004,1150002,1150003];
trigger_by_level(6, Level) when Level >= 500, Level =< 9999 -> [60033];
trigger_by_level(1, Level) when Level >= 490, Level =< 9999 -> [1149002,1149003,1149001,1149004];
trigger_by_level(1, Level) when Level >= 480, Level =< 9999 -> [1148001,1148003,1148004,1148002];
trigger_by_level(1, Level) when Level >= 470, Level =< 9999 -> [1147004,1147002,1147003,1147001];
trigger_by_level(5, Level) when Level >= 470, Level =< 9999 -> [52755];
trigger_by_level(1, Level) when Level >= 460, Level =< 9999 -> [1146003,1146004,1146001,1146002];
trigger_by_level(1, Level) when Level >= 450, Level =< 9999 -> [1145001,1145003,1145002,1145004];
trigger_by_level(8, Level) when Level >= 450, Level =< 9999 -> [40111,40114,40115,40118,40120,40116,40112,40113,40117,40119];
trigger_by_level(96, Level) when Level >= 450, Level =< 9999 -> [900003];
trigger_by_level(97, Level) when Level >= 450, Level =< 9999 -> [920003];
trigger_by_level(1, Level) when Level >= 440, Level =< 9999 -> [1144003,1144002,1144001,1144004];
trigger_by_level(1, Level) when Level >= 430, Level =< 9999 -> [1143003,1143001,1143002,1143004];
trigger_by_level(1, Level) when Level >= 420, Level =< 9999 -> [1142004,1142003,1142001,1142002];
trigger_by_level(1, Level) when Level >= 410, Level =< 9999 -> [1141004,1141001,1141002,1141003];
trigger_by_level(5, Level) when Level >= 410, Level =< 9999 -> [52754];
trigger_by_level(1, Level) when Level >= 400, Level =< 9999 -> [1140004,1140001,1140002,1140003];
trigger_by_level(1, Level) when Level >= 390, Level =< 9999 -> [1139003,1139001,1139004,1139002];
trigger_by_level(1, Level) when Level >= 380, Level =< 9999 -> [1138001,1138004,1138003,1138006,1138005,1138002];
trigger_by_level(8, Level) when Level >= 371, Level =< 9999 -> [40020,40017,40014,40016,40018,40015,40013,40012,40019,40011];
trigger_by_level(96, Level) when Level >= 371, Level =< 9999 -> [900002];
trigger_by_level(97, Level) when Level >= 371, Level =< 9999 -> [920002];
trigger_by_level(1, Level) when Level >= 370, Level =< 9999 -> [1137001,1137002,1137004,1137003];
trigger_by_level(1, Level) when Level >= 360, Level =< 9999 -> [1136001,1136002,1136003,1136004,1136005];
trigger_by_level(94, Level) when Level >= 350, Level =< 9999 -> [900001];
trigger_by_level(8, Level) when Level >= 350, Level =< 9999 -> [40007,40006,40003,40009,40010,40001,40004,40005,40002,40008];
trigger_by_level(5, Level) when Level >= 350, Level =< 9999 -> [52753,54503,54502];
trigger_by_level(95, Level) when Level >= 350, Level =< 9999 -> [920001];
trigger_by_level(6, Level) when Level >= 350, Level =< 9999 -> [60032];
trigger_by_level(1, Level) when Level >= 350, Level =< 9999 -> [1135002,1135003,1135004,1135005,1135001];
trigger_by_level(1, Level) when Level >= 340, Level =< 9999 -> [1134004,1134003,1134001,1134002];
trigger_by_level(1, Level) when Level >= 330, Level =< 9999 -> [1133002,1133004,1133005,1133003,1133001];
trigger_by_level(5, Level) when Level >= 330, Level =< 9999 -> [52205];
trigger_by_level(1, Level) when Level >= 320, Level =< 9999 -> [1132001,1132003,1132002,1132004];
trigger_by_level(1, Level) when Level >= 310, Level =< 9999 -> [1131001,1131002,1131003,1131004,1131005];
trigger_by_level(1, Level) when Level >= 300, Level =< 9999 -> [1130003,1130004,1130002,1130001,1130005];
trigger_by_level(6, Level) when Level >= 300, Level =< 9999 -> [60308];
trigger_by_level(5, Level) when Level >= 290, Level =< 9999 -> [52752];
trigger_by_level(1, Level) when Level >= 290, Level =< 9999 -> [1129003,1129002,1129001,1129004];
trigger_by_level(5, Level) when Level >= 280, Level =< 9999 -> [52204];
trigger_by_level(1, Level) when Level >= 280, Level =< 9999 -> [1128004,1128001,1128002,1128003];
trigger_by_level(6, Level) when Level >= 280, Level =< 9999 -> [60307,60305,60306,60304,60303,60302,60301,60031];
trigger_by_level(1, Level) when Level >= 270, Level =< 9999 -> [1127003,1127001,1127004,1127005,1127006,1127002];
trigger_by_level(10, Level) when Level >= 270, Level =< 9999 -> [55701];
trigger_by_level(5, Level) when Level >= 270, Level =< 9999 -> [53203];
trigger_by_level(1, Level) when Level >= 260, Level =< 9999 -> [1126006,1126007,1126004,1126005,1126002,1126003,1126001];
trigger_by_level(5, Level) when Level >= 260, Level =< 9999 -> [52850,53204];
trigger_by_level(1, Level) when Level >= 250, Level =< 9999 -> [1125003,1125005,1125002,1125001,1125004];
trigger_by_level(5, Level) when Level >= 250, Level =< 9999 -> [54302,53201,54303];
trigger_by_level(1, Level) when Level >= 240, Level =< 9999 -> [1124002,1124003,1124007,1124001,1124004,1124005,1124006];
trigger_by_level(5, Level) when Level >= 240, Level =< 9999 -> [54204,53202,52751];
trigger_by_level(10, Level) when Level >= 240, Level =< 9999 -> [55601];
trigger_by_level(6, Level) when Level >= 230, Level =< 9999 -> [60206,60208,60205,60207];
trigger_by_level(5, Level) when Level >= 230, Level =< 9999 -> [52203,53200];
trigger_by_level(1, Level) when Level >= 230, Level =< 9999 -> [1123004,1123005,1123002,1123001,1123003];
trigger_by_level(6, Level) when Level >= 220, Level =< 9999 -> [60201,60203,60204,60202,60030];
trigger_by_level(1, Level) when Level >= 220, Level =< 9999 -> [1122001,1122003,1122002,1122005,1122004];
trigger_by_level(10, Level) when Level >= 220, Level =< 9999 -> [55301];
trigger_by_level(5, Level) when Level >= 220, Level =< 9999 -> [52851];
trigger_by_level(1, Level) when Level >= 213, Level =< 9999 -> [1121007,1121006,1121005];
trigger_by_level(1, Level) when Level >= 210, Level =< 9999 -> [1121003,1121004,1121001,1121002];
trigger_by_level(1, Level) when Level >= 200, Level =< 9999 -> [1120002,1120001,1120003,1120004,1120005];
trigger_by_level(9, Level) when Level >= 200, Level =< 9999 -> [90004,90001,90002,90003];
trigger_by_level(5, Level) when Level >= 200, Level =< 9999 -> [52701,52700];
trigger_by_level(1, Level) when Level >= 190, Level =< 9999 -> [1119002,1119004,1119003,1119001];
trigger_by_level(1, Level) when Level >= 180, Level =< 9999 -> [1118002,1118005,1118003,1118001,1118004];
trigger_by_level(5, Level) when Level >= 180, Level =< 9999 -> [54203];
trigger_by_level(1, Level) when Level >= 170, Level =< 9999 -> [1117001,1117002,1117004,1117003];
trigger_by_level(5, Level) when Level >= 170, Level =< 9999 -> [52910];
trigger_by_level(1, Level) when Level >= 165, Level =< 9999 -> [1116006,1116005];
trigger_by_level(1, Level) when Level >= 160, Level =< 9999 -> [1116004,1116003,1116001,1116002];
trigger_by_level(6, Level) when Level >= 160, Level =< 9999 -> [60108,60107,60106,60105];
trigger_by_level(4, Level) when Level >= 150, Level =< 9999 -> [4000011,4000028,4000034,4000039,4000018,4000002,4000038,4000026,4000033,4000035,4000037,4000013,4000021,4000014,4000017,4000012,4000003,4000001,4000023,4000022,4000007,4000005,4000010,4000024,4000029,4000030,4000032,4000019,4000027,4000006,4000040,4000008,4000004,4000009,4000031,4000015,4000020,4000036,4000016,4000025];
trigger_by_level(1, Level) when Level >= 150, Level =< 9999 -> [1115004,1115003,1115002,1115001];
trigger_by_level(6, Level) when Level >= 150, Level =< 9999 -> [60029,60102,60101,60103,60104];
trigger_by_level(91, Level) when Level >= 150, Level =< 9999 -> [910000];
trigger_by_level(93, Level) when Level >= 150, Level =< 9999 -> [930000];
trigger_by_level(5, Level) when Level >= 150, Level =< 9999 -> [54201,54202,52350,52909];
trigger_by_level(5, Level) when Level >= 145, Level =< 9999 -> [54505];
trigger_by_level(10, Level) when Level >= 140, Level =< 9999 -> [55401,55501];
trigger_by_level(5, Level) when Level >= 140, Level =< 9999 -> [50003];
trigger_by_level(1, Level) when Level >= 140, Level =< 9999 -> [1114003,1114002,1114001,1114004];
trigger_by_level(1, Level) when Level >= 130, Level =< 9999 -> [1113003,1113002,1113001,1113004];
trigger_by_level(5, Level) when Level >= 130, Level =< 9999 -> [52906];
trigger_by_level(1, Level) when Level >= 120, Level =< 9999 -> [1112008,1112007,1112002,1112006,1112001,1112003,1112005,1112004];
trigger_by_level(5, Level) when Level >= 120, Level =< 9999 -> [54200,52600];
trigger_by_level(5, Level) when Level >= 115, Level =< 9999 -> [52905,54507,52151];
trigger_by_level(1, Level) when Level >= 115, Level =< 9999 -> [1111502,1111501,1111503,1111505,1111506,1111504];
trigger_by_level(10, Level) when Level >= 115, Level =< 9999 -> [55201];
trigger_by_level(1, Level) when Level >= 110, Level =< 9999 -> [1111005,1111001,1111002,1111006,1111004,1111003];
trigger_by_level(10, Level) when Level >= 105, Level =< 9999 -> [55101];
trigger_by_level(1, Level) when Level >= 105, Level =< 9999 -> [1110503,1110501,1110502,1110505,1110504];
trigger_by_level(5, Level) when Level >= 105, Level =< 9999 -> [52904,54504];
trigger_by_level(1, Level) when Level >= 100, Level =< 9999 -> [1110004,1110001,1110003,1110002,1110005,1110006];
trigger_by_level(5, Level) when Level >= 100, Level =< 9999 -> [54506];
trigger_by_level(1, Level) when Level >= 90, Level =< 9999 -> [1109001,1109004,1109005,1109003,1109002];
trigger_by_level(5, Level) when Level >= 90, Level =< 9999 -> [52902];
trigger_by_level(5, Level) when Level >= 86, Level =< 9999 -> [52450];
trigger_by_level(1, Level) when Level >= 85, Level =< 9999 -> [1108504,1108503,1108502,1108501];
trigger_by_level(1, Level) when Level >= 75, Level =< 9999 -> [1108003,1107502,1107501];
trigger_by_level(1, Level) when Level >= 74, Level =< 9999 -> [1107402,1107401];
trigger_by_level(1, Level) when Level >= 73, Level =< 9999 -> [1107301];
trigger_by_level(1, Level) when Level >= 72, Level =< 9999 -> [1107201];
trigger_by_level(1, Level) when Level >= 71, Level =< 9999 -> [1107101];
trigger_by_level(5, Level) when Level >= 70, Level =< 9999 -> [51048,51016,51008,51014,51030,51049,51023,51033,51047,51039,51044,51027,51050,51034,51035,51038,51007,51029,51003,51009,51042,51018,51043,51013,51022,51012,51031,51019,51002,51046,51006,51021,51037,51015,51020,51024,51028,51001,51026,51045,51011,51010,51032,51017,51041,51040,51005,51025,51036,51004];
trigger_by_level(1, Level) when Level >= 70, Level =< 9999 -> [1107001,1107003,1107002];
trigger_by_level(3, Level) when Level >= 65, Level =< 9999 -> [30016,30007,30019,30018,30006,30001,30011,30005,30002,30017,30013,30015,30009,30020,30004,30014,30003,30012,30010,30008];
trigger_by_level(90, Level) when Level >= 65, Level =< 9999 -> [900000];
trigger_by_level(92, Level) when Level >= 65, Level =< 9999 -> [920000];
trigger_by_level(1, Level) when Level >= 65, Level =< 9999 -> [1106501];
trigger_by_level(5, Level) when Level >= 60, Level =< 9999 -> [52901,50000,50002,50001];
trigger_by_level(1, Level) when Level >= 60, Level =< 9999 -> [1106500,1106211,1106210,1106208];
trigger_by_level(1, Level) when Level >= 40, Level =< 9999 -> [1105401];
trigger_by_level(1, Level) when Level >= 1, Level =< 9999 -> [1102602,1106204,1106202,1106101,1103404,1101001,1103601,1103201,1103401,1102401,1103405,1105402,1105302,1100501,1103501,1102601,1101601,1105602,1103701,1100901,1106002,1100201,1101801,1101402,1104201,1104501,1106205,1101502,1102201,1103302,1100502,1105802,1102701,1103301,1101401,1101301,1103801,1104702,1100801,1105702,1100302,1104701,1104001,1103402,1106203,1102101,1103403,1105502,1101701,1104302,1106001,1105801,1101201,1106201,1106207,1105901,1105701,1105603,1106206,1101501,1100701,1105601,1102901,1105501,1105201,1104401,1101901,1100101,1103101,1102801,1104301,1105301,1102301,1100304,1100301,1105403];
trigger_by_level(5, Level) when Level >= 1, Level =< 9999 -> [52650,50050,54501,54401,50051,51000,54301];
trigger_by_level(_, _) -> [].



trigger_by_task(1113001) -> [52100,1113002,52906];
trigger_by_task(1151042) -> [1151043];
trigger_by_task(1151041) -> [1151042];
trigger_by_task(1151043) -> [1151044];
trigger_by_task(1151040) -> [1151041];
trigger_by_task(1151036) -> [1151037];
trigger_by_task(1151039) -> [1151040];
trigger_by_task(1151038) -> [1151039];
trigger_by_task(1151037) -> [1151038];
trigger_by_task(1151032) -> [1151033];
trigger_by_task(1151033) -> [1151034];
trigger_by_task(1151035) -> [1151036];
trigger_by_task(1151034) -> [1151035];
trigger_by_task(1151029) -> [1151030];
trigger_by_task(1151028) -> [1151029];
trigger_by_task(1151030) -> [1151031];
trigger_by_task(1151031) -> [1151032];
trigger_by_task(1151024) -> [1151025];
trigger_by_task(1151025) -> [1151026];
trigger_by_task(1151027) -> [1151028];
trigger_by_task(1151026) -> [1151027];
trigger_by_task(1151020) -> [1151021];
trigger_by_task(1151023) -> [1151024];
trigger_by_task(1151021) -> [1151022];
trigger_by_task(1151022) -> [1151023];
trigger_by_task(1151016) -> [1151017];
trigger_by_task(1151017) -> [1151018];
trigger_by_task(1151018) -> [1151019];
trigger_by_task(1151019) -> [1151020];
trigger_by_task(1151013) -> [1151014];
trigger_by_task(1151014) -> [1151015];
trigger_by_task(1151012) -> [1151013];
trigger_by_task(1151015) -> [1151016];
trigger_by_task(1151008) -> [1151009];
trigger_by_task(1151009) -> [1151010];
trigger_by_task(1151011) -> [1151012];
trigger_by_task(1151010) -> [1151011];
trigger_by_task(60036) -> [60037];
trigger_by_task(1151007) -> [1151008];
trigger_by_task(1151006) -> [1151007];
trigger_by_task(1151005) -> [1151006];
trigger_by_task(1151004) -> [1151005];
trigger_by_task(1151003) -> [1151004];
trigger_by_task(1150044) -> [1151001];
trigger_by_task(1151002) -> [1151003];
trigger_by_task(60035) -> [60036];
trigger_by_task(1151001) -> [1151002];
trigger_by_task(1150041) -> [1150042];
trigger_by_task(60034) -> [60035];
trigger_by_task(1150042) -> [1150043];
trigger_by_task(1150040) -> [1150041];
trigger_by_task(1150043) -> [1150044];
trigger_by_task(1150036) -> [1150037];
trigger_by_task(1150037) -> [1150038];
trigger_by_task(1150038) -> [1150039];
trigger_by_task(1150039) -> [1150040];
trigger_by_task(1150033) -> [1150034];
trigger_by_task(1150034) -> [1150035];
trigger_by_task(1150032) -> [1150033];
trigger_by_task(1150035) -> [1150036];
trigger_by_task(1150029) -> [1150030];
trigger_by_task(1150028) -> [1150029];
trigger_by_task(1150031) -> [1150032];
trigger_by_task(1150030) -> [1150031];
trigger_by_task(1150027) -> [1150028];
trigger_by_task(1150026) -> [1150027];
trigger_by_task(1150025) -> [1150026];
trigger_by_task(1150024) -> [1150025];
trigger_by_task(1150021) -> [1150022];
trigger_by_task(1150022) -> [1150023];
trigger_by_task(1150023) -> [1150024];
trigger_by_task(1150020) -> [1150021];
trigger_by_task(1150019) -> [1150020];
trigger_by_task(1150016) -> [1150017];
trigger_by_task(1150018) -> [1150019];
trigger_by_task(60033) -> [60034];
trigger_by_task(1150017) -> [1150018];
trigger_by_task(1150014) -> [1150015];
trigger_by_task(1150015) -> [1150016];
trigger_by_task(1150012) -> [1150013];
trigger_by_task(1150013) -> [1150014];
trigger_by_task(40216) -> [40217];
trigger_by_task(920004) -> [40211,900004];
trigger_by_task(1150010) -> [1150011];
trigger_by_task(40214) -> [40215];
trigger_by_task(40213) -> [40214];
trigger_by_task(40212) -> [40213];
trigger_by_task(40219) -> [40220];
trigger_by_task(1150009) -> [1150010];
trigger_by_task(40218) -> [40219];
trigger_by_task(40217) -> [40218];
trigger_by_task(1150011) -> [1150012];
trigger_by_task(52755) -> [52756];
trigger_by_task(40215) -> [40216];
trigger_by_task(40211) -> [40212];
trigger_by_task(1150008) -> [1150009];
trigger_by_task(1150006) -> [1150007];
trigger_by_task(1150004) -> [1150005];
trigger_by_task(1150007) -> [1150008];
trigger_by_task(1150005) -> [1150006];
trigger_by_task(1149004) -> [1150001];
trigger_by_task(1150003) -> [1150004];
trigger_by_task(1150001) -> [1150002];
trigger_by_task(60032) -> [60033];
trigger_by_task(1150002) -> [1150003];
trigger_by_task(1149001) -> [1149002];
trigger_by_task(1149002) -> [1149003];
trigger_by_task(1148004) -> [1149001];
trigger_by_task(1149003) -> [1149004];
trigger_by_task(1147004) -> [1148001];
trigger_by_task(1148002) -> [1148003];
trigger_by_task(1148003) -> [1148004];
trigger_by_task(1148001) -> [1148002];
trigger_by_task(1147001) -> [1147002];
trigger_by_task(1147002) -> [1147003];
trigger_by_task(52754) -> [52755];
trigger_by_task(1146004) -> [1147001];
trigger_by_task(1147003) -> [1147004];
trigger_by_task(1146002) -> [1146003];
trigger_by_task(1146003) -> [1146004];
trigger_by_task(1145004) -> [1146001];
trigger_by_task(1146001) -> [1146002];
trigger_by_task(1144004) -> [1145001];
trigger_by_task(1145002) -> [1145003];
trigger_by_task(40116) -> [40117];
trigger_by_task(40117) -> [40118];
trigger_by_task(40118) -> [40119];
trigger_by_task(40119) -> [40120];
trigger_by_task(920003) -> [40111,900003];
trigger_by_task(40115) -> [40116];
trigger_by_task(40111) -> [40112];
trigger_by_task(40112) -> [40113];
trigger_by_task(40113) -> [40114];
trigger_by_task(40114) -> [40115];
trigger_by_task(1145001) -> [1145002];
trigger_by_task(1145003) -> [1145004];
trigger_by_task(1144002) -> [1144003];
trigger_by_task(1144001) -> [1144002];
trigger_by_task(1143004) -> [1144001];
trigger_by_task(1144003) -> [1144004];
trigger_by_task(1143003) -> [1143004];
trigger_by_task(1143002) -> [1143003];
trigger_by_task(1142004) -> [1143001];
trigger_by_task(1143001) -> [1143002];
trigger_by_task(1142003) -> [1142004];
trigger_by_task(1142002) -> [1142003];
trigger_by_task(1141004) -> [1142001];
trigger_by_task(1142001) -> [1142002];
trigger_by_task(1141003) -> [1141004];
trigger_by_task(1140004) -> [1141001];
trigger_by_task(1141001) -> [1141002];
trigger_by_task(52753) -> [52754];
trigger_by_task(1141002) -> [1141003];
trigger_by_task(1140003) -> [1140004];
trigger_by_task(1139004) -> [1140001];
trigger_by_task(1140001) -> [1140002];
trigger_by_task(1140002) -> [1140003];
trigger_by_task(1139001) -> [1139002];
trigger_by_task(1139002) -> [1139003];
trigger_by_task(1138006) -> [1139001];
trigger_by_task(1139003) -> [1139004];
trigger_by_task(1138005) -> [1138006];
trigger_by_task(1138004) -> [1138005];
trigger_by_task(1138001) -> [1138002];
trigger_by_task(1137004) -> [1138001];
trigger_by_task(1138003) -> [1138004];
trigger_by_task(1138002) -> [1138003];
trigger_by_task(40012) -> [40013];
trigger_by_task(40013) -> [40014];
trigger_by_task(920002) -> [900002,40011];
trigger_by_task(40015) -> [40016];
trigger_by_task(40011) -> [40012];
trigger_by_task(40017) -> [40018];
trigger_by_task(40014) -> [40015];
trigger_by_task(40018) -> [40019];
trigger_by_task(40019) -> [40020];
trigger_by_task(40016) -> [40017];
trigger_by_task(1136005) -> [1137001];
trigger_by_task(1137001) -> [1137002];
trigger_by_task(1137003) -> [1137004];
trigger_by_task(1137002) -> [1137003];
trigger_by_task(1135005) -> [1136001];
trigger_by_task(1136001) -> [1136002];
trigger_by_task(1136002) -> [1136003];
trigger_by_task(1136003) -> [1136004];
trigger_by_task(1136004) -> [1136005];
trigger_by_task(920001) -> [900001,40001];
trigger_by_task(40001) -> [40002];
trigger_by_task(40008) -> [40009];
trigger_by_task(52752) -> [52753];
trigger_by_task(40007) -> [40008];
trigger_by_task(60031) -> [60032];
trigger_by_task(40009) -> [40010];
trigger_by_task(40003) -> [40004];
trigger_by_task(40006) -> [40007];
trigger_by_task(40004) -> [40005];
trigger_by_task(40005) -> [40006];
trigger_by_task(1135001) -> [1135002,54501];
trigger_by_task(1135002) -> [1135003];
trigger_by_task(1135003) -> [1135004];
trigger_by_task(1135004) -> [1135005];
trigger_by_task(1134004) -> [1135001];
trigger_by_task(40002) -> [40003];
trigger_by_task(1134002) -> [1134003];
trigger_by_task(1133005) -> [1134001];
trigger_by_task(1134001) -> [1134002];
trigger_by_task(1134003) -> [1134004];
trigger_by_task(1133002) -> [1133003];
trigger_by_task(1132004) -> [1133001];
trigger_by_task(1133001) -> [1133002];
trigger_by_task(1133003) -> [1133004];
trigger_by_task(1133004) -> [1133005];
trigger_by_task(1131005) -> [1132001];
trigger_by_task(1132002) -> [1132003];
trigger_by_task(1132001) -> [1132002];
trigger_by_task(1132003) -> [1132004];
trigger_by_task(1131004) -> [1131005];
trigger_by_task(1130005) -> [1131001];
trigger_by_task(1131001) -> [1131002];
trigger_by_task(1131002) -> [1131003];
trigger_by_task(1131003) -> [1131004];
trigger_by_task(1130002) -> [1130003];
trigger_by_task(1130003) -> [1130004];
trigger_by_task(1130001) -> [1130002];
trigger_by_task(1129004) -> [1130001];
trigger_by_task(1130004) -> [1130005];
trigger_by_task(52751) -> [52752];
trigger_by_task(1128004) -> [1129001];
trigger_by_task(1129003) -> [1129004];
trigger_by_task(1129002) -> [1129003,54301];
trigger_by_task(1129001) -> [1129002];
trigger_by_task(1128001) -> [1128002];
trigger_by_task(1128002) -> [1128003];
trigger_by_task(1128003) -> [1128004];
trigger_by_task(1127006) -> [1128001];
trigger_by_task(60030) -> [60031];
trigger_by_task(1127004) -> [1127005];
trigger_by_task(1127005) -> [1127006,52850];
trigger_by_task(1127001) -> [1127002];
trigger_by_task(1127002) -> [1127003];
trigger_by_task(1126007) -> [1127001];
trigger_by_task(1127003) -> [1127004];
trigger_by_task(1126005) -> [1126006];
trigger_by_task(1126006) -> [1126007];
trigger_by_task(1126003) -> [1126004];
trigger_by_task(1126004) -> [1126005];
trigger_by_task(1126001) -> [1126002];
trigger_by_task(1126002) -> [1126003];
trigger_by_task(1125005) -> [1126001];
trigger_by_task(1125002) -> [1125003];
trigger_by_task(1125004) -> [1125005,52650];
trigger_by_task(1125001) -> [1125002];
trigger_by_task(1124007) -> [1125001];
trigger_by_task(1125003) -> [1125004];
trigger_by_task(1124002) -> [1124003];
trigger_by_task(1124006) -> [1124007];
trigger_by_task(1123005) -> [1124001];
trigger_by_task(1124003) -> [1124004];
trigger_by_task(1124005) -> [1124006,52751];
trigger_by_task(1124004) -> [1124005];
trigger_by_task(1124001) -> [1124002];
trigger_by_task(1123002) -> [1123003];
trigger_by_task(1123003) -> [1123004];
trigger_by_task(1123004) -> [1123005];
trigger_by_task(1123001) -> [1123002];
trigger_by_task(1122005) -> [1123001];
trigger_by_task(1121007) -> [1122001];
trigger_by_task(1122002) -> [1122003];
trigger_by_task(1122001) -> [1122002];
trigger_by_task(1113004) -> [52851,1114001];
trigger_by_task(60029) -> [60030];
trigger_by_task(1122004) -> [1122005];
trigger_by_task(1122003) -> [1122004];
trigger_by_task(1121006) -> [1121007];
trigger_by_task(1121005) -> [1121006];
trigger_by_task(1121004) -> [1121005];
trigger_by_task(1121002) -> [1121003];
trigger_by_task(1121003) -> [1121004];
trigger_by_task(1120005) -> [1121001];
trigger_by_task(1121001) -> [1121002];
trigger_by_task(1120001) -> [1120002];
trigger_by_task(1119004) -> [1120001];
trigger_by_task(1120002) -> [1120003,52700];
trigger_by_task(1120003) -> [1120004];
trigger_by_task(1120004) -> [1120005];
trigger_by_task(1119003) -> [1119004];
trigger_by_task(1119002) -> [1119003];
trigger_by_task(1118005) -> [1119001];
trigger_by_task(1119001) -> [1119002];
trigger_by_task(1118001) -> [1118002];
trigger_by_task(1118004) -> [1118005];
trigger_by_task(1118002) -> [1118003];
trigger_by_task(1117004) -> [1118001];
trigger_by_task(1118003) -> [1118004];
trigger_by_task(1117002) -> [1117003];
trigger_by_task(1117001) -> [52910,1117002];
trigger_by_task(1116006) -> [1117001];
trigger_by_task(1117003) -> [1117004];
trigger_by_task(1116005) -> [1116006];
trigger_by_task(1116004) -> [1116005];
trigger_by_task(1116001) -> [1116002];
trigger_by_task(1116003) -> [1116004];
trigger_by_task(1116002) -> [1116003];
trigger_by_task(1115004) -> [1116001];
trigger_by_task(4000013) -> [4000014];
trigger_by_task(4000010) -> [4000011];
trigger_by_task(4000026) -> [4000027];
trigger_by_task(4000027) -> [4000028];
trigger_by_task(4000005) -> [4000006];
trigger_by_task(4000023) -> [4000024];
trigger_by_task(1114004) -> [1115001];
trigger_by_task(4000028) -> [4000029];
trigger_by_task(4000037) -> [4000038];
trigger_by_task(4000039) -> [4000040];
trigger_by_task(4000025) -> [4000026];
trigger_by_task(4000029) -> [4000030];
trigger_by_task(4000007) -> [4000008];
trigger_by_task(4000032) -> [4000033];
trigger_by_task(4000003) -> [4000004];
trigger_by_task(4000033) -> [4000034];
trigger_by_task(930000) -> [910000,4000001];
trigger_by_task(4000034) -> [4000035];
trigger_by_task(4000038) -> [4000039];
trigger_by_task(4000035) -> [4000036];
trigger_by_task(4000036) -> [4000037];
trigger_by_task(4000031) -> [4000032];
trigger_by_task(4000030) -> [4000031];
trigger_by_task(4000015) -> [4000016];
trigger_by_task(4000021) -> [4000022];
trigger_by_task(4000008) -> [4000009];
trigger_by_task(4000012) -> [4000013];
trigger_by_task(4000006) -> [4000007];
trigger_by_task(4000016) -> [4000017];
trigger_by_task(4000004) -> [4000005];
trigger_by_task(4000014) -> [4000015];
trigger_by_task(4000011) -> [4000012];
trigger_by_task(4000017) -> [4000018];
trigger_by_task(4000002) -> [4000003];
trigger_by_task(4000020) -> [4000021];
trigger_by_task(4000019) -> [4000020];
trigger_by_task(4000018) -> [4000019];
trigger_by_task(4000022) -> [4000023];
trigger_by_task(1115003) -> [52909,1115004];
trigger_by_task(4000001) -> [4000002];
trigger_by_task(4000024) -> [4000025];
trigger_by_task(4000009) -> [4000010];
trigger_by_task(1115002) -> [1115003];
trigger_by_task(1115001) -> [1115002];
trigger_by_task(1114003) -> [1114004];
trigger_by_task(1114002) -> [1114003];
trigger_by_task(1114001) -> [1114002];
trigger_by_task(1113002) -> [1113003];
trigger_by_task(1112008) -> [1113001];
trigger_by_task(1113003) -> [1113004];
trigger_by_task(1111506) -> [1112001,52151];
trigger_by_task(1112002) -> [1112003];
trigger_by_task(52100) -> [52600];
trigger_by_task(1112004) -> [1112005];
trigger_by_task(1112003) -> [1112004];
trigger_by_task(1112007) -> [1112008];
trigger_by_task(1112006) -> [1112007];
trigger_by_task(1112001) -> [1112002];
trigger_by_task(1112005) -> [1112006];
trigger_by_task(1111502) -> [52905,1111503];
trigger_by_task(1111503) -> [1111504];
trigger_by_task(1111501) -> [1111502];
trigger_by_task(1111006) -> [1111501];
trigger_by_task(1111504) -> [54507,1111505];
trigger_by_task(1111505) -> [1111506];
trigger_by_task(1111003) -> [54506,1111004];
trigger_by_task(1111002) -> [1111003];
trigger_by_task(1111004) -> [1111005];
trigger_by_task(1110505) -> [1111001];
trigger_by_task(1111001) -> [1111002];
trigger_by_task(1111005) -> [1111006];
trigger_by_task(1110502) -> [1110503];
trigger_by_task(1110501) -> [52904,1110502];
trigger_by_task(1110006) -> [1110501];
trigger_by_task(1110504) -> [1110505];
trigger_by_task(1110503) -> [1110504,54504];
trigger_by_task(1110002) -> [1110003];
trigger_by_task(1110001) -> [1110002];
trigger_by_task(1110004) -> [1110005];
trigger_by_task(1110005) -> [1110006];
trigger_by_task(1110003) -> [1110004];
trigger_by_task(1109005) -> [1110001];
trigger_by_task(1109001) -> [1109002];
trigger_by_task(1108504) -> [1109001];
trigger_by_task(1109003) -> [1109004,52902];
trigger_by_task(1109004) -> [1109005];
trigger_by_task(1109002) -> [1109003];
trigger_by_task(1108503) -> [1108504];
trigger_by_task(1108502) -> [1108503];
trigger_by_task(1108501) -> [1108502];
trigger_by_task(1108003) -> [1108501];
trigger_by_task(1107502) -> [1108003];
trigger_by_task(1107501) -> [1107502];
trigger_by_task(1107402) -> [1107501];
trigger_by_task(1107401) -> [1107402];
trigger_by_task(1107301) -> [1107401];
trigger_by_task(1107201) -> [1107301];
trigger_by_task(1107101) -> [1107201];
trigger_by_task(1107003) -> [1107101];
trigger_by_task(1106501) -> [1107001];
trigger_by_task(1107002) -> [1107003];
trigger_by_task(1107001) -> [1107002,51000];
trigger_by_task(30003) -> [30004];
trigger_by_task(920000) -> [900000,30001];
trigger_by_task(30004) -> [30005];
trigger_by_task(30015) -> [30016];
trigger_by_task(30006) -> [30007];
trigger_by_task(30013) -> [30014];
trigger_by_task(30001) -> [30002];
trigger_by_task(30002) -> [30003];
trigger_by_task(30016) -> [30017];
trigger_by_task(30012) -> [30013];
trigger_by_task(30018) -> [30019];
trigger_by_task(30005) -> [30006];
trigger_by_task(30014) -> [30015];
trigger_by_task(30008) -> [30009];
trigger_by_task(1106500) -> [920000,1106501];
trigger_by_task(30010) -> [30011];
trigger_by_task(30011) -> [30012];
trigger_by_task(30009) -> [30010];
trigger_by_task(30007) -> [30008];
trigger_by_task(30017) -> [30018];
trigger_by_task(30019) -> [30020];
trigger_by_task(1106207) -> [1106208,52901];
trigger_by_task(1106211) -> [1106500];
trigger_by_task(1106210) -> [1106211];
trigger_by_task(1106208) -> [1106210];
trigger_by_task(1105302) -> [1105401];
trigger_by_task(1104501) -> [1104701];
trigger_by_task(1102601) -> [1102602];
trigger_by_task(1106203) -> [1106204];
trigger_by_task(1103801) -> [1104001];
trigger_by_task(1103301) -> [1103302];
trigger_by_task(1106201) -> [1106202];
trigger_by_task(1103601) -> [1103701];
trigger_by_task(1104401) -> [1104501];
trigger_by_task(1103405) -> [1103501];
trigger_by_task(1106204) -> [1106205];
trigger_by_task(1102301) -> [1102401];
trigger_by_task(1104702) -> [1105201];
trigger_by_task(1106202) -> [1106203];
trigger_by_task(1101901) -> [1102101];
trigger_by_task(1104302) -> [1104401];
trigger_by_task(1106101) -> [1106201];
trigger_by_task(1101801) -> [1101901];
trigger_by_task(1102401) -> [1102601];
trigger_by_task(1101601) -> [1101701];
trigger_by_task(1102901) -> [1103101];
trigger_by_task(1101501) -> [1101502];
trigger_by_task(1102701) -> [1102801];
trigger_by_task(1101401) -> [1101402];
trigger_by_task(1104301) -> [1104302];
trigger_by_task(1104201) -> [1104301];
trigger_by_task(1103401) -> [1103402];
trigger_by_task(1103701) -> [1103801];
trigger_by_task(1100801) -> [1100901];
trigger_by_task(1100501) -> [1100502];
trigger_by_task(1106206) -> [1106207];
trigger_by_task(1106002) -> [1106101];
trigger_by_task(1106001) -> [1106002];
trigger_by_task(1103403) -> [1103404];
trigger_by_task(1105201) -> [1105301];
trigger_by_task(1105901) -> [1106001];
trigger_by_task(1100101) -> [1100201];
trigger_by_task(1105802) -> [1105901];
trigger_by_task(1104701) -> [1104702];
trigger_by_task(1104001) -> [1104201];
trigger_by_task(1105801) -> [1105802];
trigger_by_task(1103101) -> [1103201];
trigger_by_task(1106205) -> [1106206];
trigger_by_task(1101701) -> [1101801];
trigger_by_task(1101502) -> [1101601];
trigger_by_task(1100901) -> [1101001];
trigger_by_task(1102602) -> [1102701];
trigger_by_task(1100701) -> [1100801];
trigger_by_task(1103404) -> [1103405];
trigger_by_task(1103402) -> [1103403];
trigger_by_task(1102201) -> [1102301];
trigger_by_task(1103302) -> [1103401];
trigger_by_task(1102101) -> [1102201];
trigger_by_task(1103201) -> [1103301];
trigger_by_task(1103501) -> [1103601];
trigger_by_task(1105401) -> [1105402];
trigger_by_task(1101402) -> [1101501];
trigger_by_task(1105301) -> [1105302];
trigger_by_task(1101301) -> [1101401];
trigger_by_task(1105702) -> [1105801];
trigger_by_task(1101001) -> [1101201];
trigger_by_task(1105701) -> [1105702];
trigger_by_task(1101201) -> [1101301];
trigger_by_task(1105603) -> [1105701];
trigger_by_task(1100502) -> [1100701];
trigger_by_task(1105602) -> [1105603];
trigger_by_task(1100304) -> [1100501];
trigger_by_task(1105601) -> [1105602];
trigger_by_task(1100301) -> [1100302];
trigger_by_task(1105502) -> [1105601];
trigger_by_task(1100302) -> [1100304];
trigger_by_task(1102801) -> [1102901];
trigger_by_task(1100201) -> [1100301];
trigger_by_task(1105403) -> [1105501];
trigger_by_task(1105501) -> [1105502];
trigger_by_task(1105402) -> [1105403];
trigger_by_task(_) -> [].


trigger_by_type(5) -> [54302,51032,54204,51028,51037,51025,51038,52909,54202,51010,51014,51026,52851,52756,54504,52450,51016,52906,51047,50051,52700,50003,51011,52910,54200,51042,52600,51021,51006,51034,52051,52100,52905,51001,51015,52052,53201,51036,51012,51039,51018,51017,51044,52204,54201,50001,53200,52902,51040,51048,52904,51031,51035,51050,50050,52400,52754,52203,51030,51004,51027,51045,52755,52753,51003,52901,52751,51023,51022,51043,52205,54507,54505,51024,51041,50002,54501,54502,52752,53204,52650,51005,51008,51002,54301,54303,53202,54506,51049,51033,54203,54401,51029,51019,51000,51013,51020,52850,52350,51007,50000,54503,52151,51009,53203,52701,51046];
trigger_by_type(1) -> [1151039,1146004,1146001,1129002,1117002,1107001,1104702,1103405,1151031,1128001,1112006,1111003,1105201,1106002,1151037,1150016,1128002,1105403,1114001,1113004,1151006,1150038,1150036,1150021,1143004,1121005,1112005,1107502,1106201,1102301,1101401,1151015,1130003,1120001,1119003,1108503,1103101,1151030,1147004,1127002,1122003,1122005,1100801,1106210,1105601,1151022,1144002,1138004,1126007,1124002,1113002,1150013,1147003,1133004,1125004,1103801,1101801,1146002,1124003,1121003,1112008,1104201,1101201,1150043,1150040,1121001,1102701,1150035,1125001,1120004,1118002,1110005,1106101,1150034,1146003,1142004,1131001,1127005,1112002,1120005,1110004,1150023,1150007,1128003,1124006,1122004,1120002,1140003,1135003,1131004,1129004,1116006,1104501,1151024,1132001,1122002,1111503,1106203,1103404,1151009,1150024,1133002,1103201,1148001,1116003,1114003,1101701,1105301,1101301,1150014,1150005,1148003,1130004,1120003,1101601,1107401,1102401,1150025,1144003,1126004,1116001,1108504,1107501,1106001,1101501,1150015,1150001,1136005,1123002,1121006,1150008,1135004,1135001,1114004,1111006,1107201,1150017,1150010,1145001,1145003,1116005,1104401,1150027,1150009,1126006,1105501,1105702,1151002,1150044,1150039,1142001,1125003,1109005,1107402,1105402,1138001,1134004,1133003,1130002,1125002,1110001,1151040,1151014,1149001,1103501,1105802,1119001,1111005,1151042,1150029,1144004,1134003,1126002,1121002,1101901,1150026,1123001,1118001,1100502,1151043,1151023,1105401,1103301,1103601,1150030,1141001,1115002,1110504,1103403,1102201,1123004,1117001,1151041,1151005,1150022,1147001,1141003,1131002,1105603,1151034,1150032,1138003,1137003,1109004,1104302,1105901,1140001,1132003,1123005,1112001,1112007,1107101,1150018,1143001,1139003,1126005,1106202,1123003,1111502,1148002,1142002,1137002,1137004,1134001,1130001,1111501,1102801,1142003,1117003,1111002,1104001,1124005,1118003,1151044,1151016,1151004,1150004,1143003,1127004,1117004,1115004,1107002,1102601,1105701,1105602,1147002,1141004,1109003,1108003,1119002,1115001,1151035,1151008,1149002,1138006,1135002,1132002,1110006,1125005,1106211,1151020,1150033,1150019,1140002,1137001,1133005,1106205,1110501,1110002,1150041,1150037,1150002,1139004,1127006,1112003,1101402,1101001,1105302,1100301,1151032,1151007,1141002,1139002,1111004,1110003,1151036,1127003,1126001,1116002,1110502,1140004,1128004,1118004,1116004,1104701,1102101,1151019,1150042,1100101,1106206,1112004,1100701,1105502,1150012,1149004,1115003,1113003,1103402,1103401,1151025,1151026,1151017,1151010,1144001,1106500,1107301,1106208,1143002,1136002,1131003,1114002,1111504,1109001,1106207,1100201,1100302,1111506,1103701,1109002,1151033,1151012,1136004,1129003,1108502,1106501,1151001,1124004,1111001,1104301,1105801,1102901,1107003,1151021,1151013,1151011,1148004,1138005,1136003,1149003,1135005,1132004,1126003,1113001,1150011,1138002,1111505,1110503,1103302,1150020,1145002,1145004,1121004,1108501,1106204,1121007,1119004,1151029,1150006,1139001,1134002,1133001,1129001,1101502,1100901,1150031,1150028,1150003,1122001,1131005,1130005,1100501,1124007,1124001,1151038,1151027,1151018,1151003,1118005,1100304,1151028,1136001,1127001,1110505,1102602];
trigger_by_type(6) -> [60101,60305,60301,60105,60031,60208,60203,60108,60103,60033,60207,60202,60102,60036,60303,60205,60307,60107,60032,60306,60302,60204,60106,60037,60035,60201,60104,60034,60206,60029,60308,60304,60030];
trigger_by_type(8) -> [40219,40116,40114,40020,40007,40217,40211,40214,40213,40012,40018,40009,40111,40115,40016,40010,40006,40001,40004,40003,40119,40112,40113,40019,40011,40215,40218,40216,40117,40118,40002,40008,40005,40220,40212,40013,40014,40017,40120,40015];
trigger_by_type(96) -> [900004,900003,900002];
trigger_by_type(97) -> [920004,920003,920002];
trigger_by_type(94) -> [900001];
trigger_by_type(95) -> [920001];
trigger_by_type(10) -> [55301,55401,55501,55201,55101,55701,55601];
trigger_by_type(9) -> [90002,90003,90004,90001];
trigger_by_type(4) -> [4000008,4000004,4000015,4000001,4000021,4000014,4000028,4000038,4000026,4000016,4000007,4000018,4000006,4000039,4000009,4000013,4000017,4000005,4000019,4000023,4000011,4000027,4000040,4000033,4000034,4000036,4000032,4000030,4000022,4000003,4000024,4000029,4000035,4000002,4000010,4000037,4000031,4000012,4000020,4000025];
trigger_by_type(91) -> [910000];
trigger_by_type(93) -> [930000];
trigger_by_type(3) -> [30004,30016,30017,30006,30010,30020,30007,30002,30013,30019,30009,30012,30005,30014,30003,30015,30011,30001,30008,30018];
trigger_by_type(90) -> [900000];
trigger_by_type(92) -> [920000];
trigger_by_type(_) -> [].



next(1151042) -> 1151043;
next(1151041) -> 1151042;
next(1151043) -> 1151044;
next(1151040) -> 1151041;
next(1151036) -> 1151037;
next(1151039) -> 1151040;
next(1151038) -> 1151039;
next(1151037) -> 1151038;
next(1151032) -> 1151033;
next(1151033) -> 1151034;
next(1151035) -> 1151036;
next(1151034) -> 1151035;
next(1151029) -> 1151030;
next(1151028) -> 1151029;
next(1151030) -> 1151031;
next(1151031) -> 1151032;
next(1151024) -> 1151025;
next(1151025) -> 1151026;
next(1151027) -> 1151028;
next(1151026) -> 1151027;
next(1151020) -> 1151021;
next(1151023) -> 1151024;
next(1151021) -> 1151022;
next(1151022) -> 1151023;
next(1151016) -> 1151017;
next(1151017) -> 1151018;
next(1151018) -> 1151019;
next(1151019) -> 1151020;
next(1151013) -> 1151014;
next(1151014) -> 1151015;
next(1151012) -> 1151013;
next(1151015) -> 1151016;
next(1151008) -> 1151009;
next(1151009) -> 1151010;
next(1151011) -> 1151012;
next(1151010) -> 1151011;
next(1151007) -> 1151008;
next(1151006) -> 1151007;
next(1151005) -> 1151006;
next(1151004) -> 1151005;
next(1151003) -> 1151004;
next(1150044) -> 1151001;
next(1151002) -> 1151003;
next(1151001) -> 1151002;
next(1150041) -> 1150042;
next(1150042) -> 1150043;
next(1150040) -> 1150041;
next(1150043) -> 1150044;
next(1150036) -> 1150037;
next(1150037) -> 1150038;
next(1150038) -> 1150039;
next(1150039) -> 1150040;
next(1150033) -> 1150034;
next(1150034) -> 1150035;
next(1150032) -> 1150033;
next(1150035) -> 1150036;
next(1150029) -> 1150030;
next(1150028) -> 1150029;
next(1150031) -> 1150032;
next(1150030) -> 1150031;
next(1150027) -> 1150028;
next(1150026) -> 1150027;
next(1150025) -> 1150026;
next(1150024) -> 1150025;
next(1150021) -> 1150022;
next(1150022) -> 1150023;
next(1150023) -> 1150024;
next(1150020) -> 1150021;
next(1150019) -> 1150020;
next(1150016) -> 1150017;
next(1150018) -> 1150019;
next(1150017) -> 1150018;
next(1150014) -> 1150015;
next(1150015) -> 1150016;
next(1150012) -> 1150013;
next(1150013) -> 1150014;
next(1150010) -> 1150011;
next(1150009) -> 1150010;
next(1150011) -> 1150012;
next(1150008) -> 1150009;
next(1150006) -> 1150007;
next(1150004) -> 1150005;
next(1150007) -> 1150008;
next(1150005) -> 1150006;
next(1149004) -> 1150001;
next(1150003) -> 1150004;
next(1150001) -> 1150002;
next(1150002) -> 1150003;
next(1149001) -> 1149002;
next(1149002) -> 1149003;
next(1148004) -> 1149001;
next(1149003) -> 1149004;
next(1147004) -> 1148001;
next(1148002) -> 1148003;
next(1148003) -> 1148004;
next(1148001) -> 1148002;
next(1147001) -> 1147002;
next(1147002) -> 1147003;
next(1146004) -> 1147001;
next(1147003) -> 1147004;
next(1146002) -> 1146003;
next(1146003) -> 1146004;
next(1145004) -> 1146001;
next(1146001) -> 1146002;
next(1144004) -> 1145001;
next(1145002) -> 1145003;
next(1145001) -> 1145002;
next(1145003) -> 1145004;
next(1144002) -> 1144003;
next(1144001) -> 1144002;
next(1143004) -> 1144001;
next(1144003) -> 1144004;
next(1143003) -> 1143004;
next(1143002) -> 1143003;
next(1142004) -> 1143001;
next(1143001) -> 1143002;
next(1142003) -> 1142004;
next(1142002) -> 1142003;
next(1141004) -> 1142001;
next(1142001) -> 1142002;
next(1141003) -> 1141004;
next(1140004) -> 1141001;
next(1141001) -> 1141002;
next(1141002) -> 1141003;
next(1140003) -> 1140004;
next(1139004) -> 1140001;
next(1140001) -> 1140002;
next(1140002) -> 1140003;
next(1139001) -> 1139002;
next(1139002) -> 1139003;
next(1138006) -> 1139001;
next(1139003) -> 1139004;
next(1138005) -> 1138006;
next(1138004) -> 1138005;
next(1138001) -> 1138002;
next(1137004) -> 1138001;
next(1138003) -> 1138004;
next(1138002) -> 1138003;
next(1136005) -> 1137001;
next(1137001) -> 1137002;
next(1137003) -> 1137004;
next(1137002) -> 1137003;
next(1135005) -> 1136001;
next(1136001) -> 1136002;
next(1136002) -> 1136003;
next(1136003) -> 1136004;
next(1136004) -> 1136005;
next(1135001) -> 1135002;
next(1135002) -> 1135003;
next(1135003) -> 1135004;
next(1135004) -> 1135005;
next(1134004) -> 1135001;
next(1134002) -> 1134003;
next(1133005) -> 1134001;
next(1134001) -> 1134002;
next(1134003) -> 1134004;
next(1133002) -> 1133003;
next(1132004) -> 1133001;
next(1133001) -> 1133002;
next(1133003) -> 1133004;
next(1133004) -> 1133005;
next(1131005) -> 1132001;
next(1132002) -> 1132003;
next(1132001) -> 1132002;
next(1132003) -> 1132004;
next(1131004) -> 1131005;
next(1130005) -> 1131001;
next(1131001) -> 1131002;
next(1131002) -> 1131003;
next(1131003) -> 1131004;
next(1130002) -> 1130003;
next(1130003) -> 1130004;
next(1130001) -> 1130002;
next(1129004) -> 1130001;
next(1130004) -> 1130005;
next(1128004) -> 1129001;
next(1129003) -> 1129004;
next(1129002) -> 1129003;
next(1129001) -> 1129002;
next(1128001) -> 1128002;
next(1128002) -> 1128003;
next(1128003) -> 1128004;
next(1127006) -> 1128001;
next(1127004) -> 1127005;
next(1127005) -> 1127006;
next(1127001) -> 1127002;
next(1127002) -> 1127003;
next(1126007) -> 1127001;
next(1127003) -> 1127004;
next(1126005) -> 1126006;
next(1126006) -> 1126007;
next(1126003) -> 1126004;
next(1126004) -> 1126005;
next(1126001) -> 1126002;
next(1126002) -> 1126003;
next(1125005) -> 1126001;
next(1125002) -> 1125003;
next(1125004) -> 1125005;
next(1125001) -> 1125002;
next(1124007) -> 1125001;
next(1125003) -> 1125004;
next(1124002) -> 1124003;
next(1124006) -> 1124007;
next(1123005) -> 1124001;
next(1124003) -> 1124004;
next(1124004) -> 1124005;
next(1124005) -> 1124006;
next(1124001) -> 1124002;
next(1123002) -> 1123003;
next(1123003) -> 1123004;
next(1123004) -> 1123005;
next(1123001) -> 1123002;
next(1122005) -> 1123001;
next(1121007) -> 1122001;
next(1122002) -> 1122003;
next(1122001) -> 1122002;
next(1122004) -> 1122005;
next(1122003) -> 1122004;
next(1121006) -> 1121007;
next(1121005) -> 1121006;
next(1121004) -> 1121005;
next(1121002) -> 1121003;
next(1121003) -> 1121004;
next(1120005) -> 1121001;
next(1121001) -> 1121002;
next(1120001) -> 1120002;
next(1119004) -> 1120001;
next(1120002) -> 1120003;
next(1120003) -> 1120004;
next(1120004) -> 1120005;
next(1119003) -> 1119004;
next(1119002) -> 1119003;
next(1118005) -> 1119001;
next(1119001) -> 1119002;
next(1118001) -> 1118002;
next(1118004) -> 1118005;
next(1118002) -> 1118003;
next(1117004) -> 1118001;
next(1118003) -> 1118004;
next(1117002) -> 1117003;
next(1116006) -> 1117001;
next(1117001) -> 1117002;
next(1117003) -> 1117004;
next(1116005) -> 1116006;
next(1116004) -> 1116005;
next(1116001) -> 1116002;
next(1116003) -> 1116004;
next(1116002) -> 1116003;
next(1115004) -> 1116001;
next(1114004) -> 1115001;
next(1115003) -> 1115004;
next(1115002) -> 1115003;
next(1115001) -> 1115002;
next(1114003) -> 1114004;
next(1114002) -> 1114003;
next(1114001) -> 1114002;
next(1113004) -> 1114001;
next(1113002) -> 1113003;
next(1113001) -> 1113002;
next(1112008) -> 1113001;
next(1113003) -> 1113004;
next(1111506) -> 1112001;
next(1112002) -> 1112003;
next(1112004) -> 1112005;
next(1112003) -> 1112004;
next(1112007) -> 1112008;
next(1112006) -> 1112007;
next(1112001) -> 1112002;
next(1112005) -> 1112006;
next(1111503) -> 1111504;
next(1111501) -> 1111502;
next(1111006) -> 1111501;
next(1111502) -> 1111503;
next(1111504) -> 1111505;
next(1111505) -> 1111506;
next(1111003) -> 1111004;
next(1111002) -> 1111003;
next(1111004) -> 1111005;
next(1110505) -> 1111001;
next(1111001) -> 1111002;
next(1111005) -> 1111006;
next(1110502) -> 1110503;
next(1110006) -> 1110501;
next(1110501) -> 1110502;
next(1110504) -> 1110505;
next(1110503) -> 1110504;
next(1110002) -> 1110003;
next(1110001) -> 1110002;
next(1110004) -> 1110005;
next(1110005) -> 1110006;
next(1110003) -> 1110004;
next(1109005) -> 1110001;
next(1109001) -> 1109002;
next(1108504) -> 1109001;
next(1109003) -> 1109004;
next(1109004) -> 1109005;
next(1109002) -> 1109003;
next(1108503) -> 1108504;
next(1108502) -> 1108503;
next(1108501) -> 1108502;
next(1108003) -> 1108501;
next(1107502) -> 1108003;
next(1107501) -> 1107502;
next(1107402) -> 1107501;
next(1107401) -> 1107402;
next(1107301) -> 1107401;
next(1107201) -> 1107301;
next(1107101) -> 1107201;
next(1107003) -> 1107101;
next(1106501) -> 1107001;
next(1107002) -> 1107003;
next(1107001) -> 1107002;
next(1106500) -> 1106501;
next(1106211) -> 1106500;
next(1106210) -> 1106211;
next(1106208) -> 1106210;
next(1106207) -> 1106208;
next(1105302) -> 1105401;
next(1104501) -> 1104701;
next(1102601) -> 1102602;
next(1106203) -> 1106204;
next(1103801) -> 1104001;
next(1103301) -> 1103302;
next(1106201) -> 1106202;
next(1103601) -> 1103701;
next(1104401) -> 1104501;
next(1103405) -> 1103501;
next(1106204) -> 1106205;
next(1102301) -> 1102401;
next(1104702) -> 1105201;
next(1106202) -> 1106203;
next(1101901) -> 1102101;
next(1104302) -> 1104401;
next(1106101) -> 1106201;
next(1101801) -> 1101901;
next(1102401) -> 1102601;
next(1101601) -> 1101701;
next(1102901) -> 1103101;
next(1101501) -> 1101502;
next(1102701) -> 1102801;
next(1101401) -> 1101402;
next(1104301) -> 1104302;
next(1104201) -> 1104301;
next(1103401) -> 1103402;
next(1103701) -> 1103801;
next(1100801) -> 1100901;
next(1100501) -> 1100502;
next(1106206) -> 1106207;
next(1106002) -> 1106101;
next(1106001) -> 1106002;
next(1103403) -> 1103404;
next(1105201) -> 1105301;
next(1105901) -> 1106001;
next(1100101) -> 1100201;
next(1105802) -> 1105901;
next(1104701) -> 1104702;
next(1104001) -> 1104201;
next(1105801) -> 1105802;
next(1103101) -> 1103201;
next(1106205) -> 1106206;
next(1101701) -> 1101801;
next(1101502) -> 1101601;
next(1100901) -> 1101001;
next(1102602) -> 1102701;
next(1100701) -> 1100801;
next(1103404) -> 1103405;
next(1103402) -> 1103403;
next(1102201) -> 1102301;
next(1103302) -> 1103401;
next(1102101) -> 1102201;
next(1103201) -> 1103301;
next(1103501) -> 1103601;
next(1105401) -> 1105402;
next(1101402) -> 1101501;
next(1105301) -> 1105302;
next(1101301) -> 1101401;
next(1105702) -> 1105801;
next(1101001) -> 1101201;
next(1105701) -> 1105702;
next(1101201) -> 1101301;
next(1105603) -> 1105701;
next(1100502) -> 1100701;
next(1105602) -> 1105603;
next(1100304) -> 1100501;
next(1105601) -> 1105602;
next(1100301) -> 1100302;
next(1105502) -> 1105601;
next(1100302) -> 1100304;
next(1102801) -> 1102901;
next(1100201) -> 1100301;
next(1105403) -> 1105501;
next(1105501) -> 1105502;
next(1105402) -> 1105403;
next(_) -> 0.




chapter(1) -> [40116,40114,40015,52701,4000003,30014,40216,40001,40007,52205,4000034,4000018,51029,51001,40009,30019,51004,30007,30018,51038,4000029,4000038,55201,51014,51050,50050,52100,40112,40014,30016,52052,51003,51035,30003,1100301,40113,40003,4000040,4000013,55401,52450,51036,51015,40002,52753,4000010,51011,30009,40011,52756,52700,4000031,51022,51031,30011,30012,40219,40008,51028,40217,4000027,4000030,4000032,51024,51044,30005,30006,52400,40111,52203,51020,52650,52051,40118,40013,40019,4000016,4000017,4000023,51023,40214,51048,4000035,52600,54507,54506,51012,30010,4000008,40212,40016,55701,4000004,4000005,51030,51017,40218,52204,55301,4000007,4000001,4000025,51006,51040,52755,30004,51009,51033,40120,4000021,51025,51047,51039,30013,40010,40115,52850,52851,4000014,50003,30001,50002,40117,50051,4000028,4000033,51037,51046,52752,40018,40017,4000019,51007,51042,30008,40213,4000012,4000011,40012,40006,52151,51027,51005,51002,30002,52754,50001,30015,54505,54504,51018,51008,4000009,51041,51034,40004,4000037,51013,51045,40211,40005,52751,4000015,51021,51043,30017,50000,40020,1100101,4000026,4000022,4000020,52350,51019,51000,40119,4000036,4000039,4000002,51010,51016,55601,4000024,51026,30020,40220,4000006,55501,55101,51049,51032,1100201,40215];
chapter(9) -> [1111506,1108504,1107402,1140001,1127006,1122005,1121006,1110505,1150015,1104701,1151041,1151024,1150044,1115004,90001,1110003,1138002,60033,1123002,1116004,1146003,1145002,1130005,1103601,1151029,1150042,1144003,1138004,920000,1102301,1109002,1106001,1137004,1117004,1150005,1127005,1125003,1102201,1150024,1112005,1151027,60107,1105502,1143003,1141001,1132003,1106101,60305,1116003,1103401,60201,1150011,1149004,1147003,1129003,1120005,1151004,1121003,1151032,1112003,1126003,60206,60103,1112002,1151013,1151016,1150035,54503,1104702,1103301,1115003,1113001,1143004,1103501,1102801,1151031,1150036,1114003,1109005,1104302,1118004,1131002,1147004,1135002,1124007,1151040,1134003,1105403,52910,1113004,1151012,1142002,1124003,1120001,1106210,1102601,1150033,54303,60108,1111001,1110501,1110004,1105402,1150014,1124004,90004,52904,1122001,1114002,1112008,1151005,1147001,1137001,1134001,1116005,1103402,1150026,1150006,1150003,1146002,1134002,1132002,1120002,54502,1129002,1118001,1151039,1130003,1121002,1133004,1123001,1121007,1104301,1122003,1114004,1110006,1109001,1150022,920001,1133005,60302,1103801,1151019,53202,1110503,1151028,1150027,1107201,1119004,1111502,1106208,54401,1148004,1140002,60303,1120003,1150002,1123005,1151014,1141003,1108501,1126005,1126002,60202,1103404,60301,1151021,1151009,1150041,1149003,53203,52906,54200,1151025,1135003,1119002,1112001,1110504,1150039,60304,1121004,1117002,1141004,1114001,1151043,1147002,1140004,60030,1151035,1151037,1105301,1106206,1105302,1151008,1149002,60104,1112006,1150009,1148001,1104501,1150017,1101901,1145001,1145004,1126007,52909,1121001,1144001,1131001,1129004,60307,1150013,1128002,1151026,1150012,60205,60032,1110002,1127004,1126006,54301,920002,1131003,1112007,1109004,1150016,1121005,54201,920004,60031,1112004,1111504,1106500,60034,1136001,1130004,1105602,1151011,1150028,1123003,1119003,1150031,1122002,1103403,1116006,1103701,1151030,1146001,1140003,1134004,1125002,53201,60105,1151042,1116001,1111503,1109003,1127001,1113002,1150023,1148002,1127003,53200,1105701,1151006,1136002,53204,1133003,60106,52905,1101801,1151033,1151036,1150037,1137002,1118003,1115001,1111505,1151020,1151023,1150021,1106205,1107001,60037,1141002,1127002,1151015,1151001,1150030,1138003,1116002,1111501,1151017,1151003,54204,1108503,1104001,1133002,1125005,1124005,1123004,1139002,1138006,60203,1107501,1124001,60208,1150025,1150020,1150004,1142001,1106211,1105601,1107301,1111006,1110005,1138001,54203,1117001,1111003,52901,1151022,1150029,1131005,1129001,1108003,1107502,1104401,1115002,1150018,1132001,1107002,1139001,1103405,1105702,1125004,60029,930000,1103302,1150008,1135001,1128001,60102,1102701,1150032,1143002,1136005,1107401,54501,1106002,1144002,1136004,1135004,60306,60204,1149001,1120004,1142003,1124002,1111005,1104201,1137003,90003,1106207,1103101,1105901,1103201,1136003,1135005,1128004,1111004,60101,1105201,1151010,1133001,1132004,1130002,1151034,1111002,1106501,1101701,1151007,1150040,1150010,1126004,1110502,1108502,1151002,54202,1105401,1102401,1106201,1151044,60308,1102602,1106202,1124006,52902,60035,1122004,1107101,1151038,1150043,1150019,1142004,1126001,1125001,1145003,1119001,1105802,1105801,1105603,1139003,1118005,1105501,1113003,1102901,1150038,1150001,920003,90002,1110001,1144004,1106204,1138005,1130001,1107003,1150007,1148003,1146004,1143001,60207,1118002,1117003,1151018,60036,1131004,1128003,1150034,1139004,1106203,54302,1102101];
chapter(7) -> [1101502,1101501];
chapter(6) -> [1101402];
chapter(4) -> [1101001,1100801,1101201,1100901];
chapter(2) -> [1100502,1100501,1100302,1100304];
chapter(8) -> [1101601];
chapter(5) -> [1101401,1101301];
chapter(3) -> [1100701];
chapter(_) -> [].



group(4) -> [52052,52051,54505,54507,54504,54506];
group(5) -> [52100];
group(12) -> [54502,54503,54501];
group(7) -> [52205,52204,52203];
group(13) -> [55601,55301,55401,55501,55201,55101,55701];
group(10) -> [54302,54303,54301];
group(9) -> [52701,52700];
group(1) -> [50003,50000,50002,50001];
group(6) -> [52151];
group(3) -> [51024,51029,51022,51032,51037,51026,51015,51008,51041,51043,51046,51028,51030,51049,51034,51009,51048,51018,51017,51004,51044,51012,51042,51002,51000,51003,51039,51020,51014,51025,51035,51040,51033,51038,51006,51013,51010,51027,51050,51019,51047,51011,51007,51021,51001,51023,51005,51031,51036,51016,51045];
group(2) -> [50050,50051];
group(11) -> [54401];
group(_) -> [].
