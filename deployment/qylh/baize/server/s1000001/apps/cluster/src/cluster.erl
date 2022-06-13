%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(cluster).

-include("cluster.hrl").
-include("game.hrl").
-include("errno.hrl").
-include("table.hrl").

%% API
-export([is_center/0, is_center/1]).
-export([is_cross/0, is_cross/1]).
-export([is_local/0, is_local/1]).
-export([is_same/2]).

-export([get_center/0]).
-export([get_cross/1]).
-export([get_local/1]).

-export([get_locals/0, get_locals/1, get_locals/2]).

-export([rpc_call_center/3]).
-export([rpc_call_cross/4]).
-export([rpc_call_local/4]).
-export([rpc_call_node/4]).

-export([rpc_cast_center/3]).
-export([rpc_cast_cross/4]).
-export([rpc_cast_local/4]).
-export([rpc_cast_node/4]).

-export([gen_call_center/2]).
-export([gen_call_cross/3]).
-export([gen_call_local/3]).
-export([gen_call_node/3]).

-export([gen_cast_center/2]).
-export([gen_cast_cross/3]).
-export([gen_cast_local/3]).
-export([gen_cast_node/3]).

-export([notify/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%%-----------------------------------------------
%% @doc 是否中心服
-spec is_center() ->
	boolean().
%%-----------------------------------------------
is_center() ->
	is_center(game_env:get_type()).

is_center(Type) ->
	Type == ?SERVER_TYPE_CENTER.

%%-----------------------------------------------
%% @doc 是否跨服
-spec is_cross() ->
	boolean().
%%-----------------------------------------------
is_cross() ->
	is_cross(game_env:get_type()).

is_cross(Type) ->
	Type == ?SERVER_TYPE_CROSS.

%%-----------------------------------------------
%% @doc 是否游戏服
-spec is_local() ->
	boolean().
%%-----------------------------------------------
is_local() ->
	is_local(game_env:get_type()).

is_local(Type) ->
	Type == ?SERVER_TYPE_LOCAL.


%%-----------------------------------------------
%% @doc 是否同一个服
-spec is_same(integer(), integer()) ->
	boolean().
%%-----------------------------------------------
is_same(SUID1, SUID2) ->
	case SUID1 == SUID2 of
		true  ->
			true;
		false ->
			case ets:lookup(?ETS_CLUSTER_INDEX, SUID1) of
				[#cls_index{merge=MergeTo1}] ->
					case ets:lookup(?ETS_CLUSTER_INDEX, SUID2) of
						[#cls_index{merge=MergeTo2}] ->
							if
								MergeTo1 == 0,
								MergeTo2 == 0 ->
									SUID1 == SUID2;
								MergeTo1 == 0 ->
									MergeTo2 == SUID1;
								MergeTo2 == 0 ->
									MergeTo1 == SUID2;
								true ->
									MergeTo1 == MergeTo2
							end;
						_ ->
							false
					end;
				_ ->
					false
			end
	end.

%%-----------------------------------------------
%% @doc 获取中心服节点
-spec get_center() ->
	node() | undefined.
%%-----------------------------------------------
get_center() ->
	game_env:get_center().

%%-----------------------------------------------
%% @doc 获取跨服节点(只能在游戏服调用)
-spec get_cross(integer()) ->
	node() | undefined.
%%-----------------------------------------------
get_cross(Rule) ->
	case is_local() of
		true  ->
			case cluster_util:get_cross_node(Rule) of
				?nil -> throw(?ERR_GAME_NO_CROSS);
				Node -> Node#cls_node.name
			end;
		false ->
			throw(only_call_in_local)
	end.

%%-----------------------------------------------
%% @doc 根据角色id获取其所在的游戏节点(游戏服节点不能调用)
-spec get_local(integer()) ->
	node() | undefined.
%%-----------------------------------------------
get_local(RoleID) ->
	case is_local() of
		true  ->
			throw(cannot_call_in_local);
		false ->
			SUID = game_uid:guid2suid(RoleID),
			Node = cluster_util:get_node(SUID),
			Node#cls_node.name
	end.


%%-----------------------------------------------
%% @doc 获取连到同一跨服的游戏服列表
-spec get_locals(RetType :: suid | node, integer()) ->
	[integer() | #cls_node{}].
%%-----------------------------------------------
get_locals() ->
	get_locals(node).

get_locals(suid) ->
	case is_center() of
		true  -> throw(cannot_call_in_center);
		false -> cluster_util:get_local_suids()
	end;
get_locals(node) ->
	case is_center() of
		true  -> throw(cannot_call_in_center);
		false -> cluster_util:get_local_nodes()
	end;
get_locals(Rule) ->
	get_locals(node, Rule).

get_locals(suid, Rule) ->
	case is_center() of
		true  -> throw(cannot_call_in_center);
		false -> cluster_util:get_local_suids(Rule)
	end;
get_locals(node, Rule) ->
	case is_center() of
		true  -> throw(cannot_call_in_center);
		false -> cluster_util:get_local_nodes(Rule)
	end.


rpc_call_center(M, F, A) ->
	cluster_util:call_node(get_center(), M, F, A).

rpc_call_cross(Rule, M, F, A) ->
	cluster_util:call_node(get_cross(Rule), M, F, A).

rpc_call_local(RoleID, M, F, A) ->
	case is_local() of
		true  -> rpc_call_center(?MODULE, rpc_call_local, [RoleID, M, F, A]);
		false -> cluster_util:call_node(get_local(RoleID), M, F, A)
	end.

rpc_call_node(Node, M, F, A) ->
	case is_local() of
		true  -> rpc_call_center(?MODULE, rpc_call_node, [Node, M, F, A]);
		false -> cluster_util:call_node(Node, M, F, A)
	end.


rpc_cast_center(M, F, A) ->
	cluster_util:cast_node(get_center(), M, F, A).

rpc_cast_cross(Rule, M, F, A) ->
	cluster_util:cast_node(get_cross(Rule), M, F, A).

rpc_cast_local(RoleID, M, F, A) ->
	case is_local() of
		true  -> rpc_cast_center(?MODULE, rpc_cast_local, [RoleID, M, F, A]);
		false -> cluster_util:cast_node(get_local(RoleID), M, F, A)
	end.

rpc_cast_node(Node, M, F, A) ->
	case is_local() of
		true  -> rpc_cast_center(?MODULE, rpc_cast_node, [Node, M, F, A]);
		false -> cluster_util:cast_node(Node, M, F, A)
	end.


gen_call_center(ServName, Req) ->
	cluster_util:gen_call(get_center(), ServName, Req).

gen_call_cross(Rule, ServName, Req) ->
	cluster_util:gen_call(get_cross(Rule), ServName, Req).

gen_call_local(RoleID, ServName, Req) ->
	case is_local() of
		true  -> rpc_call_center(?MODULE, gen_call_local, [RoleID, ServName, Req]);
		false -> cluster_util:gen_call(get_local(RoleID), ServName, Req)
	end.

gen_call_node(Node, ServName, Req) ->
	case is_local() of
		true  -> rpc_call_center(?MODULE, gen_call_node, [Node, ServName, Req]);
		false -> cluster_util:gen_call(Node, ServName, Req)
	end.


gen_cast_center(ServName, Msg) ->
	cluster_util:gen_cast(get_center(), ServName, Msg).

gen_cast_cross(Rule, ServName, Msg) ->
	cluster_util:gen_cast(get_cross(Rule), ServName, Msg).

gen_cast_local(RoleID, ServName, Msg) ->
	case is_local() of
		true  -> rpc_cast_center(?MODULE, gen_cast_node, [RoleID, ServName, Msg]);
		false -> cluster_util:gen_cast(get_local(RoleID), ServName, Msg)
	end.

gen_cast_node(Node, ServName, Msg) ->
	case is_local() of
		true  -> rpc_cast_center(?MODULE, gen_cast_node, [Node, ServName, Msg]);
		false -> cluster_util:gen_cast(Node, ServName, Msg)
	end.


%% 跨服广播
notify(Rule, MsgNo, Args) when is_integer(Rule) ->
	Nodes = get_locals(Rule),
	lists:foreach(fun
		(Node) ->
			rpc_cast_node(Node, game_notify, notify, [MsgNo, Args])
	end, Nodes);
notify(SUIDs, MsgNo, Args) ->
	lists:foreach(fun
		(SUID) ->
			rpc_cast_node(SUID, game_notify, notify, [MsgNo, Args])
	end, SUIDs).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------

