%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(wake_handler).

-include("game.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("table.hrl").
-include("wake.hrl").
-include("role.hrl").
-include("log.hrl").
-include("enum.hrl").
-include("task.hrl").
-include("msgno.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%获取当前觉醒信息
handle(?WAKE_INFO, _Tos, RoleSt)->
	#role_info{wake=WakeTimes} = role_data:get(?DB_ROLE_INFO),
	{ok, #m_wake_info_toc{wake_times=WakeTimes}, RoleSt};


%获取觉醒任务进度
handle(?WAKE_TASK, _Tos, RoleSt)->
	#role_info{wake=WakeTimes} = role_data:get(?DB_ROLE_INFO),
	#role_wake{step=Step} = role_data:get(?DB_ROLE_WAKE),
	Tasks = role_wake:get_tasks(WakeTimes+1, Step),
	{ok, #m_wake_task_toc{cur_step=Step, tasks=Tasks}, RoleSt};

%进入下一阶段
handle(?WAKE_NEXT_STEP, _Tos, RoleSt)->
	#role_info{career=Career, wake=WakeTimes} = role_data:get(?DB_ROLE_INFO),
	NextWakeTimes = WakeTimes+1,
	check_right_step(NextWakeTimes),
	RoleWake = #role_wake{step=Step} = role_data:get(?DB_ROLE_WAKE),
	case cfg_wake:find(Career, NextWakeTimes) of
		#cfg_wake{step=TotalStep} ->
			?_check(Step < TotalStep, ?ERR_WAKE_MAX_STEP),
			%check_tasks(Tasks),
			?_check(role_wake:is_step_finish(NextWakeTimes, Step), ?ERR_WAKE_NOT_ALL_TASK_FINISH),
			NewStep = Step + 1,
			role_wake:add_wake_tasks(NextWakeTimes, NewStep, RoleSt),
			NewTasks = role_wake:get_tasks(NextWakeTimes, Step),
			role_data:set(RoleWake#role_wake{step=NewStep}),
			?ucast(#m_wake_task_toc{cur_step=NewStep, tasks=NewTasks}),
			{ok, #m_wake_next_step_toc{}, RoleSt};
		_->
			throw(?err(?ERR_WAKE_MAX_WAKE_TIMES))
	end;

%点亮格子
handle(?WAKE_ACTIVE_GRID, Tos, RoleSt)->
	#m_wake_active_grid_tos{grid_id=GridId} = Tos,
	#role_info{career=Career, wake=WakeTimes, level=RoleLevel} = role_data:get(?DB_ROLE_INFO),
	?_check(WakeTimes >= 3, ?ERR_WAKE_CAN_NOT_LIGHT_GRID),
	#cfg_wake{open_level=Level} = cfg_wake:find(Career, WakeTimes+1),
	?_check(RoleLevel >= Level, ?ERR_WAKE_LEVEL_NOT_ENOUGH),
	RoleWake = #role_wake{grid=CurGridId} = role_data:get(?DB_ROLE_WAKE),
	%检测是否已激活
	?_check(GridId == CurGridId + 1, ?ERR_WAKE_GRID_IS_LIGHTEN),
	#cfg_wake_grid{cost=Cost, cost_exp=CostExp} = cfg_wake_grid:find(GridId),
	[{ItemId, Num}|_T] = Cost,
	HaveNum = role_bag:get_num(ItemId),
	case HaveNum >= Num orelse CostExp == [] of
		true ->
			role_bag:cost(Cost, ?LOG_WAKE_ACTIVE, RoleSt);
		false ->
			role_bag:cost(CostExp, ?LOG_WAKE_ACTIVE, RoleSt)
	end,
	role_data:set(RoleWake#role_wake{grid=GridId}),
	role_attr:recalc(role_wake, RoleSt),
	{ok, #m_wake_active_grid_toc{grid_id=GridId}, RoleSt};

%获取点亮进度
handle(?WAKE_GET_GRIDS, _Tos, RoleSt)->
	#role_wake{grid=Grid} = role_data:get(?DB_ROLE_WAKE),
	{ok, #m_wake_get_grids_toc{grid_id=Grid}, RoleSt};

%觉醒
handle(?WAKE_START, Tos, RoleSt)->
	#m_wake_start_tos{wake_type=WakeType} = Tos,
	RoleWake = #role_wake{step=Step} = role_data:get(?DB_ROLE_WAKE),
	RoleInfo = #role_info{career=Career, level=Level, wake=WakeTimes} = role_data:get(?DB_ROLE_INFO),
	NextWakeTimes = WakeTimes + 1,
	case cfg_wake:find(Career, NextWakeTimes) of
		#cfg_wake{level=WakeLevel, step=TotalStep, new_skills=NewSkills} ->
			?_check(Level>=WakeLevel, ?ERR_WAKE_LEVEL_NOT_ENOUGH),
			wake(NextWakeTimes, Career, Level, WakeType, Step, TotalStep, RoleWake, NewSkills, RoleSt),
			role_data:set(RoleInfo#role_info{wake=NextWakeTimes}),
			UpInt = #{"wake"=>NextWakeTimes},
			?ucast(#m_role_update_toc{upint=UpInt, upstr=#{}}),
			role_event:event(?EVENT_WAKE, NextWakeTimes),
			role_attr:recalc(role_wake, RoleSt),
			role_hook:hook_wake(NextWakeTimes, RoleSt),
			#role_st{role=RoleID, name=RoleName} = RoleSt,
			?notify(?MSG_WAKE_NOTICE, [{role, RoleID, RoleName}, NextWakeTimes]),
			{ok, #m_wake_start_toc{}, RoleSt};
		_->
			throw(?err(?ERR_WAKE_MAX_WAKE_TIMES))
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------

%觉醒
wake(WakeTimes, Career, Level, WakeType, Step, TotalStep, RoleWake, NewSkills, RoleSt) when WakeTimes < 4 ->
	check_step(WakeType, Step, TotalStep),
	check_tasks(WakeType, WakeTimes, Step, TotalStep, RoleSt),
	NewStep = 1,
	NewTasks = get_tasks(Career, WakeTimes, NewStep, Level, RoleSt),
	role_data:set(RoleWake#role_wake{step=NewStep}),
	handle_skills(NewSkills, RoleSt),
	?ucast(#m_wake_task_toc{cur_step=NewStep, tasks=NewTasks});
wake(4, _Career, _Level, _WakeType, _Step, _TotalStep, RoleWake, _NewSkills, _RoleSt) ->
	#role_wake{grid=Grid} = RoleWake,
	?_check(Grid == 12, ?ERR_WAKE_CONDITION_NOT_ENOUGH),
	role_data:set(RoleWake#role_wake{step=1});
wake(5, _Career, _Level, _WakeType, _Step, _TotalStep, RoleWake, _NewSkills, _RoleSt) ->
	#role_wake{grid=Grid} = RoleWake,
	?_check(Grid == 47, ?ERR_WAKE_CONDITION_NOT_ENOUGH),
	role_data:set(RoleWake#role_wake{step=1});
wake(6, _Career, _Level, _WakeType, _Step, _TotalStep, RoleWake, _NewSkills, _RoleSt) ->
	#role_wake{grid=Grid} = RoleWake,
	?_check(Grid == 137, ?ERR_WAKE_CONDITION_NOT_ENOUGH),
	role_data:set(RoleWake#role_wake{step=1}).


%检查任务是否已完成
check_step(WakeType, Step, TotalStep)->
	case WakeType == 1 of
		true->
			ignor;
		false->
			?_check(Step==TotalStep, ?ERR_WAKE_CONDITION_NOT_ENOUGH)
	end.

check_tasks(WakeType, WakeTimes, Step, _TotalStep, RoleSt)->
	case WakeType == 1 of
		true-> %一键觉醒
			Gain = finish_tasks(WakeTimes, RoleSt),
			%Gain = get_task_rewards(WakeTimes, Step+1, TotalStep, []),
			WakeCosts = cfg_game:wake_cost(),
			Cost = lists:nth(WakeTimes, WakeCosts),
			role_bag:deal([{?ITEM_GOLD, Cost}], Gain, ?LOG_WAKE_QUICKLY, RoleSt);
		false->
			?_check(role_wake:is_step_finish(WakeTimes, Step), ?ERR_WAKE_NOT_ALL_TASK_FINISH)
	end.

get_tasks(Career, WakeTimes, Step, RoleLevel, RoleSt)->
	NextWakeTimes = WakeTimes + 1,
	case cfg_wake:find(Career, NextWakeTimes) of
		#cfg_wake{level=Level} ->
			case RoleLevel >= Level of
				true->
					role_wake:add_wake_tasks(NextWakeTimes, Step, RoleSt),
					role_wake:get_tasks(NextWakeTimes, Step);
				false->
					#{}
			end;
		_->#{}
	end.

%处理技能
handle_skills(NewSkills, RoleSt)->
	lists:foreach(fun
			({0, NewSkillId}) ->
				role_skill:active(NewSkillId, RoleSt);
			({OldSkillId, NewSkillId}) ->
				role_skill:replace(OldSkillId, NewSkillId, RoleSt)
		end, NewSkills),
	skill_util:send_skills(RoleSt).

finish_tasks(WakeTimes, RoleSt)->
	Gain1 = finish_tasks(WakeTimes, 1, RoleSt),
	Gain2 = finish_tasks(WakeTimes, 2, RoleSt),
	lists:merge(Gain1, Gain2).

%提交任务
finish_tasks(WakeTimes, Step, RoleSt)->
	Tasks = role_wake:get_tasks(WakeTimes, Step),
	maps:fold(fun
			(TaskId, V, Acc)->
				case V == 0 of
					true  ->
						case role_task:get_task(TaskId) of
							{ok, Task} ->
								Gain2 = case Task#task.state of
									?TASK_STATE_FINISH ->
										{ok, _Task, RoleTask, _Add} = role_task:submit(TaskId, RoleSt),
										?ucast(#m_task_submit_toc{task_id=TaskId}),
										role_data:set(RoleTask),
										#cfg_task{gain=Gain} = cfg_task:find(TaskId),
										Gain;
									?TASK_STATE_ACCEPT ->
										{ok, _Task, RoleTask, _Add} = role_task:quick(TaskId, RoleSt),
										?ucast(#m_task_submit_toc{task_id=TaskId}),
										role_data:set(RoleTask),
										#cfg_task{gain=Gain} = cfg_task:find(TaskId),
										Gain;
									?TASK_STATE_TRIGGER ->
										#cfg_task{gain=Gain} = cfg_task:find(TaskId),
										Gain;
									_ ->
										[]
								end,
								lists:merge(Acc, Gain2);
							_ ->
								#cfg_task{gain=Gain} = cfg_task:find(TaskId),
								lists:merge(Acc, Gain)
						end;
					false ->
						Acc
				end
		end, [], Tasks).


check_right_step(WakeTimes) ->
	RoleWake = #role_wake{step=CurStep,grid=Grid} = role_data:get(?DB_ROLE_WAKE),
	case WakeTimes >= 4 of
		true ->
			case cfg_wake_step:find_step(Grid) of
				?nil -> throw(?err(?ERR_WAKE_GRID_NOT_ENOUGH));
				Step ->
					?_if(CurStep /= Step,role_data:set(RoleWake#role_wake{step = Step}))
			end;
		_ -> ignore
	end.




