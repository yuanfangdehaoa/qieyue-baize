%%%===================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%===================================================================

-module(yunying_agent_sup).

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

start_agent(YYActID) ->
	supervisor:start_child(?SERVER, [YYActID]).

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
			id       => yunying_agent,
			start    => {yunying_agent, start_link, []},
			restart  => temporary,
			shutdown => infinity,
			type     => worker,
			modules  => [yunying_agent]
    	}
    ],
    {ok, {SupFlags, ChildSpecs}}.
