% Automatically generated, do not edit
-module(cfg_target).

-compile([export_all]).
-compile(nowarn_export_all).

-include("target.hrl").

find(1) -> #cfg_target{
	id     = 1,
	name   = "魔法之魂",
	pre_id = 0,
	limit  = [{level,60}],
	skill  = 400500,
	tasks  = [801,802,803,804,805,806,807]
};
find(2) -> #cfg_target{
	id     = 2,
	name   = "古树之魂",
	pre_id = 0,
	limit  = [{level,60}],
	skill  = 400501,
	tasks  = [101,102,103,104,105,106,107]
};
find(3) -> #cfg_target{
	id     = 3,
	name   = "灵长之魂",
	pre_id = 0,
	limit  = [{level,130}],
	skill  = 400502,
	tasks  = [201,202,203,204,205,206,207]
};
find(4) -> #cfg_target{
	id     = 4,
	name   = "猛龙之魂",
	pre_id = 0,
	limit  = [{level,230}],
	skill  = 400503,
	tasks  = [301,302,303,304,305,306,307]
};
find(5) -> #cfg_target{
	id     = 5,
	name   = "精灵之魂",
	pre_id = 0,
	limit  = [{level,260}],
	skill  = 400504,
	tasks  = [401,402,403,404,405]
};
find(6) -> #cfg_target{
	id     = 6,
	name   = "神灵之魂",
	pre_id = 0,
	limit  = [{level,290}],
	skill  = 400505,
	tasks  = [501,502,503,504,505,506,507]
};
find(7) -> #cfg_target{
	id     = 7,
	name   = "攻击之魂",
	pre_id = 0,
	limit  = [{level,350}],
	skill  = 400506,
	tasks  = [601,602,603,604,605,606,607]
};
find(8) -> #cfg_target{
	id     = 8,
	name   = "战神之魂",
	pre_id = 0,
	limit  = [{level,390}],
	skill  = 400507,
	tasks  = [701,702,703,704,705,706,707]
};
find(_) -> undefined.

get_ids() -> [6,7,8,1,2,3,4,5].
