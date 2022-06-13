%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(game_alarm).

-behaviour(gen_event).

-include("game.hrl").

%% gen_event callbacks
-export([init/1]).
-export([handle_event/2]).
-export([handle_call/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
-export([start/0]).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
start() ->
	memsup:set_procmem_high_watermark(0.05),
	alarm_handler:add_alarm_handler(?MODULE).

init(_) ->
	{ok, undefined}.

handle_event({set_alarm, {process_memory_high_watermark, Pid}}, State) ->
	erlang:spawn(fun() ->
		ProcInfo = erlang:process_info(Pid, [
			registered_name,
			initial_call,
			current_function,
			messages
		]),
		?fatal("process alarm: ~p", [ProcInfo])
	end),
	{ok, State};
handle_event(_Event, State) ->
	{ok, State}.

handle_call(_Request, _State) ->
	{remove_handler, {error, unknown_call}}.

handle_info(_Info, State) ->
	{ok, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
