%%%===================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%===================================================================

-module(cluster_sup).

-behaviour(supervisor).

-include("game.hrl").

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
    ChildSpecs = case game_env:get_type() of
    	?SERVER_TYPE_LOCAL ->
    		[
    			#{
    				id       => cluster_local,
    				start    => {cluster_local, start_link, []},
    				restart  => permanent,
    				shutdown => 5000,
    				type     => worker,
    				modules  => [cluster_local]
    			}
    		];
    	?SERVER_TYPE_CROSS ->
    		[
    			#{
					id       => cluster_cross,
					start    => {cluster_cross, start_link, []},
					restart  => permanent,
					shutdown => 5000,
					type     => worker,
					modules  => [cluster_cross]
				}
    		];
    	?SERVER_TYPE_CENTER ->
    		[
	    		#{
	    			id       => cluster_center,
	    			start    => {cluster_center, start_link, []},
	    			restart  => permanent,
	    			shutdown => 5000,
	    			type     => worker,
	    			modules  => [cluster_center]
	    		}
    		]
    end,
    {ok, {SupFlags, ChildSpecs}}.
