%%%===================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%===================================================================

-module(yunying_sup).

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
			id       => yunying_manager,
			start    => {yunying_manager, start_link, []},
			restart  => permanent,
			shutdown => infinity,
			type     => worker,
			modules  => [yunying_manager]
    	},
        #{
            id       => yunying_agent_sup,
            start    => {yunying_agent_sup, start_link, []},
            restart  => permanent,
            shutdown => infinity,
            type     => worker,
            modules  => [yunying_agent_sup]
        }
    ],
    {ok, {SupFlags, ChildSpecs}}.
