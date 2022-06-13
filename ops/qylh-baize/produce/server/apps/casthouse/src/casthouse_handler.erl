%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(casthouse_handler).

-include("table.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("errno.hrl").
-include("msgno.hrl").
-include("casthouse.hrl").
-include("log.hrl").
-include("game.hrl").
-include("role.hrl").
-include("bag.hrl").


%% API
-export([handle/3]).
-export([hook_reset/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
handle(?CASTHOUSE_INFO, _Tos, RoleSt)->
	RoleCastHouse = role_data:get(?DB_ROLE_CASTHOUSE),
	#role_casthouse{grid=Grid, turn=Turn, num=Num} = RoleCastHouse,
	Count = role_count:get_times(?ROLE_COUNT_CASTHOUSE),
	ResetCount = role_count:get_times(?ROLE_COUNT_CASTHOUSE_RESET),
	SeziCount = role_count:get_times(?ROLE_COUNT_CASTHOUSE_FREE),
	Toc = #m_casthouse_info_toc{
		grid        = Grid, 
		count       = Count, 
		reset_count = ResetCount,
		sezi_count  = SeziCount,
		turn        = Turn,
		num         = Num
	},
	{ok, Toc, RoleSt};

handle(?CASTHOUSE_START, _Tos, RoleSt)->
	RoleCastHouse = role_data:get(?DB_ROLE_CASTHOUSE),
	#role_casthouse{grid=Grid, num=OldNum, turn=Turn} = RoleCastHouse,
	check_start(Grid),
	?_check(OldNum == 0, ?ERR_CASTHOUSE_PRE_NOT_END),
	EmptyNum = role_bag:get_empty(?BAG_ID_MAIN),
	?_check(EmptyNum >= 8, ?ERR_CASTHOUSE_BAG_NOTENOUGH),
	Count = role_count:get_times(?ROLE_COUNT_CASTHOUSE_FREE),
	#cfg_casthouse{free_count=FreeCount, cost=Cost, pp=PPList} = cfg_casthouse:find(1),
	Count2 = case Count < FreeCount of
		true  -> 
			role_count:add_times(?ROLE_COUNT_CASTHOUSE_FREE),
			Count+1;
		false -> 
			role_bag:cost(Cost, ?LOG_CASTHOUSE_MOVE_COST, RoleSt),
			Count
	end,
	%计算色子
	WeightList2 = case lists:keyfind(Turn, 1, PPList) of
		false ->
			{_, WeightList} = lists:last(PPList),
			WeightList;
		{_, WeightList} ->
			WeightList
	end,
	Num = ut_rand:weight(WeightList2),
	role_data:set(RoleCastHouse#role_casthouse{num=Num}),
	{ok, #m_casthouse_start_toc{num=Num, sezi_count=Count2}, RoleSt};

handle(?CASTHOUSE_REWARD, _Tos, RoleSt)->
	RoleCastHouse = role_data:get(?DB_ROLE_CASTHOUSE),
	#role_casthouse{grid=Grid, turn=Turn, num=Num} = RoleCastHouse,
	#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
	?_check(not is_max_grid(Grid), ?ERR_CASTHOUSE_MAX_GRID),
	{Grid2, Num2, ItemIds2}= case Num > 0 of
		true ->
			TmpNum = Num -1,
			Cfg = cfg_casthouse_grid:find(Grid+1),
			case Cfg == ?nil of
				true -> %走到尽头
					{Grid, 0, []};
				false->
					#cfg_casthouse_grid{drop=Drop, prob=Prob} = cfg_casthouse_grid:find(Grid+1),
					%是否暴击
					Index = ut_rand:random(1, 10000),
					Count = case Prob>=1 andalso Prob=<Index of
						true  -> 2;
						false -> 1
					end,
					Drop2 = get_drop_ids(Turn, Drop, Count, []),
					Gain = creep_drop:calc(Level, Drop2),
					{ok, OBtain} = role_bag:gain(Gain, ?LOG_CASTHOUSE_REWARD, RoleSt),
					ItemIds = get_reward_items(OBtain),
					{Grid + 1, TmpNum, ItemIds}
			end;
		false ->
			{Grid, Num, []}
	end,
	?_if(is_max_grid(Grid2), role_count:add_times(?ROLE_COUNT_CASTHOUSE)),
	role_data:set(RoleCastHouse#role_casthouse{grid=Grid2, num=Num2}),
	{ok, #m_casthouse_reward_toc{grid=Grid2, item_ids=ItemIds2}, RoleSt};

handle(?CASTHOUSE_RESET, _Tos, RoleSt)->
	RoleCastHouse = role_data:get(?DB_ROLE_CASTHOUSE),
	#role_casthouse{turn=Turn, grid=Grid} = RoleCastHouse,
	Count = role_count:get_times(?ROLE_COUNT_CASTHOUSE),
	?_check(Count > 0 orelse is_max_grid(Grid), ?ERR_CASTHOUSE_CANNOT_RESET),
	?_if(Count > 0, role_count:del_times(?ROLE_COUNT_CASTHOUSE)),
	VipLevel = role_vip:get_level(),
	ResetCount = role_count:get_times(?ROLE_COUNT_CASTHOUSE_RESET),
	MaxResetCount = cfg_vip_rights:find(?VIP_RIGHTS_CAST_RESET, VipLevel, 0),
	?_check(ResetCount < MaxResetCount, ?ERR_CASTHOUSE_MAX_RESET),
	role_count:add_times(?ROLE_COUNT_CASTHOUSE_RESET),
	SeziCount = role_count:get_times(?ROLE_COUNT_CASTHOUSE_FREE),
	#cfg_casthouse{reset_cost=Cost} = cfg_casthouse:find(1),
	role_bag:cost(Cost, ?LOG_CASTHOUSE_RESET_COST, RoleSt),
	role_data:set(RoleCastHouse#role_casthouse{turn=Turn+1,grid=0,num=0}),
	Toc = #m_casthouse_info_toc{
		grid        = 0, 
		count       = 0, 
		reset_count = ResetCount+1,
		sezi_count  = SeziCount,
		turn        = Turn+1,
		num         = 0
	},
	?ucast(Toc),
	{ok, #m_casthouse_reset_toc{}, RoleSt}.


hook_reset(_DoW, _Hour, _RoleSt)->
	RoleCastHouse = role_data:get(?DB_ROLE_CASTHOUSE),
	role_data:set(RoleCastHouse#role_casthouse{grid=0, turn=1, num=0}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%检查是否可以扔色子
check_start(Grid)->
	Count = role_count:get_times(?ROLE_COUNT_CASTHOUSE),
	?_check(Count =< 0, ?ERR_CASTHOUSE_CANNOT_START),
	Cfg = cfg_casthouse_grid:find(Grid+1),
	?_check(Cfg /= ?nil, ?ERR_CASTHOUSE_MAX_GRID).

%是否走到最后
is_max_grid(Grid)->
	Cfg = cfg_casthouse_grid:find(Grid+1),
	case Cfg of
		?nil -> true;
		_    -> false
	end.

%获取掉落包
get_drop_ids(_Turn, _Drop, 0, Result)->
	Result;
get_drop_ids(Turn, Drop, Count, Result)->
	Drop3 = case lists:keyfind(Turn, 1, Drop) of
		false -> 
			{_, Drop2} =lists:last(Drop),
			Drop2;
		{_, Drop2} ->
			Drop2
	end,
	get_drop_ids(Turn, Drop, Count-1, lists:merge(Result, Drop3)).



get_reward_items(OBtain)->
	maps:fold(fun 
			(ItemId, _, Acc) -> 
				[ItemId | Acc]
		end, [], OBtain).

