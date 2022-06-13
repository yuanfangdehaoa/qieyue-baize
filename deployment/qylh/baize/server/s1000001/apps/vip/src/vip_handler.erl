%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(vip_handler).

-include("game.hrl").
-include("mall.hrl").
-include("role.hrl").
-include("table.hrl").
-include("vip.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("msgno.hrl").

%% API
-export([handle/3]).
-export([fetch_exp_pool/3]).
-export([do_vip_invest_buy/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% vip 信息
handle(?VIP_INFO, _Tos, RoleSt) ->
	RoleVip = role_data:get(?DB_ROLE_VIP),
	?ucast(#m_vip_info_toc{
		daily_exp   = role_count:get_vip_welfare(?VIP_WELFARE_DAILY_EXP) >= 1,
		lv_reward   = RoleVip#role_vip.fetch,
		weekly_gift = role_count:get_vip_welfare(?VIP_WELFARE_WEEKLY_GIFT) >= 1,
		auto_fetch  = RoleVip#role_vip.auto
	});

%% 领取奖励
handle(?VIP_FETCH, Tos, RoleSt) ->
	#m_vip_fetch_tos{type=Type, level=Level} = Tos,
	RoleVip = role_data:get(?DB_ROLE_VIP),
	case Type of
		% 1 -> % 每日经验
		% 	fetch_vipexp_reward(RoleVip, RoleSt);
		2 -> % 等级奖励
			fetch_level_reward(RoleVip, Level, RoleSt);
		3 -> % 周礼包
			fetch_weekly_reward(RoleVip, RoleSt);
		4 -> % 经验池
			fetch_exp_pool(RoleVip, false, RoleSt)
	end,
	?ucast(#m_vip_fetch_toc{type=Type, level=Level});

%% vip 激活
handle(?VIP_ACTIVE, Tos, RoleSt) ->
	#m_vip_active_tos{type=CardID} = Tos,
	#cfg_vip_card{goods=GoodsID} = cfg_vip_card:find(CardID),
	#cfg_mall{price=Cost} = cfg_mall:find(GoodsID),
	role_bag:cost(Cost, ?LOG_VIP_ACTIVE, RoleSt),
	role_vip:active(CardID, RoleSt),
	?ucast(#m_vip_active_toc{type=CardID});

%% 设置自动领取vip经验奖励
handle(?VIP_AUTO_FETCH, Tos, RoleSt) ->
	#m_vip_auto_fetch_tos{is_auto=IsAuto} = Tos,
	RoleVip = role_data:get(?DB_ROLE_VIP),
	role_data:set(RoleVip#role_vip{auto=IsAuto}),
	?ucast(#m_vip_auto_fetch_toc{is_auto=IsAuto});

%% 经验池信息
handle(?VIP_EXP_POOL, _Tos, RoleSt) ->
	#role_vip{pool=ExpPool} = role_data:get(?DB_ROLE_VIP),
	?ucast(#m_vip_exp_pool_toc{exp=ExpPool});

handle(?VIP_MCARD, _Tos, RoleSt) ->
	#role_vip{mcard=MCard, mfetch=MFetch} = role_data:get(?DB_ROLE_VIP),
	?ucast(#m_vip_mcard_toc{buy=MCard, fetch=MFetch});

handle(?VIP_MCARD_BUY, _Tos, RoleSt) ->
 	#role_vip{mcard=MCard, mfetch=MFetch0} = RoleVip = role_data:get(?DB_ROLE_VIP),
 	case MCard of
 		true ->
 			?_check(maps:size(MFetch0) == length(cfg_vip_mcard:all()), ?ERR_VIP_MCARD_ALREADY_BUY),
 			Maxday = lists:max(cfg_vip_mcard:all()),
 			?_check({ok, true} == maps:find(Maxday, MFetch0), ?ERR_VIP_MCARD_HAS_REWARD);
 		false ->
 			ok
 	end,
 	Cost = [cfg_game:vip_mcard()],
 	Succ = fun() ->
	 	MFetch = #{0 => false, 1 => false},
	 	role_data:set(RoleVip#role_vip{mcard=true, mfetch=MFetch}),
	 	?ucast(#m_vip_mcard_toc{buy=true, fetch=MFetch}),
	 	#role_info{id=RoleID, name=RoleName} = role_data:get(?DB_ROLE_INFO),
	 	?notify(?MSG_VIP_MCARD_BUY, [
	 		{role, RoleID, RoleName},
	 		{color, element(2, cfg_game:vip_mcard()), ?COLOR_GREEN}
	 	]),
	 	role_event:event(?EVENT_VIP_MCARD)
 	end,
	role_bag:cost(Cost, ?LOG_VIP_MCARD_BUY, Succ, RoleSt);

handle(?VIP_MCARD_FETCH, Tos, RoleSt) ->
	#m_vip_mcard_fetch_tos{day=Day} = Tos,
	#role_vip{mcard=MCard, mfetch=MFetch0} = RoleVip = role_data:get(?DB_ROLE_VIP),
	?_check(MCard, ?ERR_VIP_MCARD_NOT_BUY),
	?_check({ok, false} == maps:find(Day, MFetch0), ?ERR_VIP_MCARD_FETCHED),
	#cfg_vip_mcard{reward=Gain} = cfg_vip_mcard:find(Day),
	Succ = fun() ->
		case Day == lists:max(cfg_vip_mcard:all()) of
			true ->
				% 领完最后一天，重置
				role_data:set(RoleVip#role_vip{mcard=false, mfetch=#{}}),
				?ucast(#m_vip_mcard_toc{buy=false, fetch=#{}});
			false ->
				MFetch = maps:put(Day, true, MFetch0),
				role_data:set(RoleVip#role_vip{mfetch=MFetch}),
				?ucast(#m_vip_mcard_toc{buy=true, fetch=MFetch})
		end
	end,
	role_bag:gain(Gain, ?LOG_VIP_MCARD_FETCH, Succ, RoleSt);

handle(?VIP_INVEST, _Tos, RoleSt) ->
	#role_vip{invest=Invest} = role_data:get(?DB_ROLE_VIP),
	Type = lists:max(maps:keys(maps:without([3,4], Invest))),
	#r_vip_invest{grade=Grade, list=InvestList} = maps:get(Type, Invest),
	?ucast(#m_vip_invest_toc{type=Type, grade=Grade, list=InvestList});

handle(?VIP_INVEST2, Tos, RoleSt) ->
	#m_vip_invest2_tos{type=Type} = Tos,
	#role_vip{invest=Invest} = role_data:get(?DB_ROLE_VIP),
	#r_vip_invest{grade=Grade, list=InvestList} = maps:get(Type, Invest, #r_vip_invest{}),
	?ucast(#m_vip_invest2_toc{type=Type, grade=Grade, list=InvestList});
handle(?VIP_INVEST_BUY, Tos, RoleSt) ->
	#m_vip_invest_buy_tos{type=Type} = Tos,
	?_check(lists:member(Type, [1,2,3]), ?ERR_GAME_BAD_ARGS),
	do_vip_invest_buy(Tos, RoleSt);

handle(?VIP_INVEST_FETCH, Tos, RoleSt) ->
	#m_vip_invest_fetch_tos{type=Type, id=ID} = Tos,
	#role_vip{invest=Invest} = RoleVip = role_data:get(?DB_ROLE_VIP),
	RoleInvest = maps:get(Type, Invest, ?nil),
	?_check(RoleInvest =/= ?nil, ?ERR_GAME_BAD_ARGS, [?VIP_INVEST_FETCH]),
	#r_vip_invest{grade=Grade, list=InvestList0} = RoleInvest,
	?_check(lists:keymember(ID, 1, cfg_vip_invest_reward:all(Type, Grade)),
		?ERR_GAME_BAD_ARGS, [?VIP_INVEST_FETCH]),
	#cfg_vip_invest_reward{level=Level, bgold=BGold, reward=Gain0} = cfg_vip_invest_reward:find(Type, ID),
	I = case lists:keyfind(ID, #p_invest.id, InvestList0) of
		false ->
			#p_invest{id=ID, state=?INVEST_STATE_REWARD, bgold=BGold};
		I0 ->
			I0
	end,
	?_check(I#p_invest.state == ?INVEST_STATE_REWARD, ?ERR_VIP_INVEST_ALREADY_FETCH),
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	?_check(RoleLv >= Level, ?ERR_VIP_INVEST_LEVEL_NOT_MATCH),

	Gain = case I#p_invest.bgold == BGold of
		true ->
			% 没补差额，属于第一次领取
			Gain0;
		false ->
			lists:keystore(?ITEM_BGOLD, 1, Gain0, {?ITEM_BGOLD, I#p_invest.bgold})
	end,
	Succ = fun() ->
		I2 = I#p_invest{state=?INVEST_STATE_FETCH},
	    InvestList = lists:keystore(ID, #p_invest.id, InvestList0, I2),
	    RoleInvest2 = RoleInvest#r_vip_invest{list=InvestList},
	    Invest2 = maps:put(Type, RoleInvest2, Invest),
		role_data:set(RoleVip#role_vip{invest=Invest2}),
	    ?ucast(#m_vip_invest_fetch_toc{item=I2}),

	    can_upgrade_next_type(Type, RoleInvest2) andalso begin
	    	role_data:set(RoleVip#role_vip{invest=maps:put(Type+1, #r_vip_invest{}, Invest2)}),
	    	?ucast(#m_vip_invest_next_toc{})
	    end
	end,
	LogID = ?_if(Type == 3 orelse Type == 4, ?LOG_VIP_PURCHASE, ?LOG_VIP_INVEST_FETCH),
	role_bag:gain(Gain, LogID, Succ, RoleSt);

%% v4 返利信息
handle(?VIP_REBATE_INFO, _Tos, RoleSt) ->
	#role_vip{rebate=Rebate} = role_data:get(?DB_ROLE_VIP),
	case Rebate == ?nil of
		true  ->
			?ucast(#m_vip_rebate_info_toc{
				time  = 0,
				fetch = false
			});
		false ->
			?ucast(#m_vip_rebate_info_toc{
				time  = Rebate#r_vip_rebate.time,
				fetch = Rebate#r_vip_rebate.fetch > 0
			})
	end;

handle(?VIP_REBATE_FETCH, _Tos, RoleSt) ->
	RoleVip = #role_vip{rebate=Rebate} = role_data:get(?DB_ROLE_VIP),
	case Rebate == ?nil of
		true  ->
			ignore;
		false ->
			#r_vip_rebate{time=RebateTime, fetch=FetchTime} = Rebate,
			?_check(FetchTime == 0, ?ERR_VIP_REBATE_FETCHED),
			NowTime  = ut_time:seconds(),
			CanFetch = NowTime >= RebateTime,
			?_check(CanFetch, ?ERR_VIP_REBATE_NOT_ARRIVED),
			#cfg_vip_card{goods=GoodsID} = cfg_vip_card:find(4),
			#cfg_mall{price=Price} = cfg_mall:find(GoodsID),
			role_bag:gain(Price, ?LOG_VIP_REBATE, RoleSt),
			Rebate2  = Rebate#r_vip_rebate{fetch=NowTime},
			role_data:set(RoleVip#role_vip{rebate=Rebate2}),
			?ucast(#m_vip_rebate_fetch_toc{})
	end;

%% vip体验信息
handle(?VIP_TASTE_INFO, _Tos, RoleSt) ->
	#role_vip{taste=Taste} = role_data:get(?DB_ROLE_VIP),
	case Taste == ?nil of
		true  ->
			?ucast(#m_vip_taste_info_toc{
				stime = 0,
				etime = 0
			});
		false ->
			?ucast(#m_vip_taste_info_toc{
				stime = Taste#r_vip_taste.stime,
				etime = Taste#r_vip_taste.etime
			})
	end.

do_vip_invest_buy(Tos, RoleSt) ->
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	#m_vip_invest_buy_tos{type=Type, grade=Grade} = Tos,
	#role_vip{invest=Invest} = RoleVip = role_data:get(?DB_ROLE_VIP),
	if
		Type == 3; Type == 4 ->
			RoleInvest  = maps:get(Type, Invest, #r_vip_invest{}),
			RoleInvest2 = RoleInvest#r_vip_invest{grade=Grade, list=[]},
			role_data:set(RoleVip#role_vip{invest=maps:put(Type, RoleInvest2, Invest)});
		true ->
			RoleInvest = maps:get(Type, Invest, ?nil),
			?_check(RoleInvest =/= ?nil, ?ERR_GAME_BAD_ARGS, [?VIP_INVEST_BUY]),
			#r_vip_invest{grade=InvestID, list=InvestList0} = RoleInvest,
			Levels = cfg_vip_invest_reward:all(Type, Grade),
			?_check(Levels =/= [], ?ERR_GAME_BAD_ARGS, [?VIP_INVEST_BUY]),
			?_check(Grade > InvestID, ?ERR_VIP_INVEST_ALREADY_BUY),
			Old = case cfg_vip_invest:find(Type, InvestID) of
				?nil -> 0;
				[{_, Old0}] -> Old0
			end,
			[{MoneyType, New}] = cfg_vip_invest:find(Type, Grade),
			Cost = [{MoneyType, New-Old}],
			Succ = fun() ->
				% 补差额
				InvestList = [begin
					Conf0 = cfg_vip_invest_reward:find(Type, I#p_invest.id),
					{ID, _} = lists:keyfind(Conf0#cfg_vip_invest_reward.level, 2, Levels),
					Conf = cfg_vip_invest_reward:find(Type, ID),
					Balance = case I#p_invest.state of
						?INVEST_STATE_REWARD -> Conf#cfg_vip_invest_reward.bgold;
						?INVEST_STATE_FETCH -> Conf#cfg_vip_invest_reward.bgold - I#p_invest.bgold
					end,
					I#p_invest{id = ID, state = ?INVEST_STATE_REWARD, bgold = Balance}
				end || I <- InvestList0],
				RoleInvest2 = RoleInvest#r_vip_invest{grade=Grade, list=InvestList},
				role_data:set(RoleVip#role_vip{invest=maps:put(Type, RoleInvest2, Invest)}),
				?ucast(#m_vip_invest_buy_toc{}),
				?ucast(#m_vip_invest_toc{type=Type, grade=Grade, list=InvestList}),
				?notify(?MSG_VIP_INVEST_BUY, [{role, RoleID, RoleName}, New])
			end,
			role_bag:cost(Cost, ?LOG_VIP_INVEST_BUY, Succ, RoleSt),
			role_event:event(?EVENT_INVEST, {InvestID, Grade})
	end.
%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%% 领取 vip 经验奖励
% fetch_vipexp_reward(RoleVip, RoleSt) ->
% 	IsFetch = role_count:get_vip_welfare(?VIP_WELFARE_DAILY_EXP) >= 1,
% 	?_check(not IsFetch, ?ERR_VIP_HAD_FETCH),
% 	#role_vip{level=VipLv, type=VipType} = RoleVip,
% 	?_check(VipType /= ?VIP_TYPE_NONE, ?ERR_VIP_EXPIRED),
% 	#cfg_vip_level{vipexp=ExpAdd} = cfg_vip_level:find(VipLv),
% 	role_vip:add_exp(RoleVip, ExpAdd, RoleSt),
% 	role_count:add_times({?ROLE_COUNT_VIP_WELFARE, ?VIP_WELFARE_DAILY_EXP}).

%% 领取 vip 等级奖励
fetch_level_reward(RoleVip, Level, RoleSt) ->
	#role_vip{level=VipLv, type=VipType, fetch=Fetch} = RoleVip,
	?_check(VipLv >= Level, ?ERR_VIP_NOT_ENOUGH),
	?_check(VipType /= ?VIP_TYPE_NONE, ?ERR_VIP_EXPIRED),
	IsFetch = lists:member(Level, Fetch),
	?_check(not IsFetch, ?ERR_VIP_HAD_FETCH),
	#cfg_vip_level{reward=Gain} = cfg_vip_level:find(Level),
	role_bag:gain(Gain, ?LOG_VIP_REWARD, RoleSt),
	role_data:set(RoleVip#role_vip{fetch=[Level | Fetch]}).

%% 领取周礼包奖励
fetch_weekly_reward(RoleVip, RoleSt) ->
	IsFetch = role_count:get_vip_welfare(?VIP_WELFARE_WEEKLY_GIFT) >= 1,
	?_check(not IsFetch, ?ERR_VIP_HAD_FETCH),
	#role_vip{level=VipLv, type=VipType} = RoleVip,
	?_check(VipType == ?VIP_TYPE_NORM, ?ERR_VIP_NOT_NORMAL),
	#cfg_vip_level{gift=Gain} = cfg_vip_level:find(VipLv),
	role_bag:gain(Gain, ?LOG_VIP_REWARD, RoleSt),
	role_count:add_times({?ROLE_COUNT_VIP_WELFARE, ?VIP_WELFARE_WEEKLY_GIFT}).

%% 领取经验池经验
fetch_exp_pool(RoleVip, IsAuto, RoleSt) ->
	#role_vip{type=VipType, pool=ExpPool} = RoleVip,
	case IsAuto of
		true  ->
			case VipType == ?VIP_TYPE_NONE orelse ExpPool =< 0 of
				true  -> ignore;
				false -> fetch_exp_pool2(RoleVip, RoleSt)
			end;
		false ->
			?_check(VipType /= ?VIP_TYPE_NONE, ?ERR_VIP_EXPIRED),
			?_check(ExpPool > 0, ?ERR_VIP_NO_EXP_POOL),
			fetch_exp_pool2(RoleVip, RoleSt)
	end.

fetch_exp_pool2(RoleVip, RoleSt) ->
	Exp = RoleVip#role_vip.pool,
	role_bag:gain([{?ITEM_EXP, Exp}], ?LOG_VIP_EPOOL, RoleSt),
	role_data:set(RoleVip#role_vip{pool=0}).

% 最高档位奖励全部领取完毕
can_upgrade_next_type(Type, RoleInvest) ->
	case Type < cfg_vip_invest:max_type() of
		true ->
			#r_vip_invest{grade=Grade, list=InvestList} = RoleInvest,
			case Grade == cfg_vip_invest:max_grade() of
				true ->
					CheckLen = length(InvestList) == length(cfg_vip_invest_reward:all(Type, Grade)),
					CheckFetch = lists:all(fun(#p_invest{state=State}) ->
						State == ?INVEST_STATE_FETCH
					end, InvestList),
					CheckLen andalso CheckFetch;
				false ->
					false
			end;
		false ->
			false
	end.
