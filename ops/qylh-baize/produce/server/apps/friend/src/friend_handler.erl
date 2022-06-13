%%%=============================================================================
%%% @author rong
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(friend_handler).

-include("proto.hrl").
-include("role.hrl").
-include("game.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("friend.hrl").
-include("log.hrl").

%% API
-export([handle/3, add_charm/2, request/2, add_intimacy/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
handle(?FRIEND_CONTACT, _Tos, RoleSt) ->
    #role_st{role = RoleID} = RoleSt,
    Contacts = chat_contact:get_recent(RoleID),
    Friends = friend_server:get_friends(RoleID, Contacts),
    ?ucast(#m_friend_contact_toc{friends=Friends});

%% 好友列表
handle(?FRIEND_LIST, _Tos, RoleSt) ->
    #role_st{role = RoleID} = RoleSt,
    Friends = friend_server:get_friends(RoleID),
    ?ucast(#m_friend_list_toc{friends=Friends});

%% 好友请求
handle(?FRIEND_REQUEST, Tos, RoleSt) ->
    #m_friend_request_tos{role_id = RequestID} = Tos,
    request(RequestID, RoleSt),
    ?ucast(#m_friend_request_toc{});

%% 获取好友请求列表
handle(?FRIEND_REQUEST_LIST, _Tos, RoleSt) ->
    #role_st{role = RoleID} = RoleSt,
    Requests = friend_server:get_request(RoleID),
    ?ucast(#m_friend_request_list_toc{lists=Requests});

%% 授受请求
handle(?FRIEND_ACCEPT, Tos, RoleSt) ->
    #m_friend_accept_tos{role_id = AcceptID} = Tos,
    #role_st{role=RoleID, user=User, ip=IP, sdk=SDKArgs} = RoleSt,
    case friend_server:accept(RoleID, AcceptID) of
        {ok, Accepts, Fails} ->
            Fails =/= [] andalso ?ucast(#m_game_error_toc{errno=?ERR_FRIEND_OTHER_FULL}),
            lists:foreach(fun
                (AcceptedID) ->
                    role_event:event(?EVENT_FRIEND),
                    role_event:event(AcceptedID, ?EVENT_FRIEND, ?nil),
                    log_junhai:log_friend(User, IP, SDKArgs, AcceptedID)
            end, Accepts),
            ?ucast(#m_friend_accept_toc{role_ids=Accepts, fail_ids=Fails});
        {error, ErrCode, Args} ->
            ?ucast(#m_game_error_toc{errno=ErrCode, args=Args})
    end;

%% 授受拒绝
handle(?FRIEND_REFUSE, Tos, RoleSt) ->
    #m_friend_refuse_tos{role_id = RefuseID} = Tos,
    #role_st{role = RoleID} = RoleSt,
    {ok, Refuses} = friend_server:refuse(RoleID, RefuseID),
    ?ucast(#m_friend_refuse_toc{role_ids=Refuses});

%% 删除好友
handle(?FRIEND_DELETE, Tos, RoleSt) ->
	#m_friend_delete_tos{role_ids = DelIDs0} = Tos,
    #role_st{role = RoleID} = RoleSt,
    MarryWith = role_marriage:marry_with(RoleID),
    ?_check([MarryWith] =/= DelIDs0, ?ERR_FRIEND_DEL_MARRY),
    DelIDs = lists:delete(MarryWith, DelIDs0),
    friend_server:del_friends(RoleID, DelIDs),
    ?ucast(#m_friend_delete_toc{role_ids=DelIDs});

%% 拉黑
handle(?FRIEND_ADDBLACK, Tos, RoleSt) ->
    #m_friend_addblack_tos{role_id = BlackID} = Tos,
    #role_st{role = RoleID} = RoleSt,
    friend_server:add_black(RoleID, BlackID),
    ?ucast(#m_friend_addblack_toc{role_id=BlackID});

%% 移出黑名单
handle(?FRIEND_DELBLACK, Tos, RoleSt) ->
    #m_friend_delblack_tos{role_id = BlackID} = Tos,
    #role_st{role = RoleID} = RoleSt,
    friend_server:del_black(RoleID, BlackID),
    ?ucast(#m_friend_delblack_toc{role_id=BlackID});

%% 删除仇人
handle(?FRIEND_DELENEMY, _Tos, _RoleSt) ->
	ok;

handle(?FRIEND_RECOMMEND, _Tos, RoleSt) ->
    #role_st{role = RoleID} = RoleSt,
    {ok, Roles} = friend_recommend:recommend(RoleID),
    ?ucast(#m_friend_recommend_toc{roles = Roles});

handle(?FRIEND_SEARCH, Tos, RoleSt) ->
    #m_friend_search_tos{name = Name} = Tos,
    case friend_server:search(Name) of
        {ok, Base} ->
            ?ucast(#m_friend_search_toc{base = Base});
        {error, ErrCode, Args} ->
            ?ucast(#m_game_error_toc{errno=ErrCode, args=Args})
    end;

handle(?FRIEND_FEEDBACK, Tos, RoleSt) ->
    #m_friend_feedback_tos{role_id=Target, type=Type} = Tos,
    case role:is_online(Target) of
        true ->
            Base = role:get_base(RoleSt#role_st.role),
            ?ucast(#m_friend_feedback_toc{to_self=true, type=Type}),
            ?ucast(Target, #m_friend_feedback_toc{to_self=false, base=Base, type=Type});
        false ->
            ignore
    end;

handle(?FRIEND_SEND_FLOWER, Tos, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    #m_friend_send_flower_tos{role_id=Receiver, item_id=ItemID} = Tos,
    case faker:is_fake(Receiver) of
        true ->
            ok;
        false ->
            ?_check(Receiver =/= RoleID, ?ERR_FRIEND_SEND_SELF_FLOWER),
            ?_check(role:is_online(Receiver), ?ERR_FRIEND_RECEIVER_NOT_ONLINE)
    end,
    Config = cfg_flower:find(ItemID),
    ?_check(Config =/= ?nil, ?ERR_GAME_BAD_ARGS),
    #cfg_flower{first_reward=FirstRewards, reward=Rewards} = cfg_flower:find(ItemID),
    First = case role_count:get_times(?ROLE_COUNT_SEND_FLOWER) == 0 of
        true ->
            FirstRewards;
        false ->
            []
    end,
    Gains = First++Rewards,
    Cost = [{ItemID, 1}],
    DealSucc = fun() ->
        role_count:add_times(?ROLE_COUNT_SEND_FLOWER),
        case faker:is_fake(Receiver) of
            true ->
                ignore;
            false ->
                friend_server:send_flower(RoleID, Receiver, ItemID),
                dating_manager:receive_flower(Receiver, ItemID)
        end,
        role_event:event(?EVENT_FLOWER, ItemID),
        ?ucast(#m_friend_send_flower_toc{})
    end,
    role_bag:deal(Cost, Gains, ?LOG_FRIEND_SEND_FLOWER, DealSucc, RoleSt);

handle(?FRIEND_CONTACT_UPDATE, Tos, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    #m_friend_contact_update_tos{role_id = Receiver} = Tos,
    chat_contact:log(RoleID, Receiver).

add_charm(CharmAdd, RoleSt) ->
    #role_info{charm=Charm} = RoleInfo = role_data:get(?DB_ROLE_INFO),
    role_data:set(RoleInfo#role_info{charm=Charm+CharmAdd}),
    ?ucast(#m_role_update_toc{upint=#{"charm"=>Charm+CharmAdd}}).

add_intimacy(Add, _RoleSt) ->
    role_event:event(?EVENT_ADD_INTIMACY, Add).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
request(RequestID, RoleSt) ->
    #role_st{role = RoleID} = RoleSt,
    case faker:is_fake(RequestID) of
        true ->
            ok;
        false ->
            ?_check(role_util:is_local(RequestID), ?ERR_FRIEND_SEARCH_NOT_FOUND),
            case RequestID == RoleID of
                true ->
                    throw(?err(?ERR_FRIEND_REQUEST_SELF));
                false ->
                    check_open(RequestID),
                    #role_vip{level=VipLv} = role_data:get(?DB_ROLE_VIP),
                    if
                        VipLv > 0 ->
                            ok;
                        true ->
                            Times = role_count:get_times(?ROLE_COUNT_FRIEND_REQUEST),
                            ?_check(Times < max_friend_request(RoleSt), ?ERR_FRIEND_REQUEST_MAX)
                    end,
                    case friend_server:request(RequestID, RoleID) of
                        ok ->
                            role_count:add_times(?ROLE_COUNT_FRIEND_REQUEST),
                            dating_manager:receive_friend_request(RequestID),
                            ok;
                        {error, ErrCode, Args} ->
                            throw(?err(ErrCode, Args))
                    end
            end
    end.

max_friend_request(_RoleSt) ->
    #role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
    cfg_friend_request:find(Level).

check_open(RoleID) ->
    {ok, #role_cache{level=RequestLv}} = role:get_cache(RoleID),
    SysID = cfg_sysopen:sysid(?MODULE),
    case lists:keyfind(SysID, 1, cfg_sysopen:syslist()) of
        {_, NeedLv, _} ->
            ?_check(RequestLv >= NeedLv, ?ERR_FRIEND_REQUEST_LV_NOT_ENOUGH);
        false ->
            throw(?err(?ERR_FRIEND_REQUEST_LV_NOT_ENOUGH))
    end.
