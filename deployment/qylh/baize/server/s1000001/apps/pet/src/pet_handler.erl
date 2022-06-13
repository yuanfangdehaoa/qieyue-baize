%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(pet_handler).

-include("pet.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("bag.hrl").
-include("skill.hrl").
-include("msgno.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%获取已助战宠物
handle(?PET_INFO, _Tos, RoleSt)->
	#role_pet{pets=Pets, fight=Fight} = role_data:get(?DB_ROLE_PET),
	Items = maps:fold(fun
			(_K, CellId, Lists) ->
				{ok, Item} = role_bag:get_item(CellId),
				Item2 = item_util:p_item(Item),
				[Item2|Lists]
		end, [], Pets),
	{ok, #m_pet_info_toc{pets=Items, fight_order=Fight}, RoleSt};


%设置宠物出战，助阵
handle(?PET_SET, Tos, RoleSt)->
	#m_pet_set_tos{uid=UId, is_fight=IsFight} = Tos,
	Item = case role_bag:get_item(UId) of
		{ok, TmpItem}->TmpItem;
		Error -> throw(Error)
	end,
	#p_item{etime=ETime, id=ItemId} = Item,
	?_check(ETime == 0 orelse ETime > ut_time:seconds(), ?ERR_PET_IS_EXPIRE),
	#cfg_pet{order=Order, wake=Wake, level=Level} = cfg_pet:find(ItemId),
	%检查是否可以助阵
	check_puton(Wake, Level),
	puton(Order, UId, Item, IsFight, RoleSt),
	?ucast(#m_pet_set_toc{order=Order});


%训练
handle(?PET_STRONG, Tos, RoleSt)->
	#m_pet_strong_tos{order=Order} = Tos,
	RolePet = #role_pet{strong=Strong, strong_attr=StrongAttr, pets=Pets, fight=Fight}
	= role_data:get(?DB_ROLE_PET),
	%检查是否有助战
	UId = maps:get(Order, Pets, 0),
	?_check(UId > 0 , ?ERR_PET_IS_NOT_PUTON),
	Cross = maps:get(Order, Strong, 0),
	#cfg_pet_strong{max=Max, add_value=AddValueList, strength_cost=Cost} = cfg_pet_strong:find(Order, Cross),
	OrderStrongAttr = maps:get(Order, StrongAttr, #{}),
	Max2 = filter_max(OrderStrongAttr, Max),
	%检查是否可训练
	?_check(length(Max2) > 0, ?ERR_PET_IS_STRONG_MAX),
	role_bag:cost(Cost, ?LOG_PET_STRONG, RoleSt),
	{AttrKey, MaxValue} = ut_rand:weight(Max2, 3),
	AddValueMap = maps:from_list(AddValueList),
	AddValue = maps:get(AttrKey, AddValueMap),
	%原来已加的属性值
	OldValue = maps:get(AttrKey, OrderStrongAttr, 0),
	NewValue = OldValue+AddValue,
	NewValue2 = case NewValue > MaxValue of
		true  -> MaxValue;
		false -> NewValue
	end,
	OrderStrongAttr2 = maps:put(AttrKey, NewValue2, OrderStrongAttr),
	StrongAttr2 = maps:put(Order, OrderStrongAttr2, StrongAttr),
	role_data:set(RolePet#role_pet{strong_attr=StrongAttr2}),
	%更新宠物item
	role_attr:recalc(role_pet, RoleSt),
	{ok, Item} = role_bag:get_item(UId),
	?ucast(#m_pet_info_toc{pets=[item_util:p_item(Item)], fight_order=Fight}),
	role_event:event(?EVENT_PET_STRONG),
	{ok, #m_pet_strong_toc{order=Order}, RoleSt};

%超越
handle(?PET_CROSS, Tos, RoleSt)->
	#m_pet_cross_tos{order=Order} = Tos,
	RolePet = #role_pet{strong=Strong, strong_attr=StrongAttr, pets=Pets, fight=Fight}
	= role_data:get(?DB_ROLE_PET),
	%检查是否有助战
	UId = maps:get(Order, Pets, 0),
	?_check(UId > 0 , ?ERR_PET_IS_NOT_PUTON),
	Cross = maps:get(Order, Strong, 0),
	#cfg_pet_strong{max=Max, cross_cost=Cost} = cfg_pet_strong:find(Order, Cross),
	?_check(length(Cost) > 0, ?ERR_PET_CROSS_COST_WRONG),
	OrderStrongAttr = maps:get(Order, StrongAttr, #{}),
	Max2 = filter_max(OrderStrongAttr, Max),
	%检查是否全部满
	?_check(length(Max2) == 0, ?ERR_PET_STRONG_NOT_MAX),
	role_bag:cost(Cost, ?LOG_PET_CROSS, RoleSt),
	Strong2 = maps:put(Order, Cross+1, Strong),
	%突破到下一级
	#cfg_pet_strong{base=Base} = cfg_pet_strong:find(Order, Cross+1),
	OrderStrongAttr2 = maps:from_list(Base),
	StrongAttr2 = maps:put(Order, OrderStrongAttr2, StrongAttr),
	role_data:set(RolePet#role_pet{strong=Strong2, strong_attr=StrongAttr2}),
	%更新宠物item
	role_attr:recalc(role_pet, RoleSt),
	{ok, Item} = role_bag:get_item(UId),
	?ucast(#m_pet_info_toc{pets=[item_util:p_item(Item)], fight_order=Fight}),
	{ok, #m_pet_cross_toc{order=Order}, RoleSt};

%突破
handle(?PET_EVOLVE, Tos, RoleSt)->
	#m_pet_evolve_tos{order=Order} = Tos,
	RolePet = #role_pet{pets=Pets, fight=Fight, costs=Costs} = role_data:get(?DB_ROLE_PET),
	%检查是否有助战
	UId = maps:get(Order, Pets, 0),
	?_check(UId > 0 , ?ERR_PET_IS_NOT_PUTON),
	{ok, Item} = role_bag:get_item(UId),
	#p_item{id=Id, extra=Times} = Item,
	#cfg_pet{evolution=MaxTimes} = cfg_pet:find(Id),
	NextTimes = Times+1,
	?_check(NextTimes =< MaxTimes, ?ERR_PET_EVOLVE_IS_MAX),
	#cfg_pet_evolution{cost=Cost} = cfg_pet_evolution:find(Order, NextTimes),
	{BList, List} = calc_cells(Cost),
	Cost2 = lists:merge(BList, List),
	role_bag:cost(Cost2, ?LOG_PET_EVOLUTION, RoleSt),
	{OBList, OList} = maps:get(Order, Costs, {[],[]}),
	BList2 = lists:merge(BList, OBList),
	List2 = lists:merge(List, OList),
	Costs2 = maps:put(Order, {BList2, List2}, Costs),
	role_data:set(RolePet#role_pet{costs=Costs2}),
	Item2 = Item#p_item{extra=NextTimes},
	role_bag:set_item(Item2),
	IsFight = case Fight == Order of
		true  ->
			role_pet:delete_skills(Order, Times, RoleSt),
			role_pet:add_skills(Order, NextTimes, RoleSt),
			1;
		false ->
			0
	end,
	role_event:event(?EVENT_PET_EVOLUTION, {IsFight, NextTimes}),
	role_attr:recalc(role_pet, RoleSt),
	{ok, Item3} = role_bag:get_item(UId),
	?ucast(#m_pet_info_toc{pets=[item_util:p_item(Item3)], fight_order=Fight}),
	{ok, #m_pet_evolve_toc{order=Order}, RoleSt};

%突破回退
handle(?PET_BACK, Tos, RoleSt)->
	#m_pet_back_tos{order=Order} = Tos,
	RolePet = #role_pet{pets=Pets, fight=Fight, costs=Costs} = role_data:get(?DB_ROLE_PET),
	%检查是否有助战
	UId = maps:get(Order, Pets, 0),
	?_check(UId > 0 , ?ERR_PET_IS_NOT_PUTON),
	{ok, Item} = role_bag:get_item(UId),
	#p_item{extra=Times} = Item,
	%Gain = calc_gain(Order, Times, []),
	{Costs2, Gain} = evolution_back_gain(Order, Costs),
	role_data:set(RolePet#role_pet{costs=Costs2}),
	role_bag:gain(Gain, ?LOG_PET_BACK, RoleSt),
	Item2 = Item#p_item{extra=0},
	role_bag:set_item(Item2),
	case Fight == Order of
		true ->
			role_pet:delete_skills(Order, Times, RoleSt),
			role_pet:add_skills(Order, 0, RoleSt);
		false ->
			ignore
	end,
	role_attr:recalc(role_pet, RoleSt),
	{ok, Item3} = role_bag:get_item(UId),
	?ucast(#m_pet_info_toc{pets=[item_util:p_item(Item3)], fight_order=Fight}),
	{ok, #m_pet_back_toc{order=Order}, RoleSt};

%合成
handle(?PET_COMPOSE, Tos, RoleSt)->
	#m_pet_compose_tos{id=Id, uids=UIds} = Tos,
	CfgCompose = cfg_pet_compose:find(Id),
	#cfg_pet_compose{
		type_id=TypeID, level=NeedLevel, target=Target, cost=Cost, proba=Proba,
		compose_key=ComposeKey
	} = CfgCompose,
	Sum2 = lists:foldl(fun
			({_ItemId, Num}, Sum) ->
				Sum + Num
		end, 0, Cost),
	?_check(length(UIds) == Sum2, ?ERR_ITEM_NOT_ENOUGH),
	RolePet = #role_pet{pets=Pets, costs=Costs, fight=Fight} = role_data:get(?DB_ROLE_PET),
	%先判断成功或失败
	Index = ut_rand:random(1, 10000),
	{Succ, ComposeCount} = role_equip:is_compose_succ(ComposeKey),
	%猫又是否第一次合成
	Succ2 = case ComposeKey of
		{pet_1, 3} ->
			case role_equip:is_composed(ComposeKey) of
				false -> true;
				true  -> false
			end;
		_ ->
			false
	end,
	Success = Index =< Proba orelse Succ orelse Succ2,
	%检测消耗是否正确
	{CostCells3, Gain3, HasEquiped, Pets3, Costs3, OldEvolution2, Bind}
	= check_cost(UIds, Cost, [], [], false, Pets, Costs, Fight, ?nil, false, RoleSt),
	{CostCells, Gain, Pets2, Costs2, OldEvolution} = case Success of
		true  ->
			{CostCells3, Gain3, Pets3, Costs3, OldEvolution2};
		false ->
			HighUId = get_high_uid(UIds),
			CostCells2 = lists:keydelete(HighUId, 2, CostCells3),
			{CostCells2, [], Pets, Costs, ?nil}
	end,
	#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
	?_check(Level >= NeedLevel, ?ERR_PET_LEVEL_IS_NOT_ENOUGH),
	{Gain2, Func, PetId2} = case Success of
		true ->
			{PetId, Num} = ut_rand:weight(Target, 3),
			Func2 = fun(Deal)->
				 #deal{update=Update} = Deal,
			     #update{add=Add} = Update,
				 lists:foldl(fun
				 (#p_item_base{uid=NewUId, id=ItemId}, List) ->
					case ItemId == PetId of
						true ->
							[NewUId|List];
						false ->
							List
						end
					end, [], Add)
			end,
			role_equip:update_compose_count(ComposeKey, 0),
			{[{PetId, Num, #{bind=>Bind}} | Gain], Func2, PetId};
		false ->
			Func2 = fun() ->
					[]
				end,
			role_equip:update_compose_count(ComposeKey, ComposeCount+1),
			{Gain, Func2, 0}
	end,
	{ok, _, _, Result} = role_bag:deal(CostCells, Gain2, ?LOG_PET_COMPOSE, Func, RoleSt),
	role_data:set(RolePet#role_pet{pets=Pets2, costs=Costs2}),
	Item2 = case length(Result) > 0 of
		true ->
			[NewUId3|_T2] = Result,
			{ok, NewItem} = role_bag:get_item(NewUId3),
			?ucast(#m_pet_show_toc{pet=item_util:p_item(NewItem)}),
			NewItem;
		false ->
			?nil
	end,
	case HasEquiped andalso length(Result)>0 of
		true ->
			[NewUId2|_T] = Result,
			{ok, Item} = role_bag:get_item(NewUId2),
			#p_item{id=ItemId} = Item,
			#cfg_pet{order=Order} = cfg_pet:find(ItemId),
			?_if(OldEvolution /= ?nil, role_pet:delete_skills(Order, OldEvolution, RoleSt)),
			puton(Order, NewUId2, Item, false, RoleSt);
		false ->
			ignore
	end,
	case Success of
		true ->
	 		role_event:event(?EVENT_PET_COMPOSE, {TypeID, PetId2}),
	 		case Item2 /= ?nil of
	 			true ->
	 				#role_st{role=RoleID, name=RoleName} = RoleSt,
	 				CacheId = item_cache:add_cache(Item2),
	 				ItemMap = #{CacheId => PetId2},
					?notify(?MSG_PET_COMPOSE_NOTICE, [{role, RoleID, RoleName}, {pitem, ItemMap}]);
	 			false ->
	 				ignore
	 		end;
		false ->
			ignore
	end,
	{ok, #m_pet_compose_toc{id=Id, success=Success}, RoleSt};

%分解
handle(?PET_DECOMPOSE, Tos, RoleSt)->
	#m_pet_decompose_tos{uids=UIds} = Tos,
	{Cost2, Gain2} = lists:foldl(fun
			(UId, {Cost, Gain}) ->
				{ok, #p_item{id=ID, bag=BagID}} = role_bag:get_item(UId),
				#cfg_pet{gain=TmpGain} = cfg_pet:find(ID),
				?_check(BagID==?BAG_ID_PET, ?ERR_PET_BAG_ID_WRONG),
				TmpGain2 = lists:merge(Gain, TmpGain),
				{[{cellid, UId, 1} | Cost], TmpGain2}
		end, {[], []}, UIds),
	role_bag:deal(Cost2, Gain2, ?LOG_PET_DECOMPOSE, RoleSt),
	{ok, #m_pet_decompose_toc{}, RoleSt};

%开蛋记录
handle(?PET_EGG_RECORDS, _Tos, RoleSt)->
	Records = role_pet:get_egg_records(),
	{ok, #m_pet_egg_records_toc{records=Records}, RoleSt};

handle(MsgID, Tos, RoleSt) ->
	pet_equip_handler:handle(MsgID, Tos, RoleSt).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%检查是否可以助阵
check_puton(NeedWake, NeedLevel)->
	#role_info{wake=Wake, level=Level} = role_data:get(?DB_ROLE_INFO),
	?_check(Wake >= NeedWake andalso Level >= NeedLevel, ?ERR_PET_LEVEL_IS_NOT_ENOUGH).

%宠物下阵
% putoff(UId, Pets, Costs, RoleSt)->
% 	{ok, OldItem} = role_bag:get_item(UId),
% 	#cfg_pet{order=Order} = cfg_pet:find(OldItem#p_item.id),
% 	{Costs2, Gain} = evolution_back_gain(Order, Costs),
% 	EmptyNum = role_bag:get_empty(?BAG_ID_MAIN),
% 	?_check(EmptyNum >= length(Gain), ?ERR_BAG_NO_SPACE),
% 	EmptyNum2 = role_bag:get_empty(?BAG_ID_PET),
% 	?_check(EmptyNum2 >= 2, ?ERR_BAG_NO_SPACE),
% 	OldItem2 = OldItem#p_item{extra=0},
% 	role_bag:set_item(OldItem2),
% 	{ok, [ItemBase]} = role_bag:move([{UId, 1}], ?BAG_ID_PET, RoleSt),
% 	#p_item_base{uid=NewUId} = ItemBase,
% 	Pets2 = maps:remove(Order, Pets),
% 	{NewUId, Gain, Pets2, Costs2}.

%助阵/出战
puton(Order, UId, Item, IsFight, RoleSt)->
	#p_item{id=ItemId} = Item,
	RolePet = #role_pet{fight=Fight, pets=Pets, costs=Costs} = role_data:get(?DB_ROLE_PET),
	OldCellId = maps:get(Order, Pets, 0),
	OldFightCellId = maps:get(Fight, Pets, 0),
	OldEvolution = case OldFightCellId > 0 of
		true ->
			{ok, #p_item{extra=Extra}} = role_bag:get_item(OldFightCellId),
			Extra;
		false->
			?nil
	end,
	{NewCellId, Costs3} = case Item#p_item.bag == ?BAG_ID_PET of
		true ->
			%原位置是否有装备宠物
			Costs2 = case OldCellId == 0 of
				true ->
					{ok, _, [TmpItem2]} = role_bag:move(
						?BAG_ID_PET, ?BAG_ID_PET_ASSIST, [{UId, 1}], RoleSt
					),
					Costs;
				false ->
					%计算返还突破材料
					{TmpCosts, Gain} = evolution_back_gain(Order, Costs),
					EmptyNum = role_bag:get_empty(?BAG_ID_MAIN),
					?_check(EmptyNum >= length(Gain), ?ERR_BAG_NO_SPACE),
					EmptyNum2 = role_bag:get_empty(?BAG_ID_PET),
					?_check(EmptyNum2 >= 1, ?ERR_BAG_NO_SPACE),
					{ok, OldItem} = role_bag:get_item(OldCellId),
					OldItem2 = OldItem#p_item{extra=0},
					role_bag:set_item(OldItem2),
					{ok, _, [TmpItem2]} = role_bag:move(
						?BAG_ID_PET, ?BAG_ID_PET_ASSIST, [{UId, 1}], RoleSt
					),
					role_bag:move(?BAG_ID_PET_ASSIST, ?BAG_ID_PET, [{OldCellId, 1}], RoleSt),
					role_bag:gain(Gain, ?LOG_PET_BACK, RoleSt),
					TmpCosts
			end,
			{TmpItem2#p_item.uid, Costs2};
		false ->
			{Item#p_item.uid, Costs}
	end,
	Pets2 = maps:put(Order, NewCellId, Pets),
	{RolePet2, Fight2} = case IsFight == 1 of
		true ->
			role_figure:update_pet(ItemId, RoleSt),
			{RolePet#role_pet{fight=Order,pets=Pets2, costs=Costs3}, Order};
		false ->
			{RolePet#role_pet{pets=Pets2, costs=Costs3}, Fight}
	end,
	role_data:set(RolePet2),
	%更新助阵
	{ok, NewItem2} = role_bag:get_item(NewCellId),
	#p_item{extra=Evolution} = NewItem2,
	case IsFight == 1 orelse Fight == Order of
		true ->
			?_if(OldEvolution /= ?nil, role_pet:delete_skills(Fight, OldEvolution, RoleSt)),
			role_pet:add_skills(Order, Evolution, RoleSt);
		false->
			igore
	end,
	role_attr:recalc(role_pet, RoleSt),
	role_event:event(?EVENT_PET_FIGHT, {IsFight, Order, ItemId}),
	{ok, NewItem3} = role_bag:get_item(NewCellId),
	?ucast(#m_pet_info_toc{pets=[item_util:p_item(NewItem3)], fight_order=Fight2}).

%过滤已达最大的属性
filter_max(StrongMap, Max)->
	lists:filter(fun
			({K, V, _W}) ->
				V2 = maps:get(K, StrongMap, 0),
				V2 < V
		end, Max).

%突破回退返还
evolution_back_gain(Order, Costs)->
	case maps:get(Order, Costs, ?nil) of
		?nil ->
			{Costs, []};
		{BList, List} ->
			Gain = calc_gain(BList, List),
			{maps:remove(Order, Costs), Gain}
	end.

calc_gain(BList, List)->
	BList2 = [ {ItemId, Num, 1} || {ItemId, Num} <- BList],
	List2 = [ {ItemId, Num, 2} || {ItemId, Num} <- List],
	lists:merge(BList2, List2).


%检测消耗
check_cost([], _Cost, CostCells, Gain, Flag, Pets, Costs, _Fight, Evolution, Bind, _RoleSt)->
	{CostCells, Gain, Flag, Pets, Costs, Evolution, Bind};
check_cost([ UId | UIds ], Cost, CostCells, Gain, Flag, Pets, Costs, Fight, Evolution, Bind, RoleSt)->
	{ok, Item} = role_bag:get_item(UId),
	#p_item{id=ItemId, bag=BagID, bind=NewBind, extra=OldEvolution} = Item,
	{Flag2, Costs2, Gain2, Pets2, Evolution2} = case BagID == ?BAG_ID_PET_ASSIST of
		true  ->
			#cfg_pet{order=Order} = cfg_pet:find(ItemId),
			{TCosts, TGain} = evolution_back_gain(Order, Costs),
			TPets = maps:remove(Order, Pets),
			OldEvolution2 = case Fight == Order of
				true  -> OldEvolution;
				false -> ?nil
			end,
			{Flag orelse true, TCosts, TGain, TPets, OldEvolution2};
		false ->
			{Flag, Costs, [], Pets, ?nil}
	end,
	?_check(lists:keymember(ItemId, 1, Cost), ?ERR_ITEM_NOT_ENOUGH),
	CostCells2 = [{cellid, UId} | CostCells],
	Evolution3 = case Evolution == ?nil of
		true  -> Evolution2;
		false -> Evolution
	end,
	Bind2 = NewBind orelse Bind,
	check_cost(UIds, Cost, CostCells2, lists:merge(Gain, Gain2), Flag2, Pets2, Costs2, Fight, Evolution3, Bind2, RoleSt).

%获取评分最高的
get_high_uid(UIds)->
	{Items, HighUId} = lists:foldl(fun
			(UId, {Acc, Acc2})->
				{ok, Item} = role_bag:get_item(UId),
				#p_item{bag=BagID} = Item,
				UId2 = case BagID == ?BAG_ID_PET_ASSIST of
					true  -> UId;
					false -> Acc2
				end,
				{[Item | Acc], UId2}
		end, {[], 0}, UIds),
	case HighUId > 0 of
		true ->
			HighUId;
		false ->
			Items2 = lists:keysort(#p_item.score, Items),
			#p_item{uid=UId} = lists:last(Items2),
			UId
	end.



%计算绑定，非绑定数量
calc_cells(Cost)->
	lists:foldl(fun
			({ItemID, Num}, {BLists, Lists}) ->
				BItems = role_bag:get_items(ItemID, true),
				Had = calc_num(BItems),
				case Had >= Num of
					true ->
						{[{ItemID, Num}|BLists], Lists};
					false ->
						Items = role_bag:get_items(ItemID),
						Had2 = calc_num(Items),
						?_check(Had2+Had >= Num, ?ERR_ITEM_NOT_ENOUGH),
						{[{ItemID, Had} | BLists], [{ItemID, Num-Had}|Lists]}
				end
		end, {[], []}, Cost).

%计算道具数量
calc_num(Items) ->
	lists:foldl(fun
			(#p_item{num=Num}, Acc) ->
				Acc + Num
		end, 0, Items).


