%%%===================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%===================================================================

-module(guild_agent_sup).

-behaviour(supervisor).

%% supervisor callbacks
-export([init/1]).
%% API
-export([start_link/0]).
-export([start_guild/1]).
-export([stop_guild/1]).

-define(SERVER, ?MODULE).

%%%-------------------------------------------------------------------
%%% API Functions
%%%-------------------------------------------------------------------
start_link() ->
	supervisor:start_link({local, ?SERVER}, ?MODULE, {}).

start_guild(GuildID) ->
	supervisor:start_child(?SERVER, [GuildID]).

stop_guild(GuildPid) ->
	supervisor:terminate_child(?SERVER, GuildPid).

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
			id       => guild_agent,
			start    => {guild_agent, start_link, []},
			restart  => temporary,
			shutdown => infinity,
			type     => worker,
			modules  => [guild_agent]
    	}
    ],
    {ok, {SupFlags, ChildSpecs}}.
