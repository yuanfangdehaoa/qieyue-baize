-ifndef(YUNYING_HRL).
-define(YUNYING_HRL, ok).

-define(YY_ST_STARTED, 1).
-define(YY_ST_STOPPED, 0).

-define(YYACT_GUILD, 120401).

-define(ETS_YY_ACT, ets_yy_act).
-record(yy_act, {
	  id
	, join_level
	, join_wake
	, act_stime
	, act_etime
	, act_state
	, show_stime
	, show_etime
	, show_state
}).

-record(yy_task, {
	  id     % 奖励id
	, event
	, goal   % 任务目标---废弃
	, count  % 任务计数器
	, state  % 任务状态
}).

%% 运营活动时间配置
-record(cfg_yunying, {
	  id
	, type
	, name
	, reqs
	, level
	, wake
	, cycle
	, days
	, time  % 活动时间
	, show  % 展示时间
	, rank  % 排行榜id
	, mail
	, clear % 清理条件
	, form  % 活动形式
}).

%% 运营活动奖励配置
-record(cfg_yunying_reward, {
	  id
	, act_id
	, level
	, event   % 相关事件
	, goal    % 任务目标
	, trigger
	, reqs    % 奖励条件
	, limit   % 领取上限
	, cost
	, reward  % 奖励内容
	, misc    % 杂项
}).

-record(yy_gift, {
	  id     % 活动ID
	, refund_time  % 返利时间
	, state  % 任务状态
}).

%% 运营活动时间配置
-record(cfg_yunying_gift, {
	  id
	, refund_time
	, cycle
	, days
	, time  % 活动时间
	, desc
}).

-record(yy_lottery, {
	items        = #{},
	rewards      = [], 		% 今天抽过的
	times        = #{},    	% 抽奖次数 key = Group, val = Times
	bonus        = false, 	% 是否奖励过必出彩蛋
	free_refresh = 0,
	extra        = #{}		%
}).

%抽奖奖励
-record(cfg_yunying_lottery_rewards, {
	  id
	, yunying_id    %运营活动id
	, rewards        %奖励 {item_id, num, bind}
	, prob           %权重
	, is_rare        %是否大奖(0-普通，1-珍稀)
	, is_self        %是否个人记录(0-不，1-是)
	, is_all         %是否全服记录(0-不，1-是)
	, is_broadcast   %是否广播
	, absolute       %必中次数
}).

%翻牌奖励
-record(cfg_yunying_flop_gift, {
		round					% 轮数
	, reset					% 刷新
	, cost					% 消耗
	, reward				% 奖励
}).

-record(cfg_yunying_dunge_limit_tower, {dunge, assist}).

-record(cfg_yunying_lottery_shop, {category, rewards, total, limit, max, min}).

-endif.
