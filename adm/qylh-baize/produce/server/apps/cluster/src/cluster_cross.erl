%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(cluster_cross).

-behaviour(gen_server).

-include("cluster.hrl").
-include("game.hrl").
-include("errno.hrl").
-include("table.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([get_group/1]).

-define(SERVER, ?MODULE).

-record(state, {
	  conn = false
	, init = false
}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

get_group(Rule) ->
	case ets:lookup(?ETS_CLUSTER_GROUP, Rule) of
		[#cls_group{group=GroupID}] ->
			GroupID;
		[] ->
			0
	end.

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	ok = net_kernel:monitor_nodes(true, [{node_type,all}]),
	ets:new(?ETS_CLUSTER_GROUP, [
		named_table,
		{keypos, #cls_group.rule},
		{read_concurrency, true}
	]),
	ets:new(?ETS_CLUSTER_INDEX, [
		named_table,
		{keypos, #cls_index.suid},
		{read_concurrency, true}
	]),
	{ok, #state{}}.

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


do_handle_cast({divide, Rule, GroupID, CrossNode, LocalNodes}, State) ->
	?debug("cross divide"),
	cluster_util:divide(Rule, GroupID, CrossNode, LocalNodes),
	gen_server:cast(combat1v1_settle, started),
	case State#state.init of
		true  ->
			ignore;
		false ->
			spawn(fun() -> rank:start_cross() end),
			game_start:post(?SERVER_TYPE_CROSS)
	end,
	cluster_hook:post_divide(),
	{noreply, State#state{init=true}};

do_handle_cast(started, State) ->
	loop_connect(),
	loop_sync(),
	{noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.


do_handle_info(sync, State) ->
	loop_sync(),
	case State#state.conn of
		true  ->
			SUIDs = cluster_util:get_local_suids(),
			Nodes = cluster_util:pull_data(SUIDs),
			lists:foreach(fun
				(Node) ->
					cluster_util:add_index(Node)
			end, Nodes),
			{noreply, State};
		false ->
			{noreply, State}
	end;

do_handle_info(connect, State) when State#state.conn ->
	{noreply, State};
do_handle_info(connect, State) ->
	try
		case game_env:get_center() of
			?nil ->
				?info("center is not defined"),
				{noreply, State};
			Name ->
				ok = cluster_util:connect_center(Name),
				?info("connect center succ"),
				{noreply, State#state{conn=true}}
		end
	catch Class:Reason:Stacktrace ->
		?error("connect center fail: ~p", [Reason]),
		?stacktrace(Class, Reason, Stacktrace),
		loop_connect(),
		{noreply, State}
	end;

do_handle_info({nodeup, NodeName, _}, State) ->
	?debug("~w up", [NodeName]),
	{noreply, State};

do_handle_info({nodedown, Name, _}, State) ->
	?error("~w down", [Name]),
	case Name == game_env:get_center() of
		true  ->
			loop_connect(),
			{noreply, State#state{conn=false}};
		false ->
			Pattern = #cls_index{name=Name, _='_'},
			ets:match_delete(?ETS_CLUSTER_INDEX, Pattern),
			{noreply, State}
	end;

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.

loop_connect() ->
	erlang:send_after(timer:seconds(5), self(), connect).

loop_sync() ->
	erlang:send_after(timer:minutes(10), self(), sync).
