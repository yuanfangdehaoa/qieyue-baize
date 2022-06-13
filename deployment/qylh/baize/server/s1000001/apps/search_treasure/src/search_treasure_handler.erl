%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(search_treasure_handler).

-include("bag.hrl").
-include("game.hrl").
-include("item.hrl").
-include("role.hrl").
-include("table.hrl").
-include("errno.hrl").
-include("enum.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").
-include("search_treasure.hrl").
-include("yunying.hrl").


%% API
-export([handle/3]).
-export([hook_reset/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%每日充值主题抽奖
hook_reset(_DoW, _Hour, _RoleSt)->
	RoleSearchTreasure = role_data:get(?DB_ROLE_SEARCHTREASURE),
	#role_searchtreasure{
		searchtreaure_item_maps = SearchTreasureItemMaps
	} = RoleSearchTreasure,
	SearchTreasureItemMaps2 = maps:fold(fun
			(TypeId, STItem, Acc) ->
				CfgYunying = cfg_yunying:find(TypeId),
				case CfgYunying of
					#cfg_yunying{type = 191} ->
						maps:put(TypeId, STItem, Acc);
					#cfg_yunying{} ->
						STItem2 = STItem#searchtreaure_item{bless_value=0, messages=[], turn=1},
						maps:put(TypeId, STItem2, Acc);
					_ ->
						maps:put(TypeId, STItem, Acc)
				end
		end, #{}, SearchTreasureItemMaps),
	role_data:set(RoleSearchTreasure#role_searchtreasure{searchtreaure_item_maps=SearchTreasureItemMaps2}).

handle(?SEARCHTREASURE_GETINFO, Tos, RoleSt) ->
	#m_searchtreasure_getinfo_tos{type_id = TypeId} = Tos,
	BatchId = get_batch_id(TypeId),
	RoleSearchTreasure = role_data:get(?DB_ROLE_SEARCHTREASURE),
	#role_searchtreasure{
		searchtreaure_item_maps = SearchTreasureItemMaps
	} = RoleSearchTreasure,
	STItem = case maps:get(TypeId, SearchTreasureItemMaps, ?nil) of
		SearchTreasureItem = #searchtreaure_item{}->
			SearchTreasureItem;
		_->
			#searchtreaure_item{
				  bless_value = 0
				, turn        = 1
				, messages    = []
			}
	end,
	#searchtreaure_item{bless_value=BlessValue, turn=Turn} = STItem,
	VipValue = get_first_bless(),
	Type =
		case cfg_yunying:find(TypeId) of
			#cfg_yunying{type = Type0} ->
				Type0;
			_ ->
				0
		end,
	{STItem2, ShowAdd}= case Turn==1 andalso BlessValue < VipValue andalso (lists:member(TypeId, [1,2,3,4])) andalso Type =/= 191 of
		true->
			{STItem#searchtreaure_item{bless_value=VipValue}, 1};
		false->
			{STItem, 0}
	end,
	#searchtreaure_item{bless_value=BlessValue2} = STItem2,
	SearchTreasureItemMaps2 =
		maps:put(TypeId, STItem2, SearchTreasureItemMaps),
	RoleSearchTreasure2 = RoleSearchTreasure#role_searchtreasure{
		searchtreaure_item_maps = SearchTreasureItemMaps2
	},
	role_data:set(RoleSearchTreasure2),
	Toc = #m_searchtreasure_getinfo_toc{
		type_id     = TypeId,
		batch_id    = BatchId,
		bless_value = BlessValue2,
		turn        = Turn,
		show_add    = ShowAdd
	},
	{ok, Toc, RoleSt};

handle(?SEARCHTREASURE_SEARCH, Tos, RoleSt) ->
	#m_searchtreasure_search_tos{type_id=TypeId, count=Times} = Tos,
	search_type(TypeId, Times, RoleSt);


%获取记录
handle(?SEARCHTREASURE_GETMESSAGES, Tos, RoleSt) ->
	#m_searchtreasure_getmessages_tos{type_id=TypeId, is_global=IsGlobal} = Tos,
	case IsGlobal of
		1->
			Messages = game_logger:get_logs({?MODULE, TypeId}),
			send_global_messages(TypeId, Messages, 0, IsGlobal);
		2->
			Messages = game_logger:get_logs({?MODULE, TypeId, rare}),
			send_global_messages(TypeId, Messages, 0, IsGlobal);
		0->
			#role_searchtreasure{searchtreaure_item_maps=SearchTreasureItemMaps} = role_data:get(?DB_ROLE_SEARCHTREASURE),
			case maps:get(TypeId, SearchTreasureItemMaps) of
				#searchtreaure_item{messages=Messages} ->
					send_messages(TypeId, Messages, 0, RoleSt);
				_ ->
					send_messages(TypeId, [], 0, RoleSt)
			end
	end;

%是否已抽中珍稀
handle(?SEARCHTREASURE_HAVE_RARE, Tos, RoleSt)->
	#m_searchtreasure_have_rare_tos{type_id=TypeId} = Tos,
	#role_searchtreasure{yy_rewards=YYRewards} = role_data:get(?DB_ROLE_SEARCHTREASURE),
	YYRewardList = maps:get(TypeId, YYRewards, []),
	HaveRare = not check_no_rare(YYRewardList),
	{ok, #m_searchtreasure_have_rare_toc{have_rare=HaveRare, type_id=TypeId}, RoleSt};

%一键取出
handle(?SEARCHTREASURE_FETCH, _Tos, RoleSt) ->
	#role_bag{cells=Cells, items=Items} = role_data:get(?DB_ROLE_BAG),
	#cell{used = Used} = maps:get(?BAG_ID_HUNT, Cells),
	%获取背包空格子数
	EmptyNum = role_bag:get_empty(?BAG_ID_MAIN),
	case length(Used) =< EmptyNum of
		true->
			AddItems = lists:foldl(fun
				(CellId, ItemList) ->
					#p_item{num=Num} = maps:get(CellId, Items),
					[{CellId, Num} | ItemList]
			end, [], Used),
			role_bag:move(?BAG_ID_HUNT, ?BAG_ID_MAIN, AddItems, RoleSt);
		false->
			Used2 = lists:reverse(Used),
			Used3 = lists:sublist(Used2, 1, EmptyNum),
			AddItems = lists:foldl(fun
					(CellId, ItemList) ->
						#p_item{num=Num} = maps:get(CellId, Items),
						[{CellId, Num} | ItemList]
				end, [], Used3),
			role_bag:move(?BAG_ID_HUNT, ?BAG_ID_MAIN, AddItems, RoleSt),
			#role_st{role=RoleId} = RoleSt,
			?notify(RoleId, ?MSG_SEARCHTREASURE_BAG_FULL, [])
	end,
	{ok, RoleSt};

%%是否领取钥匙的信息
handle(?SEARCHTREASURE_GET_KEY_INFO,_Tos,RoleSt) ->
	RoleSearch = role_data:get(?DB_ROLE_SEARCHTREASURE),
	#role_searchtreasure{get_key_timestamp = KeyTimes} = RoleSearch,
	NowTimes = ut_time:seconds(),
	Res = ?_if(ut_time:is_same_date(KeyTimes,NowTimes), 1, 0 ),
	?ucast(#m_searchtreasure_get_key_info_toc{res = Res});

%%领取钥匙
handle(?SEARCHTREASURE_GET_KEY,_Tos,RoleSt) ->
	RoleSearch = role_data:get(?DB_ROLE_SEARCHTREASURE),
	#role_searchtreasure{get_key_timestamp = KeyTimes} = RoleSearch,
	NowTimes = ut_time:seconds(),
	case ut_time:is_same_date(KeyTimes,NowTimes) of
		true -> throw(?err(?ERR_MCHUNT_GET_KEY_ERROR));
		false ->
			role_bag:gain([{11006,10,1}],?LOG_MCHUNT_GET_KEY,RoleSt),  %%寻宝钥匙
			RoleMcHunt2 = RoleSearch#role_searchtreasure{get_key_timestamp = NowTimes},
			role_data:set(RoleMcHunt2),
			?ucast(#m_searchtreasure_get_key_toc{res = 1})
	end.


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
get_batch_id(TypeId)->
	#role_info{level = Level} = role_data:get(?DB_ROLE_INFO),
	OpenDays = game_env:get_opened_days(),
	BatchIds = cfg_searchtreasure_batch:find_type(TypeId),
	BatchIds2 = lists:filter(fun
			(BatchId) ->
				#cfg_searchtreasure_batch{
					open_server_days = {MinDay, MaxDay},
					player_level     = {MinLevel, MaxLevel}
				} = cfg_searchtreasure_batch:find(BatchId),
				OpenDays >= MinDay andalso
				OpenDays =< MaxDay andalso
				Level >= MinLevel andalso
				Level =< MaxLevel
		end, BatchIds),
	case length(BatchIds2) > 0 of
		true  -> lists:nth(1, BatchIds2);
		false -> 0
	end.

%根据类型寻宝
%装备寻宝
search_type(TypeId, Times, RoleSt) when TypeId == 1; TypeId == 2; TypeId == 3; TypeId == 4 ->
	#role_bag{cells=Cells} = role_data:get(?DB_ROLE_BAG),
    #cell{unused=Unused} = maps:get(?BAG_ID_HUNT, Cells),
    ?_check(length(Unused) >= Times, ?ERR_SEARCHTREASURE_STORAGE_NOT_ENOUGH),
    BatchId = get_batch_id(TypeId),
    ?_check(BatchId /= 0, ?ERR_SEARCHTREASURE_BATCH_WRONG),
	SearchTreasureBatch = cfg_searchtreasure_batch:find(BatchId),
	#cfg_searchtreasure_batch{cost=Cost, gain=Gain} = SearchTreasureBatch,
	Gain2 = [{ItemId, Num*Times}|| {ItemId, Num} <- Gain],
	case lists:keyfind(Times, 1, Cost) of
		false->
			throw(?err(?ERR_SEARCHTREASURE_TIMES_WRONG));
		{_, ItemId, Num} ->
			role_bag:cost([{ItemId, Num}], ?LOG_TREASURE_SEARCH, RoleSt),
			RoleSearchTreasure = role_data:get(?DB_ROLE_SEARCHTREASURE),
			#role_searchtreasure{searchtreaure_item_maps=SearchTreasureItemMaps, equips=Equips} = RoleSearchTreasure,
			Equips2 = case TypeId == 1 of
				true  -> Equips;
				false -> []
			end,
			SearchTreasureItem = maps:get(TypeId, SearchTreasureItemMaps),
			{RewardIds, Items, NewSearchTreasureItem, Equips3} =
			search(TypeId, BatchId, Times, SearchTreasureBatch, SearchTreasureItem, [], [], RoleSt, Equips2),
			Gain3 = lists:merge(Gain2, Items),
			role_bag:gain(Gain3, ?LOG_TREASURE_SEARCH, RoleSt),
			SearchTreasureItemMaps2 = maps:put(TypeId, NewSearchTreasureItem, SearchTreasureItemMaps),
			RoleSearchTreasure2 = RoleSearchTreasure#role_searchtreasure{
				searchtreaure_item_maps=SearchTreasureItemMaps2,
				equips = ?_if(TypeId == 1, Equips3, Equips)
			},
			role_data:set(RoleSearchTreasure2),
			?ucast(#m_searchtreasure_search_toc{type_id=TypeId, reward_ids=RewardIds}),
			#searchtreaure_item{bless_value=NewBlessValue, turn=Turn} = NewSearchTreasureItem,
			send_info(TypeId, BatchId, NewBlessValue, Turn, RoleSt),
			Event = case TypeId of
				1 -> ?EVENT_SEARCH_TREASURE;
				2 -> ?EVENT_SEARCH_TOP;
				3 -> ?EVENT_SEARCH_MECHA;
				_ -> 0
			end,
			?_if(Event > 0, role_event:event(Event, Times))
	end;

%主题寻宝(typeId:YYID, acttype=5(主题寻宝), acttype=701(小R活动), acttype=191(限时寻宝))
search_type(TypeId, Times, RoleSt)->
	?_check(yunying:is_start(TypeId), ?ERR_YUNYING_NOT_START),
	CfgYunying = cfg_yunying:find(TypeId),
	?_check(CfgYunying /= ?nil, ?ERR_SEARCHTREASURE_TYPE_WRONG),
	#cfg_yunying{reqs=Reqs, type=ActType} = CfgYunying,
	case ActType of
		191 ->
			EmptyNum = role_bag:get_empty(?BAG_ID_MAIN),
			EmptyNumArtifact = role_bag:get_empty(?BAG_ID_ARTIFACT),
			?_check(EmptyNumArtifact >= Times, ?ERR_SEARCHTREASURE_BAG_NOT_ENOUGH);
		_ ->
			EmptyNum = role_bag:get_empty(?BAG_ID_MAIN)
	end,
  ?_check(EmptyNum >= Times, ?ERR_SEARCHTREASURE_BAG_NOT_ENOUGH),
	RoleSearchTreasure = role_data:get(?DB_ROLE_SEARCHTREASURE),
	#role_searchtreasure{searchtreaure_item_maps=SearchTreasureItemMaps, yy_rewards=YYRewards} = RoleSearchTreasure,
	SearchTreasureItem = maps:get(TypeId, SearchTreasureItemMaps,
		#searchtreaure_item{bless_value=0, turn=0, messages=[]}),
	#searchtreaure_item{bless_value=BlessValue} =  SearchTreasureItem,
	Count = BlessValue,
	case ActType == 701 of
		true ->
			MaxCount = cfg_yunying_lottery_rewards:max(TypeId),
			?_check(Count < MaxCount, ?ERR_SEARCHTREASURE_TIMES_WRONG);
		false ->
			ignore
	end,
	Cost = get_cost(Reqs, Times, Count),
	?_check(length(Cost) > 0, ?ERR_SEARCHTREASURE_NO_COST),
	role_bag:cost(Cost, ?LOG_TREASURE_SEARCH_YY, RoleSt),
	YYRewardList = case Count == 0 of
			true  -> [];
			false -> maps:get(TypeId, YYRewards, [])
	end,
	case ActType == 701 of
		true  -> ?_check(check_no_rare(YYRewardList), ?ERR_SEARCHTREASURE_TIMES_WRONG);
		false -> ignore
	end,
	{RewardIds, Items, NewSearchTreasureItem, YYRewardList2}
	= search_yy(TypeId, Times, Count, SearchTreasureItem, YYRewardList, [], [], RoleSt),
	role_bag:gain(Items, ?LOG_TREASURE_SEARCH, RoleSt),
	SearchTreasureItemMaps2 = maps:put(TypeId, NewSearchTreasureItem, SearchTreasureItemMaps),
	YYRewards2 = maps:put(TypeId, YYRewardList2, YYRewards),
	RoleSearchTreasure2 = RoleSearchTreasure#role_searchtreasure{
		searchtreaure_item_maps=SearchTreasureItemMaps2,
		yy_rewards=YYRewards2
	},
	role_data:set(RoleSearchTreasure2),
	?ucast(#m_searchtreasure_search_toc{type_id=TypeId, reward_ids=RewardIds}),
	#searchtreaure_item{bless_value=NewBlessValue, turn=Turn} = NewSearchTreasureItem,
	send_info(TypeId, 0, NewBlessValue, Turn, RoleSt),
	case ActType of
		5   -> role_event:event(?EVENT_YY_SEARCH, Times);
		191 -> role_event:event(?EVENT_INTEGRAL, Times);
		_   -> ignore
	end.

get_cost([], _Times, _Count)->
	[];
get_cost([Req|T], Times, Count)->
	case Req of
		{cost, Cost} ->
			{_, _, FreeNum} = lists:keyfind(1, 1, Cost),
			{_, ItemId, Num} = lists:keyfind(Times, 1, Cost),
			Num2 = case Count == 0 of
				true  -> Num - FreeNum;
				false -> Num
			end,
			[{ItemId, Num2}];
		_ ->
			get_cost(T, Times, Count)
	end.


get_group([], _Count) ->
	1;
get_group([Req|T], Count) ->
	case Req of
		{groups, GroupList} ->
			GroupList2 = lists:reverse(lists:sort(GroupList)),
			get_group2(GroupList2, Count);
		_ ->
			get_group(T, Count)
	end.

get_group2([], _Count) ->
	1;
get_group2([Gruop|_T] = L, Count) ->
	get_group2(L, Count, Gruop).

get_group2([Group|T], Count, _Acc) ->
	case Count >= Group andalso Count rem Group == 0 of
		true ->
			Group;
		false ->
			get_group2(T, Count, Group)
	end.


%主题寻宝
search_yy(_TypeId, 0, _Count, SearchTreasureItem, YYRewardList, RewardIds, Items, _RoleSt)->
	{RewardIds, Items, SearchTreasureItem, YYRewardList};
search_yy(TypeId, Times, Count, SearchTreasureItem, YYRewardList, RewardIds, Items, RoleSt) ->
	#searchtreaure_item{messages=Messages} = SearchTreasureItem,
	Count2 = Count+1,
	Pools = get_yy_rewards_pool(TypeId, Count2, YYRewardList),
	RewardId = ut_rand:weight(Pools),
	#cfg_yunying_lottery_rewards{rewards=Rewards, is_rare=IsRare, is_broadcast=IsBroadCast,
	is_self=IsSelf, is_all=IsAll} = cfg_yunying_lottery_rewards:find(RewardId),
	RewardIds2 = [RewardId | RewardIds],
	YYRewardList2 = [RewardId | YYRewardList],
	[Rewards2] = Rewards,
	{ItemId, Num, Opts} = format_rewards2(Rewards2),
	%Item = item_util:new_item(ItemId, Num, Opts),
	Items2 = [{ItemId, Num, Opts} | Items],
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	MessageItem = #p_searchtreasure_message_item{type_id=TypeId, name=RoleName, item_id=ItemId, num=Num},
	%历史大奖(全服的)
	case IsRare == 1 of
		true ->
			MessageItem2 = MessageItem#p_searchtreasure_message_item{time=ut_time:seconds(), count=Count2},
		    game_logger:add_log({?MODULE, TypeId, rare}, MessageItem2),
		    send_global_messages(TypeId, [MessageItem2], 1, 2);
		false ->
			ignore
	end,
	%个人记录
	Messages3 = case IsSelf == 1 of
		true ->
			Messages2 = case length(Messages) > 50 of
		    	true-> lists:nthtail(2, Messages);
		    	false-> Messages
		    end,
		    send_messages(TypeId, [MessageItem], 1, RoleSt),
		    [MessageItem | Messages2];
		false ->
			Messages
	end,
	SearchTreasureItem2 = SearchTreasureItem#searchtreaure_item{messages=Messages3, bless_value=Count2},
	%全服记录
	case IsAll == 1 of
		true ->
			%增加全服记录
		    game_logger:add_log({?MODULE, TypeId}, MessageItem),
		    send_global_messages(TypeId, [MessageItem], 1);
		false ->
			ignore
	end,
	%广播
	case IsBroadCast > 0 of
		true ->
			case IsBroadCast of
				170005 ->
					#cfg_yunying{name=YYName} = cfg_yunying:find(TypeId),
					Panel = cfg_yunying:panel(TypeId),
					ItemMap = maps:put(ItemId, Num, #{}),
					?notify(IsBroadCast, [
						{role, RoleID, RoleName},
						YYName,
						{item, ItemMap},
						Panel
					]);
				_ ->
					#cfg_yunying{name=YYName} = cfg_yunying:find(TypeId),
					ItemMap = maps:put(ItemId, Num, #{}),
					?notify(IsBroadCast, [
						{role, RoleID, RoleName},
						YYName,
						{item, ItemMap}
					])
			end;
		false ->
			ignore
	end,
	search_yy(TypeId, Times-1, Count2, SearchTreasureItem2, YYRewardList2, RewardIds2, Items2, RoleSt).

search(_TypeId, _BatchId, 0, _SearchTreasureBatch, SearchTreasureItem, RewardIds, Items, _RoleSt, Equips) ->
	{RewardIds, Items, SearchTreasureItem, Equips};
search(TypeId, BatchId, Times, SearchTreasureBatch, SearchTreasureItem, RewardIds, Items, RoleSt, Equips) ->
	#cfg_searchtreasure_batch{first_bless_value=FirstAddBlessValue, bless_value=AddBlessValue,
	max_bless_value=MaxBlessValue} = SearchTreasureBatch,
	#searchtreaure_item{bless_value=BlessValue, messages=Messages, turn=Turn} = SearchTreasureItem,
	BlessList = case Turn==1 of
		true ->
			FirstAddBlessValue;
		false->
			AddBlessValue
	end,
	AddValue = ut_rand:weight(BlessList),
	NewBlessValue = BlessValue + AddValue,
	NewTimes = Times - 1,
	%获得物品
	OnlyRare = case NewBlessValue >= MaxBlessValue of
		true->true;
		false->false
	end,
	RewardPool = get_rewards_pool(BatchId, NewBlessValue, OnlyRare, TypeId, Equips),
	RewardId = ut_rand:weight(RewardPool),
	#cfg_searchtreasure_rewards{rewards=Rewards, is_rare=IsRare, is_broadcast=IsBroadCast, is_notice=IsNotice} =
	cfg_searchtreasure_rewards:find(RewardId),
	RewardIds2 = [RewardId | RewardIds],
	{ItemId, Num, Opts} = format_rewards(?BAG_ID_HUNT, Rewards),
	%Item = item_util:new_item(ItemId, Num, Opts),
	Items2 = [{ItemId, Num, Opts} | Items],
	%祝福值清0
	VipValue = get_vip_bless(),
	Equips2 = case IsRare==1 of
		true->
			SearchTreasureItem2 = SearchTreasureItem#searchtreaure_item{turn=Turn+1, bless_value=VipValue},
			case TypeId == 1 andalso length(Equips) < 3 of
				true  -> [ItemId | Equips];
				false -> Equips
			end;
		false->
			case NewBlessValue >= MaxBlessValue of
				true->
					NewBlessValue2 = NewBlessValue - MaxBlessValue + VipValue,
					SearchTreasureItem2 = SearchTreasureItem#searchtreaure_item{turn=Turn+1, bless_value=NewBlessValue2};
				false->
					SearchTreasureItem2 = SearchTreasureItem#searchtreaure_item{bless_value=NewBlessValue}
			end,
			Equips
    end,
    SearchTreasureItem3 = case IsNotice == 1 of
    	true->
    		#role_st{role=RoleID, name=RoleName} = RoleSt,
		    MessageItem = #p_searchtreasure_message_item{type_id=TypeId, name=RoleName, item_id=ItemId, num=Num},
		    Messages2 = case length(Messages) > 50 of
		    	true-> lists:nthtail(2, Messages);
		    	false-> Messages
		    end,
		    Messages3 = [MessageItem | Messages2],
		    send_messages(TypeId, [MessageItem], 1, RoleSt),
		    %传闻
		    case IsBroadCast==1 of
		    	true->
		    		%增加全服记录
		    		game_logger:add_log({?MODULE, TypeId}, MessageItem),
		    		send_global_messages(TypeId, [MessageItem], 1),
		    		%广播
		    		ItemMap = maps:put(ItemId, Num, #{}),
		    		MsgNo = case TypeId of
		    			1 -> ?MSG_SEARCHTREASURE_BROADCAST;
		    			2 -> ?MSG_SEARCHTREASURE_BROADCAST2;
		    			3 -> ?MSG_SEARCHTREASURE_BROADCAST3;
		    			4 -> ?MSG_SEARCHTREASURE_BROADCAST4
		    		end,
		    		?notify(MsgNo, [
		    			{role, RoleID, RoleName},
		    			{item, ItemMap}
		    		]);
		    	false->
		    		ignor
		    end,
		    SearchTreasureItem2#searchtreaure_item{messages = Messages3};
		false->SearchTreasureItem2
    end,
    search(TypeId, BatchId, NewTimes, SearchTreasureBatch, SearchTreasureItem3, RewardIds2, Items2, RoleSt, Equips2).


format_rewards(BagId, Rewards)->
	#role_info{career=Career} = role_data:get(?DB_ROLE_INFO),
	Opts = #{bagid=>BagId},
	{ItemId2, Num2, Opts2} = case Rewards of
		{ItemId, Num} ->
			{ItemId, Num, Opts};
		{ItemId, Num, Bind} ->
			{ItemId, Num, maps:put(bind, item_util:calc_bind(Bind), Opts)};
		_ ->
			throw(?err(?ERR_SEARCHTREASURE_REWARDS_WRONG))
	end,
	ItemId3 = case is_list(ItemId2) of
		true  -> lists:nth(Career, ItemId2);
		false -> ItemId2
	end,
	{ItemId3, Num2, Opts2}.

format_rewards2(Rewards)->
	#role_info{career=Career} = role_data:get(?DB_ROLE_INFO),
	Opts = #{},
	{ItemId2, Num2, Opts2} = case Rewards of
		{ItemId, Num} ->
			{ItemId, Num, Opts};
		{ItemId, Num, Bind} ->
			{ItemId, Num, maps:put(bind, item_util:calc_bind(Bind), Opts)};
		_ ->
			throw(?err(?ERR_SEARCHTREASURE_REWARDS_WRONG))
	end,
	ItemId3 = case is_list(ItemId2) of
		true  -> lists:nth(Career, ItemId2);
		false -> ItemId2
	end,
	{ItemId3, Num2, Opts2}.


%获取奖池
get_rewards_pool(BatchId, BlessValue, OnlyRare, TypeId, Equips) ->
	RewardIds = cfg_searchtreasure_rewards:find_ids_by_batchid(BatchId),
	RewardIds2 =case OnlyRare of
		true->
			lists:filter(fun
					(RewardId) ->
						#cfg_searchtreasure_rewards{is_rare=IsRare} = cfg_searchtreasure_rewards:find(RewardId),
						IsRare==1
				end, RewardIds);
		false->
			RewardIds
	end,
	lists:foldl(fun
			(RewardId, RewardList) ->
				Reward = cfg_searchtreasure_rewards:find(RewardId),
				#cfg_searchtreasure_rewards{prob=ProbList, rewards=Rewards} = Reward,
				case TypeId == 1 andalso length(Equips) < 3 of
					true ->
						EquipID2 = case Rewards of
							{EquipID, _}    -> EquipID;
							{EquipID, _, _} -> EquipID
						end,
						case not lists:member(EquipID2, Equips) of
							true ->
								get_rewards_pool2(RewardId, ProbList, BlessValue, RewardList);
							false->
								RewardList
						end;
					false ->
						get_rewards_pool2(RewardId, ProbList, BlessValue, RewardList)
				end
		end, [], RewardIds2).

get_rewards_pool2(RewardId, ProbList, BlessValue, RewardList)->
	NewProbList = lists:filter(fun
			({Min, Max, _Prob}) ->
				BlessValue >= Min andalso BlessValue =< Max
		end, ProbList),
	case length(NewProbList) > 0 of
		true->
			{_Min, _Max, Prob} = lists:nth(1, NewProbList),
			[{RewardId, Prob}|RewardList];
		false->
			Length = length(ProbList),
			{_Min, Max, Prob} = lists:nth(Length, ProbList),
			case BlessValue > Max of
				true->[{RewardId, Prob}|RewardList];
				false->RewardList
			end
	end.


%获取主题抽奖奖池
get_yy_rewards_pool(YYID, NowCount, YYRewardList)->
	{B, Group, Level} =
		case cfg_yunying:find(YYID) of
		#cfg_yunying{type = 191, reqs = Reqs} ->
			#role_info{level = RoleLv} = role_data:get(?DB_ROLE_INFO),
			{true, get_group(Reqs, NowCount), RoleLv};
		_ ->
			{false, 1, world_level:get_level()}
	end,
	Ids = cfg_yunying_lottery_rewards:ids(YYID, Group, Level),
	{_, Pools} = lists:foldl(fun
			(Id, {Flag, Acc}) ->
				case Flag of
					false ->
						#cfg_yunying_lottery_rewards{prob=Prob, absolute=Absolute}
						= cfg_yunying_lottery_rewards:find(Id),
						{Min, Max, Plus, Weight} = Prob,
						Weight2 = case NowCount >= Min of
							true ->
								case NowCount =< Max of
									true ->
										case B of
											true ->
												Weight + Plus;
											false ->
												case not lists:member(Id, YYRewardList) of
													true -> Weight + Plus;
													false -> 0
												end
										end;
									false ->
										Weight
								end;
							false ->
								0
						end,
						case Weight2 > 0 of
							true ->
								case Absolute > 0 andalso NowCount == Absolute of
									true  -> {true, [{Id, Weight2}]};
									false -> {Flag, [{Id, Weight2}|Acc]}
								end;
							false ->
								{Flag, Acc}
						end;
					true ->
						{true, Acc}
				end
		end, {false, []}, Ids),
	Pools.

%获取首轮vip祝福值加成
get_first_bless()->
	VipLv = role_vip:get_level(),
	case VipLv >= 4 of
		true->
			cfg_vip_rights:find(?VIP_RIGHTS_SEARCH_TREASURE, 4, 0);
		false->
			0
	end.

%获取vip祝福值加成
get_vip_bless()->
	VipLv = role_vip:get_level(),
	case VipLv >= 5 of
		true->
			cfg_vip_rights:find(?VIP_RIGHTS_SEARCH_TREASURE, VipLv, 0);
		false->
			0
	end.

check_no_rare([])->
	true;
check_no_rare([RewardID | RewardList])->
	#cfg_yunying_lottery_rewards{is_rare=IsRare} = cfg_yunying_lottery_rewards:find(RewardID),
	case IsRare == 1 of
		true  -> false;
		false -> check_no_rare(RewardList)
	end.


%获取当前抽奖次数
% get_yy_count(YYActID, RoleID)->
% 	YYRole = yunying_agent:get_yy_role(YYActID, RoleID),
% 	#yy_role{tasks=Tasks} = YYRole,
% 	Lists = maps:values(Tasks),
% 	case length(Lists) > 0 of
% 		true ->
% 			#yy_task{count=Count} = lists:nth(1, Lists),
% 			Count;
% 		false ->
% 			0
% 	end.

%发送基本信息
send_info(TypeId, BatchId, BlessValue, Turn, RoleSt)->
	?ucast(#m_searchtreasure_getinfo_toc{
		  type_id     = TypeId
		, batch_id    = BatchId
		, bless_value = BlessValue
		, turn        = Turn
	}).


%广播全服记录(Global:1(普通全服记录)，2(历史大奖))
send_global_messages(TypeId, Messages, IsAddNew)->
	?bcast(#m_searchtreasure_getmessages_toc{type_id=TypeId, is_global=1, messages=Messages, is_add_new=IsAddNew}).

send_global_messages(TypeId, Messages, IsAddNew, Global)->
	?bcast(#m_searchtreasure_getmessages_toc{type_id=TypeId, is_global=Global, messages=Messages, is_add_new=IsAddNew}).

%发送个人记录
send_messages(TypeId, Messages, IsAddNew, RoleSt)->
	?ucast(#m_searchtreasure_getmessages_toc{type_id=TypeId, is_global=0, messages=Messages, is_add_new=IsAddNew}).
