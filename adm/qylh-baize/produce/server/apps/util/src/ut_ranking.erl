%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(ut_ranking).

-include("game.hrl").
-include("rank.hrl").
-include("ranking.hrl").

%% API
-export([init/5]).
-export([get_all/1]).
-export([get_top/2]).
-export([update/4]).
-export([clear/1]).
-export([del/2]).
-export([resort/1]).
-export([set_rank_limen/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init(RankID, Size, Limen, Sorter, List) ->
	Ranking = #ranking{
		id    = RankID,
		size  = Size,
		sort  = Sorter,
		list  = List,
		limen = Limen,
		last  = find_last(List, Size, Limen)
	},
	set_ranking(Ranking).

get_all(RankID) ->
	Ranking = get_ranking(RankID),
	Ranking#ranking.list.

get_top(RankID, N) ->
	Ranking = get_ranking(RankID),
	lists:sublist(Ranking#ranking.list, N).

update(RankID, ID, Sort, Data) ->
	Ranking = #ranking{list=RankList, size=Size, last=Last} = get_ranking(RankID),
	case lists:keyfind(ID, #rankitem.id, RankList) of
		% 不在榜上，且没有达到上榜阈值
		false when Sort < Last ->
			ignore;
		% 不在榜上，且榜单已满，没有超过上榜阈值
		false when Sort =< Last, length(RankList) >= Size ->
			ignore;
		% 第1次上榜
		false ->
			do_update(Ranking, rankitem(ID, Sort, Data));
		% 已在榜上
		Item  ->
			do_update(Ranking, Item#rankitem{id=ID, sort=Sort, data=Data, time=ut_time:seconds()})
	end.

clear(RankID) ->
	Ranking = get_ranking(RankID),
	#cfg_rank{limen=Limen} = cfg_rank:find(RankID),
	set_ranking(Ranking#ranking{list=[], limen=Limen, last=Limen}).

del(RankID, ID) ->
	Ranking = get_ranking(RankID),
	#ranking{list=RankList, size=Size, sort=Sorter} = Ranking,
	RankList1 = lists:keydelete(ID, #rankitem.id, RankList),
	RankList2 = sorting(RankList1, Size, Sorter),
	Ranking1  = Ranking#ranking{list=RankList2},
	Ranking2  = case lists:reverse(RankList2) of
		[Last | _] ->
			#cfg_rank{limen=Limen} = cfg_rank:find(RankID),
			case length(RankList2) >= Size of
				true  ->
					Ranking1#ranking{last=Last#rankitem.sort};
				false ->
					Ranking1#ranking{last=Limen}
			end;
		_ ->
			Ranking1#ranking{last=Ranking#ranking.limen}
	end,
	set_ranking(Ranking2).

-define(k_rank_limen, k_rank_limen).
get_rank_limen() ->
	get(?k_rank_limen).

set_rank_limen(RankLimen) ->
	put(?k_rank_limen, RankLimen).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
-define(k_ranking, {k_ranking, RankID}).
get_ranking(RankID) ->
	get(?k_ranking).

set_ranking(Ranking = #ranking{id=RankID}) ->
	put(?k_ranking, Ranking).


find_last(RankList, Size, Limen) when length(RankList) < Size ->
	Limen;
find_last(RankList, _Size, _Limen) ->
	[R | _] = lists:reverse(RankList),
	R#rankitem.sort.

rankitem(ID, Sort, Data) ->
	#rankitem{id=ID, sort=Sort, time=ut_time:seconds(), data=Data}.

do_sort(RankList) ->
	lists:sort(fun
		(Item1, Item2) ->
			case Item1#rankitem.sort == Item2#rankitem.sort of
				true  -> Item1#rankitem.time > Item2#rankitem.time;
				false -> Item1#rankitem.sort < Item2#rankitem.sort
			end
	end, RankList).

sorting(RankList, Size, Sorter) ->
	RankList1 = ?_if(Sorter == ?nil, do_sort(RankList), Sorter(RankList)),
	RankList2 = case get_rank_limen() of
		?nil ->
			sorting2(RankList1, length(RankList1), []);
		List ->
			sorting3(lists:reverse(RankList1), 1, Size, List, [])
	end,
	lists:sublist(RankList2, Size).

sorting2(_, Rank, RankList) when Rank =< 0 ->
	RankList;
sorting2([Item | T], Rank, RankList) ->
	sorting2(T, Rank-1, [Item#rankitem{rank=Rank} | RankList]);
sorting2([], _Rank, RankList) ->
	RankList.

sorting3(_, Rank, Size, _RankLimen, RankList) when Rank > Size ->
	RankList;
sorting3([Item | T], Rank, Size, RankLimen, RankList) ->
	case is_satisfy_rank_limen(RankLimen, Rank, Item#rankitem.sort) of
		true  ->
			sorting3(T, Rank+1, Size, RankLimen, [Item#rankitem{rank=Rank} | RankList]);
		false ->
			sorting3([Item | T], Rank+1, Size, RankLimen, RankList)
	end;
sorting3([], _Rank, _Size, _RankLimen, RankList) ->
	RankList.

is_satisfy_rank_limen([{MinRank,MaxRank,Limen} | T], Rank, Val) ->
	case MinRank =< Rank andalso Rank =< MaxRank of
		true  -> Val >= Limen;
		false -> is_satisfy_rank_limen(T, Rank, Val)
	end;
is_satisfy_rank_limen([], _Rank, _Val) ->
	false.

do_update(Ranking, RankItem=#rankitem{id=ID}) ->
	#ranking{list=RankList, size=Size, sort=Sorter} = Ranking,
	RankList1 = lists:keystore(ID, #rankitem.id, RankList, RankItem),
	RankList2 = sorting(RankList1, Size, Sorter),
	Ranking1 = Ranking#ranking{list=RankList2},
	Ranking2 = case length(RankList2) >= Size of
		true  ->
			LastSort = get_min_sort(RankList2),
			Ranking1#ranking{last=LastSort};
		false ->
			Ranking1
	end,
	set_ranking(Ranking2).

resort(RankID) ->
	#ranking{list=RankList, size=Size, sort=Sorter} = Ranking = get_ranking(RankID),
	RankList1 = sorting(RankList, Size, Sorter),
	Ranking1 = Ranking#ranking{list=RankList1},
	Ranking2 = case length(RankList1) >= Size of
		true  ->
			LastSort = get_min_sort(RankList1),
			Ranking1#ranking{last=LastSort};
		false ->
			Ranking1
	end,
	set_ranking(Ranking2).

get_min_sort(RankList) ->
	RankSortList = [RankItem#rankitem.sort || RankItem <- RankList],
	Sort = ?_if(RankSortList =/= [],lists:min(RankSortList),0),
	Sort.

