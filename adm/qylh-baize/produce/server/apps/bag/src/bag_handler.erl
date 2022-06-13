%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(bag_handler).

-include("bag.hrl").
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
%% 背包信息
handle(?BAG_INFO, Tos, RoleSt) ->
	#m_bag_info_tos{bag_id=BagID} = Tos,
	RoleBag = role_data:get(?DB_ROLE_BAG),
	#role_bag{cells=Cells, items=All} = RoleBag,
	Cell  = maps:get(BagID, Cells),
	Items = maps:values( maps:with(Cell#cell.used, All) ),
	?ucast(#m_bag_info_toc{
		bag_id = BagID,
		opened = Cell#cell.opened,
		items  = [item_util:p_item_base(Item) || Item <- Items]
	});

%% 开启格子
handle(?BAG_OPEN, Tos, RoleSt) ->
	#m_bag_open_tos{bag_id=BagID, num=Num} = Tos,
	#role_bag{cells=Cells} = role_data:get(?DB_ROLE_BAG),
	Cell = maps:get(BagID, Cells),
	check_open(BagID, Cell, Num),
	#cfg_bag{cost=Cost} = cfg_bag:find(BagID),
	Cost2 = [{ID, Per*Num} || {ID, Per} <- Cost],
	role_bag:cost(Cost2, ?LOG_BAG_OPEN, RoleSt),
	do_open(BagID, Num),
	role_event:event(?EVENT_OPEN_BAG, {BagID, Num}),
	?ucast(#m_bag_open_toc{bag_id=BagID, num=Num}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_open(BagID, Cell, Num) ->
	#cfg_bag{cap=Cap} = cfg_bag:find(BagID),
	?_check(Cell#cell.opened + Num =< Cap, ?ERR_BAG_ALL_OPENED),
	ok.

do_open(BagID, Num) ->
	% 这里要重新获取一下
	RoleBag = #role_bag{cells=Cells} = role_data:get(?DB_ROLE_BAG),
	Cell  = maps:get(BagID, Cells),
	Cell2 = role_bag:open(BagID, Cell, Num),
	RoleBag2 = RoleBag#role_bag{cells=maps:put(BagID, Cell2, Cells)},
	role_data:set(RoleBag2).