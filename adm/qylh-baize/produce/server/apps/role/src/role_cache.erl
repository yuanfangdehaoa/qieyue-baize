%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_cache).

-behaviour(gen_server).

-include("game.hrl").
-include("role.hrl").
-include("table.hrl").
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
-export([insert/1]).
-export([dirty_insert/1]).
-export([update/2]).
-export([get_cache/1]).
-export([load_faker/1]).

-define(ETS_CACHE, ets_cache).

-define(SERVER, ?MODULE).

-define(k_cache, {k_cache, RoleID}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?MODULE}, ?MODULE, {}, []).

insert(Cache) ->
	gen_server:cast(?SERVER, {insert, Cache}).

dirty_insert(Cache) ->
	ets:insert(?ETS_CACHE, Cache).

update(RoleID, KVList) ->
	gen_server:cast(?SERVER, {update, RoleID, KVList}).

%% 获取角色缓存数据
get_cache(RoleID) ->
	case ets:lookup(?ETS_CACHE, RoleID) of
		[R] -> {ok, R};
		[]  -> gen_server:call(?SERVER, {load, RoleID})
	end.

load_faker(Cache) ->
	gen_server:cast(?SERVER, {load_faker, Cache}).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	ets:new(?ETS_CACHE, [
		named_table,
		public,
		{keypos, #role_cache.id},
		{read_concurrency, true},
		{write_concurrency, true}
	]),
	{ok, undefined}.


handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).


handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).


handle_info(_Info, State) ->
	{noreply, State}.


terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call({load, RoleID}, _From, State) ->
	case ets:lookup(?ETS_CACHE, RoleID) of
		[]  ->
			{ok, Cache} = load_cache(RoleID),
			ets:insert(?ETS_CACHE, Cache),
			{reply, {ok, Cache}, State};
		[R] ->
			{reply, {ok, R}, State}
	end;

do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.

do_handle_cast({load_faker, Cache}, State) ->
	ets:insert(?ETS_CACHE, Cache),
	{noreply, State};

do_handle_cast({insert, Cache}, State) ->
	ets:insert(?ETS_CACHE, Cache),
	{noreply, State};

do_handle_cast({update, RoleID, KVList}, State) ->
	case ets:member(?ETS_CACHE, RoleID) of
		true ->
			ets:update_element(?ETS_CACHE, RoleID, KVList);
		false ->
			{ok, Cache} = load_cache(RoleID),
			ets:insert(?ETS_CACHE, Cache),
			ets:update_element(?ETS_CACHE, RoleID, KVList)
	end,
	{noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.

load_cache(RoleID) ->
	case cluster:is_local() of
		true  ->
			case db:dirty_read(?DB_ROLE_INFO, RoleID) of
				[RoleInfo] ->
					[RoleAttr]  = db:dirty_read(?DB_ROLE_ATTR, RoleID),
					[RoleVip]   = db:dirty_read(?DB_ROLE_VIP, RoleID),
					[RoleGuild] = db:dirty_read(?DB_ROLE_GUILD, RoleID),
					Cache = role_util:make_cache([
						RoleInfo, RoleAttr, RoleVip, RoleGuild
					]),
					{ok, Cache#role_cache{online=false}};
				[] ->
					?err(?ERR_ROLE_NOT_EXIST)
			end;
		false ->
			cluster:rpc_call_local(RoleID, role, get_cache, [RoleID])
	end.
