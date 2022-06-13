%% @author rong
%% @doc

-module(wedding_agent_sup).

-behaviour(supervisor).

%% supervisor callbacks
-export([init/1]).
%% API
-export([start_link/0]).
-export([start_agent/1]).

-define(SERVER, ?MODULE).

%%%-------------------------------------------------------------------
%%% API Functions
%%%-------------------------------------------------------------------
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, {}).

start_agent(Wedding) ->
    supervisor:start_child(?SERVER, [Wedding]).

%%%-------------------------------------------------------------------
%%% Callback Functions
%%%-------------------------------------------------------------------
init(_Args) ->
    SupFlags = #{
        strategy  => simple_one_for_one,
        intensity => 10,
        period    => 5
    },
    ChildSpecs = [
        #{
            id       => wedding_agent,
            start    => {wedding_agent, start_link, []},
            restart  => temporary,
            shutdown => 5000,
            type     => worker,
            modules  => [wedding_agent]
        }
    ],
    {ok, {SupFlags, ChildSpecs}}.
