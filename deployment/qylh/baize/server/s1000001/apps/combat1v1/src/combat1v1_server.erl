%% @author rong
%% @doc
-module(combat1v1_server).

-behaviour(gen_server).

-include("game.hrl").
-include("combat1v1.hrl").
-include("table.hrl").
-include("errno.hrl").
-include("ranking.hrl").
-include("enum.hrl").
-include("msgno.hrl").
-include("role.hrl").

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/0]).
-export([hook_chime/1]).
-export([activity_start/1, activity_stop/1, activity_post/1]).
-export([upload_result/5, fetch_join_reward/2, fetch_merit_reward/2, buy_times/2]).
-export([settle/2, reset_data/1]).
-export([gm_set_grade/2, gm_set_merit/2, gm_recalc_grade/0]).

-define(SERVER, ?MODULE).


%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

hook_chime(0) ->
    gen_server:cast(?SERVER, chime);
hook_chime(_) ->
    ignore.

activity_start(ActID) ->
    gen_server:cast(?SERVER, {activity_start, ActID}).

activity_stop(ActID) ->
    gen_server:cast(?SERVER, {activity_stop, ActID}).

activity_post(ActID) ->
    gen_server:cast(?SERVER, {post, ActID}).

upload_result(RoleID, IsWin, Grade, Score, ChgMerit) ->
    Msg = {upload_result, RoleID, IsWin, Grade, Score, ChgMerit},
    case cluster:is_local() of
        true ->
            gen_server:cast(?SERVER, Msg);
        false ->
            cluster:gen_cast_local(RoleID, ?SERVER, Msg)
    end.

fetch_join_reward(RoleID, Num) ->
    gen_server:call(?SERVER, {fetch_join_reward, RoleID, Num}).

fetch_merit_reward(RoleID, Num) ->
    gen_server:call(?SERVER, {fetch_merit_reward, RoleID, Num}).

buy_times(RoleID, Num) ->
    gen_server:call(?SERVER, {buy_times, RoleID, Num}).

settle(Node, RankList) ->
    gen_server:cast({?SERVER, Node}, {settle, RankList}).

reset_data(Node) ->
    gen_server:cast({?SERVER, Node}, reset_data).

gm_set_grade(RoleID, Grade) ->
    gen_server:cast(?SERVER, {gm_set_grade, RoleID, Grade}).

gm_set_merit(RoleID, Merit) ->
    gen_server:cast(?SERVER, {gm_set_merit, RoleID, Merit}).

gm_recalc_grade() ->
    gen_server:cast(?SERVER, gm_recalc_grade).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({}) ->
    process_flag(trap_exit, true),
    ets:new(?ETS_COMBAT1V1_ROLE, [named_table, {keypos, #combat1v1_role.id}]),
    CombatRoles = db:dirty_match_all(?DB_COMBAT1V1_ROLE),
    ets:insert(?ETS_COMBAT1V1_ROLE, CombatRoles),
    erlang:send_after(timer:minutes(15), self(), persist),
    {ok, undefined}.

handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(persist, State) ->
    erlang:send_after(timer:minutes(15), self(), persist),
    persist(),
    {noreply, State};

handle_info(Info, State) ->
    ?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
    persist(),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call({fetch_join_reward, RoleID, Num}, _From, State) ->
    #combat1v1_role{join_reward=JoinReward0} = CombatRole = combat1v1_util:get_role(RoleID),
    JoinReward = maps:put(Num, true, JoinReward0),
    combat1v1_util:set_role(CombatRole#combat1v1_role{join_reward=JoinReward}),
    {reply, ok, State};

do_handle_call({fetch_merit_reward, RoleID, Num}, _From, State) ->
    #combat1v1_role{merit_reward=MeritReward0} = CombatRole = combat1v1_util:get_role(RoleID),
    MeritReward = [Num|MeritReward0],
    combat1v1_util:set_role(CombatRole#combat1v1_role{merit_reward=MeritReward}),
    {reply, ok, State};

do_handle_call({buy_times, RoleID, Num}, _From, State) ->
    #combat1v1_role{buy_times=BuyTimes} = CombatRole = combat1v1_util:get_role(RoleID),
    BuyTimes2 = BuyTimes+Num,
    combat1v1_util:set_role(CombatRole#combat1v1_role{buy_times=BuyTimes+Num}),
    {reply, BuyTimes2, State};

do_handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

do_handle_cast({activity_start, _ActID}, State) ->
    % 活动开启时才重置场次奖励领取记录
    % 其次次数是为了方便一天多次开活动测试
    [combat1v1_util:set_role(R#combat1v1_role{
        today_merit = 0,
        today_join  = 0,
        buy_times   = 0,
        keep_win    = 0,
        join_reward = #{}
    }) || R <- ets:tab2list(?ETS_COMBAT1V1_ROLE)],
    {noreply, State};

do_handle_cast({activity_stop, _ActID}, State) ->
    {noreply, State};

do_handle_cast({post, _ActID}, State) ->
    {noreply, State};

do_handle_cast(chime, State) ->
    % 零点重置
    [combat1v1_util:set_role(R#combat1v1_role{
        today_merit = 0,
        today_join  = 0,
        buy_times   = 0,
        keep_win    = 0,
        last_grade  = R#combat1v1_role.grade
    }) || R <- ets:tab2list(?ETS_COMBAT1V1_ROLE)],
    {noreply, State};

do_handle_cast({upload_result, RoleID, IsWin, Grade, Score, ChgMerit}, State) ->
    #combat1v1_role{grade=Grade0, merit=Merit, today_merit=TodayMerit, join=Join,
        keep_win=KeepWin0, keep_lose=KeepLose, join_reward=JoinReward0,
        today_join=TodayJoin0} = CombatRole = combat1v1_util:get_role(RoleID),
    TodayJoin = TodayJoin0+1,
    JoinRewardConf = combat1v1_util:join_reward_conf(),
    JoinReward = case JoinRewardConf:find(TodayJoin) =/= [] of
        true ->
            case maps:get(TodayJoin, JoinReward0, ?nil) of
                ?nil ->
                    maps:put(TodayJoin, false, JoinReward0);
                _ ->
                    JoinReward0
            end;
        false ->
            JoinReward0
    end,
    KeepWin = ?_if(IsWin, KeepWin0+1, 0),
    combat1v1_util:set_role(CombatRole#combat1v1_role{
        grade       = Grade,
        score       = Score,
        merit       = Merit+ChgMerit,
        today_merit = TodayMerit+ChgMerit,
        join        = Join+1,
        today_join  = TodayJoin,
        keep_win    = KeepWin,
        keep_lose   = ?_if(IsWin, 0, KeepLose+1),
        join_reward = JoinReward
    }),
    rank_server:update(combat1v1_util:rank_id(), RoleID, Score, #{"grade" => Grade}),

    {ok, #role_cache{name=RoleName}} = role:get_cache(RoleID),
    lists:member(KeepWin, [5,10,15]) andalso
        ?notify(?MSG_COMBAT1V1_KEEP_WIN, [{role, RoleID, RoleName}, KeepWin]),
    Group0 = combat1v1_util:grade_group(Grade0),
    Group = combat1v1_util:grade_group(Grade),
    % 黄金段位以上广播
    Group >= 3 andalso Group > Group0 andalso
        ?notify(?MSG_COMBAT1V1_GRADE, [{role, RoleID, RoleName}, cfg_combat1v1_group:find(Group)]),
    {noreply, State};

do_handle_cast({settle, RankList}, State) ->
    settle(RankList),
    {noreply, State};

do_handle_cast(reset_data, State) ->
    timer:sleep(timer:seconds(10)),
    ets:delete_all_objects(?ETS_COMBAT1V1_ROLE),
    db:clear_table(?DB_COMBAT1V1_ROLE),
    {noreply, State};

do_handle_cast({gm_set_grade, RoleID, Grade}, State) ->
    CombatRole = combat1v1_util:get_role(RoleID),
    GradeConf = combat1v1_util:grade_conf(),
    Score = case GradeConf:find(Grade-1) of
        #cfg_combat1v1_grade{score=Score0} -> Score0;
        _ -> 0
    end,
    combat1v1_util:set_role(CombatRole#combat1v1_role{
        grade = Grade, score = Score}),
    {noreply, State};

do_handle_cast({gm_set_merit, RoleID, Merit}, State) ->
    CombatRole = combat1v1_util:get_role(RoleID),
    combat1v1_util:set_role(CombatRole#combat1v1_role{merit=Merit}),
    {noreply, State};

do_handle_cast(gm_recalc_grade, State) ->
    GradeConf = combat1v1_util:grade_conf(),
    [begin 
        Grade = GradeConf:grade(R#combat1v1_role.score),
        combat1v1_util:set_role(R#combat1v1_role{grade = Grade})
    end || R <- ets:tab2list(?ETS_COMBAT1V1_ROLE)],
    {noreply, State};

do_handle_cast(_Msg, State) ->
    {noreply, State}.

do_handle_info(_Msg, State) ->
    {noreply, State}.

persist() ->
    lists:foreach(fun(R) ->
        db:dirty_write(?DB_COMBAT1V1_ROLE, R)
    end, ets:tab2list(?ETS_COMBAT1V1_ROLE)).

settle(RankList) ->
    ?info("compete1v1 settle ranklist ~p~n",[RankList]),
    GoalRewardConf = combat1v1_util:goal_reward_conf(),
    [begin
        #combat1v1_role{id=RoleID, grade=Grade} = R,
        GradeReward = GoalRewardConf:find_by_grade(Grade),
        case lists:keyfind(RoleID, #rankitem.id, RankList) of
            false ->
                send_goal_reward(RoleID, Grade, 0, GradeReward);
            #rankitem{rank=Rank} ->
                case GoalRewardConf:find_by_rank(Rank) of
                    [] ->
                        send_goal_reward(RoleID, Grade, Rank, GradeReward);
                    RankReward ->
                        send_goal_reward(RoleID, Grade, Rank, RankReward)
                end
        end
    end || R <- ets:tab2list(?ETS_COMBAT1V1_ROLE)].

send_goal_reward(_RoleID, _Grade, _Rank, []) ->
    ignore;
send_goal_reward(RoleID, Grade, Rank, Reward) ->
    GradeConf = combat1v1_util:grade_conf(),
    #cfg_combat1v1_grade{name=Name} = GradeConf:find(Grade),
    if
        Rank >= 32 ->
            mail:send(RoleID, ?MAIL_COMBAT1V1_RANK, Reward, [Name, Rank]);
        true ->
            mail:send(RoleID, ?MAIL_COMBAT1V1_GRADE, Reward, [Name])
    end.

