-ifndef(ACHIEVE_HRL).
-define(ACHIEVE_HRL, ok).

-record(cfg_achieve, {
	  id
	, group         %所属分组
	, title         %标题
	, desc          %描述
	, point         %成就点
	, reward        %奖励
	, target        %目标{事件id, 内容}
}).


-endif.