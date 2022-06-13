%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(creep_util).

-include("creep.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").

%% API
-export([get_event/1]).
-export([set_event/3]).
-export([del_event/1]).
-export([get_events/0]).
-export([set_events/1]).
-export([clr_events/0]).
-export([add_event/3]).
-export([gen_ai/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
-define(k_creep_event, {creep_event, ActorID}).
get_event(ActorID) ->
	get(?k_creep_event).

set_event(ActorID, Event, Args) ->
	put(?k_creep_event, {Event, Args}).

del_event(ActorID) ->
    erase(?k_creep_event).


-define(k_creep_events, creep_events).
get_events() ->
	get(?k_creep_events).

set_events(Events) ->
	put(?k_creep_events, Events).

clr_events() ->
	erase(?k_creep_events).

add_event(ActorID, Event, Args) ->
	Events = case get_events() of
		?nil -> [];
		List -> List
	end,
	set_events([{ActorID,Event,Args} | Events]).

gen_ai(CreepID) ->
    #cfg_creep{ai_id=WtList} = cfg_creep:find(CreepID),
    case WtList == [] of
    	true  -> 0;
    	false -> ut_rand:weight(WtList)
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
