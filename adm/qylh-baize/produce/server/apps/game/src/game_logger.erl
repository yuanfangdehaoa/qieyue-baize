%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(game_logger).

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
-export([add_log/2, add_log/3]).
-export([get_logs/1]).

-define(SERVER, ?MODULE).

-define(ETS_LOG, ets_log).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

%%-----------------------------------------------
%% @doc 增加日志
-spec add_log(any(), any()) ->
    no_return().
%%-----------------------------------------------
add_log(Key, Log) ->
	add_log(Key, Log, 50).

add_log(Key, Log, Size) ->
	gen_server:cast(?SERVER, {add_log, Key, Log, Size}).


%%-----------------------------------------------
%% @doc 获取日志
-spec get_logs(any()) ->
	any().
%%-----------------------------------------------
get_logs(Key) ->
	case ets:lookup(?ETS_LOG, Key) of
		[{_, Logs}] ->
			Logs;
		[] ->
			[]
	end.

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	ets:new(?ETS_LOG, [named_table, public]),
	{ok, undefined}.

handle_call(_Request, _From, State) ->
	{reply, {error, unknown_call}, State}.

handle_cast({add_log, Key, Log, Size}, State) ->
	case ets:lookup(?ETS_LOG, Key) of
		[{_, Logs}] ->
			Logs2 = lists:sublist([Log | Logs], Size),
			ets:insert(?ETS_LOG, [{Key, Logs2}]);
		[] ->
			ets:insert(?ETS_LOG, {Key, [Log]})
	end,
	{noreply, State};

handle_cast(_Msg, State) ->
	{noreply, State}.

handle_info(_Info, State) ->
	{noreply, State}.

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
