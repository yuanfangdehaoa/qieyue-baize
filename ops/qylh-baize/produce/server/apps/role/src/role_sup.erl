%%%===================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%===================================================================

-module(role_sup).

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
            id       => role_manager,
            start    => {role_manager, start_link, []},
            restart  => permanent,
            shutdown => infinity,
            type     => worker,
            modules  => [role_manager]
        },
        #{
            id       => role_timer,
            start    => {role_timer, start_link, []},
            restart  => permanent,
            shutdown => infinity,
            type     => worker,
            modules  => [role_timer]
        },
        #{
            id       => role_agent_sup,
            start    => {role_agent_sup, start_link, []},
            restart  => permanent,
            shutdown => infinity,
            type     => supervisor,
            modules  => [role_agent_sup]
        }
    ],
    {ok, {SupFlags, ChildSpecs}}.
