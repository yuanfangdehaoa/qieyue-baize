%% @author rong
%% @doc
-module(actinvest_handler).

-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("enum.hrl").
-include("actinvest.hrl").
-include("log.hrl").
-include("msgno.hrl").

-export([hook_login/1, hook_reset/3, handle/3]).

hook_login(_RoleSt) ->
    #role_actinvest{acts=Acts} = RoleActinvest = role_data:get(?DB_ROLE_ACTINVEST),
    Acts2 = lists:foldl(fun(ActID, Acc) ->
        case maps:find(ActID, Acc) of
            {ok, _Act} ->
                Acc;
            _ ->
                maps:put(ActID, #r_actinvest{id=ActID}, Acc)
        end
    end, Acts, actives()),
    role_data:set(RoleActinvest#role_actinvest{acts=Acts2}).

hook_reset(_DoW, _Hour, RoleSt) ->
    hook_login(RoleSt),
    handle(?ACTINVEST_INFO, ?nil, RoleSt).

handle(?ACTINVEST_INFO, _Tos, RoleSt) ->
    #role_actinvest{acts=Acts} = role_data:get(?DB_ROLE_ACTINVEST),
    PActs = lists:map(fun(Act) ->
        case time_range(Act#r_actinvest.id) of
            {ok, STime, ETime} -> ok;
            _ -> STime = ETime = ut_time:datetime() %超时就拿当前时间
        end,
        #p_actinvest{
            act_id = Act#r_actinvest.id,
            day    = calc_day(Act#r_actinvest.time),
            fetch  = Act#r_actinvest.fetch,
            stime  = ut_time:datetime_to_seconds(STime),
            etime  = ut_time:datetime_to_seconds(ETime)
        }
    end, maps:values(Acts)),
    ?ucast(#m_actinvest_info_toc{acts=PActs});

handle(?ACTINVEST_BUY, Tos, RoleSt) ->
    #m_actinvest_buy_tos{act_id=ActID} = Tos,
    #role_actinvest{acts=Acts} = RoleActinvest = role_data:get(?DB_ROLE_ACTINVEST),
    ?_check(is_active(ActID), ?ERR_ACTINVEST_NOT_START),
    ?_check(maps:find(ActID, Acts) =/= error, ?ERR_ACTINVEST_NOT_START),
    #r_actinvest{is_invest=IsInvest, fetch=Fetch} = Act = maps:get(ActID, Acts),
    ?_check(not IsInvest, ?ERR_ACTINVEST_ALREADY_INVEST),
    #cfg_actinvest{name=Name, pay=Cost, panel=Panel} = cfg_actinvest:find(ActID),
    Day = 1,
    Gain = cfg_actinvest_reward:find(ActID, Day),
    Cost = Cost,
    Succ = fun() ->
        #role_st{role=RoleID, name=RoleName} = RoleSt,
        Act2 = Act#r_actinvest{is_invest=true, time=ut_time:seconds(), fetch=[Day|Fetch]},
        Acts2 = maps:put(ActID, Act2, Acts),
        role_data:set(RoleActinvest#role_actinvest{acts=Acts2}),
        ?ucast(#m_actinvest_buy_toc{act_id=ActID}),
        ?notify(?MSG_ACTINVEST_BUY, [{role, RoleID, RoleName}, Name, Panel])
    end,
    role_bag:deal(Cost, Gain, ?LOG_ACTINVEST, Succ, RoleSt);

handle(?ACTINVEST_REWARD, Tos, RoleSt) ->
    #m_actinvest_reward_tos{act_id=ActID, day=Day} = Tos,
    #role_actinvest{acts=Acts} = RoleActinvest = role_data:get(?DB_ROLE_ACTINVEST),
    ?_check(maps:find(ActID, Acts) =/= error, ?ERR_ACTINVEST_NOT_START),
    #r_actinvest{is_invest=IsInvest, time=Time, fetch=Fetch} = Act = maps:get(ActID, Acts),
    ?_check(IsInvest, ?ERR_ACTINVEST_NOT_INVEST),
    ?_check(not lists:member(Day, Fetch), ?ERR_ACTINVEST_ALREADY_FETCH),
    ?_check(cfg_actinvest_reward:find(ActID, Day) =/= ?nil, ?ERR_ACTINVEST_NO_REWARD),
    ?_check(Day =< calc_day(Time), ?ERR_ACTINVEST_NO_REWARD),
    Gain = cfg_actinvest_reward:find(ActID, Day),
    Succ = fun() ->
        Act2 = Act#r_actinvest{fetch=[Day|Fetch]},
        Acts2 = maps:put(ActID, Act2, Acts),
        role_data:set(RoleActinvest#role_actinvest{acts=Acts2}),
        ?ucast(#m_actinvest_reward_toc{act_id=ActID, day=Day})
    end,
    role_bag:gain(Gain, ?LOG_ACTINVEST, Succ, RoleSt).
   
%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
calc_day(Time) ->
    if
        is_integer(Time) ->
            max(0, ut_time:diff_days(Time, ut_time:seconds()) + 1);
        true ->
            0
    end.

% is_fetch_all(ActID, Fetch) ->
%     Fetch =/= [] andalso cfg_actinvest_reward:max(ActID) == lists:max(Fetch).

time_range(ActID) ->
    #cfg_actinvest{cycle=Cycle, days=DayList, time=TimeList} = cfg_actinvest:find(ActID),
    TimeList2 = [{T1, T2, T2} || {T1, T2} <- TimeList],
    ut_activity:schedule(Cycle, DayList, TimeList2).

is_active(ActID) ->
    case time_range(ActID) of
        timeout -> 
            false;
        {ok, STime, ETime} ->
            ut_time:datetime() >= STime andalso ut_time:datetime() =< ETime
    end.

actives() ->
    lists:filter(fun(ActID) -> is_active(ActID) end, lists:sort(cfg_actinvest:all())).
