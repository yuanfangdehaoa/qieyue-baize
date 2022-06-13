%% @author rong
%% @doc
-module(firstpay_handler).

-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("enum.hrl").
-include("log.hrl").
-include("msgno.hrl").

-export([hook_login/1, handle/3, notify/3]).

hook_login(_RoleSt) ->
    #role_firstpay{is_payed=IsPayed} = role_data:get(?DB_ROLE_FIRSTPAY),
    not IsPayed andalso role_event:listen(?EVENT_PAY, ?MODULE, notify).

handle(?FIRSTPAY_INFO, _Tos, RoleSt) ->
    #role_firstpay{is_payed=IsPayed, time=Time,
        fetch=Fetch} = role_data:get(?DB_ROLE_FIRSTPAY),
    Day = calc_day(Time),
    ?ucast(#m_firstpay_info_toc{is_payed=IsPayed, day=Day, fetch=Fetch});

handle(?FIRSTPAY_REWARD, Tos, RoleSt) ->
    #m_firstpay_reward_tos{day=Day} = Tos,
    #role_firstpay{is_payed=IsPayed, time=Time,
        fetch=Fetch} = FirstPay = role_data:get(?DB_ROLE_FIRSTPAY),
    ?_check(IsPayed, ?ERR_FIRSTPAY_NOT_PAYED),
    ?_check(not lists:member(Day, Fetch), ?ERR_FIRSTPAY_ALREADY_FETCH),
    ?_check(cfg_firstpay:find(Day) =/= ?nil, ?ERR_FIRSTPAY_NO_REWARD),
    case Day == 4 of
        true  ->
            BeginTime = role_count:get_times(super_firstpay),
            TotalFee  = ?_if(BeginTime == 0, 0, role_pay:fee(BeginTime)),
            ?_check(TotalFee >= 128, ?ERR_FIRSTPAY_NOT_PAYED);
        false ->
            ?_check(Day =< calc_day(Time), ?ERR_FIRSTPAY_NO_REWARD)
    end,
    Gain = cfg_firstpay:find(Day),
    Succ = fun() ->
        Fetch2 = [Day | Fetch],
        role_data:set(FirstPay#role_firstpay{fetch=Fetch2}),
%%        case lists:member(1, Fetch2) andalso lists:member(2, Fetch2) of
        case Day == 1 of
            true  ->
                %% 领了首充后就开始加，然后就不管了
                role_count:add_times(super_firstpay, ut_time:seconds());
            false ->
                ignore
        end,
        ?ucast(#m_firstpay_reward_toc{}),
        handle(?FIRSTPAY_INFO, ?nil, RoleSt),
        Day == 1 andalso begin
            #role_info{id=RoleID, name=RoleName} = role_data:get(?DB_ROLE_INFO),
            ?notify(?MSG_FIRSTPAY_REWARD, [{role, RoleID, RoleName}])
        end
    end,
    role_bag:gain(Gain, ?LOG_FIRSTPAY, Succ, RoleSt);

handle(?FIRSTPAY_SUPERINFO, _Tos, RoleSt) ->
    BeginTime = role_count:get_times(super_firstpay),
    case BeginTime == 0 of
        true  ->
            TotalFee = 0,
            IsFetch = false;
        false ->
            TotalFee = role_pay:fee(BeginTime),
            #role_firstpay{fetch=Fetch} = role_data:get(?DB_ROLE_FIRSTPAY),
            IsFetch = lists:member(4, Fetch)
    end,
    ?ucast(#m_firstpay_superinfo_toc{pay_num=TotalFee, is_fetch=IsFetch}).

notify(?EVENT_PAY, _, RoleSt) ->
    FirstPay = role_data:get(?DB_ROLE_FIRSTPAY),
    role_data:set(FirstPay#role_firstpay{is_payed=true, time=ut_time:seconds()}),
    role_event:remove(?EVENT_PAY, ?MODULE, notify),
    handle(?FIRSTPAY_INFO, ?nil, RoleSt).

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
