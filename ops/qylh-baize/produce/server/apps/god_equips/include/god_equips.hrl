-ifndef(GOD_EQUIPS_HRL).
-define(GOD_EQUIPS_HRL, ok).

%神灵装备
-record(cfg_god_equip, {
	  id
	, slot             %部位
	, base             %基础属性
	, gain             %分解获得
}).


%神灵装备强化表
-record(cfg_god_equip_level, {
	  slot             %部位
	, level            %等级
	, attr             %属性
	, cost             %升到下一级消耗
}).

%孔位开启条件
-record(cfg_god_equip_open, {
	  slot             %部位
	, open             %开启条件
}).

-endif.