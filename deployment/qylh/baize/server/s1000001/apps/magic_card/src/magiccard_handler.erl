%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(magiccard_handler).

-include("game.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("table.hrl").
-include("magic_card.hrl").
-include("role.hrl").
-include("log.hrl").
-include("item.hrl").
-include("enum.hrl").
-include("bag.hrl").
-include("msgno.hrl").
-include("skill.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%卡槽列表
handle(?MAGIC_CARD_LIST, _Tos, RoleSt)->
	#role_magic_card{cards=Cards,suite_id=SuiteId} = role_data:get(?DB_ROLE_MAGIC_CARD),
	?ucast(#m_magic_card_suite_toc{suite_id=SuiteId}),
	Cards2 = maps:map(fun(_, UId) -> 
		{ok, Card} = role_bag:get_item(UId),
		item_util:p_item(Card) 
	end, Cards),
	{ok, #m_magic_card_list_toc{cards=Cards2}, RoleSt};

%获取背包里的属性值
handle(?MAGIC_CARD_BAG_INFO, _Tos, RoleSt)->
	#role_bag{money=Money} = role_data:get(?DB_ROLE_BAG),
	Items = #{
		?ITEM_MC_EXP  => maps:get(?ITEM_MC_EXP, Money, 0),
		?ITEM_MC_EXCH => maps:get(?ITEM_MC_EXCH, Money, 0),
		?ITEM_MC_FUSE => maps:get(?ITEM_MC_FUSE, Money, 0)
	},
	{ok, #m_magic_card_bag_info_toc{items=Items}, RoleSt};


%装备魔法卡
handle(?MAGIC_CARD_PUTON, Tos, RoleSt)->
	#m_magic_card_puton_tos{pos=Pos, uid=CellId} = Tos,
	RoleMagicCard = #role_magic_card{cards=Cards, suite_id=OldSuiteId}
	 = role_data:get(?DB_ROLE_MAGIC_CARD),
	check_pos(Pos),
	check_pos_open(Pos),
	{ok, Item} = role_bag:get_item(CellId),
	#p_item{id=ItemId} = Item,
	check_pos_type(Pos, ItemId),
	TmpCards = maps:remove(Pos, Cards),
	check_attr_type(maps:to_list(TmpCards), ItemId),
	%role_bag:cost([{cellid, CellId}], ?LOG_MAGIC_CARD_PUTON, RoleSt),
	{ok, _, [NewItem]} = role_bag:move(?BAG_ID_RUNE, ?BAG_ID_RUNE_EQUIP, [{CellId, 1}], RoleSt),
	case maps:get(Pos, Cards, ?nil) of
		?nil->
			ignor;
		OldCellId->
			role_bag:move(?BAG_ID_RUNE_EQUIP, ?BAG_ID_RUNE, [{OldCellId, 1}], RoleSt)
			%role_bag:gain([OldItem], ?LOG_MAGIC_CARD_PUTOFF, RoleSt)
	end,
	Cards2 = maps:put(Pos, NewItem#p_item.uid, Cards),
	SuiteId = calc_suite(Cards2),
	role_data:set(RoleMagicCard#role_magic_card{cards=Cards2, suite_id=SuiteId}),
	UpCards = #{Pos=>item_util:p_item(NewItem)},
	?ucast(#m_magic_card_suite_toc{suite_id=SuiteId}),
	?ucast(#m_magic_card_list_toc{cards=UpCards}),
	role_attr:recalc(role_magiccard, RoleSt),
	case SuiteId > OldSuiteId of
		true ->
			#role_st{role=RoleID, name=RoleName} = RoleSt,
			#cfg_magic_card_suite{skill_id=SkillID} = cfg_magic_card_suite:find(SuiteId),
			{SkillID2, _Level} = ut_conv:string_to_term(SkillID),
			#cfg_skill{name=SkillName} = cfg_skill:find(SkillID2),
			role_skill:active(SkillID2, RoleSt),
	 		?notify(?MSG_MAGICCARD_SUITE_NOTICE, [{role, RoleID, RoleName}, SkillName]);
		false ->
			ignore
	end,
	{ok, #m_magic_card_puton_toc{}, RoleSt};

%升星
handle(?MAGIC_CARD_UPSTAR, Tos, RoleSt)->
	#m_magic_card_upstar_tos{pos=Pos} = Tos,
	RoleMagicCard = #role_magic_card{cards=Cards} = role_data:get(?DB_ROLE_MAGIC_CARD),
	CellId = maps:get(Pos, Cards, 0),
	?_check(CellId /= 0, ?ERR_MAGICCARD_CARD_NOT_EXIST),
	{ok, Item} = role_bag:get_item(CellId),
	#p_item{id=Id} = Item,
	#cfg_magic_card{cost=Cost, star=Star, max_star=MaxStar} = cfg_magic_card:find(Id),
	?_check(Star < MaxStar, ?ERR_MAGICCARD_IS_MAX_STAR),
	CostList = get_cost_items(Cost, []),
	NewCost = [{cellid, Uid} || #p_item{uid=Uid} <- CostList],
	NewCost2 = [{cellid, CellId} | NewCost],
	Gain = get_magic_exp(CostList, {0, 0}),
	NewId = Id + 1,
	NewItem = Item#p_item{id=NewId},
	Gain2 = [NewItem | Gain],
	Func = fun(Deal) -> 
			#deal{update=Update} = Deal,
			#update{add=Add} = Update,
			lists:foldl(fun
				(#p_item_base{uid=NewUId, id=ItemId}, List) ->
					case ItemId == NewId of
						true ->
							[NewUId|List];
						false ->
							List
						end
			end, [], Add)
		end,
	{ok, _, _, Result} = role_bag:deal(NewCost2, Gain2, ?LOG_MAGIC_CARD_UPSTAR, Func, RoleSt),
	[CellId2 | _T] = Result,
	{ok, NewItem2} = role_bag:get_item(CellId2),
	Cards2 = maps:put(Pos, CellId2, Cards),
	role_data:set(RoleMagicCard#role_magic_card{cards=Cards2}),
	UpCards = #{Pos=>item_util:p_item(NewItem2)},
	?ucast(#m_magic_card_list_toc{cards=UpCards}),
	role_magiccard:update_bag_info([?ITEM_MC_EXP], RoleSt),
	role_attr:recalc(role_magiccard, RoleSt),
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	ItemMaps = maps:put(Id, 0, #{}),
	?notify(?MSG_MAGICCARD_UPSTAR_NOTICE, [{role, RoleID, RoleName}, {item, ItemMaps}, Star+1]),
	{ok, #m_magic_card_upstar_toc{pos=CellId}, RoleSt};

%强化
handle(?MAGIC_CARD_STRENGTH, Tos, RoleSt)->
	#m_magic_card_strength_tos{pos=Pos} = Tos,
	#role_magic_card{cards=Cards} = role_data:get(?DB_ROLE_MAGIC_CARD),
	case maps:get(Pos, Cards, ?nil) of
		?nil->
			?err(?ERR_MAGICCARD_CARD_NOT_EXIST);
		CellId ->
			{ok, Item=#p_item{id=ItemId, extra=StrenLv}} = role_bag:get_item(CellId),
			MagicCardStrenth = cfg_magic_card_strength:find(ItemId, StrenLv+1),
			?_check(MagicCardStrenth /= ?nil, ?ERR_MAGICCARD_IS_MAX_STRONG),
			#cfg_magic_card_strength{cost=Cost} = cfg_magic_card_strength:find(ItemId, StrenLv),
			role_bag:cost(Cost, ?LOG_MAGIC_CARD_STRENGTH, RoleSt),
			role_magiccard:update_bag_info([?ITEM_MC_EXP], RoleSt),
			StrenLv2 = StrenLv+1,
			Item2 = Item#p_item{extra=StrenLv2},
			role_bag:set_item(Item2),
			%Cards2 = maps:put(Pos, Item2, Cards),
			%role_data:set(RoleMagicCard#role_magic_card{cards=Cards2}),
			UpCards = #{Pos=>item_util:p_item(Item2)},
			?ucast(#m_magic_card_list_toc{cards=UpCards}),
			role_attr:recalc(role_magiccard, RoleSt),
			Rem = StrenLv2 rem 10,
			#role_st{role=RoleID, name=RoleName} = RoleSt,
			ItemMaps = maps:put(ItemId, 0, #{}),
			?_if(Rem == 0, ?notify(?MSG_MAGICCARD_STRENGTH_NOTICE, 
				[{role, RoleID, RoleName}, {item, ItemMaps}, StrenLv2])),
			{ok, #m_magic_card_strength_toc{pos=Pos}, RoleSt}
	end;

%魔法卡融合
handle(?MAGIC_CARD_COMBINE, Tos, RoleSt)->
	#m_magic_card_combine_tos{r_item_id=RItemId} = Tos,
	#cfg_magic_card_combine{c_item_id1=CItemId1,c_item_id2=CItemId2, cost=Cost}
	= cfg_magic_card_combine:find(RItemId),
	role_magiccard:check_gate(RItemId),
	RoleMagicCard = #role_magic_card{cards=Cards} = role_data:get(?DB_ROLE_MAGIC_CARD),
	Gain = [{RItemId, 1}],
	%消耗材料1
	CardsNum = maps:size(Cards),
	Pos1 = case CardsNum > 0 of
		true->get_pos_by_item_id(Cards, CItemId1);
		false->0
    end,
	{Cost2, StrenLv1} = get_cos_gain(Cards, Pos1, CItemId1),
	%消耗材料2
	Pos2 = case CardsNum > 0 of
		true->get_pos_by_item_id(Cards, CItemId2);
		false->0
	end,
	{Cost3, StrenLv2} = get_cos_gain(Cards, Pos2, CItemId2),
	%返还魔法星尘
	#cfg_magic_card_strength{total_cost=TGain1} = cfg_magic_card_strength:find(CItemId1, StrenLv1),
	#cfg_magic_card_strength{total_cost=TGain2} = cfg_magic_card_strength:find(CItemId2, StrenLv2),
	NewCost = lists:merge3(Cost, Cost2, Cost3),
	NewGain = lists:merge3(Gain, TGain1, TGain2),
	role_bag:deal(NewCost, NewGain, ?LOG_MAGIC_CARD_COMBINE, RoleSt),
	role_magiccard:update_bag_info([?ITEM_MC_EXP, ?ITEM_MC_FUSE], RoleSt),
	Poses = [],
	%删除装备的魔法卡
	{Poses2, Cards2} = case Pos1 > 0 of
		true-> {[Pos1 | Poses], maps:remove(Pos1, Cards)};
		false-> {Poses, Cards}
	end,
	{Poses3, Cards3} = case Pos2 > 0 of
		true-> {[Pos2 | Poses2], maps:remove(Pos2, Cards2)};
		false-> {Poses2, Cards2}
	end,
	role_data:set(RoleMagicCard#role_magic_card{cards=Cards3}),
	?ucast(#m_magic_card_putoff_toc{pos=Poses3}),
	role_attr:recalc(role_magiccard, RoleSt),
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	ItemMaps = maps:put(RItemId, 0, #{}),
	?notify(?MSG_MAGICCARD_COMPOSE_NOTICE, [{role, RoleID, RoleName}, {item, ItemMaps}]),
	{ok, #m_magic_card_combine_toc{}, RoleSt};

%获取分解设置
handle(?MAGIC_CARD_GET_SET, _Tos, RoleSt)->
	#role_magic_card{auto=Auto, colors=Colors} = role_data:get(?DB_ROLE_MAGIC_CARD),
	{ok, #m_magic_card_get_set_toc{auto=Auto, color=Colors}, RoleSt};

%设置自动分解
handle(?MAGIC_CARD_DECOMPOSE_SET, Tos, RoleSt)->
	#m_magic_card_decompose_set_tos{auto=Auto,color=Colors} = Tos,
	RoleMagicCard = role_data:get(?DB_ROLE_MAGIC_CARD),
	role_data:set(RoleMagicCard#role_magic_card{auto=Auto, colors=Colors}),
	?ucast(#m_magic_card_get_set_toc{auto=Auto, color=Colors}),
	{ok, #m_magic_card_decompose_set_toc{}, RoleSt};

%分解
handle(?MAGIC_CARD_DECOMPOSE, Tos, RoleSt)->
	#m_magic_card_decompose_tos{uid=CellIdList} = Tos,
	{Cost, Gain} = role_magiccard:decompose(CellIdList, [], []),
	role_bag:deal(Cost, Gain, ?LOG_MAGIC_CARD_DECOMPOSE, RoleSt),
	role_magiccard:update_bag_info([?ITEM_MC_EXP, ?ITEM_MC_EXCH, ?ITEM_MC_FUSE], RoleSt),
	{ok, #m_magic_card_decompose_toc{}, RoleSt}.


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------

%检查位置
check_pos(Pos)->
	?_check(Pos >= 1 andalso Pos =< 8, ?ERR_MAGICCARD_POS_WRONG).

%检查位置是否开放
check_pos_open(Pos)->
	#dunge_magic{clear_floor=Floor} = role_data:get(?DB_DUNGE_MAGIC),
	#cfg_magic_card_pos{gate=OpenGate} = cfg_magic_card_pos:find(Pos),
	?_check(Floor >= OpenGate, ?ERR_MAGICCARD_GATE_NOT_OPEN).

%检查魔法卡类型
check_pos_type(Pos, ItemId)->
	#cfg_magic_card{slot=Slot} = cfg_magic_card:find(ItemId),
	case is_core_pos(Pos) of
		true->
			?_check(Slot==2, ?ERR_MAGICCARD_TYPE_NOT_RIGHT);
		false->
			?_check(Slot==1, ?ERR_MAGICCARD_TYPE_NOT_RIGHT)
	end.

%检查魔法卡属性类型
check_attr_type([], ItemId)->
	ItemId;
check_attr_type(Cards, ItemId)->
	lists:foldl(fun
			({_K, CellId}, Sum)->
				{ok, #p_item{id=Id}} = role_bag:get_item(CellId),
				#cfg_magic_card{attr_type=AttrType} = cfg_magic_card:find(ItemId),
				#cfg_magic_card{attr_type=AttrType2} = cfg_magic_card:find(Id),
				?_check(AttrType /= AttrType2, ?ERR_MAGICCARD_ATTR_NOT_RIGHT),
				AttrTypeList = string:tokens(AttrType, "@"),
				AttrTypeList2 = string:tokens(AttrType2, "@"),
				lists:foldl(fun
						(AType, Sum2) ->
							 check_attr_type2(AType, AttrTypeList2),
							 Sum2 + 0
					end, 0, AttrTypeList),
				Sum + 0
		end, 0, Cards).

check_attr_type2(AType, [])->
	AType;
check_attr_type2(AType, [AType2|ATList])->
	?_check(AType /= AType2, ?ERR_MAGICCARD_ATTR_NOT_RIGHT),
	check_attr_type2(AType, ATList).

%计算套装
calc_suite(Cards)->
	%核心卡颜色，数量
	IdList = cfg_magic_card_suite:find_id(),
	get_suite_id(Cards, IdList, 0).

get_suite_id(_Cards, [], SuiteId)->
	SuiteId;
get_suite_id(Cards, [Id|IdList], SuiteId) ->
	#cfg_magic_card_suite{com_sum=Sum,com_color=Color,is_compose=IsCompose}
	= cfg_magic_card_suite:find(Id),
	AcSum = get_pos_num(Cards, Color, IsCompose),
	SuiteId2 = case AcSum >= Sum of
		true->
			case Id > SuiteId of
				true  -> Id;
			    false -> SuiteId
			end;
		false->
			SuiteId
	end,
	get_suite_id(Cards, IdList, SuiteId2).


%获取位置上满足条件的数量
get_pos_num(Cards, Color, IsCompose)->
	maps:fold(fun 
			(_, CellId, Acc)-> 
				{ok, #p_item{id=ItemId}} = role_bag:get_item(CellId), 
				#cfg_item{color=Color2} = cfg_item:find(ItemId),
				#cfg_magic_card{attr_type=AttrType} = cfg_magic_card:find(ItemId),
				case Color2 >= Color andalso get_compose(AttrType) >= IsCompose of
					true  -> Acc + 1;
					false -> Acc
				end
		end, 0, Cards).

get_compose(AttrType)->
	case string:str(AttrType, "@") > 0 of
		true  -> 1;
		false -> 0
	end.



%是否核心部位
is_core_pos(Pos)->
	case Pos >= 1 andalso Pos =< 2 of
		true->true;
		_-> false
	end.


%获取消耗的魔法卡
get_cost_items([], ResultList)->
	ResultList;
get_cost_items([{ItemId,Num}|Cost], ResultList)->
	ItemList = role_bag:get_items(ItemId),
	?_check(length(ItemList)>=Num, ?ERR_MAGICCARD_CARDS_NOT_ENOUGH),
	ItemList2 = lists:sublist(ItemList, Num),
	ResultList2 = ResultList ++ ItemList2,
	get_cost_items(Cost, ResultList2).

%获取魔法星尘
get_magic_exp([], {ItemId, Exp})->
	case Exp == 0 of
		true->[];
		false->[{ItemId, Exp}]
	end;
get_magic_exp([#p_item{id=OldItemId, extra=Lv}|ItemList], {ItemId, Exp})->
	case Lv > 1 of
		true->
			#cfg_magic_card_strength{total_cost=TotalCost} = cfg_magic_card_strength:find(OldItemId, Lv),
			[{ItemId2, AddExp} | _TotalCost] = TotalCost,
			get_magic_exp(ItemList, {ItemId2, Exp+AddExp});
		false->
			get_magic_exp(ItemList, {ItemId, Exp})
    end.

%根据itemid查找装备的魔法卡位置
get_pos_by_item_id(Cards, ItemId)->
	PosList = maps:fold(fun
			(Pos, CellId, Lists)->
				{ok, #p_item{id=Id}} = role_bag:get_item(CellId),
				case Id == ItemId of
					true-> [Pos | Lists];
					false-> Lists
				end
		end, [], Cards),
	case length(PosList) > 0 of
		true-> lists:nth(1, PosList);
		false-> 0
	end.

%获取消耗和获得的魔法卡
get_cos_gain(Cards, Pos, ItemId)->
	case Pos > 0 of
		true->
			CellId = maps:get(Pos, Cards),
			{ok, #p_item{extra=Lv}} = role_bag:get_item(CellId),
			{[{cellid, CellId}], Lv};
		false->
			ItemList = role_bag:get_items(ItemId),
			?_check(length(ItemList)>0, ?ERR_ITEM_NOT_ENOUGH),
			#p_item{uid=Uid, extra=Lv} = lists:nth(1, ItemList),
			{[{cellid, Uid}], Lv}
	end.

