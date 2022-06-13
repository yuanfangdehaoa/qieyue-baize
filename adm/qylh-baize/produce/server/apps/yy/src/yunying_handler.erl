%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(yunying_handler).

-include("bag.hrl").
-include("game.hrl").
-include("guild.hrl").
-include("item.hrl").
-include("role.hrl").
-include("yunying.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/3]).
-export([hook_upgrade/2]).
-export([hook_wake/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 活动列表
handle(?YUNYING_LIST, _Tos, RoleSt) ->
	#role_info{level=RoleLv, wake=Wake} = role_data:get(?DB_ROLE_INFO),
	ActList = lists:filtermap(fun
		(YYAct) ->
			case can_join(YYAct, RoleLv, Wake) of
				false ->
					false;
				true  ->
					{true, #p_yy_activity{
						id         = YYAct#yy_act.id,
						act_stime  = YYAct#yy_act.act_stime,
						act_etime  = YYAct#yy_act.act_etime,
						show_stime = YYAct#yy_act.show_stime,
						show_etime = YYAct#yy_act.show_etime
					}}
			end
	end, ets:tab2list(?ETS_YY_ACT)),
	?ucast(#m_yunying_list_toc{activities=ActList});

%% 活动信息
handle(?YUNYING_INFO, Tos, RoleSt) ->
	#role_st{role=RoleID, guild=GuildID} = RoleSt,
	#m_yunying_info_tos{id=YYActID} = Tos,
	case yunying:is_start(YYActID) of
		true when YYActID == ?YYACT_GUILD ->
			#yy_role{tasks=Tasks} = yunying_agent:get_yy_role(YYActID, RoleID),
			#role_guild{post=Post} = role_data:get(?DB_ROLE_GUILD),
			#yy_info{misc=AllMisc} = yunying_manager:get_yy_info(YYActID),
			Counter  = maps:get({global,YYActID}, AllMisc, #{}),
			AllFetch = maps:get({guild,YYActID}, AllMisc, #{}),
			MyFetch  = maps:get(GuildID, AllFetch, []),
			case GuildID > 0 of
				true  ->
					{ok, [GuildInfo]} = guild:get_data(GuildID, [?DB_GUILD_INFO]);
				false ->
					GuildInfo = ?nil
			end,
			Tasks2 = maps:map(fun
				(_, Task) ->
					Task1 = case
						GuildID > 0 andalso Post == ?GUILD_POST_CHIEF andalso
						Task#yy_task.state /= ?YY_TASK_STATE_REWARD andalso
						is_finish(YYActID, {Task, GuildInfo})
					of
						true  ->
							State = case lists:member(Task#yy_task.id, MyFetch) of
								true  -> ?YY_TASK_STATE_REWARD;
								false -> ?YY_TASK_STATE_FINISH
							end,
							Task#yy_task{state=State};
						false ->
							Task
					end,
					Task1#yy_task{count=maps:get(Task#yy_task.id, Counter, 0)}
			end, Tasks),
			?ucast(#m_yunying_info_toc{
				id    = YYActID,
				tasks = [yunying_util:p_yy_task(YYActID, Task) || Task <- maps:values(Tasks2)]
			});
		true  ->
			#yy_role{tasks=Tasks} = yunying_agent:get_yy_role(YYActID, RoleID),
			?ucast(#m_yunying_info_toc{
				id    = YYActID,
				tasks = [yunying_util:p_yy_task(YYActID, Task) || Task <- maps:values(Tasks)]
			});
		false ->
			?ucast(#m_yunying_info_toc{id=YYActID, tasks=[]})
	end;

%% 领取奖励
handle(?YUNYING_FETCH, Tos, RoleSt) ->
	#role_st{role=RoleID, guild=GuildID} = RoleSt,
	#m_yunying_fetch_tos{act_id=YYActID, id=RewardID} = Tos,
	YYInfo = yunying_manager:get_yy_info(YYActID),
	YYRole = yunying_agent:get_yy_role(YYActID, RoleID),
	#yy_info{settle=IsSettle, misc=AllMisc} = YYInfo,
	?_check(not IsSettle, ?ERR_YUNYING_HAD_FETCH),
	Task = maps:get(RewardID, YYRole#yy_role.tasks, ?nil),
	?_check(Task /= ?nil, ?ERR_YUNYING_NOT_REACH),
	#yy_task{state=State} = Task,
	?_check(State /= ?YY_TASK_STATE_REWARD, ?ERR_YUNYING_HAD_FETCH),
	Mod = yunying_util:cfg_act_mod(YYInfo#yy_info.id),
	#cfg_yunying{form=Form} = Mod:find(YYActID),
	IsFinish = Form == exch orelse Form == guild orelse State == ?YY_TASK_STATE_FINISH,
	?_check(IsFinish, ?ERR_YUNYING_NOT_REACH),
	ModReward = yunying_util:cfg_reward_mod(YYActID),
	CfgReward = ModReward:find(YYActID, RewardID),
	#cfg_yunying_reward{cost=Cost, limit=Limit} = CfgReward,
	case Limit of
		?nil ->
			ok;
		{personal, MaxTimes} ->
			?_check(Task#yy_task.count < MaxTimes, ?ERR_YUNYING_PERSONAL_LIMIT);
		{global, MaxTimes} ->
			Counter  = maps:get({global,YYActID}, AllMisc, #{}),
			CurTimes = maps:get(RewardID, Counter, 0),
			?_check(CurTimes < MaxTimes, ?ERR_YUNYING_GLOBAL_LIMIT),
			case YYActID == ?YYACT_GUILD of
				true  ->
					?_check(GuildID > 0, ?ERR_YUNYING_NOT_GUILD_CHIEF),
					#role_guild{post=Post} = role_data:get(?DB_ROLE_GUILD),
					?_check(Post == ?GUILD_POST_CHIEF, ?ERR_YUNYING_NOT_GUILD_CHIEF),
					AllFetch = maps:get({guild,YYActID}, AllMisc, #{}),
					MyFetch  = maps:get(GuildID, AllFetch, []),
					IsFetch  = lists:member(RewardID, MyFetch),
					?_check(not IsFetch, ?ERR_YUNYING_HAD_FETCH),
					{ok, [GuildInfo]} = guild:get_data(GuildID, [?DB_GUILD_INFO]),
					IsFinish = is_finish(YYActID, {Task, GuildInfo}),
					?_check(IsFinish, ?ERR_YUNYING_NOT_REACH);
				false ->
					ok
			end
	end,
	Gain = yunying_reward:calc(RoleID, YYActID, RewardID, YYRole#yy_role.tasks),
	Succ = fun() ->
		Task2 = case Limit of
			?nil ->
				Task#yy_task{state=?YY_TASK_STATE_REWARD};
			{personal, MaxTimes2} ->
				Times2 = Task#yy_task.count + 1,
				Task1  = Task#yy_task{count=Times2},
				case Times2 >= MaxTimes2 of
					true  -> Task1#yy_task{state=?YY_TASK_STATE_REWARD};
					false -> Task1
				end;
			{global, _} ->
				OldCnt = maps:get({global,YYActID}, AllMisc, #{}),
				NewCnt = ut_misc:maps_increase(RewardID, 1, OldCnt),
				AllMisc1 = maps:put({global,YYActID}, NewCnt, AllMisc),
				AllMisc2 = case YYActID == ?YYACT_GUILD of
					true  ->
						Fetch  = maps:get({guild,YYActID}, AllMisc, #{}),
						Fetch2 = ut_misc:maps_append(GuildID, RewardID, Fetch),
						maps:put({guild,YYActID}, Fetch2, AllMisc1);
					false ->
						AllMisc1
				end,
				YYInfo2  = YYInfo#yy_info{misc=AllMisc2},
				ok = yunying_manager:set_yy_info(YYInfo2),
				Task#yy_task{state=?YY_TASK_STATE_REWARD}
		end,
		Tasks2 = maps:put(RewardID, Task2, YYRole#yy_role.tasks),
		yunying_agent:set_yy_role(YYActID, YYRole#yy_role{tasks=Tasks2})
	end,
	{ok, _Expend, Obtain, _} =
		role_bag:deal(Cost, Gain, yunying_util:calc_logid(YYActID), Succ, RoleSt, true),
	?_if(Obtain /= [], do_notify(YYInfo, Task, Obtain, RoleSt)),
	Obtain2 = role_bag:obtain_to_maps(Obtain),
	?ucast(#m_yunying_fetch_toc{act_id=YYActID, id=RewardID, reward=Obtain2});

handle(?YUNYING_GIFT, Tos, RoleSt) ->
	yunying_gift:handle(Tos, RoleSt);

%% 领取奖励
handle(?YUNYING_GIFT_FETCH, Tos, RoleSt) ->
	yunying_gift:handle(Tos, RoleSt);

handle(?YUNYING_LOGS, Tos, RoleSt) ->
	#m_yunying_logs_tos{act_id=YYActID} = Tos,
	Logs = game_logger:get_logs({yunying_logs, YYActID}),
	?ucast(#m_yunying_logs_toc{act_id=YYActID, logs=Logs});

handle(?YUNYING_LOTTERY_INFO, Tos, RoleSt) ->
	yunying_lottery:handle(Tos, RoleSt);

%% 领取奖励
handle(?YUNYING_LOTTERY_DO, Tos, RoleSt) ->
	yunying_lottery:handle(Tos, RoleSt);

handle(?YUNYING_LOTTERY_DRAW, Tos, RoleSt)->
	yunying_lottery:handle(Tos, RoleSt);

%% 领取奖励
handle(?YUNYING_LOTTERY_REFRESH, Tos, RoleSt) ->
	yunying_lottery:handle(Tos, RoleSt);

%% 转盘
handle(?YUNYING_LOTOINFO, Tos, RoleSt) ->
	yunying_lottery:handle(Tos, RoleSt);

%% 领取奖励
handle(?YUNYING_LOTO, Tos, RoleSt) ->
	yunying_lottery:handle(Tos, RoleSt);

handle(?YUNYING_SHOP_INFO, Tos, RoleSt) ->
	yunying_lottery:handle(Tos, RoleSt);

handle(?YUNYING_SHOP_BUY, Tos, RoleSt) ->
	yunying_lottery:handle(Tos, RoleSt);

handle(?YUNYING_SHOP_REWARD_LOG, Tos, RoleSt) ->
	yunying_lottery:handle(Tos, RoleSt).


hook_upgrade(NewLv, RoleSt) ->
	#role_info{wake=Wake} = role_data:get(?DB_ROLE_INFO),
	lists:foreach(fun
		(YYActID) ->
			case ets:lookup(?ETS_YY_ACT, YYActID) of
				[YYAct] ->
					case can_join(YYAct, NewLv, Wake) of
						true  ->
							?ucast(#m_yunying_start_toc{
								activity = #p_yy_activity{
									id         = YYAct#yy_act.id,
									act_stime  = YYAct#yy_act.act_stime,
									act_etime  = YYAct#yy_act.act_etime,
									show_stime = YYAct#yy_act.show_stime,
									show_etime = YYAct#yy_act.show_etime
								}
							});
						false ->
							ignore
					end;
				[] ->
					ignore
			end
	end, cfg_yunying:level(NewLv) ++ cfg_festival:level(NewLv)).

hook_wake(NewWake, RoleSt) ->
	#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
	lists:foreach(fun
		(YYActID) ->
			case ets:lookup(?ETS_YY_ACT, YYActID) of
				[YYAct] ->
					case can_join(YYAct, Level, NewWake) of
						true  ->
							?ucast(#m_yunying_start_toc{
								activity = #p_yy_activity{
									id         = YYAct#yy_act.id,
									act_stime  = YYAct#yy_act.act_stime,
									act_etime  = YYAct#yy_act.act_etime,
									show_stime = YYAct#yy_act.show_stime,
									show_etime = YYAct#yy_act.show_etime
								}
							});
						false ->
							ignore
					end;
				[] ->
					ignore
			end
	end, cfg_yunying:wake(NewWake) ++ cfg_festival:wake(NewWake)).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_notify(YYInfo, Task, [Item | _], RoleSt) ->
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	#yy_info{id=YYActID} = YYInfo,
	#yy_task{id=TaskID} = Task,
	Mod = yunying_util:cfg_act_mod(YYActID),
	#cfg_yunying{name=ActName, form=Form} = Mod:find(YYActID),
	ModReward = yunying_util:cfg_reward_mod(YYActID),
	CfgReward = ModReward:find(YYActID, TaskID),
	#cfg_yunying_reward{reqs=Reqs, reward=Reward, goal=Goal, misc=Misc} = CfgReward,
	if
		Form == 'pay', is_record(Item, p_item) ->
			#cfg_item{name=ItemName, color=Color} = cfg_item:find(Item#p_item.id),
			case Goal of
				{_, Amount} ->
					ok;
				{_, _, Amount} ->
					ok
			end,
			CfgMod = yunying_util:cfg_act_mod(YYActID),
			Panel  = CfgMod:panel(YYActID),
			?notify(?MSG_YUNYING_PAY, [
				{role,RoleID,RoleName},
				ActName,
				Amount,
				ut_color:format(ItemName, Color),
				Item#p_item.num,
				{"panel",Panel}
			]);
		YYActID == 120201, is_record(Item, p_item) ->
			#cfg_item{name=ItemName, color=Color} = cfg_item:find(Item#p_item.id),
			?notify(?MSG_YUNYING_MARRIAGE, [
				{role,RoleID,RoleName},
				ut_color:format(ItemName, Color),
				Item#p_item.num
			]);
		YYActID == 130301 ->
			?notify(?MSG_YUNYING_VIPLV, [{role,RoleID,RoleName}]);
		YYActID == 150501; YYActID == 240101  ->
			case lists:keymember(recommend, 1, Misc) of
				true  ->
					#cfg_item{name=ItemName, color=Color} = cfg_item:find(Item#p_item.id),
					MsgNo = case YYActID of
						150501 -> ?MSG_YUNYING_EXCH;
						240101 -> ?MSG_YUNYING_EXCH2
					end,
					?notify(MsgNo, [
						{role,RoleID,RoleName},
						ActName,
						ut_color:format(ItemName, Color)
					]);
				false ->
					ignore
			end;
		YYActID == 240401, is_record(Item, p_item) ->
			#cfg_item{name=ItemName, color=Color, notify=Notify} = cfg_item:find(Item#p_item.id),
			CfgMod = yunying_util:cfg_act_mod(YYActID),
			Panel  = CfgMod:panel(YYActID),
			Notify andalso ?notify(?MSG_YUNYING_PAY2, [
				{role,RoleID,RoleName},
				ActName,
				ut_color:format(ItemName, Color),
				Item#p_item.num,
				{"panel",Panel}
			]);
		(YYActID == 100601 orelse YYActID == 100701) andalso is_record(Item, p_item) ->
			#cfg_item{name=ItemName, color=Color, notify=Notify} = cfg_item:find(Item#p_item.id),
			Notify andalso ?notify(?MSG_YUNYING_PAY3, [
				{role,RoleID,RoleName},
				ActName,
				ut_color:format(ItemName, Color),
				Item#p_item.num
			]);
		true ->
			ignore
	end,
	case Reqs of
		[{broadcast, _N} | _] ->
			ItemMap = case Reward of
				[{ItemId, Num} | _] -> maps:put(ItemId, Num, #{});
				[{ItemId, Num, _Bind} | _] -> maps:put(ItemId, Num, #{});
				_ -> #{}
			end,
			?notify(?MSG_SEARCHTREASURE_YY_BROADCAST,[
				{role,RoleID,RoleName},
				ActName,
				{item, ItemMap}
			]);
		_ ->
			ignore
	end.

can_join(YYAct, RoleLv, Wake) ->
	YYAct#yy_act.show_state == ?YY_ST_STARTED andalso
	YYAct#yy_act.join_level =< RoleLv andalso
	YYAct#yy_act.join_wake =< Wake.

is_finish(YYActID = ?YYACT_GUILD, {Task, Guild}) ->
	Mod = yunying_util:cfg_reward_mod(YYActID),
	#cfg_yunying_reward{goal=Goal} = Mod:find(YYActID, Task#yy_task.id),
	case Task#yy_task.event of
		?EVENT_GUILD_CREATE ->
			#role_guild{post=Post} = role_data:get(?DB_ROLE_GUILD),
			Post == ?GUILD_POST_CHIEF;
		?EVENT_GUILD_APPOINT ->
			{CfgPost, CfgNum} = Goal,
			Num = length([M ||
				M <- Guild#guild_info.membs,
				M#guild_memb.post == CfgPost
			]),
			Num >= CfgNum;
		?EVENT_GUILD_NUM ->
			length(Guild#guild_info.membs) >= Goal;
		?EVENT_GUILD_LEVEL ->
			Guild#guild_info.level >= Goal
	end.
