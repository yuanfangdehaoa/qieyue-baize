%% @author rong
%% @doc 竞技场
-module(arena_handler).

-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("enum.hrl").
-include("dunge.hrl").
-include("log.hrl").
-include("arena.hrl").

-export([handle/3]).
-export([battle_result/2]).

-define(TOP_CHALLENGE_LIMIT, 50).

handle(?ARENA_INFO, _Tos, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    Defenders = arena_manager:get_defenders(RoleID),
    Rank      = arena_manager:get_rank(RoleID),
    BuyTimes  = role_count:get_scene_buy(?SCENE_STYPE_DUNGE_ARENA),
    Challenge = remain_challenge(),
    StiTimes  = role_count:get_times(?ROLE_COUNT_ARENA_STIMULATE),
    ?ucast(#m_arena_info_toc{rank=Rank, challenge=Challenge,
        sti_times=StiTimes, buy_times=BuyTimes, list=Defenders});

handle(?ARENA_REFRESH, _Tos, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    Defenders = arena_manager:refresh_defenders(RoleID),
    ?ucast(#m_arena_refresh_toc{list=Defenders});

handle(?ARENA_ADD_CHALLENGE, #m_arena_add_challenge_tos{num=Num}, RoleSt) ->
    MaxBuyTimes = max_buy_times(),
    BuyTimes    = role_count:get_scene_buy(?SCENE_STYPE_DUNGE_ARENA),
    ?_check(BuyTimes + Num =< MaxBuyTimes, ?ERR_ARENA_MAX_BUY_TIMES),
    #cfg_dunge_enter{buy=Cost0} = cfg_dunge:enter(?SCENE_STYPE_DUNGE_ARENA),
    Cost = [{ItemID, Num*CostNum} || {ItemID, CostNum} <- Cost0],
    Succ = fun() ->
        role_count:add_scene_buy(?SCENE_STYPE_DUNGE_ARENA, Num),
        MaxTimes   = max_times(),
        EnterTimes = role_count:get_scene_enter(?SCENE_STYPE_DUNGE_ARENA),
        Challenge  = max(0, MaxTimes+BuyTimes+Num - EnterTimes),
        ?ucast(#m_arena_add_challenge_toc{challenge=Challenge, buy_times=Num})
    end,
    role_bag:cost(Cost, ?LOG_ARENA_BUY_TIMES, Succ, RoleSt);

handle(?ARENA_START, Tos, RoleSt) ->
    #m_arena_start_tos{rank=Rank, role_id=DefenderID,
        is_merge=IsMerge, is_top=IsTop, is_skip=IsSkip} = Tos,
    #role_st{role=RoleID} = RoleSt,
    ?_check(RoleID =/= DefenderID, ?ERR_ARENA_CHALLENGE_SELF),
    case IsTop of
        true ->
            MyRank = arena_manager:get_rank(RoleSt#role_st.role),
            ?_check(MyRank > 0 andalso MyRank =< ?TOP_CHALLENGE_LIMIT, ?ERR_ARENA_TOP_CHALLENGE_RANK),
            Challenge  = remain_top_challenge();
        false ->
            Challenge = remain_challenge()
    end,
    ?_check(Challenge > 0, ?ERR_ARENA_NO_CHALLENGE),

    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
    ?_if(IsSkip, ?_check(RoleLv >= cfg_arena:skip_lv(), ?ERR_ARENA_SKIP_LV)),
    ?_if(IsMerge, ?_check(RoleLv >= cfg_arena:com_lv(), ?ERR_ARENA_MERGE_LV)),

    case arena_manager:challenge(RoleID, Rank, DefenderID) of
        {ok, AttRank, Defender} ->
            % 读取最新的玩家数据（战力）
            Attacker = arena_util:p_arena(AttRank, RoleSt),
            RealChallenge = if
                IsTop -> 1;
                IsMerge -> Challenge;
                true -> 1
            end,
            PlayType = if
                IsTop -> ?PLAY_STAT_ARENA_TOP;
                true -> ?PLAY_STAT_ARENA
            end,

            if
                IsSkip ->
                    case arena_util:is_skip_win(Attacker, Defender) of
                        true ->
                            Winner = Attacker,
                            Loser = Defender;
                        false ->
                            Winner = Defender,
                            Loser = Attacker
                    end,
                    add_enter_times(IsTop, RealChallenge),
                    [role_event:event(?EVENT_DUNGE_ENTER, {?SCENE_STYPE_DUNGE_ARENA, 0, 0})
                        || _ <- lists:seq(1, RealChallenge)],
                    log_api:plat_stat(PlayType, ?PLAY_OP_PART, RealChallenge, RoleSt),
                    arena_util:notify_result(Attacker, Winner, Loser, RealChallenge);
                true ->
                    erlang:put(?ARENA_ENTER_OPTS, #{
                        attacker  => Attacker,
                        defender  => Defender,
                        challenge => RealChallenge
                    }),
                    EnterTos = #m_dunge_enter_tos{stype=?SCENE_STYPE_DUNGE_ARENA,
                        id=cfg_arena:dunge_id(), floor=1, merge=RealChallenge},
                    case catch dunge_handler:handle(?DUNGE_ENTER, EnterTos, RoleSt) of
                        {ok, NewRoleSt} ->
                            add_enter_times(IsTop, RealChallenge),
                            log_api:plat_stat(PlayType, ?PLAY_OP_PART, RealChallenge, RoleSt),
                            {ok, NewRoleSt};
                        Error ->
                            arena_manager:challenge_cancel(RoleID, DefenderID),
                            throw(Error)
                    end
            end;
        Error ->
            throw(Error)
    end;

handle(?ARENA_BATTLE, Tos, RoleSt) ->
    #role_st{spid=ScenePid, role=RoleID} = RoleSt,
    scene:route(ScenePid, dunge_arena, handle, {Tos, RoleID});

handle(?ARENA_SKIP, _Tos, RoleSt) ->
    ?_check(RoleSt#role_st.type == ?SCENE_TYPE_DUNGE, ?ERR_DUNGE_NOT_IN),
    % #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
    % ?_check(RoleLv >= cfg_arena:skip_lv(), ?ERR_ARENA_SKIP_LV),
    #role_st{spid=ScenePid, role=RoleID} = RoleSt,
    erlang:send(ScenePid, {over, RoleID});

handle(?ARENA_TOP, _Tos, RoleSt) ->
    Defenders  = [arena_manager:get_arena_detail(Rank) || Rank <- lists:seq(1, 10)],
    MaxTimes   = cfg_arena:top_challenge(),
    EnterTimes = role_count:get_times(?ROLE_COUNT_ARENA_TOP_CHALLENGE),
    Challenge  = max(0, MaxTimes - EnterTimes),
    ?ucast(#m_arena_top_toc{challenge=Challenge, list=Defenders});

handle(?ARENA_STIMULATE, _Tos, RoleSt) ->
    StiTimes = role_count:get_times(?ROLE_COUNT_ARENA_STIMULATE),
    #cfg_arena_stimulate{cost=Cost} = cfg_arena_stimulate:find(StiTimes+1),
    Succ = fun() ->
        role_count:add_times(?ROLE_COUNT_ARENA_STIMULATE),
        arena_manager:update_sti_times(RoleSt#role_st.role, StiTimes+1),
        ?ucast(#m_arena_stimulate_toc{sti_times=StiTimes+1})
    end,
    role_bag:cost(Cost, ?LOG_ARENA_STIMULATE, Succ, RoleSt);

handle(?ARENA_HIGHEST_RANK, _Tos, RoleSt) ->
    #role_arena{rank=Rank, fetch=Fetch} = role_data:get(?DB_ROLE_ARENA),
    ?ucast(#m_arena_highest_rank_toc{rank=Rank, fetch=Fetch});

handle(?ARENA_HIGHEST_RANK_FETCH, Tos, RoleSt) ->
    #m_arena_highest_rank_fetch_tos{id=ID} = Tos,
    #role_arena{rank=Rank, fetch=Fetch} = RoleArena = role_data:get(?DB_ROLE_ARENA),
    ?_check(not lists:member(ID, Fetch), ?ERR_ARENA_ALREADY_FETCH),
    #cfg_arena_high_rank{rank=NeedRank, reward=Gain} = cfg_arena_high_rank:find(ID),
    ?_check(Rank > 0 andalso Rank =< NeedRank, ?ERR_ARENA_HIGH_RANK_NOT_MEET),
    Succ = fun() ->
        role_data:set(RoleArena#role_arena{fetch=[ID|Fetch]}),
        ?ucast(#m_arena_highest_rank_fetch_toc{id=ID})
    end,
    role_bag:gain(Gain, ?LOG_ARENA_HIGH_RANK, Succ, RoleSt);

handle(?ARENA_RANK, _Tos, RoleSt) ->
    IsFetch = role_count:get_times(?ROLE_COUNT_ARENA_RANK) > 0,
    ?ucast(#m_arena_rank_toc{is_fetch=IsFetch});

handle(?ARENA_RANK_FETCH, _Tos, RoleSt) ->
    IsFetch = role_count:get_times(?ROLE_COUNT_ARENA_RANK) > 0,
    ?_check(not IsFetch, ?ERR_ARENA_ALREADY_FETCH),
    Rank = arena_manager:get_rank(RoleSt#role_st.role),
    ?_check(cfg_arena_rank:find(Rank) =/= ?nil, ?ERR_ARENA_NO_REWARD),
    Gain = cfg_arena_rank:find(Rank),
    Succ = fun() ->
        role_count:add_times(?ROLE_COUNT_ARENA_RANK),
        ?ucast(#m_arena_rank_fetch_toc{is_fetch=true})
    end,
    role_bag:gain(Gain, ?LOG_ARENA_RANK_REWARD, Succ, RoleSt);

handle(?ARENA_TOP_RANK, _Tos, RoleSt) ->
    IsFetch = role_count:get_times(?ROLE_COUNT_TOP_RANK) > 0,
    ?ucast(#m_arena_top_rank_toc{is_fetch=IsFetch});

handle(?ARENA_TOP_RANK_FETCH, _Tos, RoleSt) ->
    IsFetch = role_count:get_times(?ROLE_COUNT_TOP_RANK) > 0,
    ?_check(not IsFetch, ?ERR_ARENA_ALREADY_FETCH),
    Rank = arena_manager:get_rank(RoleSt#role_st.role),
    ?_check(cfg_arena_top_rank:find(Rank) =/= ?nil, ?ERR_ARENA_NO_REWARD),
    Gain = cfg_arena_top_rank:find(Rank),
    Succ = fun() ->
        role_count:add_times(?ROLE_COUNT_TOP_RANK),
        ?ucast(#m_arena_top_rank_fetch_toc{is_fetch=true})
    end,
    role_bag:gain(Gain, ?LOG_ARENA_TOP_REWARD, Succ, RoleSt);

handle(?ARENA_NOTICE, _Tos, RoleSt) ->
    MyRank = arena_manager:get_rank(RoleSt#role_st.role),
    #role_arena{rank=HighRank, fetch=Fetch} = role_data:get(?DB_ROLE_ARENA),
    CanFetchList = lists:filter(fun(ID) ->
        Conf = cfg_arena_high_rank:find(ID),
        HighRank > 0 andalso HighRank =< Conf#cfg_arena_high_rank.rank
    end, cfg_arena_high_rank:all()),
    ?ucast(#m_arena_notice_toc{
        cur_rank      = MyRank,
        challenge     = remain_challenge() > 0,
        top_challenge = MyRank > 0 andalso MyRank =< ?TOP_CHALLENGE_LIMIT andalso remain_top_challenge() > 0,
        high_rank     = length(Fetch) < length(CanFetchList),
        rank          = MyRank > 0 andalso cfg_arena_rank:find(MyRank) =/= ?nil
            andalso role_count:get_times(?ROLE_COUNT_ARENA_RANK) == 0,
        top_rank      = MyRank > 0 andalso cfg_arena_top_rank:find(MyRank) =/= ?nil
            andalso role_count:get_times(?ROLE_COUNT_TOP_RANK) == 0
    }).

battle_result({IsWin, NewRank, Challenge}, RoleSt) ->
    #role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
    Gain = case IsWin of
        true ->
            (cfg_arena_challenge:find(Level))#cfg_arena_challenge.win;
        false ->
            (cfg_arena_challenge:find(Level))#cfg_arena_challenge.lose
    end,
    Gain2 = [{ItemID, Num*Challenge} || {ItemID, Num} <- Gain],
    role_bag:gain(Gain2, ?LOG_ARENA_CHALLENGE, RoleSt),
    case IsWin of
        true ->
            mirror_manager:update_mirror(RoleSt),
            #role_arena{rank=Rank} = RoleArena = role_data:get(?DB_ROLE_ARENA),
            ?debug("battle win ~w, old rank : ~w", [NewRank, Rank]),
            case NewRank > 0 andalso (Rank == 0 orelse NewRank < Rank) of
                true ->
                    role_event:event(?EVENT_ARENA, NewRank),
                    role_data:set(RoleArena#role_arena{rank=NewRank});
                false ->
                    role_event:event(?EVENT_ARENA, Rank)
            end;
        false ->
            ignore
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
max_times() ->
    #cfg_dunge_enter{times=MaxTimes} = cfg_dunge:enter(?SCENE_STYPE_DUNGE_ARENA),
    MaxTimes.

max_buy_times() ->
    VipLv = role_vip:get_level(),
    cfg_vip_rights:find(?VIP_RIGHTS_DUNGE_ARENA, VipLv, 0).

remain_challenge() ->
    MaxTimes   = max_times(),
    EnterTimes = role_count:get_scene_enter(?SCENE_STYPE_DUNGE_ARENA),
    BuyTimes   = role_count:get_scene_buy(?SCENE_STYPE_DUNGE_ARENA),
    max(0, MaxTimes+BuyTimes - EnterTimes).

remain_top_challenge() ->
    MaxTimes   = cfg_arena:top_challenge(),
    EnterTimes = role_count:get_times(?ROLE_COUNT_ARENA_TOP_CHALLENGE),
    max(0, MaxTimes - EnterTimes).

add_enter_times(IsTop, ChallengeTimes) ->
    if
        IsTop ->
            role_count:add_times(?ROLE_COUNT_ARENA_TOP_CHALLENGE, ChallengeTimes);
        true ->
            role_count:add_scene_enter(?SCENE_STYPE_DUNGE_ARENA, ChallengeTimes)
    end.
