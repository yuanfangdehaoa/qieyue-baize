%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(chat_handler).

-include("game.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("table.hrl").
-include("chat.hrl").
-include("scene.hrl").
-include("pb_comm.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("item.hrl").
-include("faker.hrl").


%% API
-export([handle/3]).
-export([faker_send_chat/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
handle(?CHAT_CHANNEL, Tos, RoleSt) ->
	#m_chat_channel_tos{
		  channel_id = ChannelId
		, type_id    = TypeId
		, content    = Content
		, to_role_id = ToRoleId
		, uids       = UIds
	} = Tos,
	check_reqs(cfg_game:world_chat_lv(),RoleSt),
	?_check(string:len(Content) =< 300, ?ERR_CHAT_CONTENT_TOO_LONG),
	Items = lists:foldl(fun
			(UId, Lists)->
				{ok, Item} = role_bag:get_item(UId),
				[get_full_item(Item) | Lists]
		end, [], UIds),
	#role_st{role=RoleId, scene=SceneID} = RoleSt,
	%check_cd(RoleId, ChannelId),
	?_check(not chat_silent:is_silent(RoleId), ?ERR_CHAT_BAN_SILENT),
	Message = #m_chat_channel_toc{
		channel_id = ChannelId,
		type_id    = TypeId,
		content    = Content,
		sender     = role:get_base(RoleId)
	},
	log_api:chat(ChannelId, Content, RoleSt),
	case TypeId == 0 of
		true  ->
			#role_st{user=User, ip=IP, sdk=SDKArgs} = RoleSt,
			log_junhai:log_chat(User, IP, SDKArgs, {ChannelId,Content});
		false ->
			ignore
	end,
	CItems = chat_server:add_cache(Items, is_cross(SceneID)),
	%% 检查是否满足充值限制条件
	check_chat_limit(ChannelId),
	do_handle(ChannelId, Message, CItems, RoleSt, ToRoleId);

%获取离线消息
handle(?CHAT_OFF_MSG, _Tos, RoleSt)->
	chat_server:send_off_msgs(RoleSt);

%获取信息
handle(?CHAT_ITEM, Tos, RoleSt)->
	#m_chat_item_tos{id=Id} = Tos,
	Item = chat_server:get_chat_item(Id),
	case Item == ?nil of
		true -> throw(?err(?ERR_CHAT_ITEM_NOT_EXIST));
		false -> ignore
	end,
	{ok, #m_chat_item_toc{item=item_util:p_item(Item)}, RoleSt}.

% 检查聊天充值限制条件
check_chat_limit(ChannelId) ->
	case erlang:function_exported(cfg_game, chat_limit, 0) of
		true ->
			case cfg_game:chat_limit() of
				{Amount, ChannelIdList} ->
					case lists:member(ChannelId, ChannelIdList) of
						true ->
							AllFee = role_pay:calc(),
							case AllFee >= Amount of
								true ->
									ok;
								false ->
									throw(?err(?ERR_CHAT_RECHARGE_OR_LV))
							end;
						false ->
							ok
					end;
				false ->
					ok
			end;
		false ->
			ok
	end.

faker_send_chat(FakerID, ToRoleId, Content) ->
	case role:is_online(ToRoleId) of
		true ->
			Message = #m_chat_channel_toc{
				channel_id = ?CHAT_CHANNEL_P2P,
				type_id    = 0,
				content    = Content,
				sender     = role:get_base(FakerID)
			},
			do_send(?CHAT_CHANNEL_P2P, ToRoleId, Message, []),
			chat_contact:log(FakerID, ToRoleId);
		false ->
			ignore
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------

%区域
do_handle(?CHAT_CHANNEL_SCENE, Message, Items, RoleSt, _ToRoleId) ->
	#role_st{scene=SceneID, spid=ScenePid} = RoleSt,
	RoleIds  = scene:get_roles(ScenePid),
	Message2 = Message#m_chat_channel_toc{scene=RoleSt#role_st.scene},
	case is_cross(SceneID) of
		false -> do_send(?CHAT_CHANNEL_SCENE, RoleIds, Message2, Items);
		true  -> send_cross(?CHAT_CHANNEL_SCENE, SceneID, RoleIds, Message2, Items)
	end,
	{ok, RoleSt};

%世界
do_handle(?CHAT_CHANNEL_WORLD, Message, Items, _RoleSt, _ToRoleId) ->
	do_send(?CHAT_CHANNEL_WORLD, Message, Items);

%仙盟
do_handle(?CHAT_CHANNEL_GUILD, Message, Items, RoleSt, _ToRoleId) ->
	GuildPid = RoleSt#role_st.guild,
	?_check(GuildPid /= 0, ?ERR_GUILD_NOT_JOIN),
	RoleIds  = game_role:get_guild_roles(GuildPid),
	do_send(?CHAT_CHANNEL_GUILD, RoleIds, Message, Items);

%组队
do_handle(?CHAT_CHANNEL_TEAM, Message, Items, _RoleSt, _ToRoleId) ->
	do_send(?CHAT_CHANNEL_TEAM, Message, Items);

%队伍
do_handle(?CHAT_CHANNEL_TEAM2, Message, Items, RoleSt, _ToRoleId) ->
	TeamId = RoleSt#role_st.team,
	?_check(TeamId /= 0, ?ERR_TEAM_NOT_IN_TEAM),
	RoleIds = game_role:get_team_roles(TeamId),
	do_send(?CHAT_CHANNEL_TEAM2, RoleIds, Message, Items);

%答题
do_handle(?CHAT_CHANNEL_QUESTION, Message, Items, RoleSt, _ToRoleId)->
	#role_st{scene=SceneId} = RoleSt,
	Message2 = Message#m_chat_channel_toc{scene=SceneId},
	do_send(?CHAT_CHANNEL_QUESTION, SceneId, Message2, Items);

%跨服
do_handle(?CHAT_CHANNEL_CROSS, _Message, _Items, RoleSt, _ToRoleId) ->
	{ok, RoleSt};

%私聊
do_handle(?CHAT_CHANNEL_P2P, Message, Items, _RoleSt, ToRoleId) ->
	case faker:is_fake(ToRoleId) of
		true ->
			ignore;
		false ->
			#m_chat_channel_toc{sender=Sender} = Message,
			#p_role_base{id=SendRoleId} = Sender,
			case role:is_online(ToRoleId) of
				false ->
					MsgList = chat_server:get_off_msgs(ToRoleId, SendRoleId),
					?_check(length(MsgList) < ?CHAT_OFF_MSG_NUM, ?ERR_CHAT_OFF_MSG_ENOUGH);
				true  ->
					ignore
			end,
			do_send(?CHAT_CHANNEL_P2P, ToRoleId, Message, Items),
			chat_contact:log(SendRoleId, ToRoleId)
	end.

do_send(ChannelId, RoleIds, Message, Items) ->
	chat_server:send_message(ChannelId, RoleIds, Message, Items).

do_send(ChannelId, Message, Items) ->
	chat_server:send_message(ChannelId, Message, Items).


get_full_item(Item)->
	#p_item{id=ItemId} = Item,
	#cfg_item{type=Type} = cfg_item:find(ItemId),
	case Type of
		?ITEM_TYPE_EQUIP ->
			role_equip:get_item(Item);
		_ ->
			Item
	end.

%检查cd
% check_cd(RoleId, Channel)->
% 	case Channel of
% 		?CHAT_CHANNEL_P2P ->
% 			ignore;
% 		_ ->
% 			LastTime = erlang:get({?MODULE, RoleId}),
% 			case LastTime == ?nil of
% 				true  ->
% 					ignore;
% 				false ->
% 					Now = ut_time:seconds(),
% 					?_check(Now - LastTime >= 5, ?ERR_CHAT_IN_CD)
% 			end,
% 			erlang:put({?MODULE, RoleId}, ut_time:seconds())
% 	end.


is_cross(SceneID)->
	#cfg_scene{kind=Kind} = cfg_scene:find(SceneID),
	Kind == ?SCENE_KIND_CROSS.

send_cross(Channel, SceneID, RoleIds, Message, Items)->
	chat_server:send_cross_message(Channel, SceneID, RoleIds, Message, Items).


check_reqs([{recharge,Money} | T],RoleSt) ->
	AllFee = role_pay:calc(),
	case AllFee >= Money of
		true -> check_reqs(T,RoleSt);
		false -> throw(?err(?ERR_CHAT_RECHARGE_OR_LV))
	end;

check_reqs([{level, LevelLim} | T], RoleSt) ->
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	case RoleLv >= LevelLim of
		true  -> check_reqs(T, RoleSt);
		false -> throw(?err(?ERR_CHAT_RECHARGE_OR_LV))
	end;

check_reqs([], _RoleSt) ->
	true.
