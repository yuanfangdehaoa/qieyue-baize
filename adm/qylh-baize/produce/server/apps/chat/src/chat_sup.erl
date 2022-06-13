%%%===================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%===================================================================

-module(chat_sup).

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
			id       => chat_server,
			start    => {chat_server, start_link, []},
			restart  => permanent,
			shutdown => 5000,
			type     => worker,
			modules  => [chat_server]
    	},
        #{
            id       => chat_contact,
            start    => {chat_contact, start_link, []},
            restart  => permanent,
            shutdown => 5000,
            type     => worker,
            modules  => [chat_contact]
        },
        #{
            id       => chat_silent,
            start    => {chat_silent, start_link, []},
            restart  => permanent,
            shutdown => 5000,
            type     => worker,
            modules  => [chat_silent]
        }
    ],
    {ok, {SupFlags, ChildSpecs}}.
