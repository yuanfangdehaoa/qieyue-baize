%%%===================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%===================================================================

-module(cron_worker_sup).

-behaviour(supervisor).

%% supervisor callbacks
-export([init/1]).
%% API
-export([start_link/0]).
-export([start_cron/3]).
-export([stop_cron/1]).

-define(SERVER, ?MODULE).

%%%-------------------------------------------------------------------
%%% API Functions
%%%-------------------------------------------------------------------
start_link() ->
	supervisor:start_link({local, ?SERVER}, ?MODULE, {}).

start_cron(Ref, Type, Cron) ->
    supervisor:start_child(?SERVER, [Ref, Type, Cron]).

stop_cron(Pid) ->
    supervisor:terminate_child(?SERVER, Pid).

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
			id       => cron_worker,
			start    => {cron_worker, start_link, []},
			restart  => permanent,
			shutdown => 5000,
			type     => worker,
			modules  => [cron_worker]
    	}
    ],
    {ok, {SupFlags, ChildSpecs}}.
