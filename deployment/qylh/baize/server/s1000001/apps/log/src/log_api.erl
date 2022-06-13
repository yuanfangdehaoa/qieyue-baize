%% @author rong
%% @doc
-module(log_api).

-include("logarch.hrl").
-include("table.hrl").
-include("game.hrl").
-include("enum.hrl").
-include("role.hrl").
-include("item.hrl").
-include("task.hrl").
-include("mail.hrl").
-include("proto.hrl").
-include("ranking.hrl").
-include("boss.hrl").
-include("scene.hrl").
-include("attr.hrl").
-include("pay.hrl").

-export([create_role/3, login/4, logout/3, update_role/1, levelup/4]).
-export([log_deal/4, log_task/2, item_monitor/2, upload_exception/3]).
-export([chat/3, mall_buy/5, log_online_num/1, mail/2, update_online_time/1]).
-export([log_rank/2, log_device/2, log_boss_dead/2]).
-export([log_activity/3, log_dunge/5, plat_stat/4, log_market/3]).
-export([log_equip/1,log_power/4]).
-export([log_market_exception/4]).

-define(ITEM_LIST,[?ITEM_ARENA_MONEY]).

create_role(RoleInfo, RoleVip, GameUser) ->
    Msg = jiffy:encode(
        #{
            <<"tab">>  => <<"role_infos">>,
            <<"ver">>  => <<"create_role_v2">>,
            <<"act">>  => <<"U">>,
            <<"data">> => #{
                <<"role_id">>  => RoleInfo#role_info.id,
                <<"name">>     => RoleInfo#role_info.name,
                <<"gcid">>     => GameUser#game_user.gamechan,
                <<"account">>  => GameUser#game_user.account,
                <<"pid">>      => game_env:get_pid(),
                <<"sid">>      => game_env:get_suid(),
                <<"career">>   => RoleInfo#role_info.career,
                <<"gender">>   => RoleInfo#role_info.gender,
                <<"level">>    => RoleInfo#role_info.level,
                <<"viplv">>    => RoleVip#role_vip.level,
                <<"guild_id">> => 0,
                <<"wake">>     => RoleInfo#role_info.wake,
                <<"charm">>    => RoleInfo#role_info.charm,
                <<"crime">>    => RoleInfo#role_info.crime,
                <<"ctime">>    => format_datetime(RoleInfo#role_info.ctime),
                <<"zoneid">>   => RoleInfo#role_info.zoneid
            }
        }),
    log_server:log(?DATA_QUEUE, Msg),
    web_request:async_get("/api/role/create_role_churn_rate", #{
        "account"  => GameUser#game_user.account,
        "gcid"     => GameUser#game_user.gamechan,
        "progress" => 1
    }).

login(RoleID, IP, LoginTime, ReasonCode) ->
    Msg = jiffy:encode(
        #{
            <<"tab">>  => <<"role_infos">>,
            <<"ver">>  => <<"login_v1">>,
            <<"act">>  => <<"U">>,
            <<"data">> => #{
                <<"role_id">> => RoleID,
                <<"login">>   => format_datetime(LoginTime),
                <<"ip_addr">> => ut_conv:to_binary(inet_parse:ntoa(IP))
            }
        }),
    log_server:log(?DATA_QUEUE, Msg),
    log_login_logout(RoleID, LoginTime, IP, ReasonCode).

logout(RoleID, IP, ReasonCode) ->
    Msg = jiffy:encode(
        #{
            <<"tab">>  => <<"role_infos">>,
            <<"ver">>  => <<"logout_v1">>,
            <<"act">>  => <<"U">>,
            <<"data">> => #{
                <<"role_id">> => RoleID,
                <<"logout">>  => format_datetime(ut_time:seconds())
            }
        }),
    log_server:log(?DATA_QUEUE, Msg),
    log_login_logout(RoleID, ut_time:seconds(), IP, ReasonCode).

log_equip(RoleSt) ->
    #role_info{name=Name, level=Level, suid=SUID} = role_data:get(?DB_ROLE_INFO),
    case Level >= 100 of
        true ->
            Tab = log_util:week_tag(<<"equip_logs">>),
            #role_equip{equips = Equips} = role_data:get(?DB_ROLE_EQUIP),
            Items = maps:fold(fun
                (Slot, CellId, Acc) ->
                    {ok, Item} = role_bag:get_item(CellId),
                    SlotBin = ut_conv:to_binary(Slot),
                    maps:put(SlotBin, Item#p_item.id, Acc)
            end, #{}, Equips),
            Log = #{
                <<"tab">>  => Tab,
                <<"ver">>  => <<Tab/binary, "_v1">>,
                <<"act">>  => <<"U">>,
                <<"data">> => #{
                    <<"pid">>      => game_env:get_pid(),
                    <<"sid">>      => SUID,
                    <<"role_id">>  => RoleSt#role_st.role,
                    <<"name">>     => Name,
                    <<"level">>    => Level,
                    <<"power">>    => role_util:get_power(),
                    <<"equip">>    => Items,
                    <<"log_date">> => ut_time:date_to_string(ut_time:date())
                }
            },
            log_server:log(?LOGS_QUEUE, jiffy:encode(Log));
        false ->
            ignore
    end.

log_power(RoleSt,ChangePowerMod,OldPower,NewPower) ->
    Tab = log_util:week_tag(<<"power_logs">>),
    Log = #{
        <<"tab">>  => Tab,
        <<"ver">>  => <<Tab/binary, "_v1">>,
        <<"act">>  => <<"U">>,
        <<"data">> => #{
            <<"role_id">>  => RoleSt#role_st.role,
            <<"pid">>      => game_env:get_pid(),
            <<"sid">>      => game_env:get_suid(),
            <<"old_power">>    => OldPower,
            <<"new_power">> => NewPower,
            <<"change_power">> => ut_conv:to_binary(NewPower - OldPower),
            <<"change_mod">> => ut_conv:term_to_bitstring(ChangePowerMod),
            <<"log_time">> => format_datetime(ut_time:seconds())
        }
    },
    log_server:log(?LOGS_QUEUE, jiffy:encode(Log)).

log_login_logout(RoleID, Time, IP, ReasonCode) ->
    {ok, #role_cache{level=Level}} = role:get_cache(RoleID),
    Tab = log_util:month_tag(<<"login_logout_logs">>),
    Msg = jiffy:encode(
        #{
            <<"tab">>  => Tab,
            <<"ver">>  => <<Tab/binary, "_v2">>,
            <<"data">> => #{
                <<"role_id">>  => RoleID,
                <<"pid">>      => game_env:get_pid(),
                <<"sid">>      => game_env:get_suid(),
                <<"level">>    => Level,
                <<"log_time">> => format_datetime(Time),
                <<"ip_addr">>  => ut_conv:to_binary(inet_parse:ntoa(IP)),
                <<"reason">>   => ReasonCode
            }
        }
    ),
    log_server:log(?LOGS_QUEUE, Msg).

update_role(RoleSt) ->
    #role_st{user=GameUser, scene=SceneID} = RoleSt,
    RoleInfo = role_data:get(?DB_ROLE_INFO),
    RoleVip = role_data:get(?DB_ROLE_VIP),
    RoleGuild = role_data:get(?DB_ROLE_GUILD),
    #role_pay{payments=Payments} = role_data:get(?DB_ROLE_PAY),
    Total = lists:sum([P#payment.total_fee || P <- Payments , P#payment.app_order =/= P#payment.sdk_order]),
    Msg = jiffy:encode(
        #{
            <<"tab">>  => <<"role_infos">>,
            <<"ver">>  => <<"update_role_v2">>,
            <<"act">>  => <<"U">>,
            <<"data">> => #{
                <<"role_id">>  => RoleInfo#role_info.id,
                <<"name">>     => RoleInfo#role_info.name,
                <<"gcid">>     => GameUser#game_user.gamechan,
                <<"account">>  => GameUser#game_user.account,
                <<"pid">>      => game_env:get_pid(),
                <<"sid">>      => RoleInfo#role_info.suid,
                <<"career">>   => RoleInfo#role_info.career,
                <<"gender">>   => RoleInfo#role_info.gender,
                <<"level">>    => RoleInfo#role_info.level,
                <<"viplv">>    => RoleVip#role_vip.level,
                <<"guild_id">> => RoleGuild#role_guild.guild,
                <<"wake">>     => RoleInfo#role_info.wake,
                <<"charm">>    => RoleInfo#role_info.charm,
                <<"crime">>    => RoleInfo#role_info.crime,
                <<"scene">>    => SceneID,
                <<"power">>    => role_util:get_power(),
                <<"zoneid">>   => RoleInfo#role_info.zoneid,
                <<"fee">>      => Total
            }
        }),
    log_server:log(?DATA_QUEUE, Msg).

log_deal(Spend, Obtain, LogType, RoleSt) ->
    log_deal_1(cost, Spend, LogType, RoleSt),
    log_deal_1(gain, Obtain, LogType, RoleSt),
    #role_st{user=User, ip=IP, sdk=SDKArgs} = RoleSt,
    log_junhai:log_trade(User, IP, SDKArgs, {LogType,Spend,Obtain}),
    ok.

log_deal_1(Type, Items, LogType, RoleSt) ->
    LogTime = format_datetime(ut_time:datetime()),
    #role_vip{level=VipLv} = role_data:get(?DB_ROLE_VIP),
    [begin
        Num = case Type of
            cost -> -Num0;
            gain -> Num0
        end,
        Log = case ItemID of
            ?ITEM_GOLD ->
                log_gold(0, Num, LogType, LogTime, VipLv, RoleSt);
            ?ITEM_BGOLD ->
                log_gold(Num, 0, LogType, LogTime, VipLv, RoleSt);
            ?ITEM_COIN ->
                log_coin(0, Num, LogType, LogTime, VipLv, RoleSt);
            ?ITEM_BCOIN ->
                log_coin(Num, 0, LogType, LogTime, VipLv, RoleSt);
            _ ->
                case cfg_item:find(ItemID) of
                    #cfg_item{type=ItemType} when ItemType /= 9 ->
                        log_item(ItemID, Num, LogType, LogTime, VipLv, RoleSt);
                    _ ->
                        ?nil
                end
        end,
        Log =/= ?nil andalso log_server:log(?LOGS_QUEUE, jiffy:encode(Log))
    end || {ItemID, Num0} <- maps:to_list(Items)].

log_gold(Bind, Unbind, LogType, LogTime, VipLv, RoleSt) ->
    RemUnbind = role_bag:get_money(?ITEM_GOLD),
    RemBind   = role_bag:get_money(?ITEM_BGOLD),
    RoleInfo  = role_data:get(?DB_ROLE_INFO),
    Tab = log_util:week_tag(<<"gold_logs">>),
    #{
        <<"tab">>  => Tab,
        <<"ver">>  => <<Tab/binary, "_v1">>,
        <<"data">> => #{
            <<"role_id">>    => RoleSt#role_st.role,
            <<"pid">>        => game_env:get_pid(),
            <<"sid">>        => RoleInfo#role_info.suid,
            <<"viplv">>      => VipLv,
            <<"bind">>       => Bind,
            <<"unbind">>     => Unbind,
            <<"rem_bind">>   => RemBind,
            <<"rem_unbind">> => RemUnbind,
            <<"log_type">>   => LogType,
            <<"log_time">>   => LogTime
        }
    }.

log_coin(Bind, Unbind, LogType, LogTime, VipLv, RoleSt) ->
    RemUnbind = role_bag:get_money(?ITEM_COIN),
    RemBind   = role_bag:get_money(?ITEM_BCOIN),
    RoleInfo  = role_data:get(?DB_ROLE_INFO),
    Tab = log_util:week_tag(<<"coin_logs">>),
    #{
        <<"tab">>  => Tab,
        <<"ver">>  => <<Tab/binary, "_v1">>,
        <<"data">> => #{
            <<"role_id">>    => RoleSt#role_st.role,
            <<"pid">>        => game_env:get_pid(),
            <<"sid">>        => RoleInfo#role_info.suid,
            <<"viplv">>      => VipLv,
            <<"bind">>       => Bind,
            <<"unbind">>     => Unbind,
            <<"rem_bind">>   => RemBind,
            <<"rem_unbind">> => RemUnbind,
            <<"log_type">>   => LogType,
            <<"log_time">>   => LogTime
        }
    }.

log_item(ItemID, Num, LogType, LogTime, VipLv, RoleSt) ->
    RoleInfo = role_data:get(?DB_ROLE_INFO),
    Tab = log_util:week_tag(<<"item_logs">>),
    #{
        <<"tab">>  => Tab,
        <<"ver">>  => <<Tab/binary, "_v1">>,
        <<"data">> => #{
            <<"role_id">>  => RoleSt#role_st.role,
            <<"pid">>      => game_env:get_pid(),
            <<"sid">>      => RoleInfo#role_info.suid,
            <<"viplv">>    => VipLv,
            <<"item_id">>  => ItemID,
            <<"num">>      => Num,
            <<"log_type">> => LogType,
            <<"log_time">> => LogTime
        }
    }.

% 玩家升级
levelup(Level, Exp, LogType, RoleSt) ->
    RoleInfo = role_data:get(?DB_ROLE_INFO),
    LogTime  = format_datetime(ut_time:datetime()),
    Tab = log_util:month_tag(<<"level_logs">>),
    Log = #{
        <<"tab">>  => Tab,
        <<"ver">>  => <<Tab/binary, "_v1">>,
        <<"data">> => #{
            <<"role_id">>  => RoleSt#role_st.role,
            <<"pid">>      => game_env:get_pid(),
            <<"sid">>      => RoleInfo#role_info.suid,
            <<"level">>    => Level,
            <<"exp">>      => Exp,
            <<"log_type">> => LogType,
            <<"log_time">> => LogTime
        }
    },
    log_server:log(?LOGS_QUEUE, jiffy:encode(Log)).

log_task(TaskID, State) ->
    #role_info{id=RoleID, suid=SUID} = role_data:get(?DB_ROLE_INFO),
    LogTime = format_datetime(ut_time:datetime()),
    #cfg_task{type=Type} = cfg_task:find(TaskID),
    case not lists:member(Type, [?TASK_TYPE_LOOP1, ?TASK_TYPE_LOOP2,
        ?TASK_TYPE_PREV1, ?TASK_TYPE_PREV2]) of
        true ->
            Tab = log_util:week_tag(<<"task_logs">>),
            Log = #{
                <<"tab">>  => Tab,
                <<"ver">>  => <<Tab/binary, "_v1">>,
                <<"data">> => #{
                    <<"role_id">>  => RoleID,
                    <<"pid">>      => game_env:get_pid(),
                    <<"sid">>      => SUID,
                    <<"task_id">>  => TaskID,
                    <<"type">>     => Type,
                    <<"state">>    => State,
                    <<"log_time">> => LogTime
                }
            },
            log_server:log(?LOGS_QUEUE, jiffy:encode(Log));
        false ->
            ignore
    end.

item_monitor([], _RoleSt) ->
    ignore;
item_monitor(Alert, RoleSt) ->
    #role_monitor{gain=Gains} = role_data:get(?DB_ROLE_MONITOR),
    #role_info{suid=SUID} = role_data:get(?DB_ROLE_INFO),
    [case maps:find(RuleID, Gains) of
        {ok, {ItemID, StartDT, EndDT, Num}} ->
            Log = #{
                <<"tab">>  => <<"item_monitors">>,
                <<"ver">>  => <<"item_monitor_v1">>,
                <<"act">>  => <<"U">>,
                <<"data">> => #{
                    <<"role_id">>    => RoleSt#role_st.role,
                    <<"pid">>        => game_env:get_pid(),
                    <<"sid">>        => SUID,
                    <<"rule_id">>    => RuleID,
                    <<"start_time">> => format_datetime(StartDT),
                    <<"end_time">>   => format_datetime(EndDT),
                    <<"item_id">>    => ItemID,
                    <<"num">>        => Num,
                    <<"log_time">>   => format_datetime(ut_time:datetime())
                }
            },
            log_server:log(?DATA_QUEUE, jiffy:encode(Log));
        _ ->
            ignore
    end || RuleID <- Alert].

upload_exception(Exception, LogType, RoleSt) ->
    case maps:size(Exception) > 0 of
        true ->
            LogTime  = format_datetime(ut_time:datetime()),
            RoleInfo = role_data:get(?DB_ROLE_INFO),
            [begin
                ?error("log ~w ~w", [ItemID, Num]),
                Log = #{
                    <<"tab">>  => <<"item_exception_logs">>,
                    <<"ver">>  => <<"item_exception_v1">>,
                    <<"data">> => #{
                        <<"role_id">>  => RoleSt#role_st.role,
                        <<"pid">>      => game_env:get_pid(),
                        <<"sid">>      => RoleInfo#role_info.suid,
                        <<"item_id">>  => ItemID,
                        <<"num">>      => Num,
                        <<"log_type">> => LogType,
                        <<"log_time">> => LogTime
                    }
                },
                log_server:log(?DATA_QUEUE, jiffy:encode(Log))
            end || {ItemID, Num} <- maps:to_list(Exception)];
        false ->
            ignore
    end.

chat(ChannelId, Content, RoleSt) ->
    case sdk:route() of
        {junhai, _} ->
            RoleInfo = role_data:get(?DB_ROLE_INFO),
            RoleVip = role_data:get(?DB_ROLE_VIP),
            Tab = log_util:week_tag(<<"chat_logs">>),
            Log = #{
                <<"tab">>  => Tab,
                <<"ver">>  => <<Tab/binary , "_v1">>,
                <<"data">> => #{
                    <<"role_id">>   => RoleSt#role_st.role,
                    <<"pid">>       => game_env:get_pid(),
                    <<"sid">>       => game_env:get_suid(),
                    <<"name">>      => RoleInfo#role_info.name,
                    <<"level">>     => RoleInfo#role_info.level,
                    <<"viplv">>     => RoleVip#role_vip.level,
                    <<"channel">>   => ChannelId,
                    <<"content">>   => ut_conv:to_binary(Content),
                    <<"log_time">>  => format_datetime(ut_time:datetime())
                }
            },
            log_server:log(?LOGS_QUEUE, jiffy:encode(Log));
        _ ->
            ignore
    end.

mall_buy(MallType, MallID, Num, Cost, RoleSt) ->
    RoleVip  = role_data:get(?DB_ROLE_VIP),
    RoleInfo = role_data:get(?DB_ROLE_INFO),
    {A,B} = MallType,
    Tab = log_util:month_tag(<<"mall_logs">>),
    Log = #{
        <<"tab">>  => Tab,
        <<"ver">>  => <<Tab/binary, "_v1">>,
        <<"data">> => #{
            <<"role_id">>   => RoleSt#role_st.role,
            <<"pid">>       => game_env:get_pid(),
            <<"sid">>       => RoleInfo#role_info.suid,
            <<"viplv">>     => RoleVip#role_vip.level,
            <<"mall_type">> => lists:concat([A,",",B]),
            <<"item_id">>   => MallID,
            <<"num">>       => Num,
            <<"cost_type">> => element(1, hd(Cost)),
            <<"cost_num">>  => element(2, hd(Cost)),
            <<"log_time">>  => format_datetime(ut_time:datetime())
        }
    },
    log_server:log(?LOGS_QUEUE, jiffy:encode(Log)).

log_online_num(Num) ->
    Tab = log_util:month_tag(<<"online_logs">>),
    {Date, {H, M, _}} = ut_time:datetime(),
    Log = #{
        <<"tab">>  => Tab,
        <<"ver">>  => <<Tab/binary, "_v1">>,
        <<"data">> => #{
            <<"pid">>      => game_env:get_pid(),
            <<"sid">>      => game_env:get_suid(),
            <<"num">>      => Num,
            <<"log_time">> => format_datetime({Date, {H, M, 0}})
        }
    },
    log_server:log(?LOGS_QUEUE, jiffy:encode(Log)).

mail(RoleID, Mail) ->
    {ok, #role_cache{suid=SUID}} = role:get_cache(RoleID),
    Tab = log_util:week_tag(<<"mail_logs">>),
    Log = #{
        <<"tab">>  => Tab,
        <<"ver">>  => <<Tab/binary, "_v1">>,
        <<"data">> => #{
            <<"pid">>      => game_env:get_pid(),
            <<"sid">>      => SUID,
            <<"receiver">> => RoleID,
            <<"mail_id">>  => Mail#mail.id,
            <<"sender">>   => Mail#mail.from,
            <<"type">>     => Mail#mail.type,
            <<"title">>    => Mail#mail.title,
            <<"content">>  => Mail#mail.text,
            <<"attach">>   => format_attach(Mail#mail.items ++ maps:to_list(Mail#mail.money)),
            <<"log_time">> => format_datetime(Mail#mail.send)
        }
    },
    log_server:log(?LOGS_QUEUE, jiffy:encode(Log)).

update_online_time(#role_st{role=RoleID}) ->
    RoleInfo = role_data:get(?DB_ROLE_INFO),
    Num = online_server:get_today_time(RoleID),
    case Num > 0 of
        true ->
            Tab = log_util:month_tag(<<"online_time_logs">>),
            Log = #{
                <<"tab">>  => Tab,
                <<"ver">>  => <<Tab/binary, "_v1">>,
                <<"act">>  => <<"U">>,
                <<"data">> => #{
                    <<"pid">>      => game_env:get_pid(),
                    <<"sid">>      => RoleInfo#role_info.suid,
                    <<"role_id">>  => RoleID,
                    <<"log_date">> => ut_time:date_to_string(ut_time:date()),
                    <<"num">>      => Num
                }
            },
            log_server:log(?LOGS_QUEUE, jiffy:encode(Log));
        false ->
            ignore
    end.

log_rank(RankID, RankList) ->
    NeedList = [1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 2012],
    case lists:member(RankID, NeedList) of
        true ->
            LogDate = ut_time:yesterday(),
            Tab = log_util:month_tag(LogDate, <<"rank_logs">>),
            [begin
                {ok, #role_cache{level=Level}} = role:get_cache(RankItem#rankitem.id),
                Log = #{
                    <<"tab">>  => Tab,
                    <<"ver">>  => <<Tab/binary, "_v1">>,
                    <<"act">>  => <<"U">>,
                    <<"data">> => #{
                        <<"pid">>      => game_env:get_pid(),
                        <<"sid">>      => game_env:get_suid(),
                        <<"rank_id">>  => RankID,
                        <<"item_id">>  => RankItem#rankitem.id,
                        <<"log_date">> => ut_time:date_to_string(LogDate),
                        <<"rank">>     => RankItem#rankitem.rank,
                        <<"sort">>     => RankItem#rankitem.sort,
                        <<"meta">>     => #{<<"level">> => Level}
                    }
                },
                log_server:log(?LOGS_QUEUE, jiffy:encode(Log))
            end || RankItem <- RankList];
        false ->
            ignore
    end.

log_device(RoleID, SDKArgs) ->
    Msg = jiffy:encode(
        #{
            <<"tab">>  => <<"role_devices">>,
            <<"ver">>  => <<"log_device_v1">>,
            <<"act">>  => <<"U">>,
            <<"data">> => #{
                <<"role_id">>       => RoleID,
                <<"pid">>           => game_env:get_pid(),
                <<"sid">>           => game_env:get_suid(),
                <<"device_name">>   => ut_conv:to_binary(maps:get("device_name", SDKArgs, "")),
                <<"os_type">>       => ut_conv:to_binary(maps:get("os_type", SDKArgs, "")),
                <<"net_type">>      => ut_conv:to_binary(maps:get("net_type", SDKArgs, "")),
                <<"os_ver">>        => ut_conv:to_binary(maps:get("os_ver", SDKArgs, "")),
                <<"ios_idfa">>      => ut_conv:to_binary(maps:get("ios_idfa", SDKArgs, "")),
                <<"android_imei">>  => ut_conv:to_binary(maps:get("android_imei", SDKArgs, "")),
                <<"package_name">>  => ut_conv:to_binary(maps:get("package_name", SDKArgs, "")),
                <<"screen_width">>  => maps:get("screen_width", SDKArgs, 0),
                <<"screen_height">> => maps:get("screen_height", SDKArgs, 0),
                <<"user_agent">>    => ut_conv:to_binary(maps:get("user_agent", SDKArgs, ""))
            }
        }),
    log_server:log(?DATA_QUEUE, Msg).

log_boss_dead(Killer, Defender) ->
    #actor{id=CreepID, rarity=Rarity, attr=Attr} = Defender,
    case cfg_boss:find(CreepID) of
        #cfg_boss{type=Type} when Rarity == ?CREEP_RARITY_BOSS ->
            MaxHp = ?_attr(Attr, ?ATTR_HPMAX, 1),
            JoinRoles0 = maps:get(join_roles, Defender#actor.exargs, #{}),
            JoinRoles = maps:filter(fun(_, DmgVal) ->
                DmgVal >= MaxHp*0.01
            end, JoinRoles0),
            Tab = log_util:month_tag(<<"boss_logs">>),
            UID = ut_time:milliseconds(),
            LogTime = format_datetime(ut_time:datetime()),
            Log = #{
                <<"tab">>  => Tab,
                <<"ver">>  => <<Tab/binary, "_v2">>,
                <<"data">> => #{
                    <<"pid">>         => game_env:get_pid(),
                    <<"sid">>         => game_env:get_suid(),
                    <<"boss_id">>     => CreepID,
                    <<"boss_type">>   => Type,
                    <<"boss_uid">>    => UID,
                    <<"role_id">>     => Killer#actor.uid,
                    <<"action">>      => 1,
                    <<"log_time">>    => LogTime
                }
            },
            log_server:log(?LOGS_QUEUE, jiffy:encode(Log)),
            [begin
                Log1 = #{
                    <<"tab">>  => Tab,
                    <<"ver">>  => <<Tab/binary, "_v2">>,
                    <<"data">> => #{
                        <<"pid">>         => game_env:get_pid(),
                        <<"sid">>         => game_env:get_suid(),
                        <<"boss_id">>     => CreepID,
                        <<"boss_type">>   => Type,
                        <<"boss_uid">>    => UID,
                        <<"role_id">>     => RoleID,
                        <<"action">>      => 2,
                        <<"log_time">>    => LogTime
                    }
                },
                log_server:log(?LOGS_QUEUE, jiffy:encode(Log1))
            end || RoleID <- maps:keys(JoinRoles)];
        _ ->
            ignore
    end.

log_activity(ActID, Online, Join) ->
    Msg = jiffy:encode(
        #{
            <<"tab">>  => <<"act_stats">>,
            <<"ver">>  => <<"act_stats_v1">>,
            <<"data">> => #{
                <<"pid">>      => game_env:get_pid(),
                <<"sid">>      => game_env:get_suid(),
                <<"act_id">>   => ActID,
                <<"online">>   => Online,
                <<"join_num">> => Join,
                <<"log_time">> => format_datetime(ut_time:datetime())
            }
        }),
    log_server:log(?DATA_QUEUE, Msg).

log_dunge(DungeID, SType, OpType, Num, RoleSt) ->
    RoleInfo = role_data:get(?DB_ROLE_INFO),
    Tab = log_util:week_tag(<<"dunge_logs">>),
    Log = #{
        <<"tab">>  => Tab,
        <<"ver">>  => <<Tab/binary, "_v1">>,
        <<"data">> => #{
            <<"role_id">>  => RoleSt#role_st.role,
            <<"pid">>      => game_env:get_pid(),
            <<"sid">>      => RoleInfo#role_info.suid,
            <<"dunge_id">> => DungeID,
            <<"stype">>    => SType,
            <<"op_type">>  => OpType,
            <<"num">>      => Num,
            <<"log_time">> => format_datetime(ut_time:datetime())
        }
    },
    log_server:log(?LOGS_QUEUE, jiffy:encode(Log)).

plat_stat(Type, OpType, Num, RoleSt) ->
    RoleInfo = role_data:get(?DB_ROLE_INFO),
    Tab = log_util:week_tag(<<"play_logs">>),
    Log = #{
        <<"tab">>  => Tab,
        <<"ver">>  => <<Tab/binary, "_v1">>,
        <<"data">> => #{
            <<"role_id">>  => RoleSt#role_st.role,
            <<"pid">>      => game_env:get_pid(),
            <<"sid">>      => RoleInfo#role_info.suid,
            <<"type">>     => Type,
            <<"op_type">>  => OpType,
            <<"num">>      => Num,
            <<"log_time">> => format_datetime(ut_time:datetime())
        }
    },
    log_server:log(?LOGS_QUEUE, jiffy:encode(Log)).

log_market(RoleID, Trade, Num) ->
    RoleInfo = role_data:get(?DB_ROLE_INFO),
    Tab = log_util:month_tag(<<"market_logs">>),
    Log = #{
        <<"tab">>  => Tab,
        <<"ver">>  => <<Tab/binary, "_v1">>,
        <<"data">> => #{
            <<"pid">>      => game_env:get_pid(),
            <<"sid">>      => RoleInfo#role_info.suid,
            <<"type">>     => Trade#trade.type,
            <<"buyer">>    => RoleID,
            <<"owner">>    => Trade#trade.owner,
            <<"item_id">>  => (Trade#trade.item)#p_item.id,
            <<"price">>    => Trade#trade.price,
            <<"num">>      => Num,
            <<"log_time">> => format_datetime(ut_time:datetime())
        }
    },
    log_server:log(?LOGS_QUEUE, jiffy:encode(Log)).

log_market_exception(RoleID, RoleName, Type, Amount) ->
    web_request:get("/api/server/market_monitor", #{
        "role_id" => RoleID,
        "name"    => RoleName,
        "type"    => Type,
        "amount"  => Amount
    }).
    % Tab = <<"market_monitor_logs">>,
    % Log = #{
    %     <<"tab">>  => Tab,
    %     <<"ver">>  => <<Tab/binary, "_v1">>,
    %     <<"data">> => #{
    %         <<"role_id">>  => RoleID,
    %         <<"name">>     => RoleName,
    %         <<"type">>     => Type,
    %         <<"amount">>   => Amount
    %     }
    % },
    % log_server:log(?LOGS_QUEUE, jiffy:encode(Log)).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
format_datetime(Seconds) when is_integer(Seconds) ->
    ut_conv:to_binary(ut_time:seconds_to_string(Seconds));
format_datetime(DateTime) ->
    ut_conv:to_binary(ut_time:datetime_to_string(DateTime)).

format_attach(Items) ->
    lists:map(fun
        ({Moeny, Num}) ->
            #{
                <<"item_id">> => Moeny,
                <<"num">>     => Num
            };
        (Item) ->
            #{
                <<"item_id">> => Item#p_item.id,
                <<"num">>     => Item#p_item.num,
                <<"bind">>    => Item#p_item.bind
            }
    end, Items).
