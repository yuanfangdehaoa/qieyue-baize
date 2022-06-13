%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(item_handler).

-include("bag.hrl").
-include("beast.hrl").
-include("game.hrl").
-include("item.hrl").
-include("role.hrl").
-include("table.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("enum.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 道具详情
handle(?ITEM_DETAIL, Tos, RoleSt) ->
	#m_item_detail_tos{pos=Pos, id=CellID} = Tos,
	{ok, Item} = role_bag:get_item(CellID),
	?ucast(#m_item_detail_toc{item=item_util:p_item(Item), pos=Pos});

%% 使用道具
handle(?ITEM_USE, Tos, RoleSt) ->
	#m_item_use_tos{uid=CellID, num=Num, args=Args} = Tos,
	{ok, Item} = role_bag:get_item(CellID),
	#cfg_item{stype=SType, effect=Eff} = cfg_item:find(Item#p_item.id),
	check_use(Item, Num),
	Cost = [{cellid, CellID, Num}],
	case item_effect:effect(SType, Item#p_item.id, Eff, Num, Args, RoleSt) of
		{gain, Gain} ->
			Items = #{},
			role_bag:deal(Cost, Gain, ?LOG_ITEM_USE, RoleSt);
		{func, Fun} ->
			Items = #{},
			role_bag:cost(Cost, ?LOG_ITEM_USE, Fun, RoleSt);
		{post, Fun} ->
			Items = #{},
			role_bag:cost(Cost, ?LOG_ITEM_USE, RoleSt),
			Fun();
		{deal, Gain, CostAdd, Fun, RoleSt} ->
			{ok, _, Items, _} = role_bag:deal(
				Cost++CostAdd, Gain, ?LOG_ITEM_USE, Fun, RoleSt
			)
	end,
	?ucast(#m_item_use_toc{uid=CellID, id=Item#p_item.id, num=Num, items=Items});

%% 丢弃道具
handle(?ITEM_CHUCK, Tos, RoleSt) ->
	#m_item_chuck_tos{uid=CellID, num=Num} = Tos,
	{ok, Item} = role_bag:get_item(CellID),
	check_chuck(Item, Num),
	role_bag:cost([{cellid, CellID, Num}], ?LOG_ITEM_CHUCK, RoleSt),
	?ucast(#m_item_chuck_toc{uid=CellID, num=Num});

%% 出售道具
handle(?ITEM_SELL, Tos, RoleSt) ->
	#m_item_sell_tos{items=Items} = Tos,
	check_sell(Items),
	{Cost, Gain} = maps:fold(fun
		(CellID, Num, {AccCost, AccGain}) ->
			{ok, Item} = role_bag:get_item(CellID),
			CfgItem = cfg_item:find(Item#p_item.id),
			#cfg_item{money=Money, price=Price} = CfgItem,
			AccGain2 = case Money == 0 of
				true  -> throw(?err(?ERR_ITEM_CANNOT_SELL));
				false -> [{Money, Price*Num} | AccGain]
			end,
			{[{cellid, CellID, Num} | AccCost], AccGain2}
	end, {[], []}, Items),
	role_bag:deal(Cost, Gain, ?LOG_ITEM_SELL, RoleSt),
	?ucast(#m_item_sell_toc{gain=maps:from_list(Gain), cost=Items});

%% 存到仓库
handle(?ITEM_STORE, Tos, RoleSt) ->
	#m_item_store_tos{uid=CellID, num=Num} = Tos,
	{ok, Item} = role_bag:get_item(CellID),
	check_store(Item, Num),
	role_bag:move(?BAG_ID_MAIN, ?BAG_ID_DEPOT, [{CellID, Num}], RoleSt),
	?ucast(#m_item_store_toc{uid=CellID, num=Num});

%% 从仓库取回
handle(?ITEM_FETCH, Tos, RoleSt) ->
	#m_item_fetch_tos{uid=CellID, num=Num} = Tos,
	role_bag:move(?BAG_ID_DEPOT, ?BAG_ID_MAIN, [{CellID, Num}], RoleSt),
	?ucast(#m_item_fetch_toc{uid=CellID, num=Num});

%% 道具查询
handle(?ITEM_QUERY, Tos, RoleSt) ->
	#m_item_query_tos{id=CacheID} = Tos,
	case item_cache:get_cache(CacheID) of
		?nil -> throw(?err(?ERR_ITEM_NOT_EXIST));
		Item -> ?ucast(#m_item_query_toc{item=item_util:p_item(Item)})
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_use(Item, Num) ->
	ensure_enough_item(Item, Num),
	ensure_enough_level(Item),
	ensure_enough_vip(Item),
	ok.

check_chuck(Item, Num) ->
	ensure_enough_item(Item, Num),
	#cfg_item{chuck = CanChuck} = cfg_item:find(Item#p_item.id),
	?_check(CanChuck, ?ERR_ITEM_CANNOT_CHUCK),
	ok.

check_sell(Items) ->
	IsUnique = ut_misc:is_unique( maps:keys(Items) ),
	?_check(IsUnique, ?ERR_GAME_BAD_ARGS),
	ok.

check_store(Item, Num) ->
	ensure_enough_item(Item, Num),
	#cfg_item{depot=Depot} = cfg_item:find(Item#p_item.id),
	?_check(Depot > 0, ?ERR_ITEM_CANNOT_STORE),
	ok.

ensure_enough_item(Item, Need) ->
	?_check(Need > 0 andalso Item#p_item.num >= Need, ?ERR_ITEM_NOT_ENOUGH).

ensure_enough_level(Item) ->
	#cfg_item{level_limit=LevelLimit} = cfg_item:find(Item#p_item.id),
	#role_info{level=Lv} = role_data:get(?DB_ROLE_INFO),
	?_check(Lv >= LevelLimit, ?ERR_ITEM_LEVEL_LIMIT).

ensure_enough_vip(Item) ->
	#cfg_item{vip_limit=VipLimit} = cfg_item:find(Item#p_item.id),
	#role_vip{level=Lv} = role_data:get(?DB_ROLE_VIP),
	?_check(Lv >= VipLimit, ?ERR_ITEM_VIP_LIMIT).
