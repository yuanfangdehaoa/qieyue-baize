-ifndef(BABY_HRL).
-define(BABY_HRL, ok).

-define(BABY_LIKE_RANK, 1017).

-record(baby_cache, {
	  id
	, baby_order
	, wing_id
}).

-record(cfg_baby, {
	  gender               %性别
	, name                 %名字
	, reqs                 %进度值要求
	, play_gain            %逗宝宝奖励
	, play_count           %逗宝宝有奖励的次数
	, growitem             %升级道具            
	, id                   %对应的第一个宝宝id
	, mall                 %商城跳转
}).

%宝宝升级表
-record(cfg_baby_level, {
	  gender
	, level              %等级
	, cost               %升到该级的消耗
	, attr               %增加属性
}).


%宝宝进阶表
-record(cfg_baby_order, {
	  id                %id
	, type_id           %类型
	, gender            %性别
	, order             %阶
	, res_id            %资源id
	, name              %名称
	, exp               %升阶需要经验
	, cost              %升阶使用道具
	, attr              %属性加成
	, skill             %技能
	, active            %激活消耗
	, next_id           %下一个宝宝id
	, msgno             %传闻id
}).

%宝宝点赞榜奖励
-record(cfg_baby_like_reward, {
	  rank_min
	, rank_max
	, gain
}).

%子女装备
-record(cfg_baby_equip, {
	  id
	, slot             %部位
	, base             %基础属性
	, gain             %分解获得
}).


%子女装备强化表
-record(cfg_baby_equip_level, {
	  slot             %部位
	, level            %等级
	, attr             %属性
	, cost             %升到下一级消耗
}).

%子女翅膀
-record(cfg_baby_wing_morph, {
	  id
	, name
	, reqs   % 激活条件
	, cost   % 激活消耗
	, res    % 资源id
}).

%子女翅膀升级
-record(cfg_baby_wing_star, {
	  id
	, star
	, cost
	, attrs
	, power
}).


-endif.