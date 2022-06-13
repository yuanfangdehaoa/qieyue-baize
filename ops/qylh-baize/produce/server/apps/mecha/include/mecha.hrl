
-record(cfg_mecha_star, {id, star, cost, attrs, power, skill}).

-record(cfg_mecha, {
      id
    , name
    , color  % 品质
}).

-record(cfg_mecha_upgrade, {level, exp, attrs}).


-record(cfg_mecha_equip, {
	  id
	, slot             %部位
	, base             %基础属性
	, gain             %分解获得
	, mecha_id         %机甲id
}).


%神灵装备强化表
-record(cfg_mecha_equip_level, {
	  slot             %部位
	, level            %等级
	, attr             %属性
	, cost             %升到下一级消耗
}).

%孔位开启条件
-record(cfg_mecha_equip_open, {
	  id               %机甲id
	, slot             %部位
	, open             %开启条件
}).