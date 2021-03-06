%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(buff).

-include("role.hrl").

%% API
-export([add/2]).
-export([del/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%%-----------------------------------------------
%% @doc 新增 buff
-spec add([integer()], #role_st{}) ->
    no_return().
%%-----------------------------------------------
add(BuffIDs, RoleSt) ->
	#role_st{spid=ScenePid, role=RoleID} = RoleSt,
	scene:cast(ScenePid, {add_buffs, RoleID, BuffIDs}).

%%-----------------------------------------------
%% @doc 删除 buff
%%-----------------------------------------------
del(BuffIDs, RoleSt) ->
	#role_st{spid=ScenePid, role=RoleID} = RoleSt,
	scene:cast(ScenePid, {del_buffs, RoleID, BuffIDs}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
