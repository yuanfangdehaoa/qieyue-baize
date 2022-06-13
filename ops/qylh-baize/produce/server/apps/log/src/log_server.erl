%% @author rong
%% @doc
-module(log_server).

-behaviour(gen_server).

-include("amqp_client.hrl").
-include("logarch.hrl").
-include("game.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([log/2]).

-define(SERVER, ?MODULE).

-record(state, {connection, channel}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

log(Type, Msg) ->
    case application:get_env(log, rabbit_host) of
        {ok, _} ->
            gen_server:cast(?SERVER, {log, Type, ut_conv:to_binary(Msg)});
        _ ->
            ignore
    end.

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
    process_flag(trap_exit, true),
    {ok, Connection} = connect_rabbit(),
    self() ! init,
    {ok, #state{connection = Connection}}.

handle_call(_Request, _From, State) ->
    {reply, ok, State}.

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
    ?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, #state{connection=Connection, channel=Channel}) ->
    ?_if(Channel =/= ?nil, amqp_channel:close(Channel)),
    ?_if(Connection =/= ?nil, amqp_connection:close(Connection)),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_info(init, State) ->
    #state{connection=Connection} = State,
    {ok, Channel} = init_channel(Connection),
    {noreply, State#state{channel=Channel}};

do_handle_info({'DOWN', _Ref, process, _Pid, Reason}, State) ->
    ?error(" connection down ~p~n", [Reason]),
    State2 = State#state{connection=?nil, channel=?nil},
    reconnect(State2);

do_handle_info(reconnect, State) ->
    reconnect(State);

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.

do_handle_cast({log, Type, Message}, State) ->
    #state{connection=Connection, channel=Channel} = State,
    case Connection =/= ?nil andalso Channel =/= ?nil of
        true ->
            amqp_channel:cast(State#state.channel, #'basic.publish'{
                exchange    = ?EXCHANGE,
                routing_key = Type
            }, #amqp_msg{payload = Message});
        false ->
            ignore
    end,
    {noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.

connect_rabbit() ->
    case amqp_connection:start(#amqp_params_network{
        virtual_host = log_env:vhost(),
        host         = log_env:host(),
        username     = log_env:username(),
        password     = log_env:password()
    }) of
        {ok, Connection} ->
            erlang:monitor(process, Connection),
            {ok, Connection};
        _ ->
            error
    end.

init_channel(Connection) ->
    {ok, Channel} = amqp_connection:open_channel(Connection),
    amqp_channel:call(Channel, #'exchange.declare'{exchange = ?EXCHANGE,
        type = <<"direct">>, durable = true}),
    [begin
        #'queue.declare_ok'{queue = Queue} =
            amqp_channel:call(Channel, #'queue.declare'{queue = Type, durable = true}),
        amqp_channel:call(Channel, #'queue.bind'{
            exchange = ?EXCHANGE, routing_key = Type, queue = Queue})
    end || Type <- [?DATA_QUEUE, ?LOGS_QUEUE]],
    {ok, Channel}.

reconnect(State) ->
    case connect_rabbit() of
        {ok, Connection} ->
            {ok, Channel} = init_channel(Connection),
            {noreply, State#state{connection=Connection, channel=Channel}};
        _ ->
            erlang:send_after(1000, self(), reconnect),
            ?debug(" try reconnect rabbitmq failed ...", []),
            {noreply, State}
    end.
