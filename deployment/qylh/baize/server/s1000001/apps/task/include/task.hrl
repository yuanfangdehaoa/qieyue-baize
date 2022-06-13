-ifndef(TASK_HRL).
-define(TASK_HRL, ok).

-record(cfg_task, {
      id      % 任务id
    , name    % 任务名称
    , type    % 任务类型
    , group   % 任务分组
    , reqs    % 触发条件
    , accept  % 是否自动接取
    , submit  % 是否自动提交
    , quest   % 任务道具
    , goals   % 任务内容
    , cost    % 完成消耗
    , gain    % 完成奖励
    , quick   % 快速完成消耗
    , time    % 时间限制
    , show    % 前端显示条件
}).

%% 任务内容
-record(task, {
      id    :: integer()
    , type  :: integer() % 任务类型
    , prog  :: integer() % 任务进度(目标进度)
    , doing :: tuple()   % 当前目标 #goal
    , count :: integer() % 目标计数器
    , rest  :: list()    % 剩余目标 [#goal]
    , state :: integer() % 任务状态
    , etime :: integer() % 限时任务结束时间
}).

%% 任务目标
-record(goal, {
      event  :: integer() % 事件 EVENT_XXX
    , target :: list()    % 目标
    , amount :: integer() % 数量
    , scene  :: integer() % 场景id
    , conds  :: list()    % 目标条件
}).


-endif.