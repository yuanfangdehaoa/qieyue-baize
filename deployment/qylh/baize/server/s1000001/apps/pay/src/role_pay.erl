%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_pay).

-include("game.hrl").
-include("pay.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([pay/2]).
-export([fee/1]).
-export([calc/0,calc/1, calc/2]).
-export([stat_daily/3]).
-export([get_all_pay_times/0]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

pay(Params, RoleSt) ->
	{Plat, _} = sdk:route(),
	pay_succ(Plat, Params, RoleSt).

fee(STime) ->
	#role_pay{payments=Payments} = role_data:get(?DB_ROLE_PAY),
	TotalFee =
		lists:foldl(fun
									(Payment, Acc) ->
										#payment{pay_time=PayTime, total_fee=Fee} = Payment,
										case STime =< PayTime of
											true  -> Acc + Fee;
											false -> Acc
										end
								end, 0, Payments),
	erlang:round(TotalFee).

calc() ->
	#role_pay{payments=Payments} = role_data:get(?DB_ROLE_PAY),
	lists:foldl(fun
								(Payment, Acc) ->
									#payment{total_fee = Fee} = Payment,
									Acc + Fee
							end, 0, Payments).

calc(STime) ->
	#role_pay{payments=Payments} = role_data:get(?DB_ROLE_PAY),
	lists:foldl(fun
		(Payment, Acc) ->
			#payment{pay_time=PayTime, gain_gold=Gold} = Payment,
			case STime =< PayTime of
			 	true  -> Acc + Gold;
			 	false -> Acc
			end
	end, 0, Payments).

calc(STime, ETime) ->
	#role_pay{payments=Payments} = role_data:get(?DB_ROLE_PAY),
	lists:foldl(fun
		(Payment, Acc) ->
			#payment{pay_time=PayTime, gain_gold=Gold} = Payment,
			case STime =< PayTime andalso PayTime =< ETime of
			 	true  -> Acc + Gold;
			 	false -> Acc
			end
	end, 0, Payments).

stat_daily(RoleID, SDate, EDate) ->
	#role_pay{payments=Payments} = db:dirty_read(?DB_ROLE_PAY, RoleID),
	STime = ut_time:datetime_to_seconds({SDate, {0,0,0}}),
	ETime = ut_time:datetime_to_seconds({EDate, {23,59,59}}),
	lists:foldl(fun
		(Payment, Acc) ->
			#payment{pay_time=PayTime, gain_gold=Gold} = Payment,
			case STime =< PayTime andalso PayTime =< ETime of
			 	true  ->
			 		PayDate = ut_time:seconds_to_date(PayTime),
			 		ut_misc:maps_increase(PayDate, Gold, Acc);
			 	false ->
			 		Acc
			end
	end, #{}, Payments).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
pay_succ(Plat, Params, RoleSt) when Plat =:= junhai orelse Plat =:= baize ->
	#{
		sdk_order  := SDKOrder,
		app_order  := AppOrder,
		goods_id   := GoodsID0,
		total_fee  := TotalFee,
		is_real    := IsReal
	} = Params,
	GoodsID = ut_conv:to_integer(GoodsID0),
	case (erlang:round(TotalFee) == cfg_recharge:price(GoodsID)) of
		true  ->
			Reward = cfg_recharge:gain(GoodsID),
			Rebate = cfg_recharge:rebate(GoodsID),
			Price = cfg_recharge:price(GoodsID),
			#role_pay{payments=Payments} = role_data:get(?DB_ROLE_PAY),
			IsFirst = (not lists:keymember(GoodsID, #payment.goods_id, Payments)),
			check_times(GoodsID, IsFirst),
			Rebate2 = ?_if(IsFirst, Rebate, cfg_recharge:rebate2(GoodsID)),
			?_check(Reward /= ?nil, ?ERR_GAME_BAD_ARGS),
			{ok, Obtain} = role_bag:gain(Rebate2++Reward, ?LOG_PAY, RoleSt),
			GainGold = proplists:get_value(?ITEM_GOLD, Reward, 0),
			pay_succ2(AppOrder, SDKOrder, GoodsID, Price, GainGold, Reward, Obtain, Rebate2, IsReal, RoleSt);
		false ->
			% 君海那边可能会修改金额
%%			Reward = [{?ITEM_GOLD, round(TotalFee*10)}],
%%			{GoodsID2, Rebate} = cfg_recharge:rebate_by_price(TotalFee),
			?error("error pay data ：~p~n", [{Params}]),
			igore
	end;


pay_succ(tanwan, Params, RoleSt) ->
	#{
	    sdk_order  := SDKOrder,
	    app_order  := AppOrder,
	    goods_id   := GoodsID0,
	    total_fee  := TotalFee,
	    pay_type   := PayType,
	    game_gold  := GameGold,
	    extra_gold := ExtraGold,
	    is_real    := IsReal
	} = Params,
	GoodsID = ut_conv:to_integer(GoodsID0),
	% PayType 1-游戏内购 2-第三方支付
	case PayType of
		1 ->
			Reward = cfg_recharge:gain(GoodsID),
			Rebate = cfg_recharge:rebate(GoodsID);
		2 ->
			Reward = [{?ITEM_GOLD, GameGold+ExtraGold}],
			Rebate = []
	end,
	#role_pay{payments=Payments} = role_data:get(?DB_ROLE_PAY),
	IsFirst = (not lists:keymember(GoodsID, #payment.goods_id, Payments)),
	check_times(GoodsID, IsFirst),
	Rebate2 = case PayType of
		1 ->
			case IsFirst of
				true  -> Rebate;
				false -> cfg_recharge:rebate2(GoodsID)
			end;
		2 ->
			[]
	end,
	?_check(Reward /= ?nil, ?ERR_GAME_BAD_ARGS),
	{ok, Obtain} = role_bag:gain(Rebate2++Reward, ?LOG_PAY, RoleSt),
	GainGold = proplists:get_value(?ITEM_GOLD, Reward, 0),

	pay_succ2(AppOrder, SDKOrder, GoodsID, TotalFee, GainGold, Reward, Obtain, Rebate2, IsReal, RoleSt).

pay_succ2(AppOrder, SDKOrder, GoodsID, TotalFee, GainGold, Reward, Obtain, Rebate, IsReal, RoleSt) ->
	#role_st{user=User, ip=IP, sdk=SDKArgs, role=RoleID} = RoleSt,
	Payment = #payment{
		app_order = AppOrder,
		sdk_order = SDKOrder,
		goods_id  = GoodsID,
		total_fee = TotalFee,
		gain_gold = GainGold,
		pay_time  = ut_time:seconds()
	},
	RolePay = #role_pay{payments=Payments} = role_data:get(?DB_ROLE_PAY),
	role_data:set(RolePay#role_pay{payments=[Payment | Payments]}),
	TodayOld = role_count:get_times(?ROLE_COUNT_DAILY_PAY),
	role_count:add_times(?ROLE_COUNT_DAILY_PAY, GainGold),
	TodayNew = role_count:get_times(?ROLE_COUNT_DAILY_PAY),
	?notice(
		"pay_succ, role=~w, order=~s, goodsid=~w, fee=~w, reward=~w, rebate=~w, gold=~w, old=~w, new=~w",
		[RoleID, SDKOrder, GoodsID, TotalFee, Reward, Rebate, GainGold, TodayOld, TodayNew]
	),
	role_event:event(?EVENT_PAY, {GainGold, TodayOld, TodayNew}),

	role_count:add_times({?ROLE_COUNT_DAILY_RECHARGE, GoodsID}),
%%	?_if(
%%		lists:member(GoodsID, cfg_direct_purchase:all()),
%%		role_count:add_times({?ROLE_COUNT_DAILY_RECHARGE, GoodsID})
%%	),

%%	?_if(cfg_recharge:ispay(GoodsID), vip2_handler:add_exp(TotalFee*10, RoleSt)),
  ?_if(cfg_recharge:ispay(GoodsID), role_vip:add_exp(round(TotalFee), RoleSt)),
	case GoodsID of
		16 ->
			Tos = #m_vip_invest_buy_tos{type=3, grade=1},
			role:route(RoleID, vip_handler, do_vip_invest_buy, Tos);
		17 ->
			Tos = #m_vip_invest_buy_tos{type=4, grade=1},
			role:route(RoleID, vip_handler, do_vip_invest_buy, Tos);
		_  ->
			ignore
	end,

	case IsReal of
		true  ->
			log_junhai:log_pay(User, IP, SDKArgs, {AppOrder,SDKOrder,TotalFee}),
			log_talkingdata:log_pay(
				User, IP, SDKArgs, {AppOrder,SDKOrder,GoodsID,TotalFee,GainGold}
			);
		false ->
			ignore
	end,
	?ucast(#m_game_paysucc_toc{
		gain      = Obtain,
		app_order = ut_conv:to_list(AppOrder),
		sdk_order = ut_conv:to_list(SDKOrder)
	}).

check_times(GoodsID, IsFirst) ->
	case lists:member(GoodsID, [15,16,17]) of
		true  ->
			?_check(IsFirst, ?ERR_GAME_BAD_ARGS);
		false ->
			case lists:member(GoodsID, cfg_direct_purchase:all()) of
				true  ->
					CurTimes = role_count:get_times({?ROLE_COUNT_DAILY_RECHARGE, GoodsID}),
					MaxTimes = cfg_direct_purchase:times(GoodsID),
					?_check(CurTimes < MaxTimes, ?ERR_GAME_BAD_ARGS);
				false ->
					ok
			end
	end.


get_all_pay_times() ->
	#role_pay{payments=Payments} = role_data:get(?DB_ROLE_PAY),
	lists:foldl(fun(#payment{goods_id = GoodsId}, Acc) ->
		case lists:keytake(GoodsId, 1, Acc) of
			{value, {GoodsId, Count}, Acc2} ->
				[{GoodsId, Count + 1} | Acc2];
			false ->
				[{GoodsId, 1} | Acc]
		end
		    end, [], Payments).