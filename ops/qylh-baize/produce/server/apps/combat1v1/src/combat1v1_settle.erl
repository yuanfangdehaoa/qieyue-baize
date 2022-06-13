%% @author rong
%% @doc
-module(combat1v1_settle).

-behaviour(gen_server).

-include("game.hrl").
-include("combat1v1.hrl").
-include("table.hrl").
-include("errno.hrl").
-include("ranking.hrl").
-include("enum.hrl").

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/0]).
-export([hook_chime/1]).
-export([activity_start/1, activity_stop/1, activity_post/1]).
-export([gm_settle/1, gm_change_opend/0]).

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

gm_settle(Type) ->
    gen_server:cast(?SERVER, {gm_settle, Type}).

gm_change_opend() ->
    gen_server:cast(?SERVER, gm_change_opend).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({}) ->
    process_flag(trap_exit, true),
    ets:new(?ETS_COMBAT1V1, [named_table, {keypos, #combat1v1_mode.key}]),
    {ok, undefined}.

handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
    ?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

do_handle_cast(started, State) ->
    % 确定当前赛季
    % 不在启动时跑结算处理，简化处理。
    case game_misc:read(?COMBAT1V1_MISC_SEASON) of
        ?nil ->
            CurSeason = combat1v1_util:calc_season_range(ut_time:date()),
            game_misc:write(?COMBAT1V1_MISC_SEASON, CurSeason, true),
            game_misc:write(?COMBAT1V1_MISC_MODE, mode(CurSeason), true);
        CurSeason ->
            game_misc:write(?COMBAT1V1_MISC_MODE, mode(CurSeason), true)
    end,
    {noreply, State};

do_handle_cast({activity_start, ActID}, State) ->
    ets:insert(?ETS_COMBAT1V1, #combat1v1_mode{key=?KEY, activity=ActID}),
    {noreply, State};

do_handle_cast({activity_stop, _ActID}, State) ->
    ets:delete_all_objects(?ETS_COMBAT1V1),
    {noreply, State};

do_handle_cast({post, _ActID}, State) ->
    % 要等活动结束后一段时间（副本最大时长）结算，算上结束时还在副本里1v1的最后结果
    % 赛季最后一个周五发放排名奖励
    {_, End} = game_misc:read(?COMBAT1V1_MISC_SEASON),
    Diff = ut_time:diff_days(ut_time:date(), End),
    if
        Diff == 2 ->
            settle(normal);
        true ->
            ignore
    end,
    {noreply, State};

do_handle_cast(chime, State) ->
    % 赛季开始的周一数据重置， 即赛季发生变化了
    check_and_update_season(),
    {noreply, State};

do_handle_cast({gm_settle, Type}, State) ->
    settle(Type),
    {noreply, State};

do_handle_cast(gm_change_opend, State) ->
    CurSeason = combat1v1_util:calc_season_range(ut_time:date()),
    game_misc:write(?COMBAT1V1_MISC_SEASON, CurSeason, true),
    game_misc:write(?COMBAT1V1_MISC_MODE, mode(CurSeason), true),
    {noreply, State};

do_handle_cast(_Msg, State) ->
    {noreply, State}.

do_handle_info(_Msg, State) ->
    {noreply, State}.

check_and_update_season() ->
    LastSeason = game_misc:read(?COMBAT1V1_MISC_SEASON),
    CurSeason = combat1v1_util:calc_season_range(ut_time:date()),
    game_misc:write(?COMBAT1V1_MISC_MODE, mode(LastSeason)),
    case LastSeason == CurSeason of
        true ->
            ignore;
        false ->
            ?debug("update season, old ~w, next ~w", [LastSeason, CurSeason]),
            settle(normal),
            game_misc:write(?COMBAT1V1_MISC_SEASON, CurSeason, true),
            game_misc:delete(?COMBAT1V1_MISC_REWARD)
    end,
    game_misc:write(?COMBAT1V1_MISC_MODE, mode(CurSeason), true).

settle(Type) ->
    HasSend = case Type of
        normal ->
            % 正常流程结束时发奖励
            % 如果当服务器在最后一场活动时重启，打断了正常发奖流程时，可以跑脚本再次执行，可以补发奖励
            game_misc:read(?COMBAT1V1_MISC_REWARD, false);
        gm ->
            % 强制发奖励，不管是否已经发过
            false
    end,
    not HasSend andalso settle().

settle() ->
    % 标记奖励已经发送
    game_misc:write(?COMBAT1V1_MISC_REWARD, true, true),
    % 统一由一个进程来通知发奖与清除数据
    case {game_env:get_type(), combat1v1_util:mode()} of
        {?SERVER_TYPE_LOCAL, ?MODE_LOCAL} ->
            % 本服版，本服发奖励，清除数据
            RankList = rank_server:get_ranklist(combat1v1_util:rank_id()),
            combat1v1_server:settle(node(), RankList),
            combat1v1_server:reset_data(node()),
            rank_server:clear(?RANK_ID_COMBAT1V1);
        {?SERVER_TYPE_CROSS, ?MODE_CROSS} ->
            % 跨服版，通知各游戏服发奖励，清除数据
            RankList  = rank_server:get_ranklist(combat1v1_util:rank_id()),
            LocalList = cluster_util:get_local_nodes(?CROSS_RULE_24_8),
            [begin
                % 判断游戏服是否为跨服版
                OpenDate = ut_time:seconds_to_date(OTime),
                CurDate  = ut_time:add_days(ut_time:date(), -1),
                NodeSeason = combat1v1_util:calc_season_range(CurDate, OpenDate),
                case mode(NodeSeason, OpenDate) of
                    ?MODE_CROSS ->
                        combat1v1_server:settle(Node, RankList),
                        combat1v1_server:reset_data(Node);
                    _ ->
                        ignore
                end
            end || #cls_node{name=Node, otime=OTime} <- LocalList],
            rank_server:clear(?RANK_ID_COMBAT1V1_CROSS);
        _ ->
            ignore
    end.

mode(CurSeason) ->
    {OpenDate, _} = game_env:get_env(opened),
    mode(CurSeason, OpenDate).
mode(CurSeason, OpenDate) ->
    FirstSeason = combat1v1_util:calc_first_season_range(OpenDate),
    if
        CurSeason == FirstSeason -> ?MODE_LOCAL;
        true -> ?MODE_CROSS
    end.
