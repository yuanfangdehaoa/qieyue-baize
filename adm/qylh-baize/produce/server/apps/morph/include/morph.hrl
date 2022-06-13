-ifndef(MORPH_HRL).
-define(MORPH_HRL, ok).

%% 幻化配置
-record(cfg_morph, {
	  id
	, type   % 幻化类型 MORPH_XXX
	, name
	, reqs   % 激活条件
	, cost   % 激活消耗
	, res    % 资源id
	, speed  % 坐骑速度
	, msgno  % 传闻id
	, color  % 品质
}).

%% 幻化升星配置
-record(cfg_morph_star, {
	  id
	, star
	, exp
	, cost
	, attrs
	, power
	, skill = 0
}).

-define(GOD_ACTIVE_STAR, 9). %激活神灵的星级

-endif.