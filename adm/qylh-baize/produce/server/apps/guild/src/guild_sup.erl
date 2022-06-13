%%%===================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%===================================================================

-module(guild_sup).

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
            id       => guild_agent_sup,
            start    => {guild_agent_sup, start_link, []},
            restart  => permanent,
            shutdown => infinity,
            type     => supervisor,
            modules  => [guild_agent_sup]
        },
        #{
            id       => guild_manager,
            start    => {guild_manager, start_link, []},
            restart  => permanent,
            shutdown => infinity,
            type     => worker,
            modules  => [guild_manager]
        }
    ],
    {ok, {SupFlags, ChildSpecs}}.
