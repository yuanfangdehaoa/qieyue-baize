%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(game_role).

-include("role.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([get_online_roles/0, get_online_roles/1]).
-export([get_alive_roles/0]).
-export([get_scene_roles/1, get_scene_roles/2]).
-export([get_guild_roles/1]).
-export([get_team_roles/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%%-----------------------------------------------
%% @doc 获取所有在线的角色id
-spec get_online_roles() ->
	[integer()].
%%-----------------------------------------------
get_online_roles() ->
	online_server:get_roles().

get_online_roles(Filter) ->
	RoleIDs = online_server:get_roles(),
	lists:filter(fun
		(RoleID) ->
			{ok, Cache} = role:get_cache(RoleID),
			Cache#role_cache.level >= maps:get(level, Filter, 0) andalso
			Cache#role_cache.wake >= maps:get(wake, Filter, 0)
	end, RoleIDs).


get_alive_roles() ->
	[Pid || {_, Pid, _, _} <- supervisor:which_children(role_agent_sup)].

%%-----------------------------------------------
%% @doc 获取指定场景的角色id
-spec get_scene_roles(pid()) ->
	[integer()].
%%-----------------------------------------------
get_scene_roles(ScenePid) ->
	scene:get_actids(ScenePid, ?ACTOR_TYPE_ROLE).


%%-----------------------------------------------
%% @doc 获取指定坐标附近的角色id
-spec get_scene_roles(pid(), #p_coord{}) ->
	[integer()].
%%-----------------------------------------------
get_scene_roles(ScenePid, Coord) ->
	scene:get_actids(ScenePid, ?ACTOR_TYPE_ROLE, Coord).


%%-----------------------------------------------
%% @doc 获取指定帮派的角色id
-spec get_guild_roles(pid() | integer()) ->
	[integer()].
%%-----------------------------------------------
get_guild_roles(GuildRef) ->
	guild:get_membids(GuildRef).


%%-----------------------------------------------
%% @doc 获取指定队伍的角色id
-spec get_team_roles(integer()) ->
	[integer()].
%%-----------------------------------------------
get_team_roles(TeamID) ->
	team_server:get_role_ids(TeamID).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
