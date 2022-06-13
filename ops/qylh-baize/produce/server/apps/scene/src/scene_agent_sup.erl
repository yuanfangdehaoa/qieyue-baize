%%%===================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%===================================================================

-module(scene_agent_sup).

-behaviour(supervisor).

%% supervisor callbacks
-export([init/1]).
%% API
-export([start_link/0]).
-export([start_scene/4]).
-export([stop_scene/1]).

-define(SERVER, ?MODULE).

%%%-------------------------------------------------------------------
%%% API Functions
%%%-------------------------------------------------------------------
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, {}).

start_scene(SceneID, DungeID, LineID, Opts) ->
    supervisor:start_child(?SERVER, [SceneID, DungeID, LineID, Opts]).

stop_scene(ScenePid) ->
    supervisor:terminate_child(?SERVER, ScenePid).

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
            id       => scene_agent,
            start    => {scene_agent, start_link, []},
            restart  => temporary,
            shutdown => 5000,
            type     => worker,
            modules  => [scene_agent]
        }
    ],
    {ok, {SupFlags, ChildSpecs}}.
