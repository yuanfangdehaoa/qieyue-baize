%% @author rong
%% @doc
-module(junhai_log_server).

-behaviour(gen_server).

-include("game.hrl").

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/0, add_log/1, add_log/2]).

-define(SERVER, ?MODULE).
-record(state, {logs = [], num = 0}).

-define(MAX_UPLOAD, 500).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

add_log(Log) ->
    add_log(Log, false).

add_log(Log, Sync) ->
    Url = game_env:get_junhai_upload(),
    case Url == ?nil orelse Url == "" of
        true  -> ignore;
        false -> gen_server:cast(?SERVER, {add, Log, Sync})
    end.

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({}) ->
    process_flag(trap_exit, true),
    loop_upload(),
    {ok, #state{}}.

handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

handle_cast({add, Log, true}, State) ->
    spawn(fun() -> upload([Log]) end),
    {noreply, State};

handle_cast({add, Log, false}, State) ->
    #state{logs = Logs, num = Num} = State,
    case Num+1 >= ?MAX_UPLOAD of
        true ->
            upload([Log|Logs]),
            {noreply, State#state{logs = [], num = 0}};
        false ->
            {noreply, State#state{logs = [Log|Logs], num = Num+1}}
    end;


handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(upload, State) ->
    loop_upload(),
    upload(State#state.logs),
    {noreply, State#state{logs=[], num=0}};

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State=#state{logs=Logs}) ->
    ?_if(Logs /= [], upload(Logs)),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
upload(Logs) ->
    try
        case game_env:get_junhai_upload() of
            ""  ->
                ignore;
            Url ->
                Headers = [{<<"Content-Type">>, <<"application/json">>}],
                Body    = jiffy:encode(Logs),
                web_request:post(Url, "", #{}, Headers, Body, [])
        end
    catch Class:Reason:Stacktrace ->
        ?stacktrace(Class, Reason, Stacktrace)
    end.

loop_upload() ->
    erlang:send_after(timer:minutes(5), self(), upload).
