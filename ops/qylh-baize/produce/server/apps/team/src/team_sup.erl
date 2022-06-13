%%%===================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%===================================================================

-module(team_sup).

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
			id       => team_server,
			start    => {team_server, start_link, []},
			restart  => permanent,
			shutdown => 5000,
			type     => worker,
			modules  => [team_server]
    	}
    ],
    {ok, {SupFlags, ChildSpecs}}.
