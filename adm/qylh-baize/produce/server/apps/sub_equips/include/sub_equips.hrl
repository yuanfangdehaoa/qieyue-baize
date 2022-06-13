-ifndef(SUB_EQUIPS_HRL).
-define(SUB_EQUIPS_HRL, ok).

-record(cfg_sub_equip, {
	  id
	, stype            %装备类型
	, slot             %部位
	, base             %基础属性
	, gain             %分解获得
}).


%神灵装备强化表
-record(cfg_sub_equip_level, {
	  slot             %部位
	, stype            %装备类型
	, level            %等级
	, attr             %属性
	, cost             %升到下一级消耗
}).

%孔位开启条件
-record(cfg_sub_equip_open, {
	  slot             %部位
	, stype            %装备类型
	, open             %开启条件
}).

-endif.