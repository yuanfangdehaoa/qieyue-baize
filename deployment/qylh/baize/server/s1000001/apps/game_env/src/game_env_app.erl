%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(game_env_app).

-behaviour(application).

-include("game.hrl").
-include("table.hrl").

%% application callbacks
-export([start/2, stop/1]).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
start(_, _) ->
    game_env_sup:start_link().

stop(_State) ->
    ok.
