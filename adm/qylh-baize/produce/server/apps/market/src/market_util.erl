%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(market_util).

-include("enum.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([p_market_item/1]).
-export([money_id/0]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
p_market_item(Trade = #trade{item=Item}) ->
	#p_market_item{
		uid    = Trade#trade.id,
		id     = Item#p_item.id,
		owner  = Trade#trade.owner,
		num    = Item#p_item.num,
		bind   = Item#p_item.bind,
		gender = Item#p_item.gender,
		score  = Item#p_item.score,
		extra  = Item#p_item.extra,
		price  = Trade#trade.price,
		time   = Trade#trade.time,
		misc   = item_util:item_misc(Item)
	}.

money_id() ->
	Plat = game_env:get_plat(),
	List = cfg_game:market_money(),
	proplists:get_value(Plat, List, ?ITEM_GOLD).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
