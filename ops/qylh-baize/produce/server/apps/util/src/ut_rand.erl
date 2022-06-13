%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(ut_rand).

-include("game.hrl").

%% API
-export([random/2]).
-export([choose/1, choose/3]).
-export([weight/1, weight/2, weight/3, weight/4]).
-export([shuffle/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%%-----------------------------------------------
%% @doc 生成 Min 到 Max 之间的随机整数
-spec random(integer(), integer()) ->
	integer().
%%-----------------------------------------------
random(Min, Max)->
    Min2 = Min - 1,
    uniform(Max - Min2) + Min2.


%%-----------------------------------------------
%% @doc 从列表中随机抽出一个元素
-spec choose(list()) ->
	term().
%%-----------------------------------------------
choose([])  ->
	error;
choose(List) ->
	Index = uniform( length(List) ),
    lists:nth(Index, List).


%%-----------------------------------------------
%% @doc 从列表中随机抽出N个元素
%% Repeat : 是否放回
-spec choose(list(), integer(), boolean()) ->
	term().
%%-----------------------------------------------
choose([], _Num, _Repeat) ->
	error;
choose(List, Num, Repeat) ->
	case Repeat of
		true  -> choose_repeat(List, Num);
		false -> choose_norepeat(List, Num)
	end.


%%-----------------------------------------------
%% @doc 从权重列表中随机出一个元素
-spec weight(List, Index) -> Return when
	List   :: [tuple()],
	Index  :: integer(), % 权重位在哪个位置(默认最后一位)
	Return :: any().
%%-----------------------------------------------
weight(List = [H | _]) ->
	weight(List, erlang:size(H)).

weight([], _Index) ->
	error;
weight(List, Index) ->
	{_, Elem} = do_weight(List, Index),
	split_weight(Elem, Index).


%%-----------------------------------------------
%% @doc 从权重列表中随机出N个元素
-spec weight(List, Index, Num, Repeat) -> Return when
	List   :: [tuple()],
	Index  :: integer(), % 权重位在哪个位置
	Num    :: integer(), % 抽取数量
	Repeat :: boolean(), % 是否放回
	Return :: [any()].
%%-----------------------------------------------
weight(List = [H | _], Num, Repeat) ->
	weight(List, erlang:size(H), Num, Repeat).

weight(List, Index, Num, Repeat) ->
	case Repeat of
		true  -> weight_repeat(List, Index, Num);
		false -> weight_norepeat(List, Index, Num)
	end.


%%-----------------------------------------------
%% @doc 打乱列表顺序
-spec shuffle(list()) ->
	list().
%%-----------------------------------------------
shuffle(List) ->
	Max = length(List) + 10000,
	[E || {_, E} <- lists:sort([{random(1, Max), X} || X <- List])].

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
choose_repeat(List, Num) ->
	do_choose_repeat(List, Num, []).

do_choose_repeat(_List, 0, Acc) ->
	Acc;
do_choose_repeat(List, Num, Acc) ->
	Nth  = uniform( length(List) ),
	Elem = lists:nth(Nth, List),
	do_choose_repeat(List, Num-1, [Elem | Acc]).

choose_norepeat(List, Num) when length(List) < Num ->
	error;
choose_norepeat(List, Num) when length(List) == Num ->
	List;
choose_norepeat(List, Num) ->
	do_choose_norepeat(List, Num, []).

do_choose_norepeat(_List, 0, Acc) ->
	Acc;
do_choose_norepeat(List, Num, Acc) ->
	Nth   = uniform( length(List) ),
	Elem  = lists:nth(Nth, List),
	List2 = lists:delete(Elem, List),
	do_choose_norepeat(List2, Num-1, [Elem | Acc]).

weight_repeat(List, Index, Num) ->
	do_weight_repeat(List, Index, Num, []).

do_weight_repeat(_List, _Index, 0, Acc) ->
	Acc;
do_weight_repeat(List, Index, Num, Acc) ->
	{_Nth, Elem} = do_weight(List, Index),
	Elem2 = split_weight(Elem, Index),
	do_weight_repeat(List, Index, Num-1, [Elem2 | Acc]).

weight_norepeat(List, _Index, Num) when length(List) < Num ->
	error;
weight_norepeat(List, Index, Num) when length(List) == Num ->
	[split_weight(Elem, Index) || Elem <- List];
weight_norepeat(List, Index, Num) ->
	do_weight_norepeat(List, Index, Num, []).

do_weight_norepeat(_List, _Index, 0, Acc) ->
	Acc;
do_weight_norepeat(List, Index, Num, Acc) ->
	{_Nth, Elem} = do_weight(List, Index),
	List2 = lists:delete(Elem, List),
	Elem2 = split_weight(Elem, Index),
	do_weight_norepeat(List2, Index, Num-1, [Elem2 | Acc]).

do_weight(List, Index) ->
	Sum = lists:sum([element(Index, Elem) || Elem <- List]),
	hit_weight(List, Index, random(1, Sum), 1, 0).

hit_weight([Elem | T], Index, Random, Nth, SumWt) ->
	SumWt2 = element(Index, Elem) + SumWt,
	case Random =< SumWt2 of
		true  ->
			{Nth, Elem};
		false ->
			hit_weight(T, Index, Random, Nth+1, SumWt2)
	end.

split_weight(Elem, Index) ->
	case erlang:delete_element(Index, Elem) of
		{Elem1} -> Elem1;
		Elem1   -> Elem1
	end.

uniform(N) ->
	case rand:export_seed() == ?nil of
	    true  ->
	        <<A:32, B:32, C:32>> = crypto:strong_rand_bytes(12),
		    rand:seed(exs1024, {A, B, C});
	    false ->
	    	ignore
	end,
    rand:uniform(N).

%%-----------------------------------------------
%% 算法: A-Res
%% 输入: 样本序列 V，长度未知，第 i 个样本 vi 的权重为 wi
%% 输出: 长度为 m 的结果集合 R
%%  
%% foreach vi in V (i = 1, 2, ...):
%%    ki = rand(0, 1) ^ (1 / wi)
%%    if i <= m:
%%       (vi, ki) 加入 R
%%    else:
%%       (vt, kt) = min k ∈ R // Aulddays: 选出 R 中 k 最小的那个样本
%%       if ki > kt:
%%          (vi, ki) 替换 (vt, kt)
%%
%% 当 wi 值为一般权重而非概率值时，可能会是一个很大的数值，从而使得 ki 的
%% 指数操作可能会丢失精度。这种情况下可以对 ki 取 log() 而变成 
%% ki = log(rand(0, 1)) / wi，因为后续在各个 ki 之间只涉及比较相对大小
%% 而不是绝对值， 所以可以保证精度的同时不影响结果。
%%-----------------------------------------------
% do_weight(List, Index, M) ->
% 	Heap = ut_heap:new(
% 		1000,
% 		fun({_,K1,_}, {_,K2,_}) -> K1 < K2 end,
% 		fun({I,_,_}) -> I end
% 	),
% 	{_, Heap2} = lists:foldl(fun
% 		(Elem, {I, AccHeap}) ->
% 			Wi = element(Index, Elem),
% 			Ki = math:log(rand:uniform_real()) / Wi,
% 			% math:pow(rand:uniform_real(), 1 / Wi),
% 			?debug(role_util:get_id() == 100000100000000001, "Ki--------------:~w", [Ki]),
% 			case I =< M of
% 				true  ->
% 					{ok, AccHeap2} = ut_heap:insert(AccHeap, {I,Ki,Elem}),
% 					{I+1, AccHeap2};
% 				false ->
% 					{_,Kt,_} = ut_heap:top(AccHeap),
% 					case Ki > Kt of
% 						true  ->
% 							{ok, _, AccHeap1} = ut_heap:remove(AccHeap),
% 							{ok, AccHeap2} = ut_heap:insert(AccHeap1, {I,Ki,Elem}),
% 							{I+1, AccHeap2};
% 						false ->
% 							{I+1, AccHeap}
% 					end
% 			end
% 	end, {1, Heap}, List),
% 	?debug(role_util:get_id() == 100000100000000001, "-----------------:~w", [Heap2]),
% 	do_weight2(Heap2, []).
