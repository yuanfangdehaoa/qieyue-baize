%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_newbie_fission_creepai).

-include("btree.hrl").
-include("dunge.hrl").
-include("scene.hrl").
-include("game.hrl").

%% API
-export([fission/2]).
-export([disappear/2]).
-export([is_over/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
fission(Actor, SceneSt) ->
	case creep_ai:fission(Actor, SceneSt) of
		?SUCCESS ->
			Creeps = cfg_creep:aiargs(Actor#actor.id),
			update_counter(length(Creeps)),
			?SUCCESS;
		?FAILURE ->
			?FAILURE
	end.

disappear(Actor, SceneSt) ->
	update_counter(-1),
	creep_ai:disappear(Actor, SceneSt).

is_over(_Actor, _SceneSt) ->
	DungeSt = dunge_util:get_state(),
	DungeSt#dunge_st.over.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
update_counter(Incr) ->
	DungeSt = #dunge_st{opts=Opts} = dunge_util:get_state(),
	Opts2   = ut_misc:maps_increase(fission, Incr, Opts),
	dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}).
