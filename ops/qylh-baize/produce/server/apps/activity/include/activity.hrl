-ifndef(ACTIVITY_HRL).
-define(ACTIVITY_HRL, ok).

%% 活动状态
-define(ACT_ST_BEREADY, 1). % 开始前，比如分区、预告等处理
-define(ACT_ST_STARTED, 2). % 进行中
-define(ACT_ST_STOPPED, 3). % 已结束

-define(ETS_ACTIVITY, ets_activity).
-record(activity, {
	  id
	, type   % 活动类型
	, group  % 活动分类
	, level  % 参与等级
	, stime  % 开启时间
	, etime  % 结束时间
	, state  % 活动状态
}).

%% 活动配置
-record(cfg_activity, {
	  id
	, name
	, group   % 活动分组
	, type    % 活动类型 ACTIVITY_TYPE_XXX
	, level   % 参与等级
	, reqs    % 开启条件
	, cycle   % 活动周期 ut_activity:cycle()
	, days    % 活动日期
	, pre     % 活动开始前多少秒处理
	, time    % 时间段
	, post    % 活动结束后多少秒处理
	, scene   % 活动场景
	, msgno   % 公告id
}).

%% 战区划分
-record(cfg_division, {
	  id    % 活动id
	, group % 活动分组
	, rule  % 分组规则
	, num   % 多少个服一组
	, min   % 最少多少个服一组
}).

-endif.