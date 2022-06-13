%% @author rong
%% @doc
-module(arena_util).

-include("role.hrl").
-include("proto.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("creep.hrl").
-include("rank.hrl").
-include("ranking.hrl").
-include("arena.hrl").
-include("game.hrl").

-export([calc_watch_ranks/1]).
-export([p_arena/2]).
-export([get_robot_base/2]).
-export([get_ranklist/1]).
-export([calc_power_diff/2, is_skip_win/2, notify_result/4]).

-define(MAX_RANK, cfg_arena:max_rank()).
% -define(MAX_RANK, 5).

% 计算守关者的排名
calc_watch_ranks(1) ->
    [2, 3, ut_rand:random(4,5)];
calc_watch_ranks(2) ->
    [1, 3, ut_rand:random(4,5)];
calc_watch_ranks(Rank) when Rank > 0, Rank < 10 ->
    [Rank-2, Rank-1, ut_rand:random(Rank+1, Rank+2)];
calc_watch_ranks(Rank) ->
    case Rank == 0 orelse Rank == ?MAX_RANK of
        true ->
            Rank0 = ?MAX_RANK,
            [Low, Medium, High] = lists:sort(
                [calc_medium(Rank0), calc_medium(Rank0), calc_low(Rank0)]),
            if
                Low == Medium, Medium == High ->
                    [Low, Medium+1, High+2];
                Low == Medium, Medium+1 == High ->
                    [Low, Medium+1, High+1];
                Low == Medium ->
                    [Low, Medium+1, High];
                Medium == High ->
                    [Low, Medium, High+1];
                true ->
                    [Low, Medium, High]
            end;
        false ->
            [calc_low(Rank), calc_medium(Rank), calc_high(Rank)]
    end.

calc_low(Rank) ->
    [Min, Max] = lists:sort([trunc(Rank*0.8), trunc(Rank*0.9)-2]),
    max(1, ut_rand:random(Min, Max)).

calc_medium(Rank) ->
    ut_rand:random(trunc(Rank*0.9), Rank-1).

calc_high(Rank) ->
    [Min, Max] = lists:sort([Rank+1, trunc(Rank*1.2)]),
    min(ut_rand:random(Min, Max), ?MAX_RANK).

p_arena(Rank, RoleSt) when is_record(RoleSt, role_st) ->
    RoleInfo = role_data:get(?DB_ROLE_INFO),
    StiTimes = arena_ets:get_sti_times(RoleInfo#role_info.id),
    #p_arena{
        id        = RoleInfo#role_info.id,
        creep     = 0,
        rank      = Rank,
        name      = RoleInfo#role_info.name,
        career    = RoleInfo#role_info.career,
        gender    = RoleInfo#role_info.gender,
        level     = RoleInfo#role_info.level,
        power     = calc_power(role_util:get_power(), StiTimes),
        figure    = RoleInfo#role_info.figure,
        sti_times = StiTimes
    };

p_arena(Rank, CreepID) when is_integer(CreepID) ->
    Cfg = cfg_creep:find(CreepID),
    #p_arena{
        id        = Rank,
        creep     = CreepID,
        rank      = Rank,
        name      = Cfg#cfg_creep.name,
        career    = ?CAREER_SWORDMAN,
        gender    = ?GENDER_MALE,
        level     = Cfg#cfg_creep.level,
        power     = mod_attr:power(cfg_creep_attr:find(CreepID, Rank)),
        sti_times = 0
    };

p_arena(Rank, Mirror) ->
    StiTimes = arena_ets:get_sti_times(Mirror#mirror.id),
    #p_arena{
        id        = Mirror#mirror.id,
        creep     = 0,
        rank      = Rank,
        name      = Mirror#mirror.name,
        career    = Mirror#mirror.career,
        gender    = Mirror#mirror.gender,
        level     = Mirror#mirror.level,
        power     = calc_power(Mirror#mirror.power, StiTimes),
        figure    = Mirror#mirror.figure,
        sti_times = StiTimes
    }.

calc_power(Power, StiTimes) ->
    case cfg_arena_stimulate:find(StiTimes) of
        #cfg_arena_stimulate{stimulate=Sti} ->
            trunc(Power*(1+Sti/10000));
        _ ->
            Power
    end.

% 构造机器人的排行榜数据
get_robot_base(Rank, ID) ->
    Cfg = cfg_creep:find(cfg_arena:robot_id()),
    #p_role_base{
        id     = ID,
        name   = Cfg#cfg_creep.name,
        career = ?CAREER_SWORDMAN,
        gender = ?GENDER_MALE,
        level  = Cfg#cfg_creep.level,
        viplv  = 0,
        power  = mod_attr:power(cfg_creep_attr:find(cfg_arena:robot_id(), Rank)),
        figure = #{},
        guild  = 0,
        gname  = "",
        charm  = 0,
        wake   = 0,
        gpost  = 0,
        marry  = 0,
        mname  = "",
        mtype  = 0,
        suid   = game_env:get_suid(),
    	zoneid = 0,
        team   = 0
    }.

get_ranklist(RoleID) ->
    #cfg_rank{size=RankSize} = cfg_rank:find(?RANK_ID_ARENA),
    RankList = [begin
        case arena_ets:get_arena(Rank) of
            [#arena{role_id = RoleID0}] ->
                ID = RoleID0;
            _ ->
                ID = Rank
        end,
        #rankitem{
            id   = ID,
            rank = Rank,
            sort = Rank,
            time = ut_time:seconds(),
            data = #{}
        }
    end|| Rank <- lists:seq(1, RankSize)],
    MyRank = arena_manager:get_rank(RoleID),
    {RankList, {MyRank, #{}}}.

calc_power_diff(Attacker, Defender) ->
    AttPower = Attacker#p_arena.power,
    DefPower = Defender#p_arena.power,
    % show_in_chat(Attacker#p_arena.id, lists:concat(["diff: ", (DefPower - AttPower) / DefPower, " "])),
    max((DefPower - AttPower) / DefPower, -99).

is_skip_win(Attacker, Defender) ->
    Diff = arena_util:calc_power_diff(Attacker, Defender),
    case cfg_arena_skip:find(Diff) of
        Prob when is_integer(Prob) ->
            Ret = Prob >= ut_rand:random(1, 10000),
            % show_in_chat(Attacker#p_arena.id, lists:concat(["prob: ", Prob, " is_win: ", Ret])),
            Ret;
        _ ->
            % show_in_chat(Attacker#p_arena.id, lists:concat(["prob: ", no, " is_win: false"])),
            false
    end.

notify_result(Attacker, Winner, Loser, Challenge) ->
    #p_arena{id=AttackerID} = Attacker,
    #p_arena{id=WinnerID, rank=WinnerRank} = Winner,
    #p_arena{id=LoserID, rank=LoserRank} = Loser,

    IsWin = AttackerID == WinnerID,
    NewRank = case IsWin of
        true ->
            case WinnerRank > 0 andalso WinnerRank < LoserRank of
                true -> WinnerRank;
                false -> LoserRank
            end;
        false ->
            LoserRank
    end,

    role:is_online(AttackerID) andalso
        ?ucast(AttackerID, #m_arena_end_toc{
            is_win    = IsWin,
            old_rank  = Attacker#p_arena.rank,
            new_rank  = NewRank,
            challenge = Challenge
        }),

    Msg = {IsWin, NewRank, Challenge},
    role:route(AttackerID, arena_handler, battle_result, Msg, Msg),
    arena_manager:challenge_finish(AttackerID, WinnerID, LoserID).

% show_in_chat(RoleID, Content) ->
%     ?ucast(RoleID, #m_chat_channel_toc{
%         channel_id = 1,
%         content    = Content,
%         sender     = role:get_base(RoleID),
%         ids        = #{}
%     }).
