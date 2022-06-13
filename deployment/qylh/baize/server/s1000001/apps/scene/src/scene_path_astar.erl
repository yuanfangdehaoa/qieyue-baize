%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(scene_path_astar).

-include("game.hrl").
-include("scene.hrl").
-include("proto.hrl").

%% API
-export([find/3]).

-record(anode, {key, tx, ty, f, g, h, parent}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
find(SceneID, SrcCoord, DstCoord) ->
	{SrcTX, SrcTY} = ?tile(SrcCoord),
	{DstTX, DstTY} = ?tile(DstCoord),
	G = 0,
	H = h_cost(SrcTX, SrcTY, DstTX, DstTY),
	Node = make_node(SrcTX, SrcTY, G, H, ?nil),
	Open = ut_heap:new(2000, fun less/2, fun getkey/1),
	{ok, Open2} = ut_heap:insert(Open, Node),
	% ?debug("find============:~w", [{SrcTX, SrcTY, DstTX, DstTY}]),
	find_path(SceneID, {DstTX,DstTY}, Open2, #{}).

% find(SceneID) ->
% 	{SrcTX, SrcTY} = {3, 5},
% 	{DstTX, DstTY} = {7, 6},
% 	G = 0,
% 	H = h_cost(SrcTX, SrcTY, DstTX, DstTY),
% 	Node = make_node(SrcTX, SrcTY, G, H, ?nil),
% 	Open = ut_heap:new(2000, fun less/2, fun getkey/1),
% 	{ok, Open2} = ut_heap:insert(Open, Node),
% 	?debug("find============:~w", [{SrcTX, SrcTY, DstTX, DstTY}]),
% 	find_path(SceneID, {DstTX,DstTY}, Open2, #{}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
find_path(SceneID, DstPos, Open, Close) ->
	case ut_heap:remove(Open) of
		{ok, Node, Open1} ->
			% ?debug("path----------:~w", [Node#anode.key]),
			Close1 = maps:put(Node#anode.key, Node, Close),
			case find_next(SceneID, DstPos, Node, Open1, Close1) of
				{ok, Open2, Close2} ->
					case maps:is_key(DstPos, Close2) of
						true  ->
							build_path(DstPos, Close2, []);
						false ->
							find_path(SceneID, DstPos, Open2, Close2)
					end;
				_R ->
					?debug("11111111--------:~w", [_R]),
					false
			end;
		{error, _} =R ->
			?debug("222222================:~w", [R]),
			false
	end.

build_path(Pos, Close, Path) ->
	% ?debug("build_path:~w", [Path]),
	case maps:find(Pos, Close) of
		{ok, Node} ->
			Path2 = [Node#anode.key | Path],
			build_path(Node#anode.parent, Close, Path2);
		error ->
			Path2 = [#p_coord{
		        x = TX*?TILE_WIDTH + ?TILE_WIDTH/2,
		        y = TY*?TILE_HEIGHT + ?TILE_HEIGHT/2
		    } || {TX,TY} <- Path],
			{ok, Path2}
	end.

find_next(SceneID, DstPos, CurNode, Open, Close) ->
	Around = [
		            {0, 1,10},
		{-1, 0,10},            {1, 0,10},
		            {0,-1,10}
	],
	find_next2(Around, SceneID, DstPos, CurNode, Open, Close).

find_next2([{OffsetX,OffsetY,OffsetG} | T], SceneID, DstPos={DstTX,DstTY}, CurNode, Open, Close) ->
	TX = CurNode#anode.tx + OffsetX,
	TY = CurNode#anode.ty + OffsetY,
	IfIgnore = maps:is_key({TX,TY}, Close) orelse (not walkable(SceneID, TX, TY)),
	% ?debug("ignore:~w", [{TX,TY,maps:is_key({TX,TY}, Close),walkable(SceneID, TX, TY)}]),
	case IfIgnore of
		true  ->
			find_next2(T, SceneID, DstPos, CurNode, Open, Close);
		false ->
			G = CurNode#anode.g + OffsetG,
			H = h_cost(TX, TY, DstTX, DstTY),
			NewNode = make_node(TX, TY, G, H, CurNode#anode.key),
			case ut_heap:find(Open, NewNode#anode.key) of
				{ok, OldNode} ->
					% ?debug("in open------>~w", [{NewNode, OldNode}]),
					case less(NewNode, OldNode) of
						true  ->
							OldNode2 = OldNode#anode{
								parent = CurNode#anode.key,
								g      = G,
								f      = G + OldNode#anode.h
							},
							{ok, Open2} = ut_heap:update(Open, OldNode2),
							% ?debug("------------->~w", [{OldNode, OldNode2, Open2}]),
							find_next2(T, SceneID, DstPos, CurNode, Open2, Close);
						false ->
							find_next2(T, SceneID, DstPos, CurNode, Open, Close)
					end;
				{error, _} ->
					% ?debug("not in open------>~w", [{NewNode}]),
					case ut_heap:insert(Open, NewNode) of
						{ok, Open2} ->
							find_next2(T, SceneID, DstPos, CurNode, Open2, Close);
						{error, _} = R ->
							?debug("333333-------------:~w", [R]),
							false
					end
			end
	end;
find_next2([], _SceneID, _DstPos, _CurNode, Open, Close) ->
	{ok, Open, Close}.


make_node(TX, TY, G, H, Parent) ->
	#anode{key={TX,TY}, tx=TX, ty=TY, f=G+H, g=G, h=H, parent=Parent}.

less(Node1, Node2) ->
	Node1#anode.f =< Node2#anode.f.

getkey(Node) ->
	Node#anode.key.

h_cost(TX1, TY1, TX2, TY2) ->
	10 * (abs(TX2-TX1) + abs(TY2-TY1)).

walkable(SceneID, TX, TY) ->
	scene_config:walkable(SceneID, TX, TY).

% walkable(_SceneID, TX, TY) ->
% 	element(TX, element(TY, scene())) == 0.

% scene() ->
% 	{
% 		{1, 1, 1, 1, 1, 1, 1, 1, 1},
% 		{1, 0, 0, 0, 0, 0, 0, 0, 1},
% 		{1, 0, 0, 0, 1, 0, 0, 0, 1},
% 		{1, 0, 1, 0, 1, 0, 0, 0, 1},
% 		{1, 0, 0, 1, 1, 1, 0, 1, 1},
% 		{1, 1, 1, 1, 1, 1, 0, 0, 1},
% 		{1, 0, 0, 0, 0, 0, 0, 0, 1},
% 		{1, 1, 1, 1, 1, 1, 1, 1, 1}
% 	}.