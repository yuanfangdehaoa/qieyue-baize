%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(cluster_center).

-behaviour(gen_server).

-include("activity.hrl").
-include("cluster.hrl").
-include("game.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("table.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([conn/2]).
-export([disconn/2]).
-export([push/3]).
-export([pull/2]).
-export([hook_start/1]).
-export([divide_by_rule2/4]).

-define(SERVER, ?MODULE).

-record(state, {
	  divided = false % 是否已分组
}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

%% 连接中心服
conn(Center, Node) ->
	gen_server:call({?SERVER, Center}, {conn, Node}).

%% 断开连接
disconn(Center, Node) ->
	gen_server:cast({?SERVER, Center}, {disconn, Node}).

%% 游戏服上传数据
push(Center, SUID, Data) ->
	gen_server:cast({?SERVER, Center}, {push, SUID, Data}).

%% 跨服拉取数据
pull(Center, SUIDs) ->
	gen_server:call({?SERVER, Center}, {pull, SUIDs}).

%% 跨服分组
hook_start(ActID) ->
	#cfg_activity{reqs=[{cross,Rule}]} = cfg_activity:find(ActID),
	erlang:send(?SERVER, {divide, Rule}).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	process_flag(trap_exit, true),
	ok = net_kernel:monitor_nodes(true, [{node_type,all}]),

	ets:new(?ETS_CLUSTER_GROUP, [named_table, public, {keypos,#cls_group.group}]),

	ets:new(?ETS_CLUSTER_NODES, [named_table, public, {keypos,#cls_node.suid}]),
	Nodes  = db:dirty_match_all(?DB_CLS_NODE),
	ets:insert(?ETS_CLUSTER_NODES, Nodes),

	ets:new(?ETS_CLUSTER_INDEX, [named_table, public, {keypos,#cls_index.suid}]),
	[cluster_util:add_index(Node) || Node <- Nodes],

	divide_later(),
	{ok, #state{}}.

handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
    ?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
	% 保存游戏服，避免维护中的游戏服没有参与分组
	% 不保存跨服，避免已移除的跨服节点参与分组
	db:clear_table(?DB_CLS_NODE),
	lists:foreach(fun
		(Node=#cls_node{type=Type}) ->
			?_if(
				cluster:is_local(Type),
				db:dirty_write(?DB_CLS_NODE, Node#cls_node{conn=false})
			)
	end, ets:tab2list(?ETS_CLUSTER_NODES)),
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call({pull, SUIDs}, _From, State) ->
	Reply = lists:map(fun
		(SUID) ->
			[Node] = ets:lookup(?ETS_CLUSTER_NODES, SUID),
			Node
	end, SUIDs),
	{reply, Reply, State};

do_handle_call({conn, Node}, _From, State) when not State#state.divided ->
	?info("~p connected", [Node]),
	cluster_util:add_index(Node),
	ets:insert(?ETS_CLUSTER_NODES, Node),
	{reply, ok, State};
do_handle_call({conn, Node}, _From, State) ->
	?info("~p connected", [Node]),
	cluster_util:add_index(Node),
	case ets:lookup(?ETS_CLUSTER_NODES, Node#cls_node.suid) of
		[#cls_node{group=Group, merge=Merge}] when Group /= #{} orelse Merge /= [] ->% 该节点是已有分组或者有其他服合过来了,只保留分组信息，更新节点其他数据
			ets:insert(?ETS_CLUSTER_NODES, Node#cls_node{group=Group}),
			maps:fold(fun
				(Rule, GroupID, _) ->
					%% 通知给分组对应的跨服节点和同组的游戏节点，分组信息有变
					post_divide(Rule, GroupID)
			end, ok, Group);
		_ ->
			ets:insert(?ETS_CLUSTER_NODES, Node),
			case cluster:is_local(Node#cls_node.type) of
				true  ->
					erlang:send(self(), divide);
				false ->
					?_if(if_divide(), erlang:send(self(), divide))
			end
	end,
	{reply, ok, State};

do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.


do_handle_cast({push, SUID, Data}, State) ->
	case ets:lookup(?ETS_CLUSTER_NODES, SUID) of
		[Node] ->
			Node2 = Node#cls_node{
				otime = maps:get(otime, Data, Node#cls_node.otime),
				level = maps:get(level, Data),
				name  = maps:get(name, Data, Node#cls_node.name)
			},
			ets:insert(?ETS_CLUSTER_NODES, Node2);
		[] ->
			?error("node[~w] not found when push data", [SUID])
	end,
	{noreply, State};

do_handle_cast({disconn, Node}, State) ->
	ets:delete(?ETS_CLUSTER_NODES, Node#cls_node.suid),
	cluster_util:del_index(Node),
	{noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.


do_handle_info({nodeup, _Name, _}, State) ->
	{noreply, State};

do_handle_info({nodedown, Name, _}, State) ->
	?info("~w down", [Name]),
	case ets:match_object(?ETS_CLUSTER_NODES, #cls_node{name=Name, _='_'}) of
		[Node] ->
			#cls_node{suid=SUID, type=Type, group=Group} = Node,
			case cluster:is_local(Type) of
				true  ->
					ets:insert(?ETS_CLUSTER_NODES, Node#cls_node{conn=false});
				false ->
					ets:delete(?ETS_CLUSTER_NODES, SUID),
					?_if(Group /= ?nil, set_divide())
			end,
			cluster_util:del_index(Node);
		[] ->
			ignore
	end,
	{noreply, State};

do_handle_info(divide, State) ->
	Pattern = #cls_node{type=?SERVER_TYPE_LOCAL, _='_'},
	case ets:match_object(?ETS_CLUSTER_NODES, Pattern) == [] of
		true  ->
			?info("no server connected, try later"),
			divide_later(),
			{noreply, State};
		false ->
			divide_all(),
			{noreply, State#state{divided=true}}
	end;

do_handle_info({divide, Rule}, State) ->
	% cluster_hook:pre_divide(),
	divide_by_rule(Rule),
	{noreply, State};

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.


divide_all() ->
	ActList = cfg_activity:group(?ACTIVITY_GROUP_CLUSTER),
	{LocalNodes, CrossNodes, MergedSUIDs} = partition_nodes(),
	lists:foreach(fun
		(ActID) ->
			#cfg_activity{reqs=[{cross,Rule}]} = cfg_activity:find(ActID),
			new_divide_by_rule(Rule, LocalNodes, CrossNodes, MergedSUIDs)
%%			divide_by_rule2(Rule, LocalNodes, CrossNodes, MergedSUIDs)
	end, ActList).

divide_by_rule(Rule) ->
	{LocalNodes, CrossNodes, MergedSUIDs} = partition_nodes(),
	new_divide_by_rule(Rule, LocalNodes, CrossNodes, MergedSUIDs).
%%	divide_by_rule2(Rule, LocalNodes, CrossNodes, MergedSUIDs).

new_divide_by_rule(Rule, LocalNodes, CrossNodes, MergedSUIDs) ->
	LocalNodes2 = lists:keysort(#cls_node.suid, LocalNodes),
	CrossNodes2 = lists:keysort(#cls_node.suid, CrossNodes),
	GroupID = Rule * 1000 + 1,
	new_divide_by_rule(Rule, LocalNodes2, CrossNodes2, MergedSUIDs, GroupID).

new_divide_by_rule(_Rule, _LocalNodes, [], _MergedSUIDs, _GroupID) ->
	?error("not enough cross divide"),
	error;
new_divide_by_rule(Rule, LocalNodes, [CrossNode|CrossNodes], MergedSUIDs, GroupID) ->
	case length(LocalNodes) =< 8 of
		true ->
			do_divide_by_role(Rule, LocalNodes, CrossNode, MergedSUIDs, GroupID),
			Fun =
				fun(#cls_group{group = Group}) ->
					case Group > GroupID of
						true ->
							ets:delete(?ETS_CLUSTER_GROUP, Group);
						false ->
							igore
					end
				end,
			lists:foreach(Fun, ets:tab2list(?ETS_CLUSTER_GROUP));
		false ->
			{LocalNodesHead, LocalNodesTail} = lists:split(8, LocalNodes),
			do_divide_by_role(Rule, LocalNodesHead, CrossNode, MergedSUIDs, GroupID),
			new_divide_by_rule(Rule, LocalNodesTail, CrossNodes, MergedSUIDs, GroupID + 1)
	end.



do_divide_by_role(Rule, LocalNodes, CrossNode, _MergedSUIDs, GroupID) ->
	ets:insert(?ETS_CLUSTER_GROUP, #cls_group{
		group  = GroupID,
		rule   = Rule,
		cross  = CrossNode#cls_node.suid,
		locals = [Node#cls_node.suid || Node <- LocalNodes]
	}),
	CrossNode2 = CrossNode#cls_node{
		group = maps:put(Rule, GroupID, CrossNode#cls_node.group)
	},
	ets:insert(?ETS_CLUSTER_NODES, CrossNode2),
	LocalNodes2 =
		lists:map(
			fun
				(Node) ->
					OldGrp = maps:get(Rule, Node#cls_node.group, 0),
					?_if(
						OldGrp /= GroupID,
						cluster_hook:hook_divide(Node, OldGrp, GroupID)
					),
					Node2 = Node#cls_node{
						group = maps:put(Rule, GroupID, Node#cls_node.group)
					},
					ets:insert(?ETS_CLUSTER_NODES, Node2),

					?debug(
						"divide: old=~w, new=~w, local=~p, cross=~p",
						[OldGrp, GroupID, Node#cls_node.suid, CrossNode2#cls_node.suid]
					),

					lists:foreach(
						fun(MergeSUID) ->
							case ets:lookup(?ETS_CLUSTER_NODES, MergeSUID) of
								[MergeNode] ->
									MergeOldGrp = maps:get(Rule, MergeNode#cls_node.group, 0),
									?_if(
										MergeOldGrp /= GroupID,
										cluster_hook:hook_divide(MergeNode, MergeOldGrp, GroupID)
									),
									MergeNode2 = MergeNode#cls_node{
										group = maps:put(Rule, GroupID, MergeNode#cls_node.group)
									},
									ets:insert(?ETS_CLUSTER_NODES, MergeNode2),

									?debug(
										"divide: old=~w, new=~w, local=~p, cross=~p",
										[MergeOldGrp, GroupID, MergeNode#cls_node.suid, CrossNode2#cls_node.suid]
									);
								[] ->
									ignore
							end
						end, Node#cls_node.merge),

					Node2
			end, LocalNodes),
	post_divide2(Rule, GroupID, CrossNode2, LocalNodes2),
	ok.

partition_nodes() ->
	F =
		fun(#cls_node{suid = SUID}) ->
			case ets:lookup(?ETS_CLUSTER_INDEX, SUID) of
				[#cls_index{merge = Merge}] ->
					not (is_integer(Merge) andalso Merge > 0);
				_ ->
					false
			end
		end,
	Nodes = lists:filter(F, ets:tab2list(?ETS_CLUSTER_NODES)),
	MergedSUIDs = lists:foldl(fun
		(Node, Acc) ->
			Node#cls_node.merge ++ Acc
	end, [], Nodes),
	{LocalNodes, CrossNodes} = lists:partition(fun
		(Node) ->
			cluster:is_local(Node#cls_node.type)
	end, Nodes),
	{LocalNodes, CrossNodes, MergedSUIDs}.

divide_by_rule2(_Rule, [], _CrossNodes, _MergedSUIDs) ->
	ignore;
divide_by_rule2(Rule, LocalNodes, CrossNodes, MergedSUIDs) ->
	LocalNodes2 = lists:keysort(#cls_node.suid, LocalNodes),
	CrossNodes2 = lists:keysort(#cls_node.suid, CrossNodes),
	[#cls_node{otime=StdTime} | _] = LocalNodes2,
	{_, StdMonth, _} = ut_time:seconds_to_date(StdTime),
	{_, CurMonth, _} = ut_time:date(),
	DiffMonth = max(0, CurMonth - StdMonth),
	divide_by_rule3(LocalNodes2, CrossNodes2, DiffMonth, Rule, MergedSUIDs).

divide_by_rule3(LocalNodes, CrossNodes, DiffMonth, Rule, MergedSUIDs) ->
	GroupID = Rule * 1000 + 1,
	case Rule of
		?CROSS_RULE_24_8 ->
			divide_24(LocalNodes, CrossNodes, DiffMonth rem 8, GroupID, MergedSUIDs)
	end.

divide_24([], _CrossNodes, _DiffMonth, _GroupID, _MergedSUIDs) ->
	ok;
divide_24(LocalNodes, [], _DiffMonth, _GroupID, _MergedSUIDs) ->
	?error("cross nodes not enough: ~w", [LocalNodes]),
	set_divide();
divide_24(LocalNodes, CrossNodes, DiffMonth, GroupID, MergedSUIDs) ->
	N1 = min(24, length(LocalNodes)),
	{AllotLocNodes, RestLocNodes} = lists:split(N1, LocalNodes),
	% 小于24个服时，按顺序划分，避免新开服时，已分好的服会划分到不同分组
	N2 = case length(LocalNodes) < 24 of
		true  -> 0;
		false -> min(DiffMonth, length(AllotLocNodes))
	end,
	{TailLocNodes, HeadLocNodes}  = lists:split(N2, AllotLocNodes),
	AllotLocNodes2 = HeadLocNodes ++ TailLocNodes,
	{GroupID2, CrossNodes2} = divide_24_8(AllotLocNodes2, CrossNodes, GroupID, MergedSUIDs),
	divide_24(RestLocNodes, CrossNodes2, DiffMonth, GroupID2, MergedSUIDs).

divide_24_8([], CrossNodes, GroupID, _MergedSUIDs) ->
	{GroupID, CrossNodes};
divide_24_8(LocalNodes, [], GroupID, _MergedSUIDs) ->
	?error("cross nodes not enough: ~w", [LocalNodes]),
	set_divide(),
	{GroupID, []};
divide_24_8(LocalNodes, [CrossNode | RestCrossNodes], GroupID, MergedSUIDs) ->
	N = min(8, length(LocalNodes)),
	{AllotLocNodes0, RestLocNodes} = lists:split(N, LocalNodes),
	AllotLocNodes = lists:filter(fun
		(Node) ->
			not lists:member(Node#cls_node.suid, MergedSUIDs)
	end, AllotLocNodes0),
	Rule = ?CROSS_RULE_24_8,
	ets:insert(?ETS_CLUSTER_GROUP, #cls_group{
		group  = GroupID,
		rule   = Rule,
		cross  = CrossNode#cls_node.suid,
		locals = [Node#cls_node.suid || Node <- AllotLocNodes]
	}),

	CrossNode2 = CrossNode#cls_node{
		group = maps:put(Rule, GroupID, CrossNode#cls_node.group)
	},
	ets:insert(?ETS_CLUSTER_NODES, CrossNode2),

	AllotLocNodes2 = lists:map(fun
		(Node) ->
			OldGrp = maps:get(Rule, Node#cls_node.group, 0),
			?_if(
				OldGrp /= GroupID,
				cluster_hook:hook_divide(Node, OldGrp, GroupID)
			),
			Node2 = Node#cls_node{
				group = maps:put(Rule, GroupID, Node#cls_node.group)
			},
			ets:insert(?ETS_CLUSTER_NODES, Node2),

			?debug(
				"divide: old=~w, new=~w, local=~p, cross=~p",
				[OldGrp, GroupID, Node#cls_node.suid, CrossNode2#cls_node.suid]
			),

			lists:foreach(fun
				(MergeSUID) ->
					case ets:lookup(?ETS_CLUSTER_NODES, MergeSUID) of
						[MergeNode] ->
							MergeOldGrp = maps:get(Rule, MergeNode#cls_node.group, 0),
							?_if(
								MergeOldGrp /= GroupID,
								cluster_hook:hook_divide(MergeNode, MergeOldGrp, GroupID)
							),
							MergeNode2 = MergeNode#cls_node{
								group = maps:put(Rule, GroupID, MergeNode#cls_node.group)
							},
							ets:insert(?ETS_CLUSTER_NODES, MergeNode2),

							?debug(
								"divide: old=~w, new=~w, local=~p, cross=~p",
								[MergeOldGrp, GroupID, MergeNode#cls_node.suid, CrossNode2#cls_node.suid]
							);
						[] ->
							ignore
					end
			end, Node#cls_node.merge),

			Node2
	end, AllotLocNodes),

	post_divide2(Rule, GroupID, CrossNode2, AllotLocNodes2),
	divide_24_8(RestLocNodes, RestCrossNodes, GroupID+1, MergedSUIDs).

post_divide(Rule, GroupID) ->
	case ets:lookup(?ETS_CLUSTER_GROUP, GroupID) of
		[Group] ->
			#cls_group{cross=CrossID, locals=LocalIDs} = Group,
			[CrossNode] = ets:lookup(?ETS_CLUSTER_NODES, CrossID),
			LocalNodes  = lists:map(fun
				(LocalID) ->
					[LocalNode] = ets:lookup(?ETS_CLUSTER_NODES, LocalID),
					LocalNode
			end, LocalIDs),
			post_divide2(Rule, GroupID, CrossNode, LocalNodes);
		[] ->
			ignore
	end.

post_divide2(Rule, GroupID, CrossNode, LocalNodes) ->
	Msg = {divide,Rule,GroupID,CrossNode,LocalNodes},
	cluster_util:gen_cast(LocalNodes, cluster_local, Msg),
	cluster_util:gen_cast(CrossNode, cluster_cross, Msg).


divide_later() ->
	erlang:send_after(timer:minutes(1), self(), divide).

-define(k_redivide, k_redivide).
set_divide() ->
	put(?k_redivide, true).

if_divide() ->
	erase(?k_redivide) == true.
