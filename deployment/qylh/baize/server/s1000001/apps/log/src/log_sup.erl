%% @author rong
%% @doc 
-module(log_sup).

-behaviour(supervisor).

%% supervisor callbacks
-export([init/1]).
%% API
-export([start_link/0]).

-define(SERVER, ?MODULE).

%%%-------------------------------------------------------------------
%%% API Functions
%%%-------------------------------------------------------------------
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, {}).

%%%-------------------------------------------------------------------
%%% Callback Functions
%%%-------------------------------------------------------------------
init(_Args) ->
    SupFlags = #{
        strategy  => one_for_one,
        intensity => 10,
        period    => 5
    },
    case application:get_env(log, rabbit_host) of
        {ok, _} ->
            ChildSpecs = [
                #{
                    id       => log_server,
                    start    => {log_server, start_link, []},
                    restart  => permanent,
                    shutdown => 5000,
                    type     => worker,
                    modules  => [log_server]
                }
            ];
        _ ->
            ChildSpecs = []
    end,
    {ok, {SupFlags, ChildSpecs}}.
