%% @author rong
%% @doc 记录最近联系人
-module(chat_contact).

-behaviour(gen_server).

-include("table.hrl").
-include("game.hrl").
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
-export([log/2, get_recent/1]).

-define(SERVER, ?MODULE).
-define(ETS_CONTACT, ets_chat_contact).
-define(change_list, change_list).
-define(MAX, 20).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

log(Sender, Receiver) ->
    erlang:is_integer(Sender) andalso erlang:is_integer(Receiver)
        andalso gen_server:cast(?SERVER, {log, Sender, Receiver}).

get_recent(RoleID) ->
    #chat_contact{contacts = Contacts} = get_contacts(RoleID),
    Contacts.

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
    % TODO 删号时记得清除contacts上的废弃玩家记录
    ets:new(?ETS_CONTACT, [named_table, {keypos, #chat_contact.id}]),
    ChatContact = db:dirty_match_all(?DB_CHAT_CONTACT),
    ets:insert(?ETS_CONTACT, ChatContact),
    loop(),
    {ok, 0}.

handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
    ?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
    persist_data(),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.

do_handle_cast({log, Sender, Receiver}, State) ->
    Seconds = ut_time:seconds(),
    update_chat_time(Sender, Receiver, Seconds),
    update_chat_time(Receiver, Sender, Seconds),
    {noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.


do_handle_info(loop, State) ->
    loop(),
    persist_data(),
    {noreply, State};

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.

get_contacts(RoleID) ->
    case ets:lookup(?ETS_CONTACT, RoleID) of
        [ChatContact] ->
            ChatContact;
        _ ->
            #chat_contact{id = RoleID}
    end.

update_chat_time(RoleID, ToRoleID, Time) ->
    #chat_contact{contacts = Contacts} = ChatContact = get_contacts(RoleID),
    % 保留最近MAX个联系人
    Contacts2 = lists:sublist([{ToRoleID, Time}|lists:keydelete(ToRoleID, 1, Contacts)], ?MAX),
    ets:insert(?ETS_CONTACT, ChatContact#chat_contact{contacts = Contacts2}),
    case role:is_online(RoleID) of
        true ->
            [Friend] = friend_server:get_friends(RoleID, [{ToRoleID, Time}]),
            ?ucast(RoleID, #m_friend_contact_update_toc{add = Friend});
        false ->
            ignore
    end,
    add_change(RoleID).

loop() ->
    erlang:send_after(30*60*1000, self(), loop).

persist_data() ->
    [case ets:lookup(?ETS_CONTACT, RoleID) of
        [Info] ->
            db:dirty_write(?DB_CHAT_CONTACT, Info);
        _ ->
            ignore
    end || RoleID <- change_list()],
    clear_change(),
    ok.

% 获取数据更新过的玩家列表
change_list() ->
    case erlang:get(?change_list) of
        undefined -> [];
        List -> List
    end.
% 标记更新过的玩家
add_change(RoleID) ->
    List = change_list(),
    erlang:put(?change_list, [RoleID|lists:delete(RoleID, List)]).

clear_change() ->
    erlang:erase(?change_list).
