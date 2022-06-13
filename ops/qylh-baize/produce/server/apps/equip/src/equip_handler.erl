%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(equip_handler).

-include("equip.hrl").
-include("game.hrl").
-include("item.hrl").
-include("pet.hrl").
-include("role.hrl").
-include("table.hrl").
-include("log.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("msgno.hrl").
-include("bag.hrl").
-include("enum.hrl").

%% API
-export([handle/3, check_puton/1]).
-export([calc_strength_suite/1]).
-export([is_max_strength/4]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 装备列表
handle(?EQUIP_LIST, _Tos, RoleSt) ->
	#role_equip{equips = Equips} = role_data:get(?DB_ROLE_EQUIP),
	Items = maps:fold(fun
			(_, CellId, Lists) ->
				{ok, Item} = role_bag:get_item(CellId),
				Item2 = role_equip:get_item(Item),
				[item_util:p_item(Item2) | Lists]
		end, [], Equips),

	?ucast(#m_equip_list_toc{equips=Items});

%% 穿上装备
handle(?EQUIP_PUTON, Tos, RoleSt) ->
	#m_equip_puton_tos{uid = CellId} = Tos,
	Item = case role_bag:get_item(CellId) of
		{ok, TmpItem}->TmpItem;
		Error -> throw(Error)
	end,
	#p_item{id=ItemId} = Item,
	check_puton(Item),
	RoleEquip = role_data:get(?DB_ROLE_EQUIP),
	#role_equip{equips=Equips, suites=Suites, stones=Stones, suite_cost=SuiteCost, casts=Casts} = RoleEquip,
	#cfg_equip{slot = Slot} = cfg_equip:find(ItemId),
	OldCellId = maps:get(Slot, Equips, 0),
	%原部位上是否有装备
	{Gains3, Suites3, SuiteCost3, Casts3}= case OldCellId > 0 of
		true ->
			{ok, OldItem} = role_bag:get_item(OldCellId),
			#p_item{id=OldId} = OldItem,
			%是否退回套装制作材料
			Gains = get_suite_materia(SuiteCost, Slot, OldId, ItemId),
			Suites2 = case length(Gains) > 0 of
				true->
					clear_suite_maked(Suites, Slot);
				false->
					notify_suite(Suites, Slot, RoleSt),
					Suites
			end,
			%返回铸造材料
			CastGains = get_cast_materia(Casts, OldId, ItemId),
			Gains2 = lists:merge(Gains, CastGains),
			EmptyNum = role_bag:get_empty(?BAG_ID_MAIN),
			?_check(EmptyNum >= length(Gains2) + 1, ?ERR_BAG_NO_SPACE),
			SuiteCost2 = case length(Gains) > 0 of
				true  -> maps:remove(Slot, SuiteCost);
				false -> SuiteCost
			end,
			Casts2 = case length(CastGains) > 0 of
				true  -> clear_cast(Slot, Casts);
				false -> Casts
			end,
			clear_item(OldItem),
			role_bag:move(?BAG_ID_EQUIP, ?BAG_ID_MAIN, [{OldCellId, 1}], RoleSt),
			{Gains2, Suites2, SuiteCost2, Casts2};
		_->
			{[], Suites, SuiteCost, Casts}
	end,
	{ok, _, [NewItem]} = role_bag:move(?BAG_ID_MAIN, ?BAG_ID_EQUIP, [{CellId,1}], RoleSt),
	role_bag:gain(Gains3, ?LOG_EQUIP_PUTOFF, RoleSt),
	Equips2 = maps:put(Slot, NewItem#p_item.uid, Equips),
	Stones2 = cal_stones(Slot, ItemId, Stones, RoleSt),
	notify_strength(Slot, ItemId, RoleSt),
	role_data:set(RoleEquip#role_equip{
		equips     = Equips2,
		suites     = Suites3,
		stones     = Stones2,
		suite_cost = SuiteCost3,
		casts      = Casts3
	}),
	send_all_suites(Suites3, RoleSt),
	Item3 = role_equip:get_item(NewItem),
	?ucast(#m_equip_list_toc{equips = [item_util:p_item(Item3)]}),
	role_attr:recalc(role_equip, RoleSt),
	role_event:event(?EVENT_EQUIP, {Slot, ItemId, Equips2}),
	{ok, #m_equip_puton_toc{slot=Slot}, RoleSt};

%%精灵卸下
handle(?EQUIP_TAKEDOWN, Tos, RoleSt) ->
	#m_equip_takedown_tos{slot=Slot} = Tos,
	?_check(Slot==?ITEM_STYPE_FAIRY orelse Slot ==?ITEM_STYPE_FAIRY2, ?ERR_EQUIP_ONLY_FAIRY_CAN_OFF),
	RoleEquip = #role_equip{equips=Equips} = role_data:get(?DB_ROLE_EQUIP),
	CellId = maps:get(Slot, Equips, 0),
	case CellId == 0 of
		true ->
			throw(?err(?ERR_EQUIP_NOT_PUTON));
		false ->
			Equips2 = maps:remove(Slot, Equips),
			role_data:set(RoleEquip#role_equip{equips = Equips2}),
			role_bag:move(?BAG_ID_EQUIP, ?BAG_ID_MAIN, [{CellId, 1}], RoleSt),
			role_attr:recalc(role_equip, RoleSt),
			{ok, #m_equip_takedown_toc{slot=Slot}, RoleSt}
	end;


%获取强化套装
handle(?EQUIP_GETSTRENGTHSUITE, _Tos, RoleSt)->
	#role_equip{strength_suite_id=StrengthSuiteId} = role_data:get(?DB_ROLE_EQUIP),
	{ok, #m_equip_getstrengthsuite_toc{id=StrengthSuiteId}, RoleSt};

%强化
handle(?EQUIP_STRENGTH, Tos, RoleSt)->
	?_check(role_misc:is_sys_open({equip_handler,1}), ?ERR_GAME_SYS_OPENED),
	#m_equip_strength_tos{slot=Slot} = Tos,
	RoleEquip = role_data:get(?DB_ROLE_EQUIP),
	#role_equip{equips=Equips, strengths=Strengths} = RoleEquip,
	CellId = maps:get(Slot, Equips, 0),
	?_check(CellId > 0, ?ERR_EQUIP_NOT_PUTON),
	{ok, Item} = role_bag:get_item(CellId),
	#equip_strength{phase=Phase, level=Level} = role_equip:get_equip_strength(Slot),
	check_strength(Item, Slot, Phase, Level),
	{Result, TmpES, Strengths2, Cost} = strength(Slot, Item, Strengths, {?ITEM_COIN, 0}),
	role_bag:cost([Cost], ?LOG_EQUIP_STRENGTH, RoleSt),
	role_data:set(RoleEquip#role_equip{strengths=Strengths2}),
	Item2 = role_equip:get_item(Item),
	role_equip:send_item_toc(Item2, RoleSt),
	role_attr:recalc(role_equip, RoleSt),
	role_event:event(?EVENT_EQUIP_STR_FINAL),
	#equip_strength{bless_value=BlessValue2} = TmpES,
	?ucast(#m_equip_strong_bless_toc{slot=Slot, bless=BlessValue2}),
	{ok, #m_equip_strength_toc{slot=Slot, result=Result}, RoleSt};

%一键强化
handle(?EQUIP_STRENGTH_ALL, Tos, RoleSt)->
	?_check(role_misc:is_sys_open({equip_handler,1}), ?ERR_GAME_SYS_OPENED),
	#m_equip_strength_all_tos{slot=Slot} = Tos,
	RoleEquip = role_data:get(?DB_ROLE_EQUIP),
	#role_equip{equips=Equips, strengths=Strengths} = RoleEquip,
	Coin = role_bag:get_money(?ITEM_COIN),
	{Strengths2, Cost} = strength_all(Equips, Strengths, Coin, {?ITEM_COIN, 0}),
	role_bag:cost([Cost], ?LOG_EQUIP_STRENGTH, RoleSt),
	role_data:set(RoleEquip#role_equip{strengths=Strengths2}),
	role_attr:recalc(role_equip, RoleSt),
	role_event:event(?EVENT_EQUIP_STR_FINAL),
	Items = maps:fold(fun
			(_, CellId, Lists) ->
				{ok, Item} = role_bag:get_item(CellId),
				Item2 = role_equip:get_item(Item),
				[item_util:p_item(Item2) | Lists]
		end, [], Equips),
	?ucast(#m_equip_list_toc{equips=Items}),
	#equip_strength{bless_value=BlessValue} = role_equip:get_equip_strength(Slot),
	?ucast(#m_equip_strong_bless_toc{slot=Slot, bless=BlessValue}),
	CellId = maps:get(Slot, Equips, 0),
	{ok, Item} = role_bag:get_item(CellId),
	Item2 = role_equip:get_item(Item),
	role_equip:send_item_toc(Item2, RoleSt),
	?ucast(#m_equip_strength_toc{slot=Slot, result=0}),
	{ok, #m_equip_strength_all_toc{}, RoleSt};

%强化套装升级
handle(?EQUIP_STRONG_SUITE_UP, _Tos, RoleSt)->
	RoleEquip = role_data:get(?DB_ROLE_EQUIP),
	#role_equip{strength_suite_id=SuiteID} = RoleEquip,
	NextSuiteID = SuiteID + 1,
	StrenghSuiteCfg =  cfg_equip_strength_suite:find(NextSuiteID),
	?_check(StrenghSuiteCfg /= ?nil, ?ERR_EQUIP_SS_REACH_MAX_LEVEL),
	#cfg_equip_strength_suite{phase=Phase, level=Level, slots=Slots, num=Num} = StrenghSuiteCfg,
	HadNum = check_slot(Slots, Phase, Level, 0),
	?_check(HadNum >= Num, ?ERR_EQUIP_SS_CAN_NOT_UP),
	RoleEquip2 = RoleEquip#role_equip{strength_suite_id=NextSuiteID},
	role_data:set(RoleEquip2),
	role_attr:recalc(role_equip, RoleSt),
	?ucast(#m_equip_getstrengthsuite_toc{id=NextSuiteID}),
	{ok, #m_equip_strong_suite_up_toc{}, RoleSt};

%获取祝福值
handle(?EQUIP_STRONG_BLESS, Tos, RoleSt)->
	#m_equip_strong_bless_tos{slot=Slot} = Tos,
	#equip_strength{bless_value=BlessValue} = role_equip:get_equip_strength(Slot),
	{ok, #m_equip_strong_bless_toc{slot=Slot, bless=BlessValue}, RoleSt};

%宝石镶嵌
handle(?EQUIP_STONE_FILLIN, Tos, RoleSt)->
	?_check(role_misc:is_sys_open({equip_handler,2}), ?ERR_GAME_SYS_OPENED),
	#m_equip_stone_fillin_tos{slot=Slot, hole=Hole, item_id=ItemId} = Tos,
	#role_equip{equips=Equips, stones=AllStones} = RoleEquip = role_data:get(?DB_ROLE_EQUIP),
	CellId = maps:get(Slot, Equips, 0),
	?_check(CellId > 0, ?ERR_EQUIP_NOT_PUTON),
	{ok, Item} = role_bag:get_item(CellId),
	#p_item{id=Id} = Item,
	#cfg_equip{order=Order} = cfg_equip:find(Id),
	VipLv = role_vip:get_level(),
	check_hole(Hole, Order, VipLv),
	check_stone(ItemId, Slot),
	Stones = maps:get(Slot, AllStones, #{}),
	Gain = case maps:get(Hole, Stones, ?nil) of
		?nil->  %原来的孔没有宝石
			[];
		OldItemId->     %原来的孔有宝石
			[{OldItemId, 1}]
	end,
	role_bag:deal([{ItemId, 1}], Gain, ?LOG_EQUIP_STONE_FILLIN, RoleSt),
	Stones2 = maps:put(Hole, ItemId, Stones),
	AllStones2 = maps:put(Slot, Stones2, AllStones),
	role_data:set(RoleEquip#role_equip{stones=AllStones2}),
	Item2 = role_equip:get_item(Item),
	role_equip:send_item_toc(Item2, RoleSt),
	role_attr:recalc(role_equip, RoleSt),
	role_event:event(?EVENT_STONE, AllStones2),
	{ok, #m_equip_stone_fillin_toc{slot=Slot}, RoleSt};

%取下宝石
handle(?EQUIP_STONE_TAKEDOWN, Tos, RoleSt)->
	#m_equip_stone_takedown_tos{slot=Slot, hole=Hole} = Tos,
	RoleEquip = #role_equip{equips=Equips, stones=AllStones} = role_data:get(?DB_ROLE_EQUIP),
	CellId = maps:get(Slot, Equips, 0),
	?_check(CellId > 0, ?ERR_EQUIP_NOT_PUTON),
	{ok, Item} = role_bag:get_item(CellId),
	Stones = maps:get(Slot, AllStones, #{}),
	case maps:get(Hole, Stones, ?nil) of
		?nil ->
			throw(?err(?ERR_EQUIP_NO_STONE));
		ItemId ->
			role_bag:gain([{ItemId, 1}], ?LOG_EQUIP_STONE_TAKEDOWN, RoleSt),
			Stones2 = maps:remove(Hole, Stones),
			AllStones2 = maps:put(Slot, Stones2, AllStones),
			role_data:set(RoleEquip#role_equip{stones=AllStones2}),
			Item2 = role_equip:get_item(Item),
			role_equip:send_item_toc(Item2, RoleSt),
			role_attr:recalc(role_equip, RoleSt),
			{ok, #m_equip_stone_takedown_toc{slot=Slot}, RoleSt}
	end;


%装备孔上的宝石升级
handle(?EQUIP_STONE_UPLEVEL, Tos, RoleSt)->
	#m_equip_stone_uplevel_tos{slot=Slot, hole=Hole} = Tos,
	RoleEquip = #role_equip{equips=Equips, stones=AllStones} = role_data:get(?DB_ROLE_EQUIP),
	CellId = maps:get(Slot, Equips, 0),
	?_check(CellId > 0, ?ERR_EQUIP_NOT_PUTON),
	{ok, Item} = role_bag:get_item(CellId),
	Stones = maps:get(Slot, AllStones, #{}),
	case maps:get(Hole, Stones, ?nil) of
		?nil ->
			throw(?err(?ERR_EQUIP_NO_STONE));
		ItemId ->
			#cfg_item{type=Type} = cfg_item:find(ItemId),
			case Type of
				?ITEM_TYPE_STONE ->
					#cfg_stone{next_level_id=NextItemId, need_num=NeedNum} = cfg_stone:find(ItemId);
				_ ->
					#cfg_spar{next_level_id=NextItemId, need_num=NeedNum} = cfg_spar:find(ItemId)
			end,
			?_check(NextItemId > 0, ?ERR_EQUIP_STONE_IS_MAX),
			NeedNum2 = NeedNum - 1,
			Cost = case Type of
				?ITEM_TYPE_STONE -> calc_need_stones(ItemId, NeedNum2, []);
				_                -> calc_need_spars(ItemId, NeedNum2, [])
			end,
			role_bag:cost(Cost, ?LOG_EQUIP_STONE_UPLEVEL, RoleSt),
			Stones2 = maps:put(Hole, NextItemId, Stones),
			AllStones2 = maps:put(Slot, Stones2, AllStones),
			role_data:set(RoleEquip#role_equip{stones=AllStones2}),
			Item2 = role_equip:get_item(Item),
			role_equip:send_item_toc(Item2, RoleSt),
			role_attr:recalc(role_equip, RoleSt),
			role_event:event(?EVENT_STONE_UPGRADE, NextItemId),
			{ok, #m_equip_stone_uplevel_toc{slot=Slot}, RoleSt}
	end;


%获取套装
handle(?EQUIP_GET_SUITE, Tos, RoleSt)->
	#m_equip_get_suite_tos{level=Level} = Tos,
	RoleEquip = #role_equip{suites=Suites} = role_data:get
	(?DB_ROLE_EQUIP),
	Suites2 = active_suites(Suites),
	role_data:set(RoleEquip#role_equip{suites=Suites2}),
	case maps:get(Level, Suites2, ?nil) of
		#suite{active=Active, maked=Maked}->
			{ok, #m_equip_get_suite_toc{level=Level, active=Active, maked_slots=Maked}, RoleSt};
		_->
			{ok, #m_equip_get_suite_toc{level=Level}, RoleSt}
	end;


%套装制作
handle(?EQUIP_SUITE_MAKE, Tos, RoleSt)->
	?_check(role_misc:is_sys_open({equip_handler,3}), ?ERR_GAME_SYS_OPENED),
	#m_equip_suite_make_tos{level=Level, slot=Slot} = Tos,
	RoleEquip = #role_equip{suites=Suites, suite_cost=SuiteCost, equips=Equips} = role_data:get(?DB_ROLE_EQUIP),
	case role_equip:get_item_base(Slot) of
		#p_item{id=ItemId}->
			#cfg_equip{order=Order, star=Star} = cfg_equip:find(ItemId),
			#cfg_item{color=Color} = cfg_item:find(ItemId),
			Suite = maps:get(Level, Suites, #suite{active=#{}, maked=[]}),
			role_equip:check_maked(Suites, Slot, Level),
			check_pre_maked(Suites, Slot, Level),
			{_TypeId, BItems, Items} = check_can_make(Slot, Order, Level, Star, Color, RoleSt),
			{OBItems, OItems} = maps:get(Slot, SuiteCost, {[],[]}),
			BItems2 = lists:merge(BItems, OBItems),
			Items2 = lists:merge(Items, OItems),
			SuiteCost2 = maps:put(Slot, {BItems2, Items2}, SuiteCost),
			#suite{maked=Maked} = Suite,
			Suite2 = Suite#suite{maked=[Slot | Maked]},
			%如果是制作的高级套装，删除低级套装
			Suites2 = case Level == 2 of
				true ->
					LowSuite = #suite{maked=LowMaked} = maps:get(1, Suites),
					LowMaked2 = lists:delete(Slot, LowMaked),
					LowSuite2 = LowSuite#suite{maked=LowMaked2},
					maps:put(1, LowSuite2, Suites);
				false->
					Suites
			end,
			Suites3 = maps:put(Level, Suite2, Suites2),
			Suites4 = active_suites(Suites3),
			%Suite3 = active_suite(Suite2, TypeId, Order, Level),
			%Suites2 = maps:put(Level, Suite3, Suites),
			%Suites3 = clear_suite_maked_level(Suites2, Level, Slot),
			role_data:set(RoleEquip#role_equip{suites=Suites4, suite_cost=SuiteCost2}),
			%?ucast(#m_equip_get_suite_toc{level=Level, active=Active, maked_slots=Maked2}),
			send_all_suites(Suites4, RoleSt),
			role_attr:recalc(role_equip, RoleSt),
			role_event:event(?EVENT_MAKE_SUIT, {Level, Slot, Order}),
			role_event:event(?EVENT_EQUIP, {Slot, ItemId, Equips}),
			{ok, #m_equip_suite_make_toc{}, RoleSt};
    	?nil->
    		throw(?err(?ERR_EQUIP_NOT_PUTON))
	end;

%熔炼
handle(?EQUIP_SMELT, Tos, RoleSt)->
	#m_equip_smelt_tos{uids=UIds} = Tos,
	{_Smelt, Smelt2, Exp} = role_equip:smelt(UIds, RoleSt),
	?ucast(#m_equip_smelt_info_toc{id=Smelt2, exp=Exp}),
	{ok, #m_equip_smelt_toc{}, RoleSt};

%获取熔炼信息
handle(?EQUIP_SMELT_INFO, _Tos, RoleSt)->
	#role_equip{smelt=Smelt, smelt_exp=Exp} = role_data:get(?DB_ROLE_EQUIP),
	{ok, #m_equip_smelt_info_toc{id=Smelt, exp=Exp}, RoleSt};

%铸造
handle(?EQUIP_CAST, Tos, RoleSt)->
	#m_equip_cast_tos{slot=Slot} = Tos,
	RoleEquip = #role_equip{equips=Equips, casts=Casts} = role_data:get(?DB_ROLE_EQUIP),
	EquipCast = maps:get(Slot, Casts, #equip_cast{cast=0, cost={[],[]}}),
	#equip_cast{cast=CastLevel, cost=OldCost} = EquipCast,
	NextCastLevel = CastLevel+1,
	CfgEquipCast = cfg_equip_cast:find(Slot, NextCastLevel),
	?_check(CfgEquipCast /= ?nil, ?ERR_EQUIP_CAST_IS_MAX),
	#cfg_equip_cast{name=Name, cost=Cost, msgno=Msgno} = CfgEquipCast,
	%获取穿戴uid
	UId = maps:get(Slot, Equips, 0),
	?_check(UId > 0, ?ERR_EQUIP_NOT_PUTON),
	{ok, Item} = role_bag:get_item(UId),
	#p_item{equip=Equip, id=ItemId} = Item,
	check_cast(CfgEquipCast, Item),
	%消耗道具，升级，记录消耗物品绑定，非绑
	{BItems, Items} = calc_cells(Cost),
	role_bag:cost(Cost, ?LOG_EQUIP_CAST, RoleSt),
	{OBItems, OItems} = OldCost,
	BItems2 = lists:merge(OBItems, BItems),
	Items2 = lists:merge(OItems, Items),
	EquipCast2 = EquipCast#equip_cast{cast=NextCastLevel, cost={BItems2, Items2}},
	Casts2 = maps:put(Slot, EquipCast2, Casts),
	role_data:set(RoleEquip#role_equip{casts=Casts2}),
	Equip2 = Equip#p_equip{cast=NextCastLevel},
	Item2 = Item#p_item{equip=Equip2},
	role_bag:set_item(Item2),
	role_attr:recalc(role_equip, RoleSt),
	role_equip:send_item_toc(role_equip:get_item(Item2), RoleSt),
	role_event:event(?EVENT_EQUIP_CAST, NextCastLevel),
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	ItemMap = maps:put(ItemId, 0, #{}),
	?_if(Msgno>0, ?notify(Msgno, [{role, RoleID, RoleName}, {item, ItemMap}, Name])),
	{ok, #m_equip_cast_toc{}, RoleSt};

%获取洗练信息
handle(?EQUIP_REFINE_INFO, _Tos, RoleSt)->
	#role_equip{refine=Refine} = role_data:get(?DB_ROLE_EQUIP),
	Slots = maps:values(Refine),
	Count = role_count:get_times(?ROLE_COUNT_EQUIP_REFINE),
	{ok, #m_equip_refine_info_toc{free_count=Count, slots=Slots}, RoleSt};

%解锁部位
handle(?EQUIP_REFINE_UNLOCK, Tos, RoleSt)->
	#m_equip_refine_unlock_tos{slot=Slot} = Tos,
	RoleEquip = #role_equip{refine=Refine} = role_data:get(?DB_ROLE_EQUIP),
	?_check(not maps:is_key(Slot, Refine), ?ERR_EQUIP_REFINE_UNLOCKED),
	#cfg_equip_refine{open=OpenLevel, attr_libs=AttrLibs} = cfg_equip_refine:find(Slot),
	#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
	?_check(Level >= OpenLevel, ?ERR_EQUIP_REFINE_SLOT_LEVEL_WRONG),
	[PRefine] = get_refine_attr(0, AttrLibs, 1, [], []),
	PRefineSlot = #p_refine_slot{
		slot  = Slot,
		holes = #{1 => PRefine}
	},
	Refine2 = maps:put(Slot, PRefineSlot, Refine),
	role_data:set(RoleEquip#role_equip{refine=Refine2}),
	Count = role_count:get_times(?ROLE_COUNT_EQUIP_REFINE),
	?ucast(#m_equip_refine_info_toc{free_count=Count, slots=[PRefineSlot]}),
	role_attr:recalc(role_equip, RoleSt),
	{ok, #m_equip_refine_unlock_toc{}, RoleSt};

%解锁孔位
handle(?EQUIP_REFINE_UNLOCK_HOLE, Tos, RoleSt)->
	#m_equip_refine_unlock_hole_tos{slot=Slot, hole=Hole} = Tos,
	RoleEquip = #role_equip{refine=Refine, equips=Equips} = role_data:get(?DB_ROLE_EQUIP),
	UId = maps:get(Slot, Equips, 0),
	?_check(UId > 0, ?ERR_EQUIP_REFINE_SLOT_NO_EQUIP),
	PRefineSlot = maps:get(Slot, Refine, ?nil),
	?_check(PRefineSlot /= ?nil, ?ERR_EQUIP_REFINE_SLOT_NOT_ACTIVE),
	#p_refine_slot{holes=Holes} = PRefineSlot,
	?_check(not maps:is_key(Hole, Holes), ?ERR_EQUIP_REFINE_HOLE_ACTIVED),
	#cfg_equip_refine_other{unlock=Cost} = cfg_equip_refine_other:find(1),
	{_, Cost2} = lists:keyfind(Hole, 1, Cost),
	%检查消耗
	case Cost2 of
		{vip, NeedVip} ->
			VipLevel = role_vip:get_level(),
			?_check(VipLevel >= NeedVip, ?ERR_EQUIP_REFINE_VIP_NOT_ENOUGH);
		_ ->
			role_bag:cost(Cost2, ?LOG_EQUIP_REFINE_HOLE, RoleSt)
	end,
	Exclude = get_refine_had_attr(Holes),
	#cfg_equip_refine{attr_libs=AttrLibs} = cfg_equip_refine:find(Slot),
	[PRefine] = get_refine_attr(0, AttrLibs, 1, Exclude, []),
	Holes2 = maps:put(Hole, PRefine, Holes),
	PRefineSlot2 = PRefineSlot#p_refine_slot{holes=Holes2},
	Refine2 = maps:put(Slot, PRefineSlot2, Refine),
	role_data:set(RoleEquip#role_equip{refine=Refine2}),
	Count = role_count:get_times(?ROLE_COUNT_EQUIP_REFINE),
	?ucast(#m_equip_refine_info_toc{free_count=Count, slots=[PRefineSlot2]}),
	role_attr:recalc(role_equip, RoleSt),
	{ok, #m_equip_refine_unlock_hole_toc{}, RoleSt};

%洗练
handle(?EQUIP_REFINE, Tos, RoleSt)->
	#m_equip_refine_tos{slot=Slot, itemid=ItemId, locks=Locks} = Tos,
	?_check(length(Locks) < 5, ?ERR_EQUIP_REFINE_LOCK_TOO_MANY),
	RoleEquip = #role_equip{refine=Refine, equips=Equips} = role_data:get(?DB_ROLE_EQUIP),
	UId = maps:get(Slot, Equips, 0),
	?_check(UId > 0, ?ERR_EQUIP_REFINE_SLOT_NO_EQUIP),
	PRefineSlot = maps:get(Slot, Refine, ?nil),
	?_check(PRefineSlot /= ?nil, ?ERR_EQUIP_REFINE_SLOT_NOT_ACTIVE),
	#p_refine_slot{holes=Holes} = PRefineSlot,
	%检查锁定孔位
	Exclude = lists:foldl(fun
			(Hole, Acc) ->
				?_check(maps:is_key(Hole, Holes), ?ERR_EQUIP_REFINE_LOCK_WRONG),
				#p_refine{attr=Attr} = maps:get(Hole, Holes),
				[Attr | Acc]
		end, [], Locks),
	%锁定消耗
	#cfg_equip_refine_other{cost=Cost, lock=LockCost, freecount=FreeCount} = cfg_equip_refine_other:find(1),
	%是否免费洗练
	Count = role_count:get_times(?ROLE_COUNT_EQUIP_REFINE),
	{Cost2, Count2} = case Count < FreeCount of
		true  ->
			role_count:add_times(?ROLE_COUNT_EQUIP_REFINE),
			{[], Count+1};
		false ->
			{Cost, Count}
	end,
	%锁定消耗
	Length = length(Locks),
	Cost4 = case Length > 0 of
		true ->
			{_, Cost3} = lists:keyfind(Length, 1, LockCost),
	 		lists:merge(Cost2, Cost3);
	 	false ->
	 		Cost2
	end,
	Cost5 = case ItemId > 0 of
		true  -> [{ItemId, 1} | Cost4];
		false -> Cost4
	end,
	role_bag:cost(Cost5, ?LOG_EQUIP_REFINE, RoleSt),
	Holes2 = do_refine(ItemId, Slot, Holes, Locks, Exclude),
	PRefineSlot2 = PRefineSlot#p_refine_slot{holes=Holes2, old_holes=Holes},
	Refine2 = maps:put(Slot, PRefineSlot2, Refine),
	role_data:set(RoleEquip#role_equip{refine=Refine2}),
	?ucast(#m_equip_refine_info_toc{slots=[PRefineSlot2], free_count=Count2}),
	role_attr:recalc(role_equip, RoleSt),
	notify_refine(UId, Holes2, Locks, RoleSt),
	role_event:event(?EVENT_EQUIP_REFINE_FINAL, Refine2),
	{ok, #m_equip_refine_toc{}, RoleSt};

%还原
handle(?EQUIP_REFINE_BACK, Tos, RoleSt)->
	#m_equip_refine_back_tos{slot=Slot} = Tos,
	#cfg_equip_refine_other{cost=Cost, freecount=FreeCount} = cfg_equip_refine_other:find(1),
	RoleEquip = #role_equip{refine=Refine, equips=Equips} = role_data:get(?DB_ROLE_EQUIP),
	UId = maps:get(Slot, Equips, 0),
	?_check(UId > 0, ?ERR_EQUIP_REFINE_SLOT_NO_EQUIP),
	PRefineSlot = maps:get(Slot, Refine, ?nil),
	?_check(PRefineSlot /= ?nil, ?ERR_EQUIP_REFINE_SLOT_NOT_ACTIVE),
	#p_refine_slot{old_holes=OldHoles, holes=Holes} = PRefineSlot,
	?_check(maps:size(OldHoles) > 0, ?ERR_EQUIP_REFINE_NO_BACK_ATTR),
	?_check(maps:size(OldHoles) == maps:size(Holes), ?ERR_EQUIP_REFINE_CAN_REFINE_BACK),
	%是否免费
	Count = role_count:get_times(?ROLE_COUNT_EQUIP_REFINE),
	{Cost2, Count2} = case Count < FreeCount of
		true  ->
			role_count:add_times(?ROLE_COUNT_EQUIP_REFINE),
			{[], Count+1};
		false ->
			{Cost, Count}
	end,
	role_bag:cost(Cost2, ?LOG_EQUIP_REFINE_BACK, RoleSt),
	PRefineSlot2 = PRefineSlot#p_refine_slot{holes=OldHoles},
	Refine2 = maps:put(Slot, PRefineSlot2, Refine),
	role_data:set(RoleEquip#role_equip{refine=Refine2}),
	?ucast(#m_equip_refine_info_toc{slots=[PRefineSlot2], free_count=Count2}),
	role_attr:recalc(role_equip, RoleSt),
	{ok, #m_equip_refine_back_toc{}, RoleSt};


%道具，装备合成
handle(?EQUIP_COMBINE, Tos, RoleSt)->
	#m_equip_combine_tos{item_id=CombineId, cost=ClientCost} = Tos,
	#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
	#cfg_equip_combine{
		  gain       = Gain
		, open_level = OpenLevel
		, cost       = Cost
		, other_cost = OtherCost
		, min_num    = MinNum
		, max_num    = MaxNum
		, probs      = Probs
		, compose_key = ComposeKey
	} = cfg_equip_combine:find(CombineId),
	?_check(Level >= OpenLevel, ?ERR_EQUIP_LEVEL_LIMIT),
	[{ItemId, _}|_T] = Gain,
	ItemCfg = cfg_item:find(ItemId),
	{NeedPutOn, PutOn, Slot} = case ItemCfg of
		#cfg_item{stype=SType} ->
			case SType == ?ITEM_STYPE_RING1 orelse SType == ?ITEM_STYPE_RING2 of
				true ->
					PutOff = role_equip:putoff_nocalc(SType, RoleSt),
					{true, PutOff, SType};
				false ->
					{false, false, SType}
			end;
		_ ->
			{false, false, 0}
	end,
	%检查消耗道具
	Length = maps:size(ClientCost),
	?_check(Length >= MinNum andalso Length =< MaxNum, ?ERR_ITEM_NOT_ENOUGH),
	{Cost2, Bind} = check_combine_cost(ClientCost, OtherCost),
	{Cost4, Bind2} = check_is_bind(Cost, NeedPutOn),
	Bind3 = Bind or Bind2,
	Cost3 = lists:merge(Cost4, Cost2),
	% 构造合成
	Gain2 = build_combine_gain(Gain, Cost2, Bind3),
	%扣道具
	{ok, Expend} = role_bag:cost(Cost3, ?LOG_EQUIP_COMBINE_COST, ?nil, RoleSt, true),
	%计算概率
	RealProb = lists:foldl(fun
			({Num, Prob}, Sum) ->
				case Length >= Num of
					true-> Prob;
					false-> Sum
				end
		end, 0, Probs),
	{Succ, ComposeCount} = role_equip:is_compose_succ(ComposeKey),
	Index = ut_rand:random(1, 100),
	case RealProb >= Index orelse Succ of
		true->
			{ok, [Obtain]} = role_bag:gain(
				Gain2, ?LOG_EQUIP_COMBINE_ADD, ?nil, RoleSt, true
			),
			EquipInfo = Obtain#p_item.equip,
			case ItemCfg#cfg_item.type == ?ITEM_TYPE_EQUIP of
				true  ->
					#cfg_equip{order=Order} = cfg_equip:find(ItemId),
					case ItemCfg#cfg_item.color == ?COLOR_PINK andalso Order >= 9 of
						true  ->
							role_bag:set_item(Obtain#p_item{equip=EquipInfo#p_equip{combine=Expend}});
						false ->
							ignore
					end;
				false ->
					ignore
			end,
			role_event:event(?EVENT_COMPOSE, Obtain#p_item.id),
			?_if(PutOn, role_equip:puton_nocalc(Slot, Obtain#p_item.uid, RoleSt)),
			notify_combine(Gain),
			role_equip:update_compose_count(ComposeKey, 0),
			role_attr:recalc(role_equip, RoleSt),
			case ItemCfg#cfg_item.type == ?ITEM_TYPE_PET_EQUIP of
				true  ->
					CacheID = item_cache:add_cache(Obtain),
					#role_st{role=RoleID, name=RoleName} = RoleSt,
					#cfg_pet_equip{star=Star} = cfg_pet_equip:find(ItemId, 1),
					?notify(
						?MSG_PET_EQUIP_COMPOSE,
						[{role,RoleID,RoleName}, Star, {pitem,#{CacheID=>ItemId}}]
					);
				false ->
					ignore
			end,
			{ok, #m_equip_combine_toc{result=0}, RoleSt};
		false->
			role_equip:update_compose_count(ComposeKey, ComposeCount+1),
			{ok, #m_equip_combine_toc{result=1}, RoleSt}
	end;

handle(?EQUIP_DECOMBINE, Tos, RoleSt) ->
	#m_equip_decombine_tos{item_uid=CellID} = Tos,
	{ok, Item} = role_bag:get_item(CellID),
	#p_item{id=ItemID, equip=EquipInfo} = Item,
	?_check(EquipInfo /= ?nil, ?ERR_EQUIP_CANNOT_DECOMBINE),
	#cfg_item{color=Color} = cfg_item:find(ItemID),
	?_check(Color == ?COLOR_PINK, ?ERR_EQUIP_CANNOT_DECOMBINE),
	#cfg_equip{order=Order} = cfg_equip:find(ItemID),
	?_check(Order >= 9, ?ERR_EQUIP_CANNOT_DECOMBINE),
	Gain = calc_decombine_refund(ItemID, EquipInfo),
	{ok, _, Obtain} = role_bag:deal([{cellid,CellID}], Gain, ?LOG_EQUIP_DECOMBINE, RoleSt),
	?ucast(#m_equip_decombine_toc{item_uid=CellID, refund=Obtain}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_puton(Item) ->
	#cfg_item{type=Type, level=Level} = cfg_item:find(Item#p_item.id),
	?_check(Type == ?ITEM_TYPE_EQUIP, ?ERR_EQUIP_NOT_EQUIP),
	RoleInfo = role_data:get(?DB_ROLE_INFO),
	#role_info{career=MyCareer, level=MyLevel, wake=MyWake} = RoleInfo,
	?_check(MyLevel >= Level, ?ERR_EQUIP_LEVEL_LIMIT),
	#cfg_equip{career=Careers, wake=Wake} = cfg_equip:find(Item#p_item.id),
	?_check(lists:member(MyCareer, Careers), ?ERR_EQUIP_CAREER_LIMIT),
	?_check(MyWake >= Wake, ?ERR_EQUIP_WAKE_NOT_ENOUGH),
	#p_item{etime=Etime} = Item,
	?_check(Etime > ut_time:seconds() orelse Etime == 0, ?ERR_EQUIP_IS_EXPIRE),
	ok.


check_strength(Item, Slot, Phase, Level)->
	Id = cfg_equip_strength:find_id({Slot, Phase, Level}),
	?_check(Id =/= undefined, ?ERR_EQUIP_NO_EQUIP_STRENGTH),
	#cfg_equip_strength{next_id=NextId} = cfg_equip_strength:find(Id),
	?_check(NextId > 0, ?ERR_EQUIP_REACH_MAX_LEVEL),
	#p_item{id=ItemId} = Item,
	#cfg_equip{order=Order} = cfg_equip:find(ItemId),
	#cfg_item{color=Color} = cfg_item:find(ItemId),
	LimitId = cfg_equip_strength_limit:find_id({Slot, Order, Color}),
	?_check(LimitId =/= undefined, ?ERR_EQUIP_NO_EQUIP_STRENGTH_LIMIT),
	#cfg_equip_strength{phase=NextPhase} = cfg_equip_strength:find(NextId),
	#cfg_equip_strength_limit{max_phase=MaxPhase} = cfg_equip_strength_limit:find(LimitId),
	?_check(NextPhase < MaxPhase, ?ERR_EQUIP_REACH_MAX_LEVEL),
	ok.

%继承宝石
cal_stones(Slot, ItemId, AllStones, RoleSt)->
	#cfg_equip{order=Order} = cfg_equip:find(ItemId),
	Stones = maps:get(Slot, AllStones, #{}),
	case maps:size(Stones) > 0 of
		true->
			Stones2 = maps:fold(fun
					(Hole, StoneId, NewStrones) ->
						case Hole >= 1 andalso Hole =< 6 of
							true ->
								#cfg_stones_hole{open_condition=OpenCondition} = cfg_stones_hole:find(Hole);
							_   ->
								#cfg_spar_unlock{open_condition=OpenCondition} = cfg_spar_unlock:find(Hole)
						end,
						case OpenCondition of
							{order, NeedOrder}->
								?_if(Order>=NeedOrder, maps:put(Hole, StoneId, NewStrones), NewStrones);
							{vip, _NeedVip} ->
								maps:put(Hole, StoneId, NewStrones)
						end
				end, #{}, Stones),
			%去除继承的宝石
			Keys = maps:keys(Stones2),
			Stones3 = maps:without(Keys, Stones),
			case maps:size(Stones3) >= 0 of
				true->
			        ItemIds = maps:values(Stones3),
			        Gain = [ {StoneId, 1} || StoneId<-ItemIds],
			        role_bag:gain(Gain, ?LOG_EQUIP_STONE_TAKEDOWN, RoleSt);
			    false->
			    	igonre
		    end,
			maps:put(Slot, Stones2, AllStones);
		false->
			AllStones
	end.

calc_need_stones(ItemId, NeedNum, Cost)->
	HadNum = role_bag:get_num(ItemId),
	case HadNum >= NeedNum of
		true  ->
			[{ItemId, NeedNum} | Cost];
		false ->
			#cfg_stone{pre_level_id=PreItemId} = cfg_stone:find(ItemId),
			case PreItemId > 0 of
				true ->
					#cfg_stone{need_num=Need} = cfg_stone:find(PreItemId),
					Cost2 = [{ItemId, HadNum} | Cost],
					calc_need_stones(PreItemId, (NeedNum-HadNum)*Need, Cost2);
				false ->
					[{ItemId, NeedNum} | Cost]
			end
	end.

calc_need_spars(ItemId, NeedNum, Cost)->
	HadNum = role_bag:get_num(ItemId),
	case HadNum >= NeedNum of
		true  ->
			[{ItemId, NeedNum} | Cost];
		false ->
			#cfg_spar{pre_level_id=PreItemId} = cfg_spar:find(ItemId),
			case PreItemId > 0 of
				true ->
					#cfg_spar{need_num=Need} = cfg_spar:find(PreItemId),
					Cost2 = [{ItemId, HadNum} | Cost],
					calc_need_spars(PreItemId, (NeedNum-HadNum)*Need, Cost2);
				false ->
					[{ItemId, NeedNum} | Cost]
			end
	end.

%提示继承强化
notify_strength(Slot, ItemId, RoleSt)->
	#cfg_equip{order=Order} = cfg_equip:find(ItemId),
	#cfg_item{color=Color} = cfg_item:find(ItemId),
	LimitId = cfg_equip_strength_limit:find_id({Slot, Order, Color}),
	%继承强化等级
	case cfg_equip_strength_limit:find(LimitId) of
		#cfg_equip_strength_limit{max_phase=MaxPhase}->
			#equip_strength{phase=Phase, level=Level} = role_equip:get_equip_strength(Slot),
			case MaxPhase > Phase of
				true->
					case Phase > 1 orelse Level > 0 of
						true->
							?notify(RoleSt#role_st.role, ?MSG_EQUIP_INHERIT_STRONG, []);
						false->igonre
					end;
				false->
					igonre
			end;
		_->
			igonre
	end.


%计算强化套装
calc_strength_suite(_RoleSt)->
	RoleEquip = role_data:get(?DB_ROLE_EQUIP),
	Ids = cfg_equip_strength_suite:suite_ids(),
	SuiteId = get_suite_id(lists:sort(Ids), 0),
	case SuiteId > 0 of
		true->
			RoleEquip2 = RoleEquip#role_equip{strength_suite_id=SuiteId},
			role_data:set(RoleEquip2);
			%?ucast(#m_equip_getstrengthsuite_toc{id=SuiteId});
		_->
			igonre
	end.


get_suite_id([], ResultId)->
	ResultId;
get_suite_id([Id|Ids], ResultId)->
	#cfg_equip_strength_suite{phase=Phase, level=Level, slots=Slots, num=Num} = cfg_equip_strength_suite:find(Id),
	case check_slot(Slots, Phase, Level, 0) >= Num of
		true->
			ResultId2 = Id,
			get_suite_id(Ids, ResultId2);
		false->
			ResultId
	end.

%检查部位
check_slot([], _Tphase, _TLevel, Num) ->
	Num;
check_slot([Slot|Slots], TPhase, TLevel, Num) ->
	#equip_strength{phase=Phase, level=Level} = role_equip:get_equip_strength(Slot),
	case Phase > TPhase orelse (Phase==TPhase andalso Level>=TLevel) of
		true-> check_slot(Slots, TPhase, TLevel, Num+1);
		false-> check_slot(Slots, TPhase, TLevel, Num)
	end.

%检查孔位是否解锁
check_hole(Hole, Order, Vip) when Hole =< 6 ->
	#cfg_stones_hole{open_condition=OpenCondition} = cfg_stones_hole:find(Hole),
	case OpenCondition of
		{order, NeedOrder}->
			?_check(Order>=NeedOrder, ?ERR_EQUIP_STONE_HOLE_NOT_OPEN);
		{vip, NeedVip} ->
			?_check(Vip>=NeedVip, ?ERR_EQUIP_STONE_HOLE_NOT_OPEN)
	end;
check_hole(Hole, Order, Vip) ->
	#cfg_spar_unlock{open_condition=OpenCondition} = cfg_spar_unlock:find(Hole),
	case OpenCondition of
		{order, NeedOrder}->
			?_check(Order>=NeedOrder, ?ERR_EQUIP_STONE_HOLE_NOT_OPEN);
		{vip, NeedVip} ->
			?_check(Vip>=NeedVip, ?ERR_EQUIP_STONE_HOLE_NOT_OPEN)
	end.


%提示套装转移
notify_suite(Suites, Slot, RoleSt)->
	Num = maps:fold(fun
			(_K, #suite{maked=Maked}, Sum) ->
				case lists:member(Slot, Maked) of
					true-> Sum + 1;
					false-> Sum + 0
				end
		end, 0, Suites),
    case Num > 0 of
		true->?notify(RoleSt#role_st.role, ?MSG_EQUIP_INHERIT_SUITE, []);
		false->ignor
	end.

%检查初阶套装是否有制作
check_pre_maked(Suites, Slot, Level) ->
	case Level > 1 of
		true->
			 Suite = maps:get(Level-1, Suites, ?nil),
			 ?_check(Suite /= ?nil, ?ERR_EQUIP_SLOT_PRE_IS_NOT_MAKED),
			 #suite{maked=Maked} = Suite,
			 ?_check(lists:member(Slot, Maked), ?ERR_EQUIP_SLOT_PRE_IS_NOT_MAKED);
		false->
			ignor
	end.

%检查是否可以制作
check_can_make(Slot, Order, Level, Star, Color, RoleSt)->
	#role_info{career=Career} = role_data:get(?DB_ROLE_INFO),
	%检查星，颜色
	#cfg_equip_suite_level{color=NeedColor, star=NeedStar} = cfg_equip_suite_level:find(Level),
	?_check(Star >= NeedStar andalso Color >= NeedColor, ?ERR_EQUIP_CANNOT_MAKE_SUITE),
	%检查阶位
	Id = cfg_equip_suite_make:find_id({Slot, Order, Level}),
	?_check(Id =/= undefined, ?ERR_EQUIP_CANNOT_MAKE_SUITE),
	#cfg_equip_suite_make{type_id=TypeId, cost=Cost} = cfg_equip_suite_make:find(Id),
	Cost2 = lists:nth(Career, Cost),
	SuiteId = case TypeId == 1 of
		true  -> cfg_equip_suite:find_id({TypeId, Order, Level});
		false -> cfg_equip_suite:find_id({TypeId, 0, Level})
	end,
	?_check(SuiteId =/= undefined, ?ERR_EQUIP_CANNOT_MAKE_SUITE),
	%扣材料
	{BItems, Items} = calc_cells(Cost2),
	role_bag:cost(Cost2, ?LOG_EQUIP_SUITE_MAKE, RoleSt),
	{TypeId, BItems, Items}.

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
						Items = role_bag:get_items(ItemID, false),
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

%获取返还套装制作材料
get_suite_materia(SuiteCost, Slot, OldId, Id)->
	#cfg_item{color=Color} = cfg_item:find(Id),
	#cfg_item{color=OldColor} = cfg_item:find(OldId),
	#cfg_equip{star=Star, order=Order} = cfg_equip:find(Id),
	#cfg_equip{order=OldOrder, star=OldStar} = cfg_equip:find(OldId),
	case Order==OldOrder andalso Color == OldColor andalso Star == OldStar of
		true->
			[];
		false->
			get_suite_materia2(SuiteCost, Slot)
	end.

get_suite_materia2(SuiteCost, Slot) ->
	{BItems, Items} = maps:get(Slot, SuiteCost, {[], []}),
	BItems2 = [ {ItemId, Num, 1} || {ItemId, Num} <- BItems],
	Items2 = [ {ItemId, Num, 2} || {ItemId, Num} <- Items],
	lists:merge(BItems2, Items2).

% get_suite_materia_level(Slot, Maked, Level, Order, Lists)->
% 	case lists:member(Slot, Maked) of
% 		true->
% 			 Id = cfg_equip_suite_make:find_id({Slot, Order, Level}),
% 			 #cfg_equip_suite_make{cost=Cost} = cfg_equip_suite_make:find(Id),
% 			 #role_info{career=Career} = role_data:get(?DB_ROLE_INFO),
% 			 Cost2 = lists:nth(Career, Cost),
% 			 Cost3 = [ {ItemId, Num, 2} || {ItemId, Num} <- Cost2 ],
% 			 lists:append(Lists, Cost3);
% 		false->
% 			Lists
% 	end.

%清除套装制作
clear_suite_maked(Suites, Slot) ->
	Suites2 = maps:fold(fun
			(K, #suite{maked=Maked} = Suite, Maps) ->
				case lists:member(Slot, Maked) of
					true->
						Maked2 = lists:delete(Slot, Maked),
						Suite2 = Suite#suite{maked=Maked2},
						maps:put(K, Suite2, Maps);
					false->
						maps:put(K, Suite, Maps)
				end
			end, #{}, Suites),
	active_suites(Suites2).

% clear_suite_maked2(Suite, Slot)->
% 	#suite{maked=Maked} = Suite,
% 	case lists:member(Slot, Maked) of
% 		true->
% 			Maked2 = lists:delete(Slot, Maked),
% 			Suite#suite{maked=Maked2};
% 		false->
% 			Suite
% 	end.

% clear_suite_maked_level(Suites, Level, Slot)->
% 	Suites2 = maps:fold(fun
% 			(K, Suite, Maps) ->
% 				case K < Level of
% 					true->
% 						Suite2 = clear_suite_maked2(Suite, Slot),
% 						maps:put(K, Suite2, Maps);
% 					false->
% 						maps:put(K, Suite, Maps)
% 				end
% 		end, #{}, Suites),
% 	active_suites(Suites2).

%检查宝石类型
check_stone(ItemId, Slot)->
	#cfg_item{type=Type} = cfg_item:find(ItemId),
	case Type of
		?ITEM_TYPE_STONE ->
			#cfg_stone{slots=Slots} = cfg_stone:find(ItemId),
			?_check(lists:member(Slot, Slots), ?ERR_EQUIP_STONE_CANNOT_FILLIN_SLOT);
		_->
			#cfg_spar{slots=Slots} = cfg_spar:find(ItemId),
			?_check(lists:member(Slot, Slots), ?ERR_EQUIP_STONE_CANNOT_FILLIN_SLOT)
	end.


check_combine_cost(ClientCost, OtherCost)->
	maps:fold(fun
			(K, V, {List, Bind}) ->
				{ok, #p_item{id=Id,bind=Bind0}} = role_bag:get_item(K),
				?_check(lists:member(Id, OtherCost), ?ERR_EQUIP_COMBINE_COST_WRONG),
				{[{cellid, K, V} | List], Bind or Bind0 }
		end, {[], false}, ClientCost).

%是否绑定
check_is_bind(Cost, NeedPutOn)->
	lists:foldl(fun
			({ItemID, Num}, {Acc, Bind}) ->
				#cfg_item{stype=Slot} = cfg_item:find(ItemID),
				{PutOnItems, TBind} = case NeedPutOn of
					true ->
						case role_equip:get_item_base(Slot) of
							?nil -> {[], false};
							Item -> {[Item], Item#p_item.bind}
						end;
					false ->
						{[], false}
				end,
				{TCost, Left3} = get_cells(PutOnItems, Num, []),
				{Cost5, Bind4} = case Left3 > 0 of
					true ->
						Items = role_bag:get_items(ItemID, false),
						{Cost2, Left} = get_cells(Items, Left3, []),
						{Cost4, Bind2} = case Left > 0 of
							true ->
								Items2 = role_bag:get_items(ItemID, true),
								{Cost3, Left2} = get_cells(Items2, Left, []),
								?_check(Left2==0, ?ERR_ITEM_NOT_ENOUGH),
								{lists:merge(Cost2, Cost3), true};
							false ->
								{Cost2, false}
						end,
						{lists:merge(TCost, Cost4), TBind or Bind2};
					false ->
						{TCost, TBind}
				end,
				{lists:merge(Acc, Cost5), Bind or Bind4}
		end, {[], false}, Cost).


get_cells([], Num, Cost)->
	{Cost, Num};
get_cells([#p_item{uid=UId, num=Had}|Items], Num, Cost)->
	case Had >= Num of
		true  ->
			{[{cellid, UId, Num}|Cost], 0};
		false ->
			Cost2 = [{cellid, UId}|Cost],
			get_cells(Items, Num-Had, Cost2)
	end.


%计算升级需要宝石，元宝
% calc_stones(ItemId, 0, Cost)->
% 	{ItemId, Cost};
% calc_stones(ItemId, UpLevel, TotalCost)->
% 	#cfg_stone{next_level_id=NextItemId, need_num=NeedNum, pre_level_id=PreItemId} = cfg_stone:find(ItemId),
% 	NeedNum2 = NeedNum - 1,
% 	TotalNum = role_bag:get_num(ItemId),
% 	{_, GoldId, Price} = cfg_voucher:find(ItemId),
% 	{Cost, NeedGold2} = case TotalNum < NeedNum2 of
% 		true ->
% 			RealNum = NeedNum2 - TotalNum,
% 			NeedGold = Price * RealNum,
% 			calc_stones2(PreItemId, RealNum*3, [{ItemId, TotalNum}], NeedGold);
% 		false ->
% 			{[{ItemId, NeedNum2}], 0}
% 	end,
% 	TotalCost2 = TotalCost ++ Cost ++ [{GoldId, NeedGold2}],
% 	calc_stones(NextItemId, UpLevel-1, TotalCost2).

%计算需要宝石
% calc_stones2(0, _NeedNum, List, NeedGold)->
% 	{List, NeedGold};
% calc_stones2(ItemId, NeedNum, List, NeedGold)->
% 	#cfg_stone{pre_level_id=PreItemId} = cfg_stone:find(ItemId),
% 	{_, _, Price} = cfg_voucher:find(ItemId),
% 	TotalNum = role_bag:get_num(ItemId),
% 	case TotalNum < NeedNum of
% 		true ->
% 			RealNum = (NeedNum-TotalNum),
% 			List2 = List ++ [{ItemId, TotalNum}],
% 			NeedGold2 = NeedGold - TotalNum * Price,
% 			calc_stones2(PreItemId, RealNum*3, List2, NeedGold2);
% 		false ->
% 			{List ++ [{ItemId, NeedNum}], 0}
% 	end.

%重算激活套装
active_suites(Suites)->
	maps:fold(fun
			(Level, #suite{maked=Maked, active=OldActive}=Suite, Maps) ->
				Active = gen_active(Level, Maked),
				maps:fold(fun
						(SuiteId, Num, Acc) ->
							OldNum = maps:get(SuiteId, OldActive, 0),
							?_if(Num > OldNum, notify_suite_active(Level, SuiteId, Num)),
							Acc+0
					end, 0, Active),
				Suite2 = Suite#suite{active=Active},
				maps:put(Level, Suite2, Maps)
		end, #{}, Suites).

%计算套装激活数
gen_active(Level, Maked)->
	lists:foldl(fun
		(Slot, Maps) ->
			case role_equip:get_item_base(Slot) of
				#p_item{id=Id}->
					#cfg_equip{order=Order} = cfg_equip:find(Id),
					MakeId = cfg_equip_suite_make:find_id({Slot, Order, Level}),
					#cfg_equip_suite_make{type_id=TypeId} = cfg_equip_suite_make:find(MakeId),
					SuiteId =case TypeId == 1 of
						true  -> cfg_equip_suite:find_id({TypeId, Order, Level});
						false -> cfg_equip_suite:find_id({TypeId, 0, Level})
					end,
					Num = maps:get(SuiteId, Maps, 0),
					Num2 = Num + 1,
					maps:put(SuiteId, Num2, Maps);
				?nil->
					Maps
			end
	end, #{}, Maked).

%激活套装
% active_suite(Suite, TypeId, Order, Level)->
% 	#suite{active=Active}=Suite,
% 	SuiteId = cfg_equip_suite:find_id({TypeId, Order, Level}),
% 	ActiveNum = maps:get(SuiteId, Active, 0),
% 	Active2 = maps:put(SuiteId, ActiveNum+1, Active),
% 	notify_suite_active(Level, SuiteId, ActiveNum+1),
% 	Suite#suite{active=Active2}.

%清除铸造
clear_cast(Slot, Casts)->
	EquipCast = maps:get(Slot, Casts, ?nil),
	EquipCast2 = EquipCast#equip_cast{cast=0, cost={[], []}},
	maps:put(Slot, EquipCast2, Casts).

clear_item(Item)->
	#p_item{equip=Equip} = Item,
	Equip2 = Equip#p_equip{
		cast        = 0,
		stren_phase = 0,
		stren_lv    = 1,
		stones      = #{},
		refine      = [],
		suite       = #{}
	},
	Item2 = Item#p_item{equip=Equip2},
	role_bag:set_item(Item2).


%铸造是否返还
get_cast_materia(Casts, OldItemId, ItemId)->
	#cfg_item{color=Color1} = cfg_item:find(OldItemId),
	#cfg_equip{slot=Slot, order=Order1, star=Star1} = cfg_equip:find(OldItemId),
	OldMaxLevel = cfg_equip_cast_limit:max_level(Order1, Color1, Star1),
	#cfg_item{color=Color2} = cfg_item:find(ItemId),
	#cfg_equip{order=Order2, star=Star2} = cfg_equip:find(ItemId),
	MaxLevel = cfg_equip_cast_limit:max_level(Order2, Color2, Star2),
	case OldMaxLevel /= MaxLevel of
		true ->
			calc_cast_gain(Casts, Slot);
		false ->
			[]
	end.

%计算铸造返还材料
calc_cast_gain(Casts, Slot)->
	EquipCast = maps:get(Slot, Casts, ?nil),
	case EquipCast of
		?nil ->
			[];
		#equip_cast{cost=Cost} ->
			{BItems, Items} = Cost,
			BItems2 = [{ItemId, Num, 1} || {ItemId, Num} <- BItems],
			Items2 = [{ItemId, Num, 2} || {ItemId, Num} <- Items],
			lists:merge(BItems2, Items2)
	end.

%获取洗练已有属性
get_refine_had_attr(Holes)->
	maps:fold(fun
			(_K, PRefine, Acc) ->
				#p_refine{attr=Attr} = PRefine,
				[Attr | Acc]
		end, [], Holes).

%获取洗练属性
%Exclude:排除的属性id列表
get_refine_attr(_ItemId, _AttrLibs, 0, _Exclude, Result)->
	Result;
get_refine_attr(ItemId, AttrLibs, Num, Exclude, Result) ->
	{_, LibId} = lists:keyfind(ItemId, 1, AttrLibs),
	#cfg_equip_refine_attr{attr_type=AttrList, attr=AttrLibList} = cfg_equip_refine_attr:find(LibId),
	AttrList2 = lists:filter(fun
			({AttrId, _}) ->
				not lists:member(AttrId, Exclude)
		end, AttrList),
	Attr = ut_rand:weight(AttrList2),
	{_, List} = lists:keyfind(Attr, 1, AttrLibList),
	{Min, Max, Color} = ut_rand:weight(List, 3),
	AttrValue = ut_rand:random(Min, Max),
	PRefine = #p_refine{
		attr  = Attr,
		value = AttrValue,
		min   = Min,
		max   = Max,
		color = Color
	},
	Result2 = [PRefine | Result],
	Exclude2 = [Attr | Exclude],
	get_refine_attr(0, AttrLibs, Num-1, Exclude2, Result2).

%获取洗练属性
get_refine_attr2(ItemId, AttrLibs, Attr)->
	{_, LibId} = lists:keyfind(ItemId, 1, AttrLibs),
	#cfg_equip_refine_attr{attr=AttrLibList} = cfg_equip_refine_attr:find(LibId),
	{_, List} = lists:keyfind(Attr, 1, AttrLibList),
	{Min, Max, Color} = ut_rand:weight(List, 3),
	AttrValue = ut_rand:random(Min, Max),
	#p_refine{
		attr  = Attr,
		value = AttrValue,
		min   = Min,
		max   = Max,
		color = Color
	}.


send_all_suites(Suites, RoleSt)->
	maps:fold(fun
			(Level, #suite{active=Active, maked=Maked}, Sum) ->
				?ucast(#m_equip_get_suite_toc{level=Level, active=Active, maked_slots=Maked}),
				Sum+1
		end, 0, Suites).

build_combine_gain([{ItemID, 1}] = Gain, Cost, Bind) ->
	case cfg_beast_equip:find(ItemID) of
		undefined ->
			build_combine_gain2(Gain, Bind);
		_ ->
			beast_handler:combine(ItemID, Cost, Bind)
	end;
build_combine_gain(Gain, _Cost, Bind) ->
	build_combine_gain2(Gain, Bind).

build_combine_gain2(Gain, Bind)->
	lists:foldl(fun
			({ItemId, Num}, List) ->
				[{ItemId, Num, #{bind=>Bind}} | List]
		end, [], Gain).

%检查铸造条件
check_cast(CfgEquipCast, Item)->
	#cfg_equip_cast{order=NeedOrder, color=NeedColor, star=NeedStar} = CfgEquipCast,
	#p_item{id=ItemId} = Item,
	#cfg_item{color=Color} = cfg_item:find(ItemId),
	#cfg_equip{order=Order, star=Star} = cfg_equip:find(ItemId),
	?_check(Order>=NeedOrder andalso Color>=NeedColor andalso Star>=NeedStar, ?ERR_EQUIP_CAST_CANNOT_CAST).

%洗练
%洗红满
do_refine(13121, _Slot, Holes, Locks, _Exclude) ->
	%过滤锁定的
	Holes2 = maps:without(Locks, Holes),
	?_check(maps:size(Holes2) == 1, ?ERR_EQUIP_REFINE_RED_FULL_WRONG),
	{K, PRefine2} = maps:fold(fun
			(K, #p_refine{color=Color, max=Max} = PRefine, {_Acc, _Acc1})->
				?_check(Color == ?COLOR_RED, ?ERR_EQUIP_REFINE_RED_FULL_WRONG),
				{K, PRefine#p_refine{value=Max}}
		end, {0, #{}}, Holes2),
	maps:put(K, PRefine2, Holes);
%洗粉色
do_refine(13122, Slot, Holes, Locks, _Exclude) ->
	Holes2 = maps:without(Locks, Holes),
	?_check(maps:size(Holes2) == 1, ?ERR_EQUIP_REFINE_PINK_WRONG),
	[Hole] = maps:keys(Holes2),
	#p_refine{color=Color, attr=Attr, value=Value, max=Max} = maps:get(Hole, Holes2),
	?_check(Value == Max, ?ERR_EQUIP_REFINE_PINK_WRONG),
	?_check(Color == ?COLOR_RED, ?ERR_EQUIP_REFINE_PINK_WRONG),
	#cfg_equip_refine{attr_libs=AttrLibs} = cfg_equip_refine:find(Slot),
	PRefine = get_refine_attr2(13122, AttrLibs, Attr),
	maps:put(Hole, PRefine, Holes);
%其他情况
do_refine(ItemId, Slot, Holes, Locks, Exclude)->
	#cfg_equip_refine{attr_libs=AttrLibs} = cfg_equip_refine:find(Slot),
	Num = maps:size(Holes) - length(Locks),
	PRefineList = get_refine_attr(ItemId, AttrLibs, Num, Exclude, []),
	{_, TmpHoles} = maps:fold(fun
		(K, PRefine, {List, Map}) ->
			case lists:member(K, Locks) of
				true  ->
					{List, maps:put(K, PRefine, Map)};
				false ->
					Index = ut_rand:random(1, length(List)),
					PRefine2 = lists:nth(Index, List),
					{lists:delete(PRefine2, List), maps:put(K, PRefine2, Map)}
				end
			end, {PRefineList, #{}}, Holes),
	TmpHoles.

%是否已达最大强化等级
is_max_strength(Item, Slot, Phase, Level)->
	Id = cfg_equip_strength:find_id({Slot, Phase, Level}),
	case Id == ?nil of
		true ->
			true;
		false ->
			#cfg_equip_strength{next_id=NextId} = cfg_equip_strength:find(Id),
			case NextId == 0 of
				true ->
					true;
				false ->
					#p_item{id=ItemId} = Item,
					#cfg_equip{order=Order} = cfg_equip:find(ItemId),
					#cfg_item{color=Color} = cfg_item:find(ItemId),
					LimitId = cfg_equip_strength_limit:find_id({Slot, Order, Color}),
					case LimitId == ?nil of
						true ->
							true;
						false ->
							#cfg_equip_strength{phase=NextPhase} = cfg_equip_strength:find(NextId),
							#cfg_equip_strength_limit{max_phase=MaxPhase} = cfg_equip_strength_limit:find(LimitId),
							NextPhase >= MaxPhase
					end
			end
	end.

%强化
strength(Slot, Item, Strengths, TotalCost)->
	EquipStrength = #equip_strength{phase=Phase, level=Level, bless_value=BlessValue}
	= case maps:find(Slot, Strengths) of
		{ok, E} -> E;
		error -> #equip_strength{phase=1,level=0,bless_value=0}
	end,
	StrengthId = cfg_equip_strength:find_id({Slot, Phase, Level}),
	#cfg_equip_strength{
		  cost            = Cost
		, next_id         = NextId
		, prob            = Prob
		, bless_value     = AddBlessValue
		, max_bless_value = MaxBlessValue
	}= cfg_equip_strength:find(StrengthId),
	[{_, NeedCoin}|_T] = Cost,
	{ItemID, TotalCoin} = TotalCost,
	TotalCost2 = {ItemID, TotalCoin+NeedCoin},
	%role_bag:cost(Cost, ?LOG_EQUIP_STRENGTH, RoleSt),
	%是否强化成功
	Index = ut_rand:random(1, 100),
	case Index =< Prob orelse BlessValue + AddBlessValue >= MaxBlessValue of
		true->
			%强化成功
			#cfg_equip_strength{phase=NextPhase, level=NextLevel} = cfg_equip_strength:find(NextId),
			EquipStrength2 = EquipStrength#equip_strength{phase=NextPhase, level=NextLevel, bless_value=0},
			Strengths2 = maps:put(Slot, EquipStrength2, Strengths),
			role_event:event(?EVENT_EQUIP_STRENGTH, {Item#p_item.id, NextPhase, NextLevel}),
			notify_strong(Item#p_item.id, NextPhase, NextLevel),
			{0, EquipStrength2, Strengths2, TotalCost2};
		false->
			%强化失败，增加祝福值
			EquipStrength2 = EquipStrength#equip_strength{bless_value=BlessValue+AddBlessValue},
			Strengths2 = maps:put(Slot, EquipStrength2, Strengths),
			role_event:event(?EVENT_EQUIP_STRENGTH, {0, Phase, Level}),
			{1, EquipStrength2, Strengths2, TotalCost2}
	end.

%获取最小可强化装备
get_can_strength_equip(Equips, Strengths)->
	Lists = maps:fold(fun
			(Slot, CellId, Acc) ->
				case CellId > 0 of
					true ->
						{ok, Item} = role_bag:get_item(CellId),
						#equip_strength{phase=Phase, level=Level} = case maps:find(Slot, Strengths) of
					        {ok, E} -> E;
					        error -> #equip_strength{phase=1,level=0,bless_value=0}
					    end,
						case is_max_strength(Item, Slot, Phase, Level) of
							false ->
								[{Slot, Phase*10 + Level, Item}|Acc];
							true ->
								Acc
						end;
					false->
						Acc
				end
		end, [], Equips),
	case length(Lists) > 0 of
		true ->
			Lists2 = lists:keysort(2, Lists),
			{Slot2, _, Item2} = lists:nth(1, Lists2),
			{Slot2, Item2};
		false ->
			{0, ?nil}
	end.

strength2(Slot, Item, Strengths, Coin, TotalCost)->
	{Result, _, Strengths2, TotalCost2} = strength(Slot, Item, Strengths, TotalCost),
	{_, NeedCoin2} = TotalCost2,
	case Coin - NeedCoin2 >= 0 of
		true ->
			case Result of
				0 ->
					{true, Strengths2, TotalCost2};
				1 ->
					strength2(Slot, Item, Strengths2, Coin, TotalCost2)
			end;
		false ->
			{false, Strengths, TotalCost}
	end.

%一键强化
strength_all(Equips, Strengths, Coin, TotalCost)->
	{Slot, Item} = get_can_strength_equip(Equips, Strengths),
	case Slot > 0 of
		true ->
			{GoOn, Strengths2, TotalCost2} = strength2(Slot, Item, Strengths, Coin, TotalCost),
			case GoOn of
				true ->
					{_, NeedCoin2} = TotalCost2,
					case Coin - NeedCoin2 >= 0 of
						true  ->
							strength_all(Equips, Strengths2, Coin, TotalCost2);
						false ->
							{Strengths2, TotalCost2}
					end;
				false ->
					{Strengths2, TotalCost2}
			end;
		false ->
			{Strengths, TotalCost}
	end.

%合成公告
notify_combine(Gain)->
	#role_info{id=RoleID, name=RoleName} = role_data:get(?DB_ROLE_INFO),
	[{ItemId, _Num}|_T] = Gain,
	#cfg_item{name=ItemName, color=Color, type=Type, notify=Notify} = cfg_item:find(ItemId),
	?_if(
		Type == ?ITEM_TYPE_EQUIP orelse Type == ?ITEM_TYPE_EQUIP_BEAST orelse Notify,
		?notify(?MSG_EQUIP_COMPOSE_NOTICE, [
			{role, RoleID, RoleName},
			{color, ItemName, Color}
		])
	).

%强化公告
notify_strong(ItemId, Phase, Level)->
	case Phase >=3 andalso Level == 1 of
		true ->
			#role_info{id=RoleID, name=RoleName} = role_data:get(?DB_ROLE_INFO),
			#cfg_item{name=ItemName, color=Color} = cfg_item:find(ItemId),
			?notify(?MSG_EQUIP_STRONG_NOTICE, [
				{role, RoleID, RoleName},
				{color, ItemName, Color},
				{color, Phase, ?COLOR_GREEN}
			]);
		false ->
			igonre
	end.

%套装公告
notify_suite_active(Level, SuiteId, ActiveNum)->
	#cfg_equip_suite_level{name=Name1} = cfg_equip_suite_level:find(Level),
	#cfg_equip_suite{title=Name2, attribs=Attribs} = cfg_equip_suite:find(SuiteId),
	AttrMaps = maps:from_list(Attribs),
	case maps:get(ActiveNum, AttrMaps, 0) of
		0 ->
			igonre;
		_ ->
			#role_info{id=RoleID, name=RoleName} = role_data:get(?DB_ROLE_INFO),
			?notify(?MSG_EQUIP_SUITE_NOTICE, [
				{role, RoleID, RoleName},
				Name1,
				Name2,
				{color, ActiveNum, ?COLOR_GREEN}
			])
	end.

%洗练公告
notify_refine(UId, Holes, Locks, RoleSt) ->
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	{ok, Item} = role_bag:get_item(UId),
	Color2 = maps:fold(fun
			(K, #p_refine{color=Color}, Acc) ->
				case not lists:member(K, Locks) of
					true ->
						role_event:event(?EVENT_EQUIP_REFINE, Color),
						case Color >= ?COLOR_ORANGE of
							true  -> Color;
							false -> Acc
						end;
					false ->
						Acc
				end
		end, 0, Holes),
	ItemMap = maps:put(Item#p_item.id, 0, #{}),
	?_if(Color2 > 0, ?notify(?MSG_EQUIP_REFINE_NOTICE, [{role, RoleID, RoleName},
		{item, ItemMap}, ut_color:format(cfg_lang:find({color,Color2}), Color2)])).


calc_decombine_refund(ItemID, Equip) ->
	case Equip#p_equip.combine == ?nil orelse Equip#p_equip.combine == [] of
		true  ->
			#cfg_equip_combine{cost=FixCost, other_cost=OtherCost, min_num=Num} = cfg_equip_combine:find(ItemID),
			Refund1 = [{ID, N, #{bind=>false}} || {ID,N} <- FixCost],
			Refund2 = ?_if(
				OtherCost == [],
				[],
				[{ID, 1, #{bind=>false}} || ID <- ut_rand:choose(OtherCost, Num, false)]
			),
			Refund1 ++ Refund2;
		false ->
			Equip#p_equip.combine
	end.
