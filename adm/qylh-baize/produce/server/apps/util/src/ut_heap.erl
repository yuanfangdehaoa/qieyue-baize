%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(ut_heap).

-include("game.hrl").

%% API
-export([new/3]).
-export([top/1]).
-export([insert/2]).
-export([remove/1]).
-export([update/2]).
-export([find/2]).
-export([is_full/1]).
-export([is_empty/1]).

-record(heap, {
      cap
    , less
    , key
    , size
    , data
    , index
}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
new(Cap, Less, GetKey) ->
    #heap{cap=Cap, less=Less, key=GetKey, size=0, data={}, index=#{}}.

top(Heap) ->
    case is_empty(Heap) of
        true  ->
            {error, empty};
        false ->
            erlang:element(1, Heap#heap.data)
    end.

insert(Heap, Elem) ->
    case is_full(Heap) of
        true  ->
            {error, full};
        false ->
            #heap{size=Size, data=Data, index=Index, key=GetKey} = Heap,
            Data2  = erlang:append_element(Data, Elem),
            Size2  = Size + 1,
            Index2 = maps:put(GetKey(Elem), Size2, Index),
            Heap1  = Heap#heap{size=Size2, data=Data2, index=Index2},
            Heap2  = percolate_up(Heap1),
            {ok, Heap2}
    end.

remove(Heap) ->
    case is_empty(Heap) of
        true  ->
            {error, empty};
        false when Heap#heap.size == 1 ->
            Elem  = element(1, Heap#heap.data),
            Heap2 = Heap#heap{size=0, data={}, index=#{}},
            {ok, Elem, Heap2};
        false ->
            #heap{size=Size, data=Data, index=Index, key=GetKey} = Heap,
            Elem1  = element(1, Data),
            Elem2  = element(Size, Data),
            Data1  = setelement(1, Data, Elem2),
            Data2  = erlang:delete_element(Size, Data1),
            Size2  = Size - 1,
            Index1 = maps:remove(GetKey(Elem1), Index),
            Index2 = maps:put(GetKey(Elem2), 1, Index1),
            Heap1  = Heap#heap{size=Size2, data=Data2, index=Index2},
            Heap2  = percolate_dn(Heap1),
            {ok, Elem1, Heap2}
    end.

update(Heap, Elem) ->
    #heap{less=Less, key=GetKey, data=Data, index=Index} = Heap,
    case maps:find(GetKey(Elem), Index) of
        {ok, Pos} ->
            Data2 = setelement(Pos, Data, Elem),
            Heap1 = Heap#heap{data=Data2},
            Heap2 = case Pos =< 1 of
                true  ->
                    percolate_dn(Heap1);
                false ->
                    ParentPos = get_parent_pos(Pos),
                    case Less(Elem, element(ParentPos, Data)) of
                        true  ->
                            percolate_up2(Pos, ParentPos, Heap1);
                        false ->
                            LChildPos = get_lchild_pos(Pos),
                            RChildPos = get_rchild_pos(Pos),
                            percolate_dn2(Pos, LChildPos, RChildPos, Heap1)
                    end
            end,
            {ok, Heap2};
        {error, _}  ->
            {error, not_found}
    end.

find(Heap, Key) ->
    #heap{data=Data, index=Index} = Heap,
    case maps:find(Key, Index) of
        {ok, Pos} when size(Data) >= Pos ->
            {ok, element(Pos, Data)};
        {ok, Pos} ->
            ?debug("find error:------------->~w", [{Pos, size(Data), Data}]),
            {error, not_found};
        error ->
            {error, not_found}
    end.

is_full(Heap) ->
    Heap#heap.size >= Heap#heap.cap.

is_empty(Heap) ->
    Heap#heap.size == 0.


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
percolate_up(Heap) ->
    ChildPos  = Heap#heap.size,
    ParentPos = get_parent_pos(ChildPos),
    percolate_up2(ChildPos, ParentPos, Heap).

percolate_up2(ChildPos, ParentPos, Heap) when ParentPos >= 1 ->
    #heap{less=Less, data=Data} = Heap,
    Child  = element(ChildPos, Data),
    Parent = element(ParentPos, Data),
    case Less(Child, Parent) of
        true  ->
            Heap2 = swap(ChildPos, ParentPos, Heap),
            ChildNew  = ParentPos,
            ParentNew = get_parent_pos(ChildNew),
            percolate_up2(ChildNew, ParentNew, Heap2);
        false ->
            Heap
    end;
percolate_up2(_ChildPos, _ParentPos, Heap) ->
    Heap.


percolate_dn(Heap) ->
    ParentPos = 1,
    LChildPos = get_lchild_pos(ParentPos),
    RChildPos = get_rchild_pos(ParentPos),
    percolate_dn2(ParentPos, LChildPos, RChildPos, Heap).

percolate_dn2(ParentPos, LChildPos, RChildPos, Heap) when LChildPos < Heap#heap.size ->
    #heap{less=Less, data=Data} = Heap,
    Parent = element(ParentPos, Data),
    LChild = element(LChildPos, Data),
    RChild = element(RChildPos, Data),
    case Less(LChild, RChild) of
        true  ->
            case Less(Parent, LChild) of
                false ->
                    Heap2 = swap(ParentPos, LChildPos, Heap),
                    ParentNew = LChildPos,
                    LChildNew = get_lchild_pos(ParentNew),
                    RChildNew = get_rchild_pos(ParentNew),
                    percolate_dn2(ParentNew, LChildNew, RChildNew, Heap2);
                true  ->
                    Heap
            end;
        false ->
            case Less(Parent, RChild) of
                false ->
                    Heap2 = swap(ParentPos, RChildPos, Heap),
                    ParentNew = RChildPos,
                    LChildNew = get_lchild_pos(ParentNew),
                    RChildNew = get_rchild_pos(ParentNew),
                    percolate_dn2(ParentNew, LChildNew, RChildNew, Heap2);
                true  ->
                    Heap
            end
    end;
percolate_dn2(ParentPos, LChildPos, _RChildPos, Heap) when LChildPos == Heap#heap.size ->
    #heap{less=Less, data=Data} = Heap,
    Parent = element(ParentPos, Data),
    LChild = element(LChildPos, Data),
    case Less(Parent, LChild) of
        false ->
            Heap2 = swap(ParentPos, LChildPos, Heap),
            ParentNew = LChildPos,
            LChildNew = get_lchild_pos(ParentNew),
            RChildNew = get_rchild_pos(ParentNew),
            percolate_dn2(ParentNew, LChildNew, RChildNew, Heap2);
        true  ->
            Heap
    end;
percolate_dn2(_ParentPos, _LChildPos, _RChildPos, Heap) ->
    Heap.


get_parent_pos(Pos) ->
    ut_math:floor(Pos / 2).

get_lchild_pos(Pos) ->
    2 * Pos.

get_rchild_pos(Pos) ->
    2 * Pos + 1.

swap(Pos1, Pos2, Heap) ->
    #heap{data=Data, key=GetKey, index=Index} = Heap,
    Elem1  = element(Pos1, Data),
    Elem2  = element(Pos2, Data),
    Data1  = setelement(Pos1, Data, Elem2),
    Data2  = setelement(Pos2, Data1, Elem1),
    Index1 = maps:put(GetKey(Elem1), Pos2, Index),
    Index2 = maps:put(GetKey(Elem2), Pos1, Index1),
    Heap#heap{data=Data2, index=Index2}.
