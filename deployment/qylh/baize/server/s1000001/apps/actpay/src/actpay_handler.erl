%% @author rong
%% @doc
-module(actpay_handler).

-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("enum.hrl").
-include("actpay.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("pay.hrl").


-export([hook_login/1, hook_reset/3, handle/3, notify/4]).

hook_login(_RoleSt) ->
    #role_actpay{acts=Acts} = RoleActpay = role_data:get(?DB_ROLE_ACTPAY),
    Acts2 = lists:foldl(fun(ActID, Acc) ->
        case maps:find(ActID, Acc) of
            {ok, Act} ->
                if
                    is_integer(Act#r_actpay.time) ->
                        Acc;
                    true ->
                        role_event:listen(?EVENT_PAY, ?MODULE, notify, ActID),
                        Acc
                end;
            _ ->
                role_event:listen(?EVENT_PAY, ?MODULE, notify, ActID),
                maps:put(ActID, #r_actpay{id=ActID}, Acc)
        end
    end, Acts, actives()),
    role_data:set(RoleActpay#role_actpay{acts=Acts2}).

hook_reset(_DoW, _Hour, RoleSt) ->
    hook_login(RoleSt),
    handle(?ACTPAY_INFO, ?nil, RoleSt).

handle(?ACTPAY_INFO, _Tos, RoleSt) ->
    #role_actpay{acts=Acts} = role_data:get(?DB_ROLE_ACTPAY),
    PActs = [
        #p_actpay{
            act_id = Act#r_actpay.id,
            day    = calc_day(Act#r_actpay.time),
            fetch  = Act#r_actpay.fetch
        }
    || Act <- maps:values(Acts)],
    ?ucast(#m_actpay_info_toc{acts=PActs});

handle(?ACTPAY_REWARD, Tos, RoleSt) ->
    #m_actpay_reward_tos{act_id=ActID, day=Day} = Tos,
    #role_actpay{acts=Acts} = RoleActpay = role_data:get(?DB_ROLE_ACTPAY),
    #cfg_actpay{opdays=NeedOpdays} = cfg_actpay:find(ActID),
    ?_check(game_env:get_opened_days() >= NeedOpdays, ?ERR_ACTPAY_NOT_START),
    ?_check(maps:find(ActID, Acts) =/= error, ?ERR_ACTPAY_NOT_START),
    #r_actpay{time=Time, fetch=Fetch} = Act = maps:get(ActID, Acts),
    ?_check(is_integer(Time), ?ERR_ACTPAY_NOT_PAYED),
    ?_check(not lists:member(Day, Fetch), ?ERR_ACTPAY_ALREADY_FETCH),
    ?_check(cfg_actpay_reward:find(ActID, Day) =/= ?nil, ?ERR_ACTPAY_NO_REWARD),
    ?_check(Day =< calc_day(Time), ?ERR_ACTPAY_NO_REWARD),
    Gain = cfg_actpay_reward:find(ActID, Day),
    Succ = fun() ->
        Act2 = Act#r_actpay{fetch=[Day|Fetch]},
        Acts2 = maps:put(ActID, Act2, Acts),
        role_data:set(RoleActpay#role_actpay{acts=Acts2}),
        ?ucast(#m_actpay_reward_toc{act_id=ActID, day=Day}),
        Day == 1 andalso begin
            #role_st{role=RoleID, name=RoleName} = RoleSt,
            ItemMap = #{11080326 => 0, 41009 => 0},
            ?notify(?MSG_ACTPAY_REWARD, [{role, RoleID, RoleName}, {item, ItemMap}])
        end
    end,
    role_bag:gain(Gain, ?LOG_ACTPAY, Succ, RoleSt).

notify(?EVENT_PAY, ActID, {_GainGold, _TodayOld, _TodayNew}, RoleSt) ->
    #role_actpay{acts=Acts} = RoleActpay = role_data:get(?DB_ROLE_ACTPAY),
    case maps:find(ActID, Acts) of
        {ok, Act} ->
            #cfg_actpay{pay=ActGoodsId} = cfg_actpay:find(ActID),
            #role_pay{payments=Payments} = role_data:get(?DB_ROLE_PAY),
            RGoodsList = [GoodsId ||#payment{goods_id = GoodsId} <- Payments],
            case lists:member(ActGoodsId,RGoodsList) of
                true ->
                    role_event:remove(?EVENT_PAY, ?MODULE, notify, ActID),
                    Act2 = Act#r_actpay{time=ut_time:seconds()},
                    Acts2 = maps:put(ActID, Act2, Acts),
                    role_data:set(RoleActpay#role_actpay{acts=Acts2}),
                    handle(?ACTPAY_INFO, ?nil, RoleSt);
                _ ->
                    ignore
            end;
        error ->
            ignore
    end.
    
%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
calc_day(Time) ->
    if
        is_integer(Time) ->
            ut_time:diff_days(Time, ut_time:seconds()) + 1;
        true ->
            0
    end.

actives() ->
    lists:filter(fun(ActID) ->
        #cfg_actpay{opdays=NeedOpdays} = cfg_actpay:find(ActID),
        game_env:get_opened_days() >= NeedOpdays
    end, cfg_actpay:all()).
