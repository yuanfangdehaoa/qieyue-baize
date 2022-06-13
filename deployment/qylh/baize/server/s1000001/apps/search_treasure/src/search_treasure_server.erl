%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(search_treasure_server).

-include("search_treasure.hrl").
-include("game.hrl").

-behaviour(gen_server).

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).

-export([get_messages/1, add_message/2]).

-define(SERVER, ?MODULE).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).


get_messages(TypeId)->
	gen_server:call(?SERVER, {get_messages, TypeId}).


add_message(TypeId, MessageItem)->
	gen_server:call(?SERVER, {add_message, TypeId, MessageItem}).


%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	{ok, 0}.

handle_call({get_messages, TypeId}, _From, State) ->
	Messages = get_type_messages(TypeId),
	Messages2 = lists:reverse(Messages),
	{reply, Messages2, State};

handle_call({add_message, TypeId, MessageItem}, _From, State) ->
	add_type_messages(TypeId, MessageItem),
	{reply, ok, State}.

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
%获取全服记录
get_type_messages(TypeId)->
	case get_data(TypeId) of
		undefined ->
			[];
		Messages ->
			Messages
	end.


%添加全服记录
add_type_messages(TypeId, MessageItem)->
	Messages = get_type_messages(TypeId),
	Messages2 = [MessageItem | Messages],
	set_data(TypeId, Messages2).


set_data(TypeId, Messages)->
	erlang:put(?searchtreasure_message, Messages).

get_data(TypeId)->
	erlang:get(?searchtreasure_message).

