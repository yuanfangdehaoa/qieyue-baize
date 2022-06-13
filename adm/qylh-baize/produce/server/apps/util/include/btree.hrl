-ifndef(BTREE_HRL).
-define(BTREE_HRL, ok).

%% 行为树
-record(btree, {
      id
    , entry
    , nodes
}).

%% 行为树数据
-record(bdata, {
      ref
    , rootree            % 根树
    , curtree            % 运行中的 btree.id
    , running :: tuple() % 运行中的节点
    , status  :: map()   % 节点状态   key={TreeID,NodeID}, val=any()
    , counter :: map()   % 节点计数器 key={TreeID,NodeID}, val=any()
    , delay   :: list()  % 延迟执行的节点 [{TreeID,#bnode}]
    , listen  :: map()   % 事件监听   key=Event, val=[{TreeID,#bnode}]
}).

-record(bnode, {
	  id    % NodeID
	, type  % 节点类型
	, props % 节点属性
	, nodes % 子节点列表
}).

-define(SUCCESS, success).
-define(FAILURE, failure).
-define(RUNNING, running).

-endif.