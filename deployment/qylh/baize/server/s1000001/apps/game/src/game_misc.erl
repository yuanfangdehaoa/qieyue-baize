%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(game_misc).

-behaviour(gen_server).

-include("game.hrl").
-include("enum.hrl").
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
-export([read/1, read/2]).
-export([write/2, write/3]).
-export([delete/1]).
-export([dirty_read/1, dirty_read/2]).
-export([dirty_write/2]).
-export([post_divide/0]).

-define(SERVER, ?MODULE).

-define(ETS_GAME_MISC, ets_game_misc).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

read(Key) ->
	read(Key, ?nil).

read(Key0, Default) ->
	Key = transform_key(Key0),
	case ets:lookup(?ETS_GAME_MISC, Key) of
		[]  -> Default;
		[R] -> R#game_misc.val
	end.

write(Key, Val) ->
	write(Key, Val, false).

write(Key0, Val, Dirty) ->
	Key = transform_key(Key0),
	ets:insert(?ETS_GAME_MISC, #game_misc{key=Key, val=Val}),
	case cluster:is_cross() of
		true  -> cluster:rpc_cast_center(?MODULE, write, [Key, Val, Dirty]);
		false -> ?_if(Dirty, dirty_write(Key, Val))
	end.

delete(Key0) ->
	Key = transform_key(Key0),
	ets:delete(?ETS_GAME_MISC, Key),
	case cluster:is_cross() of
		true  -> cluster:rpc_cast_center(?MODULE, delete, [Key]);
		false -> db:dirty_delete(?DB_GAME_MISC, Key)
	end.

dirty_read(Key) ->
	dirty_read(Key, ?nil).

dirty_read(Key0, Default) ->
	Key = transform_key(Key0),
	case db:dirty_read(?DB_GAME_MISC, Key) of
		[R] -> R#game_misc.val;
		[]  -> Default
	end.

dirty_write(Key0, Val) ->
	Key = transform_key(Key0),
	Rec = #game_misc{key=Key, val=Val},
	db:dirty_write(?DB_GAME_MISC, Rec).


post_divide() ->
	delete(boss_kill),
	delete(drop_rare),
	ok.

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	process_flag(trap_exit, true),
	ets:new(?ETS_GAME_MISC, [
		named_table,
		public,
		{keypos, #game_misc.key},
		{read_concurrency, true},
		{write_concurrency, true}
	]),
	ets:insert(?ETS_GAME_MISC, db:dirty_match_all(?DB_GAME_MISC)),
	loop_dump(),
	{ok, undefined}.

handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
    ?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
	% 跨服直接写自己的数据到中心服，由中央服来统一持久化
	case not cluster:is_cross() of
		true  -> do_dump();
		false -> ignore
	end,
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.


do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.


do_handle_info(dump, State) ->
	loop_dump(),
	do_dump(),
	{noreply, State};

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.

loop_dump() ->
	case not cluster:is_cross() of
		true  -> erlang:send_after(timer:minutes(5), self(), dump);
		false -> ignore
	end.

do_dump() ->
	lists:foreach(fun
		(R) ->
			db:dirty_write(?DB_GAME_MISC, R)
	end, ets:tab2list(?ETS_GAME_MISC)).

transform_key(Key) ->
	case cluster:is_cross() of
		true ->
			Rule  = if
				true ->
					?CROSS_RULE_24_8
			end,
			Group = cluster_cross:get_group(Rule),
			{Group, Key};
		false ->
			Key
	end.
