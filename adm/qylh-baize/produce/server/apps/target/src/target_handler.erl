%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(target_handler).

-include("game.hrl").
-include("role.hrl").
-include("table.hrl").
-include("log.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("msgno.hrl").
-include("target.hrl").
-include("msgno.hrl").
-include("skill.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%获取完成进度
handle(?TARGET_INFO, _Tos, RoleSt)->
	#role_target{tasks=Tasks, targets=Targets} = role_data:get(?DB_ROLE_TARGET),
	{ok, #m_target_info_toc{tasks=Tasks, targets=Targets}, RoleSt};

%领取任务奖励
handle(?TARGET_GET_REWARD, Tos, RoleSt)->
	#m_target_get_reward_tos{id=TaskId} = Tos,
	RoleTask = #role_target{tasks=Tasks} = role_data:get(?DB_ROLE_TARGET),
	Task = maps:get(TaskId, Tasks, ?nil),
	case Task of
		?nil->
			throw(?err(?ERR_TARGET_TASK_WRONG));
		Task = #p_target_task{status=Status}->
			?_check(Status == 1, ?ERR_TARGET_TASK_STATE_WRONG)
	end,
	#cfg_target_task{gain=Gain} = cfg_target_task:find(TaskId),
	role_bag:gain(Gain, ?LOG_TARGET_REWARD, RoleSt),
	Task2 = Task#p_target_task{status=2},
	Tasks2 = maps:put(TaskId, Task2, Tasks),
	role_data:set(RoleTask#role_target{tasks=Tasks2}),
	UpTask = #{TaskId => Task2},
	{ok, #m_target_info_toc{tasks=UpTask}, RoleSt};

%领取技能
handle(?TARGET_GET_SKILL, Tos, RoleSt)->
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	#m_target_get_skill_tos{id=Id} = Tos,
	RoleTarget = #role_target{targets=Targets} = role_data:get(?DB_ROLE_TARGET),
	case maps:get(Id, Targets, 0) of
		0 -> throw(?err(?ERR_TARGET_STATE_WRONG));
		2 -> throw(?err(?ERR_TARGET_STATE_WRONG));
		_ -> ignor
	end,
	#cfg_target{skill=SkillId} = cfg_target:find(Id),
	role_skill:active(SkillId, RoleSt),
	Targets2 = maps:put(Id, 2, Targets),
	role_data:set(RoleTarget#role_target{targets=Targets2}),
	UpTarget = #{Id=>2},
	?ucast(#m_target_info_toc{targets=UpTarget}),
	#cfg_skill{name=SkillName} = cfg_skill:find(SkillId),
	?notify(?MSG_TARGET_GET_SKILL, [
		{role, RoleID, RoleName},
		{color, SkillName, ?COLOR_GREEN}
	]),
	{ok, #m_target_get_skill_toc{}, RoleSt}.


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
