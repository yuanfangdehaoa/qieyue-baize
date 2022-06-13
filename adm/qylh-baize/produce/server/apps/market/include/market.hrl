-ifndef(MARKET_HRL).
-define(MARKET_HRL, ok).

-define(ETS_TRADE, ets_trade).

-record(market, {
	  count   = #{} % key={Type, SType}, val=Num
	, group   = #{} % key={Type, SType}, val=[TradeID]
	, saling  = #{} % key=RoleID, val=[TradeID]
	, dealing = []  % [{FromRole, ToRole, TradeID}]
	, recent  = #{} % 最近交易价格 key=ItemID, val=[Price]
}).

%% 价格配置
-record(cfg_market_price, {
	  id
	, min
	, max
}).

%% 补货配置
-record(cfg_market_fill, {
	  id
	, floor % 低于此数量时触发补货
	, lap   % 叠加数量
	, fill  % 补货数量
	, price % 补货底价
}).

-endif.