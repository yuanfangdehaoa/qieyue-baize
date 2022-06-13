-ifndef(WAKE_HRL).
-define(WAKE_HRL, ok).


-record(cfg_wake, {
	  career              %职业
	, wake_times          %觉醒次数
	, open_level          %开放等级
	, level               %觉醒等级
	, icon                %图标
	, title               %标题
	, step                %段数
	, name                %名字
	, pic                 %头像id
	, res                 %模型id
	, attribs             %属性加成
	, skills              %技能
	, new_skills          %新技能 {old_skillid,new_sill_id},
    , desc                %描述
}).

-record(cfg_wake_step, {
	  wake_times          %觉醒次数
	, step                %觉醒阶段
    , tasks             %任务id
	, grid                % 需要开启格子数
}).

-record(cfg_wake_grid, {
	  id                 %格子id
	, name               %名称
	, pre_id             %前置id
	, next_id            %下一id
	, cost               %优先消耗道具
	, cost_exp           %消耗经验
	, attr               %增加属性
}).

-endif.