%%%=============================================================================
%%% @author rong
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(friend_server).

-behaviour(gen_server).

-include("game.hrl").
-include("errno.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("friend.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([get_friends/1, get_friends/2, request/2, get_request/1, accept/2,
    refuse/2, del_friends/2, add_black/2, del_black/2, add_enemy/2,
    search/1, send_flower/3, get_friend_list/1]).
-export([get_info/1, is_in_blacklist/2, is_friend/2]).
-export([add_intimacy/3, get_intimacy/2, get_max_intimacy/1]).
-export([hook_login/1, hook_logout/1]).

-define(SERVER, ?MODULE).
-define(ETS_FRIEND, ets_friend).
-define(change_list, change_list).

-define(FRIEND_NUM, 100).  %好友上限

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

get_friends(RoleID) ->
    #friend{roles = Roles} = get_info(RoleID),
    friends_detail(Roles).

get_friends(RoleID, Contacts) ->
    #friend{roles = Roles} = get_info(RoleID),
    friends_detail(Roles, Contacts).

% 好友名单
get_friend_list(RoleID) ->
    #friend{roles = Roles} = get_info(RoleID),
    lists:filtermap(fun({RID, FriendInfo}) ->
        case FriendInfo#friend_info.relation == ?RELATION_FRIEND of
            true -> {true, RID};
            false -> false
        end
    end, maps:to_list(Roles)).

request(RequestID, RoleID) ->
    gen_server:call(?SERVER, {request, RequestID, RoleID}).

get_request(RoleID) ->
    #friend{applied = AppliedList} = get_info(RoleID),
    [role:get_base(R) || R <- AppliedList].

accept(RoleID, AcceptID) ->
    gen_server:call(?SERVER, {accept, RoleID, AcceptID}).

refuse(RoleID, RefuseID) ->
    gen_server:call(?SERVER, {refuse, RoleID, RefuseID}).

del_friends(RoleID, DelIDs) ->
    gen_server:cast(?SERVER, {del_friends, RoleID, DelIDs}).

add_black(RoleID, BlackID) ->
    gen_server:cast(?SERVER, {add_black, RoleID, BlackID}).

del_black(RoleID, BlackID) ->
    gen_server:cast(?SERVER, {del_black, RoleID, BlackID}).

add_enemy(RoleID, Enemy) ->
    gen_server:cast(?SERVER, {add_enemy, RoleID, Enemy}).

search(Name) ->
    case role:get_roleid(Name) of
        {ok, RoleID} ->
            {ok, role:get_base(RoleID)};
        _ ->
            {error, ?ERR_FRIEND_SEARCH_NOT_FOUND, []}
    end.

send_flower(Sender, Recevier, ItemID) ->
    gen_server:cast(?SERVER, {send_flower, Sender, Recevier, ItemID}).

is_in_blacklist(RoleID, TargetID) ->
    #friend{roles=Roles} = get_info(RoleID),
    case maps:get(TargetID, Roles, undefined) of
        #friend_info{relation=?RELATION_BLACK} ->
            true;
        _ ->
            false
    end.

is_friend(RoleID, TargetID) ->
    #friend{roles=Roles} = get_info(RoleID),
    case maps:get(TargetID, Roles, undefined) of
        #friend_info{relation=?RELATION_FRIEND} ->
            true;
        _ ->
            false
    end.

add_intimacy(Sender, Recevier, Intimacy) ->
    gen_server:cast(?SERVER, {add_intimacy, Sender, Recevier, Intimacy}).

% 获取亲密度
get_intimacy(RoleID, TargetID) ->
    #friend{roles=Roles} = get_info(RoleID),
    case maps:get(TargetID, Roles, undefined) of
        #friend_info{intimacy = Intimacy} ->
            Intimacy;
        _ ->
            0
    end.

% 获取最高的亲密度
get_max_intimacy(RoleID) ->
    #friend{roles=Roles} = get_info(RoleID),
    maps:fold(fun(_K, FriendInfo, Acc) ->
        #friend_info{intimacy = Intimacy} = FriendInfo,
        max(Intimacy, Acc)
    end, 0, Roles).

hook_login(_RoleSt) ->
    notify_online(true).

hook_logout(_RoleSt) ->
    notify_online(false).


%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
    process_flag(trap_exit, true),
    ets:new(?ETS_FRIEND, [named_table,
        {keypos, #friend.id}, {read_concurrency, true}]),
    Friends = db:dirty_match_all(?DB_FRIEND),
    ets:insert(?ETS_FRIEND, Friends),
    loop(),
    {ok, undefined}.

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
do_handle_call({request, RequestID, RoleID}, _From, State) ->
    #friend{roles=MyRoles, friend_num=FriendNum} = get_info(RoleID),
    ?_check(FriendNum < ?FRIEND_NUM, ?ERR_FRIEND_SELF_FULL),
    case maps:get(RequestID, MyRoles, undefined) of
        #friend_info{relation=?RELATION_BLACK} ->
            throw(?err(?ERR_FRIEND_IN_BLACKLIST));
        #friend_info{relation=?RELATION_FRIEND} ->
            throw(?err(?ERR_FRIEND_ALREADY_FRIEND));
        _ ->
            ignore
    end,

    #friend{applied=AppliedList, roles=Roles} = RoleInfo = get_info(RequestID),
    ?_check(not lists:member(RoleID, AppliedList), ?ERR_FRIEND_ALREADY_APPLY),
    case maps:get(RoleID, Roles, undefined) of
        #friend_info{relation=?RELATION_BLACK} ->
            throw({error, ?ERR_FRIEND_REQUEST_IN_BLACKLIST, []});
        _ ->
            RoleInfo2 = RoleInfo#friend{applied=[RoleID|AppliedList]},
            set_info(RoleInfo2),
            case role:is_online(RequestID) of
                true ->
                    ?ucast(RequestID, #m_friend_request_list_toc{lists=[role:get_base(RoleID)]});
                false ->
                    ignore
            end,
            {reply, ok, State}
    end;

do_handle_call({accept, RoleID, AcceptID}, _From, State) ->
    #friend{applied=AppliedListT, friend_num=FriendNum,
        roles=Roles} = RoleInfo = get_info(RoleID),
    if
        AcceptID == 0 ->
            AppliedList = AppliedListT;
        true ->
            ?_check(lists:member(AcceptID, AppliedListT), ?ERR_GAME_BAD_ARGS),
            AppliedList = [AcceptID]
    end,

    AddNum = max(0, ?FRIEND_NUM - FriendNum),
    ?_check(AddNum > 0, ?ERR_FRIEND_ACEEPT_FULL),

    {AddNum2, AppliedList2, Fails, Roles2} = lists:foldl(
    fun(AppliedID, {Index, AccApplieds, AccFails, AccRoles}) ->
        if
            Index < AddNum ->
                case peer_accept_friend(AppliedID, RoleID) of
                    ok ->
                        {FriendInfo, AccRoles2} = add_friend(AppliedID, AccRoles),
                        notify_update(RoleID, [FriendInfo], []),
                        AccApplieds2 = [AppliedID|AccApplieds],
                        {Index+1, AccApplieds2, AccFails, AccRoles2};
                    full ->
                        {Index, AccApplieds, [AppliedID|AccFails], AccRoles}
                end;
            true ->
                {Index, AccApplieds, AccFails, AccRoles}
        end
    end, {0, [], [], Roles}, AppliedList),
    RoleInfo2 = RoleInfo#friend{applied=AppliedListT--AppliedList2,
        friend_num=FriendNum+AddNum2, roles=Roles2},
    set_info(RoleInfo2),
    {reply, {ok, AppliedList2, Fails}, State};

do_handle_call({refuse, RoleID, 0}, _From, State) ->
    #friend{applied=AppliedList} = RoleInfo = get_info(RoleID),
    RoleInfo2 = RoleInfo#friend{applied=[]},
    set_info(RoleInfo2),
    {reply, {ok, AppliedList}, State};

do_handle_call({refuse, RoleID, RefuseID}, _From, State) ->
    #friend{applied=AppliedList} = RoleInfo = get_info(RoleID),
    RoleInfo2 = RoleInfo#friend{applied=lists:delete(RefuseID, AppliedList)},
    set_info(RoleInfo2),
    {reply, {ok, [RefuseID]}, State};

do_handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

do_handle_cast({del_friends, RoleID, DelIDs}, State) ->
    do_del_friends(RoleID, DelIDs),
    [do_del_friends(DelID, [RoleID]) || DelID <- DelIDs],
    {noreply, State};

do_handle_cast({add_black, RoleID, BlackID}, State) ->
    do_del_friends(RoleID, [BlackID]),
    do_del_friends(BlackID, [RoleID]),
    #friend{applied=AppliedList, roles=Roles} = RoleInfo = get_info(RoleID),
    FriendInfo = case maps:get(BlackID, Roles, undefined) of
        undefined ->
            #friend_info{id=BlackID, relation=?RELATION_BLACK};
        Role ->
            Role#friend_info{relation=?RELATION_BLACK}
    end,
    Roles2 = maps:put(BlackID, FriendInfo, Roles),
    RoleInfo2 = RoleInfo#friend{applied=lists:delete(BlackID,AppliedList), roles=Roles2},
    set_info(RoleInfo2),
    notify_update(RoleID, [FriendInfo], []),
    {noreply, State};

do_handle_cast({del_black, RoleID, BlackID}, State) ->
    #friend{roles=Roles} = RoleInfo = get_info(RoleID),
    Roles2 = case maps:get(BlackID, Roles, undefined) of
        #friend_info{relation=?RELATION_BLACK, is_enemy=false} ->
            notify_update(RoleID, [], [BlackID]),
            maps:remove(BlackID, Roles);
        #friend_info{relation=?RELATION_BLACK, is_enemy=true} = Role ->
            FriendInfo = Role#friend_info{relation=?RELATION_STRANGER},
            notify_update(RoleID, [FriendInfo], []),
            maps:put(BlackID, FriendInfo, Roles);
        _ ->
            throw({error, ?ERR_GAME_BAD_ARGS, []})
    end,
    RoleInfo2 = RoleInfo#friend{roles=Roles2},
    set_info(RoleInfo2),
    {noreply, State};

do_handle_cast({add_enemy, RoleID, Enemy}, State) ->
    #friend{roles=Roles} = RoleInfo = get_info(RoleID),
    Roles2 = case maps:get(Enemy, Roles, undefined) of
        #friend_info{is_enemy=true} ->
            Roles;
        #friend_info{} = Role ->
            FriendInfo = Role#friend_info{is_enemy = true},
            notify_update(RoleID, [FriendInfo], []),
            maps:put(Enemy, FriendInfo, Roles);
        _ ->
            FriendInfo = #friend_info{id = Enemy, is_enemy = true},
            notify_update(RoleID, [FriendInfo], []),
            maps:put(Enemy, FriendInfo, Roles)
    end,
    RoleInfo2 = RoleInfo#friend{roles=Roles2},
    set_info(RoleInfo2),
    {noreply, State};

do_handle_cast({send_flower, Sender, Recevier, ItemID}, State) ->
    #cfg_flower{intimacy=Intimacy,charm=Charm} = cfg_flower:find(ItemID),
    add_charm(Recevier, Charm),
    add_intimacy2(Sender, Recevier, Intimacy),
    #p_role_base{name=RoleName} = SenderBase = role:get_base(Sender),
    #p_role_base{name=RoleName2} = role:get_base(Recevier),
    ?ucast(Recevier, #m_friend_receive_flower_toc{
        sender=SenderBase, flower=ItemID}),
    ?bcast(#m_friend_flower_toc{flower=ItemID}),
    #cfg_flower{broadcast=MsgNo} = cfg_flower:find(ItemID),
    ?_if(MsgNo > 0, ?notify(MsgNo, [
            {role, Sender, RoleName},
            {role, Recevier, RoleName2},
            {item, #{ItemID=>0}}
        ])),
    {noreply, State};

do_handle_cast({add_intimacy, Sender, Recevier, Intimacy}, State) ->
    add_intimacy2(Sender, Recevier, Intimacy),
    {noreply, State};

do_handle_cast(_Msg, State) ->
    {noreply, State}.


do_handle_info(loop, State) ->
    loop(),
    persist_data(),
    {noreply, State};

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.

loop() ->
    erlang:send_after(30*60*1000, self(), loop).

get_info(RoleID) ->
    case ets:lookup(?ETS_FRIEND, RoleID) of
        [] ->
            #friend{id = RoleID};
        [Info] ->
            Info
    end.

set_info(RoleInfo) ->
    ets:insert(?ETS_FRIEND, RoleInfo),
    add_change(RoleInfo#friend.id),
    ok.

friends_detail(Roles, Contacts) ->
    lists:filtermap(fun({RoleID, LastChatTime}) ->
        case role:get_cache(RoleID) of
            {ok, Cache} ->
                P = #p_friend{
                    base           = role:get_base(Cache),
                    is_online      = role:is_online(RoleID),
                    login          = Cache#role_cache.login,
                    logout         = Cache#role_cache.logout,
                    last_chat_time = LastChatTime
                },
                P2 = case maps:get(RoleID, Roles, undefined) of
                    #friend_info{relation=Relation, is_enemy=IsEnemy} ->
                        P#p_friend{
                            relation  = Relation,
                            is_enemy  = IsEnemy
                        };
                    _ ->
                        % 陌生人数据不保留在好友里面,找不到数据即为陌生人
                        P#p_friend{
                            relation  = ?RELATION_STRANGER,
                            is_enemy  = false
                        }
                end,
                {true, P2};
            _ ->
                false
        end
    end, Contacts).

friends_detail(Roles) when is_map(Roles) ->
    lists:filtermap(fun({_RoleID, FriendInfo}) ->
        p_friend(FriendInfo)
    end, maps:to_list(Roles));

friends_detail(Roles) when is_list(Roles) ->
    lists:filtermap(fun(FriendInfo) ->
        p_friend(FriendInfo)
    end, Roles).

p_friend(FriendInfo) ->
    #friend_info{id=RoleID, relation=Relation, is_enemy=IsEnemy, intimacy=Intimacy} = FriendInfo,
    case role:get_cache(RoleID) of
        {ok, Cache} ->
            {true, #p_friend{
                base      = role:get_base(Cache),
                is_online = role:is_online(RoleID),
                login     = Cache#role_cache.login,
                logout    = Cache#role_cache.logout,
                relation  = Relation,
                is_enemy  = IsEnemy,
                intimacy  = Intimacy
            }};
        _ ->
            false
    end.

peer_accept_friend(PeerID, RoleID) ->
    #friend{applied=AppliedList, friend_num=FriendNum,
        roles=Roles} = RoleInfo = get_info(PeerID),
    {FriendInfo, Roles2} = add_friend(RoleID, Roles),
    if
        FriendNum >= ?FRIEND_NUM ->
            full;
        true ->
            RoleInfo2 = RoleInfo#friend{
                applied=lists:delete(RoleID, AppliedList),
                friend_num=FriendNum+1, roles=Roles2},
            set_info(RoleInfo2),
            notify_update(PeerID, [FriendInfo], []),
            ok
    end.

add_friend(RoleID, Roles) ->
    FriendInfo = case maps:get(RoleID, Roles, undefined) of
        undefined ->
            #friend_info{id=RoleID, relation=?RELATION_FRIEND};
        Role ->
            Role#friend_info{relation=?RELATION_FRIEND}
    end,
    Roles2 = maps:put(RoleID, FriendInfo, Roles),
    {FriendInfo, Roles2}.

do_del_friends(RoleID, DelIDs) ->
    #friend{friend_num=FriendNum, roles=Roles} = RoleInfo = get_info(RoleID),
    {DelNum, Roles2} = lists:foldl(fun(R, {AccDel,Acc}) ->
        case maps:get(R, Acc, undefined) of
            #friend_info{relation=?RELATION_FRIEND, is_enemy=false} ->
                {AccDel+1, maps:remove(R, Acc)};
            #friend_info{relation=?RELATION_FRIEND, is_enemy=true} = Role ->
                % 保留仇人关系
                {AccDel+1, maps:put(R, Role#friend_info{relation=?RELATION_STRANGER,intimacy=0}, Acc)};
            _ ->
                {AccDel, Acc}
        end
    end, {0,Roles}, DelIDs),
    RoleInfo2 = RoleInfo#friend{friend_num=FriendNum-DelNum, roles=Roles2},
    set_info(RoleInfo2),
    team_server:update_intimacy(RoleID),
    notify_update(RoleID, [], DelIDs).

notify_update(RoleIDs, Add, Del) when is_list(RoleIDs) ->
    [notify_update(RoleID, Add, Del) || RoleID <- RoleIDs];
notify_update(RoleID, Add, Del) ->
    case role:is_online(RoleID) of
        true ->
            ?ucast(RoleID, #m_friend_update_toc{add = friends_detail(Add), del = Del});
        false ->
            ignore
    end.

add_charm(Recevier, Charm) ->
    role:route(Recevier, friend_handler, add_charm, Charm).

add_intimacy2(Sender, Recevier, Intimacy) ->
    #friend{roles=SRoles} = SRoleInfo = get_info(Sender),
    #friend{roles=RRoles} = RRoleInfo = get_info(Recevier),
    case maps:get(Recevier, SRoles, undefined) of
        #friend_info{relation=?RELATION_FRIEND} ->
            AddIntimacy = fun(RoleID, Roles, Add) ->
                case maps:get(RoleID, Roles, undefined) of
                    #friend_info{intimacy = I}=F ->
                        F2 = F#friend_info{intimacy=Add+I},
                        team_server:update_intimacy(RoleID),
                        role:route(RoleID, friend_handler, add_intimacy, Add, Add),
                        {F2, maps:put(RoleID, F2, Roles)};
                    _ ->
                        {error, not_found}
                end
            end,
            {RF, SRoles2} = AddIntimacy(Recevier, SRoles, Intimacy),
            {SF, RRoles2} = AddIntimacy(Sender, RRoles, Intimacy),
            set_info(SRoleInfo#friend{roles=SRoles2}),
            set_info(RRoleInfo#friend{roles=RRoles2}),
            notify_update(Sender, [RF], []),
            notify_update(Recevier, [SF], []);
        _ ->
            ignore
    end.

notify_online(IsOnline) ->
    #role_info{id=RoleID, name=Name} = role_data:get(?DB_ROLE_INFO),
    #friend{roles=Roles} = get_info(RoleID),
    maps:fold(fun(_K, FrinedInfo, _) ->
        case FrinedInfo of
            #friend_info{id=Target} ->
                case role:is_online(Target) of
                    true ->
                        ?ucast(Target, #m_friend_online_toc{
                            role_id=RoleID, name=Name, is_online=IsOnline});
                    false ->
                        ignore
                end;
            _ ->
                ignore
        end
    end, 0, Roles).

persist_data() ->
    [case ets:lookup(?ETS_FRIEND, RoleID) of
        [Info] ->
            db:dirty_write(?DB_FRIEND, Info);
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
