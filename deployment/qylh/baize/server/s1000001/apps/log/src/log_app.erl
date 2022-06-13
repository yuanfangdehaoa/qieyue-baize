%% @author rong
%% @doc 
-module(log_app).

-behaviour(application).

%% application callbacks
-export([start/2, stop/1]).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
start(_, _) ->
    log_sup:start_link().

stop(_State) ->
    ok.
