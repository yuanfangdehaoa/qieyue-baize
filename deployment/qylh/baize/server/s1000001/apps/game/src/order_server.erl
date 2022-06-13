%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(order_server).

-behaviour(gen_server).

-include("game.hrl").
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
-export([new_order/1]).
-export([del_order/1]).
-export([is_order/1]).
-export([is_my_order/2]).

-define(SERVER, ?MODULE).

-define(ETS_PAY_ORDER, ets_pay_order).
-record(pay_order, {id, role, time}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

new_order(RoleID) ->
	gen_server:call(?SERVER, {new, RoleID}).

del_order(OrderID) ->
	gen_server:call(?SERVER, {del, OrderID}).

is_order(OrderID) ->
	ets:member(?ETS_PAY_ORDER, OrderID).

is_my_order(OrderID, RoleID) ->
	case ets:lookup(?ETS_PAY_ORDER, OrderID) of
		[#pay_order{role=OrderRole}] ->
			OrderRole == RoleID;
		[] ->
			false
	end.

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	ets:new(?ETS_PAY_ORDER, [named_table, {keypos, #pay_order.id}]),
	{ok, undefined}.

handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

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
%% 生成订单号
do_handle_call({new, RoleID}, _From, State) ->
	MicroSecs = ut_time:microseconds(),
	OrderID   = ut_str:md5(lists:concat([RoleID, MicroSecs])),
	ets:insert_new(?ETS_PAY_ORDER, #pay_order{
		id   = OrderID,
		role = RoleID,
		time = MicroSecs div 1000000
	}),
	{reply, {ok, OrderID}, State};

%% 删除订单号
do_handle_call({del, OrderID}, _From, State) ->
	ets:delete(?ETS_PAY_ORDER, OrderID),
	{reply, ok, State};

do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.