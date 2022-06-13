%%%===================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%===================================================================

-module(game_sup).

-behaviour(supervisor).

%% supervisor callbacks
-export([init/1]).
%% API
-export([start_link/0]).
-export([child_spec/1]).

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
    ChildSpecs = [
        #{
            id       => game_pool,
            start    => {poolboy, start_link, [
                [
                    {name, {local, game_pool}},
                    {worker_module, game_pool},
                    {size, 512},
                    {max_overflow, 1024},
                    {strategy, fifo}
                ],
                []
            ]},
            restart  => permanent,
            shutdown => 5000,
            type     => worker,
            modules  => [poolboy]
        }
    ] ++ [child_spec(Mod) ||
        Mod <- game_start:mods( game_env:get_type() )
    ],
    {ok, {SupFlags, ChildSpecs}}.

child_spec(ChildID) ->
    #{
        id       => ChildID,
        start    => {ChildID, start_link, []},
        restart  => permanent,
        shutdown => infinity,
        type     => worker,
        modules  => [ChildID]
    }.