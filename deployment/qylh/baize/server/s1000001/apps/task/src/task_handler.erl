%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(task_handler).

-include("game.hrl").
-include("role.hrl").
-include("task.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 任务列表
handle(?TASK_LIST, _Tos, RoleSt) ->
	RoleTask = role_data:get(?DB_ROLE_TASK),
	#role_task{accept=Accepted, next=Next} = RoleTask,
	NowSecs  = ut_time:seconds(),
	TaskList = lists:filtermap(fun
		(Task) ->
			#cfg_task{show=Reqs} = cfg_task:find(Task#task.id),
			case
				(not task_util:is_expired(Task, NowSecs)) andalso
				task_util:check_reqs(Reqs, RoleTask)
			of
				true  ->
					{true, task_util:p_task(Task)};
				false ->
					false
			end
	end, maps:values(Accepted)),
	?ucast(#m_task_list_toc{tasks=TaskList, next=Next});

%% 授受任务
handle(?TASK_ACCEPT, Tos, RoleSt) ->
	#m_task_accept_tos{task_id=TaskID} = Tos,
	#cfg_task{quest=Items} = cfg_task:find(TaskID),
	{ok, Task, RoleTask} = role_task:accept(TaskID),
	role_bag:gain(Items, ?LOG_TASK_ACCEPT, RoleSt),
	role_data:set(RoleTask),
	?ucast(#m_task_accept_toc{task=task_util:p_task(Task)});

%% 提交任务
handle(?TASK_SUBMIT, Tos, RoleSt) ->
	#m_task_submit_tos{task_id=TaskID} = Tos,
	#cfg_task{cost=Cost, gain=Gain, group=Group} = cfg_task:find(TaskID),
	Succ = fun() ->
		{ok, Task, RoleTask, Add} = role_task:submit(TaskID, RoleSt),
		role_data:set(RoleTask),
		?ucast(#m_task_submit_toc{task_id=TaskID}),
		Add2 = case (
			Task#task.type == ?TASK_TYPE_SIDE orelse
			Task#task.type == ?TASK_TYPE_ACTIVE
		) andalso Group > 0 of
			true  ->
				case find_next_show(RoleTask, TaskID, Group) of
					?nil -> Add;
					Next -> [task_util:p_task(Next) | Add]
				end;
			false ->
				Add
		end,
		task_util:update_notify(RoleTask, Add2, [], [], RoleSt)
	end,
	role_bag:deal(Cost, Gain, ?LOG_TASK_SUBMIT, Succ, RoleSt);

%% 快速完成
% handle(?TASK_QUICK, Tos, RoleSt) ->
% 	#m_task_quick_tos{task_id=TaskID} = Tos,
% 	{ok, _Task, RoleTask, Add} = role_task:quick(TaskID, RoleSt),
% 	#cfg_task{quick=Cost, gain=Gain} = cfg_task:find(TaskID),
% 	role_bag:cost(Cost, Gain, ?LOG_TASK_QUICK, RoleSt),
% 	role_data:set(RoleTask),
% 	?ucast(#m_task_quick_toc{task_id=TaskID}),
% 	task_util:update_notify(RoleTask, Add, [], [], RoleSt);

%% 章节奖励
handle(?TASK_REWARD, Tos, RoleSt) ->
	#m_task_reward_tos{chapter=Chapter} = Tos,
	RoleTask = role_data:get(?DB_ROLE_TASK),
	check_reward(Chapter, RoleTask#role_task.submit),
	Gain = cfg_task_chapter:find(Chapter),
	role_bag:gain(Gain, ?LOG_TASK_CHAPTER, RoleSt),
	role_data:set(RoleTask#role_task{
		reward = [Chapter | RoleTask#role_task.reward]
	}).


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_reward(Chapter, Submitted) ->
	IsValid  = lists:member(Chapter, cfg_task:chapters()),
	?_check(not IsValid, ?ERR_GAME_BAD_ARGS),
	IsFinish = lists:all(fun
		(TaskID) ->
			lists:member(TaskID, Submitted)
	end, cfg_task:chapter(Chapter)),
	?_check(not IsFinish, ?ERR_TASK_CHAPTER_NOT_FINISH),
	ok.

find_next_show(RoleTask, TaskID, Group) ->
	GroupTasks = cfg_task:group(Group),
	find_next_show2(GroupTasks, RoleTask, TaskID).

find_next_show2([TaskID2 | T], RoleTask, TaskID) ->
    #cfg_task{show=Reqs} = cfg_task:find(TaskID2),
	case lists:keyfind(prev, 1, Reqs) of
		{_, TaskID} ->
			case maps:find(TaskID2, RoleTask#role_task.accept) of
				{ok, Task2} ->
					Task2;
				error ->
					find_next_show2(T, RoleTask, TaskID)
			end;
		_ ->
			find_next_show2(T, RoleTask, TaskID)
	end;
find_next_show2([], _RoleTask, _TaskID)->
	?nil.
