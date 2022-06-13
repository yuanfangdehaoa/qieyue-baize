-ifndef(CASTHOUSE_HRL).
-define(CASTHOUSE_HRL, ok).


-record(cfg_casthouse, {
	  id
	, free_count      %免费色子次数
	, cost            %扔色子消耗
	, reset_cost      %重置消耗
	, model           %模型资源
	, drop_show       %显示掉落物品
	, pp              %色子权重
}).

-record(cfg_casthouse_grid, {
	  id              %格子id
	, res             %显示图片
	, drop            %掉落包 {1,[drop_id]}
	, items           %额外显示的道具id列表
	, prob            %暴击率(万分比)
	, pos             %位置 x, y
}).

-endif.