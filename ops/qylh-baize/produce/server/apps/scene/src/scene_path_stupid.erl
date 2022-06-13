%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(scene_path_stupid).

-include("scene.hrl").
-include("proto.hrl").

%% API
-export([find/3, find/4]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
find(SceneID, SrcCoord, DstCoord) ->
	find(SceneID, SrcCoord, DstCoord, 1000).

find(SceneID, SrcCoord, DstCoord, Step) ->
	case find_path(Step, SceneID, ?tile(SrcCoord), ?tile(DstCoord), []) of
		{ok, Path} ->
			Path2 = [#p_coord{
		        x = TX*?TILE_WIDTH + ?TILE_WIDTH/2,
		        y = TY*?TILE_HEIGHT + ?TILE_HEIGHT/2
		    } || {TX,TY} <- Path],
			{ok, Path2};
		false ->
			false
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
find_path(0, _SceneID, _CurPos, _DstPos, _Path) ->
	false;
find_path(_, _SceneID, DstPos, DstPos, Path) ->
	{ok, lists:reverse(Path)};
find_path(N, SceneID, {CurTX, CurTY}, DstPos={DstTX, DstTY}, Path) ->
	case find_next_pos(SceneID, CurTX, CurTY, DstTX, DstTY) of
		false ->
			false;
		NextPos when NextPos == DstPos ->
			{ok, lists:reverse([NextPos | Path])};
		NextPos ->
			case lists:member(NextPos, Path) of
				true  ->
					false;
				false ->
					Path2 = [NextPos | Path],
					find_path(N-1, SceneID, NextPos, DstPos, Path2)
			end
	end.

find_next_pos(SceneID, CurTX, CurTY, DstTX, DstTY) ->
	PosList = if
		CurTX == DstTX, CurTY == DstTY ->
			[];
		CurTX == DstTX, CurTY < DstTY -> % 目标在正上方
			[{CurTX,CurTY+1}, {CurTX-1,CurTY+1}, {CurTX+1,CurTY+1}];
		CurTX == DstTX, CurTY > DstTY -> % 目标在正下方
			[{CurTX,CurTY-1}, {CurTX-1,CurTY-1}, {CurTX+1,CurTY-1}];

		CurTX < DstTX, CurTY == DstTY -> % 目标在正右方
			[{CurTX+1,CurTY}, {CurTX+1,CurTY-1}, {CurTX+1,CurTY+1}];
		CurTX < DstTX, CurTY < DstTY  -> % 目标在右上方
			[{CurTX+1,CurTY+1}, {CurTX+1,CurTY}, {CurTX,CurTY+1}];
		CurTX < DstTX, CurTY > DstTY  -> % 目标在右下方
			[{CurTX+1,CurTY-1}, {CurTX+1,CurTY}, {CurTX,CurTY-1}];

		CurTX > DstTX, CurTY == DstTY -> % 目标在正左方
			[{CurTX-1,CurTY}, {CurTX-1,CurTY-1}, {CurTX-1,CurTY+1}];
		CurTX > DstTX, CurTY < DstTY  -> % 目标在左上方
			[{CurTX-1,CurTY+1}, {CurTX-1,CurTY}, {CurTX,CurTY+1}];
		CurTX > DstTX, CurTY > DstTY  -> % 目标在左下方
			[{CurTX-1,CurTY-1}, {CurTX-1,CurTY}, {CurTX,CurTY-1}]
	end,
	find_next_pos2(PosList, SceneID).

find_next_pos2([{TX,TY} | T], SceneID) ->
	case scene_config:walkable(SceneID, TX, TY) of
		true  -> {TX, TY};
		false -> find_next_pos2(T, SceneID)
	end;
find_next_pos2([], _SceneID) ->
	false.