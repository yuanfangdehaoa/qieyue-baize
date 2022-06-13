%%%===================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%===================================================================

-module(role_agent_sup).

-behaviour(supervisor).

%% supervisor callbacks
-export([init/1]).
%% API
-export([start_link/0]).
-export([start_role/2]).
-export([stop_role/1]).

-define(SERVER, ?MODULE).

%%%-------------------------------------------------------------------
%%% API Functions
%%%-------------------------------------------------------------------
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, {}).

start_role(RoleID, GatePid) ->
    supervisor:start_child(?SERVER, [RoleID, GatePid]).

stop_role(RolePid) ->
    supervisor:terminate_child(?SERVER, RolePid).

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
            id       => role_agent,
            start    => {role_agent, start_link, []},
            restart  => temporary,
            shutdown => infinity,
            type     => worker,
            modules  => [role_agent]
        }
    ],
    {ok, {SupFlags, ChildSpecs}}.
