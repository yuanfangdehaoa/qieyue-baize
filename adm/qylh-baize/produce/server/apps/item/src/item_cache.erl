%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(item_cache).

-behaviour(gen_server).

-include("game.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([get_cache/1]).
-export([add_cache/1]).

-define(SERVER, ?MODULE).

-record(state, {id, q}).

-define(MAX_LEN, 2000).
-define(MAX_ID, 100000000).

-define(ETS_CROSS_ITEM, ets_cross_item).
-record(cross_item, {id, item}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

add_cache(Item) ->
	gen_server:call(?SERVER, {add_cache, Item}).

get_cache(ID) ->
	case ID > ?MAX_ID of
		true ->
			case ets:lookup(?ETS_CROSS_ITEM, ID) of
				[#cross_item{item=Item}] ->
					Item;
				[] ->
					Item = cluster:gen_call_center(?SERVER, {get_cache,ID}),
					gen_server:cast(?SERVER, {insert, ID, Item}),
					Item
			end;
		false ->
			gen_server:call(?SERVER, {get_cache, ID})
	end.

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	ets:new(?ETS_CROSS_ITEM, [
		named_table,
		{keypos, #cross_item.id},
		{read_concurrency, true}
	]),
	ID = case cluster:is_local() of
		true  -> 1;
		false -> ?MAX_ID+1
	end,
	{ok, #state{id=ID, q=queue:new()}}.

handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast({insert, ID, Item}, State) ->
	ets:insert(?ETS_CROSS_ITEM, #cross_item{id=ID, item=Item}),
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
do_handle_call({add_cache, Item}, _From, State=#state{id=ID}) ->
	set_item(ID, Item),
	Q1 = queue:in(ID, State#state.q),
	Q2 = case queue:len(Q1) > ?MAX_LEN of
		true  ->
			{{value,DelID}, Q3} = queue:out(Q1),
			del_item(DelID),
			Q3;
		false ->
			Q1
	end,
	{reply, ID, State#state{id=ID+1, q=Q2}};

do_handle_call({get_cache, ID}, _From, State) ->
	Item = get_item(ID),
	{reply, Item, State};

do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.


-define(k_item, {k_item, ID}).
get_item(ID) ->
	get(?k_item).

set_item(ID, Item) ->
	put(?k_item, Item).

del_item(ID) ->
	erase(?k_item).
