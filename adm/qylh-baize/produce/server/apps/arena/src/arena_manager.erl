%% @author rong
%% @doc
-module(arena_manager).

-behaviour(gen_server).

-include("game.hrl").
-include("table.hrl").
-include("errno.hrl").
-include("enum.hrl").
-include("arena.hrl").
-include("dunge.hrl").
-include("role.hrl").

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/0]).
-export([get_rank/1, get_defenders/1, refresh_defenders/1, get_arena_detail/1]).
-export([challenge/3, challenge_finish/3, challenge_cancel/2]).
-export([update_sti_times/2]).

-define(SERVER, ?MODULE).

-define(in_fight, in_fight). %正在战斗

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

get_rank(RoleID) ->
    ArenaRole = arena_ets:get_role(RoleID),
    ArenaRole#r_arena_role.rank.

% 获取当前的守关者
get_defenders(RoleID) ->
    gen_server:call(?SERVER, {get_defenders, RoleID}).

refresh_defenders(RoleID) ->
    gen_server:call(?SERVER, {refresh_defenders, RoleID}).

% 根据排名获取玩家信息
get_arena_detail(Rank) ->
    case arena_ets:get_arena(Rank) of
        [#arena{role_id = RoleID}] ->
            % 玩家
            {ok, Mirror} = mirror_manager:get_mirror(RoleID),
            arena_util:p_arena(Rank, Mirror);
        _ ->
            % 机器人
            arena_util:p_arena(Rank, cfg_arena:robot_id())
    end.

% 挑战
challenge(RoleID, Rank, DefenderID) ->
    gen_server:call(?SERVER, {challenge, RoleID, Rank, DefenderID}).

challenge_finish(AttackerID, WinnerID, LoserID) ->
    gen_server:cast(?SERVER, {challenge_finish, AttackerID, WinnerID, LoserID}).

challenge_cancel(AttackerID, DefenderID) ->
    gen_server:cast(?SERVER, {challenge_cancel, AttackerID, DefenderID}).

update_sti_times(RoleID, StiTimes) ->
    gen_server:cast(?SERVER, {update_sti_times, RoleID, StiTimes}).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({}) ->
    process_flag(trap_exit, true),
    arena_ets:init(),
    [begin
        arena_ets:set_arena(Arena),
        arena_ets:set_role(#r_arena_role{
            role_id = Arena#arena.role_id, 
            rank    = Arena#arena.rank,
            watch   = arena_util:calc_watch_ranks(Arena#arena.rank)
        })
    end || Arena <- db:dirty_match_all(?DB_ARENA)],
    [arena_ets:set_misc(Misc) || Misc <- db:dirty_match_all(?DB_ARENA_MISC)],
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

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    persist(),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call({get_defenders, RoleID}, _From, State) ->
    #r_arena_role{rank=Rank, watch=Watch} = AreanRole = arena_ets:get_role(RoleID),
    case Watch == [] of
        true ->
            Ranks = arena_util:calc_watch_ranks(Rank),
            arena_ets:set_role(AreanRole#r_arena_role{watch=Ranks});
        false ->
            Ranks = Watch
    end,
    Defenders = [get_arena_detail(Rank0) || Rank0 <- Ranks],
    {reply, Defenders, State};

do_handle_call({refresh_defenders, RoleID}, _From, State) ->
    #r_arena_role{rank=Rank} = AreanRole = arena_ets:get_role(RoleID),
    Ranks = arena_util:calc_watch_ranks(Rank),
    arena_ets:set_role(AreanRole#r_arena_role{watch=Ranks}),
    Defenders = [get_arena_detail(Rank0) || Rank0 <- Ranks],
    {reply, Defenders, State};

do_handle_call({challenge, AttackerID, DefRank, DefenderID}, _From, State) ->
    #r_arena_role{rank=AttRank} = arena_ets:get_role(AttackerID),
    case arena_ets:get_arena(DefRank) of
        [#arena{role_id=DefenderID}] ->
            ok;
        [] when ?IS_ROBOT(DefenderID) ->
            % 机器人
            ok;
        _ ->
            throw(?err(?ERR_ARENA_DEFENDER_RANK_CHANGE))
    end,
    ?_check(not is_lock(AttRank), ?ERR_ARENA_SELF_IN_FIGHT),
    ?_check(not is_lock(DefRank), ?ERR_ARENA_IN_FIGHT),
    lock(AttRank),
    lock(DefRank),
    {reply, {ok, AttRank, get_arena_detail(DefRank)}, State};

do_handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

do_handle_cast({challenge_finish, AttackerID, WinnerID, LoserID}, State) ->
    #r_arena_role{rank=WinnerRank} = Winner = arena_ets:get_role(WinnerID),
    #r_arena_role{rank=LoserRank} = Loser = arena_ets:get_role(LoserID),
    IsWin  = AttackerID == WinnerID,
    ?debug("IsWin ~w", [{IsWin, WinnerRank == 0 orelse WinnerRank > LoserRank}]),
    case IsWin andalso (WinnerRank == 0 orelse WinnerRank > LoserRank) of
        true ->
            % 先清空之前的排名
            arena_ets:del_arena(WinnerRank),
            arena_ets:del_arena(LoserRank),

            % 更新攻方
            arena_ets:set_role(Winner#r_arena_role{rank=LoserRank, watch=[]}),
            arena_ets:set_arena(#arena{rank=LoserRank, role_id=WinnerID}),
            ?debug("winner ~w", [arena_ets:get_role(WinnerID)]),
            ?debug("winner rank ~w", [arena_ets:get_arena(LoserRank)]),
            case not ?IS_ROBOT(LoserID) of
                true ->
                    % 更新守方，非机器人
                    arena_ets:set_role(Loser#r_arena_role{rank=WinnerRank, watch=[]}),
                    case WinnerRank > 0 of
                        true ->
                            arena_ets:set_arena(#arena{rank=WinnerRank, role_id=LoserID});
                        false ->
                            ignore
                    end,
                    case LoserRank =< 100 andalso LoserRank > 0 of
                        true ->
                            {ok, #role_cache{name=WinnerName}} = role:get_cache(WinnerID),
                            mail:send(LoserID, ?MAIL_ARENA_PK, [], [WinnerName, WinnerRank]);
                        false ->
                            ignore
                    end,
                    ?debug("loser ~w", [arena_ets:get_role(LoserID)]),
                    ?debug("loser rank ~w", [arena_ets:get_arena(WinnerRank)]),
                    ok;
                false ->
                    ignore
            end;
        _ ->
            ignore
    end,
    % 最后再释放锁
    unlock(WinnerRank),
    unlock(LoserRank),
    {noreply, State};

do_handle_cast({update_sti_times, RoleID, StiTimes}, State) ->
    Misc = arena_ets:get_misc(RoleID),
    arena_ets:set_misc(Misc#arena_misc{sti_times=StiTimes, sti_date=ut_time:date()}),
    {noreply, State};

do_handle_cast({challenge_cancel, AttackerID, DefenderID}, State) ->
    #r_arena_role{rank=AttRank} = arena_ets:get_role(AttackerID),
    #r_arena_role{rank=DefRank} = arena_ets:get_role(DefenderID),
    unlock(AttRank),
    unlock(DefRank),
    {noreply, State};

% gm强制修复排名
% 删除指定排名记录，如果玩家有多个排名，将数据设置为剩下的排名
do_handle_cast({gm_fixrank, Rank}, State) ->
    case arena_ets:get_arena(Rank) of
        [#arena{role_id=RoleID}] ->
            arena_ets:del_arena(Rank),
            ArenaRole = arena_ets:get_role(RoleID),
            case arena_ets:get_arena_by_role(RoleID) of
                [#arena{rank=Rank1}|_] ->
                    arena_ets:set_role(ArenaRole#r_arena_role{rank=Rank1, watch=[]});
                _ -> 
                    arena_ets:set_role(ArenaRole#r_arena_role{rank=0, watch=[]})
            end;
        _ ->
            ignore
    end,
    {noreply, State};

do_handle_cast(_Msg, State) ->
    {noreply, State}.

persist() ->
    db:clear_table(?DB_ARENA),
    lists:foreach(fun(R) ->
        db:dirty_write(?DB_ARENA, R)
    end, arena_ets:all_arena()),
    lists:foreach(fun(R) ->
        db:dirty_write(?DB_ARENA_MISC, R)
    end, arena_ets:all_misc()).

is_lock(Rank) ->
    case erlang:get({?in_fight, Rank}) of
        EndTime when is_integer(EndTime) -> 
            ut_time:seconds() < EndTime;
        _ -> 
            false
    end.

% 只锁住有排名的
% 记录副本结束的时间戳，防止意外bug导致，一直锁住
lock(Rank) when Rank > 0 ->
    #cfg_dunge{last=BattleTime} = cfg_dunge:find(cfg_arena:dunge_id()),
    erlang:put({?in_fight, Rank}, ut_time:seconds() + BattleTime + 5);
lock(_Rank) ->
    ok.

unlock(Rank) ->
    erlang:erase({?in_fight, Rank}).
