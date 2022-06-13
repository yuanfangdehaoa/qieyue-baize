%% @author rong
%% @doc
-module(yunying_shop_manager).

-behaviour(gen_server).

-include_lib("stdlib/include/ms_transform.hrl").
-include("game.hrl").
-include("yunying.hrl").
-include("table.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("enum.hrl").

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/0]).
-export([hook_chime/1, hook_start/1, hook_stop/1]).
-export([get_info/2, get_reward_logs/1, buy/7]).

-define(SERVER, ?MODULE).
-define(ACT_TYPE, 780).

-record(state, {keys = []}).

-record(r_yy_shop, {id, count=0, roles = #{}}).

-record(r_yy_shop_role, {role_id, name, suid, buy_num=0}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

hook_chime(0) ->
    gen_server:cast(?SERVER, chime);
hook_chime(Hour) ->
    gen_server:cast(?SERVER, {reward, Hour}).

hook_start(ActID) ->
    gen_server:cast(?SERVER, {hook_start, ActID}).

hook_stop(ActID) ->
    gen_server:cast(?SERVER, {hook_stop, ActID}).

get_info(ActID, RoleID) ->
    cluster:gen_call_cross(?CROSS_RULE_24_8, ?SERVER, {get_info, ActID, RoleID}).

get_reward_logs(ActID) ->
    cluster:gen_call_cross(?CROSS_RULE_24_8, ?SERVER, {get_reward_logs, ActID}).

buy(RoleID, ActID, ShopID, Num, Name, SUID, BroadcastIds) ->
    cluster:gen_call_cross(?CROSS_RULE_24_8, ?SERVER, {buy, RoleID, ActID, ShopID, Num, Name, SUID, BroadcastIds}).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({}) ->
    process_flag(trap_exit, true),
    {ok, #state{}}.

handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(persist, State) ->
    erlang:send_after(timer:minutes(15), self(), persist),
    persist(State),
    {noreply, State};

handle_info(Info, State) ->
    ?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, State) ->
    persist(State),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call({get_info, ActID, RoleID}, _From, State) ->
    #yy_shop_act{join_log=Logs, world_lv=WorldLv, day=Day, shop=Shops} = get_act(ActID),
    ShopList = lists:map(fun(ID) ->
        Shop = maps:get(ID, Shops, default_shop(ID)),
        p_shop(RoleID, Shop)
    end, cfg_yunying_lottery_shop:ids(ActID, Day, WorldLv)),
    {reply, {ok, ShopList, Logs}, State};

do_handle_call({get_reward_logs, ActID}, _From, State) ->
    #yy_shop_act{reward_log=Logs} = get_act(ActID),
    {reply, Logs, State};

do_handle_call({buy, RoleID, ActID, ShopID, Num, Name, SUID, BroadcastIds}, _From, State) ->
    #yy_shop_act{day=Day, world_lv=WorldLv, shop=Shops, join_log=Logs} = Act = get_act(ActID),
    IDs = cfg_yunying_lottery_shop:ids(ActID, Day, WorldLv),
    ?_check(lists:member(ShopID, IDs), ?ERR_YUNYING_SHOP_NOT_SELL),

    #r_yy_shop{count=Count, roles=Roles} = Shop = maps:get(ShopID, Shops, default_shop(ShopID)),

    #cfg_yunying_lottery_shop{limit=Limit, max=Max} = cfg_yunying_lottery_shop:find(ActID, ShopID),
    ?_check(Count + Num =< Max, ?ERR_YUNYING_SHOP_MAX),

    #r_yy_shop_role{buy_num=RoleBuyNum} = Role = case maps:find(RoleID, Roles) of
        {ok, Role0} ->
            Role0#r_yy_shop_role{name=Name, suid=SUID};
        _ ->
            #r_yy_shop_role{role_id=RoleID, name=Name, suid=SUID, buy_num=0}
    end,
    case is_in_unlimit(ActID) of
        true ->
            ok;
        false ->
            ?_check(RoleBuyNum + Num =< Limit, ?ERR_YUNYING_SHOP_LIMIT)
    end,

    {NewLogs, Logs2} = case BroadcastIds =/= [] of
        true ->
            NewLogs0 = [#p_yy_shop_log{
                role_id   = RoleID,
                role_name = Name,
                suid      = SUID,
                shop_id   = ShopID,
                reward_id = RewardId
            } || RewardId <- BroadcastIds],
            {NewLogs0, lists:sublist(NewLogs0 ++ Logs, 50)};
        false ->
            {[], Logs}
    end,
    Shop2 = Shop#r_yy_shop{
        count = Count + Num,
        roles = maps:put(RoleID, Role#r_yy_shop_role{buy_num=Num+RoleBuyNum}, Roles)
    },
    Act2 = Act#yy_shop_act{
        shop     = maps:put(ShopID, Shop2, Shops),
        join_log = Logs2
    },
    set_act(Act2),
    {reply, {ok, p_shop(RoleID, Shop2), NewLogs}, State};

do_handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

do_handle_cast(started, State) ->
    Group = cluster_cross:get_group(?CROSS_RULE_24_8),
    MS = ets:fun2ms(fun(E) when element(1, E#yy_shop_act.act_id) == Group -> E end),
    ShopActs = db:dirty_select(?DB_YY_SHOP_ACT, MS),
    Keys  = lists:map(fun(Act) ->
        Act2 = Act#yy_shop_act{act_id=element(2, Act#yy_shop_act.act_id)},
        set_act(Act2),
        Act#yy_shop_act.act_id
    end, ShopActs),
    {noreply, State#state{keys = Keys}};

do_handle_cast({hook_start, ActID}, #state{keys=Keys} = State) ->
    Mod = yunying_util:cfg_act_mod(ActID),
    #cfg_yunying{type=Type} = Mod:find(ActID),
    case Type of
        ?ACT_TYPE ->
            {ok, STime, _} = yunying:get_act_time(ActID),
            case get_act(ActID) of
                ?nil ->
                    Act = #yy_shop_act{
                        act_id   = ActID,
                        world_lv = world_level:get_level(),
                        day      = ut_time:diff_days(STime, ut_time:seconds()) + 1
                    },
                    set_act(Act);
                Act ->
                    Act2 = Act#yy_shop_act{day = ut_time:diff_days(STime, ut_time:seconds()) + 1},
                    set_act(Act2)
            end,
            Key = key(ActID),
            {noreply, State#state{keys=[Key|lists:delete(Key, Keys)]}};
        _ ->
            {noreply, State}
    end;

do_handle_cast({hook_stop, ActID}, #state{keys=Keys} = State) ->
    Mod = yunying_util:cfg_act_mod(ActID),
    #cfg_yunying{type=Type} = Mod:find(ActID),
    case Type of
        ?ACT_TYPE ->
            Key = key(ActID),
            del_act(ActID, Key),
            {noreply, State#state{keys=lists:delete(Key, Keys)}};
        _ ->
            {noreply, State}
    end;

do_handle_cast(chime, #state{keys=Keys} = State) ->
    [begin
        case yunying:get_act_time(ActID) of
            {ok, STime, _} ->
                % 还在活动期间
                Act = get_act(ActID),
                Act2 = Act#yy_shop_act{
                    day        = ut_time:diff_days(STime, ut_time:seconds()) + 1,
                    shop       = #{},
                    join_log   = [],
                    reward_log = []
                },
                set_act(Act2);
            error ->
                ignore
        end
    end || {_, ActID} <- Keys],
    {noreply, State};

do_handle_cast({reward, Hour}, State) ->
    [begin
        Mod = yunying_util:cfg_act_mod(ActID),
        #cfg_yunying{reqs=Reqs} = Mod:find(ActID),
        RewardHour = proplists:get_value(reward_hour, Reqs),
        case RewardHour == Hour of
            true ->
                send_reward(ActID);
            false ->
                ignore
        end
    end || {_, ActID} <- State#state.keys],
    {noreply, State};

do_handle_cast(_Msg, State) ->
    {noreply, State}.

do_handle_info(_Msg, State) ->
    {noreply, State}.

persist(State) ->
    [begin
        Act = get_act(ActID),
        db:dirty_write(?DB_YY_SHOP_ACT, Act#yy_shop_act{act_id=Key})
    end || Key = {_, ActID} <- State#state.keys].

get_act(ActID) ->
    erlang:get({shop, ActID}).

set_act(Act) ->
    erlang:put({shop, Act#yy_shop_act.act_id}, Act).

del_act(ActID, Key) ->
    erlang:erase({shop, ActID}),
    db:dirty_delete(?DB_YY_SHOP_ACT, Key).

default_shop(ShopID) ->
    #r_yy_shop{id=ShopID}.

get_role_buy_num(RoleID, Roles) ->
    case maps:find(RoleID, Roles) of
        {ok, Role} ->
            Role#r_yy_shop_role.buy_num;
        _ ->
            0
    end.

is_in_unlimit(ActID) ->
    Mod = yunying_util:cfg_act_mod(ActID),
    #cfg_yunying{reqs=Reqs} = Mod:find(ActID),
    RewardHour = proplists:get_value(reward_hour, Reqs),
    UnlimitSec = proplists:get_value(unlimit_seconds, Reqs),
    RewardTime = ut_time:datetime_to_seconds({ut_time:date(), {RewardHour, 0, 0}}),
    Now = ut_time:seconds(),
    Now >= (RewardTime - UnlimitSec) andalso Now < RewardTime.

send_reward(ActID) ->
    #yy_shop_act{shop=Shops} = Act = get_act(ActID),
    Logs2 = maps:fold(fun(ShopID, Shop, AccLogs1) ->
        #cfg_yunying_lottery_shop{total=Total, max=Max, rewards=Rewards, min=Min}
            = cfg_yunying_lottery_shop:find(ActID, ShopID),
        #r_yy_shop{count=Count, roles=Roles} = Shop,
        TotalRewardNum0 = Count * Total div Max,
        TotalRewardNum  = ?_if(TotalRewardNum0 < 1, ?_if(Count >= Min, 1, 0), TotalRewardNum0),
        Weights = maps:fold(fun(RoleID, ShopRole, Acc) ->
            #r_yy_shop_role{buy_num=BuyNum} = ShopRole,
            [{RoleID, BuyNum} | Acc]
        end, [], Roles),

        RewardRoles0 = case TotalRewardNum >= 1 andalso lists:reverse(lists:keysort(2, Weights)) of
            [{ID, _} | _] ->
                TotalRewardNum2 = TotalRewardNum - 1,
                #{ID=>1};
            _ ->
                TotalRewardNum2 = TotalRewardNum,
                #{}
        end,

        RewardRoles = lists:foldl(fun(_, Acc) ->
            RoleID = ut_rand:weight(Weights),
            ut_misc:maps_increase(RoleID, 1, Acc)
        end, RewardRoles0, lists:seq(1, max(0, TotalRewardNum2))),

        ?debug("yy_shop_act : ~w, reward num ~w, roles: ~w", [ActID, TotalRewardNum, RewardRoles]),

        maps:fold(fun(RoleID, RewardNum, AccLogs2) ->
            ShopRole = maps:get(RoleID, Roles),
            Items = lists:map(fun(R) ->
                Num = erlang:element(2, R),
                erlang:setelement(2, R, Num*RewardNum)
            end, Rewards),
            mail:send(RoleID, ?MAIL_YUNYING_SHOP_REWARD, Items, []),
            [#p_yy_shop_reward_log{
                id        = ShopID,
                role_id   = RoleID,
                role_name = ShopRole#r_yy_shop_role.name,
                suid      = ShopRole#r_yy_shop_role.suid,
                num       = RewardNum
            } | AccLogs2]
        end, AccLogs1, RewardRoles)
    end, [], Shops),
    Logs3 = lists:sort(fun(A, B) ->
        #cfg_yunying_lottery_shop{category=C1}
            = cfg_yunying_lottery_shop:find(ActID, A#p_yy_shop_reward_log.id),
        #cfg_yunying_lottery_shop{category=C2}
            = cfg_yunying_lottery_shop:find(ActID, B#p_yy_shop_reward_log.id),
        C1 < C2
    end, Logs2),
    set_act(Act#yy_shop_act{reward_log=Logs3}).

p_shop(RoleID, Shop) ->
    BuyNum = get_role_buy_num(RoleID, Shop#r_yy_shop.roles),
    #p_yy_shop{
        id       = Shop#r_yy_shop.id,
        buy_num  = BuyNum,
        progress = Shop#r_yy_shop.count
    }.

key(ActID) ->
    {cluster_cross:get_group(?CROSS_RULE_24_8), ActID}.

% find_log(_, _, []) ->
%     not_found;
% find_log(RoleID, ShopID, [H|T]) ->
%     if
%         H#p_yy_shop_log.role_id == RoleID,
%         H#p_yy_shop_log.shop_id == ShopID ->
%             found;
%         true ->
%             find_log(RoleID, ShopID, T)
%     end.
