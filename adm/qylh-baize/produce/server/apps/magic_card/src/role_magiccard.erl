%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_magiccard).
-include("table.hrl").
-include("game.hrl").
-include("item.hrl").
-include("log.hrl").
-include("errno.hrl").
-include("magic_card.hrl").
-include("bag.hrl").
-include("proto.hrl").
-include("role.hrl").
-include("enum.hrl").

%% API
-export([auto_decompose/1, decompose/3, hook_update_cost/2]).
-export([update_bag_info/2]).
-export([check_gate/1]).
-export([get_attr/1]).
-export([hook_login/1]).
-export([notify/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

notify(?EVENT_ITEM, {ItemID, _Num}, RoleSt)->
	#cfg_item{stype=SType} = cfg_item:find(ItemID),
	case SType == ?ITEM_STYPE_MAGICCARD of
		true  -> auto_decompose(RoleSt);
		false -> ignore
	end.

hook_login(_RoleSt)->
	role_event:listen(?EVENT_ITEM, ?MODULE, notify).

get_attr(_AttrType)->
	#role_magic_card{cards=Cards} = role_data:get(?DB_ROLE_MAGIC_CARD),
	#role_info{id=RoleID} = role_data:get(?DB_ROLE_INFO),
	{TotalAttr, Power} = maps:fold(fun
			(_K, CellId, {Attr, Acc}) ->
				{ok, Item} = role_bag:get_item(CellId),
				#p_item{id=Id, extra=StongLv} = Item,
				#cfg_magic_card{base=Base, rare=Rare, score=Score}
				= cfg_magic_card:find(Id),
				#cfg_magic_card_strength{attrib = Attrib, fight=Fight}
				= cfg_magic_card_strength:find(Id, StongLv),
				{mod_attr:sum([Attr, Base, Rare, Attrib]), Acc+Score+Fight}
		end, {#{}, 0}, Cards),
	role_event:event(?EVENT_MC_POWER, Power),
	?ucast(RoleID, #m_magic_power_toc{power=Power}),
	TotalAttr.

auto_decompose(RoleSt)->
	#role_magic_card{auto=Auto, colors=Colors} = role_data:get(?DB_ROLE_MAGIC_CARD),
	#role_bag{cells=Cells, items=Items} = role_data:get(?DB_ROLE_BAG),
	#cell{used = Used, unused=UnUsed} = maps:get(?BAG_ID_RUNE, Cells),
	case Auto == 1 andalso length(UnUsed) < 25 of
		true ->
			CellIds = get_cards_color(Colors, Used, Items, []),
			{Cost, Gain} = decompose(CellIds, [], []),
			role_bag:deal(Cost, Gain, ?LOG_MAGIC_CARD_DECOMPOSE, RoleSt);
		false -> 
			ignore
	end.

%分解
decompose([], Cost, Gain)->
	{Cost, Gain};
decompose([CellId|CellIdList], Cost, Gain)->
	{ok, Item} = role_bag:get_item(CellId),
	#p_item{id=ItemId, num = Num, extra=StrenLv} = Item,
	TotalCost2 = case StrenLv /= ?nil of
		true ->
			#cfg_magic_card_strength{total_cost=TotalCost} = cfg_magic_card_strength:find(ItemId, StrenLv),
			TotalCost;
		_->[]
	end,
	#cfg_magic_card{gain=Gain1} = cfg_magic_card:find(ItemId),
	Gain2 = [ {ItemNo, erlang:round(Count * Num)} || {ItemNo, Count} <- Gain1],
	decompose(CellIdList,  [{cellid, CellId} | Cost], lists:merge3(Gain, TotalCost2, Gain2)).

%更新消耗值
hook_update_cost(Cost, RoleSt)->
	ItemIds = [ ItemId || {ItemId, _num} <- Cost],
	update_bag_info(ItemIds, RoleSt).

%发送属性更新
update_bag_info(ItemIds, RoleSt)->
	#role_bag{money=Money} = role_data:get(?DB_ROLE_BAG),
	Ups = lists:foldl(fun
			(ItemId, Maps) ->
				maps:put(ItemId, maps:get(ItemId, Money, 0), Maps)
		end, #{}, ItemIds),
	?ucast(#m_magic_card_bag_info_toc{items=Ups}).

%检查关卡
check_gate(ItemId)->
	#dunge_magic{clear_floor=Floor} = role_data:get(?DB_DUNGE_MAGIC),
	#cfg_magic_card{gate=Gate} = cfg_magic_card:find(ItemId),
	?_check(Floor >= Gate, ?ERR_MALL_BUY_MCARD_GATE_NOT_OPEN).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------

%根据颜色获取魔法卡
get_cards_color([], _Used, _Items, Cards)->
	Cards;
get_cards_color([Color|ColorList], Used, Items, Cards)->
	Cards2 = lists:foldl(fun
			(CellId, Lists)->
				#p_item{id=ItemId} = maps:get(CellId, Items),
				#cfg_item{color=ItemColor} = cfg_item:find(ItemId),
				case Color == ItemColor of
					true  -> [CellId | Lists];
					false -> Lists
				end
		end, Cards, Used),
	get_cards_color(ColorList, Used, Items, Cards2).