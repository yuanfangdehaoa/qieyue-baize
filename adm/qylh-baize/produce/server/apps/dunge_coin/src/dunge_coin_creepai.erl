%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_coin_creepai).

-include("dunge.hrl").
-include("game.hrl").
-include("btree.hrl").
-include("scene.hrl").

%% API
-export([fission/2]).
-export([bomb/2]).
-export([is_timeout/2]).
-export([is_over/2]).

-define(CREEP_BOMB, 1100004).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
fission(Actor, SceneSt) ->
	% ?debug("--------------fission"),
	case ut_rand:random(1, 100) =< 5 of
		true  ->
			[Last] = cfg_creep:aiargs(?CREEP_BOMB),
			ETime = ut_time:seconds() + Last,
			Opts  = #{
				etime  => ETime,
				exargs => #{"disappear"=>ETime}
			},
			Creeps = [{?CREEP_BOMB, Actor#actor.coord, Opts}],
			creep_agent:add(Creeps, SceneSt);
		false ->
			ignore
	end,
	creep_ai:fission(Actor, SceneSt).


bomb(Actor, SceneSt) ->
	#actor{killer=Killer} = Actor,
	case Killer > 0 of
		true  ->
			creep_agent:clear(Killer, SceneSt),
			?SUCCESS;
		false ->
			?FAILURE
	end.


is_timeout(Actor, _SceneSt) ->
	% ?debug("--------------is_timeout"),
	ut_time:seconds() >= Actor#actor.etime.

is_over(_Actor, _SceneSt) ->
	DungeSt = dunge_util:get_state(),
	DungeSt#dunge_st.over.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
