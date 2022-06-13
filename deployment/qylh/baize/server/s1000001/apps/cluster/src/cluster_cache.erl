%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(cluster_cache).

-behaviour(gen_server).

-include("bag.hrl").
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

-export([get_role/1]).

-define(SERVER, ?MODULE).

-define(ETS_CROSS_ROLE, ets_cross_role).
-record(cross_role, {id, cache, equips, time}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

get_role(RoleID) ->
	NowSecs = ut_time:seconds(),
	case ets:lookup(?ETS_CROSS_ROLE, RoleID) of
		[#cross_role{cache=Cache, equips=Equips, time=Time}] when NowSecs - Time =< 15*60 ->
			{ok, Cache, Equips};
		_ ->
			{ok, Cache, Equips} = do_get_role(RoleID),
			gen_server:cast(?SERVER, {insert, RoleID, Cache, Equips, NowSecs}),
			{ok, Cache, Equips}
	end.

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	ets:new(?ETS_CROSS_ROLE, [
		named_table,
		{keypos, #cross_role.id},
		{read_concurrency, true}
	]),
	{ok, undefined}.

handle_call(_Request, _From, State) ->
	{reply, {error, unknown_call}, State}.


handle_cast({insert, RoleID, Cache, Equips, Secs}, State) ->
	ets:insert(?ETS_CROSS_ROLE, #cross_role{
		id     = RoleID,
		cache  = Cache,
		equips = Equips,
		time   = Secs
	}),
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
do_get_role(RoleID) ->
	Keys = [
		{bag,?BAG_ID_EQUIP},
		?DB_ROLE_INFO,
		?DB_ROLE_ATTR,
		?DB_ROLE_VIP,
		?DB_ROLE_GUILD
	],
	{ok, [Equips | T]} = role:get_data(RoleID, Keys),
	Cache = role_util:make_cache(T),
	{ok, Cache, Equips}.
