% Automatically generated, do not edit
-module(cfg_wake).

-compile([export_all]).
-compile(nowarn_export_all).

-include("wake.hrl").

find(1, 0) -> #cfg_wake{
	career     = 1,
	wake_times = 0,
	open_level = 0,
	level      = 0,
	icon       = "",
	title      = "",
	step       = 0,
	name       = "诛龙",
	pic        = "img_role_head_1",
	res        = "",
	attribs    = [],
	skills     = [],
	new_skills = [],
	desc       = ""
};
find(1, 1) -> #cfg_wake{
	career     = 1,
	wake_times = 1,
	open_level = 120,
	level      = 150,
	icon       = "1_juexing1",
	title      = "初次觉醒",
	step       = 2,
	name       = "苍瞳炼力",
	pic        = "img_role_head_1",
	res        = "",
	attribs    = [{4,525},{6,225},{2,10500},{5,225}],
	skills     = [{102001,strength}],
	new_skills = [{101001,102001},{101002,102002},{101003,102003},{101004,102004}],
	desc       = "解锁新装备:5阶装备,6阶装备
解锁新外形:泰坦光羽,异星魔仆"
};
find(1, 2) -> #cfg_wake{
	career     = 1,
	wake_times = 2,
	open_level = 170,
	level      = 220,
	icon       = "1_juexing2",
	title      = "二次觉醒",
	step       = 2,
	name       = "地脉山魂",
	pic        = "img_role_head_1",
	res        = "model_soul_10000",
	attribs    = [{4,1575},{6,675},{2,31500},{5,675}],
	skills     = [{101009,new},{103005,strength},{103001,strength}],
	new_skills = [{102001,103001},{102002,103002},{102003,103003},{102004,103004},{0,101009},{101006,103005}],
	desc       = "解锁新装备:7阶装备,8阶装备
解锁新外形:仙林幽羽,远古光核"
};
find(1, 3) -> #cfg_wake{
	career     = 1,
	wake_times = 3,
	open_level = 270,
	level      = 280,
	icon       = "1_juexing3",
	title      = "三次觉醒",
	step       = 2,
	name       = "天域风灵",
	pic        = "img_role_head_1",
	res        = "model_soul_10002",
	attribs    = [{4,4725},{6,2025},{2,94500},{5,2025}],
	skills     = [{101011,new},{101012,new},{101010,strength}],
	new_skills = [{0,101011},{0,101012},{101009,101010}],
	desc       = "解锁新装备:9阶装备
解锁新外形:凝羽魔翼,魔龙宝珠"
};
find(1, 4) -> #cfg_wake{
	career     = 1,
	wake_times = 4,
	open_level = 300,
	level      = 370,
	icon       = "1_juexing4",
	title      = "四次觉醒",
	step       = 1,
	name       = "星涌魔神",
	pic        = "img_role_head_1",
	res        = "",
	attribs    = [{4,5250},{6,2250},{2,105000},{5,2250}],
	skills     = [],
	new_skills = [],
	desc       = "突破等级限制:等级变为觉醒等级
开启天赋系统:每级获得1点天赋点
解锁新装备：10阶装备"
};
find(1, 5) -> #cfg_wake{
	career     = 1,
	wake_times = 5,
	open_level = 500,
	level      = 540,
	icon       = "1_juexing4",
	title      = "五次觉醒",
	step       = 2,
	name       = "炼狱魔神",
	pic        = "img_role_head_1",
	res        = "",
	attribs    = [{4,6300},{6,2700},{2,126000},{5,2700}],
	skills     = [],
	new_skills = [],
	desc       = "解锁新装备：12,13阶装备
解锁新外形:圣灵羽翼,黎明之光
提升角色属性"
};
find(1, 6) -> #cfg_wake{
	career     = 1,
	wake_times = 6,
	open_level = 600,
	level      = 630,
	icon       = "1_juexing4",
	title      = "六次觉醒",
	step       = 3,
	name       = "暗羽魔神",
	pic        = "img_role_head_1",
	res        = "",
	attribs    = [{4,47250},{6,20250},{2,945000},{5,20250}],
	skills     = [],
	new_skills = [],
	desc       = "解锁新外形: 暗鸦之鸣, 神后金盏
解锁新装备: 14, 15阶装备
提升角色属性"
};
find(2, 0) -> #cfg_wake{
	career     = 2,
	wake_times = 0,
	open_level = 0,
	level      = 0,
	icon       = "",
	title      = "",
	step       = 0,
	name       = "灵姬",
	pic        = "img_role_head_2",
	res        = "",
	attribs    = [],
	skills     = [],
	new_skills = [],
	desc       = ""
};
find(2, 1) -> #cfg_wake{
	career     = 2,
	wake_times = 1,
	open_level = 120,
	level      = 150,
	icon       = "2_juexing1",
	title      = "初次觉醒",
	step       = 2,
	name       = "暗雾语者",
	pic        = "img_role_head_2",
	res        = "",
	attribs    = [{4,525},{6,225},{2,10500},{5,225}],
	skills     = [{202001,strength}],
	new_skills = [{201001,202001},{201002,202002},{201003,202003},{201004,202004}],
	desc       = "解锁新装备:5阶装备,6阶装备
解锁新外形:泰坦光羽,异星魔仆"
};
find(2, 2) -> #cfg_wake{
	career     = 2,
	wake_times = 2,
	open_level = 170,
	level      = 220,
	icon       = "2_juexing2",
	title      = "二次觉醒",
	step       = 2,
	name       = "妖隐灵姬",
	pic        = "img_role_head_2",
	res        = "model_soul_10000",
	attribs    = [{4,1575},{6,675},{2,31500},{5,675}],
	skills     = [{201009,new},{203005,strength},{203001,strength}],
	new_skills = [{202001,203001},{202002,203002},{202003,203003},{202004,203004},{0,201009},{201006,203005}],
	desc       = "解锁新装备:7阶装备,8阶装备
解锁新外形:仙林幽羽,远古光核"
};
find(2, 3) -> #cfg_wake{
	career     = 2,
	wake_times = 3,
	open_level = 270,
	level      = 280,
	icon       = "2_juexing3",
	title      = "三次觉醒",
	step       = 2,
	name       = "月陨星使",
	pic        = "img_role_head_2",
	res        = "model_soul_10002",
	attribs    = [{4,4725},{6,2025},{2,94500},{5,2025}],
	skills     = [{201011,new},{201012,new},{201010,strength}],
	new_skills = [{0,201011},{0,201012},{201009,201010}],
	desc       = "解锁新装备:9阶装备
解锁新外形:凝羽魔翼,魔龙宝珠"
};
find(2, 4) -> #cfg_wake{
	career     = 2,
	wake_times = 4,
	open_level = 300,
	level      = 370,
	icon       = "2_juexing3",
	title      = "四次觉醒",
	step       = 1,
	name       = "光逝女神",
	pic        = "img_role_head_2",
	res        = "",
	attribs    = [{4,5250},{6,2250},{2,105000},{5,2250}],
	skills     = [],
	new_skills = [],
	desc       = "突破等级限制:等级变为觉醒等级
开启天赋系统:每级获得1点天赋点
解锁新装备：10阶装备"
};
find(2, 5) -> #cfg_wake{
	career     = 2,
	wake_times = 5,
	open_level = 500,
	level      = 540,
	icon       = "2_juexing3",
	title      = "五次觉醒",
	step       = 2,
	name       = "天空女神",
	pic        = "img_role_head_2",
	res        = "",
	attribs    = [{4,6300},{6,2700},{2,126000},{5,2700}],
	skills     = [],
	new_skills = [],
	desc       = "解锁新装备：12,13阶装备
解锁新外形:圣灵羽翼,黎明之光
提升角色属性"
};
find(2, 6) -> #cfg_wake{
	career     = 2,
	wake_times = 6,
	open_level = 600,
	level      = 630,
	icon       = "2_juexing3",
	title      = "六次觉醒",
	step       = 3,
	name       = "圣翼女神",
	pic        = "img_role_head_2",
	res        = "",
	attribs    = [{4,47250},{6,20250},{2,945000},{5,20250}],
	skills     = [],
	new_skills = [],
	desc       = "解锁新外形: 暗鸦之鸣, 神后金盏
解锁新装备: 14, 15阶装备
提升角色属性"
};
find(_, _) -> undefined.
