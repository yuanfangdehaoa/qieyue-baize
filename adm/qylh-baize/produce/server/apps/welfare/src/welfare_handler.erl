%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(welfare_handler).

-include("game.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("table.hrl").
-include("welfare.hrl").
-include("role.hrl").
-include("log.hrl").
-include("enum.hrl").
-include("msgno.hrl").
-include("pay.hrl").

%% API
-export([handle/3]).
-export([hook_reset/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%等级礼包
handle(?WELFARE_LEVEL, _Tos, RoleSt)->
	#role_welfare{level=LevelReward} = role_data:get(?DB_ROLE_WELFARE),
	#welfare{level=LevelCount} = get_welfare(),
	{ok, #m_welfare_level_toc{level=LevelReward, count=LevelCount}, RoleSt};

%领取等级奖励
handle(?WELFARE_LEVEL_REWARD, Tos, RoleSt)->
	#m_welfare_level_reward_tos{level=Level} = Tos,
	RoleWelfare = #role_welfare{level=LevelReward} = role_data:get(?DB_ROLE_WELFARE),
	#role_info{level=RoleLevel} = role_data:get(?DB_ROLE_INFO),
	?_check(RoleLevel >= Level, ?ERR_WELFARE_CONDI_NOT_ENOUGH),
	%检测是否已领取
	case lists:member(Level, LevelReward) of
		true  -> throw(?err(?ERR_WELFARE_REWARD_IS_GOT));
		false -> ignor
	end,
	%检测是否已领完
	#cfg_welfare_level_reward{count=Limit, reward=Gain, reward2=Gain2} = cfg_welfare_level_reward:find(Level),
	WelFare = #welfare{level=LevelCount} = get_welfare(),
	{NewLevelCount, NewGain}= case Limit > 0 of
		true ->
			Count = maps:get(Level, LevelCount, 0),
			case Count < Limit of
				true ->
					LevelCount2 = maps:put(Level, Count+1, LevelCount),
					WelFare2 = WelFare#welfare{level=LevelCount2},
					game_misc:write(welfare, WelFare2),
					{LevelCount2, Gain2};
				false ->
					{LevelCount, Gain}
			end;
		false->
			{LevelCount, Gain}
    end,
    role_bag:gain(NewGain, ?LOG_WELFARE_LEVEL_REWARD, RoleSt),
    LevelReward2 = [Level | LevelReward],
    role_data:set(RoleWelfare#role_welfare{level=LevelReward2}),
    ?ucast(#m_welfare_level_toc{level=LevelReward2, count=NewLevelCount}),
	{ok, #m_welfare_level_reward_toc{level=Level}, RoleSt};

%战力礼包
handle(?WELFARE_POWER, _Tos, RoleSt)->
	#role_welfare{power=PowerReward} = role_data:get(?DB_ROLE_WELFARE),
	#welfare{power=PowerCount} = get_welfare(),
	{ok, #m_welfare_power_toc{power=PowerReward, count=PowerCount}, RoleSt};

%领取战力奖励
handle(?WELFARE_POWER_REWARD, Tos, RoleSt)->
	#m_welfare_power_reward_tos{power=Power} = Tos,
	RoleWelfare = #role_welfare{power=PowerReward} = role_data:get(?DB_ROLE_WELFARE),
	#role_attr{power=RolePower} = role_data:get(?DB_ROLE_ATTR),
	?_check(RolePower >= Power, ?ERR_WELFARE_CONDI_NOT_ENOUGH),
	%检测是否已领取
	case lists:member(Power, PowerReward) of
		true  -> throw(?err(?ERR_WELFARE_REWARD_IS_GOT));
		false -> ignor
	end,
	%检测是否已领完
	#cfg_welfare_power_reward{count=Limit, reward=Gain, reward2=Gain2} = cfg_welfare_power_reward:find(Power),
	WelFare = #welfare{power=PowerCount} = get_welfare(),
	{NewPowerCount, NewGain}= case Limit > 0 of
		true ->
			Count = maps:get(Power, PowerCount, 0),
			case Count < Limit of
				true ->
					PowerCount2 = maps:put(Power, Count+1, PowerCount),
					WelFare2 = WelFare#welfare{power=PowerCount2},
					game_misc:write(welfare, WelFare2),
					{PowerCount2, Gain2};
				false->
					{PowerCount, Gain}
			end;
		false->
			{PowerCount, Gain}
    end,
    role_bag:gain(NewGain, ?LOG_WELFARE_POWER_REWARD, RoleSt),
    PowerReward2 = [Power | PowerReward],
    role_data:set(RoleWelfare#role_welfare{power=PowerReward2}),
    ?ucast(#m_welfare_power_toc{power=PowerReward2, count=NewPowerCount}),
	{ok, #m_welfare_power_reward_toc{power=Power}, RoleSt};


%在线礼包
handle(?WELFARE_ONLINE, _Tos, RoleSt)->
	#role_st{role=RoleID} = RoleSt,
	#role_welfare{online=OnlineReward} = role_data:get(?DB_ROLE_WELFARE),
	OnlineTime = online_server:get_today_time(RoleID),
	{ok, #m_welfare_online_toc{ids=OnlineReward, online_time=OnlineTime}, RoleSt};

%领取在线礼包
handle(?WELFARE_ONLINE_REWARD, Tos, RoleSt)->
	#role_st{role=RoleID} = RoleSt,
	#m_welfare_online_reward_tos{id=Id} = Tos,
	#cfg_welfare_online_reward{reward=Gain, time=Time} = cfg_welfare_online_reward:find(Id),
	RoleWelfare = #role_welfare{online=OnlineReward} = role_data:get(?DB_ROLE_WELFARE),
	case lists:member(Id, OnlineReward) of
		true  -> throw(?err(?ERR_WELFARE_REWARD_IS_GOT));
		false -> ignor
	end,
	OnlineTime = online_server:get_today_time(RoleID),
	?_check(OnlineTime >= Time, ?ERR_WELFARE_CONDI_NOT_ENOUGH),
	role_bag:gain(Gain, ?LOG_WELFARE_ONLINE_REWARD, RoleSt),
	OnlineReward2 = [Id | OnlineReward],
	role_data:set(RoleWelfare#role_welfare{online=OnlineReward2}),
	{ok, #m_welfare_online_reward_toc{id=Id}, RoleSt};

%每日签到
handle(?WELFARE_SIGN, _Tos, RoleSt)->
	#role_welfare{sign=SignReward} = role_data:get(?DB_ROLE_WELFARE),
	#welfare_sign{signs=Signs,count=Count} = SignReward,
	MaxDays = get_max_days(Signs),
	FreeCount = role_count:get_times(?ROLE_COUNT_WELFARE_SIGN),
	IsSign = case FreeCount == 1 of
		true  -> true;
		false -> false
	end,
	{ok, #m_welfare_sign_toc{signs=Signs,max_days=MaxDays,count=Count,is_sign=IsSign}, RoleSt};

%每日签到领奖
handle(?WELFARE_SIGN_REWARD, _Tos, RoleSt)->
	RoleWelfare = #role_welfare{sign=SignReward} = role_data:get(?DB_ROLE_WELFARE),
	#welfare_sign{signs=Signs,count=Count} = SignReward,
	FreeCount = role_count:get_times(?ROLE_COUNT_WELFARE_SIGN),
	%获取补签次数
	VipLv = role_vip:get_level(),
	VipCount = cfg_vip_rights:find(?VIP_RIGHTS_17, VipLv, 0),
	MaxDays = get_max_days(Signs),
	?_check(Signs < MaxDays, ?ERR_WELFARE_IS_MAX_DAYS),
	Signs2 = Signs + 1,
	Count2 = case FreeCount == 0 of
		true  ->
			role_count:add_times(?ROLE_COUNT_WELFARE_SIGN),
			Count;
		false ->
			?_check(Count < VipCount, ?ERR_WELFARE_SIGN_COUNT_WRONG),
			TotalActive = daily_handler:get_total(),
			#cfg_welfare_sign_count{active=NeedActive} = cfg_welfare_sign_count:find(Count+1),
			?_check(TotalActive >= NeedActive, ?ERR_WELFARE_ACTIVE_NOT_ENOUGH),
			Count+1
	end,
	#cfg_welfare_sign_reward{reward=Gain, vip=NeedVip} = cfg_welfare_sign_reward:find(Signs2),
	Gain2 = case NeedVip > 0 andalso VipLv >= NeedVip of
		true  -> double_gain(Gain, []);
		false -> Gain
	end,
	role_bag:gain(Gain2, ?LOG_WELFARE_SIGN_REWARD, RoleSt),
	SignReward2 = SignReward#welfare_sign{signs=Signs2, count=Count2},
	role_data:set(RoleWelfare#role_welfare{sign=SignReward2}),
	?ucast(#m_welfare_sign_toc{signs=Signs2,max_days=MaxDays,count=Count2,is_sign=true}),
	role_event:event(?EVENT_WELFARE_SIGN),
	{ok, #m_welfare_sign_reward_toc{}, RoleSt};

%圣杯祝福
handle(?WELFARE_GRAIL, _Tos, RoleSt)->
	Count = role_count:get_times(?ROLE_COUNT_WELFARE_GRAIL),
	{ok, #m_welfare_grail_toc{count=Count}, RoleSt};

%圣杯祝福领奖
handle(?WELFARE_GRAIL_REWARD, _Tos, RoleSt)->
	Count = role_count:get_times(?ROLE_COUNT_WELFARE_GRAIL),
	NewCount = Count+1,
	CfgWareCost = cfg_welfare_grail_cost:find(NewCount),
	?_check(CfgWareCost /= ?nil, ?ERR_WELFARE_GRAIL_COUNT_IS_MAX),
	#cfg_welfare_grail_cost{cost=Cost} = CfgWareCost,
	#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
	Ids = cfg_welfare_grail_reward:find_ids(),
	Gain = grail_gain(Ids, Level, NewCount),
	role_bag:deal(Cost, Gain, ?LOG_WELFARE_GRAIL_REWARD, RoleSt),
	role_count:add_times(?ROLE_COUNT_WELFARE_GRAIL),
	role_event:event(?EVENT_WELFARE_GRAIL),
	notify_grail(Gain, NewCount),
	{ok, #m_welfare_grail_reward_toc{}, RoleSt};

%更新公告
handle(?WELFARE_NOTICE, Tos, RoleSt)->
	#m_welfare_notice_tos{id=ID} = Tos,
	#role_welfare{notice=NoticeReward} = role_data:get(?DB_ROLE_WELFARE),
	IsGet = case lists:member(ID, NoticeReward) of
		true  -> true;
		false ->false
	end,
	{ok, #m_welfare_notice_toc{id=ID,is_get=IsGet}, RoleSt};

%更新公告领奖
handle(?WELFARE_NOTICE_REWARD, Tos, RoleSt)->
	#m_welfare_notice_reward_tos{id=ID} = Tos,
	RoleWelfare = #role_welfare{notice=NoticeReward} = role_data:get(?DB_ROLE_WELFARE),
	?_check(not lists:member(ID, NoticeReward), ?ERR_WELFARE_REWARD_IS_GOT),
	#cfg_welfare_notice_reward{reward=Gain, start_time=STime, end_time=ETime, state=State}
	= cfg_welfare_notice_reward:find(ID),
	?_check(State==1, ?ERR_WELFARE_CONDI_NOT_ENOUGH),
	STime2 = ut_time:datetime_to_seconds(ut_time:string_to_datetime(STime)),
	ETime2 = ut_time:datetime_to_seconds(ut_time:string_to_datetime(ETime)),
	Now = ut_time:seconds(),
	?_check(Now >= STime2 andalso Now =< ETime2, ?ERR_WELFARE_NOT_IN_DURATION),
	?_check(length(Gain)>0, ?ERR_WELFARE_REWARD_WRONG),
	role_bag:gain(Gain, ?LOG_WELFARE_NOTICE_REWARD, RoleSt),
	NoticeReward2 =  [ID | NoticeReward],
	role_data:set(RoleWelfare#role_welfare{notice=NoticeReward2}),
	{ok, #m_welfare_notice_reward_toc{id=ID}, RoleSt};

%兑换码
handle(?WELFARE_GIFTCODE, Tos, RoleSt=#role_st{user=User}) ->
	#m_welfare_giftcode_tos{code=Code} = Tos,
	case cfg_gift_code:find(string:lowercase(Code), User#game_user.gamechan) of
		?nil ->
			RoleInfo = role_data:get(?DB_ROLE_INFO),
			#role_info{id=RoleID, name=RoleName, userid={Chan,_}, level=Level} = RoleInfo,
			VipLv = role_vip:get_level(),
			Path  = "/api/server/redeem?code=~s&chan=~s&id=~w&name=~ts&level=~w&viplv=~w",
			case web_request:get(Path, [Code, Chan, RoleID, RoleName, Level, VipLv]) of
		        {ok, Resp} ->
					Result  = jiffy:decode(Resp, [return_maps]),
					RetCode = maps:get(<<"code">>, Result),
		        	case RetCode of
						0 ->
		        			Reward = maps:get(<<"reward">>, Result),
		        			Gain   = lists:map(fun
		    					(KV) ->
		    						ID  = ut_conv:to_integer(maps:get(<<"id">>, KV)),
		    						Num = ut_conv:to_integer(maps:get(<<"num">>, KV)),
		    						{ID, Num}
		    				end, Reward),
		    				?debug("gain:~w", [Gain]),
		    				role_bag:gain(Gain, ?LOG_WELFARE_NOTICE_REWARD, RoleSt);
		        		_ ->
		        			?debug("redeem:~ts", [maps:get(<<"msg">>, Result, "unknown")]),
		        			throw(?err(ut_conv:to_integer(RetCode)))
		        	end;
				_ ->
		            ?fatal("fetch giftcode error", []),
		            throw(?err(?ERR_GAME_SYS_ERROR))
		    end;
		Rewards ->
			RoleWelfare = #role_welfare{misc=Misc} = role_data:get(?DB_ROLE_WELFARE),
			FetchKey = ut_conv:to_atom(string:lowercase(Code)),
			?_check(not maps:get(FetchKey, Misc, false), ?ERR_REDEEM_HAD_FETCH),
			role_bag:gain(Rewards, ?LOG_WELFARE_NOTICE_REWARD, RoleSt),
			role_data:set(RoleWelfare#role_welfare{misc=maps:put(FetchKey, true, Misc)})
	end,
	{ok, #m_welfare_giftcode_toc{}, RoleSt};

%资源大礼
handle(?WELFARE_RES, _Tos, RoleSt)->
	#role_welfare{res=ResReward} = role_data:get(?DB_ROLE_WELFARE),
	IsGet = case ResReward == 0 of
		true  -> false;
		false -> true
	end,
	{ok, #m_welfare_res_toc{is_get=IsGet}, RoleSt};

%领取资源大礼
handle(?WELFARE_RES_REWARD, _Tos, RoleSt)->
	RoleWelfare = #role_welfare{res=ResReward} = role_data:get(?DB_ROLE_WELFARE),
	?_check(ResReward == 0, ?ERR_WELFARE_REWARD_IS_GOT),
	#cfg_welfare_res_reward{reward=Gain} = cfg_welfare_res_reward:find(1),
	role_bag:gain(Gain, ?LOG_WELFARE_RES_REWARD, RoleSt),
	role_data:set(RoleWelfare#role_welfare{res=1}),
	?ucast(#m_welfare_res_toc{is_get=true}),
	{ok,#m_welfare_res_reward_toc{}, RoleSt};

%% 其他福利
handle(?WELFARE_MISC, _Tos, RoleSt) ->
	#role_welfare{misc=Misc} = role_data:get(?DB_ROLE_WELFARE),
	send_misc_welfares(Misc, RoleSt);

handle(?WELFARE_MISC_REWARD, Tos, RoleSt) ->
	#m_welfare_misc_reward_tos{type=Type} = Tos,
	RoleWelfare = #role_welfare{misc=Misc} = role_data:get(?DB_ROLE_WELFARE),
	?_check(not maps:get(Type, Misc, false), ?ERR_WELFARE_REWARD_IS_GOT),
	Gain = proplists:get_value(Type, cfg_game:welfare_misc(), []),
	{ok, Obtain} = role_bag:gain(Gain, ?LOG_WELFARE_MSIC_REWARD, RoleSt),
	role_data:set(RoleWelfare#role_welfare{misc=maps:put(Type, true, Misc)}),
	?ucast(#m_welfare_misc_reward_toc{type=Type, reward=Obtain});

%%上线任选福利
handle(?WELFARE_LOGIN_REWARD_INFO, _Tos, RoleSt) ->
	#role_welfare{login_choose_reward=RewardList} = role_data:get(?DB_ROLE_WELFARE),
	{ok, #m_welfare_login_reward_info_toc{reward_list=RewardList}, RoleSt};

%%上线任选福利领取
handle(?WELFARE_GET_LOGIN_REWARD, Tos, RoleSt) ->
	#m_welfare_get_login_reward_tos{reward_list=IdList} = Tos,
	#role_pay{payments=Payments} = role_data:get(?DB_ROLE_PAY),
	RoleWelfare = #role_welfare{login_choose_reward=RewardList} = role_data:get(?DB_ROLE_WELFARE),
	RGoodsList = [GoodsId ||#payment{goods_id = GoodsId} <- Payments],
	GetRewardList = lists:foldl(fun(Id,Acc)-> cfg_login_gift:get_reward(Id) ++ Acc end,[],IdList),
	RechargeIdList = lists:foldl(fun(Id,Acc) -> [cfg_login_gift:get_recharge_id(Id)] ++ Acc end,[],IdList),
	ResRecharge = lists:all(fun(Id)->lists:member(Id,RGoodsList)end,RechargeIdList),
	case RewardList =:= [] orelse ResRecharge of
		true -> %% 第一次领取 或 已充值
			ResReward = lists:all(fun(Id)->lists:member(Id,RewardList)end,IdList),  %%正常情况发送过来的Id是未领取
			case ResReward of
				false ->  %% 没领取
					role_bag:gain(GetRewardList,?LOG_WELFARE_LOGIN_CHOOSE_REWARD,RoleSt),
					RewardList2 = IdList ++ RewardList ,
					role_data:set(RoleWelfare#role_welfare{login_choose_reward = RewardList2}),
					{ok, #m_welfare_get_login_reward_toc{res = 1}, RoleSt};
				true -> %% 已领取
					throw(?err(?ERR_WELFARE_REWARD_IS_GOT))
			end;
		false ->
			throw(?err(?ERR_WELFARE_REWARD_IS_GOT))
	end.


hook_reset(_DoW, _Hour, RoleSt) ->
	RoleWelfare = #role_welfare{misc=Misc} = role_data:get(?DB_ROLE_WELFARE),
	Misc2 = maps:without([2], Misc),
	role_data:set(RoleWelfare#role_welfare{misc=Misc2}),
	send_misc_welfares(Misc2, RoleSt).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%获取已领取
get_welfare()->
	game_misc:read(welfare, #welfare{level=#{}, power=#{}}).

%圣杯祝福经验
grail_gain([], _Level, _Count)->
	[];
grail_gain([Id|Ids], Level, Count)->
	#cfg_welfare_grail_reward{down_line=Down, up_line=Up} =
	cfg_welfare_grail_reward:find(Id),
	case Level >= Down andalso Level =< Up of
		true  ->
			#cfg_welfare_grail_reward_exp{exp=Gain} = cfg_welfare_grail_reward_exp:find(Id, Count),
			Gain;
		false ->
			grail_gain(Ids, Level, Count)
	end.

%双倍
double_gain([], Result) ->
	Result;
double_gain([Gain|Gains], Result)->
	Result2 = case Gain of
		{ItemId, Num, Bind} ->
			[{ItemId, Num*2, Bind} | Result];
		{ItemId, Num} ->
			[{ItemId, Num*2} | Result]
	end,
	double_gain(Gains, Result2).

%获取最大可签到天数
get_max_days(Signs)->
	#role_info{ctime=CTime} = role_data:get(?DB_ROLE_INFO),
	Days = ut_time:diff_days(CTime, ut_time:seconds()) + 1,
	Ids = cfg_welfare_sign_reward:ids(),
	Rem = Days rem length(Ids),
	MaxDays = case Rem == 0 of
		true  -> Days;
		false -> Rem
	end,
	case MaxDays < Signs of
		true  -> min(Days, length(Ids));
		false -> MaxDays
	end.

%祈福公告
notify_grail(Gain, Count)->
	case Count rem 5 of
		0 ->
			#role_info{id=RoleId, name=RoleName} = role_data:get(?DB_ROLE_INFO),
			[{_ItemId, Num}] = Gain,
			?notify(?MSG_WELFARE_GRAIL, [{role,RoleId,RoleName}, Num]);
		_ ->
			ignore
	end.

send_misc_welfares(Misc, RoleSt) ->
	Welfares = lists:foldl(fun
		(Type, Acc) ->
			IsGet  = maps:get(Type, Misc, false),
			IsOpen = true,
			[#p_welfare_misc{type=Type, is_open=IsOpen, is_get=IsGet} | Acc]
	end, [], misc_welfares()),
	?_if(Welfares /= [], ?ucast(#m_welfare_misc_toc{welfares=Welfares})).

misc_welfares() ->
	case sdk:route() of
		{tanwan, _} ->
			[1,2,3,4,5];
		_ ->
			[]
	end.
