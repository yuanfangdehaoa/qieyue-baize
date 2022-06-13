%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_magic_dungeai).

-include("btree.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([stat/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
stat(SceneSt) ->
	% ?debug("---------结算"),
	#scene_st{dunge=DungeID, floor=FloorID} = SceneSt,
	#dunge_st{clear=IsClear, roles=[RoleID]} = dunge_util:get_state(),
	role:route(RoleID, dunge_magic, dunge_over, {IsClear, DungeID, FloorID}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
