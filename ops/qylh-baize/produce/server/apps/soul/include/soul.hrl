-ifndef(SOUL_HRL).
-define(SOUL_HRL, ok).

-record(cfg_soul, {
	  id                   %item.id
	, slot                 %部位（1-普通，2-核心）
	, attr_type            %属性类型
	, base                 %普通属性
	, rare                 %极品属性
	, score                %评分
	, gain                 %分解获得
}).

%强化消耗
-record(cfg_soul_level, {
	  id                   %魔法卡id
	, level                %强化等级
	, cost                 %升到下一级消耗的魔法星尘
	, total_cost           %该等级的总消耗
	, attrib               %属性
	, fight                %评分
}).


%槽位开放配置
-record(cfg_soul_pos, {
	  pos                  %槽位
	, level                %解锁等级
}).

%融合
-record(cfg_soul_combine, {
	  type_id              %大类
	, sub_type_id          %小类
	, name                 %大类名字    
	, sname                %小类名字
	, r_item_id            %结果圣痕id
	, c_item_id1           %消耗圣痕id1
	, c_item_id2           %消耗圣痕id2
	, cost                 %消耗材料
}).


-endif.