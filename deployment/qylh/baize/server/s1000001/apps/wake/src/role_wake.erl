%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_wake).

-include("game.hrl").
-include("errno.hrl").
-include("table.hrl").
-include("wake.hrl").
-include("proto.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("task.hrl").

%% API
-export([hook_upgrade/2, add_wake_tasks/3, hook_finish/2]).
-export([is_step_finish/2]).
-export([get_tasks/2]).
-export([get_attr/1]).
-export([hook_sysopen/1]).
-export([check_tasks/2]).
-export([hook_login/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
hook_login(RoleSt)->
	hook_upgrade(1, RoleSt).

hook_sysopen(RoleSt)->
	#role_st{role=RoleID} = RoleSt,
	role_timer:rep_task({RoleID, ?MODULE}, 2, ?MODULE, check_tasks).

check_tasks({_, _}, RoleSt)->
	hook_upgrade(1, RoleSt).

get_attr(_AttrType)->
	#role_wake{grid=Grid} = role_data:get(?DB_ROLE_WAKE),
	#role_info{wake=Wake, career=Career} = role_data:get(?DB_ROLE_INFO),
	#cfg_wake{attribs=Attrs} = cfg_wake:find(Career, Wake),
	Attr2 = add_attr(Grid, #{}),
	mod_attr:sum([Attrs, Attr2]).

hook_upgrade(_NewLv, RoleSt)->
	#role_info{career=Career, wake=WakeTimes} = role_data:get(?DB_ROLE_INFO),
	NextWakeTimes = WakeTimes + 1,
	check_correct_step(NextWakeTimes),
	#role_wake{step=Step} = role_data:get(?DB_ROLE_WAKE),
	case cfg_wake:find(Career, NextWakeTimes) of
		#cfg_wake{} ->
			case role_misc:is_sys_open(role_wake) of
				true-> %开放觉醒任务
					add_wake_tasks(NextWakeTimes, Step, RoleSt),
					NewTasks = get_tasks(NextWakeTimes, Step),
					?ucast(#m_wake_task_toc{cur_step=Step, tasks=NewTasks});
				false-> 
					ignore
			end;
		_->
			ignore
	end.

%任务类完成
hook_finish(TaskId, RoleSt)->
	#role_wake{step=Step} = role_data:get(?DB_ROLE_WAKE),
	UpTasks = #{TaskId => 1},
	?ucast(#m_wake_task_toc{cur_step=Step, tasks=UpTasks}).


add_wake_tasks(WakeTimes, Step, RoleSt)->
	case cfg_wake_step:find(WakeTimes, Step) of
		#cfg_wake_step{tasks=AddTasks} ->
			role_task:trigger(AddTasks, RoleSt),
			Chgs = lists:foldl(fun 
					(TaskId, Chg) -> 
						case role_task:get_task(TaskId) of
                        	{ok, Task} ->
                        		case Task#task.state == ?TASK_STATE_TRIGGER of
                        			true ->
		                        		{ok, Task2, RoleTask} = role_task:accept(TaskId),
		                        		role_data:set(RoleTask),
		                        		[task_util:p_task(Task2)| Chg];
		                        	false->
		                        		Chg
                        	    end;
                        	_ -> 
                        		Chg
						end
				end, [], AddTasks),
			RoleTask2 = role_data:get(?DB_ROLE_TASK),
			task_util:update_notify(RoleTask2, [], Chgs, [], RoleSt);
		_->
			ignore
	end.

%获取任务
get_tasks(WakeTimes, Step)->
	case cfg_wake_step:find(WakeTimes, Step) of
		#cfg_wake_step{tasks=Tasks}->
			lists:foldl(fun
					(TaskId, Maps) ->
						Status = case role_task:is_finish(TaskId) of
							true  ->1;
							false ->0
						end,
						maps:put(TaskId, Status, Maps)
				end, #{}, Tasks);
		_->#{}
	end.

%当前阶段是否完成
is_step_finish(WakeTimes, Step)->
	case cfg_wake_step:find(WakeTimes, Step) of
		#cfg_wake_step{tasks=Tasks}->
			is_tasks_finish(Tasks);
		_-> true
	end.


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
is_tasks_finish([])->
	true;
is_tasks_finish([TaskId|Tasks])->
	case role_task:is_finish(TaskId) of
		true  -> is_tasks_finish(Tasks);
		false -> false
	end.

add_attr(0, Attrs)->
	Attrs;
add_attr(Grid, Attrs)->
	#cfg_wake_grid{attr=Attr} = cfg_wake_grid:find(Grid),
	Attrs2 = mod_attr:add(Attrs, Attr),
	add_attr(Grid-1, Attrs2).

check_correct_step(WakeTimes) ->
	case WakeTimes >= 4 of
		true ->
			RoleWake = #role_wake{step=Step,grid=Grid} = role_data:get(?DB_ROLE_WAKE),
			RightStep = cfg_wake_step:get_step(WakeTimes,Grid),
			case RightStep /= ?nil andalso RightStep /= Step of
				true ->
					role_data:set(RoleWake#role_wake{step = RightStep});
				_ -> ignore
			end;
		_ ->
			ignore
	end.


