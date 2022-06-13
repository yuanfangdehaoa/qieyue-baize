%%%===================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%===================================================================

-module(rank_sup).

-behaviour(supervisor).

%% supervisor callbacks
-export([init/1]).
%% API
-export([start_link/0]).
-export([start_rank/1]).
-export([stop_rank/1]).

-define(SERVER, ?MODULE).

%%%-------------------------------------------------------------------
%%% API Functions
%%%-------------------------------------------------------------------
start_link() ->
	supervisor:start_link({local,?SERVER}, ?MODULE, {}).

start_rank(RankID) ->
	supervisor:start_child(?SERVER, [RankID]).

stop_rank(RankPid) ->
	supervisor:terminate_child(?SERVER, RankPid).

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
			id       => rank_server,
			start    => {rank_server, start_link, []},
			restart  => permanent,
			shutdown => infinity,
			type     => worker,
			modules  => [rank_server]
    	}
    ],
    {ok, {SupFlags, ChildSpecs}}.
