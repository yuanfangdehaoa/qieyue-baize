%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_mall).

-include("table.hrl").
-include("game.hrl").
-include("mall.hrl").
-include("proto.hrl").
-include("role.hrl").

%% API
-export([init/2, check_day_refresh/0, check_week_refresh/0, check_limit/0
	, get_limit_items/1, is_have_limit/1, hook_upgrade/2]).
-export([check_refresh/0]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

init(RoleMall, _RoleSt)->
	case RoleMall == ?nil of
		true->
			role_data:set(#role_mall{refresh_type_maps=#{}, limit_maps=#{}});
		false->
			role_data:set(RoleMall)
	end.

%升级处理
hook_upgrade(_newLevel, RoleSt)->
	check_limit(),
	send_limit(RoleSt).
 
%检查刷新 
check_refresh()->
	RoleMall = role_data:get(?DB_ROLE_MALL),
	#role_mall{refresh_type_maps=BoughtMaps} = RoleMall,
	NowTime = ut_time:seconds(),
	BoughtMaps2 = maps:fold(fun 
			(ID, {Num, BoughtTime}, Maps) -> 
				#cfg_mall{refresh=Refresh} = cfg_mall:find(ID),
				case Refresh of
					?MALL_REFRESH_DAY->
						case ut_time:is_today(BoughtTime) of
							false -> Maps;
							true  -> maps:put(ID, {Num, BoughtTime}, Maps)
						end;
					?MALL_REFRESH_WEEK ->
						case ut_time:is_same_week(BoughtTime, NowTime) of
							false -> Maps;
							true  -> maps:put(ID, {Num, BoughtTime}, Maps)
						end;
					_->
						maps:put(ID, {Num, BoughtTime}, Maps)
				end
		end, #{}, BoughtMaps),
	role_data:set(RoleMall#role_mall{refresh_type_maps=BoughtMaps2}).

%检查每日刷新
check_day_refresh()->
	RoleMall = role_data:get(?DB_ROLE_MALL),
	#role_mall{refresh_type_maps=RefreshTypeMaps} = RoleMall,
	MallBoughtDay = maps:get(?MALL_REFRESH_DAY, RefreshTypeMaps, ?nil),
	case MallBoughtDay ==?nil of
		false->
			#mall_bought{last_refresh=LastRefresh} = MallBoughtDay,
			case ut_time:is_today(LastRefresh) of
				false->
					MallBoughtDay2 = #mall_bought{last_refresh=ut_time:seconds(), bought_maps=#{}},
					RefreshTypeMaps2 = maps:put(?MALL_REFRESH_DAY, MallBoughtDay2, RefreshTypeMaps),
					RoleMall2 = RoleMall#role_mall{refresh_type_maps=RefreshTypeMaps2},
					role_data:set(RoleMall2);
				true->
					ignor
			end;
		true->
			MallBoughtDay2 = #mall_bought{last_refresh=ut_time:seconds(),bought_maps=#{}},
			RefreshTypeMaps2 = maps:put(?MALL_REFRESH_DAY, MallBoughtDay2, RefreshTypeMaps),
			RoleMall2 = RoleMall#role_mall{refresh_type_maps=RefreshTypeMaps2},
			role_data:set(RoleMall2)
	end.

%检查每周刷新
check_week_refresh()->
	RoleMall = #role_mall{refresh_type_maps=RefreshTypeMaps} = role_data:get(?DB_ROLE_MALL),
	MallBoughtWeek = maps:get(?MALL_REFRESH_WEEK, RefreshTypeMaps, ?nil),
	case MallBoughtWeek ==?nil of
		false->
			#mall_bought{last_refresh=LastRefresh} = MallBoughtWeek,
			NowTime = ut_time:seconds(),
			case ut_time:is_same_week(LastRefresh, NowTime) of
				false->
					MallBoughtWeek2 = #mall_bought{last_refresh=NowTime, bought_maps=#{}},
					RefreshTypeMaps2 = maps:put(?MALL_REFRESH_WEEK, MallBoughtWeek2, RefreshTypeMaps),
					RoleMall2 = RoleMall#role_mall{refresh_type_maps=RefreshTypeMaps2},
					role_data:set(RoleMall2);
				true->
					ignor
			end;
		true->
			MallBoughtWeek2 = #mall_bought{last_refresh=ut_time:seconds(),bought_maps=#{}},
			RefreshTypeMaps2 = maps:put(?MALL_REFRESH_WEEK, MallBoughtWeek2, RefreshTypeMaps),
			RoleMall2 = RoleMall#role_mall{refresh_type_maps=RefreshTypeMaps2},
			role_data:set(RoleMall2)
	end.

%检查是否有新物品加入限时抢购
check_limit()->
	Ids = cfg_mall:find_ids_by_limittype(?LIMIT_TYPE_TIME),
	#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
	VipLv = role_vip:get_level(),
	OpenDays = game_env:get_opened_days(),
	RoleMall = #role_mall{limit_maps=LimitMaps} = role_data:get(?DB_ROLE_MALL),
	LimitMaps2 = lists:foldl(fun
		(Id, AddLimitMaps) ->
			#cfg_mall{
				limit_num       = LimitNum,
				limit_vip       = LimitVip,
				limit_pre_id    = LimitPreId,
				limit_level     = LimitLevel,
				limit_open_days = LimitOpenDays,
				limit_duration  = LimitDuration
			} = cfg_mall:find(Id),
			case
				VipLv >= LimitVip andalso
				Level >= LimitLevel andalso
				OpenDays >= LimitOpenDays andalso
				is_bought(AddLimitMaps, LimitPreId)	andalso
				is_not_in_bought(AddLimitMaps, Id)
			of
				true->
					LimitItem = #p_mall_limit_item{
						id       = Id,
						left_num = LimitNum,
						end_time = ut_time:seconds()+LimitDuration,
						buy_num  = 0
					},
					maps:put(Id, LimitItem, AddLimitMaps);
				false->
					AddLimitMaps
		    end
	end, LimitMaps, Ids),
	RoleMall2 = RoleMall#role_mall{limit_maps=LimitMaps2},
	role_data:set(RoleMall2).

%获取限时购买商品
get_limit_items(LimitMaps) ->
	maps:fold(fun
			(_K, V, ItemList) ->
				#p_mall_limit_item{left_num=LeftNum, end_time=EndTime} = V,
				case LeftNum > 0 andalso EndTime >= ut_time:seconds() of
					true->
						[V|ItemList];
					false->
						ItemList
				end
		end, [], LimitMaps).


%是否有限购产品
is_have_limit(LimitMaps) ->
	case maps:size(LimitMaps) == 0 of
		true ->
			false;
		false ->
			loop_limit(maps:values(LimitMaps))
	end.

loop_limit([]) ->
	false;
loop_limit([T|List]) ->
	#p_mall_limit_item{left_num=LeftNum, end_time=EndTime} = T,
	case LeftNum > 0 andalso EndTime >= ut_time:seconds() of
		true ->
			true;
		false ->
			loop_limit(List)
	end.

%检查是否购买过该产品
is_bought(LimitMaps, Id) ->
	case Id == 0 of
		true->
			true;
		false ->
			case maps:get(Id, LimitMaps, ?nil) of
				?nil ->
					false;
				#p_mall_limit_item{buy_num=BuyNum} ->
					BuyNum > 0
			end
    end.

%是否不在可购列表中
is_not_in_bought(LimitMaps, Id)->
	not maps:is_key(Id, LimitMaps).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------

send_limit(RoleSt)->
	#role_mall{limit_maps=LimitMaps} = role_data:get(?DB_ROLE_MALL),
	ItemList = get_limit_items(LimitMaps),
	?ucast(#m_mall_getlimit_toc{limit_items=ItemList}).
