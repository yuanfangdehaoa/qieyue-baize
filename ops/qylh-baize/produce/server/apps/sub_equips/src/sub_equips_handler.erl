%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(sub_equips_handler).

-include("game.hrl").
-include("proto.hrl").
-include("msgno.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("table.hrl").
-include("sub_equips.hrl").
-include("role.hrl").
-include("item.hrl").
-include("bag.hrl").
-include("enum.hrl").

%% API
%-export([handle/3]).
%-export([get_attr/2]).


%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%获取装备列表
% handle(?SUB_EQUIP, Tos, RoleSt)->
% 	#m_sub_equip_tos{stype=SType} = Tos,
% 	#role_sub_equips{equips=TypeEquips} = role_data:get(?DB_ROLE_SUB_EQUIPS),
% 	Equips = maps:get(SType, TypeEquips, #{}),
% 	Items = maps:fold(fun
% 			(_, CellId, Lists) ->
% 				{ok, Item} = role_bag:get_item(CellId),
% 				[item_util:p_item(Item) | Lists]
% 		end, [], Equips),
% 	Slots = #{},
% 	{ok, #m_sub_equip_toc{stype=SType, equips=Items, slots=Slots}, RoleSt};

% %穿戴装备
% handle(?SUB_EQUIP_PUTON, Tos, RoleSt)->
% 	#m_sub_equip_puton_tos{uid=UId} = Tos,
% 	{ok, Item} = role_bag:get_item(UId),
% 	#p_item{id=ItemID} = Item,
% 	#cfg_sub_equip{slot=Slot, stype=SType} = cfg_sub_equip:find(ItemID),
% 	%check_slot_open(Slot),
% 	RoleSubEquips = #role_sub_equips{equips=TypeEquips} = role_data:get(?DB_ROLE_SUB_EQUIPS),
% 	Equips = maps:get(SType, TypeEquips, #{}),
% 	OldUId = maps:get(Slot, Equips, 0),
% 	{BagID, EquipBagID} = get_bag_id(SType),
% 	{ok, _, [NewItem]} = role_bag:move(BagID, EquipBagID, [{UId,1}], RoleSt),
% 	%原部位有装备
% 	NewItem4 = case OldUId > 0 of
% 		true ->
% 			{ok, OldItem} = role_bag:get_item(OldUId),
% 			#p_item{extra=Level} = OldItem,
% 			role_bag:move(EquipBagID, BagID, [{OldUId, 1}], RoleSt),
% 			OldItem2 = OldItem#p_item{extra=0},
% 			#p_item{equip=OldEquip} = OldItem2,
% 			OldPower = calc_power(OldItem2),
% 			OldEquip2 = OldEquip#p_equip{power=OldPower},
% 			OldItem3 = OldItem2#p_item{equip=OldEquip2},
% 			role_bag:set_item(OldItem3),
% 			NewItem2 = NewItem#p_item{extra=Level},
% 			#p_item{equip=Equip} = NewItem2,
% 			Power = calc_power(NewItem2),
% 			Equip2 = Equip#p_equip{power=Power},
% 			NewItem3 = NewItem2#p_item{equip=Equip2},
% 			role_bag:set_item(NewItem3),
% 			NewItem3;
% 		false->
% 			NewItem
% 	end,
% 	Equips2 = maps:put(Slot, NewItem4#p_item.uid, Equips),
% 	TypeEquips2 = maps:put(SType, Equips2, TypeEquips),
% 	role_data:set(RoleSubEquips#role_sub_equips{equips=TypeEquips2}),
% 	role_attr:recalc({sub_equips_handler, SType}, RoleSt),
% 	?ucast(#m_sub_equip_toc{equips=[item_util:p_item(NewItem4)]}),
% 	{ok, #m_sub_equip_puton_toc{slot=Slot, stype=SType}, RoleSt};

% %装备强化
% handle(?SUB_EQUIP_UPLEVEL, Tos, RoleSt)->
% 	#m_sub_equip_uplevel_tos{slot=Slot, stype=SType} = Tos,
% 	#role_sub_equips{equips=TypeEquips} = role_data:get(?DB_ROLE_SUB_EQUIPS),
% 	Equips = maps:get(SType, TypeEquips, #{}),
% 	UId = maps:get(Slot, Equips, 0),
% 	?_check(UId > 0, ?ERR_BABY_NO_EQUIP_PUTON),
% 	{ok, Item} = role_bag:get_item(UId),
% 	#p_item{extra=OldLevel} = Item,
%     #cfg_sub_equip_level{cost=Cost} = cfg_sub_equip_level:find(SType, Slot, OldLevel),
%     ?_check(length(Cost) > 0, ?ERR_BABY_EQUIP_MAX_LEVEL),
%     role_bag:cost(Cost, ?LOG_GOD_EQUIP_UPLEVEL, RoleSt),
%     Item2 = Item#p_item{extra=OldLevel+1},
%     #p_item{equip=Equip} = Item2,
%     Power = calc_power(Item2),
%     Equip2 = Equip#p_equip{power=Power},
%     Item3 = Item2#p_item{equip=Equip2},
%     role_bag:set_item(Item3),
%     role_attr:recalc({sub_equips_handler, SType}, RoleSt),
%     ?ucast(#m_sub_equip_toc{equips=[item_util:p_item(Item3)]}),
% 	{ok, #m_sub_equip_uplevel_toc{slot=Slot, stype=SType}, RoleSt};


% %装备分解
% handle(?SUB_EQUIP_DECOMPOSE, Tos, RoleSt)->
% 	#m_god_equip_decompose_tos{uid=UIds} = Tos,
% 	{Costs, Gains} = lists:foldl(fun 
% 			(UId, {Acc1, Acc2}) -> 
% 				{ok, Item} = role_bag:get_item(UId),
% 				#p_item{id=ItemID} = Item,
% 				 #cfg_sub_equip{gain=Gain} = cfg_sub_equip:find(ItemID),
% 				 {[{cellid, UId}|Acc1], lists:merge(Gain, Acc2)}
% 		end, {[], []}, UIds),
% 	role_bag:deal(Costs, Gains, ?LOG_GOD_EQUIP_DECOMPOSE, RoleSt),
% 	{ok, #m_sub_equip_decompose_toc{}, RoleSt}.

% %计算属性
%  get_attr(_AttrType, SType)->
%  	#role_sub_equips{equips=TypeEquips} = role_data:get(?DB_ROLE_SUB_EQUIPS),
%  	Equips = maps:get(SType, TypeEquips, #{}),
%  	maps:fold(fun 
%  			(_K, UId, Acc) -> 
%  				{ok, Item} = role_bag:get_item(UId),
%  				#p_item{id=ItemID, extra=Level, equip=Equip} = Item,
%  				#p_equip{base=Base} = Equip,
%                 #cfg_sub_equip{slot=Slot} = cfg_sub_equip:find(ItemID),
%                 #cfg_sub_equip_level{attr=Attr} = cfg_sub_equip_level:find(SType, Slot, Level),
%                 mod_attr:sum([Acc, Base, mod_attr:to_map(Attr)])
%  		end, #{}, Equips).

% %%%-----------------------------------------------------------------------------
% %%% Internal Functions
% %%%-----------------------------------------------------------------------------
% calc_power(Item)->
% 	#p_item{id=ItemID, extra=Level, equip=Equip} = Item,
% 	#cfg_sub_equip{slot=Slot, stype=SType} = cfg_sub_equip:find(ItemID),
% 	#cfg_sub_equip_level{attr=Attr} = cfg_sub_equip_level:find(SType, Slot, Level),
% 	StrongAttr = mod_attr:to_map(Attr),
% 	#p_equip{base=BaseAttr} = Equip, 
% 	mod_attr:power(mod_attr:sum([BaseAttr, StrongAttr])).

% get_bag_id(_)->
% 	{?BAG_ID_MECHA, ?BAG_ID_MECHA_EQUIP}.
