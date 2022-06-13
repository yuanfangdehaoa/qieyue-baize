-ifndef(RANKING_HRL).
-define(RANKING_HRL, ok).

-record(ranking, {
	  id    % 榜单id
	, size  % 榜单大小
	, sort  % 排序方法
	, list  % 榜单列表
	, limen % 阈值
	, last
}).

-record(rankitem, {
      id   % 唯一id
    , rank % 名次
    , sort % 排序字段的值
    , time % 上榜时间
    , data % 其他数据
}).

-endif.