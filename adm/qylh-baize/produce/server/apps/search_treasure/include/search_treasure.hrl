-ifndef(SEARCH_TREASURE_HRL).
-define(SEARCH_TREASURE_HRL, ok).

-define(searchtreasure_message, {'@searchtreasure_message', TypeId}).


%数据库记录数据
-record(searchtreaure_item, {
	  bless_value = 0 :: integer()  %祝福值
	, turn = 1 :: integer()         %当前轮次
    , messages = [] :: list()       %寻宝记录
}).

%批次表
-record(cfg_searchtreasure_batch, {
	  id            %批次id
	, type_id       %类型
	, first_bless_value  %首轮祝福值  {祝福值,权重}
	, bless_value        %次轮祝福值  {祝福值,权重}
	, max_bless_value    %满祝福值
	, open_server_days   %开服天数范围   格式:{1,3}
	, player_level       %玩家等级范围   格式:{1,30}
	, cost               %花费           格式:{count,item_id,num},{count,item_id,num},{50,item_id,45}
	, gain               %获得积分
	}).


%奖池表
-record(cfg_searchtreasure_rewards, {
	  id
	, type_id        %类型
	, batch_id       %批次
	, prob           %权重 [{最小祝福值,最大祝福值,权重},...]
	, rewards        %奖励 {item_id, num}
	, is_rare        %是否珍稀(0-普通，1-珍稀)
	, is_broadcast   %传闻(0-不，1-是)
	, channel        %展示频道
	, is_notice      %公告栏(0-不，1-是)
	}).


-endif.