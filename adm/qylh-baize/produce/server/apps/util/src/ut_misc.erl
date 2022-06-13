%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(ut_misc).

%% API
-export([
	is_unique/1,
	maps_increase/3,
	maps_append/3,
	maps_delete/3,
	paginate/3,
	cancel_timer/1,
	until_next_minute/0
]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%%-----------------------------------------------
%% @ 检查列表元素是否唯一
-spec is_unique(list()) ->
	boolean().
%%-----------------------------------------------
is_unique(List) ->
	lists:sort(List) == lists:usort(List).


%%-----------------------------------------------
%% @doc 把 Map 中键值为 Key 的整数增加 Incr
-spec maps_increase(any(), integer(), map()) ->
	map().
%%-----------------------------------------------
maps_increase(Key, Incr, Map) ->
    maps:update_with(Key, fun(N) -> N + Incr end, Incr, Map).


%%-----------------------------------------------
%% @doc 把 List | Elem 添加到 Map 中键值为 Key 的列表
-spec maps_append(any(), list() | any(), map()) ->
	map().
%%-----------------------------------------------
maps_append(Key, List, Map) when is_list(List) ->
	maps:update_with(Key, fun(L) -> List ++ L end, List, Map);
maps_append(Key, Elem, Map) ->
	maps:update_with(Key, fun(L) -> [Elem | L] end, [Elem], Map).


%%-----------------------------------------------
%% @doc 把 Elem 从 Map 中键值为 Key 的列表中删除
-spec maps_delete(any(), any(), map()) ->
	any().
%%-----------------------------------------------
maps_delete(Key, Elem, Map) ->
	maps:update_with(Key, fun(L) -> lists:delete(Elem, L) end, [], Map).


%%-----------------------------------------------
%% @doc 分页
-spec paginate(List, Size, Page) -> Return when
	List   :: list(),    % 要进行分页列表
	Size   :: integer(), % 每页的长度
	Page   :: integer(), % 第几页
	Return :: {Total :: integer(), list()}.
%%-----------------------------------------------
paginate(List, Size, Page) ->
	Total = max(1, ut_math:ceil(length(List) / Size)),
    List2 = case Page > Total of
    	true  -> [];
    	false -> lists:sublist(List, Size*(Page-1)+1, Size)
    end,
    {Total, List2}.

cancel_timer(TimerRef) ->
	is_reference(TimerRef) andalso erlang:cancel_timer(TimerRef).


until_next_minute() ->
	{_, _, S} = ut_time:time(),
	case S == 0 of
		true  -> 0;
		false -> 60 - S
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
