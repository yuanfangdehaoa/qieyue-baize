-ifndef(PET_HRL).
-define(PET_HRL, ok).


-record(cfg_pet, {
	  id
	, order         %阶数
	, name          %名字
	, wake          %觉醒要求
	, level         %等级要求
	, quality       %品质
	, evolution     %可突破次数
	, base          %基本属性
	, count         %天生属性条数
	, rare1         %蓝属性
	, rare2         %紫属性
	, rare3         %橙属性
	, gain          %分解获得
	, atk           %继承伤害
}).

%宠物训练
-record(cfg_pet_strong, {
	  order         %阶
	, cross         %当前阶段
	, percent       %加成百分比(填万分比值)
	, base          %当前阶段属性基础加成
	, max           %当前阶段属性上限值{key,value,权重}
	, add_value     %属性增加{属性key,value}
	, strength_cost %训练消耗
	, cross_cost    %超越消耗
	, plus_percent  %额外增加属性万分比
}).


%突破
-record(cfg_pet_evolution, {
	  order        %阶
	, times        %突破次数
	, cost         %消耗
	, skill        %技能
	, attr         %属性
	, normal_atk    %变身前技能
	, change_atk    %变身后技能
	, profound      %变身技能
	, passive       %被动技能
	, fight_attr    %出战增加属性
}).

%融合
-record(cfg_pet_compose, {
	  id           %主键
	, type_id      %分类
	, level        %开放等级
	, target       %目标宠物
	, cost         %需求宠物
	, proba        %融合成功率（万分比）
	, compose_key
}).


-record(cfg_pet_equip, {
      id
    , order
    , star
    , cost
    , base
    , rare1
    , rare2
    , rare3
    , exp
    , limit
}).

-record(cfg_pet_equip_strength, {
	  slot
	, level
	, cost
	, attr
}).

-record(cfg_pet_equip_attr, {
	  color
	, star
	, attr
}).

-endif.