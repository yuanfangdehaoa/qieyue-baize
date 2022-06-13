-ifndef(WELFARE_HRL).
-define(WELFARE_HRL, ok).



%记录全服领取数量
-record(welfare, {
	  level = #{} :: map()    %等级奖励，key=level,val=已领取数量
	, power = #{} :: map()    %战力奖励，key=power,val=已领取数量
}).

%每日签到
-record(welfare_sign, {
	  signs = 0 :: integer()  %当前的签到天数
	, count = 0 :: integer()  %补签次数
	, update= 0 :: integer()  %上次更新时间
}).


%等级奖励
-record(cfg_welfare_level_reward, {
	  level
	, count             %限量
	, reward            %非限制奖励
	, reward2           %限制奖励
}).

%战力奖励
-record(cfg_welfare_power_reward, {
	  power
	, count             %限量
	, reward            %非限制奖励
	, reward2           %限制奖励
}).

%在线时长奖励
-record(cfg_welfare_online_reward, {
	  id               %
	, reward           %奖励
	, time             %在线时长
}).


%每日签到
-record(cfg_welfare_sign_reward, {
	  id               %签到天数
	, month            %轮
	, day              %日
	, reward           %奖励
	, vip              %双倍奖励vip
}).

%补签次数对应活跃度
-record(cfg_welfare_sign_count, {
	  count            %补签次数
	, active           %活跃度值
}).


%圣杯祝福
-record(cfg_welfare_grail_reward, {
	  id
	, down_line        %等级下限
	, up_line          %等级上限
}).

-record(cfg_welfare_grail_reward_exp, {
	  id 
	, count
	, exp
}).

%圣杯祝福花费
-record(cfg_welfare_grail_cost, {
	  count            %次数
	, cost             %花费
}).

%更新公告
-record(cfg_welfare_notice_reward, {
	  id
	, name             %名称
	, content          %内容
	, reward           %奖励
	, start_time       %开始时间
	, end_time         %结束时间
	, state            %状态(1-启用，0-停用)
}).

%资源大礼
-record(cfg_welfare_res_reward, {
	  id
	, reward           %奖励
}).

-endif.