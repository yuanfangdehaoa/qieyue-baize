%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%% 商城
%%% @end
%%%=============================================================================

-module(mall_handler).

-include("mall.hrl").
-include("proto.hrl").
-include("table.hrl").
-include("game.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("item.hrl").
-include("bag.hrl").
-include("msgno.hrl").
-include("yunying.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%获取限购已购买信息
handle(?MALL_BOUGHT, _Tos, RoleSt) ->
	role_mall:check_refresh(),
	#role_mall{refresh_type_maps=RefreshTypeMaps} = role_data:get(?DB_ROLE_MALL),
	RefreshTypeMaps2 = bought_maps(RefreshTypeMaps),
	{ok, #m_mall_bought_toc{bought_items=RefreshTypeMaps2}, RoleSt};

%获取限时抢购
handle(?MALL_GETLIMIT, _Tos, RoleSt) ->
	role_mall:check_limit(),
	#role_mall{limit_maps=LimitMaps} = role_data:get(?DB_ROLE_MALL),
	ItemList = role_mall:get_limit_items(LimitMaps),
	{ok, #m_mall_getlimit_toc{limit_items=ItemList}, RoleSt};

%获取活动商品
handle(?MALL_ACT_ITEMS, Tos, RoleSt)->
	#m_mall_act_items_tos{act_id=ActID} = Tos,
	?_check(yunying:is_start(ActID), ?ERR_SCENE_NO_ACTIVITY),
	IdList = cfg_mall:act_items(ActID),
	ItemList = lists:foldl(fun
			(ID, Lists) ->
				Item = cfg_mall:find(ID),
				[p_mallitem(Item) | Lists]
		end, [], IdList),
	{ok, #m_mall_act_items_toc{act_id=ActID, items=ItemList}, RoleSt};

%续期
handle(?MALL_VALIDATE, Tos, RoleSt)->
	#m_mall_validate_tos{id=MallId, uid=UId} = Tos,
	{ok, PItem} = role_bag:get_item(UId),
	#p_item{etime=ETime, bag=BagID} = PItem,
	?_check(ETime < ut_time:seconds(), ?ERR_MALL_BUY_NOT_EXPIRE),
	case cfg_mall:find(MallId) of
		?nil ->
			ignore;
		#cfg_mall{item=Item, price=Cost} ->
			[{ItemId2, _Num, _Bind}] = Item,
			#cfg_item{stype=SType, expire=Expire} = cfg_item:find(ItemId2),
			?_check(SType == ?ITEM_STYPE_FAIRY orelse SType == ?ITEM_STYPE_FAIRY2, ?ERR_MALL_BUY_CAN_NOT_VALIDATE),
			%?_check(ItemId==ItemId2, ?ERR_GAME_BAD_ARGS),
			role_bag:cost(Cost, ?LOG_MALL_VALIDATE, RoleSt),
			PItem2 = PItem#p_item{etime=ut_time:seconds()+Expire},
			role_bag:set_item(PItem2),
			case BagID == ?BAG_ID_MAIN of
				true ->
					ignore;
				false ->
					role_attr:recalc(role_equip, RoleSt),
					role_equip:send_item_toc(PItem2, RoleSt)
			end
	end,
	{ok, #m_mall_validate_toc{id=MallId}, RoleSt};


%购买
handle(?MALL_BUY, Tos, RoleSt) ->
	#m_mall_buy_tos{id=Id, num=Num} = Tos,
	?_check(Num > 0, ?ERR_GAME_BAD_ARGS),
	role_mall:check_refresh(),
	role_mall:check_limit(),
	case cfg_mall:find(Id) of
		undefined->
			throw(?err(?ERR_MALL_BUY_MALLITEM_NOT_EXSIT));
		#cfg_mall{mall_type=MallType, limit_type=LimitType, price=Cost, item=Item,
		limit_num=LimitNum, activity=ActID} = MallItem ->
			case LimitType of
				0->  %不限购
					buy(MallItem, MallType, Item, Cost, Num, RoleSt);
				3->  %限时抢购
					RoleMall = #role_mall{limit_maps=LimitMaps} = role_data:get(?DB_ROLE_MALL),
					case maps:get(Id, LimitMaps, ?nil) of
						?nil->
							throw(?err(?ERR_MALL_BUY_MALLITEM_NOT_EXSIT));
						#p_mall_limit_item{left_num=LeftNum, buy_num=BuyNum} =LimitItem->
							?_check(is_can_buy(LimitItem, Num), ?ERR_MALL_BUY_TOO_MANY),
							buy(MallItem, MallType, Item, Cost, Num, RoleSt),
							LeftNum2 = LeftNum - Num,
							BuyNum2 = BuyNum + Num,
							LimitItem2 = LimitItem#p_mall_limit_item{left_num=LeftNum2, buy_num=BuyNum2},
							LimitMaps2 = maps:put(Id, LimitItem2, LimitMaps),
							RoleMall2 = RoleMall#role_mall{limit_maps=LimitMaps2},
							role_data:set(RoleMall2),
							role_mall:check_limit(),
							#role_mall{limit_maps=LimitMaps3} = role_data:get(?DB_ROLE_MALL),
							ItemList = role_mall:get_limit_items(LimitMaps3),
							?ucast(#m_mall_getlimit_toc{limit_items=ItemList})
					end;
				4-> %活动限购
					RoleMall = #role_mall{refresh_type_maps=RefreshTypeMaps} = role_data:get(?DB_ROLE_MALL),
					?_check(yunying:is_start(ActID), ?ERR_MALL_BUY_NOT_IN_ACTIVITY),
					{BoughtNum, _Time} = maps:get(Id, RefreshTypeMaps, {0, 0}),
					case BoughtNum + Num =< LimitNum of
						true ->
							buy(MallItem, MallType, Item, Cost, Num, RoleSt),
							BoughtNum2 = BoughtNum + Num,
							RefreshTypeMaps2 = add_buy_num(RoleMall, RefreshTypeMaps, Id, BoughtNum2),
							?ucast(#m_mall_bought_toc{bought_items=bought_maps(RefreshTypeMaps2)});
						false->
							throw(?err(?ERR_MALL_BUY_TOO_MANY))
					end;
				_->  %其他类型
					RoleMall = #role_mall{refresh_type_maps=RefreshTypeMaps} = role_data:get(?DB_ROLE_MALL),
					{BoughtNum, _Time} = maps:get(Id, RefreshTypeMaps, {0, 0}),
					case BoughtNum + Num =< LimitNum of
						true->
							buy(MallItem, MallType, Item, Cost, Num, RoleSt),
							BoughtNum2 = BoughtNum + Num,
							RefreshTypeMaps2 = add_buy_num(RoleMall, RefreshTypeMaps, Id, BoughtNum2),
							?ucast(#m_mall_bought_toc{bought_items=bought_maps(RefreshTypeMaps2)});
						false->
							throw(?err(?ERR_MALL_BUY_TOO_MANY))
					end
			end
	end,
	{ok, #m_mall_buy_toc{id=Id}, RoleSt};

handle(?MALL_BUY_PACK, Tos, RoleSt) ->
	#m_mall_buy_pack_tos{act_id=ActID} = Tos,
	role_mall:check_refresh(),
	role_mall:check_limit(),
	?_check(yunying:is_start(ActID), ?ERR_MALL_BUY_NOT_IN_ACTIVITY),
	#role_info{career=Career} = role_data:get(?DB_ROLE_INFO),
	RoleMall = #role_mall{refresh_type_maps=RefreshTypeMaps} = role_data:get(?DB_ROLE_MALL),

	{Gain, MoneyNum, RefreshTypeMaps2} = lists:foldl(fun(Id, {Gain0, MoneyNum0, RMaps}) ->
		{BoughtNum, _} = maps:get(Id, RMaps, {0, 0}),
		#cfg_mall{limit_num=LimitNum, item=Item, price=[{_, MoneyNum1}]} = cfg_mall:find(Id),
		BuyNum = max(0, LimitNum-BoughtNum),
		if
			BuyNum > 0 ->
				Gain1 = gen_gain_item(Item, LimitNum-BoughtNum, Career),
				RMaps1 = maps:put(Id, {LimitNum, ut_time:seconds()}, RMaps),
				{Gain1++Gain0, MoneyNum1*BuyNum + MoneyNum0, RMaps1};
			true ->
				{Gain0, MoneyNum0, RMaps}
		end
	end, {[], 0, RefreshTypeMaps}, cfg_mall:act_items(ActID)),

	#cfg_yunying{reqs=Reqs} = cfg_yunying:find(ActID),
	{price, {_, CostNum}=Cost} = lists:keyfind(price, 1, Reqs),
	?_check(MoneyNum > CostNum, ?ERR_MALL_BUY_PACK_FAIL),

	role_bag:deal([Cost], Gain, ?LOG_MALL_BUY_PACK, RoleSt),
	role_data:set(RoleMall#role_mall{refresh_type_maps=RefreshTypeMaps2}),
	#cfg_mall{mall_type=MallType} = cfg_mall:find(hd(cfg_mall:act_items(ActID))),
	log_api:mall_buy(MallType, ActID, 1, [Cost], RoleSt),

	?ucast(#m_mall_bought_toc{bought_items=bought_maps(RefreshTypeMaps2)}),
	{ok, #m_mall_buy_pack_toc{}, RoleSt}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%检查是否可以购买
is_can_buy(LimitItem, Num) ->
	#p_mall_limit_item{left_num=LeftNum, end_time=EndTime} = LimitItem,
	EndTime >= ut_time:seconds() andalso LeftNum >= Num.


buy(MallItem, MallType, Item, Cost, Num, RoleSt) ->
	#role_info{career=Career} = role_data:get(?DB_ROLE_INFO),
	#cfg_mall{id=ID, limit_vip=LimitVip} = MallItem,
	VipLv = role_vip:get_level(),
	?_check(VipLv >= LimitVip, ?ERR_GUILD_LOW_VIPLV),
	check(Item, Career),
	Item2 = gen_gain_item(Item, Num, Career),
	Cost2 = gen_cost_item(Cost, Num),
	role_bag:deal(Cost2, Item2, ?LOG_MALL_BUY, RoleSt),
	lists:foreach(fun
		(Mod) ->
			Mod:hook_update_cost(Cost2, RoleSt)
	end, [
		  role_magiccard
	]),
	notify(MallItem),
	log_api:mall_buy(MallType, ID, Num, Cost2, RoleSt).

%系统公告
notify(MallItem)->
	#role_info{id=RoleID, name=RoleName, career=Career} = role_data:get(?DB_ROLE_INFO),
	#cfg_mall{id=Id,mall_type=MallType,notify=Nofity,name=Name,discount=Discount,
		item=Items, price=Price, panel=Panel} = MallItem,
	[Item|_T] = Items,
	{ItemId2, Num2} = case Item of
		{ItemId, Num} ->
			{ItemId, Num};
		{ItemId, Num, _Bind} ->
			case is_list(ItemId) of
				true ->
					{lists:nth(Career, ItemId), Num};
				false ->
					{ItemId, Num}
			end
	end,
	% #cfg_item{name=ItemName, color=Color} = cfg_item:find(ItemId2),
	% NameList = [ItemName, "*", Num2],
	ItemMap = maps:put(ItemId2, Num2, #{}),
	{Type1, Type2} = MallType,
	PanelArgs = [Panel,"@",Type1,"@",Type2,"@",Id],
	Params = if
		Nofity == ?MSG_MALL_BUY_ITEM ->
			[{role,RoleID, RoleName},
			  	Discount,
				Name,
				{item, ItemMap},
				{"panel", lists:concat(PanelArgs)}];
		Nofity == ?MSG_MAGICCARD_BUY_NOTICE ->
			[{role,RoleID, RoleName},
				{item, ItemMap},
				{"panel", lists:concat(PanelArgs)}];
		Nofity == ?MSG_MALL_BUY_INTEGRAL ->
			[{_, Score}|_T] = Price,
			[{role,RoleID, RoleName}, Score,
				{item, ItemMap},
				{"panel", lists:concat(PanelArgs)}];
		Nofity == ?MSG_MALL_BEAST_REWARD1;
		Nofity == ?MSG_MALL_BEAST_REWARD2;
		Nofity == ?MSG_MALL_BEAST_REWARD3;
		Nofity == ?MSG_MALL_BEAST_REWARD4;
		Nofity == ?MSG_MALL_MACHE_REWARD1;
		Nofity == ?MSG_MALL_MACHE_REWARD2;
		Nofity == ?MSG_MALL_MACHE_REWARD3;
		Nofity == ?MSG_MALL_MACHE_REWARD4;
		Nofity == ?MSG_MALL_PET_EQUIP1;
		Nofity == ?MSG_MALL_PET_EQUIP2;
		Nofity == ?MSG_MALL_PET_EQUIP3;
		Nofity == ?MSG_MALL_PET_EQUIP4;
		Nofity == ?MSG_MALL_ARTIFACT_LIMIT1;
		Nofity == ?MSG_MALL_ARTIFACT_LIMIT2;
		Nofity == ?MSG_MALL_ARTIFACT_LIMIT3;
		Nofity == ?MSG_MALL_ARTIFACT_LIMIT4;
		Nofity == ?MSG_MALL_TOTEMS_LIMIT1;
		Nofity == ?MSG_MALL_TOTEMS_LIMIT2;
		Nofity == ?MSG_MALL_TOTEMS_LIMIT3;
		Nofity == ?MSG_MALL_TOTEMS_LIMIT4	->

			[{role,RoleID, RoleName},
				Name,
				{"panel", lists:concat(PanelArgs)}];
		true ->
			[]
	end,
	?_if(Nofity > 0, ?notify(Nofity, Params)).


%记录购买数量
add_buy_num(RoleMall, RefreshTypeMaps, Id, BoughtNum)->
	RefreshTypeMaps2 = maps:put(Id, {BoughtNum, ut_time:seconds()}, RefreshTypeMaps),
	RoleMall2 = RoleMall#role_mall{refresh_type_maps=RefreshTypeMaps2},
	role_data:set(RoleMall2),
	RefreshTypeMaps2.

gen_gain_item(ItemList, Num, Career)->
	lists:foldl(fun
			(Item, List) ->
				{ItemId, OldNum, Bind} = case Item of
					{ItemId0, OldNum0} ->
						{ItemId0, OldNum0, 2};
					{ItemId0, OldNum0, Bind0} ->
						{ItemId0, OldNum0, Bind0}
				end,
				ItemId2 = case is_list(ItemId) of
					true ->
						lists:nth(Career, ItemId);
					false ->
						ItemId
				end,
				[{ItemId2, OldNum*Num, #{bind=>item_util:calc_bind(Bind)}} | List]
		end, [], ItemList).

gen_cost_item(ItemList, Num)->
	lists:foldl(fun
			({ItemId, OldNum}, List) ->
				[{ItemId, OldNum*Num} | List]
		end, [], ItemList).

%检查条件
check([], _Career)->
	ignor;
check([Item | ItemList], Career)->
	ItemId = case Item of
		{ItemId0, _} ->
			ItemId0;
		{ItemId0, _, _} ->
			ItemId0
	end,
	ItemId2 = case is_list(ItemId) of
		true  -> lists:nth(Career, ItemId);
		false -> ItemId
	end,
	#cfg_item{stype=SType} = cfg_item:find(ItemId2),
	case SType of
		?ITEM_STYPE_MAGICCARD ->
			role_magiccard:check_gate(ItemId2);
		_ ->
           	ignor
	end,
	check(ItemList, Career).

bought_maps(BoughtMaps)->
	maps:fold(fun
		(ID, {Num, _Time}, Maps)->
			maps:put(ID, Num, Maps)
	end, #{}, BoughtMaps).

p_mallitem(MallItem)->
	#cfg_mall{
		  id             = Id
		, order          = Order
		, name           = Name
		, item           = Item
		, discount       = Discount
		, price          = Price
		, original_price = OriginalPrice
		, limit_num      = LimitNum
		, limit_vip      = LimitVip
		, limit_other    = LimitOther
		, limit_pre_id   = LimitPreId
		, limit_level    = LimitLevel
		, activity       = Activity
	} = MallItem,
	#p_mallitem{
		  id             = Id
		, order          = Order
		, name           = Name
		, item           = ut_conv:term_to_string(Item)
		, discount       = Discount
		, price          = gen_item(Price)
		, original_price = OriginalPrice
		, limit_num      = LimitNum
		, limit_vip      = LimitVip
		, limit_pre_id   = LimitPreId
		, limit_level    = LimitLevel
		, activity       = Activity
		, limit_other    = LimitOther
	}.


gen_item(Item)->
	lists:foldl(fun
			(OneItem, Maps) ->
				case OneItem of
					{ItemId, Num} ->
						maps:put(gen_item_id(ItemId), Num, Maps);
					{ItemId, Num, _B} ->
						maps:put(gen_item_id(ItemId), Num, Maps);
					_->
						Maps
				end
		end, #{}, Item).

gen_item_id(ItemId)->
	case is_list(ItemId) of
		true ->
			#role_info{career=Career} = role_data:get(?DB_ROLE_INFO),
			lists:nth(Career, ItemId);
		false ->
			ItemId
	end.
