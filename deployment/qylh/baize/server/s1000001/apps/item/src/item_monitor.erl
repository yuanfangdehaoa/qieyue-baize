%% @author rong
%% @doc 监控道具产出
-module(item_monitor).

-include("table.hrl").
-include("item.hrl").
-include("role.hrl").
-include("bag.hrl").

-export([monitor/3]).

monitor(ItemID, Num, Deal) ->
    case cfg_item_monitor:monitor(ItemID) of
        Rules when length(Rules) > 0 ->
            lists:foldl(fun(RuleID, {AccRet, AccDeal}) ->
                % 当发现规则中有一条异常，即重置Deal，不给发放该道具
                case AccRet of
                    exception ->
                        {AccRet, AccDeal};
                    _ ->
                        {Ret, Deal2} = incr(RuleID, ItemID, Num, AccDeal),
                        case Ret of
                            exception -> {exception, Deal};
                            _ -> {Ret, Deal2}
                        end
                end
            end, {ok, Deal}, Rules);            
        _ ->
            {ok, Deal}
    end.

incr(RuleID, ItemID, Add, Deal) ->
    #deal{monitor=RoleMonitor, alert=Alert} = Deal,
    #role_monitor{gain=Gains} = RoleMonitor,
    #cfg_item_monitor{start_time=StartTime, end_time={Day, EndTime},
        alert=AlertNum, exception=ExceptionNum} = cfg_item_monitor:find(RuleID),
    StartDT = {ut_time:date(), StartTime},    
    EndDT = {ut_time:add_days(ut_time:date(), Day), EndTime},
    Now = ut_time:datetime(),
    case Now >= StartDT andalso Now =< EndDT of
        true ->
            OldNum = case maps:find(RuleID, Gains) of
                {ok, {ItemID, StartDT, EndDT, OldNumT}} ->
                    OldNumT;
                _ ->
                    0
            end,
            if
                OldNum >= ExceptionNum ->
                    {exception, Deal};
                true ->
                    Num = OldNum+Add,
                    Gains2 = maps:put(RuleID, {ItemID, StartDT, EndDT, Num}, Gains),
                    RoleMonitor2 = RoleMonitor#role_monitor{gain=Gains2},
                    Alert2 = if
                        Num >= AlertNum -> [RuleID|lists:delete(RuleID, Alert)];
                        true -> Alert
                    end,
                    {ok, Deal#deal{monitor=RoleMonitor2, alert=Alert2}}
            end;
        false ->
            {ok, Deal}
    end.
