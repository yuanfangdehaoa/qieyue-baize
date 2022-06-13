%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(soul_handler).

-include("game.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("table.hrl").
-include("soul.hrl").
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
handle(?SOUL_LIST, _Tos, RoleSt)->
	#role_soul{souls=Souls} = role_data:get(?DB_ROLE_SOUL),
	Souls2 = maps:map(fun(_, UId) ->
		{ok, Soul} = role_bag:get_item(UId),
		item_util:p_item(Soul)
	end, Souls),
	RoleBag = #role_bag{cells=Cells} = role_data:get(?DB_ROLE_BAG),
	case maps:get(?BAG_ID_SOUL, Cells) of
		#cell{opened=Opened} = Cell ->
			case Opened == 60 of
				true ->
					Cell2 = open_cell(?BAG_ID_SOUL, Cell, 140),
					Cells2 = maps:put(?BAG_ID_SOUL, Cell2, Cells),
					role_data:set(RoleBag#role_bag{cells=Cells2});
				false ->
					ignore
			end;
		_ ->
			ignore
	end,
	{ok, #m_soul_list_toc{souls=Souls2}, RoleSt};


%装备
handle(?SOUL_PUTON, Tos, RoleSt)->
	#m_soul_puton_tos{pos=Pos, uid=CellId} = Tos,
	RoleSoul = #role_soul{souls = Souls} = role_data:get(?DB_ROLE_SOUL),
	check_pos(Pos),
	check_pos_open(Pos),
	{ok, Item} = role_bag:get_item(CellId),
	#p_item{id=ItemId} = Item,
	check_pos_type(Pos, ItemId),
	TmpCards = maps:remove(Pos, Souls),
	check_attr_type(maps:to_list(TmpCards), ItemId),
	{ok, _, [NewItem]} = role_bag:move(?BAG_ID_SOUL, ?BAG_ID_SOUL_EQUIP, [{CellId, 1}], RoleSt),
	case maps:get(Pos, Souls, ?nil) of
		?nil->
			ignore;
		OldCellId->
			role_bag:move(?BAG_ID_SOUL_EQUIP, ?BAG_ID_SOUL, [{OldCellId, 1}], RoleSt)
	end,
	Souls2 = maps:put(Pos, NewItem#p_item.uid, Souls),
	role_data:set(RoleSoul#role_soul{souls=Souls2}),
	UpSouls = #{Pos=>item_util:p_item(NewItem)},
	?ucast(#m_soul_list_toc{souls=UpSouls}),
	role_attr:recalc(role_equip, RoleSt),
	role_attr:recalc(role_soul, RoleSt),
	{ok, #m_soul_puton_toc{}, RoleSt};

%取下
handle(?SOUL_PUTOFF, Tos, RoleSt)->
	#m_soul_putoff_tos{pos=Pos} = Tos,
	RoleSoul = #role_soul{souls = Souls} = role_data:get(?DB_ROLE_SOUL),
	UId = maps:get(Pos, Souls, 0),
	?_check(UId > 0, ?ERR_SOUL_DO_NOT_HAVE_ITEM),
	role_bag:move(?BAG_ID_SOUL_EQUIP, ?BAG_ID_SOUL, [{UId, 1}], RoleSt),
	Souls2 = maps:remove(Pos, Souls),
	role_data:set(RoleSoul#role_soul{souls=Souls2}),
	role_attr:recalc(role_equip, RoleSt),
	role_attr:recalc(role_soul, RoleSt),
	{ok, #m_soul_putoff_toc{pos=[Pos]}, RoleSt};


%升级
handle(?SOUL_UPLEVEL, Tos, RoleSt)->
	#m_soul_uplevel_tos{pos=Pos} = Tos,
	#role_soul{souls=Souls} = role_data:get(?DB_ROLE_SOUL),
	case maps:get(Pos, Souls, ?nil) of
		?nil->
			?err(?ERR_SOUL_DO_NOT_HAVE_ITEM);
		CellId ->
			{ok, Item=#p_item{id=ItemId, extra=Level}} = role_bag:get_item(CellId),
			SoulLevel = cfg_soul_level:find(ItemId, Level+1),
			?_check(SoulLevel /= ?nil, ?ERR_SOUL_IS_MAX_STRONG),
			#cfg_soul_level{cost=Cost} = cfg_soul_level:find(ItemId, Level),
			role_bag:cost(Cost, ?LOG_SOUL_UPLEVEL, RoleSt),
			Level2 = Level+1,
			Item2 = Item#p_item{extra=Level2},
			role_bag:set_item(Item2),
			UpSouls = #{Pos=>item_util:p_item(Item2)},
			?ucast(#m_soul_list_toc{souls=UpSouls}),
			role_attr:recalc(role_equip, RoleSt),
			role_attr:recalc(role_soul, RoleSt),
			Rem = Level2 rem 10,
			#role_st{role=RoleID, name=RoleName} = RoleSt,
			ItemMaps = maps:put(ItemId, 0, #{}),
			?_if(Rem == 0, ?notify(?MSG_SOUL_UPLEVEL_NOTICE,
				[{role, RoleID, RoleName}, {item, ItemMaps}, Level2])),
			{ok, #m_soul_uplevel_toc{pos=Pos}, RoleSt}
	end;


%获取分解设置
handle(?SOUL_GET_SET, _Tos, RoleSt)->
	#role_soul{auto=Auto, color=Color} = role_data:get(?DB_ROLE_SOUL),
	{ok, #m_soul_get_set_toc{auto=Auto, color=Color}, RoleSt};

%设置自动分解
handle(?SOUL_DECOMPOSE_SET, Tos, RoleSt)->
	#m_soul_decompose_set_tos{auto=Auto,color=Color} = Tos,
	RoleSoul = role_data:get(?DB_ROLE_SOUL),
	role_data:set(RoleSoul#role_soul{auto=Auto, color=Color}),
	%?ucast(#m_soul_get_set_toc{auto=Auto, color=Color}),
	{ok, #m_soul_decompose_set_toc{}, RoleSt};


%圣痕合成
handle(?SOUL_COMBINE, Tos, RoleSt)->
	#m_soul_combine_tos{r_item_id=RItemId} = Tos,
	#cfg_soul_combine{c_item_id1=CItemId1,c_item_id2=CItemId2, cost=Cost}
	= cfg_soul_combine:find(RItemId),
	RoleSoul = #role_soul{souls=Souls} = role_data:get(?DB_ROLE_SOUL),
	%消耗材料1
	SoulsNum = maps:size(Souls),
	{Pos1, Cost2, TGain1}= case CItemId1 > 0 of
		true ->
			TmpPos2 = case SoulsNum > 0 of
				true  -> get_pos_by_item_id(Souls, CItemId1);
				false -> 0
		    end,
		    {TmpCost2, Level} = get_cos_gain(Souls, TmpPos2, CItemId1),
			#cfg_soul_level{total_cost=TmpTGain2} = cfg_soul_level:find(CItemId1, Level),
			{TmpPos2, TmpCost2, TmpTGain2};
		false ->
			{0, [], []}
	end,
	%消耗材料2
	{Pos2, Cost3, TGain2} = case CItemId2 > 0 of
		true ->
			TmpPos = case SoulsNum > 0 of
				true  -> get_pos_by_item_id(Souls, CItemId2);
				false -> 0
			end,
			{TmpCost, Level2} = get_cos_gain(Souls, TmpPos, CItemId2),
			#cfg_soul_level{total_cost=TmpTGain} = cfg_soul_level:find(CItemId2, Level2),
			{TmpPos, TmpCost, TmpTGain};
		false ->
			{0, [], []}
	end,
	TVV = case length(TGain1) >0 of
		true ->
			[{_, TV1}|_T] = TGain1,
			TV1;
		false ->
			0
	end,
	TVV2 = case length(TGain2) >0 of
		true ->
			[{_, TV2}|_T2] = TGain2,
			TV2;
		false ->
			0
	end,
	{NewLevel, TGain3} = calc_level(RItemId, 1, TVV+TVV2),
	Opts = #{soul_level=>NewLevel},
	Gain = [{RItemId, 1, Opts}],
	%返还升级材料
	NewCost = lists:merge3(Cost, Cost2, Cost3),
	NewGain = lists:merge(Gain, TGain3),
	role_bag:deal(NewCost, NewGain, ?LOG_SOUL_COMPOSE, RoleSt),
	Poses = [],
	%删除装备的魔法卡
	{Poses2, Souls2} = case Pos1 > 0 of
		true  -> {[Pos1 | Poses], maps:remove(Pos1, Souls)};
		false -> {Poses, Souls}
	end,
	{Poses3, Souls3} = case Pos2 > 0 of
		true-> {[Pos2 | Poses2], maps:remove(Pos2, Souls2)};
		false-> {Poses2, Souls2}
	end,
	role_data:set(RoleSoul#role_soul{souls=Souls3}),
	?ucast(#m_soul_putoff_toc{pos=Poses3}),
	role_attr:recalc(role_equip, RoleSt),
	role_attr:recalc(role_soul, RoleSt),
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	ItemMaps = maps:put(RItemId, 0, #{}),
	?notify(?MSG_SOUL_COMPOSE_NOTICE, [{role, RoleID, RoleName}, {item, ItemMaps}]),
	{ok, #m_soul_combine_toc{}, RoleSt};

%分解
handle(?SOUL_DECOMPOSE, Tos, RoleSt)->
	#m_soul_decompose_tos{uid=CellIdList} = Tos,
	RoleSoul = #role_soul{souls=Souls} = role_data:get(?DB_ROLE_SOUL),
	{Cost, Gain, Souls2} = role_soul:decompose(CellIdList, [], [], Souls),
	role_bag:deal(Cost, Gain, ?LOG_SOUL_DECOMPOSE, RoleSt),
	role_data:set(RoleSoul#role_soul{souls=Souls2}),
	role_attr:recalc(role_equip, RoleSt),
	role_attr:recalc(role_soul, RoleSt),
	{ok, #m_soul_decompose_toc{}, RoleSt}.


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------

%检查位置
check_pos(Pos)->
	?_check(Pos >= 1 andalso Pos =< 7, ?ERR_SOUL_POS_WRONG).

%检查位置是否开放
check_pos_open(Pos)->
	#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
	#cfg_soul_pos{level=OpenLevel} = cfg_soul_pos:find(Pos),
	?_check(Level >= OpenLevel, ?ERR_SOUL_POS_NOT_OPEN).

%检查魔法卡类型
check_pos_type(Pos, ItemId)->
	#cfg_soul{slot=Slot} = cfg_soul:find(ItemId),
	case is_core_pos(Pos) of
		true->
			?_check(Slot==2, ?ERR_SOUL_TYPE_NOT_RIGHT);
		false->
			?_check(Slot==1, ?ERR_SOUL_TYPE_NOT_RIGHT)
	end.

%检查魔法卡属性类型
check_attr_type([], ItemId)->
	ItemId;
check_attr_type(Souls, ItemId)->
	lists:foldl(fun
			({_K, CellId}, Sum)->
				{ok, #p_item{id=Id}} = role_bag:get_item(CellId),
				#cfg_soul{attr_type=AttrType} = cfg_soul:find(ItemId),
				#cfg_soul{attr_type=AttrType2} = cfg_soul:find(Id),
				?_check(AttrType /= AttrType2, ?ERR_SOUL_ATTR_NOT_RIGHT),
				AttrTypeList = string:tokens(AttrType, "@"),
				AttrTypeList2 = string:tokens(AttrType2, "@"),
				lists:foldl(fun
						(AType, Sum2) ->
							 check_attr_type2(AType, AttrTypeList2),
							 Sum2 + 0
					end, 0, AttrTypeList),
				Sum + 0
		end, 0, Souls).

check_attr_type2(AType, [])->
	AType;
check_attr_type2(AType, [AType2|ATList])->
	?_check(AType /= AType2, ?ERR_SOUL_ATTR_NOT_RIGHT),
	check_attr_type2(AType, ATList).



%是否核心部位
is_core_pos(Pos)->
	case Pos == 1 of
		true -> true;
		_    -> false
	end.

%根据itemid查找装备的圣痕位置
get_pos_by_item_id(_Souls, 0) ->
	0;
get_pos_by_item_id(Souls, ItemId) ->
	PosList = maps:fold(fun
			(Pos, CellId, Lists)->
				{ok, #p_item{id=Id}} = role_bag:get_item(CellId),
				case Id == ItemId of
					true-> [Pos | Lists];
					false-> Lists
				end
		end, [], Souls),
	case length(PosList) > 0 of
		true  -> lists:nth(1, PosList);
		false -> 0
	end.


%获取消耗和获得的魔法卡
get_cos_gain(Souls, Pos, ItemId)->
	case Pos > 0 of
		true->
			CellId = maps:get(Pos, Souls),
			{ok, #p_item{extra=Lv}} = role_bag:get_item(CellId),
			{[{cellid, CellId}], Lv};
		false->
			ItemList = role_bag:get_items(ItemId),
			?_check(length(ItemList)>0, ?ERR_ITEM_NOT_ENOUGH),
			ItemList2 = lists:keysort(#p_item.extra, ItemList),
			#p_item{uid=Uid, extra=Lv} = lists:last(ItemList2),
			{[{cellid, Uid}], Lv}
	end.

%计算等级
calc_level(ItemID, Level, Had)->
	SoulLevelCfg = cfg_soul_level:find(ItemID, Level),
	case SoulLevelCfg of
		?nil ->
			#cfg_soul_level{total_cost=TotalCost} = cfg_soul_level:find(ItemID, Level-1),
			[{MoneyID, Need}|_T] = TotalCost,
			{Level-1, [{MoneyID, Had-Need}]};
		_ ->
			#cfg_soul_level{total_cost=TotalCost} = SoulLevelCfg,
			[{MoneyID, Need}|_T] = TotalCost,
			case Had >= Need of
				true ->
					calc_level(ItemID, Level+1, Had);
				false ->
					#cfg_soul_level{total_cost=TotalCost2} = cfg_soul_level:find(ItemID, Level-1),
					[{_, Need2}|_T] = TotalCost2,
					{Level-1, [{MoneyID, Had-Need2}]}
			end
	end.

open_cell(BagID, Cell, Num) ->
    ID  = role_bag:gen_cellid(BagID),
    Min = ID + Cell#cell.opened,
    Max = Min + Num - 1,
    Cell#cell{
        opened = Cell#cell.opened + Num,
        unused = Cell#cell.unused ++ lists:seq(Min, Max)
    }.

