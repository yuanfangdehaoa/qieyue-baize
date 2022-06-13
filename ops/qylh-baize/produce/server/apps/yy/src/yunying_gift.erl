%% @author rong
%% @doc
-module(yunying_gift).

-include("game.hrl").
-include("role.hrl").
-include("proto.hrl").
-include("yunying.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("msgno.hrl").

-export([handle/2, get/1, set/1]).

handle(#m_yunying_gift_tos{}, RoleSt) ->
    ActList = lists:map(fun(ActID) ->
        p_yy_gift(ActID)
    end, cfg_yunying_gift:all()),
    ?ucast(#m_yunying_gift_toc{list=ActList});

handle(#m_yunying_gift_fetch_tos{act_id=YYActID, id=RewardID}, RoleSt) ->
    #yy_gift{refund_time=RefundTime, state=State} = YYGift = ?MODULE:get(YYActID),
    case RewardID of
        1 ->
            ?_check(RefundTime == 0, ?ERR_YUNYING_NOT_REACH),
            ?_check(State == ?YY_TASK_STATE_UNDONE, ?ERR_YUNYING_NOT_REACH);
        2 ->
            ?_check(ut_time:seconds() >= RefundTime, ?ERR_YUNYING_NOT_REACH),
            ?_check(State == ?YY_TASK_STATE_REWARD, ?ERR_YUNYING_NOT_REACH)
    end,
    Mod = yunying_util:cfg_reward_mod(YYActID),
    #cfg_yunying_reward{reqs=Reqs, reward=Gain, cost=Cost} = Mod:find(YYActID, RewardID),
    check_reqs(Reqs, RoleSt),
    role_bag:deal(Cost, Gain, ?LOG_YUNYING_4, RoleSt),
    case RewardID of
        1 ->
            #cfg_yunying_gift{refund_time=RFTime, desc=Desc} = cfg_yunying_gift:find(YYActID),
            set(YYGift#yy_gift{state=?YY_TASK_STATE_REWARD, refund_time=ut_time:seconds()+RFTime}),
            #role_st{role=RoleID, name=RoleName} = RoleSt,
            ?notify(?MSG_YYGIFT_REWARD, [
                {role, RoleID, RoleName},
                {color, Desc, ?COLOR_GREEN}
            ]);
        2 ->
            set(YYGift#yy_gift{state=?YY_TASK_STATE_REFUND, refund_time=0})
    end,
    ?ucast(#m_yunying_gift_fetch_toc{
        gift = p_yy_gift(YYActID)
    }).

get(ActID) ->
    #role_yy_gift{list=List} = role_data:get(?DB_ROLE_YY_GIFT),
    maps:get(ActID, List, #yy_gift{id=ActID, refund_time=0, state=?YY_TASK_STATE_UNDONE}).

set(YYGift) ->
    #role_yy_gift{list=List} = RoleGift = role_data:get(?DB_ROLE_YY_GIFT),
    List2 = maps:put(YYGift#yy_gift.id, YYGift, List),
    role_data:set(RoleGift#role_yy_gift{list=List2}).

p_yy_gift(ActID) ->
    #cfg_yunying_gift{cycle=Cycle, days=DayList, time=TimeList} = cfg_yunying_gift:find(ActID),
    TimeList2 = [{T1, T2, T2} || {T1, T2} <- TimeList],
    case ut_activity:schedule(Cycle, DayList, TimeList2) of
        {ok, ActSTime0, ActETime0} ->
            ActSTime = ut_time:datetime_to_seconds(ActSTime0),
            ActETime = ut_time:datetime_to_seconds(ActETime0);
        _ ->
            ActSTime = 0, ActETime = 0
    end,
    #yy_gift{refund_time=RefundTime, state=State} = yunying_gift:get(ActID),
    #p_yy_gift{
        act_id      = ActID,
        stime       = ActSTime,
        etime       = ActETime,
        refund_time = RefundTime,
        state       = State
    }.

check_reqs([{level, Lv}|T], RoleSt) ->
    #role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
    ?_check(Level >= Lv, ?ERR_YUNYING_NOT_REACH),
    check_reqs(T, RoleSt);
check_reqs([], _RoleSt) ->
    ok.
