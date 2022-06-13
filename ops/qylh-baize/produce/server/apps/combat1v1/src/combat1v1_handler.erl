%% @author rong
%% @doc
-module(combat1v1_handler).

-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("combat1v1.hrl").
-include("enum.hrl").
-include("table.hrl").
-include("log.hrl").
-include("activity.hrl").

-export([handle/3, battle_result/2]).
-export([match_succ/2]).

handle(?COMBAT1V1_INFO, _Tos, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    #combat1v1_role{grade=Grade, score=Score, merit=Merit,
        join_reward=JoinReward, today_merit=TodayMerit, last_grade=LastGrade,
        today_join=TodayJoin, merit_reward=MeritReward, buy_times=BuyTimes}
            = combat1v1_util:get_role(RoleID),
    DailyReward = if
        LastGrade == 0 -> ?REWARD_NONE;
        true ->
            case role_count:get_combat1v1_count(?COMBAT1V1_COUNT_DAILY_REWARD) of
                0 -> ?REWARD_CAN_FETCH;
                _ -> ?REWARD_ALREADY_FETCHED
            end
    end,
    Mode = combat1v1_util:mode(),
    LimitConf = combat1v1_util:limit_conf(),
    {_, End} = game_misc:read(?COMBAT1V1_MISC_SEASON),
    ?ucast(#m_combat1v1_info_toc{
        grade        = Grade,
        score        = Score,
        today_join   = TodayJoin,
        merit        = Merit,
        today_merit  = TodayMerit,
        join_reward  = JoinReward,
        last_grade   = LastGrade,
        daily_reward = DailyReward,
        merit_reward = MeritReward,
        mode         = ut_conv:to_list(Mode),
        remain_join  = max(0, LimitConf:max_free() - TodayJoin + BuyTimes),
        remain_buy   = max(0, LimitConf:max() - LimitConf:max_free() - BuyTimes),
        season_end   = ut_time:datetime_to_seconds({ut_time:add_days(End, -2), {0,0,0}})
    });

handle(?COMBAT1V1_MATCH_START, _Tos, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    ?_check(combat1v1_util:activity() =/= 0, ?ERR_SCENE_NO_ACTIVITY),
    #role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
    #cfg_activity{level=NeedLv} = cfg_activity:find(combat1v1_util:activity()),
    ?_check(Level >= NeedLv, ?ERR_COMBAT1V1_LV_NOT_ENOUGH),
    #combat1v1_role{grade=Grade, score=Score, join=Join,
        keep_lose=KeepLose, today_join=TodayJoin, buy_times=BuyTimes}
        = combat1v1_util:get_role(RoleID),
    Mode = combat1v1_util:mode(),
    LimitConf = combat1v1_util:limit_conf(),
    ?_check(TodayJoin < LimitConf:max_free() + BuyTimes, ?ERR_COMBAT1V1_MAX_JOIN),

    Power = role:get_power(RoleID),
    Rank = rank_server:get_rank(combat1v1_util:rank_id(), RoleID),
    MatchRole = #match_role{
        role_id    = RoleID,
        type       = ?ACTOR_TYPE_ROLE,
        grade      = Grade,
        score      = Score,
        power      = Power,
        level      = Level,
        mode       = Mode,
        rank       = Rank,
        today_join = TodayJoin+1,
        join       = Join,
        keep_lose  = KeepLose
    },
    ?ucast(#m_combat1v1_match_start_toc{}),
    ok = combat1v1_matcher:join(MatchRole);

handle(?COMBAT1V1_MATCH_CANCEL, _Tos, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    case erlang:get({?MODULE, timer}) of
        TimerRef when is_reference(TimerRef) ->
            erlang:cancel_timer(TimerRef);
        _ ->
            ignore
    end,
    combat1v1_matcher:cancel(RoleID),
    ?ucast(#m_combat1v1_match_cancel_toc{});

handle(?COMBAT1V1_BATTLE_PREPARE, _Tos, RoleSt) ->
    #role_st{spid=ScenePid, role=RoleID} = RoleSt,
    scene:route(ScenePid, combat1v1, prepare, RoleID);

handle(?COMBAT1V1_JOIN_REWARD, Tos, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    #m_combat1v1_join_reward_tos{num=Num} = Tos,
    JoinRewardConf = combat1v1_util:join_reward_conf(),
    Reward = JoinRewardConf:find(Num),
    ?_check(Reward =/= [], ?ERR_GAME_BAD_ARGS, [?COMBAT1V1_JOIN_REWARD]),
    #combat1v1_role{join_reward=JoinReward} = combat1v1_util:get_role(RoleID),
    case maps:find(Num, JoinReward) of
        {ok, false} ->
            ok = combat1v1_server:fetch_join_reward(RoleID, Num),
            role_bag:gain(Reward, ?LOG_COMBAT1V1_JOIN_REWARD, RoleSt),
            ?ucast(#m_combat1v1_join_reward_toc{num=Num});
        {ok, true} ->
            throw(?err(?ERR_COMBAT1V1_REWARD_FETCHED));
        _ ->
            throw(?err(?ERR_COMBAT1V1_REWARD_NOT_QUALIFIED))
    end;

handle(?COMBAT1V1_DAILY_REWARD, _Tos, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    #combat1v1_role{last_grade=LastGrade} = combat1v1_util:get_role(RoleID),
    ?_check(LastGrade > 0, ?ERR_COMBAT1V1_DAILY_REWARD_NO_GRADE),
    ?_check(role_count:get_combat1v1_count(?COMBAT1V1_COUNT_DAILY_REWARD) == 0,
        ?ERR_COMBAT1V1_REWARD_FETCHED),
    GradeConf = combat1v1_util:grade_conf(),
    #cfg_combat1v1_grade{daily_reward=Reward} = GradeConf:find(LastGrade),
    role_bag:gain(Reward, ?LOG_COMBAT1V1_DAILY_REWARD, RoleSt),
    role_count:add_combat1v1_count(?COMBAT1V1_COUNT_DAILY_REWARD),
    ?ucast(#m_combat1v1_daily_reward_toc{});

handle(?COMBAT1V1_MERIT_REWARD, Tos, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    #m_combat1v1_merit_reward_tos{merit=Num} = Tos,
    #combat1v1_role{merit=Merit, merit_reward=MeritReward} = combat1v1_util:get_role(RoleID),
    ?_check(not lists:member(Num, MeritReward), ?ERR_COMBAT1V1_REWARD_FETCHED),
    ?_check(Merit >= Num, ?ERR_COMBAT1V1_REWARD_NOT_QUALIFIED),
    MeritRewardConf = combat1v1_util:merit_reward_conf(),
    Reward = MeritRewardConf:find(Num),
    ?_check(Reward =/= [], ?ERR_GAME_BAD_ARGS, [?COMBAT1V1_MERIT_REWARD]),
    combat1v1_server:fetch_merit_reward(RoleID, Num),
    role_bag:gain(Reward, ?LOG_COMBAT1V1_DAILY_REWARD, RoleSt),
    ?ucast(#m_combat1v1_merit_reward_toc{merit=Num});

handle(?COMBAT1V1_BUY_TIMES, Tos, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    #m_combat1v1_buy_times_tos{num=Num} = Tos,
    ?_check(combat1v1_util:activity() =/= 0, ?ERR_SCENE_NO_ACTIVITY),
    #combat1v1_role{today_join=TodayJoin, buy_times=BuyTimes} = combat1v1_util:get_role(RoleID),
    LimitConf = combat1v1_util:limit_conf(),
    ?_check(BuyTimes + Num =< LimitConf:max() - LimitConf:max_free(), ?ERR_COMBAT1V1_MAX_BUY_TIMES),
    Cost = lists:foldl(fun(I, Acc) ->
        #cfg_combat1v1_limit{buy=Cost0} = LimitConf:find(LimitConf:max_free()+BuyTimes+I),
        Cost0 ++ Acc
    end, [], lists:seq(1, Num)),
    role_bag:cost(Cost, ?LOG_COMBAT1V1_BUY_TIMES, RoleSt),
    BuyTimes2 = combat1v1_server:buy_times(RoleID, Num),
    RemainBuy = max(0, LimitConf:max() - LimitConf:max_free() - BuyTimes2),
    RemainJoin = max(0, LimitConf:max_free() - TodayJoin + BuyTimes2),
    ?ucast(#m_combat1v1_buy_times_toc{remain_join=RemainJoin, remain_buy=RemainBuy}).

match_succ({SceneID, RoomID, Index}, RoleSt) ->
    ?ucast(#m_combat1v1_match_succ_toc{}),
    combat1v1_util:set_entry_opts(#{room => RoomID, index => Index}, RoleSt),
    Opts = #{act_id=>combat1v1_util:activity()},
    {ok, RoleSt2} = scene_change:change(?SCENE_CHANGE_ACT, SceneID, Opts, RoleSt),
    log_api:plat_stat(?PLAY_STAT_COMBAT1V1, ?PLAY_OP_PART, 1, RoleSt),
    {ok, RoleSt2}.

battle_result(Gain, RoleSt) ->
    role_bag:gain(Gain, ?LOG_COMBAT1V1_BATTLE, RoleSt).


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
