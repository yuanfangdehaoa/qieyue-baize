%% @author rong
%% @doc
-module(realname_handler).

-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").

-define(OK      , 1).
-define(UNKNOWN , 2).
-define(NEVER   , 3).
-define(REALIZED, 4).

-define(AUTH, 0).
-define(WAIT, 1).
-define(DENY, 2).

-record(r_realname, {status, is_registerd, age, is_adult, id_card, real_name, state}).

-export([handle/3, call_back/2, hook_reset/1]).
-export([parse_idcard/1]).
-export([kickout/2]).

handle(?REALNAME_INFO, Tos, RoleSt) ->
    spawn(fun() ->
        #role_st{user=#game_user{gamechan=GameChan, account=Account}} = RoleSt,
        URL = ut_conv:to_binary(lists:concat([game_env:get_admin_host(),
            "/api/role/real_name?game_channel_id=", GameChan, "&account=", Account])),

        case hackney:request(get, URL, [], <<>>, [{connect_timeout,1000}]) of
            {ok, 200, _, ClientRef} ->
                {ok, Body} = hackney:body(ClientRef),
                #{<<"data">> := Data} = jiffy:decode(Body, [return_maps]),
                #{<<"online_notice">> := OnlineNotice, <<"limit_charge">> := LimitCharge,
                    <<"reduce_gain">> := ReduceGain, <<"id_card">> := IdCard,
                    <<"charge">> := Charge} = Data;
            Ret ->
                ?error("realname error ~p, ~p", [URL, Ret]),
                OnlineNotice = LimitCharge = ReduceGain = false,
                IdCard = <<>>,
                Charge = 0
        end,

        role:route(RoleSt#role_st.role, ?MODULE, call_back,
            {Tos, OnlineNotice, LimitCharge, ReduceGain, ut_conv:to_list(IdCard), Charge})
    end);

handle(?REALNAME_REGISTER, Tos, RoleSt) ->
    register_data(Tos, RoleSt);

handle(?REALNAME_CANCEL, _Tos, RoleSt) ->
    Realname = info(),
    if
        Realname#r_realname.state == ?WAIT ->
            save(Realname#r_realname{state=?DENY}),
            check_need_kickout(),
            process_reduce_gain(RoleSt);
        true ->
            ignore
    end,
    ?ucast(#m_realname_cancel_toc{}).

-ifdef(DEBUG).

register_data(Tos, RoleSt) ->
    #m_realname_register_tos{area_code=AreaCode,
        id_card=IdCard, real_name=RealName} = Tos,
    #role_st{user=#game_user{gamechan=GameChan, account=Account}} = RoleSt,
    Sign2 = ut_str:md5(lists:concat([GameChan, Account, AreaCode, IdCard, RealName, game_env:get_admin_key()])),
    URL2 = ut_conv:to_binary(lists:concat([game_env:get_admin_host(),
        "/api/role/real_name/register?game_channel_id=", GameChan, "&account=", Account,
        "&area_code=", AreaCode, "&id_card=", IdCard, "&real_name=", RealName, "&sign=", Sign2])),
    hackney:request(get, URL2, [], <<>>, []),

    Realname = #r_realname{
        status       = ?NEVER,
        is_registerd = true,
        age          = age(IdCard),
        is_adult     = is_adult(IdCard),
        id_card      = IdCard,
        real_name    = RealName,
        state        = ?AUTH
    },
    save(Realname),
    process_reduce_gain(RoleSt),
    ?ucast(#m_realname_register_toc{succ = true, msg = "", is_adult=is_adult(IdCard), age=age(IdCard)}).

-else.

register_data(Tos, RoleSt) ->
    #m_realname_register_tos{game_id=GameID, channel_id=ChannelID,
        area_code=AreaCode, id_card=IdCard, real_name=RealName} = Tos,
    #role_st{user=#game_user{gamechan=GameChan, account=Account}} = RoleSt,
    Param = lists:concat(["area_code=", AreaCode,
        "&channel_id=", ChannelID, "&game_channel_id=", GameChan,
        "&game_id=", GameID, "&id_card=", IdCard,
        "&real_name=", RealName,
        "&user_id=", Account]),
    AppSecret = sdk:secret(),
    ?debug("Param----------:~p", [Param]),
    ?debug("AppSecret----------:~p", [AppSecret]),
    Sign = ut_str:md5(Param ++ "&" ++ AppSecret),
    ?debug("Sign----------:~p", [Sign]),
    URL = ut_conv:to_binary("http://agent.ijunhai.com/user/authUserCertification?" ++ Param ++ "&sign=" ++ Sign),
    ?debug("URL----------:~p", [URL]),
    {ok, StatusCode, _, ClientRef} = hackney:request(get, URL, [], <<>>, []),
    case StatusCode of
        200 ->
            {ok, Body} = hackney:body(ClientRef),
            #{<<"ret">> := Ret, <<"msg">> := Msg} = jiffy:decode(Body, [return_maps]),
            ?debug("realname auth ret: ~p, msg: ~p", [Ret, Msg]),
            case Ret of
                <<"1">> ->
                    Sign2 = ut_str:md5(lists:concat([GameChan, Account, AreaCode, IdCard, RealName, game_env:get_admin_key()])),
                    URL2 = ut_conv:to_binary(lists:concat([game_env:get_admin_host(),
                        "/api/role/real_name/register?game_channel_id=", GameChan, "&account=", Account,
                        "&area_code=", AreaCode, "&id_card=", IdCard, "&real_name=", RealName, "&sign=", Sign2])),
                    hackney:request(get, URL2, [], <<>>, []),
                    Realname = #r_realname{
                        status       = ?NEVER,
                        is_registerd = true,
                        age          = age(IdCard),
                        is_adult     = is_adult(IdCard),
                        id_card      = IdCard,
                        real_name    = RealName,
                        state        = ?AUTH
                    },
                    save(Realname),
                    process_reduce_gain(RoleSt);
                _ ->
                    ignore
            end,
            ?ucast(#m_realname_register_toc{succ = (Ret == <<"1">>), msg = Msg, is_adult=is_adult(IdCard), age=age(IdCard)});
        _ ->
            ?error("junhai realname api error ~w", [StatusCode]),
            ?ucast(#m_realname_register_toc{succ = false, msg = <<"认证接口繁忙"/utf8>>, is_adult=false, age=0})
    end.

-endif.

call_back({Tos, OnlineNotice, LimitCharge, ReduceGain, IdCard, Charge}, RoleSt) ->
    Realname = update_realname(Tos, IdCard),
    save_switch(OnlineNotice, LimitCharge, ReduceGain),
    % 开防沉迷才返回数据
    case OnlineNotice orelse LimitCharge orelse ReduceGain of
        true when Realname#r_realname.status =/= ?REALIZED ->
            process_reduce_gain(RoleSt),
            ?ucast(#m_realname_info_toc{
                online_notice = OnlineNotice,
                limit_charge  = LimitCharge,
                reduce_gain   = ReduceGain,
                is_registerd  = Realname#r_realname.is_registerd,
                age           = Realname#r_realname.age,
                is_adult      = Realname#r_realname.is_adult,
                online_time   = online_server:get_today_time(RoleSt#role_st.role),
                charge        = Charge,
                online_time2  = online_server:get_total_time(RoleSt#role_st.role)
            });
        _ ->
            ignore
    end.

hook_reset(_RoleSt) ->
    check_need_kickout().

kickout(_Ref, _RoleSt) ->
    role_agent:kickgame(self(), [], ?ERR_GAME_KICKOUT_FCM2).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
save(Realname) ->
    erlang:put({?MODULE, realname}, Realname).

info() ->
    erlang:get({?MODULE, realname}).

save_switch(OnlineNotice, LimitCharge, ReduceGain) ->
    erlang:put({?MODULE, online_notice}, OnlineNotice),
    erlang:put({?MODULE, limit_charge}, LimitCharge),
    erlang:put({?MODULE, reduce_gain}, ReduceGain).

is_reduce_gain() ->
    case erlang:get({?MODULE, reduce_gain}) of
        ?nil -> false;
        Bool ->
            case info() of
                #r_realname{is_adult=IsAdult, state=State} ->
                    % 等待验证期间暂不执行防沉迷
                    if
                        IsAdult -> false;
                        State == ?WAIT -> false;
                        true -> Bool
                    end;
                _ ->
                    false
            end
    end.

update_realname(Tos, IdCard) ->
    #m_realname_info_tos{status=Status} = Tos,
    Realname = case Status of
        ?OK ->
            #r_realname{
                status       = Status,
                is_registerd = Tos#m_realname_info_tos.is_registerd,
                age          = Tos#m_realname_info_tos.age,
                is_adult     = Tos#m_realname_info_tos.is_adult,
                id_card      = Tos#m_realname_info_tos.id_card,
                real_name    = Tos#m_realname_info_tos.real_name,
                state        = ?AUTH
            };
        ?UNKNOWN ->
            #r_realname{
                status       = Status,
                is_registerd = false,
                age          = 1,
                is_adult     = false,
                id_card      = "",
                real_name    = "",
                state        = ?AUTH
            };
        ?NEVER ->
            #r_realname{
                status       = Status,
                is_registerd = IdCard =/= "",
                age          = age(IdCard),
                is_adult     = is_adult(IdCard),
                id_card      = IdCard,
                real_name    = "",
                state        = ?_if(IdCard =/= "", ?AUTH, ?WAIT)
            };
        ?REALIZED ->
            #r_realname{
                status       = Status,
                is_registerd = false,
                age          = 1,
                is_adult     = false,
                id_card      = "",
                real_name    = "",
                state        = ?AUTH
            }
    end,
    save(Realname),
    Realname.

% 220822 19950529 7334
parse_idcard(IdCard) when length(IdCard) == 15 ->
    Year  = ut_conv:to_integer("19" ++ string:slice(IdCard, 6, 2)),
    Month = ut_conv:to_integer(string:slice(IdCard, 8, 2)),
    Day   = ut_conv:to_integer(string:slice(IdCard, 10, 2)),
    {Year, Month, Day};
parse_idcard(IdCard) when length(IdCard) == 18 ->
    Year  = ut_conv:to_integer(string:slice(IdCard, 6, 4)),
    Month = ut_conv:to_integer(string:slice(IdCard, 10, 2)),
    Day   = ut_conv:to_integer(string:slice(IdCard, 12, 2)),
    {Year, Month, Day};
parse_idcard(_IdCard) ->
    ut_time:date().

age(IdCard) ->
   {Year, _Month, _Day} = parse_idcard(IdCard),
   {ToYear, _, _} = ut_time:date(),
   max(0, ToYear - Year).

is_adult(IdCard) ->
    age(IdCard) >= 18.

process_reduce_gain(RoleSt) ->
    case is_reduce_gain() of
        true ->
            judge_add_buff(RoleSt);
        false ->
            del_buf(RoleSt)
    end,
    check_need_kickout().

judge_add_buff(RoleSt) ->
    del_buf(RoleSt),
    #r_realname{is_adult=IsAdult, state=State} = info(),
    case not IsAdult andalso State =/= ?WAIT of
        true ->
            OnlineTime = online_server:get_today_time(RoleSt#role_st.role),
            Now = ut_time:seconds(),
            case Now + reduce_timeout() - OnlineTime of
                ETime when ETime > Now ->
                    role_timer:add_task({RoleSt#role_st.role, ?MODULE}, ETime-Now, ?MODULE, kickout);
                    % buff:add([{cfg_game:realname_trigger_buff(), #{etime => ETime}}], RoleSt);
                _ ->
                    role_agent:kickgame(self(), [], ?ERR_GAME_KICKOUT_FCM2)
                    % Midnight = ut_time:datetime_to_seconds({ut_time:date(), {23,59,59}}),
                    % buff:add([{cfg_game:realname_decay_buff(), #{etime => Midnight}}], RoleSt)
            end;
        false ->
            ignore
    end.

del_buf(RoleSt) ->
    role_timer:del_task({RoleSt#role_st.role, ?MODULE}).
    % buff:del([cfg_game:realname_trigger_buff(), cfg_game:realname_decay_buff()], RoleSt).

reduce_timeout() ->
    Day = ut_time:day_of_week(),
    Timeout = case Day of
        6 -> 3*3600;
        7 -> 3*3600;
        _ -> 1.5*3600
    end,
    trunc(Timeout).

check_need_kickout() ->
    Realname = info(),
    case is_reduce_gain() andalso Realname#r_realname.state =/= ?WAIT of
        true ->
            {Hour, _, _} = ut_time:time(),
            case Hour >= 22 orelse Hour =< 8 of
                true ->
                    role_agent:kickgame(self(), [], ?ERR_GAME_KICKOUT_FCM);
                false ->
                    ignore
            end;
        false ->
            ignore
    end.
