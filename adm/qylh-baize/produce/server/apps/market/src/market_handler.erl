%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(market_handler).

-include_lib("stdlib/include/qlc.hrl").

-include("bag.hrl").
-include("game.hrl").
-include("market.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/3]).
-export([update_deal_times/2]).
-export([update_gain_gold/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 商品统计
handle(?MARKET_STAT, Tos, RoleSt) ->
	#m_market_stat_tos{type=Type1} = Tos,
	Market = market_server:get_market(),
	Stat = maps:fold(fun
		({Type2, SType}, Num, Acc) ->
			case Type1 == Type2 of
				true  -> maps:put(SType, Num, Acc);
				false -> Acc
			end
	end, #{}, Market#market.count),
	?ucast(#m_market_stat_toc{
		type  = Type1,
		stat  = Stat,
		times = role_count:get_times(?ROLE_COUNT_MARKET_DEAL)
	});

%% 商品列表
handle(?MARKET_LIST, Tos, RoleSt) ->
	#m_market_list_tos{type=Type, stype=SType} = Tos,
	#market{group=Group} = market_server:get_market(),
	TradeIDs = case SType == 0 of
		true  ->
			lists:foldl(fun
				(SType2, Acc) ->
					maps:get({Type, SType2}, Group, []) ++ Acc
			end, [], cfg_market_stype:stype(Type));
		false ->
			maps:get({Type, SType}, Group, [])
	end,
	QH = qlc:q([market_util:p_market_item(Trade)
		|| Trade <- ets:table(?ETS_TRADE),
		   lists:member(Trade#trade.id, TradeIDs)
	]),
	?ucast(#m_market_list_toc{type=Type, stype=SType, items=qlc:e(QH)});

%% 商品详情
handle(?MARKET_DETAIL, Tos, RoleSt) ->
	#m_market_detail_tos{uid=TradeID} = Tos,
	{ok, Trade} = market_server:get_trade(TradeID),
	?ucast(#m_market_detail_toc{item=item_util:p_item(Trade#trade.item)});

% 搜索
handle(?MARKET_SEARCH, Tos, RoleSt) ->
	#m_market_search_tos{item_ids=ItemIDs} = Tos,
	QH = qlc:q([market_util:p_market_item(Trade)
		|| Trade = #trade{item=Item, type=Type} <- ets:table(?ETS_TRADE),
		   Type == ?TRADE_TYPE_SALE,
		   lists:member(Item#p_item.id, ItemIDs)
	]),
	?ucast(#m_market_search_toc{items=qlc:e(QH)});

%% 已上架商品
handle(?MARKET_SALING, _Tos, RoleSt) ->
	#role_st{role=RoleID} = RoleSt,
	#market{saling=Saling} = market_server:get_market(),
	Mine = maps:get(RoleID, Saling, []),
	QH = qlc:q([market_util:p_market_item(Trade)
		|| Trade <- ets:table(?ETS_TRADE),
		   lists:member(Trade#trade.id, Mine)
	]),
	?ucast(#m_market_saling_toc{items=qlc:e(QH)});

%% 上架
handle(?MARKET_SALE, Tos, RoleSt) ->
	#m_market_sale_tos{uid=ItemUID, num=Num, price=Price} = Tos,
	{ok, Item} = role_bag:get_item(ItemUID),
	VipLv = role_vip:get_level(),
	check_trade(VipLv, Item, Num, Price),
	#role_st{role=RoleID} = RoleSt,
	Item2 = Item#p_item{num=Num},
	Succ  = fun() ->
		{ok, Trade} = market_server:sale(RoleID, VipLv, Item2, Price),
		Trade
	end,
	Cost = [{cellid, ItemUID, Num}],
	{ok, _, Trade} = role_bag:cost(Cost, ?LOG_MARKET_SALE, Succ, RoleSt),
	role_event:event(?EVENT_MARKET_SALE, Num),
	?ucast(#m_market_sale_toc{item=market_util:p_market_item(Trade)}),
	update_deal_times(1, RoleSt);

%% 指定交易信息
handle(?MARKET_DEALING, _Tos, RoleSt) ->
	#role_st{role=RoleID} = RoleSt,
	#market{dealing=Dealing} = market_server:get_market(),
	{FromMe, ToMe} = lists:foldl(fun
		({FromRole, ToRole, TradeID}, Acc={AccFrom, AccTo}) when RoleID == FromRole ->
			case market_server:get_trade(TradeID) of
				{ok, Trade} ->
					{[p_market_deal(FromRole, ToRole, Trade) | AccFrom], AccTo};
				_ ->
					?error("unexist trade: ~w", [TradeID]),
					Acc
			end;
		({FromRole, ToRole, TradeID}, Acc={AccFrom, AccTo}) when RoleID == ToRole ->
			case market_server:get_trade(TradeID) of
				{ok, Trade} ->
					{AccFrom, [p_market_deal(FromRole, ToRole, Trade) | AccTo]};
				_ ->
					?error("unexist trade: ~w", [TradeID]),
					Acc
			end;
		(_, Acc) ->
			Acc
	end, {[], []}, Dealing),
	?ucast(#m_market_dealing_toc{from_me=FromMe, to_me=ToMe});

%% 指定交易上架
handle(?MARKET_DEAL, Tos, RoleSt) ->
	#m_market_deal_tos{
		to_role=ToRole, item_uid=ItemUID, item_num=Num, price=Price
	} = Tos,
	VipLv  = role_vip:get_level(),
	IsOpen = cfg_vip_rights:find(?VIP_RIGHTS_MARKET_DEAL, VipLv, 0),
	?_check(IsOpen == 1, ?ERR_MARKET_LOW_VIPLV),
	{ok, Item} = role_bag:get_item(ItemUID),
	check_trade(VipLv, Item, Num, Price),
	#role_st{role=RoleID} = RoleSt,
	IsFriend = friend_server:is_friend(RoleID, ToRole),
	?_check(IsFriend, ?ERR_MARKET_DEAL_ONLY_FRIEND),
	Item2 = Item#p_item{num=Num},
	Succ  = fun() ->
		{ok, Trade} = market_server:deal(RoleID, VipLv, ToRole, Item2, Price),
		Trade
	end,
	Cost = [{cellid, ItemUID, Num}],
	{ok, _, Trade} = role_bag:cost(Cost, ?LOG_MARKET_DEAL, Succ, RoleSt),
	Toc = #m_market_deal_toc{deal=p_market_deal(RoleID, ToRole, Trade)},
	?ucast(Toc),
	?ucast(ToRole, Toc),
	update_deal_times(1, RoleSt);

%% 下架
handle(?MARKET_REMOVE, Tos, RoleSt) ->
	#m_market_remove_tos{type=Type, uid=TradeID} = Tos,
	Empty = role_bag:get_empty(?BAG_ID_MAIN),
	?_check(Empty >= 1, ?ERR_BAG_NO_SPACE),
	#role_st{role=RoleID} = RoleSt,
	{ok, Trade} = market_server:remove(RoleID, Type, TradeID),
	role_bag:gain([Trade#trade.item], ?LOG_MARKET_REMOVE, RoleSt),
	?ucast(#m_market_remove_toc{type=Type, uid=TradeID}),
	update_deal_times(-1, RoleSt);

%% 修改价格
handle(?MARKET_ALTER, Tos, RoleSt) ->
	#m_market_alter_tos{uid=TradeID, price=Price} = Tos,
	#role_st{role=RoleID} = RoleSt,
	?_check(Price > 0, ?ERR_GAME_BAD_ARGS),
	ok = market_server:alter(RoleID, TradeID, Price),
	?ucast(#m_market_alter_toc{uid=TradeID, price=Price});

%% 购买
handle(?MARKET_BUY, Tos, RoleSt) ->
	#m_market_buy_tos{type=Type, uid=TradeID, num=Num, price=Price} = Tos,
	enum:check_trade_type(Type),
	?_check(Num > 0, ?ERR_GAME_BAD_ARGS),
	check_times(role_vip:get_level()),
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	Succ = fun() ->
		{ok, Trade} = market_server:buy(RoleID, Type, TradeID, Num, Price),
		Trade
	end,

	Gold = Price * Num,
	MoneyID = market_util:money_id(),
	{ok, _, Trade} = role_bag:cost(
		[{MoneyID, Gold}], ?LOG_MARKET_BUY, Succ, RoleSt
	),
	#trade{item=Item, owner=Owner} = Trade,
	mail:send(RoleID, ?MAIL_MARKET_BUY, [Item#p_item{num=Num}]),
	?ucast(#m_market_buy_toc{type=Type, uid=TradeID}),
	update_deal_times(1, RoleSt),
	log_api:log_market(RoleID, Trade, Num),

	{GainLimen, CostLimen} = cfg_game:market_monitor(),

	CostKey = ?ROLE_COUNT_MARKET_COST_GOLD,
	role_count:add_times(CostKey, Gold),
	CostGold = role_count:get_times(CostKey),
	?_if(CostGold >= CostLimen, log_api:log_market_exception(RoleID, RoleName, 1, CostGold)),

	case Owner > 0 of
		true  ->
			case role:is_alive(Owner) of
				true  ->
					role:route(Owner, ?MODULE, update_gain_gold, Gold);
				false ->
					GainKey = ?ROLE_COUNT_MARKET_GAIN_GOLD,
					role_count:dirty_add_times(Owner, GainKey, Gold),
					GainGold = role_count:dirty_get_times(Owner, GainKey),
					{ok, #role_cache{name=OwnerName}} = role:get_cache(Owner),
					?_if(
						GainGold >= GainLimen,
						log_api:log_market_exception(Owner, OwnerName, 2, GainGold)
					)
			end;
		false ->
			ignore
	end;

%% 拒绝交易
handle(?MARKET_REFUSE, Tos, RoleSt) ->
	#m_market_refuse_tos{uid=TradeID} = Tos,
	ok = market_server:refuse(RoleSt#role_st.role, TradeID),
	?ucast(#m_market_refuse_toc{uid=TradeID});

%% 交易日志
handle(?MARKET_LOG, _Tos, RoleSt) ->
	Logs = game_logger:get_logs({market, RoleSt#role_st.role}),
	?ucast(#m_market_log_toc{logs=Logs}).

%% 更新交易次数
update_deal_times(Incr, RoleSt) ->
	role_count:add_times(?ROLE_COUNT_MARKET_DEAL, Incr),
	Times = role_count:get_times(?ROLE_COUNT_MARKET_DEAL),
	?ucast(#m_market_dealtimes_toc{times=Times}).

update_gain_gold(Gold, RoleSt) ->
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	GainKey = ?ROLE_COUNT_MARKET_GAIN_GOLD,
	role_count:add_times(GainKey, Gold),
	GainGold = role_count:get_times(GainKey),
	{GainLimen, _} = cfg_game:market_monitor(),
	?_if(
		GainGold >= GainLimen,
		log_api:log_market_exception(RoleID, RoleName, 2, GainGold)
	),
	ok.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_trade(VipLv, Item, Num, Price) ->
	?_check(Num > 0, ?ERR_GAME_BAD_ARGS),
	?_check(Item#p_item.num >= Num, ?ERR_GAME_BAD_ARGS),
	?_check(not Item#p_item.bind, ?ERR_MARKET_BIND_ITEM),
	CfgPrice = cfg_market_item:price(Item#p_item.id),
	?_check(CfgPrice /= ?nil, ?ERR_MARKET_CANNOT_TRADE),
	#cfg_market_price{min=Min, max=Max} = CfgPrice,
	?_check(Min =< Price andalso Price =< Max, ?ERR_MARKET_BAD_PRICE),
	check_times(VipLv).

check_times(VipLv) ->
	CurTimes = role_count:get_times(?ROLE_COUNT_MARKET_DEAL),
	MaxTimes = cfg_vip_rights:find(?VIP_RIGHTS_MARKET_TIMES, VipLv, 0),
	?_check(CurTimes < MaxTimes, ?ERR_MARKET_MAX_DEAL_TIMES).

p_market_deal(FromRole, ToRole, Trade) ->
	{ok, #role_cache{name=FromName}} = role:get_cache(FromRole),
	{ok, #role_cache{name=ToName}} = role:get_cache(ToRole),
	#p_market_deal{
		from_id   = FromRole,
		from_name = FromName,
		to_id     = ToRole,
		to_name   = ToName,
		item      = market_util:p_market_item(Trade)
	}.
