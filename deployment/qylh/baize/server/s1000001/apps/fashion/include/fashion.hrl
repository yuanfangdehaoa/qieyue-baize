-ifndef(FASHION_HRL).
-define(FASHION_HRL, ok).

%时装
-record(cfg_fashion, {
	  id          % item.id
	, type_id     % 分类id
	, man_model   % 男模型
	, girl_model  % 女模型
	, max_star    % 最大星级
	, cost        % 激活消耗
	, time        % 有效期(秒)
	, msgno       % 广播id
}).

%时装升星
-record(cfg_fashion_star, {
	  id
	, star   % 星级
	, cost   % 升到该星级的消耗
	, attrib % 当前星级属性
	, msgno  % 广播id
}).

-endif.