%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(scene_config).

-include("scene.hrl").
-include("proto.hrl").

%% API
-export([size/1]).
-export([width/1]).
-export([height/1]).
-export([walkable/2, walkable/3]).
-export([jumpable/2]).
-export([is_safe/2, is_safe/3]).
-export([portal/2]).
-export([born/1]).
-export([reborn/1]).
-export([hunt/1]).
-export([npcs/1]).
-export([creeps/1]).

-define(MASK_SAFE, 2#10000000).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 场景大小
size(SceneID) ->
    Mod = mod_mask(SceneID),
    Mod:size().

%% 场景宽度
width(SceneID) ->
    Mod = mod_mask(SceneID),
    Mod:width().

%% 场景高度
height(SceneID) ->
    Mod = mod_mask(SceneID),
    Mod:height().

%% 是否可走
walkable(SceneID, Coord) ->
    {TX, TY} = ?tile(Coord#p_coord.x, Coord#p_coord.y),
    walkable(SceneID, TX, TY).

walkable(SceneID, TX, TY) ->
	Mod = mod_mask(SceneID),
	TYs = Mod:mask(TX),
	case 0 =< TY andalso TY < erlang:size(TYs) of
		true  -> element(TY+1, TYs) > 0;
		false -> false
	end.

%% 是否跳跃点
jumpable(SceneID, Coord) ->
    Mod = mod_actor(SceneID),
	jumpable2(Mod:get_jump(), Coord).

%% 安全区
is_safe(SceneID, Coord) ->
    {TX, TY} = ?tile(Coord#p_coord.x, Coord#p_coord.y),
    is_safe(SceneID, TX, TY).

is_safe(SceneID, TX, TY) ->
	Mod = mod_mask(SceneID),
	TYs = Mod:mask(TX),
    case 0 =< TY andalso TY < erlang:size(TYs) of
		true  -> element(TY+1, TYs) band ?MASK_SAFE == ?MASK_SAFE;
		false -> false
	end.

%% 传送点
%% {CurCoord, DstScene, DstCoord}
portal(SceneID, PortalID) ->
	Mod = mod_actor(SceneID),
    Mod:get_portal(PortalID).

%% 出生点
born(SceneID) ->
	Mod = mod_actor(SceneID),
	Mod:get_born().

%% 复活点
reborn(SceneID) ->
	Mod = mod_actor(SceneID),
	Mod:get_reborn().

%% 寻宝点
hunt(SceneID) ->
	Mod = mod_actor(SceneID),
	Mod:get_hunt().

%% npc
npcs(SceneID) ->
	Mod = mod_actor(SceneID),
	Mod:get_npcs().

%% 怪物
creeps(SceneID) ->
	Mod = mod_actor(SceneID),
	Mod:get_creeps().

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
mod_mask(SceneID) ->
    ut_conv:to_atom( lists:concat(["scene_mask_", SceneID]) ).

mod_actor(SceneID) ->
    ut_conv:to_atom( lists:concat(["scene_actor_", SceneID]) ).

jumpable2([Coord1 | T], Coord2) ->
	case scene_util:is_nearby(Coord1, Coord2) of
		true  -> true;
		false -> jumpable2(T, Coord2)
	end;
jumpable2([], _) ->
	false.