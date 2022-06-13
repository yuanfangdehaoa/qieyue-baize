%% @author rong
%% @doc 禁言管理
-module(chat_silent).

-behaviour(gen_server).

-include("table.hrl").
-include("chat.hrl").
-include("game.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([is_silent/1, ban/1, unban/1]).

-define(SERVER, ?MODULE).
-define(ETS_SILENT, ets_chat_silent).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

is_silent(RoleID) ->
    ets:lookup(?ETS_SILENT, RoleID) =/= [].

ban(RoleID) ->
    gen_server:cast(?SERVER, {ban, RoleID}).

unban(RoleID) ->
    gen_server:cast(?SERVER, {unban, RoleID}).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
    process_flag(trap_exit, true),
    ets:new(?ETS_SILENT, [named_table]),
    ChatSilent = game_misc:read(chat_silent, #chat_silent{}),
    [ets:insert(?ETS_SILENT, {RoleID, true}) || RoleID <- ChatSilent#chat_silent.role_ids],
    {ok, ?nil}.

handle_call(_Msg, _From, State) ->
    {reply, ok, State}.

handle_cast({ban, RoleID}, State) ->
    ets:insert(?ETS_SILENT, {RoleID, true}),
    {noreply, State};

handle_cast({unban, RoleID}, State) ->
    ets:delete(?ETS_SILENT, RoleID),
    {noreply, State};

handle_cast(_Info, State)->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    RoleIDs = ets:foldl(fun({RoleID, _}, Acc) ->
        [RoleID | Acc]
    end, [], ?ETS_SILENT),
    game_misc:write(chat_silent, #chat_silent{role_ids = RoleIDs}),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
