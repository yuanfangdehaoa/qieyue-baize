%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_newbie_fission_dungeai).

-include("game.hrl").
-include("dunge.hrl").

%% API
-export([summon/1]).
-export([is_over/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
summon(SceneSt) ->
	DungeSt = dunge_util:get_state(),
	dunge_util:set_state(DungeSt#dunge_st{opts=#{fission=>1}}),
	dunge_ai:summon(SceneSt).

is_over(_SceneSt) ->
	#dunge_st{opts=Opts} = dunge_util:get_state(),
	maps:get(fission, Opts) == 0.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
