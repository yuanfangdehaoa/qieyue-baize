-ifndef(VIP_HRL).
-define(VIP_HRL, ok).

-define(VIP_WELFARE_DAILY_EXP  , 1).
-define(VIP_WELFARE_WEEKLY_GIFT, 3).

%% vip 等级
-record(cfg_vip_level, {
	  level  % vip 等级
	, exp    % 升级所需经验
	, reward % vip 等级奖励
	, gift   % 周礼包
	, gold   % 每日元宝上限
	, bgold  % 每日绑元上限
	, vipexp % 每日vip经验
	, buffs  % vip buff
	, attrs  % vip 属性
}).

%% vip 卡
-record(cfg_vip_card, {
	  id    % id
	, item  % 对应的道具id
	, level % 对应的 vip 等级
	, exp   % 增加的 vip 经验
	, last  % 持续时长
	, goods % 对应商品id
}).

-record(cfg_vip_mcard, {type, reward}).

-record(cfg_vip_invest_reward, {grade, level, reward, bgold}).

-define(INVEST_STATE_REWARD, 1). %可领取
-define(INVEST_STATE_FETCH, 2). %已领取

-record(r_vip_invest, {grade=0, list=[]}).

-record(r_vip_rebate, {
	  time  % 返还时间
	, fetch % 领取时间
}).

-record(r_vip_taste, {
	  stime % 体验开始时间
	, etime % 体验结束时间
}).

-endif.