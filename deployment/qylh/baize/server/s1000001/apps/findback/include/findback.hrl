-ifndef(FINDBACK_HRL).
-define(FINDBACK_HRL, ok).

-record(cfg_findback, {
	  key          %"id@sub_id"
	, module       %后端模块
	, cost         %单次找回价格{金币item_id,num}, {绑元item_id,num}
	, exp_type     %经验类型(不同类型用不同公式)
	, params       %参数
	, drops        %掉落包奖励
	, dropsgold    %金币找回奖励
	, event        %副本通关事件{9, 副本id}
	, role_count     %计数器 {group,id}
	, max_count      %最大可找回次数
	, vip_role_count %vip次数计数器 {group,id}
	, vip_rights     %vip权限额外次数
	, vip_cost       %额外次数单次花费
}).


-endif.