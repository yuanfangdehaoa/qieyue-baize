%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(pet_equip_handler).

-include("bag.hrl").
-include("game.hrl").
-include("item.hrl").
-include("pet.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/3]).
-export([get_attr/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
handle(?PET_EQUIPS, Tos, RoleSt) ->
	#m_pet_equips_tos{pet_id=PetID} = Tos,
	#role_pet{equips=AllEquips} = role_data:get(?DB_ROLE_PET),
	Equips = maps:get(PetID, AllEquips, #{}),
	Items  = lists:map(fun
		(CellID) ->
			{ok, Item} = role_bag:get_item(CellID),
			item_util:p_item(Item)
	end, maps:values(Equips)),
	?ucast(#m_pet_equips_toc{pet_id=PetID, equips=Items});

handle(?PET_EQUIP_PUTON, Tos, RoleSt) ->
	#m_pet_equip_puton_tos{pet_id=PetID, equip_id=CellID} = Tos,
    {ok, Item} = role_bag:get_item(CellID),
    #p_item{id=ItemID, equip=#p_equip{stren_phase=Order}} = Item,
    #cfg_item{stype=Slot} = cfg_item:find(ItemID),
	RolePet = role_data:get(?DB_ROLE_PET),
	#role_pet{pets=AllPets, equips=AllEquips} = RolePet,
	PetCellID = maps:get(PetID, AllPets, ?nil),
	?_check(PetCellID /= ?nil, ?ERR_PET_IS_NOT_PUTON),
	{ok, #p_item{id=PetItemID}} = role_bag:get_item(PetCellID),
	#cfg_pet{quality=Qual} = cfg_pet:find(PetItemID),
	#cfg_pet_equip{limit=Limit} = cfg_pet_equip:find(ItemID, Order),
	QualLim = proplists:get_value(quality, Limit, 0),
	?_check(Qual >= QualLim, ?ERR_PET_EQUIP_CAN_NOT_PUTON),
	Equips = maps:get(PetID, AllEquips, #{}),
	OldCellID = maps:get(Slot, Equips, 0),
    {ok, _, [Equip]} = puton_equip(CellID, RoleSt),
    ?_if(OldCellID > 0, putoff_equip(OldCellID, RoleSt)),
    Equips2 = maps:put(Slot, Equip#p_item.uid, Equips),
    AllEquips2 = maps:put(PetID, Equips2, AllEquips),
    role_data:set(RolePet#role_pet{equips=AllEquips2}),
    role_attr:recalc(?MODULE, RoleSt),
	?ucast(#m_pet_equip_puton_toc{
		pet_id = PetID,
		slot   = Slot,
		equip  = item_util:p_item(Equip)
	});

handle(?PET_EQUIP_PUTOFF, Tos, RoleSt) ->
	#m_pet_equip_putoff_tos{pet_id=PetID, slot=Slot} = Tos,
	RolePet = role_data:get(?DB_ROLE_PET),
	#role_pet{pets=AllPets, equips=AllEquips} = RolePet,
	?_check(maps:is_key(PetID, AllPets), ?ERR_PET_IS_NOT_PUTON),
	Equips = maps:get(PetID, AllEquips, #{}),
	CellID = maps:get(Slot, Equips, 0),
	?_check(CellID > 0, ?ERR_PET_EQUIP_NOT_PUTON),
	putoff_equip(CellID, RoleSt),
	Equips2 = maps:remove(Slot, Equips),
	AllEquips2 = maps:put(PetID, Equips2, AllEquips),
    role_data:set(RolePet#role_pet{equips=AllEquips2}),
    role_attr:recalc(?MODULE, RoleSt),
	?ucast(#m_pet_equip_putoff_toc{pet_id=PetID, slot=Slot});

handle(?PET_EQUIP_REINF, Tos, RoleSt) ->
	#m_pet_equip_reinf_tos{pet_id=PetID, slot=Slot} = Tos,
	RolePet = role_data:get(?DB_ROLE_PET),
	#role_pet{pets=AllPets, equips=AllEquips} = RolePet,
	?_check(maps:is_key(PetID, AllPets), ?ERR_PET_IS_NOT_PUTON),
	Equips = maps:get(PetID, AllEquips, #{}),
	CellID = maps:get(Slot, Equips, 0),
	?_check(CellID > 0, ?ERR_PET_EQUIP_NOT_PUTON),
	{ok, Item} = role_bag:get_item(CellID),
	#p_item{id=ItemID, equip=EquipInfo} = Item,
	#cfg_item{color=Color, stype=Slot} = cfg_item:find(ItemID),
	?_check(Color >= ?COLOR_PURPLE, ?ERR_PET_EQUIP_CAN_NOT_REINF),
	#p_equip{stren_phase=Order, stren_lv=Level} = EquipInfo,
	?_check(Level < Order*10, ?ERR_PET_EQUIP_MAX_REINF),
	NewLevel = Level + 1,
	#cfg_pet_equip_strength{cost=Cost} = cfg_pet_equip_strength:find(Slot, NewLevel),
	role_bag:cost(Cost, ?LOG_PET_EQUIP_REINF, RoleSt),
	NewEquip = EquipInfo#p_equip{stren_lv=NewLevel},
	NewItem0 = Item#p_item{equip=NewEquip},
	NewItem  = calc_equip_attr(NewItem0),
	role_bag:set_item(NewItem),
    role_attr:recalc(?MODULE, RoleSt),
    case NewLevel rem 10 == 0 of
    	true  ->
    		#role_st{role=RoleID, name=RoleName} = RoleSt,
    		CacheID = item_cache:add_cache(NewItem),
    		?notify(
    			?MSG_PET_EQUIP_REINF,
    			[{role,RoleID,RoleName}, {pitem,#{CacheID=>ItemID}}, NewLevel]
    		);
    	false ->
    		ignore
    end,
	?ucast(#m_pet_equip_reinf_toc{
		pet_id = PetID,
		slot   = Slot,
		equip  = item_util:p_item(NewItem)
	});

handle(?PET_EQUIP_UPORDER, Tos, RoleSt) ->
	#m_pet_equip_uporder_tos{pet_id=PetID, slot=Slot} = Tos,
	RolePet = role_data:get(?DB_ROLE_PET),
	#role_pet{pets=AllPets, equips=AllEquips} = RolePet,
	?_check(maps:is_key(PetID, AllPets), ?ERR_PET_IS_NOT_PUTON),
	Equips = maps:get(PetID, AllEquips, #{}),
	CellID = maps:get(Slot, Equips, 0),
	?_check(CellID > 0, ?ERR_PET_EQUIP_NOT_PUTON),
	{ok, Item} = role_bag:get_item(CellID),
	#p_item{id=ItemID, equip=EquipInfo} = Item,
	#cfg_item{color=Color} = cfg_item:find(ItemID),
	?_check(Color >= ?COLOR_ORANGE, ?ERR_PET_EQUIP_CAN_NOT_UPORDER),
	#p_equip{stren_phase=Order, stren_lv=Level} = EquipInfo,
	?_check(Level == Order*10, ?ERR_PET_EQUIP_CAN_NOT_UPORDER),
	NewOrder = Order + 1,
	CfgPetEquip = cfg_pet_equip:find(ItemID, NewOrder),
	?_check(CfgPetEquip /= ?nil, ?ERR_PET_EQUIP_MAX_ORDER),
	#cfg_pet_equip{cost=Cost} = CfgPetEquip,
	role_bag:cost(Cost, ?LOG_PET_EQUIP_REINF, RoleSt),
	NewEquip = EquipInfo#p_equip{stren_phase=NewOrder},
	NewItem0 = Item#p_item{equip=NewEquip},
	NewItem  = calc_equip_attr(NewItem0),
	role_bag:set_item(NewItem),
    role_attr:recalc(?MODULE, RoleSt),
    #role_st{role=RoleID, name=RoleName} = RoleSt,
    CacheID = item_cache:add_cache(NewItem),
    ?notify(
    	?MSG_PET_EQUIP_UPORDER,
    	[{role,RoleID,RoleName}, {pitem,#{CacheID=>ItemID}}, NewOrder]
    ),
	?ucast(#m_pet_equip_uporder_toc{
		pet_id = PetID,
		slot   = Slot,
		equip  = item_util:p_item(NewItem)
	});

handle(?PET_EQUIP_SMELT, Tos, RoleSt) ->
	#m_pet_equip_smelt_tos{item_uid=CellIDs} = Tos,
	?_check(
		length(lists:usort(CellIDs)) == length(CellIDs),
		?ERR_GAME_BAD_ARGS
	),
	TotalExp = lists:foldl(fun
		(CellID, AccExp) ->
			{ok, Item} = role_bag:get_item(CellID),
			#p_item{id=ItemID, equip=EquipInfo} = Item,
			#p_equip{stren_phase=Order, stren_lv=Level} = EquipInfo,
			?_check(Order == 1 andalso Level == 0, ?ERR_PET_EQUIP_CAN_NOT_SMELT),
			#cfg_pet_equip{exp=Exp} = cfg_pet_equip:find(ItemID, 1),
			AccExp + Exp
	end, 0, CellIDs),
	{ok, _, Obtain} = role_bag:deal(
		[{cellid,CellID,1} || CellID <- CellIDs],
		[{?ITEM_PETEQUIP_EXP, TotalExp}],
		?LOG_PET_EQUIP_SMELT,
		RoleSt
	),
	?ucast(#m_pet_equip_smelt_toc{refund=Obtain});

handle(?PET_EQUIP_SPLIT, Tos, RoleSt) ->
	#m_pet_equip_split_tos{item_uid=CellID} = Tos,
	{ok, Item} = role_bag:get_item(CellID),
	#p_item{id=ItemID, equip=EquipInfo} = Item,
	#p_equip{stren_phase=Order, stren_lv=Level} = EquipInfo,
	?_check(Order > 1 orelse Level > 0, ?ERR_PET_EQUIP_CAN_NOT_SPLIT),
	#cfg_item{stype=Slot} = cfg_item:find(ItemID),
	Gain1 = calc_reinf_cost(Slot, Level, []),
	Gain2 = calc_uporder_cost(ItemID, Order, []),
	{ok, Obtain} = role_bag:gain(Gain1++Gain2, ?LOG_PET_EQUIP_SPLIT, RoleSt),
	NewEquip = EquipInfo#p_equip{stren_phase=1, stren_lv=0},
	NewItem0 = Item#p_item{equip=NewEquip},
	NewItem  = calc_equip_attr(NewItem0),
	role_bag:set_item(NewItem),
	?ucast(#m_pet_equip_split_toc{
		equip  = item_util:p_item(NewItem),
		refund = Obtain
	});

handle(?PET_EQUIP_INHERIT, Tos, RoleSt) ->
	#m_pet_equip_inherit_tos{src_item_uid=SrcUID, dst_item_uid=DstUID} = Tos,
	{ok, SrcItem} = role_bag:get_item(SrcUID),
	SrcEquip = #p_equip{stren_phase=SrcOrder, stren_lv=SrcLevel} = SrcItem#p_item.equip,
	?_check(SrcOrder > 1 orelse SrcLevel > 0, ?ERR_PET_EQUIP_CAN_NOT_INHERIT),
	{ok, DstItem} = role_bag:get_item(DstUID),
	DstEquip = #p_equip{stren_phase=DstOrder, stren_lv=DstLevel} = DstItem#p_item.equip,
	?_check(DstOrder == 1 andalso DstLevel == 0, ?ERR_PET_EQUIP_CAN_NOT_INHERIT),
	SrcItem1 = SrcItem#p_item{equip=SrcEquip#p_equip{stren_phase=1, stren_lv=0}},
	DstItem1 = DstItem#p_item{equip=DstEquip#p_equip{stren_phase=SrcOrder, stren_lv=SrcLevel}},
	SrcItem2 = calc_equip_attr(SrcItem1),
	DstItem2 = calc_equip_attr(DstItem1),
	role_bag:set_item(SrcItem2),
	role_bag:set_item(DstItem2),
	?ucast(#m_pet_equip_inherit_toc{
		src_item = item_util:p_item(SrcItem2),
		dst_item = item_util:p_item(DstItem2)
	}).

get_attr(_AttrType) ->
	#role_pet{pets=Pets, equips=AllEquips} = role_data:get(?DB_ROLE_PET),

	maps:fold(fun
		(PetID, Equips, Acc1) ->
			{ok, Pet} = role_bag:get_item(maps:get(PetID, Pets)),
			{Items, Attr} = lists:foldl(fun
				(CellID, {AccItems, AccAttr}) ->
					{ok, Item} = role_bag:get_item(CellID),
					#p_item{equip=EquipInfo} = Item,
					AccAttr2 = mod_attr:sum([
						AccAttr,
						EquipInfo#p_equip.base,
						EquipInfo#p_equip.rare1,
						EquipInfo#p_equip.rare2,
						EquipInfo#p_equip.rare3
					]),
					{[Item|AccItems], AccAttr2}
			end, {[], #{}}, maps:values(Equips)),

			SuitAttr = case length(Items) == 4 of
				true  ->
					SuitID = get_suit_id(Pet#p_item.id, Items),
					cfg_pet_equip_suite:attr(Pet#p_item.id, SuitID);
				false ->
					[]
			end,

			mod_attr:sum([Acc1, Attr, SuitAttr])
	end, #{}, AllEquips).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
puton_equip(CellID, RoleSt) ->
	role_bag:move(
		?BAG_ID_PET_EQUIP, ?BAG_ID_PET_LOAD_EQUIP, [{CellID,1}], RoleSt
	).

putoff_equip(CellID, RoleSt) ->
	role_bag:move(
		?BAG_ID_PET_LOAD_EQUIP, ?BAG_ID_PET_EQUIP, [{CellID,1}], RoleSt
	).

calc_equip_attr(Item) ->
	#p_item{id=ItemID, equip=EquipInfo} = Item,
	#cfg_item{stype=SType} = cfg_item:find(ItemID),
	#p_equip{
		stren_phase=Order, stren_lv=Level, rare1=Rare1, rare2=Rare2, rare3=Rare3
	} = EquipInfo,
	CfgPetEquip = cfg_pet_equip:find(ItemID, Order),
	#cfg_pet_equip{
		base=CfgBase, rare1=CfgRare1, rare2=CfgRare2, rare3=CfgRare3
	} = CfgPetEquip,
	#cfg_pet_equip_strength{attr=ReinfAttr} = cfg_pet_equip_strength:find(SType, Level),
	EquipInfo2 = EquipInfo#p_equip{
		base  = mod_attr:add(CfgBase, ReinfAttr),
		rare1 = update_rare_attr(Rare1, CfgRare1),
		rare2 = update_rare_attr(Rare2, CfgRare2),
		rare3 = update_rare_attr(Rare3, CfgRare3)
	},
	Item#p_item{equip=EquipInfo2}.

update_rare_attr(Had, Cfg) ->
	maps:map(fun
		(AttrID, AttrVal) ->
			case lists:keyfind(AttrID, 1, Cfg) of
				{_, AttrVal2, _} ->
					AttrVal2;
				_ ->
					AttrVal
			end
	end, Had).

calc_reinf_cost(_Slot, Level, Acc) when Level =< 0 ->
	Acc;
calc_reinf_cost(Slot, Level, Acc) ->
	#cfg_pet_equip_strength{cost=Cost} = cfg_pet_equip_strength:find(Slot, Level),
	calc_reinf_cost(Slot, Level-1, Cost++Acc).

calc_uporder_cost(_ItemID, Order, Acc) when Order =< 1 ->
	Acc;
calc_uporder_cost(ItemID, Order, Acc) ->
	#cfg_pet_equip{cost=Cost} = cfg_pet_equip:find(ItemID, Order),
	calc_uporder_cost(ItemID, Order-1, Cost++Acc).

get_suit_id(PetID, Items) ->
	SuitIDs = lists:reverse(lists:sort(cfg_pet_equip_suite:suits(PetID))),
	get_suit_id2(SuitIDs, PetID, Items).

get_suit_id2([SuitID | T], PetID, Items) ->
	{ColorLim, StarLim} = cfg_pet_equip_suite:limit(PetID, SuitID),
	IsSuit = lists:all(fun
		(Item) ->
			#p_item{id=ItemID, equip=EquipInfo} = Item,
			#cfg_item{color=Color} = cfg_item:find(ItemID),
			case Color >= ColorLim of
				true  ->
					#p_equip{stren_phase=Order} = EquipInfo,
					#cfg_pet_equip{star=Star} = cfg_pet_equip:find(ItemID, Order),
					Star >= StarLim;
				false ->
					false
			end
	end, Items),
	case IsSuit of
		true  -> SuitID;
		false -> get_suit_id2(T, PetID, Items)
	end;
get_suit_id2([], _PetID, _Items) ->
	0.
