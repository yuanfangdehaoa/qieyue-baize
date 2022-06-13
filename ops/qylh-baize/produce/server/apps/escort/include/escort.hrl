-ifndef(ESCORT_HRL).
-define(ESCORT_HRL, ok).

%-define(ESCORT_LIST, escort_list).
%-define(ESCORT_APPLY, escort_apply_map).

%护送数据
-record(cfg_escort, {
	  id
	, attend           %参与次数
	, robcount         %劫掠次数
	, support          %支援次数
	, support_reward   %支援奖励
	, robbed           %被劫次数
	, fail_robbed      %失败被劫次数
	, protect          %保护时长
	, refresh          %免费刷新次数
	, price            %刷新消耗
	, lost             %损失比例
	, show             %品质出现权重
	, fresh            %品质刷新权重
	, max_quality      %最高品质
	, duration         %护送时间（秒）
	, double           %双倍时间段
	, random           %中间随机奖励
	, buff             %护送buffid
}).

%护送商品表
-record(cfg_escort_product, {
	  quality          %品质
	, level            %玩家等级
	, complete         %护送奖励
	, failure          %失败奖励
	, rob              %抢劫奖励
}).

%护送路线
-record(cfg_escort_road, {
	  id
	, start            %开始点 npcid
	, second           %中间点 npcid
	, end_npc          %结束点 npcid
}).

-endif.