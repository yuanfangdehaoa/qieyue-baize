-ifndef(TARGET_HRL).
-define(TARGET_HRL, ok).

-record(cfg_target, {
	  id            %主题id
	, name          %主题名称
	, pre_id        %前置id
	, limit         %其他限制
	, skill         %主题奖励技能
	, tasks         %主题任务
}).

-record(cfg_target_task, {
	  id            %任务id
	, name          %名称
	, type          %任务种类
	, goals         %任务类容{xx,xx,...},...
	, gain          %奖励
	, desc          %描述
}).

-endif.