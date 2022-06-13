%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(yunying_task).

-include("game.hrl").
-include("mount.hrl").
-include("pet.hrl").
-include("role.hrl").
-include("yunying.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("table.hrl").
-include("boss.hrl").
-include("equip.hrl").
-include("item.hrl").

%% API
-export([hook_login/1]).
-export([add_listen/2]).
-export([del_listen/1]).
-export([notify/4]).
-export([reset/2]).
-export([continue_reset/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
hook_login(RoleSt) ->
	NTime = ut_time:seconds(),
	lists:foreach(fun
		(YYAct) ->
			#yy_act{
				id=YYActID, act_state=State, show_stime=STime, show_etime=ETime
			} = YYAct,
			case STime =< NTime andalso NTime =< ETime of
				true  -> add_listen(YYActID, State == ?YY_ST_STARTED, RoleSt);
				false -> ignore
			end
	end, ets:tab2list(?ETS_YY_ACT)).

add_listen(YYActID, RoleSt) ->
	add_listen(YYActID, true, RoleSt).

add_listen(YYActID, Listen, _RoleSt = #role_st{role=RoleID}) ->
	Tasks  = make_tasks(RoleID, YYActID, Listen),
	YYRole = yunying_agent:get_yy_role(YYActID, RoleID),
	Tasks2 = maps:fold(fun
		(Level, Task, Acc) ->
			case maps:is_key(Level, Acc) of
				true  -> Acc;
				false -> maps:put(Level, Task, Acc)
			end
	end, YYRole#yy_role.tasks, Tasks),
	yunying_agent:set_yy_role(YYActID, YYRole#yy_role{tasks=Tasks2}).

del_listen(YYActID) ->
	lists:foreach(fun(TaskID) ->
		Mod = yunying_util:cfg_reward_mod(YYActID),
		#cfg_yunying_reward{event=Event} = Mod:find(YYActID, TaskID),
		?_if(Event > 0, role_event:remove(Event, ?MODULE, notify, YYActID))
	end, cfg_yunying_reward:tasks(YYActID) ++ cfg_festival_reward:tasks(YYActID)).

%% 更新活动数据
notify(Event, YYActID, Args, RoleSt = #role_st{role=RoleID}) ->
	case yunying:is_start(YYActID) of
		true  ->
			YYRole = yunying_agent:get_yy_role(YYActID, RoleID),
			#yy_role{tasks=Tasks, finish=Finish} = YYRole,
			case update_tasks(YYActID, Tasks, Event, Args, RoleSt) of
				{ok, true, Tasks2} ->
					IsFinish = lists:all(fun
						(Task) ->
							Task#yy_task.state == ?YY_TASK_STATE_FINISH orelse
							Task#yy_task.state == ?YY_TASK_STATE_REWARD
					end, maps:values(Tasks2)),
					Finish2 = ?_if(IsFinish, ut_time:seconds(), Finish),
					YYRole2 = YYRole#yy_role{tasks=Tasks2, finish=Finish2},
					yunying_agent:set_yy_role(YYActID, YYRole2),
					?ucast(#m_yunying_info_toc{
						id    = YYActID,
						tasks = [yunying_util:p_yy_task(YYActID, Task) || Task <- maps:values(Tasks2)]
					});
				_ ->
					ignore
			end;
		false ->
			ignore
	end.

reset(YYActID, _RoleSt=#role_st{role=RoleID}) ->
	case yunying:is_start(YYActID) of
		true  ->
			Tasks  = make_tasks(RoleID, YYActID, true),
			YYRole = yunying_agent:get_yy_role(YYActID, RoleID),
			Tasks2 = maps:fold(fun
				(Level, Task, Acc) ->
					case maps:is_key(Level, Acc) of
						true  -> Acc;
						false -> maps:put(Level, Task, Acc)
					end
			end, #{}, Tasks),
			yunying_agent:set_yy_role(YYActID, YYRole#yy_role{tasks=Tasks2});
		false ->
			ignore
	end.

continue_reset(YYActID) ->
	case yunying:is_start(YYActID) of
		true  ->
			All = yunying_agent:get_yy_roles(YYActID),
			[begin
				#yy_role{tasks=Tasks} = YYRole,
				Tasks2 = maps:fold(fun(Level, Task, Acc) ->
					case Task of
						#yy_task{event=?EVENT_PAY, state=?YY_TASK_STATE_UNDONE} ->
							{Type, _, Amount} = find_reward(YYActID, Task),
							case Type == 4 of
								true  ->
									Yesterday = ut_time:yesterday(),
									Stat = role_pay:stat_daily(Yesterday, Yesterday),
									Total = maps:get(Yesterday, Stat, 0),
									case Total < Amount of
										true ->
											maps:put(Level, Task#yy_task{count=0}, Acc);
										false ->
											Acc
									end;
								false ->
									Acc
							end;
						_ ->
							Acc
					end
				end, Tasks, Tasks),
				yunying_agent:set_yy_role(YYActID, YYRole#yy_role{tasks=Tasks2})
			end || YYRole <- All];
		false ->
			ignore
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
make_tasks(RoleID, YYActID, Listen) ->
	Mod = yunying_util:cfg_reward_mod(YYActID),
	lists:foldl(fun
		(TaskID, AccTasks) ->
			CfgReward = Mod:find(YYActID, TaskID),
			#cfg_yunying_reward{event=Event, reqs=Reqs} = CfgReward,
			case Event > 0 andalso yunying_reward:listen_check(RoleID, Reqs, AccTasks) of
				true  ->
					?_if(Listen, role_event:listen(Event, ?MODULE, notify, YYActID)),
					Task = yy_task(Event, YYActID, TaskID),
					maps:put(TaskID, Task, AccTasks);
				false ->
					AccTasks
			end
	end, #{}, Mod:tasks(YYActID)).

yy_task(Event, YYActID, TaskID) ->
	Task = #yy_task{id=TaskID, event=Event, count=0},
	{Count, IsDone} = init_count(Event, YYActID, Task),
	State = case IsDone of
		true  -> ?YY_TASK_STATE_FINISH;
		false -> ?YY_TASK_STATE_UNDONE
	end,
	Task#yy_task{count=Count, state=State}.


init_count(Event=?EVENT_DUNGE, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal0} = find_reward(YYActID, Task),
	Goal  = erlang:tuple_to_list(Goal0),
	SType = proplists:get_value(stype, Goal, 0),
	case SType == ?SCENE_STYPE_DUNGE_GOD of
		true ->
			#dunge_god{cur_wave=CurWave} = role_data:get(?DB_DUNGE_GOD),
			update_count(Event, {SType, 0, 0, [{wave, CurWave}]}, YYActID, Task);
		false ->
			{0, false}
	end;
init_count(Event=?EVENT_VIPLV, YYActID, Task) ->
	VipLv = role_vip:get_level(),
	update_count(Event, VipLv, YYActID, Task);
init_count(Event=?EVENT_LEVEL, YYActID, Task) ->
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	update_count(Event, RoleLv, YYActID, Task);
init_count(Event=?EVENT_TRAIN_ORDER, YYActID, Task) ->
	#role_train{mounts=Mounts, trains=Trains} = role_data:get(?DB_ROLE_TRAIN),
	#cfg_yunying_reward{goal={Type,_,_}} = find_reward(YYActID, Task),
	if
		Type == ?TRAIN_MOUNT;
		Type == ?TRAIN_OFFHAND ->
			case maps:find(Type, Mounts) of
				{ok, #mount{order=Order, level=Level}} ->
					update_count(Event, {Type,Order,Level}, YYActID, Task);
				_ ->
					{0, false}
			end;
		true ->
			case maps:find(Type, Trains) of
				{ok, #p_train{level=Level}} ->
					update_count(Event, {Type,0,Level}, YYActID, Task);
				_ ->
					{0, false}
			end
	end;
init_count(Event=?EVENT_POWER, YYActID, Task) ->
	RolePower = role_util:get_power(),
	update_count(Event, RolePower, YYActID, Task);
init_count(Event=?EVENT_ILLUSTRATION_POWER, YYActID, Task) ->
	Power = illustration_handler:get_power(),
	update_count(Event, Power, YYActID, Task);
init_count(Event=?EVENT_BABY_POWER, YYActID, Task) ->
	Power = baby_handler:get_power(),
	update_count(Event, Power, YYActID, Task);
init_count(Event=?EVENT_LOGIN, YYActID, Task) ->
	case role_count:get_times(?ROLE_COUNT_LOGIN) > 0 of
		true ->
			update_count(Event, ?nil, YYActID, Task);
		false ->
			{0, false}
	end;
init_count(Event=?EVENT_WAKE, YYActID, Task) ->
	#role_info{wake=Wake} = role_data:get(?DB_ROLE_INFO),
	update_count(Event, Wake, YYActID, Task);
init_count(Event=?EVENT_DUNGE_FLOOR, YYActID, Task) ->
	#cfg_yunying_reward{goal={SType, _Times}} = find_reward(YYActID, Task),
	case SType  of
		?SCENE_STYPE_DUNGE_MAGICTOWER ->
			Floor = dunge_magic:get_clr_floor(),
			update_count(Event, {SType, 0, Floor}, YYActID, Task);
		?SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER ->
			Floor = yunying_dunge_limit_tower:get_clr_floor(YYActID),
			update_count(Event, {SType, 0, Floor}, YYActID, Task);
		_ ->
			{0, false}
	end;
init_count(Event=?EVENT_EQUIP, YYActID, Task) ->
	#role_equip{equips=Equips} = role_data:get(?DB_ROLE_EQUIP),
	update_count(Event, {0, 0, Equips}, YYActID, Task);
init_count(Event=?EVENT_EQUIP_CAST, YYActID, Task) ->
	update_count(Event, 0, YYActID, Task);
init_count(Event=?EVENT_STONE, YYActID, Task) ->
	#role_equip{stones=AllStones} = role_data:get(?DB_ROLE_EQUIP),
	update_count(Event, AllStones, YYActID, Task);
init_count(Event=?EVENT_EQUIP_REFINE_FINAL, YYActID, Task) ->
	#role_equip{refine=Refine} = role_data:get(?DB_ROLE_EQUIP),
	update_count(Event, Refine, YYActID, Task);
init_count(Event=?EVENT_EQUIP_STR_FINAL, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal0} = find_reward(YYActID, Task),
	Goal = erlang:tuple_to_list(Goal0),
	case is_list(Goal) of
		true ->
			case lists:keyfind(total_lv, 1, Goal) of
				{total_lv, _Total} ->
					update_count(Event, ?nil, YYActID, Task);
				_ ->
					{0, false}
			end;
		false ->
			{0, false}
	end;
init_count(Event=?EVENT_ADD_INTIMACY, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal0} = find_reward(YYActID, Task),
	Goal = erlang:tuple_to_list(Goal0),
	case is_list(Goal) of
		true ->
			case lists:keyfind(max, 1, Goal) of
				{max, _Max} ->
					update_count(Event, ?nil, YYActID, Task);
				_ ->
					{0, false}
			end;
		false ->
			{0, false}
	end;
init_count(_Event, _YYActID, _Task) ->
	{0, false}.

update_tasks(YYActID, _Tasks, ?EVENT_YY_ACT, Args, _RoleSt)
when is_tuple(Args), element(1,Args) =/= YYActID ->
	ignore;
update_tasks(YYActID, Tasks, Event, Args, RoleSt) ->
	Tasks2 = do_update_tasks(YYActID, Tasks, Event, Args, RoleSt),
	{ok, has_update(), Tasks2}.


do_update_tasks(YYActID, Tasks, Event1, Args, RoleSt) ->
	Mod = yunying_util:cfg_reward_mod(YYActID),
	maps:map(fun
		(TaskID, Task) when Task#yy_task.state == ?YY_TASK_STATE_UNDONE ->
			CfgReward = Mod:find(YYActID, TaskID),
			#cfg_yunying_reward{event=Event2, trigger=Trigger} = CfgReward,
			case Event1 =:= Event2 andalso update_count(Event1, Args, YYActID, Task) of
				{Count2, IsDone} ->
					set_update_flag(),
					State2 = case IsDone of
						true  -> ?YY_TASK_STATE_FINISH;
						false -> ?YY_TASK_STATE_UNDONE
					end,
					Task2 = Task#yy_task{count=Count2, state=State2},
					case Task /= Task2 andalso Trigger of
						{once, {NextEvent, NextArgs}} ->
							role_event:event(NextEvent, {YYActID, NextArgs, Count2-Task#yy_task.count});
						{done, {NextEvent, NextArgs}} when IsDone ->
							role_event:event(NextEvent, {YYActID, NextArgs, 1});
						_ ->
							ignore
					end,
					if
						IsDone, YYActID == 120201, Event1 == ?EVENT_YY_ACT ->
							Log = #p_yy_log{
								role_id   = RoleSt#role_st.role,
								role_name = RoleSt#role_st.name,
								item_id   = 0,
								item_num  = 0
							},
							game_logger:add_log({yunying_logs,YYActID}, Log);
						true ->
							ignore
					end,
					Task2;
				false ->
					Task
			end;
		(_TaskID, Task) ->
			Task
	end, Tasks).

set_update_flag() ->
	erlang:put({?MODULE, update_flag}, true).

has_update() ->
	erlang:erase({?MODULE, update_flag}) == true.

%% 充值
update_count(?EVENT_PAY, {CurPay, TodayOld, TodayNew}, YYActID, Task) ->
	#yy_task{count=Count} = Task,
	#cfg_yunying_reward{goal=Goal} = find_reward(YYActID, Task),
	case Goal of
		{1, Amount} -> % 累充
			Count2 = min(Amount, Count + CurPay),
			IsDone = Count2 >= Amount,
			{Count2, IsDone};
		{2, Amount} -> % 每日累充
			Count2 = TodayNew,
			IsDone = Count2 >= Amount,
			{Count2, IsDone};
		{3, Times, Amount} -> % 累充天数(如累计充值xx元宝xx天)
			Count2 = case TodayOld < Amount andalso Amount =< TodayNew of
				true  -> Count + 1;
				false -> Count
			end,
			IsDone = Count2 >= Times,
			{Count2, IsDone};
		{4, Times, Amount} -> % 连续累充（连续3天充300钻）
			Count2 = case TodayOld < Amount andalso Amount =< TodayNew of
				true  -> min(Times, Count + 1);
				false -> Count
			end,
			IsDone = Count2 >= Times,
			{Count2, IsDone};
		{Amount, Times} -> % 累充,完成多少次（次数只能1次）
			case ets:lookup(?ETS_YY_ACT, YYActID) of
				[#yy_act{act_stime=STime, act_etime=ETime}] ->
					Total = role_pay:calc(STime, ETime),
					if
						Total >= Amount ->
							Count2 = min(Count+1, Times),
							IsDone = Count2 >= Times,
							{Count2, IsDone};
						true ->
							false
					end;
				_ ->
					false
			end
	end;
update_count(?EVENT_TRAIN_ORDER, {Type, Order, Level}, YYActID, Task) ->
	#cfg_yunying_reward{goal={Type2,Order2,Level2}} = find_reward(YYActID, Task),
	case Type == Type2 of
		true  ->
			case Type of
				?TRAIN_MOUNT   ->
					ID  = cfg_mount:id(Order, Level),
					ID2 = cfg_mount:id(Order2, Level2);
				?TRAIN_OFFHAND ->
					ID  = cfg_offhand:id(Order, Level),
					ID2 = cfg_offhand:id(Order2, Level2);
				_ ->
					ID  = Level,
					ID2 = Level2
			end,
			Count  = ID,
			IsDone = ID >= ID2,
			{Count, IsDone};
		false ->
			false
	end;
update_count(?EVENT_LEVEL, Level, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal} = find_reward(YYActID, Task),
	Count  = Level,
	IsDone = Level >= Goal,
	{Count, IsDone};
update_count(?EVENT_POWER, Power, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal} = find_reward(YYActID, Task),
	Count  = Power,
	IsDone = Power >= Goal,
	{Count, IsDone};
update_count(?EVENT_ILLUSTRATION_POWER, Power, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal} = find_reward(YYActID, Task),
	Count  = Power,
	IsDone = Power >= Goal,
	{Count, IsDone};
update_count(?EVENT_BABY_POWER, Power, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal} = find_reward(YYActID, Task),
	Count  = Power,
	IsDone = Power >= Goal,
	{Count, IsDone};
update_count(?EVENT_CONSUME, Gold, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal} = find_reward(YYActID, Task),
	Count  = Gold + Task#yy_task.count,
	IsDone = Count >= Goal,
	{Count, IsDone};
update_count(?EVENT_MC_POWER, Power, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal} = find_reward(YYActID, Task),
	Count  = Power,
	IsDone = Count >= Goal,
	{Count, IsDone};
update_count(?EVENT_LOGIN, _, YYActID, Task) ->
	#yy_task{count=Count} = Task,
	#cfg_yunying_reward{goal={_, Times}} = find_reward(YYActID, Task),
	Count2 = min(Count+1, Times),
	IsDone = Count2 >= Times,
	{Count2, IsDone};
update_count(?EVENT_MARRY, MarryType1, YYActID, Task) ->
	#yy_task{count=Count} = Task,
	#cfg_yunying_reward{goal={MarryType2, Times}} = find_reward(YYActID, Task),
	case MarryType2 == 0 orelse MarryType1 == MarryType2 of
		true  ->
			Count2 = min(Count+1, Times),
			IsDone = Count2 >= Times,
			{Count2, IsDone};
		false ->
			false
	end;
update_count(?EVENT_YY_ACT, {_YYActID, Progress, Num}, YYActID, Task) ->
	#yy_task{count=Count} = Task,
	#cfg_yunying_reward{goal=Goal} = find_reward(YYActID, Task),
	Count2 = min(Count+trunc(Progress*Num), Goal),
	IsDone = Count2 >= Goal,
	{Count2, IsDone};
update_count(?EVENT_DUNGE_FLOOR, {SType, _Dunge, Floor}, YYActID, Task) ->
	#yy_task{count=Count} = Task,
	#cfg_yunying_reward{goal={SType2, Times}} = find_reward(YYActID, Task),
	case SType2 == SType of
		true when SType == ?SCENE_STYPE_DUNGE_MAGICTOWER; 
			SType == ?SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER ->
			Count2 = Floor,
			IsDone = Floor >= Times,
			{Count2, IsDone};
		true ->
			Count2 = min(Count+1, Times),
			IsDone = Count2 >= Times,
			{Count2, IsDone};
		false ->
			false
	end;
update_count(?EVENT_WELFARE_GRAIL, _, YYActID, Task) ->
	#yy_task{count=Count} = Task,
	#cfg_yunying_reward{goal={_, Times}} = find_reward(YYActID, Task),
	Count2 = min(Count+1, Times),
	IsDone = Count2 >= Times,
	{Count2, IsDone};
update_count(?EVENT_TASK, {TaskType, _TaskID}, YYActID, Task) ->
	#yy_task{count=Count} = Task,
	#cfg_yunying_reward{goal={TaskType2, Times}} = find_reward(YYActID, Task),
	case TaskType2 == TaskType of
		true ->
			Count2 = min(Count+1, Times),
			IsDone = Count2 >= Times,
			{Count2, IsDone};
		false ->
			false
	end;
update_count(?EVENT_SEARCH_TREASURE, Add, YYActID, Task) ->
	#yy_task{count=Count} = Task,
	#cfg_yunying_reward{goal={_, Times}} = find_reward(YYActID, Task),
	Count2 = min(Count+Add, Times),
	IsDone = Count2 >= Times,
	{Count2, IsDone};
update_count(?EVENT_SEARCH_TOP, Add, YYActID, Task) ->
	#yy_task{count=Count} = Task,
	#cfg_yunying_reward{goal={_, Times}} = find_reward(YYActID, Task),
	Count2 = min(Count+Add, Times),
	IsDone = Count2 >= Times,
	{Count2, IsDone};
update_count(?EVENT_MC_HUNT, Type, YYActID, Task) ->
	#yy_task{count=Count} = Task,
	#cfg_yunying_reward{goal={_, Times}} = find_reward(YYActID, Task),
	Count2 = min(Count+ ?_if(Type==1, 1, 10), Times),
	IsDone = Count2 >= Times,
	{Count2, IsDone};
update_count(?EVENT_DUNGE_ENTER, {SType, _Dunge, _Floor}, YYActID, Task) ->
	#yy_task{count=Count} = Task,
	#cfg_yunying_reward{goal={SType2, Times}} = find_reward(YYActID, Task),
	case SType2 == SType of
		true ->
			Count2 = min(Count+1, Times),
			IsDone = Count2 >= Times,
			{Count2, IsDone};
		false ->
			false
	end;
update_count(?EVENT_CREEP, {CreepID, Rarity}, YYActID, Task) ->
	#yy_task{count=Count} = Task,
	#cfg_yunying_reward{goal=Goal} = find_reward(YYActID, Task),
	case Goal of
		{CfgBossType, Times} when is_integer(CfgBossType) ->
			case cfg_boss:find(CreepID) of
				#cfg_boss{type=BossType} when CfgBossType == BossType ->
					Count2 = min(Count+1, Times),
					IsDone = Count2 >= Times,
					{Count2, IsDone};
				_ ->
					false
			end;
		{CfgBossType, Times} when is_list(CfgBossType) ->
			case cfg_boss:find(CreepID) of
				#cfg_boss{type=BossType} when Rarity == ?CREEP_RARITY_BOSS ->
					case lists:member(BossType, CfgBossType) of
						true ->
							Count2 = min(Count+1, Times),
							IsDone = Count2 >= Times,
							{Count2, IsDone};
						false ->
							false
					end;
				_ ->
					false
			end;
		{CfgBossType, CfgQua, Times} ->
			case cfg_boss:find(CreepID) of
				#cfg_boss{type=BossType, qual=Qua} when CfgBossType == BossType, Qua >= CfgQua ->
					Count2 = min(Count+1, Times),
					IsDone = Count2 >= Times,
					{Count2, IsDone};
				_ ->
					false
			end;
		{{rarity, Rarity0}, {num, Times}} when Rarity0 == Rarity ->
			Count2 = min(Count+1, Times),
			IsDone = Count2 >= Times,
			{Count2, IsDone};
		_ ->
			false
	end;
update_count(?EVENT_ESCORT, {_, IsDouble}, YYActID, Task) ->
	#yy_task{count=Count} = Task,
	#cfg_yunying_reward{goal={_, Times}} = find_reward(YYActID, Task),
	case IsDouble of
		1 ->
			Count2 = min(Count+1, Times),
			IsDone = Count2 >= Times,
			{Count2, IsDone};
		_ ->
			false
	end;
update_count(Event, AddTimes, YYActID, Task) when Event == ?EVENT_YY_SEARCH orelse Event == ?EVENT_INTEGRAL ->
	#yy_task{count=Count} = Task,
	#cfg_yunying_reward{goal=Goal} = find_reward(YYActID, Task),
	case Goal of
		{NeedTimes, Times} ->
			Count2 = min(Count+AddTimes, NeedTimes),
			IsDone = (Count2 div NeedTimes) >= Times,
			{Count2, IsDone};
		Times ->
			Count2 = Count+AddTimes,
			IsDone = Count2 >= Times,
			{Count2, IsDone}
	end;
update_count(?EVENT_VIPLV, VipLv, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal} = find_reward(YYActID, Task),
	Count  = VipLv,
	IsDone = VipLv >= Goal,
	{Count, IsDone};
update_count(?EVENT_PET_TOTAL_POWER, Power, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal} = find_reward(YYActID, Task),
	Count  = Power,
	IsDone = Power >= Goal,
	{Count, IsDone};
update_count(?EVENT_PET_COMPOSE, {_TypeID, PetID}, YYActID, Task) ->
	#cfg_yunying_reward{goal={CfgQua, CfgNum}} = find_reward(YYActID, Task),
	#cfg_pet{quality=Qua} = cfg_pet:find(PetID),
	case Qua >= CfgQua of
		true  ->
			Count  = Task#yy_task.count + 1,
			IsDone = Count >= CfgNum,
			{Count, IsDone};
		false ->
			false
	end;
update_count(?EVENT_PET_FIGHT, {1, _Order, PetID}, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal} = find_reward(YYActID, Task),
	case PetID == Goal of
		true  ->
			Count  = 1,
			IsDone = true,
			{Count, IsDone};
		false ->
			false
	end;
update_count(?EVENT_GWAR_RANK, Rank, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal} = find_reward(YYActID, Task),
	{CfgMinRank, CfgMaxRank, CfgMinPost, CfgMaxPost, CfgOpdays} = Goal,
	IsToday = CfgOpdays == game_env:get_opened_days(),
	case IsToday andalso CfgMinRank =< Rank andalso Rank =< CfgMaxRank of
		true  ->
			#role_guild{post=Post} = role_data:get(?DB_ROLE_GUILD),
			case CfgMinPost =< Post andalso Post =< CfgMaxPost of
				true  ->
					Count  = 1,
					IsDone = true,
					{Count, IsDone};
				false ->
					false
			end;
		false ->
			false
	end;
update_count(?EVENT_YY_LOTTERY, {_YYActID, AddTimes}, YYActID, Task) ->
	#yy_task{count=Count} = Task,
	#cfg_yunying_reward{goal=Goal} = find_reward(YYActID, Task),
	case Goal of
		{NeedTimes, Times} ->
			Count2 = min(Count+AddTimes, NeedTimes),
			IsDone = (Count2 div NeedTimes) >= Times,
			{Count2, IsDone};
		Times ->
			Count2 = Count+AddTimes,
			IsDone = Count2 >= Times,
			{Count2, IsDone}
	end;
update_count(?EVENT_GOD_TOTAL_POWER, Power, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal} = find_reward(YYActID, Task),
	Count  = Power,
	IsDone = Power >= Goal,
	{Count, IsDone};
update_count(?EVENT_ACTIVITY_JOIN, ActID, YYActID, Task) ->
	#yy_task{count=Count} = Task,
	#cfg_yunying_reward{goal=Goal} = find_reward(YYActID, Task),
	case Goal of
		{ActID, Times} ->
			Count2  = Count + 1,
			IsDone = Count2 >= Times,
			{Count2, IsDone};
		_ ->
			false
	end;
update_count(?EVENT_WAKE, Wake, YYActID, Task) ->
	#cfg_yunying_reward{goal=NeedWake} = find_reward(YYActID, Task),
	Count = Wake,
	IsDone = Count >= NeedWake,
	{Count, IsDone};
update_count(?EVENT_EQUIP, {_Slot, _ItemId, Equips}, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal0} = find_reward(YYActID, Task),
	Goal = erlang:tuple_to_list(Goal0),
	case lists:keyfind(num, 1, Goal) of
		{num, NeedNum} ->
			NeedColor = proplists:get_value(color, Goal, 0),
			NeedOrder = proplists:get_value(order, Goal, 0),
			NeedStar = proplists:get_value(star, Goal, 0),
			SuitLv = proplists:get_value(suit, Goal, 0),
			Num = maps:fold(fun(Slot, CellID, Acc) ->
				{ok, #p_item{id=ItemID}} = role_bag:get_item(CellID),
				#cfg_item{color=Color} = cfg_item:find(ItemID),
				#cfg_equip{order=Order, star=Star} = cfg_equip:find(ItemID),
				if
					Color >= NeedColor, Order >= NeedOrder, Star >= NeedStar ->
						case SuitLv == 0 orelse role_equip:is_suite_maked(Slot, SuitLv) of
							true ->
								Acc + 1;
							false ->
								Acc
						end;
					true ->
						Acc
				end
			end, 0, Equips),
			Count = Num,
			IsDone = Count >= NeedNum,
			{Count, IsDone};
		_ ->
			{0, false}
	end;
update_count(?EVENT_EQUIP_CAST, _, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal0} = find_reward(YYActID, Task),
	Goal = erlang:tuple_to_list(Goal0),
	#role_equip{casts=Casts} = role_data:get(?DB_ROLE_EQUIP),
	NeedNum = proplists:get_value(num, Goal, 0),
	NeedCast = proplists:get_value(cast, Goal, 0),
	Num = maps:fold(fun(_Slot, EquipCast, Acc) ->
		#equip_cast{cast=Cast} = EquipCast,
		if
			Cast >= NeedCast ->
				Acc + 1;
			true ->
				Acc
		end
	end, 0, Casts),
	Count = Num,
	IsDone = Count >= NeedNum,
	{Count, IsDone};
update_count(?EVENT_STONE, AllStones, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal0} = find_reward(YYActID, Task),
	Goal = erlang:tuple_to_list(Goal0),
	NeedNum = proplists:get_value(total_lv, Goal, 0),
	Num = maps:fold(fun(_Slot, Stones, Acc) ->
		maps:fold(fun(_Hole, ItemID, Acc2) ->
			#cfg_item{level=Level} = cfg_item:find(ItemID),
			Level + Acc2
		end, 0, Stones) + Acc
	end, 0, AllStones),
	Count = Num,
	IsDone = Count >= NeedNum,
	{Count, IsDone};
update_count(?EVENT_EQUIP_REFINE_FINAL, Refine, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal0} = find_reward(YYActID, Task),
	Goal = erlang:tuple_to_list(Goal0),
	NeedNum = proplists:get_value(num, Goal, 0),
	NeedColor = proplists:get_value(color, Goal, 0),
	Num = maps:fold(fun(_Slot, #p_refine_slot{holes=Holes}, Acc) ->
		maps:fold(fun(_Hole, #p_refine{color=Color}, Acc2) ->
			if
				Color >= NeedColor ->
					Acc2 + 1;
				true ->
					Acc2
			end
		end, 0, Holes) + Acc
	end, 0, Refine),
	Count = Num,
	IsDone = Count >= NeedNum,
	{Count, IsDone};
update_count(?EVENT_EQUIP_STR_FINAL, _, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal0} = find_reward(YYActID, Task),
	#role_equip{strengths=Strengths} = role_data:get(?DB_ROLE_EQUIP),
	Goal = erlang:tuple_to_list(Goal0),
	NeedNum = proplists:get_value(total_lv, Goal, 0),
	Num = lists:foldl(fun(#equip_strength{phase=Phase, level=Level}, Acc) ->
		(Phase-1)*10 + Level + Acc
	end, 0, maps:values(Strengths)),
	Count = Num,
	IsDone = Count >= NeedNum,
	{Count, IsDone};
update_count(?EVENT_ADD_INTIMACY, _, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal0} = find_reward(YYActID, Task),
	#role_info{id=RoleID} = role_data:get(?DB_ROLE_INFO),
	Goal = erlang:tuple_to_list(Goal0),
	Max = friend_server:get_max_intimacy(RoleID),
	NeedNum = proplists:get_value(max, Goal, 0),
	Count = Max,
	IsDone = Count >= NeedNum,
	{Count, IsDone};
update_count(?EVENT_DUNGE, {SType, _Dunge, _Floor, Opts}, YYActID, Task) ->
	#cfg_yunying_reward{goal=Goal0} = find_reward(YYActID, Task),
	Goal = erlang:tuple_to_list(Goal0),
	SType0 = proplists:get_value(stype, Goal, 0),
	Wave0 = proplists:get_value(wave, Goal, 0),
	case SType0 == SType of
		true ->
			Wave = proplists:get_value(wave, Opts, 0),
			Count = Wave,
			IsDone = Count >= Wave0,
			{Count, IsDone};
		false ->
			{0, false}
	end;
update_count(?EVENT_MECHA_EQUIP, Equips, YYActID, Task) ->
	#cfg_yunying_reward{goal=Times} = find_reward(YYActID, Task),
	Count2 = maps:size(Equips),
	IsDone = Count2 >= Times,
	{Count2, IsDone};
update_count(_Event, _Args, _YYActID, _Task) ->
	false.

find_reward(YYActID, Task) ->
	Mod = yunying_util:cfg_reward_mod(YYActID),
	Mod:find(YYActID, Task#yy_task.id).
