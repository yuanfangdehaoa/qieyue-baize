%%%=============================================================================
%%% @author z.hua
%%% @doc
%%% Role API
%%% @end
%%%=============================================================================

-module(role).

-include("game.hrl").
-include("role.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("faker.hrl").

%% API
-export([get_ref/1]).
-export([get_pid/1]).
-export([get_data/2]).
-export([get_roleid/1]).
-export([get_cache/1]).
-export([get_base/1]).
-export([get_power/1]).
-export([cast/2]).
-export([route/3, route/4, route/5]).
-export([is_role/1]).
-export([is_exist/1]).
-export([is_online/1]).
-export([is_alive/1]).
-export([kickout/2, kickout/3]).
-export([add_exp/3]).

-define(is_roleid(RoleID), RoleID > 100000000000).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%%-----------------------------------------------
%% @doc 获取玩家进程的引用
-spec get_ref(integer()) ->
    RoleRef :: atom() | tuple().
%%-----------------------------------------------
get_ref(RoleID) when is_integer(RoleID) andalso ?is_roleid(RoleID) ->
    RegName = role_util:reg_name(RoleID),
    case role_util:is_local(RoleID) of
        true  ->
            RegName;
        false ->
            % 游戏服不能获取，避免游戏服之间相连
            case cluster:is_local() of
                true  -> ?nil;
                false -> {RegName, cluster:get_local(RoleID)}
            end
    end;
get_ref(_) ->
    ?nil.


%%-----------------------------------------------
%% @doc 获取玩家进程 pid
-spec get_pid(integer()) ->
    pid().
%%-----------------------------------------------
get_pid(RoleID) when is_integer(RoleID) andalso ?is_roleid(RoleID) ->
	RegName = role_util:reg_name(RoleID),
    case role_util:is_local(RoleID) of
        true  ->
            erlang:whereis(RegName);
        false ->
            cluster:rpc_call_local(RoleID, erlang, whereis, [RegName])
    end;
get_pid(_) ->
    ?nil.


%%-----------------------------------------------
%% @doc 通过玩家名称获取玩家id
-spec get_roleid(string()) ->
    integer().
%%-----------------------------------------------
get_roleid(Name) ->
    role_manager:get_roleid(Name).


%%-----------------------------------------------
%% @doc 获取玩家缓存
-spec get_cache(integer()) ->
    {ok, #role_cache{}} | error().
%%-----------------------------------------------
get_cache(RoleID) ->
    case RoleID == role_util:get_id() of
        true  ->
            {ok, role_util:make_cache()};
        false ->
            case role_util:is_local(RoleID) of
                true  ->
                    role_cache:get_cache(RoleID);
                false ->
                    cluster:rpc_call_local(RoleID, role_cache, get_cache, [RoleID])
            end
    end.

get_base(RoleID) when is_integer(RoleID) ->
    case role_util:is_local(RoleID) of
        true  ->
            {ok, Cache} = get_cache(RoleID),
            p_role_base(Cache);
        false ->
            case cluster:is_local() of
                true  ->
                    {ok, Cache, _} = cluster_cache:get_role(RoleID),
                    p_role_base(Cache);
                false ->
                    {ok, Cache} = get_cache(RoleID),
                    p_role_base(Cache)
            end

    end;
get_base(Cache) ->
    p_role_base(Cache).


%%-----------------------------------------------
%% @doc 获取玩家战力
-spec get_power(integer()) ->
    integer().
%%-----------------------------------------------
get_power(RoleID) ->
    {ok, Cache} = get_cache(RoleID),
    Cache#role_cache.power.


%%-----------------------------------------------
%% @doc 获取角色数据
-spec get_data(integer() | pid(), [atom()]) ->
    {ok, [any()]}.
%%-----------------------------------------------
-ifdef(DEBUG).

get_data(RoleID, Keys) when is_integer(RoleID) andalso RoleID > 0 ->
    ?_check(RoleID /= role_util:get_id(), ?ERR_GAME_BAD_CALL),
    do_get_data(RoleID, Keys);
get_data(RolePid, Keys) when is_pid(RolePid) ->
    ?_check(RolePid /= self(), ?ERR_GAME_BAD_CALL),
    do_get_data(RolePid, Keys).

-else.

get_data(RoleRef, Keys) ->
    do_get_data(RoleRef, Keys).

-endif.


%%-----------------------------------------------
%% @doc cast 玩家进程
-spec cast(integer(), any()) ->
    no_return().
%%-----------------------------------------------
cast(RoleID, Msg) when is_integer(RoleID) ->
    gen_server:cast(get_ref(RoleID), Msg);
cast(RolePid, Msg) when is_pid(RolePid) ->
    gen_server:cast(RolePid, Msg).


%%-----------------------------------------------
%% @doc 路由转发
%% 角色进程会以 Mod:Fun(Args, RoleSt) 进行回调
-spec route(integer() | pid(), module(), function(), any(), any()) ->
    no_return().
%%-----------------------------------------------
route(RoleID, Mod, Fun) when is_integer(RoleID) ->
    gen_server:cast(get_ref(RoleID), {route, Mod, Fun});
route(RolePid, Mod, Fun) when is_pid(RolePid) ->
    gen_server:cast(RolePid, {route, Mod, Fun}).

route(RoleID, Mod, Fun, Args) when is_integer(RoleID) ->
    gen_server:cast(get_ref(RoleID), {route, Mod, Fun, Args});
route(RolePid, Mod, Fun, Args) when is_pid(RolePid) ->
    gen_server:cast(RolePid, {route, Mod, Fun, Args}).

route(RoleID, Mod, Fun, Args, OffMsg) ->
    case role_util:is_local(RoleID) of
        true  ->
            case get_pid(RoleID) of
                ?nil ->
                    role_offmsg:insert(RoleID, Mod, Fun, OffMsg);
                Pid  ->
                    gen_server:cast(Pid, {route, Mod, Fun, Args})
            end;
        false ->
            cluster:rpc_cast_local(
                RoleID,
                ?MODULE,
                route,
                [RoleID, Mod, Fun, Args, OffMsg]
            )
    end.



%%-----------------------------------------------
%% @doc 是否是玩家id
-spec is_role(integer()) ->
    boolean().
%%-----------------------------------------------
is_role(RoleID) ->
    ?is_roleid(RoleID).


%%-----------------------------------------------
%% @doc 玩家是否存在
-spec is_exist(integer()) ->
    boolean().
%%-----------------------------------------------
is_exist(RoleID) ->
    db:dirty_read(?DB_ROLE_INFO, RoleID) /= [].


%%-----------------------------------------------
%% @doc 玩家是否在线
-spec is_online(integer()) ->
    boolean().
%%-----------------------------------------------
is_online(RoleID) ->
    online_server:is_online(RoleID).


%%-----------------------------------------------
%% @doc 玩家进程是否存在
-spec is_alive(integer()) ->
    boolean().
%%-----------------------------------------------
is_alive(RoleID) ->
    get_pid(RoleID) /= ?nil.


%%-----------------------------------------------
%% @doc 踢玩家下线
-spec kickout(integer(), list(), integer()) ->
    no_return().
%%-----------------------------------------------
kickout(RoleID, Errno) ->
    kickout(RoleID, [], Errno).

kickout(RoleID, Reqs, Errno) ->
    role_agent:kickgame(get_ref(RoleID), Reqs, Errno).


%%-----------------------------------------------
%% @doc 加经验
-spec add_exp(integer() | pid(), integer(), integer()) ->
    no_return().
%%-----------------------------------------------
add_exp(RoleRef, Exp, Log) ->
    cast(RoleRef, {add_exp, Exp, Log}).


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
p_role_base(Cache) ->
    #role_cache{viptype=VipType, viplv=VipLv, vipend=VipETime} = Cache,
    #p_role_base{
        id     = Cache#role_cache.id,
        name   = Cache#role_cache.name,
        career = Cache#role_cache.career,
        gender = Cache#role_cache.gender,
        level  = Cache#role_cache.level,
        viplv  = role_vip:get_level(VipLv, VipType, VipETime),
        power  = Cache#role_cache.power,
        guild  = Cache#role_cache.guild,
        gname  = Cache#role_cache.gname,
        gpost  = Cache#role_cache.gpost,
        figure = Cache#role_cache.figure,
        charm  = Cache#role_cache.charm,
        wake   = Cache#role_cache.wake,
        marry  = Cache#role_cache.marry,
        mname  = Cache#role_cache.mname,
        mtype  = Cache#role_cache.mtype,
        icon   = Cache#role_cache.icon,
        suid   = Cache#role_cache.suid,
    	zoneid = Cache#role_cache.zoneid,
        team   = Cache#role_cache.team
    }.

do_get_data(RoleID, Keys) when is_integer(RoleID) andalso RoleID > 0 ->
    case role_util:is_local(RoleID) of
        true  ->
            case role:is_alive(RoleID) of
                true  ->
                    RegName = role_util:reg_name(RoleID),
                    role_agent:query(RegName, Keys);
                false ->
                    Vals = lists:map(fun
                        ({bag, BagID}) ->
                            case db:dirty_read(?DB_ROLE_BAG, RoleID) of
                                [RoleBag] ->
                                    role_bag:get_bagitems(RoleBag, BagID);
                                [] ->
                                    []
                            end;
                        (Tab) ->
                            case db:dirty_read(Tab, RoleID) of
                                [R] -> R;
                                []  -> ?nil
                            end
                    end, Keys),
                    {ok, Vals}
            end;
        false ->
            cluster:rpc_call_local(RoleID, ?MODULE, get_data, [RoleID,Keys])
    end;
do_get_data(RolePid, Keys) when is_pid(RolePid) ->
    case node(RolePid) == node() of
        true  -> role_agent:query(RolePid, Keys);
        false -> throw(?err(?ERR_GAME_CALL_NODE))
    end.
