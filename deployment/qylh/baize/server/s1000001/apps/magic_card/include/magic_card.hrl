-ifndef(MAGIC_CARD_HRL).
-define(MAGIC_CARD_HRL, ok).


-record(cfg_magic_card, {
	  id                   %item.id
	, star                 %星级
	, max_star             %最大星级
	, cost                 %升星消耗
	, slot                 %部位（1-普通，2-核心）
	, attr_type            %属性类型
	, base                 %普通属性
	, rare                 %极品属性
	, gate                 %解锁关卡
	, score                %评分
	, gain                 %分解获得
}).

%强化消耗
-record(cfg_magic_card_strength, {
	  id                   %魔法卡id
	, level                %强化等级
	, cost                 %升到下一级消耗的魔法星尘
	, total_cost           %该等级的总消耗
	, attrib               %属性
	, fight                %评分
}).


%槽位开放配置
-record(cfg_magic_card_pos, {
	  pos                  %槽位
	, gate                 %解锁关卡
}).

%套装技能
-record(cfg_magic_card_suite, {
	  id                   %套装id
	, com_sum              %部位数量
	, com_color            %部位品质
	, is_compose           %是否融合
	, skill_id             %技能id
	, desc                 %描述
}).

%融合
-record(cfg_magic_card_combine, {
	  type_id              %大类
	, sub_type_id          %小类
	, name                 %大类名字    
	, sname                %小类名字
	, r_item_id            %结果魔法卡id
	, c_item_id1           %消耗魔法卡id1
	, c_item_id2           %消耗魔法卡id2
	, cost                 %消耗材料
	, sort                 %排序
}).

-endif.