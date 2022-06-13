-ifndef(JOBTITLE_HRL).
-define(JOBTITLE_HRL, ok).

-record(cfg_jobtitle, {
	  id          %头衔id
	, name        %名字
	, need_power  %需要战力
	, cost        %消耗
	, attr        %增加的属性
	, next_id     %下一级id
}).

-endif.