%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(chat_server).

-include("game.hrl").
-include("chat.hrl").
-include("proto.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("faker.hrl").

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

-export([send_message/4, send_message/3, get_off_msgs/2, send_off_msgs/1]).
-export([get_chat_item/1]).
-export([notice/2]).
-export([send_cross_message/5]).
-export([add_cache/2]).
-export([gm_faker_chat/0]).
-export([hook_chime/1]).

-define(SERVER, ?MODULE).

-define(MAX_ID, 100000000).
-define(CHAT_TIME1, 2700).
-define(CHAT_TIME2, 25).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%整点
hook_chime(9)->
	gen_server:cast(?SERVER, {start_faker});
hook_chime(_)->
	ignore.

start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).


send_message(ChannelId, RoleIds, Message, Items) ->
	gen_server:cast(?SERVER, {ChannelId, RoleIds, Message, Items}).

send_message(ChannelId, Message, Items) ->
	gen_server:cast(?SERVER, {ChannelId, Message, Items}).

send_off_msgs(RoleSt)->
	gen_server:cast(?SERVER, {send_off_msgs, RoleSt}).

send_cross_message(ChannelId, SceneID, RoleIds, Message, Items)->
	Msg = {ChannelId, RoleIds, Message, Items},
	cluster:gen_cast_cross(cfg_scene:cluster(SceneID), ?SERVER, Msg).

%添加物品cache
add_cache(Items, IsCross)->
	case IsCross of
		false -> gen_server:call(?SERVER, {add_cache, Items});
		true  -> cluster:gen_call_cross(?CROSS_RULE_24_8, ?SERVER, {add_cache, Items})
	end.

%发送系统公告
%ShowType:1-跑马灯
notice(Content, ShowType)->
	gen_server:cast(?SERVER, {notice, Content, ShowType}).

get_off_msgs(RoleId, SendRoleId) ->
	gen_server:call(?SERVER, {get_off_msgs, RoleId, SendRoleId}).

get_chat_item(Id)->
	case Id > ?MAX_ID of
		true  -> cluster:gen_call_cross(?CROSS_RULE_24_8, ?SERVER, {get_chat_item,Id});
		false -> gen_server:call(?SERVER, {get_chat_item, Id})
	end.

gm_faker_chat()->
	gen_server:cast(?SERVER, gm_faker_chat).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	ID = case cluster:is_local() of
		true  ->
			{Hour, Min, Sec} = ut_time:time(),
			case Hour > 9 orelse (Hour==9 andalso (Min > 0 orelse Sec > 0)) of
				true  ->
					TimerRef = erlang:send_after(timer:seconds(?CHAT_TIME1), self(), faker_chat),
					set_timer(TimerRef);
				false ->
					ignore
			end,
			erlang:send_after(timer:seconds(?CHAT_TIME2), self(), faker_chat2),
			0;
		false ->
			?MAX_ID
	end,
	{ok, #state{id=ID}}.

handle_call(Request, From, State) ->
	?try_handle_call(do_handle_call(Request, From, State), State).

handle_cast(Msg, State) ->
	?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
	?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call({get_off_msgs, RoleId, SendRoleId}, _From, State) ->
	MsgList = get_msgs(RoleId, SendRoleId),
	{reply, MsgList, State};

do_handle_call({add_cache, Items}, _From, #state{id=Id}=State)->
	{Id2, CItems} = set_items(Items, Id),
	NewState = State#state{id=Id2},
	{reply, CItems, NewState};

do_handle_call({get_chat_item, Id}, _From, State)->
	Item = get_item(Id),
	{reply, Item, State}.

do_handle_cast(gm_faker_chat, State)->
	gm_faker_send(),
	{noreply, State};

do_handle_cast({?CHAT_CHANNEL_SCENE, RoleIds, Message, Items}, State)->
	do_send(RoleIds, Message, Items, State);

do_handle_cast({?CHAT_CHANNEL_GUILD, RoleIds, Message, Items}, State)->
	do_send(RoleIds, Message, Items, State);

do_handle_cast({?CHAT_CHANNEL_TEAM2, RoleIds, Message, Items}, State)->
	do_send(RoleIds, Message, Items, State);

do_handle_cast({?CHAT_CHANNEL_QUESTION, SceneId, Message, _Items}, State)->
	scene:bcast(SceneId, Message),
	{noreply, State};

do_handle_cast({?CHAT_CHANNEL_WORLD, Message, Items}, State)->
	do_send(Message, Items, State);

do_handle_cast({?CHAT_CHANNEL_TEAM, Message, _Items}, State)->
	?bcast(Message),
	{noreply, State};

do_handle_cast({?CHAT_CHANNEL_P2P, ToRoleId, Message, Items}, State)->
	%{Id2, CItmes} = set_items(Items, Id),
	#m_chat_channel_toc{sender=Sender} = Message,
	#p_role_base{id=SendRoleId} = Sender,
	Message2 = Message#m_chat_channel_toc{ids=Items},
	Message3 = Message2#m_chat_channel_toc{to_role_id=ToRoleId},
	case friend_server:is_in_blacklist(ToRoleId, SendRoleId) of
		true ->
			?ucast(SendRoleId, Message3);
		false ->
			case role:is_online(ToRoleId) of
				true->
					?bcast([SendRoleId,ToRoleId], Message3);
				false->
					save_msg(ToRoleId, Message3),
					?ucast(SendRoleId, Message3)
			end
	end,
	{noreply, State};

do_handle_cast({notice, Content, ShowType}, State)->
	?bcast(#m_chat_channel_toc{
		  		  channel_id = ?CHAT_CHANNEL_SYS
				, type_id = 0
				, content = Content
				, show_type = ShowType
			}),
	{noreply, State};

do_handle_cast({send_off_msgs, RoleSt}, State)->
	#role_st{role=RoleId}=RoleSt,
	MsgMap = get_data(RoleId),
	maps:fold(fun
			(_k, MsgList, AccIn) ->
				[?ucast(Message) || Message<-MsgList],
				AccIn
		end, 0, MsgMap),
	set_data(RoleId, #{}),
	{noreply, State};

%启动机器人
do_handle_cast({start_faker}, State)->
	case cluster:is_local() of
		true ->
			erlang:erase({?MODULE, chat_list}),
			case get_timer() of
				?nil     -> ignore;
				TimerRef -> erlang:cancel_timer(TimerRef)
			end,
			faker_chat();
		false ->
			ignore
	end,
	{noreply, State}.


do_handle_info(faker_chat, State)->
	faker_chat(),
	{noreply, State};

do_handle_info(faker_chat2, State)->
	faker_chat2(),
	{noreply, State}.

do_send(RoleIds, Message, Items, State)->
	%{Id2, CItmes} = set_items(Items, Id),
	Message2 = Message#m_chat_channel_toc{ids=Items},
	?bcast(RoleIds, Message2),
	{noreply, State}.

do_send(Message, Items, State)->
	%{Id2, CItmes} = set_items(Items, Id),
	Message2 = Message#m_chat_channel_toc{ids=Items},
	?bcast(Message2),
	{noreply, State}.

%获取离线信息
get_msgs(RoleId, SendRoleId)->
	MsgMap = get_data(RoleId),
	maps:get(SendRoleId, MsgMap, []).

save_msg(RoleId, Message)->
	#m_chat_channel_toc{sender=Sender} = Message,
	#p_role_base{id=SendRoleId}=Sender,
	MsgMap = get_data(RoleId),
	MsgList = get_msgs(RoleId, SendRoleId),
	MsgList2 = [Message | MsgList],
	MsgMap2 = maps:put(SendRoleId, MsgList2, MsgMap),
	set_data(RoleId, MsgMap2).

get_data(RoleId)->
	case erlang:get(?chat_off_msg) of
		undefined->
			#{};
		MsgMap->
			MsgMap
	end.

set_data(RoleId, MsgMap)->
	erlang:put(?chat_off_msg, MsgMap).

get_item_list()->
	case erlang:get(?chat_items) of
		?nil -> [];
		ItemList -> ItemList
	end.

%保存物品
set_items(Items, Id)->
	lists:foldl(fun
			(Item, {Id2, Maps}) ->
				Id3 = Id2 + 1,
				set_item(Item, Id3),
				#p_item{uid=UId} = Item,
				Maps2 = maps:put(UId, Id3, Maps),
				{Id3, Maps2}
		end, {Id, #{}}, Items).

set_item(Item, Id)->
	ItemList = get_item_list(),
	ItemList2 = case length(ItemList) >= 1000 of
		true ->
			[_Item|Tail] = ItemList,
			Tail;
		false ->
			ItemList
	end,
	ItemList3 = ItemList2 ++ [{Id, Item}],
	erlang:put(?chat_items, ItemList3).

get_item(Id)->
	ItemList = get_item_list(),
	Result = lists:keyfind(Id, 1, ItemList),
	case Result == false of
		true ->
			?nil;
		false ->
			{_, Item} = Result,
			Item
	end.

%10分钟随机拿一组聊天
faker_chat()->
	WorldLevel = world_level:get_level(),
	GoOn = case WorldLevel >= 135 of
		true ->
			List = get_list(),
			Length = length(List),
			case Length > 0 of
				true ->
					Index = ut_rand:random(1, Length),
					Elem = lists:nth(Index, List),
					List2 = lists:delete(Elem, List),
					set_list2(Elem),
					set_list(List2),
					true;
				false ->
					false
			end;
		false ->
			true
    end,
    TimerRef = case GoOn of
    	true  -> erlang:send_after(timer:seconds(?CHAT_TIME1), self(), faker_chat);
		false -> ?nil
	end,
    set_timer(TimerRef).

%从组里10秒拿一个对话
faker_chat2()->
	WorldLevel = world_level:get_level(),
	case WorldLevel >= 135 of
		true ->
			ContentList = get_list2(),
			Length = length(ContentList),
			case Length > 0 of
				true ->
					ContentId = lists:nth(1, ContentList),
					ContentList2 = lists:delete(ContentId, ContentList),
					set_list2(ContentList2),
					%发送消息
					send_faker_message(ContentId);
				false ->
					ignore
			end;
		false ->
			ignore
	end,
	erlang:send_after(timer:seconds(?CHAT_TIME2), self(), faker_chat2).

gm_faker_send()->
	?debug("gm_faker_send"),
	ContentList = get_list2(),
	Length = length(ContentList),
	case Length > 0 of
		true ->
			ContentId = lists:nth(1, ContentList),
			%发送消息
			send_faker_message(ContentId);
		false ->
			send_faker_message(1)
	end.



send_faker_message(ContentId)->
	ContentCfg = cfg_faker_world_content:find(ContentId),
	case ContentCfg of
		#cfg_faker_world_content{level=Level, vip=Vip, content=Content} ->
			#faker{base=RoleBase} = faker:random(),
			WorldLevel = world_level:get_level(),
			Level2 = ut_math:floor(WorldLevel*Level),
			MinVip = lists:nth(1, Vip),
			MaxVip = lists:nth(2, Vip),
			Vip2 = ut_rand:random(MinVip, MaxVip),
			RoleBase2 = RoleBase#p_role_base{level=Level2, viplv=Vip2},
			Message = #m_chat_channel_toc{
				channel_id = ?CHAT_CHANNEL_WORLD,
				type_id    = 0,
				content    = Content,
				sender     = RoleBase2
			},
			?bcast(Message);
		_ ->
			ignore
	end.


get_list()->
	List = erlang:get({?MODULE, chat_list}),
	case List of
		?nil ->
			OpenDays = game_env:get_opened_days(),
			cfg_faker_world_chat:find(OpenDays);
		_ ->
			List
	end.

set_list(ContentList)->
	erlang:put({?MODULE, chat_list}, ContentList).


get_list2()->
	List = erlang:get({?MODULE, chat_list2}),
	case List == ?nil orelse length(List) == 0 of
		true  -> [];
		false -> List
	end.

set_list2(List)->
	erlang:put({?MODULE, chat_list2}, List).


set_timer(TimeRef)->
	erlang:put({?MODULE, timer}, TimeRef).

get_timer()->
	erlang:get({?MODULE, timer}).

