%% @author rong
%% @doc 
-module(combat1v1_util).

-include("combat1v1.hrl").
-include("activity.hrl").
-include("table.hrl").
-include("game.hrl").
-include("enum.hrl").

-export([set_entry_opts/2, get_entry_opts/1]).
-export([scene/0, activity/0]).
-export([get_role/1, set_role/1]).
-export([is_junior/1, calc_grade_junior_lv/1, grade_group/1]).
-export([calc_first_season_range/0, calc_first_season_range/1]).
-export([calc_season_range/1, calc_season_range/2]).
-export([mode/0, rank_id/0]).
-export([limit_conf/0, join_reward_conf/0, merit_reward_conf/0, 
    goal_reward_conf/0, grade_conf/0]).
-export([test/0]).

set_entry_opts(Opts, _RoleSt) ->
    erlang:put({?MODULE, entry_opts}, Opts).

get_entry_opts(_RoleSt) ->
    erlang:erase({?MODULE, entry_opts}).    

activity() ->
    case ets:lookup(?ETS_COMBAT1V1, ?KEY) of
        [#combat1v1_mode{activity=ActID}] -> ActID;
        _ -> 0
    end.

scene() ->
    [#combat1v1_mode{activity=ActID}] = ets:lookup(?ETS_COMBAT1V1, ?KEY),
    #cfg_activity{scene=Scene} = cfg_activity:find(ActID),
    Scene.

get_role(RoleID) ->
    case ets:lookup(?ETS_COMBAT1V1_ROLE, RoleID) of
        [CombatRole] -> CombatRole;
        _ -> #combat1v1_role{id=RoleID, grade=?INITIAL_GRADE}
    end.

set_role(CombatRole) ->
    ets:insert(?ETS_COMBAT1V1_ROLE, CombatRole).

% 是否黑铁段位
is_junior(Grade) ->
    Grade div 10 == 1.

calc_grade_junior_lv(Grade) ->
    (Grade div 10) * 10 + 1.

% 段位分组
grade_group(Grade) ->
    Grade div 10.

% 计算赛季时间范围
calc_first_season_range() ->
    {OpenDate, _} = game_env:get_env(opened),
    calc_first_season_range(OpenDate).
calc_first_season_range(OpenDate) ->
    Start = ut_time:monday(OpenDate),
    End = ut_time:add_days(ut_time:sunday(OpenDate), 7),
    {Start, End}.

calc_season_range(CurDate) ->
    {OpenDate, _} = game_env:get_env(opened),
    calc_season_range(CurDate, OpenDate).
calc_season_range(CurDate, OpenDate) ->
    {FirstS, FirstE} = calc_first_season_range(OpenDate),
    if 
        CurDate >= FirstS, CurDate =< FirstE ->
            {FirstS, FirstE};
        true ->
            {_Year, _Month, Day} = CurDate,
            DayOfWeek = ut_time:day_of_week(CurDate),
            case {Day, DayOfWeek} of
                % 归属到上个月，以上个月最后一天来算
                {1, 6} -> calc_season_range_1(FirstE, ut_time:add_days(CurDate, -1));
                {1, 7} -> calc_season_range_1(FirstE, ut_time:add_days(CurDate, -1));
                {2, 7} -> calc_season_range_1(FirstE, ut_time:add_days(CurDate, -2));
                % 以当前时间来算 
                _      -> calc_season_range_1(FirstE, CurDate)
            end
    end.

calc_season_range_1(FirstE, CurDate) ->
    {Year, Month, _} = CurDate,
    % 以最后一个周五来找周日，有可能周日已经是下一个月了
    End0 = ut_time:add_days(ut_time:last_weekday_of_month(CurDate, 5), 2),
    if 
        CurDate > End0 ->
            % 跨到下个月
            FirstDate = ut_time:add_days({Year, Month, calendar:last_day_of_the_month(Year, Month)}, 1),
            Start = calc_season_start(FirstE, FirstDate),
            End = ut_time:add_days(ut_time:last_weekday_of_month(FirstDate, 5), 2),
            {Start, End};
        true ->
            FirstDate = {Year, Month, 1},
            Start = calc_season_start(FirstE, FirstDate),
            {Start, End0}
    end.

calc_season_start(FirstE, FirstDate) ->
    DayOfWeek = ut_time:day_of_week(FirstDate),
    Start0 = if
        DayOfWeek == 6 ->
            ut_time:add_days(FirstDate, 2);
        DayOfWeek == 7 ->
            ut_time:add_days(FirstDate, 1);
        true ->
            ut_time:add_days(FirstDate, -(DayOfWeek-1))
    end,
    Start = if 
        FirstE > Start0 ->
            ut_time:add_days(FirstE, 1);
        true ->
             Start0
    end,
    Start.

test() ->
    TestFun = fun(CurDate, Expected) ->
        Result = calc_season_range(CurDate),
        io:format("cur date ~w, expected ~w, result ~w, match ~w ~n", [CurDate, Expected, Result, Expected == Result])
    end,
    TestFun({2019,09,30}, {{2019,09,30}, {2019,10,27}}),
    TestFun({2019,09,29}, {{2019,09,02}, {2019,09,29}}),
    TestFun({2019,09,18}, {{2019,09,02}, {2019,09,29}}),
    TestFun({2019,09,01}, {{2019,08,12}, {2019,09,01}}),
    TestFun({2019,11,01}, {{2019,10,28}, {2019,12,01}}),
    ok.

% 当前模式
mode() ->
    %  return local|cross
    case cluster:is_local() of
        true ->
            game_misc:read(?COMBAT1V1_MISC_MODE);
        false ->
            ?MODE_CROSS
    end.

rank_id() ->
    case mode() of
        ?MODE_LOCAL -> ?RANK_ID_COMBAT1V1;
        ?MODE_CROSS -> ?RANK_ID_COMBAT1V1_CROSS
    end.

limit_conf() ->
    case mode() of
        ?MODE_LOCAL -> cfg_combat1v1_local_limit;
        ?MODE_CROSS -> cfg_combat1v1_cross_limit
    end.

join_reward_conf() ->
    case mode() of
        ?MODE_LOCAL -> cfg_combat1v1_local_join_reward;
        ?MODE_CROSS -> cfg_combat1v1_cross_join_reward
    end.

merit_reward_conf() ->
    case mode() of
        ?MODE_LOCAL -> cfg_combat1v1_local_merit_reward;
        ?MODE_CROSS -> cfg_combat1v1_cross_merit_reward
    end.

goal_reward_conf() ->
    case mode() of
        ?MODE_LOCAL -> cfg_combat1v1_local_goal_reward;
        ?MODE_CROSS -> cfg_combat1v1_cross_goal_reward
    end.
 
grade_conf() ->
    case mode() of
        ?MODE_LOCAL -> cfg_combat1v1_local_grade;
        ?MODE_CROSS -> cfg_combat1v1_cross_grade
    end.
