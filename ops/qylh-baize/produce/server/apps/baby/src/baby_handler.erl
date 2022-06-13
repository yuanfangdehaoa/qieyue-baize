%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(baby_handler).

-include("game.hrl").
-include("proto.hrl").
-include("msgno.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("table.hrl").
-include("baby.hrl").
-include("role.hrl").
-include("item.hrl").
-include("bag.hrl").
-include("enum.hrl").

%% API
-export([handle/3]).
-export([add_baby_progress/2]).
-export([full_progress/2]).
-export([get_attr/1]).
-export([get_power/0]).
-export([hook_reset/3]).
-export([role_like/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%宝宝信息
handle(?BABY_INFO, _Tos, RoleSt)->
	add_baby_progress(#{}, RoleSt),
	RoleBaby = role_data:get(?DB_ROLE_BABY),
	#role_baby{is_hide=IsHide, baby=Baby, progress=Progress} = RoleBaby,
	Babies = maps:values(Baby),
	update_figure(RoleSt),
	{ok, #m_baby_info_toc{is_hide=IsHide, babies=Babies, progress=Progress}, RoleSt};

%升级
handle(?BABY_UPLEVEL, Tos, RoleSt)->
	#m_baby_uplevel_tos{gender=Gender} = Tos,
	RoleBaby = role_data:get(?DB_ROLE_BABY),
	#role_baby{baby=BabyMap, is_hide=IsHide} = RoleBaby,
	Baby = maps:get(Gender, BabyMap, ?nil),
	?_check(Baby /= ?nil, ?ERR_BABY_NOT_BORN),
	#p_baby{level=Level} = Baby,
	BabyLevel = cfg_baby_level:find(Gender, Level+1),
	?_check(BabyLevel /= ?nil, ?ERR_BABY_LEVEL_IS_MAX),
	#cfg_baby{growitem=ItemId} = cfg_baby:find(Gender),
	#cfg_item{effect=Effect} = cfg_item:find(ItemId),
	role_bag:cost([{ItemId, 1}], ?LOG_BABY_UPLEVEL, RoleSt),
	Baby2 = check_uplevel(Baby, ut_conv:to_integer(Effect), RoleSt),
	BabyMap2 = maps:put(Gender, Baby2, BabyMap),
	role_data:set(RoleBaby#role_baby{baby=BabyMap2}),
	?ucast(#m_baby_info_toc{is_hide=IsHide, babies=[Baby2]}),
	role_attr:recalc(baby_handler, RoleSt),
	{ok, #m_baby_uplevel_toc{}, RoleSt};

%逗宝宝
handle(?BABY_PLAY, Tos, RoleSt)->
	#m_baby_play_tos{gender=Gender} = Tos,
	RoleBaby = #role_baby{is_hide=IsHide, baby=BabyMap} = role_data:get(?DB_ROLE_BABY),
	Baby = maps:get(Gender, BabyMap, ?nil),
	?_check(Baby /= ?nil, ?ERR_BABY_NOT_BORN),
	#p_baby{play=PlayCount} = Baby,
	#cfg_baby{play_gain=Gain, play_count=Count} = cfg_baby:find(Gender),
	Baby2 = case PlayCount < Count of
		true ->
			role_bag:gain(Gain, ?LOG_BABY_PLAY_REWARD, RoleSt),
			Baby#p_baby{play=PlayCount+1};
		false->
			Baby
	end,
	BabyMap2 = maps:put(Gender, Baby2, BabyMap),
	role_data:set(RoleBaby#role_baby{baby=BabyMap2}),
	?ucast(#m_baby_info_toc{is_hide=IsHide, babies=[Baby2]}),
	{ok, #m_baby_play_toc{}, RoleSt};

%进阶信息
handle(?BABY_ORDER_INFO, _Tos, RoleSt) ->
	#role_baby{order=BabyOrders, figure=Figure} = role_data:get(?DB_ROLE_BABY),
	BabyList = maps:values(BabyOrders),
	{ok, #m_baby_order_info_toc{babies=BabyList, figure=Figure}, RoleSt};

%升阶
handle(?BABY_UP_ORDER, Tos, RoleSt) ->
	#m_baby_up_order_tos{id=Id, item_id=ItemId} = Tos,
	RoleBaby = #role_baby{order=BabyMap, figure=Figure} = role_data:get(?DB_ROLE_BABY),
	Baby = maps:get(Id, BabyMap, ?nil),
	?_check(Baby /= ?nil, ?ERR_BABY_NOT_ACTIVE),
	#p_baby_order{order=Order, exp=OldExp} = Baby,
	#cfg_baby_order{cost=Cost, next_id=NextId} = cfg_baby_order:find(Id, Order),
	?_check(not maps:is_key(NextId, BabyMap), ?ERR_BABY_ORDER_IS_MAX),
	?_check(not is_max_order(Id, Order, NextId), ?ERR_BABY_ORDER_IS_MAX),
	?_check(lists:member(ItemId, Cost), ?ERR_BABY_UP_ORDER_ITEM_WRONG),
	role_bag:cost([{ItemId, 1}], ?LOG_BABY_UP_ORDER, RoleSt),
	#cfg_item{effect=Effect} = cfg_item:find(ItemId),
	Baby2 = Baby#p_baby_order{exp=OldExp+ut_conv:to_integer(Effect)},
	{BabyMap2, UpList} = check_up_order(Baby2, BabyMap, [Baby2], RoleSt),
	role_data:set(RoleBaby#role_baby{order=BabyMap2}),
	?ucast(#m_baby_order_info_toc{figure=Figure, babies=UpList}),
	role_attr:recalc(baby_handler, RoleSt),
	{ok, #m_baby_up_order_toc{}, RoleSt};

%激活
handle(?BABY_ACTIVE, Tos, RoleSt) ->
	#m_baby_active_tos{id=Id} = Tos,
	RoleBaby = #role_baby{order=BabyMap, figure=Figure} = role_data:get(?DB_ROLE_BABY),
	Baby = maps:get(Id, BabyMap, ?nil),
	?_check(Baby == ?nil, ?ERR_BABY_ALREADY_ACTIVE),
	#cfg_baby_order{active=Cost, type_id=Type, name=BabyName} = cfg_baby_order:find(Id, 0),
	?_check(Type==2, ?ERR_BABY_TYPE_CANNOT_ACTVIE),
	role_bag:cost(Cost, ?LOG_BABY_ACTIVE, RoleSt),
	Baby2 = p_baby_order(Id, 0),
	BabyMap2 = maps:put(Id, Baby2, BabyMap),
	role_data:set(RoleBaby#role_baby{order=BabyMap2}),
	?ucast(#m_baby_order_info_toc{figure=Figure, babies=[Baby2]}),
	role_attr:recalc(baby_handler, RoleSt),
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	?notify(?MSG_BABY_BORN, [{role, RoleID, RoleName}, BabyName]),
	update_figure(RoleSt),
	{ok, #m_baby_active_toc{}, RoleSt};

%隐藏显示
handle(?BABY_HIDE, Tos, RoleSt)->
	#m_baby_hide_tos{hide=Hide} = Tos,
	RoleBaby = role_data:get(?DB_ROLE_BABY),
	role_data:set(RoleBaby#role_baby{is_hide=Hide}),
	?ucast(#m_baby_info_toc{is_hide=Hide}),
	update_figure(RoleSt),
	{ok, #m_baby_hide_toc{}, RoleSt};

%幻化
handle(?BABY_FIGURE, Tos, RoleSt) ->
	#m_baby_figure_tos{id=Id} = Tos,
	#role_st{role=RoleID} = RoleSt,
	RoleBaby = #role_baby{order=BabyMap, figure=Figure, wing_id=WingID} = role_data:get(?DB_ROLE_BABY),
	Baby = maps:get(Id, BabyMap, ?nil),
	?_check(Baby /= ?nil, ?ERR_BABY_NOT_ACTIVE),
	?_check(Figure /= Id, ?ERR_BABY_ALREADY_SHOW),
	role_data:set(RoleBaby#role_baby{figure=Id}),
	?ucast(#m_baby_order_info_toc{figure=Id}),
	update_figure(RoleSt),
	baby_server:update_cache(RoleID, Baby, WingID),
	{ok, #m_baby_figure_toc{}, RoleSt};

%点赞
handle(?BABY_LIKE, Tos, RoleSt)->
	#m_baby_like_tos{role_id=LikeRoleID} = Tos,
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	{ok, BabyCache} = baby_server:get_baby(LikeRoleID),
	?_check(BabyCache /= ?nil, ?ERR_BABY_NO_FIGURE_BABY),
	#baby_cache{baby_order=PBabyOrder} = BabyCache,
	#p_baby_order{id=BabyID} = PBabyOrder,
	RoleBaby = #role_baby{likes=Likes} = role_data:get(?DB_ROLE_BABY),
	Result = lists:member(LikeRoleID, Likes),
	{Likes2, AddCount} = case Result==false andalso RoleID /=LikeRoleID of
		true ->
			Message = #p_baby_like{role_id=RoleID,role_name=RoleName, time=ut_time:seconds(), state=0},
			game_logger:add_log({?MODULE, like, LikeRoleID}, Message),
			{_, {Count, Data}} = rank:get_ranklist(?BABY_LIKE_RANK, LikeRoleID),
			Count2 = Count + 1,
			rank:update_rank(?BABY_LIKE_RANK, LikeRoleID, Count2, maps:put("baby_id", BabyID, Data)),
			?_if(online_server:is_online(LikeRoleID), role:route(LikeRoleID, baby_handler, role_like, {RoleID, Message})),
			{[LikeRoleID | Likes], true};
		false->
			{Likes, false}
	end,
	role_data:set(RoleBaby#role_baby{likes=Likes2}),
	{ok, #m_baby_like_toc{role_id=LikeRoleID, add_count=AddCount}, RoleSt};

%获取点赞信息
handle(?BABY_LIKE_INFO, Tos, RoleSt)->
	#m_baby_like_info_tos{role_id=RoleID} = Tos,
	{ok, BabyCache} = baby_server:get_baby(RoleID),
	?_check(BabyCache /= ?nil, ?ERR_BABY_NO_FIGURE_BABY),
	#baby_cache{baby_order=PBabyOrder,wing_id=WingID} = BabyCache,
	{_, {Count, _}} = rank:get_ranklist(?BABY_LIKE_RANK, RoleID),
	#p_role_base{name=RoleName} = role:get_base(RoleID),
	{ok, #m_baby_like_info_toc{count=Count, baby=PBabyOrder, wing_id=WingID, role_id=RoleID, role_name=RoleName}, RoleSt};

%获取记录
handle(?BABY_LIKE_RECORDS, _Tos, RoleSt)->
	#role_st{role=RoleID} = RoleSt,
	Messages = game_logger:get_logs({?MODULE, like, RoleID}),
	#role_baby{likes=Likes} = role_data:get(?DB_ROLE_BABY),
	Messages2 = [ p_baby_like(PBabyLike, Likes) || PBabyLike <- Messages],
	{ok, #m_baby_like_records_toc{records=Messages2}, RoleSt};

%获取装备列表
handle(?BABY_EQUIPS, _Tos, RoleSt)->
	#role_baby{equips=Equips} = role_data:get(?DB_ROLE_BABY),
	Items = maps:fold(fun
			(_, CellId, Lists) ->
				{ok, Item} = role_bag:get_item(CellId),
				[item_util:p_item(Item) | Lists]
		end, [], Equips),
	{ok, #m_baby_equips_toc{equips=Items}, RoleSt};

%穿戴装备
handle(?BABY_EQUIP_PUTON, Tos, RoleSt)->
	#m_baby_equip_puton_tos{uid=UId} = Tos,
	{ok, Item} = role_bag:get_item(UId),
	#p_item{id=ItemID} = Item,
	#cfg_baby_equip{slot=Slot} = cfg_baby_equip:find(ItemID),
	RoleBaby = #role_baby{equips=Equips} = role_data:get(?DB_ROLE_BABY),
	OldUId = maps:get(Slot, Equips, 0),
	{ok, _, [NewItem]} = role_bag:move(?BAG_ID_BABY, ?BAG_ID_BABY_EQUIP, [{UId,1}], RoleSt),
	%原部位有装备
	NewItem4 = case OldUId > 0 of
		true ->
			{ok, OldItem} = role_bag:get_item(OldUId),
			#p_item{extra=Level} = OldItem,
			role_bag:move(?BAG_ID_BABY_EQUIP, ?BAG_ID_BABY, [{OldUId, 1}], RoleSt),
			OldItem2 = OldItem#p_item{extra=0},
			#p_item{equip=OldEquip} = OldItem2,
			OldPower = calc_power(OldItem2),
			OldEquip2 = OldEquip#p_equip{power=OldPower},
			OldItem3 = OldItem2#p_item{equip=OldEquip2},
			role_bag:set_item(OldItem3),
			NewItem2 = NewItem#p_item{extra=Level},
			#p_item{equip=Equip} = NewItem2,
			Power = calc_power(NewItem2),
			Equip2 = Equip#p_equip{power=Power},
			NewItem3 = NewItem2#p_item{equip=Equip2},
			role_bag:set_item(NewItem3),
			NewItem3;
		false->
			NewItem
	end,
	Equips2 = maps:put(Slot, NewItem4#p_item.uid, Equips),
	role_data:set(RoleBaby#role_baby{equips=Equips2}),
	role_attr:recalc(baby_handler, RoleSt),
	?ucast(#m_baby_equips_toc{equips=[item_util:p_item(NewItem4)]}),
	{ok, #m_baby_equip_puton_toc{slot=Slot}, RoleSt};

%装备强化
handle(?BABY_EQUIP_UPLEVEL, Tos, RoleSt)->
	#m_baby_equip_uplevel_tos{slot=Slot} = Tos,
	#role_baby{equips=Equips} = role_data:get(?DB_ROLE_BABY),
	UId = maps:get(Slot, Equips, 0),
	?_check(UId > 0, ?ERR_BABY_NO_EQUIP_PUTON),
	{ok, Item} = role_bag:get_item(UId),
	#p_item{extra=OldLevel} = Item,
    #cfg_baby_equip_level{cost=Cost} = cfg_baby_equip_level:find(Slot, OldLevel),
    ?_check(length(Cost) > 0, ?ERR_BABY_EQUIP_MAX_LEVEL),
    role_bag:cost(Cost, ?LOG_BABY_EQUIP_UPLEVEL, RoleSt),
    Item2 = Item#p_item{extra=OldLevel+1},
    #p_item{equip=Equip} = Item2,
    Power = calc_power(Item2),
    Equip2 = Equip#p_equip{power=Power},
    Item3 = Item2#p_item{equip=Equip2},
    role_bag:set_item(Item3),
    role_attr:recalc(baby_handler, RoleSt),
    ?ucast(#m_baby_equips_toc{equips=[item_util:p_item(Item3)]}),
	{ok, #m_baby_equip_uplevel_toc{slot=Slot}, RoleSt};

%装备分解
handle(?BABY_EQUIP_DECOMPOSE, Tos, RoleSt)->
	#m_baby_equip_decompose_tos{uid=UIds} = Tos,
	{Costs, Gains} = lists:foldl(fun
			(UId, {Acc1, Acc2}) ->
				{ok, Item} = role_bag:get_item(UId),
				#p_item{id=ItemID} = Item,
				 #cfg_baby_equip{gain=Gain} = cfg_baby_equip:find(ItemID),
				 {[{cellid, UId}|Acc1], lists:merge(Gain, Acc2)}
		end, {[], []}, UIds),
	role_bag:deal(Costs, Gains, ?LOG_BABY_EQUIP_DECOMPOSE, RoleSt),
	{ok, #m_baby_equip_decompose_toc{}, RoleSt};

%子女翅膀
handle(?BABY_WING, _Tos, RoleSt)->
	#role_baby{wings=Wings, wing_id=WingID} = role_data:get(?DB_ROLE_BABY),
	{ok, #m_baby_wing_toc{ids=Wings, show_id=WingID}, RoleSt};

%子女翅膀升级
handle(?BABY_WING_UPLEVEL, Tos, RoleSt)->
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	#m_baby_wing_uplevel_tos{id=ID} = Tos,
	RoleBaby = #role_baby{order=Orders, figure=Figure, wings=Wings, wing_id=WingID} = role_data:get(?DB_ROLE_BABY),
	Level = maps:get(ID, Wings, ?nil),
	Level2 = case Level of
		?nil ->
			#cfg_baby_wing_morph{cost=Cost} = cfg_baby_wing_morph:find(ID),
			1;
		_ ->
			?_check(Level < cfg_baby_wing_star:max(ID), ?ERR_BABY_WING_MAX_STAR),
			#cfg_baby_wing_star{cost=Cost} = cfg_baby_wing_star:find(ID, Level),
			Level+1
	end,
	role_bag:cost(Cost, ?LOG_BABY_WING_UPLEVEL, RoleSt),
	WingID2 = case WingID == 0 of
		true  ->
			ResID = cfg_baby_wing_morph:res(ID),
			role_figure:update_baby_wing(ResID, RoleSt),
			ID;
		false ->
			WingID
	end,
	Wings2 = maps:put(ID, Level2, Wings),
	role_data:set(RoleBaby#role_baby{wings=Wings2, wing_id=WingID2}),
	UPWings = #{ID=>Level2},
	role_attr:recalc(baby_handler, RoleSt),
	PBabyOrder = maps:get(Figure, Orders, ?nil),
 	case PBabyOrder /= ?nil of
 		true  -> baby_server:update_cache(RoleID, PBabyOrder, WingID2);
 		false -> ignore
 	end,
 	[{ItemID, _}|_T] = Cost,
 	case Level2 == 1 of
 		true ->
 			?notify(?MSG_BABY_WING_ACTIVE, [{role, RoleID, RoleName}, {item, #{ItemID=>0}}]);
 		false ->
 			?notify(?MSG_BABY_WING_UPLEVEL, [{role, RoleID, RoleName}, {item, #{ItemID=>0}}, Level2])
 	end,
	?ucast(#m_baby_wing_toc{ids=UPWings, show_id=WingID2}),
	{ok, #m_baby_wing_uplevel_toc{id=ID}, RoleSt};

%子女翅膀幻化
handle(?BABY_WING_SHOW, Tos, RoleSt)->
	#role_st{role=RoleID} = RoleSt,
	#m_baby_wing_show_tos{id=ID} = Tos,
	RoleBaby = #role_baby{order=Orders, figure=Figure, wings=Wings, wing_id=WingID} = role_data:get(?DB_ROLE_BABY),
	?_check(ID /= WingID, ?ERR_BABY_WING_IS_SHOW),
	?_check(maps:is_key(ID, Wings), ?ERR_BABY_WING_IS_NO_ACTIVE),
	role_data:set(RoleBaby#role_baby{wing_id=ID}),
	?ucast(#m_baby_wing_toc{show_id=ID}),
	ResID = cfg_baby_wing_morph:res(ID),
	role_figure:update_baby_wing(ResID, RoleSt),
	PBabyOrder = maps:get(Figure, Orders, ?nil),
 	case PBabyOrder /= ?nil of
 		true  -> baby_server:update_cache(RoleID, PBabyOrder, ID);
 		false -> ignore
 	end,
	{ok, #m_baby_wing_show_toc{id=ID}, RoleSt}.

role_like({RoleID, PBabyLike}, RoleSt)->
	#role_baby{likes=Likes} = role_data:get(?DB_ROLE_BABY),
	{ok, BabyCache} = baby_server:get_baby(RoleID),
	case lists:member(RoleID, Likes) of
		false ->
			PBabyLike2 = case BabyCache == ?nil of
				true  -> PBabyLike#p_baby_like{state=1};
				false -> PBabyLike
			end,
			?ucast(#m_baby_like_record_toc{record=PBabyLike2});
		true  ->
			ignore
	end.

%添加出生值
 add_baby_progress(BornMap, RoleSt)->
 	Value1 = maps:get(1, BornMap, 0),
 	Value2 = maps:get(2, BornMap, 0),
 	RoleBaby = role_data:get(?DB_ROLE_BABY),
	#role_baby{progress=Progress, is_hide=IsHide} = RoleBaby,
	OldValue1 = maps:get(1, Progress, 0),
	OldValue2 = maps:get(2, Progress, 0),
	NewValue1 = OldValue1 + Value1,
	NewValue2 = OldValue2 + Value2,
	Progress2 = maps:put(1, NewValue1, Progress),
	Progress3 = maps:put(2, NewValue2, Progress2),
	RoleBaby2 = RoleBaby#role_baby{progress=Progress3},
	{RoleBaby3, AddBaby, AddOrder}= check_born(Progress3, RoleBaby2, RoleSt),
	role_data:set(RoleBaby3),
 	?ucast(#m_baby_info_toc{is_hide=IsHide, progress=Progress3, babies=AddBaby}),
 	?ucast(#m_baby_order_info_toc{babies=AddOrder, figure=RoleBaby3#role_baby.figure}),
 	update_figure(RoleSt),
 	notify_born(AddBaby, RoleSt).

 %出生值满
 full_progress(Gender, RoleSt)->
 	RoleBaby = role_data:get(?DB_ROLE_BABY),
 	#role_st{role=RoleID} = RoleSt,
	#role_baby{progress=Progress, baby=BabyMap, is_hide=IsHide, wing_id=WingID} = RoleBaby,
	?_check(not maps:is_key(Gender, BabyMap), ?ERR_BABY_ALREADY_ACTIVE),
	#cfg_baby{reqs=Reqs} = cfg_baby:find(Gender),
	Progress2 = maps:put(Gender, Reqs, Progress),
	RoleBaby2 = RoleBaby#role_baby{progress=Progress2},
	{RoleBaby3, AddBaby, AddOrder}= check_born(Progress2, RoleBaby2, RoleSt),
	role_data:set(RoleBaby3),
 	?ucast(#m_baby_info_toc{is_hide=IsHide, progress=Progress2, babies=AddBaby}),
 	?ucast(#m_baby_order_info_toc{babies=AddOrder, figure=RoleBaby3#role_baby.figure}),
 	update_figure(RoleSt),
 	#role_baby{figure=Figure, order=Orders} = RoleBaby3,
 	PBabyOrder = maps:get(Figure, Orders, ?nil),
 	case PBabyOrder /= ?nil of
 		true  -> baby_server:update_cache(RoleID, PBabyOrder, WingID);
 		false -> ignore
 	end,
 	notify_born(AddBaby, RoleSt).

%计算属性
 get_attr(_)->
 	Attr = calc_attr(),
 	role_event:event(?EVENT_BABY_POWER, mod_attr:power(Attr)),
	Attr.

get_power() ->
 	Attr = calc_attr(),
 	mod_attr:power(Attr).

 hook_reset(_DoW, _Hour, _RoleSt)->
 	RoleBaby = role_data:get(?DB_ROLE_BABY),
	#role_baby{baby=BabyMap} = RoleBaby,
	BabyMap2 = maps:fold(fun
			(K, Baby, Acc) ->
				Baby2 = Baby#p_baby{play=0},
				maps:put(K, Baby2, Acc)
		end, #{}, BabyMap),
	role_data:set(RoleBaby#role_baby{baby=BabyMap2, likes=[]}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%生成宝宝
p_baby_order(Id, Exp)->
	#p_baby_order{
		id      = Id,
		order   = 0,
		exp     = Exp,
		blood_type = ut_rand:random(1, 4),
		constellation = ut_rand:random(1, 12)
	}.

p_baby(Gender)->
	#p_baby{
		gender = Gender,
		level  = 0,
		play   = 0,
		exp    = 0
	}.

%是否已达最高阶
is_max_order(Id, Order, NextId)->
	NextBaby = cfg_baby_order:find(Id, Order+1),
	case NextBaby == ?nil andalso NextId == 0 of
		true  -> true;
		false -> false
	end.

%检查升级
check_uplevel(Baby, AddExp, RoleSt)->
	#p_baby{gender=Gender, level=Level, exp=Exp} = Baby,
	BabyLevelCfg = cfg_baby_level:find(Gender, Level+1),
	case BabyLevelCfg of
		?nil ->
			Baby#p_baby{exp=Exp+AddExp};
		#cfg_baby_level{cost=NeedExp}->
			case Exp+AddExp >= NeedExp of
				true  ->
					Level2 = Level+1,
					Baby2 = Baby#p_baby{level=Level2, exp=Exp+AddExp-NeedExp},
					Rem = Level2 rem 10,
					case Level2 > 0 andalso Rem == 0 of
						true ->
							#role_st{role=RoleID, name=RoleName} = RoleSt,
							#cfg_baby{name=BabyName} = cfg_baby:find(Gender),
							?notify(?MSG_BABY_UPLEVEL, [{role, RoleID, RoleName}, BabyName, Level2]);
						false ->
							ignore
					end,
					check_uplevel(Baby2, 0, RoleSt);
				false ->
					Baby#p_baby{exp=Exp+AddExp}
			end
	end.

%宝宝出生
check_born(Progress, RoleBaby, RoleSt)->
	maps:fold(fun
			(Gender, Pro, {Acc, AddBaby, AddOrder}) ->
				#role_baby{baby=BabyMap, order=OrderMap, figure=Figure} = Acc,
				#cfg_baby{id=Id, reqs=Need} = cfg_baby:find(Gender),
				case Pro >= Need andalso not maps:is_key(Gender, BabyMap) of
					true ->
						Baby = p_baby(Gender),
						BabyMap2 = maps:put(Gender, Baby, BabyMap),
						AddBaby2 = [Baby|AddBaby],
						BabyOrder = p_baby_order(Id, 0),
						OrderMap2 = maps:put(Id, BabyOrder, OrderMap),
						AddOrder2 = [BabyOrder|AddOrder],
						Figure2 = case Figure == 0 of
							true  -> Id;
							false -> Figure
						end,
						Acc2 = Acc#role_baby{baby=BabyMap2, order=OrderMap2, figure=Figure2},
						role_attr:recalc(baby_handler, RoleSt),
						{Acc2, AddBaby2, AddOrder2};
					false ->
						{Acc, AddBaby, AddOrder}
				end
		end, {RoleBaby, [], []}, Progress).


%宝宝升阶
check_up_order(Baby, BabyMap, NewBabyList, RoleSt)->
	#p_baby_order{id=Id, order=Order, exp=OldExp} = Baby,
	#cfg_baby_order{exp=NeedExp, next_id=NextId} = cfg_baby_order:find(Id, Order),
	case OldExp >= NeedExp of
		true ->
			case NextId > 0 of
				true  ->
					case not maps:is_key(NextId, BabyMap) of
						true ->
							Baby2 = Baby#p_baby_order{exp=NeedExp},
							BabyMap2 = maps:put(Id, Baby2, BabyMap),
							NewBaby = p_baby_order(NextId, OldExp-NeedExp),
							BabyMap3 = maps:put(NextId, NewBaby, BabyMap2),
							NewBabyList2 = [NewBaby|NewBabyList],
							NewBabyList3 = lists:keyreplace(Id, #p_baby_order.id, NewBabyList2, Baby2),
							check_up_order(NewBaby, BabyMap3, NewBabyList3, RoleSt);
						false ->
							{maps:put(Id, Baby, BabyMap), NewBabyList}
					end;
				false ->
					case cfg_baby_order:find(Id, Order+1) of
						?nil ->
							{maps:put(Id, Baby, BabyMap), NewBabyList};
						_ ->
							Baby2 = Baby#p_baby_order{order=Order+1, exp=OldExp-NeedExp},
							#cfg_baby_order{skill=Skills, msgno=Msgno, name=Name} = cfg_baby_order:find(Id, Order+1),
							role_skill:active(Skills, RoleSt),
							BabyMap2 = maps:put(Id, Baby2, BabyMap),
							NewBabyList2 = lists:keyreplace(Id, #p_baby_order.id, NewBabyList, Baby2),
							#role_st{role=RoleID, name=RoleName} = RoleSt,
							?_if(Msgno>0, ?notify(Msgno, [{role, RoleID, RoleName}, Name, Order+1])),
							check_up_order(Baby2, BabyMap2, NewBabyList2, RoleSt)
					end
			end;
		false ->
			{maps:put(Id, Baby, BabyMap), NewBabyList}
	end.

%出生广播
notify_born(BabyList, RoleSt)->
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	lists:foreach(fun
			(Baby) ->
				#cfg_baby{name=BabyName} = cfg_baby:find(Baby#p_baby.gender),
				?notify(?MSG_BABY_BORN, [{role, RoleID, RoleName}, BabyName])
		end, BabyList).


update_figure(RoleSt)->
	#role_baby{is_hide=IsHide, figure=Figure} = role_data:get(?DB_ROLE_BABY),
	Figure2 = case IsHide of
		true  -> 0;
		false -> Figure
	end,
	role_figure:update_baby(Figure2, RoleSt).


calc_power(Item)->
	#p_item{id=ItemID, extra=Level, equip=Equip} = Item,
	#cfg_baby_equip{slot=Slot} = cfg_baby_equip:find(ItemID),
	#cfg_baby_equip_level{attr=Attr} = cfg_baby_equip_level:find(Slot, Level),
	StrongAttr = mod_attr:to_map(Attr),
	#p_equip{base=BaseAttr} = Equip,
	mod_attr:power( mod_attr:sum([BaseAttr, StrongAttr])).

p_baby_like(PBabyLike, Likes)->
	#p_baby_like{role_id=RoleID} = PBabyLike,
	{ok, BabyCache} = baby_server:get_baby(RoleID),
	State = case lists:member(RoleID, Likes) orelse BabyCache == ?nil of
		true  -> 1;
		false -> 0
	end,
	PBabyLike#p_baby_like{state=State}.

calc_attr() ->
	#role_baby{baby=Babies, order=BabyOrders, equips=Equips, wings=Wings} = role_data:get(?DB_ROLE_BABY),
 	Attr1 = maps:fold(fun
 			(_K, #p_baby{gender=Gender, level=Level}, Acc) ->
 				#cfg_baby_level{attr=Attr} = cfg_baby_level:find(Gender, Level),
 				mod_attr:add(Acc, Attr)
 		end, #{}, Babies),
 	Attr2 = maps:fold(fun
 			(_K, #p_baby_order{id=ID, order=Order}, Acc) ->
 				#cfg_baby_order{attr=Attr} = cfg_baby_order:find(ID, Order),
 				mod_attr:add(Acc, Attr)
 		end, #{}, BabyOrders),
 	Attr3 = maps:fold(fun
 			(_K, UId, Acc) ->
 				{ok, Item} = role_bag:get_item(UId),
 				#p_item{id=ItemID, extra=Level, equip=Equip} = Item,
 				#p_equip{base=Base} = Equip,
                #cfg_baby_equip{slot=Slot} = cfg_baby_equip:find(ItemID),
                #cfg_baby_equip_level{attr=Attr} = cfg_baby_equip_level:find(Slot, Level),
                mod_attr:sum([Acc, Base, mod_attr:to_map(Attr)])
 		end, #{}, Equips),
 	Attr4 = maps:fold(fun
 			(WingID, Level, Acc) ->
 				#cfg_baby_wing_star{attrs=Attrs} = cfg_baby_wing_star:find(WingID, Level),
 				mod_attr:sum([Acc, mod_attr:to_map(Attrs)])
 		end, #{}, Wings),
 	mod_attr:sum([Attr1, Attr2, Attr3, Attr4]).