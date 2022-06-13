%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(guild_data).

-compile({no_auto_import,[get/1]}).

-include("game.hrl").
-include("guild.hrl").
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

%%-----------------------------------------------
%% @doc 初始化帮派数据
%%-----------------------------------------------
init(GuildID) ->
	lists:foreach(fun
		(Tab) ->
			do_init(Tab, GuildID)
	end, table:guild_tabs()).


%%-----------------------------------------------
%% @doc 持久化帮派数据
%%-----------------------------------------------
dump() ->
	lists:foreach(fun
		(Tab) ->
			do_dump(Tab)
	end, table:guild_tabs()).


%%-----------------------------------------------
%% @doc 从帮派进程字典读取帮派数据
-spec get(atom()) ->
	tuple(). % 见 table.hrl
%%-----------------------------------------------
get(Key) ->
	erlang:get(?k_data).


%%-----------------------------------------------
%% @doc 将帮派数据写入内存
-spec set(tuple()) ->
	no_return().
%%-----------------------------------------------
set(Rec) ->
	Key = element(1, Rec),
	erlang:put(?k_data, Rec).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_init(Tab, _) when Tab#r_tab.init == never ->
	ignore;
do_init(Tab, GuildID) ->
	#r_tab{name=Name, rec=Rec, init=Mod} = Tab,
	case db:dirty_read(Name, GuildID) of
		[] when Mod /= ?nil ->
			Mod:init(GuildID);
		[]  ->
			set(table:init(Rec, GuildID));
		[R] ->
			set(R)
	end.

do_dump(Tab) when Tab#r_tab.init == never ->
	ignore;
do_dump(Tab) ->
	#r_tab{name=Name} = Tab,
	db:dirty_write(Name, get(Name)).