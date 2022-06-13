%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(cron_manager).

-behaviour(gen_server).

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([start_cron/3]).
-export([stop_cron/1]).
-export([get_state/1]).

-define(SERVER, ?MODULE).

-define(ETS_CRON, ets_cron).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

start_cron(Ref, Type, Cron) ->
	gen_server:call(?SERVER, {start_cron, Ref, Type, Cron}).

stop_cron(Ref) ->
	gen_server:cast(?SERVER, {stop_cron, Ref}).

get_state(Ref) ->
	case ets:lookup(?ETS_CRON, Ref) of
		[{_,_,Pid}] ->
			gen_server:call(Pid, get_state);
		[] ->
			{error, not_exist}
	end.

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	process_flag(trap_exit, true),
	ets:new(?ETS_CRON, [named_table, public]),
	{ok, undefined}.


handle_call({start_cron, Ref, Type, Cron}, _From, State) ->
	case ets:member(?ETS_CRON, Ref) of
		true  ->
			{reply, {error, already_started}, State};
		false ->
			{ok, Pid} = cron_worker_sup:start_cron(Ref, Type, Cron),
			MRef = erlang:monitor(process, Pid),
			ets:insert(?ETS_CRON, {Ref, MRef, Pid}),
			{reply, ok, State}
	end;

handle_call(_Request, _From, State) ->
	{reply, {error, unknown_call}, State}.


handle_cast({stop_cron, Ref}, State) ->
	case ets:lookup(?ETS_CRON, Ref) of
		[{_, MRef, Pid}] ->
			erlang:demonitor(MRef),
			cron_worker_sup:stop_cron(Pid),
			ets:delete(?ETS_CRON, Ref);
		[] ->
			ignore
	end,
	{noreply, State};

handle_cast(_Msg, State) ->
	{noreply, State}.


handle_info({'DOWN',MRef,_,_,_}, State) ->
	ets:match_delete(?ETS_CRON, {'_', MRef, '_'}),
	{noreply, State};

handle_info(_Info, State) ->
	{noreply, State}.


terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
