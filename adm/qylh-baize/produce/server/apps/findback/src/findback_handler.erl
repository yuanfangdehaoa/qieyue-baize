%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(findback_handler).

-include("game.hrl").
-include("findback.hrl").
-include("role.hrl").
-include("table.hrl").
-include("log.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("msgno.hrl").
-include("item.hrl").
-include("task.hrl").

%% API
-export([handle/3]).
-export([hook_reset/3]).
-export([hook_login/1]).
-export([notify/4]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%获取信息
handle(?FINDBACK_INFO, _Tos, RoleSt)->
	#role_findback{lists=Lists, level=Level, floors=Floors} = role_data:get(?DB_ROLE_FINDBACK),
	{ok, #m_findback_info_toc{lists=Lists,level=Level,floors=Floors}, RoleSt};


%按次找回
handle(?FINDBACK_FIND, Tos, RoleSt)->
	#m_findback_find_tos{key=Key, type_id=TypeId, count=Count} = Tos,
	CfgFindBack = cfg_findback:find(Key),
	?_check(CfgFindBack /= ?nil, ?ERR_FINDBACK_DATA_NOT_EXIST),
	RoleFindBack = role_data:get(?DB_ROLE_FINDBACK),
	#role_findback{lists=Lists, level=Level, floors=Floors} = RoleFindBack,
	PFindback =  lists:keyfind(Key, 2, Lists),
	?_check(PFindback /= false, ?ERR_FINDBACK_KEY_WRONG),
	%检查次数是否正确
	TotalCount = get_total_count(TypeId, PFindback, true),
	?_check(Count =< TotalCount, ?ERR_FINDBACK_COUNT_WRONG),
	{Cost, Gain, PFindback2} = find_back(TypeId, Count, Level, Floors, CfgFindBack, PFindback),
	role_bag:deal(Cost, Gain, ?LOG_FINDBACK_FIND_REWARDS, RoleSt),
	Lists2 = lists:keyreplace(Key, 2, Lists, PFindback2),
	role_data:set(RoleFindBack#role_findback{lists=Lists2}),
	?ucast(#m_findback_info_toc{lists=[PFindback2]}),
	{ok, #m_findback_find_toc{}, RoleSt};

%一键找回
handle(?FINDBACK_FIND_ALL, Tos, RoleSt)->
	#m_findback_find_all_tos{type_id=TypeId, extra=Extra} = Tos,
	RoleFindBack = role_data:get(?DB_ROLE_FINDBACK),
	#role_findback{lists=Lists, level=Level, floors=Floors} = RoleFindBack,
	{Cost2, Gain2, Lists2} = lists:foldl(fun 
			(PFindback, {ACost, AGain, ALists}) -> 
				#p_findback{key=Key} = PFindback,
				TotalCount = get_total_count(TypeId, PFindback, Extra),
				case TotalCount > 0 of
					true ->
						CfgFindBack = cfg_findback:find(Key),
						{Cost, Gain, PFindback2} = find_back(TypeId, TotalCount, Level, Floors, CfgFindBack, PFindback),
						{lists:merge(ACost, Cost), lists:merge(AGain, Gain), lists:keyreplace(Key, 2, ALists, PFindback2)};
					false ->
						{ACost, AGain, ALists}
				end
		end, {[], [], Lists}, Lists),
	role_bag:deal(Cost2, Gain2, ?LOG_FINDBACK_FIND_REWARDS, RoleSt),
	role_data:set(RoleFindBack#role_findback{lists=Lists2}),
	?ucast(#m_findback_info_toc{lists=Lists2}),
	{ok, #m_findback_find_all_toc{}, RoleSt}.

%在计数器重置前调用
hook_reset(LstSecs, NowSecs, RoleSt)->
	{NowDate, _} = ut_time:seconds_to_datetime(NowSecs),
	RstSecs = ut_time:datetime_to_seconds({NowDate, {0,0,0}}),
	NeedRst = LstSecs < RstSecs andalso RstSecs =< NowSecs,
	case NeedRst of
		true ->
			DiffDays = ut_time:diff_days(LstSecs, NowSecs),
			#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
			case role_misc:is_sys_open(findback_handler) of
				true  -> add_new_findback(RoleSt, Level, DiffDays);
				false -> ignore
			end;
		false ->
			ignore
	end.

hook_login(_RoleSt)->
	Keys = cfg_findback:keys(),
	lists:foreach(fun 
			(Key) -> 
				#cfg_findback{event=Events} = cfg_findback:find(Key),
				case Events of
					{Event, _SType} ->
						role_event:listen(Event, ?MODULE, notify, Key);
					_ ->
						ignore
				end
		end, Keys).

notify(Event, Key, Args, _RoleSt) ->
	#cfg_findback{event=Events} = cfg_findback:find(Key),
	{Event2, TaskType} = Events,
	case Event2 == Event of
		true ->
			case Event of
				?EVENT_DUNGE_FLOOR ->
					RoleFindback = #role_findback{floors=Floors} = role_data:get(?DB_ROLE_FINDBACK),
					{SType, _Dunge, Floor} = Args,
					case SType == TaskType of
						true ->
							Floors2 = maps:put(SType, Floor, Floors),
							role_data:set(RoleFindback#role_findback{floors=Floors2});
						false ->
							ignore
					end;
				?EVENT_DUNGE_STAR ->
					RoleFindback = #role_findback{floors=Floors} = role_data:get(?DB_ROLE_FINDBACK),
					{SType, Dunge, _Floor, _Star} = Args,
					case SType == TaskType of
						true ->
							Floors2 = maps:put(SType, Dunge, Floors),
							role_data:set(RoleFindback#role_findback{floors=Floors2});
						false ->
							ignore
					end;
				?EVENT_TASK ->
					RoleFindback = #role_findback{floors=Floors} = role_data:get(?DB_ROLE_FINDBACK),
					{TaskType2, _TaskID} = Args,
					case TaskType == TaskType2 of
						true ->
							Count = maps:get(99999, Floors, 0),
							Floors2 = maps:put(99999, Count+1, Floors),
							role_data:set(RoleFindback#role_findback{floors=Floors2});
						false ->
							ignore
					end;
				_ ->
					ignore
			end;
		false ->
			ignore
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
add_new_findback(RoleSt, Level, DiffDays)->
	Keys = cfg_findback:keys(),
	RoleFindBack = #role_findback{lists=Lists, floors=Floors} = role_data:get(?DB_ROLE_FINDBACK),
	Lists2 = add_new_findback2(Lists, Keys, DiffDays, 0),
	Floors2 = maps:remove(99999, Floors),
	role_data:set(RoleFindBack#role_findback{lists=Lists2,floors=Floors2,level=Level}),
	?ucast(#m_findback_info_toc{lists=Lists2, level=Level}).

add_new_findback2(Lists, _Keys, 0, _Times)->
	Lists;
add_new_findback2(Lists, _Keys, _DiffDays, 2)->
	Lists;
add_new_findback2(Lists, Keys, DiffDays, Times)->
	Lists2 = lists:foldl(fun 
			(Key, Acc) -> 
				#cfg_findback{role_count=RCount, max_count=MaxCount, module=Mod,
				vip_role_count=VRCount,vip_rights=VRights} = cfg_findback:find(Key),
				case role_misc:is_sys_open(Mod) of
					true ->
						{Count2, ECount2} = calc_count(Key, RCount, MaxCount, VRCount, VRights, DiffDays),
						PFindback = lists:keyfind(Key, 2, Lists),
						PFindback2 = case PFindback of
							false -> #p_findback{key=Key, counts=[], extra_counts=[]};
							_ -> PFindback
						end,
						PFindback3 = case Count2 > 0 orelse ECount2 > 0 of 
							true ->
								add_new_count(PFindback2, Count2, ECount2);
							false ->
								PFindback2
						end,
						case get_total_count(2, PFindback3, true) > 0 of
							true  -> [PFindback3|Acc];
							false -> Acc
						end;
					false ->
						Acc
				end
		end, [], Keys),
	add_new_findback2(Lists2, Keys, DiffDays-1, Times+1).

%计算可找回次数
calc_count(Key, _RCount, MaxCount, _VRCount, VRights, DiffDays) when DiffDays >= 2 ->
	case Key of
		"270@1" ->
			{MaxCount, 0};
		_ ->
			Vip = role_vip:get_level(),
			MaxVipCount = cfg_vip_rights:find(VRights, Vip, 0),
			{MaxCount, MaxVipCount}
	end;

%计算可找回次数
calc_count(Key, RCount, MaxCount, VRCount, VRights, _DiffDays)->
	case Key of
		"270@1" ->
			#role_findback{floors=Floors} = role_data:get(?DB_ROLE_FINDBACK),
			Count = maps:get(99999, Floors, 0),
			case MaxCount >= Count of
				true ->
					{MaxCount-Count, 0};
				false ->
					{0, 0}
			end;
		_ ->
			Count = lists:foldl(fun 
					(CountKey, Acc) -> 
						Acc + role_count:get_times(CountKey)
				end, 0, RCount),
			Count2 = case MaxCount >= Count of
				true  -> MaxCount - Count;
				false -> 0
			end,
			%vip额外次数
			ECount = role_count:get_times(VRCount),
			Vip = role_vip:get_level(),
			MaxVipCount = cfg_vip_rights:find(VRights, Vip, 0),
			ECount2 = case MaxVipCount >= ECount of
				true  -> MaxVipCount - ECount;
				false -> 0
			end,
			{Count2, ECount2}
	end.

%增加新的次数
add_new_count(PFindback, Count, ECount)->
	#p_findback{counts=Counts, extra_counts=ECounts} = PFindback,
	Counts2 = case length(Counts) >= 2 of
		true -> 
			TCounts = lists:delete(lists:nth(2, Counts), Counts),
			[Count|TCounts];
		false ->
			[Count|Counts]
	end,
	ECounts2 = case length(ECounts) >= 2 of
		true -> 
			TECounts = lists:delete(lists:nth(2, ECounts), ECounts),
			[ECount|TECounts];
		false ->
			[ECount|ECounts]
	end,
	PFindback#p_findback{counts=Counts2, extra_counts=ECounts2}.


%获取总可找回次数(1-金币，2-绑元)
get_total_count(1, PFindback, _Extra)->
	#p_findback{counts=Counts} = PFindback,
	lists:nth(1, Counts);
get_total_count(2, PFindback, true)->
	#p_findback{counts=Counts, extra_counts=Counts2} = PFindback,
	lists:sum(Counts) + lists:sum(Counts2);
get_total_count(2, PFindback, false)->
	#p_findback{counts=Counts} = PFindback,
	lists:sum(Counts);
get_total_count(_, _PFindback, _Extra)->
	throw(?err(?ERR_FINDBACK_TYPE_WRONG)).

%找回
find_back(Type, Count, Level, Floors, CfgFindBack, PFindback)->
	#cfg_findback{cost=Cost, event=Event, exp_type=ExpType, 
	params=Params, drops=Drops, dropsgold=DropsGold, vip_cost=VipCost} = CfgFindBack,
	Exp = calc_exp(Type, ExpType, Level, Params),
	RealDrops = case Type of
		1 -> %金币找回
			DropsGold;
		_ -> %钻石找回
			Drops
	end,
	Drops2 = case Event of
		{?EVENT_TASK, _} ->
			RealDrops;
		{_, SType} -> 
			Floor = maps:get(SType, Floors, 0),
			DropMaps = maps:from_list(RealDrops),
			TDrops = maps:get(Floor, DropMaps, ?nil),
			case TDrops == ?nil of
				true -> 
					{_, TDrops2} = lists:nth(1, RealDrops),
					TDrops2;
				false ->
					TDrops
			end;
		_ ->
			RealDrops
	end,
	Gain = creep_drop:calc(Level, Drops2),
	Gain2 = [{?ITEM_EXP, Exp}|Gain],
	Cost2 = [lists:nth(Type, Cost)],
	Cost3 = [{ItemId, Num*Count} || {ItemId, Num} <- Cost2],
	Gain3 = lists:foldl(fun 
			(TGain, Acc) -> 
				TGain2 = case TGain of
					{ItemId, Num} -> {ItemId, Num*Count};
					{ItemId, Num, Bind} -> {ItemId, Num*Count, Bind};
					_ -> TGain
				end,
				[TGain2 | Acc]
		end, [], Gain2),
	#p_findback{counts=Counts, extra_counts=ECounts} = PFindback,
	{Counts2, ECounts2, ExtraCount} = delete_count(Count, Counts, ECounts, 0),
	Cost4 = case ExtraCount > 0 of
		true -> 
			VipCost2 = [{ItemId, Num*ExtraCount}||{ItemId, Num} <- VipCost],
			lists:merge(Cost3, VipCost2);
		false ->
			Cost3
	end,
	PFindback2 = PFindback#p_findback{counts=Counts2, extra_counts=ECounts2},
	{Cost4, Gain3, PFindback2}.

%扣除找回次数
delete_count(0, Counts, Counts2, ExtraCount)->
	{Counts, Counts2, ExtraCount};
delete_count(_DeleteCount, [], [], ExtraCount)->
	{[0|0], [0|0], ExtraCount};
delete_count(DeleteCount, [Count|Counts], [Count2|Counts2], ExtraCount)->
	case Count-DeleteCount >= 0 of
		true  -> 
			{[Count-DeleteCount|Counts], [Count2|Counts2], ExtraCount};
		false ->
			case Count + Count2 - DeleteCount >= 0 of
				true  ->
					DelECount = DeleteCount-Count,
					{[0|Counts], [Count2-DelECount|Counts2], ExtraCount+DelECount};
				false ->
					delete_count(DeleteCount-Count-Count2, Counts, Counts2, ExtraCount+Count2)
			end
	end.

%计算经验
calc_exp(Type, 1, Level, Params)->
	Ratio = case Type == 1 of
		true  -> 0.55;
		false -> 1
	end,
	Param = ut_conv:to_integer(Params),
	#cfg_exp_acti_base{role_exp=Exp} = cfg_exp_acti_base:find(Level),
	ut_math:ceil(Exp * Param * Ratio);

calc_exp(_Type, 0, _Level, _Params) ->
	0.

