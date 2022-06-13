-ifndef(CLUSTER_HRL).
-define(CLUSTER_HRL, ok).

-define(ETS_CLUSTER_NODES, ets_cluster_nodes).

-define(ETS_CLUSTER_GROUP, ets_cluster_group).
-record(cls_group, {
	  group  % 分组id
	, rule   % 分组规则
	, cross  % CrossID
	, locals % [LocalID]
}).

-define(ETS_CLUSTER_INDEX, ets_cluster_index).
-record(cls_index, {
	  suid
	, name
	, node
	, merge % 是否已合服
}).

-endif.