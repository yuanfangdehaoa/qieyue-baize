%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_data).

-compile({no_auto_import,[get/1]}).

-include("game.hrl").
-include("role.hrl").
-include("table.hrl").

%% API
-export([init/1]).
-export([dump/0]).
-export([get/1]).
-export([set/1]).


-define(k_data, {'@data', Key}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 初始化玩家数据
init(RoleID) ->
	lists:foreach(fun
		(Tab) ->
			do_init(Tab, RoleID)
	end, table:role_tabs()).

%% 持久化玩家数据
dump() ->
	lists:foreach(fun
		(Tab) ->
			do_dump(Tab)
	end, table:role_tabs()).


%%-----------------------------------------------
%% @doc 从内存中读取玩家数据
-spec get(atom()) ->
	tuple(). % 见 table.hrl
%%-----------------------------------------------
get(Key) ->
	erlang:get(?k_data).


%%-----------------------------------------------
%% @doc 将玩家数据写入内存
-spec set(tuple()) ->
	no_return().
%%-----------------------------------------------
set(Rec) ->
	do_set(Rec),
	Key = element(1, Rec),
	persist(Key, Rec).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_init(Tab, _) when Tab#r_tab.init == never ->
	ignore;
do_init(Tab, RoleID) ->
	#r_tab{name=Name, rec=Rec, init=Mod} = Tab,
	case db:dirty_read(Name, RoleID) of
		[] when Mod /= ?nil ->
			Mod:init(RoleID);
		[]  ->
			do_set(table:init(Rec, RoleID));
		[R] ->
			do_set(R)
	end.

do_set(Rec) ->
	Key = element(1, Rec),
	erlang:put(?k_data, Rec),
	update_cache(Key, Rec).

do_dump(Tab) when Tab#r_tab.init == never ->
	ignore;
do_dump(Tab) ->
	#r_tab{name=Name} = Tab,
	db:dirty_write(Name, get(Name)).

update_cache(Key, Rec) ->
	KVList = lists:map(fun
		({RecKey, CacheKey}) ->
			{CacheKey, element(RecKey, Rec)}
	end, table:cache(Key)),
	role_cache:update(role_util:get_id(), KVList).

persist(Tab, Rec) ->
	case table:persist(Tab) of
		now ->
			db:dirty_write(Tab, Rec);
		_ ->
			ignore
	end.
