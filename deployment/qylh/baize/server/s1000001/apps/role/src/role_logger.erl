%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_logger).

-behaviour(gen_server).

-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).

-export([log/3, log/4]).

-define(SERVER, ?MODULE).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

log(LogType, Action, RoleSt) ->
    #role_st{role=RoleID, name=RoleName} = RoleSt,
    gen_server:cast(?SERVER, {log, RoleID, RoleName, LogType, Action}).

log(LogType, Action, RoleID, RoleName) ->
    gen_server:cast(?SERVER, {log, RoleID, RoleName, LogType, Action}).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	{ok, undefined}.

handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
    ?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.


do_handle_cast({log, RoleID, RoleName, LogType, Action}, State) ->
    ?notice("~w|~ts|~w|~ts", [RoleID, RoleName, LogType, jiffy:encode(Action)]),
    {noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.