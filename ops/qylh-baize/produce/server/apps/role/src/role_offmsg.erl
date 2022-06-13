%%%=============================================================================
%%% @author z.hua
%%% @doc
%%% 离线消息
%%% @end
%%%=============================================================================

-module(role_offmsg).

-include("game.hrl").
-include("table.hrl").

%% API
-export([hook_login/1]).
-export([insert/3, insert/4]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%% 上线时处理离线消息
hook_login(_RoleSt) ->
	Misc = role_data:get(?DB_ROLE_MISC),
	Msgs = lists:reverse(Misc#role_misc.offline_msg),
	lists:foreach(fun
		({role_event, event, [Event, Args]}) ->
			role_event:event(Event, Args);
		({Mod, Fun, ?nil}) ->
			role:route(self(), Mod, Fun);
		({Mod, Fun, Args}) ->
			role:route(self(), Mod, Fun, Args)
	end, Msgs),
	role_data:set(Misc#role_misc{offline_msg=[]}).

%%-----------------------------------------------
%% @doc 插入离线消息
%% 玩家上线时会将消息通过 role:route/4 发送到玩家进程处理
%% 参数详见 role:route/4
-spec insert(integer(), atom(), atom(), any()) ->
	no_return().
%%-----------------------------------------------
insert(RoleID, Mod, Fun) ->
	insert(RoleID, Mod, Fun, ?nil).

insert(RoleID, Mod, Fun, Args) ->
	case db:dirty_read(?DB_ROLE_MISC, RoleID) of
		[RoleMisc] ->
			#role_misc{offline_msg=OfflineMsg} = RoleMisc,
			OfflineMsg2 = case (Mod == role_pay andalso Fun == pay) orelse Mod == role_event of
				true  ->
					[{Mod,Fun,Args} | OfflineMsg];
				false ->
					OfflineMsg1 = [MFA || MFA={M,F,_} <- OfflineMsg, Mod /= M, Fun /= F],
					[{Mod,Fun,Args} | OfflineMsg1]
			end,
			RoleMisc2  = RoleMisc#role_misc{offline_msg=OfflineMsg2},
			db:dirty_write(?DB_ROLE_MISC, RoleMisc2);
		[] ->
			ok
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
