%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(creep).

-include("role.hrl").
-include("proto.hrl").

%% API
-export([add/2, add/4]).
-export([sync_add/2, sync_add/4]).
-export([del/2, del/4]).
-export([clear/1, clear/3]).

-type creep() :: {CreepID :: integer(), Coord :: #p_coord{}}
	| {CreepID :: integer(), Coord :: #p_coord{}, Num :: integer()}
	| {CreepID :: integer(), Coord :: #p_coord{}, Num :: integer(), Opts :: map()}.

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%%-----------------------------------------------
%% @doc 异步添加怪物
-spec add([creep()], #role_st{}) ->
	no_return().
%%-----------------------------------------------
add(Creeps, RoleSt) when is_record(RoleSt, role_st) ->
	#role_st{spid=ScenePid} = RoleSt,
	scene:route(ScenePid, creep_agent, add, Creeps);
add(Creeps, ScenePid) when is_pid(ScenePid) ->
	scene:route(ScenePid, creep_agent, add, Creeps).


%%-----------------------------------------------
%% @doc 异步添加怪物
-spec add(integer(), integer(), integer(), [creep()]) ->
	no_return().
%%-----------------------------------------------
add(SceneID, RoomID, LineID, Creeps) ->
	ScenePid = scene:get_pid(SceneID, RoomID, LineID),
	scene:route(ScenePid, creep_agent, add, Creeps).

%%-----------------------------------------------
%% @doc 同步添加怪物
-spec sync_add([creep()], #role_st{}) ->
	[ActorID :: integer()].
%%-----------------------------------------------
sync_add(Creeps, RoleSt) when is_record(RoleSt, role_st) ->
	#role_st{spid=ScenePid} = RoleSt,
	scene:sync_route(ScenePid, creep_agent, add, Creeps);
sync_add(Creeps, ScenePid) when is_pid(ScenePid) ->
	scene:sync_route(ScenePid, creep_agent, add, Creeps).


%%-----------------------------------------------
%% @doc 同步添加怪物
-spec sync_add(integer(), integer(), integer(), [creep()]) ->
	[ActorID :: integer()].
%%-----------------------------------------------
sync_add(SceneID, RoomID, LineID, Creeps) ->
	ScenePid = scene:get_pid(SceneID, RoomID, LineID),
	scene:sync_route(ScenePid, creep_agent, add, Creeps).


%%-----------------------------------------------
%% @doc 删除怪物
-spec del([integer()], #role_st{}) ->
	no_return().
%%-----------------------------------------------
del(ActorIDs, RoleSt) when is_record(RoleSt, role_st) ->
	#role_st{spid=ScenePid} = RoleSt,
	scene:route(ScenePid, creep_agent, del, ActorIDs);
del(ActorIDs, ScenePid) when is_pid(ScenePid) ->
	scene:route(ScenePid, creep_agent, del, ActorIDs).


%%-----------------------------------------------
%% @doc 删除怪物
-spec del(integer(), integer(), integer(), [integer()]) ->
	no_return().
%%-----------------------------------------------
del(SceneID, RoomID, LineID, ActorIDs) ->
	ScenePid = scene:get_pid(SceneID, RoomID, LineID),
	scene:route(ScenePid, creep_agent, del, ActorIDs).


%%-----------------------------------------------
%% @doc 清理怪物
-spec clear(#role_st{}) ->
	no_return().
%%-----------------------------------------------
clear(RoleSt) when is_record(RoleSt, role_st) ->
	#role_st{spid=ScenePid} = RoleSt,
	scene:route(ScenePid, creep_agent, clear);
clear(ScenePid) when is_pid(ScenePid) ->
	scene:route(ScenePid, creep_agent, clear).


%%-----------------------------------------------
%% @doc 清理怪物
-spec clear(integer(), integer(), integer()) ->
	no_return().
%%-----------------------------------------------
clear(SceneID, RoomID, LineID) ->
	ScenePid = scene:get_pid(SceneID, RoomID, LineID),
	scene:route(ScenePid, creep_agent, clear).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
