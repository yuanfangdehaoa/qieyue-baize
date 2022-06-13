%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_event).

-include("game.hrl").
-include("role.hrl").
-include("enum.hrl").

%% API
-export([init/0]).
-export([listen/3, listen/4]).
-export([remove/3, remove/4]).
-export([event/1, event/2, event/3]).
-export([notify/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init() ->
	set_listener(#{}).

%%-----------------------------------------------
%% @doc 监听事件
%% 事件发生时会调用 Mod:Fun(Event, Args, RoleSt)
%% 其中 Args 是自定义的任意类型的事件参数
-spec listen(Event, Mod, Fun, Opts) -> no_return() when
	Event :: atom(),     % 见 enum.xml
	Mod   :: module(),   % 回调模块
	Fun   :: function(), % 回调函数
	Opts  :: any().
%%-----------------------------------------------
listen(Event, Mod, Fun) ->
	listen(Event, Mod, Fun, ?nil).

listen(Event, Mod, Fun, Opts) ->
	Listener = get_listener(),
	Listened = maps:get(Event, Listener, []),
	Callback = {Mod, Fun, Opts},
	case lists:member(Callback, Listened) of
		true  ->
			ignore;
		false ->
			Listened2 = [Callback | Listened],
			Listener2 = maps:put(Event, Listened2, Listener),
			set_listener(Listener2)
	end.


%%-----------------------------------------------
%% @doc 移除监听
-spec remove(atom(), module(), function(), any()) ->
	no_return().
%%-----------------------------------------------
remove(Event, Mod, Fun) ->
	remove(Event, Mod, Fun, ?nil).

remove(Event, Mod, Fun, Opts) ->
	Listener = get_listener(),
	Callback = {Mod, Fun, Opts},
	case maps:find(Event, Listener) of
		{ok, Listened} ->
			Listened2 = lists:delete(Callback, Listened),
			Listener2 = maps:put(Event, Listened2, Listener),
			set_listener(Listener2);
		error ->
			ignore
	end.


%%-----------------------------------------------
%% @doc 事件触发
%% 详见 listen/3
-spec event(any(), any()) ->
	no_return().
%%-----------------------------------------------
event(Event) ->
	event(Event, ?nil).
event(Event, Args) ->
	role:cast(self(), {event, Event, Args}).
event(RoleID, Event, Args) ->
	role:cast(RoleID, {event, Event, Args}).


%%-----------------------------------------------
%% @doc 事件回调(不需要主动调用，触发事件请调用 event/1,2,3)
-spec notify(any(), any(), #role_st{}) ->
	#role_st{}.
%%-----------------------------------------------
notify(Event, Args, RoleSt) ->
	Listener = get_listener(),
	Listened = maps:get(Event, Listener, []),
	lists:foldl(fun
		({M,F,Opts}, AccSt) ->
			Result = case Opts == ?nil of
				true  -> M:F(Event, Args, AccSt);
				false -> M:F(Event, Opts, Args, AccSt)
			end,
			case Result of
				{ok, AccSt2} when is_record(AccSt2, role_st) ->
					AccSt2;
				_ ->
					AccSt
			end
	end, RoleSt, Listened).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
-define(k_listener, {?MODULE, listener}).
get_listener() ->
	get(?k_listener).

set_listener(Listener) ->
	put(?k_listener, Listener).
