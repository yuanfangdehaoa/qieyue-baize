%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(scene_app).

-behaviour(application).

%% application callbacks
-export([start/2, stop/1]).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
start(_, _) ->
    scene_sup:start_link().

stop(_State) ->
    ok.
