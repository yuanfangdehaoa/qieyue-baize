%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(rank).

-include("rank.hrl").
-include("ranking.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("table.hrl").
-include("game.hrl").

%% API
-export([update_rank/3, update_rank/4]).
-export([get_ranklist/1, get_ranklist/2]).
-export([get_toplist/2]).
-export([get_rank/2]).
-export([remove_rank/1]).
-export([clear_rank/1]).
-export([load_rank/1]).
-export([open_rank/1]).
-export([close_rank/1]).
-export([reinit_rank/1]).
-export([start_cross/0]).
-export([hook_chime/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
update_rank(RankID, Sort, RoleSt) when is_record(RoleSt, role_st) ->
	rank_server:update(RankID, RoleSt#role_st.role, Sort, #{});
update_rank(RankID, RoleID, Sort) ->
	rank_server:update(RankID, RoleID, Sort, #{}).


update_rank(RankID, Sort, Data, RoleSt) when is_record(RoleSt, role_st) ->
	rank_server:update(RankID, RoleSt#role_st.role, Sort, Data);
update_rank(RankID, RoleID, Sort, Data) ->
	rank_server:update(RankID, RoleID, Sort, Data).

%% 获取排行榜
get_ranklist(RankID) ->
	rank_server:get_ranklist(RankID).

%% 获取排行榜并获取自己的数据
get_ranklist(RankID, RoleID) ->
	rank_server:get_ranklist(RankID, RoleID).

%% 获取排行榜前 N 名
get_toplist(RankID, TopN) ->
	RankList1 = rank_server:get_ranklist(RankID),
	lists:sublist(RankList1, TopN).

%% 获取排名
get_rank(RankID, RoleID) ->
	RankList = rank_server:get_ranklist(RankID),
	case lists:keyfind(RoleID, #rankitem.id, RankList) of
		false -> 0;
		Item  -> Item#rankitem.rank
	end.

%% 移除排行榜
remove_rank(RankID) ->
	RankPid = rank_util:get_pid(RankID),
	rank_sup:stop_rank(RankPid),
	db:dirty_delete(?DB_GAME_RANK, RankID).

%% 清空排行榜
clear_rank(RankID) ->
	rank_server:clear(RankID).

%% 加载排行榜
load_rank(RankID) ->
	rank_server:load(RankID).

%% 开启排行榜
open_rank(RankID) ->
	?_if(rank_util:get_pid(RankID) == ?nil, rank_sup:start_rank(RankID)),
	rank_server:open(RankID).

%% 关闭排行榜
close_rank(RankID) ->
	rank_server:close(RankID).

%% 重新加载，排序，开启排行榜
reinit_rank(RankID) ->
	rank_server:reinit(RankID).

% 启动跨服排行榜
start_cross() ->
	[rank_sup:start_rank(RankID) || RankID <- cfg_rank:cross()],
	ok.

% 零点保存log
hook_chime(0) ->
    [rank_server:send_log(RankID) || RankID <- cfg_rank:all()];
hook_chime(_) ->
    ignore.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
