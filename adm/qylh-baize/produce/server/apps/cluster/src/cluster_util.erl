%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(cluster_util).

-include("cluster.hrl").
-include("game.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("table.hrl").

%% API
-export([connect_center/1]).
-export([push_data/0]).
-export([pull_data/1]).
-export([add_index/1]).
-export([del_index/1]).
-export([get_cross_suid/1]).
-export([get_local_suids/0, get_local_suids/1]).
-export([get_cross_node/1]).
-export([get_local_nodes/0, get_local_nodes/1]).
-export([get_node/1]).
-export([get_nodes/0, get_nodes/1]).
-export([call_node/4]).
-export([cast_node/4]).
-export([gen_call/3]).
-export([gen_cast/3]).
-export([divide/4]).

-define(DEFAULT_TIMEOUT, 3000).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
connect_center(Center) ->
	SUID = game_env:get_suid(),
	Type = game_env:get_type(),
	case Type of
		?SERVER_TYPE_LOCAL ->
			OTime = game_env:get_opened_time(),
			Level = world_level:get_level(),
			#merge{suids=Merge} = game_misc:read(merge, #merge{});
		?SERVER_TYPE_CROSS ->
			OTime = game_env:get_opened_time(),
			Level = 0,
			Merge = []
	end,
	Node = #cls_node{
		suid  = SUID,
		type  = Type,
		name  = node(),
		otime = OTime,
		level = Level,
		merge = Merge,
		conn  = true,
		group = #{}
	},
	cluster_center:conn(Center, Node).

push_data() ->
	SUID = game_env:get_suid(),
	Data = #{
		level => world_level:get_level(),
		name  => node()
	},
	cluster_center:push(game_env:get_center(), SUID, Data).

pull_data(SUIDs) ->
	cluster_center:pull(game_env:get_center(), SUIDs).

add_index(Node) ->
	ets:insert(?ETS_CLUSTER_INDEX, #cls_index{
		suid  = Node#cls_node.suid,
		name  = Node#cls_node.name,
		node  = Node,
		merge = 0
	}),
	lists:foreach(fun
		(NodeID) ->
			ets:insert(?ETS_CLUSTER_INDEX, #cls_index{
				suid  = NodeID,
				name  = Node#cls_node.name,
				node  = Node,
				merge = Node#cls_node.suid
			})
	end, Node#cls_node.merge).

del_index(Node) ->
	ets:delete(?ETS_CLUSTER_INDEX, Node#cls_node.suid),
	lists:foreach(fun
		(NodeID) ->
			ets:delete(?ETS_CLUSTER_INDEX, NodeID)
	end, Node#cls_node.merge).

get_cross_suid(Rule) ->
	case ets:lookup(?ETS_CLUSTER_GROUP, Rule) of
		[#cls_group{cross=CrossID}] ->
			CrossID;
		[] ->
			0
	end.

get_cross_node(Rule) ->
	case ets:lookup(?ETS_CLUSTER_GROUP, Rule) of
		[#cls_group{cross=CrossID}] ->
			get_node(CrossID);
		[] ->
			?nil
	end.

get_local_suids() ->
	[SUID ||
		#cls_index{suid=SUID, node=Node, merge=MergeTo} <- ets:tab2list(?ETS_CLUSTER_INDEX),
		MergeTo == 0,
		cluster:is_local(Node#cls_node.type)
	].

get_local_suids(Rule) ->
	case ets:lookup(?ETS_CLUSTER_GROUP, Rule) of
		[#cls_group{locals=SUIDs}] ->
			SUIDs;
		[] ->
			[]
	end.

get_local_nodes() ->
	[Node ||
		#cls_index{node=Node, merge=MergeTo} <- ets:tab2list(?ETS_CLUSTER_INDEX),
		MergeTo == 0,
		cluster:is_local(Node#cls_node.type)
	].

get_local_nodes(Rule) ->
	case ets:lookup(?ETS_CLUSTER_GROUP, Rule) of
		[#cls_group{locals=SUIDs}] ->
			lists:filtermap(fun
				(SUID) ->
					case get_node(SUID) of
						?nil -> false;
						Node -> {true, Node}
					end
			end, SUIDs);
		[] ->
			[]
	end.


get_node(SUID) ->
	case ets:lookup(?ETS_CLUSTER_INDEX, SUID) of
		[#cls_index{node=Node}] ->
			Node;
		[] ->
			%% 暂时不知道什么原因找不到节点数据了，先去center拿回来放进表里先，记录下日志，分组规则要优化
			?error("could not find Node Data : ~p~n", [{SUID}]),
			case cluster:is_center() of
				true ->
					?nil;
				false ->
					Center = game_env:get_center(),
					case rpc:call(Center, ets, lookup, [?ETS_CLUSTER_INDEX, SUID]) of
						[#cls_index{node=Node}] ->
							Node;
						_ ->
							?error("could not find Node Data in center : ~p~n", [{SUID}]),
							?nil
					end
			end
	end.

get_nodes() ->
	case cluster:is_center() of
		true  -> ets:tab2list(?ETS_CLUSTER_NODES);
		false -> cluster:rpc_call_center(?MODULE, get_nodes, [])
	end.

get_nodes(Type) ->
	case cluster:is_center() of
		true  -> ets:match_object(?ETS_CLUSTER_NODES, #cls_node{type=Type, _='_'});
		false -> cluster:rpc_call_center(?MODULE, get_nodes, [Type])
	end.

call_node(?nil, M, F, A) ->
	?error("bad node: ~p", [{M, F, A}]),
	?err(?ERR_GAME_NO_CROSS);
call_node(Nodes, M, F, A) when is_list(Nodes) ->
	[call_node(Node, M, F, A) || Node <- Nodes];
call_node(Node, M, F, A) ->
	Node2 = ts_node(Node),
	?_if(Node2 /= ?nil, rpc:call(Node2, M, F, A, ?DEFAULT_TIMEOUT)).


cast_node(?nil, M, F, A) ->
	?error("bad node: ~p", [{M, F, A}]),
	?err(?ERR_GAME_NO_CROSS);
cast_node(Nodes, M, F, A) when is_list(Nodes) ->
	[cast_node(Node, M, F, A) || Node <- Nodes];
cast_node(Node, M, F, A) ->
	Node2 = ts_node(Node),
	?_if(Node2 /= ?nil, rpc:cast(Node2, M, F, A)).


gen_call(?nil, Serv, Req) ->
	?error("bad node: ~p", [{Serv, Req}]),
	?err(?ERR_GAME_NO_CROSS);
gen_call(Nodes, Serv, Req) when is_list(Nodes) ->
	Nodes2 = ts_node(Nodes),
	?_if(Nodes2 /= ?nil, gen_server:multi_call(Nodes2, Serv, Req, ?DEFAULT_TIMEOUT));
gen_call(Node, Serv, Req) ->
	Node2 = ts_node(Node),
	?_if(Node2 /= ?nil, gen_server:call({Serv,Node2}, Req, ?DEFAULT_TIMEOUT)).


gen_cast(?nil, Serv, Req) ->
	?error("bad node: ~p", [{Serv, Req}]),
	?err(?ERR_GAME_NO_CROSS);
gen_cast(Nodes, Serv, Req) when is_list(Nodes) ->
	Nodes2 = ts_node(Nodes),
	?_if(Nodes2 /= ?nil, gen_server:abcast(Nodes2, Serv, Req));
gen_cast(Node, Serv, Req) ->
	Node2 = ts_node(Node),
	?_if(Node2 /= ?nil, gen_server:cast({Serv,Node2}, Req)).


divide(Rule, GroupID, CrossNode, LocalNodes) ->
	ets:delete_all_objects(?ETS_CLUSTER_GROUP),
	ets:delete_all_objects(?ETS_CLUSTER_INDEX),
	case ets:lookup(?ETS_CLUSTER_GROUP, Rule) of
		[#cls_group{cross=OldCrossID, locals=OldLocalIDs}] ->
			OldCrossNode = get_node(OldCrossID),
			?_if(OldCrossNode /= ?nil, del_index(OldCrossNode)),
			lists:foreach(fun
				(OldLocalID) ->
					OldLocalNode = get_node(OldLocalID),
					?_if(OldLocalNode /= ?nil, del_index(OldLocalNode))
			end, OldLocalIDs);
		[] ->
			ignore
	end,

	ets:insert(?ETS_CLUSTER_GROUP, #cls_group{
		rule   = Rule,
		group  = GroupID,
		cross  = CrossNode#cls_node.suid,
		locals = [Node#cls_node.suid || Node <- LocalNodes]
	}),

	add_index(CrossNode),
	lists:foreach(fun
		(Node) ->
			add_index(Node)
	end, LocalNodes).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
ts_node(Node) when is_record(Node, cls_node) ->
	Node#cls_node.name;
ts_node(SUID) when is_integer(SUID) ->
%%	[#cls_index{node=Node}] = ets:lookup(?ETS_CLUSTER_INDEX, SUID),
	case case ets:lookup(?ETS_CLUSTER_INDEX, SUID) of
				 [] ->
					 %% 暂时不知道什么原因找不到节点数据了，先去center拿回来放进表里先，记录下日志，分组规则要优化
					 ?error("could not find Node Data : ~p~n", [{SUID}]),
					 case cluster:is_center() of
						 true ->
							 ?nil;
						 false ->
							 Center = game_env:get_center(),
							 case rpc:call(Center, ets, lookup, [?ETS_CLUSTER_INDEX, SUID]) of
								 [ClsNode] ->
									 ClsNode;
								 _ ->
									 ?error("could not find Node Data in center : ~p~n", [{SUID}]),
									 ?nil
							 end
					 end;
				 [ClsNode] ->
					 ClsNode
			 end of
		#cls_index{node=Node} ->
			Node#cls_node.name;
		_ ->
			?nil
	end;
ts_node(Name) when is_atom(Name) ->
	Name;
ts_node(Nodes) when is_list(Nodes) ->
	[ts_node(Node) || Node <- Nodes];
ts_node(Node) ->
	?error("bad node: ~p", [Node]),
	?nil.
