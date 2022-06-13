%%%===================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%===================================================================

-module(cron_sup).

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
    ChildSpecs = [
        #{
            id       => cron_manager,
            start    => {cron_manager, start_link, []},
            restart  => permanent,
            shutdown => 5000,
            type     => worker,
            modules  => [cron_manager]
        },

    	#{
    		id       => cron_worker_sup,
    		start    => {cron_worker_sup, start_link, []},
    		restart  => temporary,
    		shutdown => 5000,
    		type     => supervisor,
    		modules  => [cron_worker_sup]
    	}
    ],
    {ok, {SupFlags, ChildSpecs}}.
