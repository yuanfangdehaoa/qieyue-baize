%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(user_default).

-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("proto.hrl").
-include("table.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
o() ->
	observer_cli:start().

%% 根据账号获取角色id列表
acc2ids(PfAc) ->
	Pattern = #game_user{account=PfAc, _='_'},
	case db:dirty_match_object(?DB_GAME_USER, Pattern) of
		[#game_user{roles=RoleIDs}] ->
			RoleIDs;
		[] ->
			not_found
	end.

%% 根据角色名获取角色id
name2id(Name) ->
	Pattern = #role_info{name=Name, _='_'},
	case db:dirty_match_object(?DB_ROLE_INFO, Pattern) of
		[#role_info{id=RoleID}] ->
			RoleID;
		[] ->
			not_found
	end.

%% 根据角色名获取账号名
name2acc(Name) ->
	Pattern = #role_info{name=Name, _='_'},
	case db:dirty_match_object(?DB_ROLE_INFO, Pattern) of
		[#role_info{userid={_,Account}}] ->
			Account;
		[] ->
			not_found
	end.

id2name(RoleID) ->
	case db:dirty_read(?DB_ROLE_INFO, RoleID) of
		[#role_info{name=RoleName}] ->
			RoleName;
		[] ->
			not_found
	end.

id2acc(RoleID) ->
	case db:dirty_read(?DB_ROLE_INFO, RoleID) of
		[#role_info{userid={_,Account}}] ->
			Account;
		[] ->
			not_found
	end.

%% 获取角色数据
data(RoleID, Keys) ->
	role:get_data(RoleID, Keys).

%% 直接设置玩家数据
setdata(RoleID, Rec) ->
	case get_pid(RoleID) of
		?nil -> not_online;
		Pid  -> gen_server:cast(Pid, {setdata, Rec})
	end.

%% 获取角色进程信息
role_process_info(RoleID) ->
	case get_pid(RoleID) of
		?nil -> not_online;
		Pid  -> process_info(Pid)
	end.

%% 获取角色进程的消息列表
role_messages(RoleID) ->
	case get_pid(RoleID) of
		?nil -> not_online;
		Pid  -> erlang:process_info(Pid, messages)
	end.

%% 获取 #role_st
role_st(RoleID) ->
	case get_pid(RoleID) of
		?nil -> not_online;
		Pid  -> sys:get_state(Pid)
	end.

role_actor(RoleID) when is_integer(RoleID) ->
	case role_st(RoleID) of
		not_online ->
			not_online;
		RoleSt ->
			scene:get_actor(RoleSt#role_st.spid, RoleID)
	end;
role_actor(RoleName) when is_list(RoleName) ->
	case name2id(RoleName) of
		not_found ->
			not_found;
		RoleID ->
			role_actor(RoleID)
	end.

%% 协议追踪
trace(RoleID) when is_integer(RoleID) ->
	mochiglobal:put(gateway_trace_role, [RoleID]),
	mochiglobal:put(gateway_trace_all, true);
trace(RoleName) when is_list(RoleName) ->
	case name2id(RoleName) of
		not_found ->
			not_found;
		RoleID ->
			trace(RoleID)
	end.

trace(RoleID, PkgList) when is_integer(RoleID) ->
	mochiglobal:put(gateway_trace_role, [RoleID]),
	mochiglobal:put(gateway_trace_all, false),
	mochiglobal:put(gateway_trace_pkg, PkgList);
trace(RoleName, PkgList) when is_list(RoleName) ->
	case name2id(RoleName) of
		not_found ->
			not_found;
		RoleID ->
			trace(RoleID, PkgList)
	end.

-ifdef(DEBUG).

%% 取消协议追踪
detrace() ->
	mochiglobal:put(gateway_trace_role, ?nil),
	mochiglobal:put(gateway_trace_all, false),
	mochiglobal:put(gateway_trace_pkg, []).

-else.

%% 取消协议追踪
detrace() ->
	mochiglobal:put(gateway_trace_role, []),
	mochiglobal:put(gateway_trace_all, false),
	mochiglobal:put(gateway_trace_pkg, []).

-endif.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
get_pid(RoleID) ->
	whereis( role_util:reg_name(RoleID) ).
