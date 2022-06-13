%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(baby_server).

-include("game.hrl").
-include("baby.hrl").
-include("enum.hrl").
-include("rank.hrl").
-include("ranking.hrl").
-include("errno.hrl").
-include("table.hrl").

-behaviour(gen_server).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
%% API
-export([start_link/0]).
-export([hook_chime/1]).
-export([get_baby/1]).
-export([update_cache/3]).

-define(SERVER, ?MODULE).

-define(ETS_BABY_CACHE, ets_baby_cache).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

%0点发奖，清榜单
hook_chime(0) ->
	gen_server:cast(?SERVER, reward);
hook_chime(_) ->
	ignore.

get_baby(RoleID)->
	gen_server:call(?SERVER, {get_baby, RoleID}).

update_cache(RoleID, PBabyOrder, WingID)->
	gen_server:cast(?SERVER, {update, RoleID, PBabyOrder, WingID}).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	ets:new(?ETS_BABY_CACHE, [
		named_table,
		{keypos, #baby_cache.id},
		{read_concurrency, true}
	]),
	{ok, undefined}.

handle_call(Request, From, State) ->
	?try_handle_call(do_handle_call(Request, From, State), State).

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
do_handle_cast(reward, State)->
	RankList = rank:get_ranklist(?BABY_LIKE_RANK),
	lists:foreach(fun 
			(#rankitem{id=RoleID, rank=Rank}) -> 
				Gain = cfg_baby_like_reward:reward(Rank),
				?_if(length(Gain) > 0,
					mail:send(RoleID, ?MAIL_BABY_LIKE_RANK, Gain, [Rank]))
		end, RankList),
	rank:clear_rank(?BABY_LIKE_RANK),
	{noreply, State};

do_handle_cast({update, RoleID, PBabyOrder, WingID}, State)->
	NewCache = make_cache(RoleID, PBabyOrder, WingID),
	case ets:member(?ETS_BABY_CACHE, RoleID) of
		true ->
			ets:update_element(?ETS_BABY_CACHE, RoleID, {#baby_cache.wing_id, WingID}),
			ets:update_element(?ETS_BABY_CACHE, RoleID, {#baby_cache.baby_order, PBabyOrder});
		false ->
			Cache = load_cache(RoleID),
			case Cache of
				?nil  -> 
					ets:insert(?ETS_BABY_CACHE, NewCache);
				Cache ->
				 	ets:insert(?ETS_BABY_CACHE, Cache),
				 	ets:update_element(?ETS_BABY_CACHE, RoleID, {#baby_cache.wing_id, WingID}),
				 	ets:update_element(?ETS_BABY_CACHE, RoleID, {#baby_cache.baby_order, PBabyOrder})
			end
	end,
	{noreply, State}.

do_handle_call({get_baby, RoleID}, _From, State)->
	case ets:lookup(?ETS_BABY_CACHE, RoleID) of
		[]  ->
			Cache = load_cache(RoleID),
			case Cache of
				?nil  -> ?nil;
				Cache -> ets:insert(?ETS_BABY_CACHE, Cache)
			end,
			{reply, {ok, Cache}, State};
		[R] ->
			{reply, {ok, R}, State}
	end.

load_cache(RoleID) ->
	case db:dirty_read(?DB_ROLE_BABY, RoleID) of
		[RoleBaby] ->
			#role_baby{figure=Figure,order=Orders, wing_id=WingID} = RoleBaby,
			case maps:get(Figure, Orders, ?nil) of
				?nil -> ?nil;
				R    -> make_cache(RoleID, R, WingID)
			end;
		[] ->
			?nil
	end.

make_cache(RoleID, BabyOrder, WingID)->
	#baby_cache{
		  id         = RoleID
		, baby_order = BabyOrder
		, wing_id    = WingID
	}.
