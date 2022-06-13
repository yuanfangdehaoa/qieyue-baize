%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(scene).

-include("creep.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").

%% API
-export([get_ref/2, get_ref/3]).
-export([get_pid/2, get_pid/3]).
-export([create/1, create/2, create/3]).
-export([destroy/1, destroy/2, destroy/3]).
-export([kickout/1, kickout/2, kickout/3]).
-export([bcast/2, bcast/3, bcast/4]).
-export([get_roles/1, get_roles/2]).
-export([get_actids/1, get_actids/2, get_actids/3]).
-export([get_actors/1, get_actors/2, get_actors/3]).
-export([get_actor/2]).
-export([call/2]).
-export([cast/2]).
-export([route/3, route/4]).
-export([sync_route/2, sync_route/3, sync_route/4]).
-export([update_actor/3]).
-export([get_cross/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%%-----------------------------------------------
%% @doc 获取场景进程的引用
-spec get_ref(integer(), integer(), integer()) ->
    atom() | tuple().
%%-----------------------------------------------
get_ref(SceneID, RoomID) ->
    get_ref(SceneID, RoomID, ?MAIN_LINE).

get_ref(SceneID, RoomID, LineID) ->
    RegName = scene_util:reg_name(SceneID, RoomID, LineID),
    case scene_util:is_same_node(SceneID) of
        true  -> RegName;
        false -> {RegName, get_cross(SceneID)}
    end.


%%-----------------------------------------------
%% @doc 获取场景进程的pid
-spec get_pid(integer(), integer(), integer()) ->
    undefined | pid().
%%-----------------------------------------------
get_pid(SceneID, RoomID) ->
    get_pid(SceneID, RoomID, ?MAIN_LINE).

get_pid(SceneID, RoomID, LineID) ->
    RegName = scene_util:reg_name(SceneID, RoomID, LineID),
    case scene_util:is_same_node(SceneID) of
        true  -> erlang:whereis(RegName);
        false -> ?nil
    end.


%%-----------------------------------------------
%% @doc 创建场景
-spec create(SceneID, RoomID, Opts) -> Return when
    SceneID :: integer(),
    RoomID  :: integer(),
    Opts    :: map(),
    Return  :: {ok,pid()} | error().
%%-----------------------------------------------
create(SceneID) ->
    scene_manager:create(SceneID, 0, #{}).

create(SceneID, RoomID) ->
    scene_manager:create(SceneID, RoomID, #{}).

create(SceneID, RoomID, Opts) ->
    scene_manager:create(SceneID, RoomID, Opts).


%%-----------------------------------------------
%% @doc 销毁场景
-spec destroy(integer()) ->
    no_return().
%%-----------------------------------------------
destroy(SceneID) ->
    scene_manager:destroy(SceneID).

destroy(SceneID, RoomID) ->
    scene_manager:destroy(SceneID, RoomID).

destroy(SceneID, RoomID, LineID) ->
    scene_manager:destroy(SceneID, RoomID, LineID).


%%-----------------------------------------------
%% @doc 踢出场景
-spec kickout(integer(), integer(), integer()) ->
    no_return().
%%-----------------------------------------------
kickout(SceneID) ->
    scene_manager:kickout(SceneID).

kickout(SceneID, RoomID) ->
    scene_manager:kickout(SceneID, RoomID).

kickout(SceneID, RoomID, LineID) ->
    scene_manager:kickout(SceneID, RoomID, LineID).


%%-----------------------------------------------
%% @doc 场景广播
-spec bcast(integer(), integer(), tuple()) ->
    no_return().
%%-----------------------------------------------
bcast(SceneID, Toc) when is_integer(SceneID) ->
    scene_manager:bcast(SceneID, Toc);
bcast(ScenePid, Toc) when is_pid(ScenePid) ->
    gen_server:cast(ScenePid, {bcast, Toc}).

bcast(SceneID, RoomID, Toc) ->
    scene_manager:bcast(SceneID, RoomID, Toc).

bcast(SceneID, RoomID, LineID, Toc) ->
    scene_manager:bcast(SceneID, RoomID, LineID, Toc).


%%-----------------------------------------------
%% 获取场景中的 RoleID
-spec get_roles(pid() | integer()) ->
    [integer()].

-spec get_roles(pid() | integer(), #p_coord{}) ->
    [integer()].
%%-----------------------------------------------
get_roles(SceneRef) ->
    ?MODULE:get_actids(SceneRef, ?ACTOR_TYPE_ROLE).

get_roles(SceneRef, Coord) ->
    ?MODULE:get_actids(SceneRef, ?ACTOR_TYPE_ROLE, Coord).


%%-----------------------------------------------
%% 获取场景中的 ActorID
-spec get_actids(pid(), integer() | #p_coord{}) ->
    [integer()].

-spec get_actids(pid(), integer(), #p_coord{}) ->
    [integer()].
%%-----------------------------------------------
%% 获取场景中所有的 ActorID
get_actids(ScenePid) ->
    call(ScenePid, {get_actids, all}).

%% 获取场景中所有类型为 Type 的 ActorID, Type 参见 ACTOR_TYPE_xxx
get_actids(ScenePid, Type) when is_integer(Type) ->
    call(ScenePid, {get_actids, Type});
%% 获取场景中 Coord 坐标周围的 ActorID
get_actids(ScenePid, Coord) when is_record(Coord, p_coord) ->
    call(ScenePid, {get_actids, all, Coord}).

%% 获取场景中 Coord 坐标周围的类型为 Type 的 ActorID
get_actids(ScenePid, Type, Coord) ->
    call(ScenePid, {get_actids, Type, Coord}).


%%-----------------------------------------------
%% @doc 获取场景中的 #actor{}
-spec get_actors(pid(), integer() | #p_coord{}) ->
    [#actor{}].

-spec get_actors(pid(), integer(), #p_coord{}) ->
    [#actor{}].
%%-----------------------------------------------
%% 获取场景中所有的 #actor{}
get_actors(ScenePid) ->
    call(ScenePid, {get_actors, all}).

%% 获取场景中所有类型为 Type 的 #actor{}, Type 参见 ACTOR_TYPE_xxx
get_actors(ScenePid, Type) when is_integer(Type) ->
    call(ScenePid, {get_actors, Type});
%% 获取场景中 Coord 坐标周围的 #actor{}
get_actors(ScenePid, Coord) when is_tuple(Coord) ->
    call(ScenePid, {get_actors, all, Coord}).

%% 获取场景中 Coord 坐标周围的类型为 Type 的 #actor{}
get_actors(ScenePid, Type, Coord) ->
    call(ScenePid, {get_actors, Type, Coord}).


%%-----------------------------------------------
%% @doc 获取场景对象
-spec get_actor(pid(), integer()) ->
    {ok, #actor{}} | error().
%%-----------------------------------------------
get_actor(ScenePid, ActorID) ->
    call(ScenePid, {get_actor, ActorID}).


%%-----------------------------------------------
%% @doc call 场景进程
-spec call(pid(), any()) ->
    any().
%%-----------------------------------------------
-ifdef(DEBUG).

call(ScenePid, Req) ->
    ?_check(ScenePid /= self(), ?ERR_GAME_BAD_CALL),
    try
        gen_server:call(ScenePid, Req)
    catch Class:Reason:Stacktrace ->
        ?stacktrace(Class, Reason, Stacktrace),
        ?err(?ERR_SCENE_CHANGE_FAIL)
    end.

-else.

call(ScenePid, Req) ->
    try
        gen_server:call(ScenePid, Req)
    catch Class:Reason:Stacktrace ->
        ?stacktrace(Class, Reason, Stacktrace),
        ?err(?ERR_SCENE_CHANGE_FAIL)
    end.

-endif.


%%-----------------------------------------------
%% @doc cast 场景进程
-spec cast(pid(), any()) ->
    no_return().
%%-----------------------------------------------
cast(ScenePid, Msg) ->
    gen_server:cast(ScenePid, Msg).


%%-----------------------------------------------
%% @doc 路由转发
%% 场景进程会以 Mod:Fun(Args, SceneSt) 进行回调
-spec route(pid() | integer(), module(), function(), any()) ->
    no_return().
%%-----------------------------------------------
route(SceneID, Mod, Fun) when is_integer(SceneID) ->
    scene_manager:route(SceneID, {route,Mod,Fun});
route(ScenePid, Mod, Fun) when is_pid(ScenePid) ->
    erlang:send(ScenePid, {route,Mod,Fun}).

route(SceneID, Mod, Fun, Args) when is_integer(SceneID) ->
    scene_manager:route(SceneID, {route,Mod,Fun,Args});
route(ScenePid, Mod, Fun, Args) ->
    erlang:send(ScenePid, {route,Mod,Fun,Args}).


%%-----------------------------------------------
%% @doc 同步路由
%% 场景进程会以 Mod:Fun(Args, SceneSt) 进行回调
-spec sync_route(pid(), module(), function(), any()) ->
    any().
%%-----------------------------------------------
sync_route(ScenePid, Func) ->
    call(ScenePid, {sync_route, Func}).

sync_route(ScenePid, Mod, Fun) ->
    call(ScenePid, {sync_route, Mod, Fun}).

sync_route(ScenePid, Mod, Fun, Args) ->
    call(ScenePid, {sync_route, Mod, Fun, Args}).


%%-----------------------------------------------
%% @doc 更新 actor
-spec update_actor(pid(), integer(), [{Key :: atom(), Val :: any()}]) ->
    no_return().
%%-----------------------------------------------
update_actor(ScenePid, RoleID, Update) ->
    gen_server:cast(ScenePid, {update_actor, RoleID, Update}).


%%-----------------------------------------------
%% @doc 获取跨服场景所在节点
-spec get_cross(integer()) ->
    node().
%%-----------------------------------------------
get_cross(SceneID) ->
    Rule = cfg_scene:cluster(SceneID),
    cluster:get_cross(Rule).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
