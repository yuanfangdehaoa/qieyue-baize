%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(market_server).

-behaviour(gen_server).

-include("game.hrl").
-include("market.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("table.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([get_market/0]).
-export([get_trade/1]).
-export([get_trades/0]).
-export([sale/4]).
-export([deal/5]).
-export([remove/3]).
-export([alter/3]).
-export([buy/5]).
-export([refuse/2]).

-define(SERVER, ?MODULE).

-define(tref(TradeID), {?MODULE, TradeID}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

get_market() ->
	game_misc:read(market, #market{}).

set_market(Market) ->
	game_misc:write(market, Market).

get_trade(TradeID) ->
	case ets:lookup(?ETS_TRADE, TradeID) of
		[R] -> {ok, R};
		[]  -> ?err(?ERR_MARKET_ITEM_NOT_FOUND)
	end.

get_trades() ->
	ets:tab2list(?ETS_TRADE).

%% 上架
sale(RoleID, VipLv, Item, Price) ->
	gen_server:call(?SERVER, {sale, RoleID, VipLv, Item, Price}).

%% 交易
deal(FromRole, VipLv, ToRole, Item, Price) ->
	gen_server:call(?SERVER, {deal, FromRole, VipLv, ToRole, Item, Price}).

%% 下架
remove(RoleID, Type, TradeID) ->
	gen_server:call(?SERVER, {remove, RoleID, Type, TradeID}).

%% 修改价格
alter(RoleID, TradeID, Price) ->
	gen_server:call(?SERVER, {alter, RoleID, TradeID, Price}).

%% 购买
buy(RoleID, Type, TradeID, Num, Price) ->
	gen_server:call(?SERVER, {buy, Type, RoleID, TradeID, Num, Price}).

%% 拒绝交易
refuse(RoleID, TradeID) ->
	gen_server:call(?SERVER, {refuse, RoleID, TradeID}).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	process_flag(trap_exit, true),
	ets:new(?ETS_TRADE, [named_table, {keypos, #trade.id}]),
	{ok, undefined}.


handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
    ?try_handle_info(do_handle_info(Info, State), State).


terminate(_Reason, _State) ->
	do_dump(),
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%% 市场上架
do_handle_call({sale, RoleID, VipLv, Item, Price}, _From, State) ->
	Market = #market{count=Count, group=Group, saling=Saling} = get_market(),
	#p_item{id=ItemID, num=Num} = Item,
	Key = {Type, SType} = cfg_market_item:get_key(ItemID),
	GlobalLimit = cfg_market_stype:limit(Type, SType),
	?_check(
		length(maps:get(Key, Group, [])) < GlobalLimit,
		?ERR_MARKET_GLOBAL_NUM_LIMIT
	),
	PersonLimit = cfg_vip_rights:find(?VIP_RIGHTS_MARKET_NUM, VipLv, 0),
	?_check(
		length(maps:get(RoleID, Saling, [])) < PersonLimit,
		?ERR_MARKET_PERSON_NUM_LIMIT
	),
	Trade = add_trade(?TRADE_TYPE_SALE, RoleID, VipLv, Item, Price),
	set_market(Market#market{
		count  = ut_misc:maps_increase(Key, Num, Count),
		group  = ut_misc:maps_append(Key, Trade#trade.id, Group),
		saling = ut_misc:maps_append(RoleID, Trade#trade.id, Saling)
	}),
	{reply, {ok, Trade}, State};

%% 交易上架
do_handle_call({deal, FromRole, VipLv, ToRole, Item, Price}, _From, State) ->
	Market = #market{dealing=Dealing} = get_market(),
	SelfDealing = [Deal || Deal = {ID, _, _} <- Dealing, ID == FromRole],
	?_check(length(SelfDealing) < 6, ?ERR_MARKET_SELF_MAX_DEAL),
	PeerDealing = [Deal || Deal = {_, ID, _} <- Dealing, ID == ToRole],
	?_check(length(PeerDealing) < 6, ?ERR_MARKET_PEER_MAX_DEAL),
	Trade = add_trade(?TRADE_TYPE_DEAL, FromRole, VipLv, Item, Price),
	set_market(Market#market{
		dealing = [{FromRole, ToRole, Trade#trade.id} | Dealing]
	}),
	{reply, {ok, Trade}, State};

%% 下架
do_handle_call({remove, RoleID, _Type, TradeID}, _From, State) ->
	{ok, Trade} = get_trade(TradeID),
	?_check(Trade#trade.owner == RoleID, ?ERR_MARKET_ITEM_NOT_FOUND),
	ets:delete(?ETS_TRADE, TradeID),
	post_removed(Trade),
	{reply, {ok, Trade}, State};

%% 修改价格
do_handle_call({alter, RoleID, TradeID, Price}, _From, State) ->
	{ok, Trade} = get_trade(TradeID),
	?_check(Trade#trade.owner == RoleID, ?ERR_MARKET_ITEM_NOT_FOUND),
	#p_item{id=ItemID} = Trade#trade.item,
	#cfg_market_price{min=Min, max=Max} = cfg_market_item:price(ItemID),
	?_check(Min =< Price andalso Price =< Max, ?ERR_MARKET_BAD_PRICE),
	ets:insert(?ETS_TRADE, Trade#trade{price=Price}),
	{reply, ok, State};

%% 购买
do_handle_call({buy, ?TRADE_TYPE_SALE, RoleID, TradeID, BuyNum, Price}, _From, State) ->
	{ok, Trade} = check_buy(TradeID, BuyNum, Price),
	#trade{owner=Owner, item=Item} = Trade,
	?_check(RoleID /= Owner, ?ERR_MARKET_CANNOT_BUY_SELF),
	Market = get_market(),
	#market{count=Count, group=Group, saling=Saling, recent=Recent} = Market,
	#p_item{id=ItemID, num=OldNum} = Item,
	?_check(BuyNum =< OldNum, ?ERR_GAME_BAD_ARGS),
	Key = cfg_market_item:get_key(ItemID),
	Count2 = ut_misc:maps_increase(Key, -BuyNum, Count),
	case OldNum > BuyNum of
		true  ->
			Saling2 = Saling,
			Group2  = Group,
			Item2   = Item#p_item{num=OldNum-BuyNum},
			ets:insert(?ETS_TRADE, Trade#trade{item=Item2});
		false ->
			Saling2 = ut_misc:maps_delete(Owner, TradeID, Saling),
			Group2  = ut_misc:maps_delete(Key, TradeID, Group),
			ets:delete(?ETS_TRADE, TradeID)
	end,
	Prices  = lists:sublist([Price | maps:get(ItemID, Recent, [])], 10),
	Market2 = Market#market{
		count  = Count2,
		group  = Group2,
		saling = Saling2,
		recent = maps:put(ItemID, Prices, Recent)
	},
	post_bought(Market2, ?TRADE_TYPE_SALE, RoleID, Trade, BuyNum, Price),
	{reply, {ok, Trade}, State};

do_handle_call({buy, ?TRADE_TYPE_DEAL, RoleID, TradeID, BuyNum, Price1}, _From, State) ->
	{ok, Trade} = check_buy(TradeID, BuyNum, Price1),
	#trade{owner=Owner, item=Item} = Trade,
	Market = #market{dealing=Dealing} = get_market(),
	case Item#p_item.num > BuyNum of
		true  ->
			Dealing2 = Dealing,
			Item2    = Item#p_item{num=Item#p_item.num-BuyNum},
			ets:insert(?ETS_TRADE, Trade#trade{item=Item2});
		false ->
			Dealing2 = lists:keydelete(TradeID, 3, Dealing),
			ets:delete(?ETS_TRADE, TradeID)
	end,
	Market2 = Market#market{dealing=Dealing2},
	post_bought(Market2, ?TRADE_TYPE_DEAL, RoleID, Trade, BuyNum, Price1),
	update_deal_times(Owner, 1),
	{reply, {ok, Trade}, State};

%% 拒绝交易
do_handle_call({refuse, RoleID, TradeID}, _From, State) ->
	Market = #market{dealing=Dealing} = get_market(),
	{ok, Trade} = market_server:get_trade(TradeID),
	{FromRole, ToRole, _} = lists:keyfind(TradeID, 3, Dealing),
	?_check(ToRole == RoleID, ?ERR_MARKET_NEVER_DEAL),
	set_market(Market#market{dealing=lists:keydelete(TradeID, 3, Dealing)}),
	ets:delete(?ETS_TRADE, TradeID),
	mail:send(FromRole, ?MAIL_MARKET_REFUSE, [Trade#trade.item]),
	update_deal_times(FromRole, -1),
	{reply, ok, State};

do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.


do_handle_cast(started, State) ->
	init_market(),
	Trades = db:dirty_match_all(?DB_TRADE),
	ets:insert(?ETS_TRADE, Trades),
	set_tradeid( game_misc:read(trade_id, game_uid:gen_guid()) ),
	erlang:send(self(), fill),
	erlang:send(self(), check),
	loop_dump(),
	{noreply, State};

do_handle_cast({insert, Trades}, State) ->
	lists:foreach(fun
		(Trade) ->
			case ets:member(?ETS_TRADE, Trade#trade.id) of
				true  -> ignore;
				false -> ets:insert(?ETS_TRADE, Trade)
			end
	end, Trades),
	{noreply, State};


do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.


do_handle_info(check, State) ->
	loop_check(),
	NowSecs  = ut_time:seconds(),
	LastSecs = cfg_game:market_last(),
	ets:safe_fixtable(?ETS_TRADE, true),
    check_expire(ets:first(?ETS_TRADE), NowSecs, LastSecs),
    ets:safe_fixtable(?ETS_TRADE, false),
	{noreply, State};

do_handle_info(fill, State) ->
	loop_fill(),
	try_fill(),
	{noreply, State};

do_handle_info(dump, State) ->
	loop_dump(),
	do_dump(),
	{noreply, State};

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.

check_buy(TradeID, Num, Price1) ->
	{ok, Trade} = get_trade(TradeID),
	?_check(Trade /= ?nil, ?ERR_MARKET_ITEM_NOT_FOUND),
	#trade{item=Item, price=Price2} = Trade,
	?_check(Price1 == Price2, ?ERR_MARKET_PRICE_CHANGE),
	?_check(Item#p_item.num >= Num, ?ERR_MARKET_ITEM_NOT_ENOUGH),
	{ok, Trade}.

add_trade(Type, Owner, VipLv, Item, Price) ->
	Tax   = cfg_vip_rights:find(?VIP_RIGHTS_MARKET_TAX, VipLv, 0),
	Trade = new_trade(Type, Owner, Item, Price, Tax),
	ets:insert(?ETS_TRADE, Trade),
	Trade.

new_trade(Type, Owner, Item, Price, Tax) ->
	#trade{
		id    = get_tradeid(),
		type  = Type,
		owner = Owner,
		item  = Item,
		time  = ut_time:seconds(),
		price = Price,
		tax   = Tax
	}.

try_fill() ->
	Market  = get_market(),
	Market2 = lists:foldl(fun
		(ItemID, Acc) ->
			case cfg_market_item:fill(ItemID) of
				?nil -> Acc;
				Conf -> try_fill2(Acc, Conf)
			end
	end, Market, cfg_market_item:all()),
	set_market(Market2).

try_fill2(Market, Conf) ->
	#cfg_market_fill{
		id=ItemID, floor=Floor, lap=Lap, fill=Num, price=Price
	} = Conf,
	Key = cfg_market_item:get_key(ItemID),
	Had = length(maps:get(Key, Market#market.group, [])),
	case Had < Floor of
		true  ->
			Prices = maps:get(ItemID, Market#market.recent, []),
			Price2 = calc_price(Prices, Price),
			Item   = item_util:new_item(ItemID, Lap, #{}),
			do_fill(Num, Market, Key, Item, Price2);
		false ->
			Market
	end.

calc_price([], MinPrice) ->
	MinPrice;
calc_price(Prices, MinPrice) when length(Prices) =< 2 ->
	Avg = lists:sum(Prices) div length(Prices),
	max(MinPrice, Avg);
calc_price(Prices, MinPrice) ->
	Sorted  = lists:sort(Prices),
	Prices2 = tl( lists:reverse( tl(Sorted) ) ),
	Avg = lists:sum(Prices2) div length(Prices2),
	max(MinPrice, ut_math:ceil(Avg*1.2)).

do_fill(0, Market, _Key, _Item, _Price) ->
	Market;
do_fill(N, Market, Key, Item, Price) ->
	#market{count=Count, group=Group} = Market,
	Trade   = add_trade(?TRADE_TYPE_SALE, 0, 0, Item, Price),
	Market2 = Market#market{
		count = ut_misc:maps_increase(Key, Item#p_item.num, Count),
		group = ut_misc:maps_append(Key, Trade#trade.id, Group)
	},
	do_fill(N-1, Market2, Key, Item, Price).


check_expire('$end_of_table', _NowSecs, _LastSecs) ->
    ok;
check_expire(TradeID, NowSecs, LastSecs) ->
    [Trade] = ets:lookup(?ETS_TRADE, TradeID),
    case NowSecs >= Trade#trade.time+LastSecs of
    	true  -> post_expired(Trade, true);
    	false -> ignore
    end,
    check_expire(ets:next(?ETS_TRADE, TradeID), NowSecs, LastSecs).

post_bought(Market, Type, RoleID, Trade, Num, Price1) ->
	#trade{owner=Owner, tax=TaxRate} = Trade,
	set_market(Market),
	TaxNum = ut_math:ceil(Price1 * Num * ?_per(TaxRate)),
	Price2 = Price1 * Num - TaxNum,
	MoneyID = market_util:money_id(),
	?_if(
		Owner > 0,
		mail:send(Owner, ?MAIL_MARKET_SALE, [{MoneyID, Price2}])
	),
	MItem0 = market_util:p_market_item(Trade),
	MItem = MItem0#p_market_item{num=Num},
	NTime = ut_time:seconds(),
	Log1  = #p_market_log{
		item=MItem, type=Type, time=NTime, tax=0, inout=-Price1*Num
	},
	game_logger:add_log({market, RoleID}, Log1),
	Log2  = #p_market_log{
		item=MItem, type=Type, time=NTime, tax=TaxNum, inout=Price2
	},
	game_logger:add_log({market, Owner}, Log2).

post_expired(Trade, NeedDel) ->
	#trade{id=TradeID, owner=Owner, item=Item} = Trade,
	?_if(NeedDel, ets:delete(?ETS_TRADE, TradeID)),
	post_removed(Trade),
	?_if(Owner > 0, mail:send(Owner, ?MAIL_MARKET_EXPIRE, [Item])).

post_removed(Trade) when Trade#trade.type == ?TRADE_TYPE_SALE ->
	#trade{id=TradeID, owner=Owner, item=Item} = Trade,
	#p_item{id=ItemID, num=Num} = Item,
	Key = cfg_market_item:get_key(ItemID),
	Market  = #market{count=Count, group=Group, saling=Saling} = get_market(),
	Market2 = Market#market{
		count  = ut_misc:maps_increase(Key, -Num, Count),
		group  = ut_misc:maps_delete(Key, TradeID, Group),
		saling = ut_misc:maps_delete(Owner, TradeID, Saling)
	},
	set_market(Market2),
	Market2;
post_removed(#trade{id=TradeID}) ->
	ets:delete(?ETS_TRADE, TradeID),
	Market = #market{dealing=Dealing} = get_market(),
	Dealing2 = lists:keydelete(TradeID, 3, Dealing),
	Market2  = Market#market{dealing=Dealing2},
	set_market(Market2),
	Market2.

update_deal_times(RoleID, Incr) ->
	case role:is_alive(RoleID) of
		true  ->
			role:route(RoleID, market_handler, update_deal_times, Incr);
		false ->
			role_count:dirty_add_times(RoleID, ?ROLE_COUNT_MARKET_DEAL, Incr)
	end.

loop_check() ->
	erlang:send_after(timer:seconds(5), self(), check).

loop_fill() ->
	erlang:send_after(timer:minutes(1), self(), fill).

loop_dump() ->
	erlang:send_after(timer:minutes(15), self(), dump).

do_dump() ->
	db:clear_table(?DB_TRADE),
	lists:foreach(fun
		(Trade) ->
			db:dirty_write(?DB_TRADE, Trade)
	end, ets:tab2list(?ETS_TRADE)).

-define(k_tradeid, k_tradeid).
get_tradeid() ->
	TradeID = get(?k_tradeid),
	game_misc:write(trade_id, TradeID+1, true),
	set_tradeid(TradeID+1),
	TradeID.

set_tradeid(TradeID) ->
	put(?k_tradeid, TradeID).

init_market() ->
	Trades = db:dirty_match_all(?DB_TRADE),
	init_market2(Trades).

init_market2(Trades) ->
	Market0 = game_misc:read(market, #market{}),
	Market1 = #market{
		dealing = Market0#market.dealing,
		recent  = Market0#market.recent
	},
	Market  = lists:foldl(fun
		(Trade, Acc) ->
			#market{count=Count, group=Group, saling=Saling} = Acc,
			#trade{id=TradeID, owner=Owner, item=Item} = Trade,
			#p_item{id=ItemID, num=Num} = Item,
			Key = cfg_market_item:get_key(ItemID),
			case Trade#trade.type of
				?TRADE_TYPE_SALE ->
					Acc#market{
						count  = ut_misc:maps_increase(Key, Num, Count),
						group  = ut_misc:maps_append(Key, TradeID, Group),
						saling = ut_misc:maps_append(Owner, TradeID, Saling)
					};
				?TRADE_TYPE_DEAL ->
					Acc
			end
	end, Market1, Trades),
	set_market(Market).
