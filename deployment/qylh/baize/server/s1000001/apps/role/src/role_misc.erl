%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_misc).

-include("game.hrl").
-include("role.hrl").
-include("table.hrl").
-include("proto.hrl").

%% API
-export([hook_finish/2]).
-export([hook_upgrade/2]).
-export([hook_login/1]).
-export([is_sys_open/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 根据任务开放系统
hook_finish(TaskID, RoleSt) ->
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	lists:foreach(fun
		({SysID, Level}) ->
			case Level == 0 orelse RoleLv >= Level of
			 	true  -> open_sys(SysID, RoleSt, true);
			 	false -> ignore
			end
	end, cfg_sysopen:open_by_task(TaskID)).

%% 根据等级开放系统
hook_upgrade(Level, RoleSt) ->
	#role_task{submit=Submited} = role_data:get(?DB_ROLE_TASK),
	lists:foreach(fun
		({SysID, TaskID}) ->
			case TaskID == 0 orelse lists:member(TaskID, Submited) of
				true  -> open_sys(SysID, RoleSt, true);
				false -> ignore
			end
	end, cfg_sysopen:open_by_level(Level)).

hook_login(RoleSt) ->
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	#role_task{submit=Submited} = role_data:get(?DB_ROLE_TASK),
	lists:foreach(fun
		({SysID, Level, TaskID}) ->
			CanOpen = (Level == 0 orelse RoleLv >= Level)
			  andalso (TaskID == 0 orelse lists:member(TaskID, Submited)),

			case CanOpen of
				true  -> open_sys(SysID, RoleSt, false);
				false -> ignore
			end
	end, cfg_sysopen:syslist()).

is_sys_open(Mod) ->
	case cfg_sysopen:sysid(Mod) of
		?nil ->
			false;
		SysID ->
			RoleMisc = role_data:get(?DB_ROLE_MISC),
			#role_misc{sys_opened=Opened} = RoleMisc,
			lists:member(SysID, Opened)
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
open_sys(SysID, RoleSt, Notify) ->
	RoleMisc = role_data:get(?DB_ROLE_MISC),
	#role_misc{sys_opened=Opened} = RoleMisc,
	case lists:member(SysID, Opened) of
		true  ->
			ignore;
		false ->
			Opened2 = [SysID | Opened],
			role_data:set(RoleMisc#role_misc{sys_opened=Opened2}),
			role_hook:hook_sysopen(cfg_sysopen:mod(SysID), RoleSt),
			{MailID, Rewards} = cfg_sysopen:mail(SysID),
			?_if(MailID > 0, mail:send(RoleSt#role_st.role, MailID, Rewards, [])),
			?_if(Notify, ?ucast(#m_game_sysopen_toc{sysid=SysID}))
	end.


