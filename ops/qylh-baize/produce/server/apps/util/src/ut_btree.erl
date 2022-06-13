%%%=============================================================================
%%% @author z.hua
%%% @doc
%%% 行为树
%%% @end
%%%=============================================================================

-module(ut_btree).

-include("game.hrl").
-include("btree.hrl").

%% API
-export([init/2]).
-export([del/1]).
-export([run/1, run/2]).
%% Internal API
-export([node_sequence/3]).
-export([node_selector/3]).
-export([node_parallel/3]).
-export([node_listen/3]).
-export([node_delisten/3]).
-export([node_repeater/3]).
-export([node_counter/3]).
-export([node_random/3]).
-export([node_success/3]).
-export([node_failure/3]).
-export([node_inverter/3]).
-export([node_timer/3]).
-export([node_jumper/3]).
-export([node_subtree/3]).
-export([node_condition/3]).
-export([node_action/3]).
-export([node_interrupt/3]).
-export([node_reset/3]).
-export([node_sleep/3]).
-export([node_linger/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init(Ref, BTree) ->
    set_btree(BTree),
    set_bdata(init_bdata(Ref, BTree#btree.id)),
    % 场景中没有玩家的时候，会停止ai，所以这里先run一次，做一些初始化操作，比如监听事件
    run(Ref).

del(Ref) ->
    del_bdata(Ref).

run(Ref) ->
    case get_bdata(Ref) of
        ?nil  ->
            ignore;
        BData ->
            BData1 = run_delay(BData),
            BData2 = run_btree(BData1),
            ?_if(get_bdata(Ref) /= ?nil, set_bdata(BData2))
    end.

run(Ref, Event) ->
    case get_bdata(Ref) of
        ?nil  ->
            ignore;
        BData ->
            BData1 = BData#bdata{curtree=BData#bdata.rootree},
            Nodes  = maps:get(Event, BData1#bdata.listen, []),
            BData2 = run_event(Nodes, BData1),
            ?_if(get_bdata(Ref) /= ?nil, set_bdata(BData2))
    end.


%%-----------------------------------------------
%% @doc 序列节点
%% 若子节点返回 failure, 停止迭代, 并向父节点返回 failure
%% 若子节点返回 success, 继续执行下一子节点
%% 若所有子节点都返回 success, 则向父节点返回 success

%% 节点属性
%%     无
%%-----------------------------------------------
node_sequence(BData, BNode, Parent) ->
    % ?debug("~ts, ~p", ["序列节点", BNode]),
    #bnode{id=NodeID, nodes=Childs} = BNode,
    State = get_node_state(BData, NodeID, ?nil),
    case ?_if(State == ?nil, Childs, State) of
        [ChildID | Rest] ->
            Self = fun
                (?FAILURE, NewData) ->
                    NewData2 = update_node_state(NewData, NodeID, ?nil),
                    Parent(?FAILURE, NewData2);
                (?SUCCESS, NewData) ->
                	NewData2 = update_node_state(NewData, NodeID, Rest),
                    node_sequence(NewData2, BNode, Parent)
            end,
            run_child(BData, ChildID, Self);
        [] ->
        	BData2 = update_node_state(BData, NodeID, ?nil),
            Parent(?SUCCESS, BData2)
    end.


%%-----------------------------------------------
%% @doc 选择节点
%% 若子节点返回 success, 停止迭代, 并向父节点返回 success
%% 若子节点返回 failure, 继续执行下一子节点
%% 若所有子节点都返回 failure, 则向父节点返回 failure

%% 节点属性
%%     无
%%-----------------------------------------------
node_selector(BData, BNode, Parent) ->
    % ?debug("~ts, ~p", ["选择节点", BNode]),
    #bnode{id=NodeID, nodes=Childs} = BNode,
    State = get_node_state(BData, NodeID, ?nil),
    case ?_if(State == ?nil, Childs, State) of
        [ChildID | Rest] ->
            Self = fun
                (?SUCCESS, NewData) ->
                	NewData2 = update_node_state(NewData, NodeID, ?nil),
                	Parent(?SUCCESS, NewData2);
                (?FAILURE, NewData) ->
                	NewData2 = update_node_state(NewData, NodeID, Rest),
                	node_selector(NewData2, BNode, Parent)
            end,
            run_child(BData, ChildID, Self);
        [] ->
        	BData2 = update_node_state(BData, NodeID, ?nil),
            Parent(?FAILURE, BData2)
    end.


%%-----------------------------------------------
%% @doc 并行节点
%% 执行所有子节点，根据不同的 prop 来返回结果

%% 节点属性
%% key=type
%% val=0: 总返回 success, 默认
%%     1: 若有一个节点返回 success, 则向父节点返回 success
%%     2: 若所有节点都返回 success, 则向父节点返回 success

%%-----------------------------------------------
node_parallel(BData, BNode, Parent) ->
    % ?debug("~ts, ~p", ["并行节点", BNode]),
	#bnode{id=NodeID, props=Props, nodes=Childs} = BNode,
    Type   = proplists:get_value(type, Props, 0),
    State  = get_node_state(BData, NodeID, ?nil),
    State1 = case State == ?nil of
		true when Type == 0 ->
            {?SUCCESS, Childs};
        true when Type == 1 ->
            {?FAILURE, Childs};
        true when Type == 2 ->
            {?SUCCESS, Childs};
		false ->
			State
	end,
	case State1 of
		{Result, [ChildID | Rest]} ->
			Self = fun
				(?SUCCESS, NewData) ->
                    State2 = case Type of
                        0 -> {?SUCCESS, Rest};
						1 -> {?SUCCESS, Rest};
						2 -> {Result, Rest}
					end,
					NewData2 = update_node_state(NewData, NodeID, State2),
					node_parallel(NewData2, BNode, Parent);
				(?FAILURE, NewData) ->
                    State2 = case Type of
                        0 -> {?SUCCESS, Rest};
						1 -> {Result, Rest};
						2 -> {?FAILURE, Rest}
					end,
					NewData2 = update_node_state(NewData, NodeID, State2),
					node_parallel(NewData2, BNode, Parent)
			end,
			run_child(BData, ChildID, Self);
		{Result, []} ->
			BData2 = update_node_state(BData, NodeID, ?nil),
			Parent(Result, BData2)
	end.


%%-----------------------------------------------
%% @doc 事件节点
%% 监听事件，返回 success
%%-----------------------------------------------
node_listen(BData, BNode, Parent) ->
    % ?debug("~ts, ~p", ["事件节点", BNode]),
    #bdata{curtree=TreeID, listen=Listen, status=Status} = BData,
    #bnode{id=NodeID, props=Props} = BNode,
    Event = proplists:get_value(event, Props),
    case maps:is_key({TreeID,NodeID}, Status) of
        true  ->
            Parent(?SUCCESS, BData);
        false ->
            BData2 = BData#bdata{
                listen = ut_misc:maps_append(Event, {TreeID,BNode}, Listen),
                status = maps:put({TreeID,NodeID}, Event, Status)
            },
            Parent(?SUCCESS, BData2)
    end.


%%-----------------------------------------------
%% @doc 取消节点
%% 取消监听事件，返回 success
%%-----------------------------------------------
node_delisten(BData, BNode, Parent) ->
    % ?debug("~ts, ~p", ["取消节点", BNode]),
    Event  = proplists:get_value(event, BNode#bnode.props),
    NodeID = proplists:get_value(node, BNode#bnode.props),
    Listen = case NodeID == all of
        true  ->
            maps:remove(Event, BData#bdata.listen);
        false ->
            maps:update_with(Event, fun
                (Nodes) ->
                    lists:keydelete(NodeID, #bnode.id, Nodes)
            end, [], BData#bdata.listen)
    end,
    BData2 = BData#bdata{listen=Listen},
    Parent(?SUCCESS, BData2).


%%-----------------------------------------------
%% @doc 循环节点
%%
%% 节点属性
%% key=times
%% val=-3: 直到子节点返回 success 时，终止循环，并向父节点返回 success
%%     -2: 直到子节点返回 failure 时，终止循环，并向父节点返回 failure
%%     -1: 无限循环
%%     >0: 循环 N 次
%%-----------------------------------------------
node_repeater(BData, BNode, Parent) ->
    % ?debug("~ts, ~p", ["循环节点", BNode]),
	#bnode{id=NodeID, props=Props, nodes=[ChildID]} = BNode,
    Times = proplists:get_value(times, Props),
    Count = get_node_count(BData, NodeID, ?nil),
    Self  = case ?_if(Count == ?nil, Times, Count) of
        -3 ->
            fun(Result, NewData) ->
                NewData2 = update_node_count(NewData, NodeID, -3),
                case Result == ?SUCCESS of
                    true  -> Parent(?SUCCESS, NewData2);
                    false -> update_running(NewData2, NodeID, Parent)
                end
            end;
        -2 ->
            fun(Result, NewData) ->
                NewData2 = update_node_count(NewData, NodeID, -2),
                case Result == ?FAILURE of
                    true  -> Parent(?FAILURE, NewData2);
                    false -> update_running(NewData2, NodeID, Parent)
                end
            end;
    	-1 ->
    		fun(_Result, NewData) ->
                NewData2 = update_node_count(NewData, NodeID, -1),
                update_running(NewData2, NodeID, Parent)
        	end;
        0  ->
            fun(Result, NewData) ->
            	NewData2 = update_node_count(NewData, NodeID, ?nil),
                Parent(Result, NewData2#bdata{running=?nil})
            end;
        N  ->
        	fun(_Result, NewData) ->
                NewData2 = update_node_count(NewData, NodeID, N-1),
                update_running(NewData2, NodeID, Parent)
            end
    end,
    run_child(BData, ChildID, Self).


%%-----------------------------------------------
%% @doc 计数节点
%% 当未达到指定次数时，执行子节点，如果子节点执行成功，则次数+1，并向父节点返回子节点的结果
%% 否则不执行子节点，并向父节点返回 failure
%%
%% 注：与循环节点中的计数器有所差别，
%%     循环节点中的计数器是一直循环执行子节点，直到执行 N 次
%%     而计数节点中的计数器是会跳出子节点的
%%
%% 节点属性
%% key=times val=N(N>0)     执行 N 次
%% key=wait  val=true|false 是否等子节点返回才计数
%%-----------------------------------------------
node_counter(BData, BNode, Parent) ->
    % ?debug(BData#bdata.rootree == 130002, "~ts, ~p", ["计数节点", BNode]),
	#bnode{id=NodeID, props=Props, nodes=[ChildID]} = BNode,
    Times = proplists:get_value(times, Props),
    Wait  = proplists:get_value(wait, Props, true),
    Count = get_node_count(BData, NodeID, ?nil),
    case ?_if(Count == ?nil, Times, Count) of
        0 ->
            Parent(?FAILURE, BData);
        N when Wait ->
            Self = fun
                (?SUCCESS, NewData) ->
                    NewData2 = update_node_count(NewData, NodeID, N-1),
                    Parent(?SUCCESS, NewData2);
                (?FAILURE, NewData) ->
                    Parent(?FAILURE, NewData)
            end,
            run_child(BData, ChildID, Self);
        N ->
            Self   = fun(Result, NewData) -> Parent(Result, NewData) end,
            BData2 = update_node_count(BData, NodeID, N-1),
            run_child(BData2, ChildID, Self)
    end.


%%-----------------------------------------------
%% @doc 随机节点
%% 随机选择一个子节点执行，并向父节点返回子节点的结果
%%
%% 节点属性
%% key=weighted
%% val=true  : 子节点中包含 weight 属性
%%     false : 子节点中不包含 weight 属性(随机)
%%-----------------------------------------------
node_random(BData, BNode, Parent) ->
	#bnode{props=Props, nodes=Childs} = BNode,
	ChildID = case proplists:get_value(weighted, Props, false) of
		true  ->
            BTree  = get_btree(BData#bdata.curtree),
            WtList = get_weight_list(Childs, BTree, []),
            ut_rand:weight(WtList);
        false ->
            ut_rand:choose(Childs)
	end,
    % ?debug(BData#bdata.ref == {creep_ai, 2000021}, "~ts, ~p", ["随机节点", ChildID]),
    Self  = fun(Result, NewData) -> Parent(Result, NewData) end,
    run_child(BData, ChildID, Self).

get_weight_list([NodeID | T], BTree, Acc) ->
    BNode  = maps:get(NodeID, BTree#btree.nodes),
    Weight = proplists:get_value(weight, BNode#bnode.props),
    get_weight_list(T, BTree, [{NodeID,Weight} | Acc]);
get_weight_list([], _BTree, Acc) ->
    Acc.


%%-----------------------------------------------
%% @doc 成功节点
%% 总是向父节点返回 success
%%-----------------------------------------------
node_success(BData, BNode, Parent) ->
    % ?debug("~ts, ~p", ["成功节点", BNode]),
	#bnode{nodes=[ChildID]} = BNode,
    Self = fun(_Result, NewData) -> Parent(?SUCCESS, NewData) end,
    run_child(BData, ChildID, Self).


%%-----------------------------------------------
%% @doc 失败节点
%% 总是向父节点返回 failure
%%-----------------------------------------------
node_failure(BData, BNode, Parent) ->
    % ?debug("~ts, ~p", ["失败节点", BNode]),
	#bnode{nodes=[ChildID]} = BNode,
    Self = fun(_Result, NewData) -> Parent(?FAILURE, NewData) end,
    run_child(BData, ChildID, Self).


%%-----------------------------------------------
%% @doc 取反节点
%% 对子节点结果进行取反
%%-----------------------------------------------
node_inverter(BData, BNode, Parent) ->
    % ?debug("~ts, ~p", ["取反节点", BNode]),
	#bnode{nodes=[ChildID]} = BNode,
    Self = fun
        (?SUCCESS, NewData) -> Parent(?FAILURE, NewData);
        (?FAILURE, NewData) -> Parent(?SUCCESS, NewData)
    end,
    run_child(BData, ChildID, Self).


%%-----------------------------------------------
%% @doc 延迟节点(定时器节点)
%% 延迟执行的节点，不会被事件中断，返回 success
%%-----------------------------------------------
node_timer(BData, BNode, Parent) ->
    % ?debug("~ts, ~p", ["延迟节点", BNode]),
    #bdata{curtree=TreeID, delay=Delay, counter=Counter} = BData,
    #bnode{id=NodeID, props=Props} = BNode,
    Tick = case proplists:get_value(tick, Props) of
        [Mod, Fun, Args] ->
            Mod:Fun(BData#bdata.ref, Args);
        [Mod, Fun] ->
            Mod:Fun(BData#bdata.ref);
        Tick0 ->
            Tick0
    end,
    BData2 = BData#bdata{
        delay   = [{TreeID,BNode} | Delay],
        counter = maps:put({TreeID,NodeID}, Tick, Counter)
    },
    Parent(?SUCCESS, BData2).


%%-----------------------------------------------
%% @doc 跳转节点
%% 节点属性
%% key=node, val=NodeID
%% key=args, val=Args
%%-----------------------------------------------
node_jumper(BData, BNode, Parent) ->
    % ?debug("~ts, ~p", ["跳转节点", BNode]),
    #bnode{props=Props} = BNode,
    NodeID = proplists:get_value(node, Props),
    Self   = fun(Result, NewData) -> Parent(Result, NewData) end,
    run_child(BData, NodeID, Self).


%%-----------------------------------------------
%% @doc 子树节点
%% 节点属性
%% key=mod , val=Module
%% key=func, val=Function
%% key=args, val=Args
%%-----------------------------------------------
node_subtree(BData, BNode, Parent) ->
    [Mod, Fun, SubTreeID] = proplists:get_value(tree, BNode#bnode.props),
    SubTree = Mod:Fun(SubTreeID),
    set_btree(SubTree),
    Self = fun(Result, NewData) ->
        % ?debug("~ts", ["完成子树节点"]),
        NewData2 = NewData#bdata{curtree=BData#bdata.curtree},
        Parent(Result, NewData2)
    end,
    BData2 = BData#bdata{curtree=SubTree#btree.id},
    run_child(BData2, SubTree#btree.entry, Self).


%%-----------------------------------------------
%% @doc 条件节点
%%
%% 节点属性
%% key=mod , val=Module
%% key=func, val=Function
%% key=args, val=Args
%%-----------------------------------------------
node_condition(BData, BNode, Parent) ->
    % ?debug("~ts, ~p", ["条件节点", BNode]),
	#bnode{props=Props} = BNode,
    M = proplists:get_value(mod, Props),
    F = proplists:get_value(func, Props),
    A = proplists:get_value(args, Props, []),
    case M:F(BData#bdata.ref, A) of
        true  -> Parent(?SUCCESS, BData);
        false -> Parent(?FAILURE, BData)
    end.


%%-----------------------------------------------
%% @doc 动作节点
%%
%% 节点属性
%% key=mod , val=Module
%% key=func, val=Function
%% key=args, val=Args
%%-----------------------------------------------
node_action(BData, BNode, Parent) ->
    % ?debug("~ts, ~p", ["动作节点", BNode]),
    #bnode{id=NodeID, props=Props} = BNode,
    M = proplists:get_value(mod, Props),
    F = proplists:get_value(func, Props),
    A = proplists:get_value(args, Props, []),
	case M:F(BData#bdata.ref, A) of
        ?RUNNING -> update_running(BData, NodeID, Parent);
        Result   -> Parent(Result, BData#bdata{running=?nil})
	end.



%%-----------------------------------------------
%% @doc 中断节点
%% 中断 running 节点，返回 success
%%-----------------------------------------------
node_interrupt(BData, _BNode, Parent) ->
    % ?debug("~ts, ~p", ["中断节点", _BNode]),
    BData2 = BData#bdata{running=?nil},
    Parent(?SUCCESS, BData2).


%%-----------------------------------------------
%% @doc 重置节点
%% 重置整颗树的状态，返回 success
%%-----------------------------------------------
node_reset(BData, _BNode, Parent) ->
    % ?debug("~ts, ~p", ["重置节点", _BNode]),
    BData2 = init_bdata(BData#bdata.ref, BData#bdata.curtree),
    Parent(?SUCCESS, BData2).


%%-----------------------------------------------
%% @doc 休眠节点
%% 休眠 N 个 tick ，可以被打断
%% key=tick val=N(-1表示无限休眠)
%%-----------------------------------------------
node_sleep(BData, BNode, Parent) ->
    #bnode{id=NodeID, props=Props} = BNode,
    Count = case get_node_count(BData, NodeID, ?nil) of
        ?nil ->
            case proplists:get_value(tick, Props) of
                [Mod, Fun, Args] ->
                    Mod:Fun(BData#bdata.ref, Args);
                [Mod, Fun] ->
                    Mod:Fun(BData#bdata.ref);
                Tick0 ->
                    Tick0
            end;
        Cnt  ->
            Cnt
    end,
    % ?debug(BData#bdata.ref == {creep_ai, 2000021}, "~ts, ~p", ["随机节点", ChildID]),
    % ?debug(BData#bdata.ref == {creep_ai, 2000021}, "~ts, ~p", ["等待节点", {NodeID, Count, get_node_count(BData, NodeID, ?nil)}]),
    case Count of
        -1 ->
            BData2 = update_node_count(BData, NodeID, -1),
            update_running(BData2, NodeID, Parent);
        0  ->
            % ?debug(BData#bdata.ref == {creep_ai, 2000021}, "~ts", ["等待结束"]),
            Parent(?SUCCESS, BData#bdata{
                running = ?nil,
                counter = maps:remove({BData#bdata.curtree,NodeID}, BData#bdata.counter)
            });
        N  ->
            BData2 = update_node_count(BData, NodeID, N-1),
            update_running(BData2, NodeID, Parent)
    end.


%%-----------------------------------------------
%% @doc 逗留节点
%% 如果子节点返回 success 且 tick > 0 ，继续逗留；否则中断逗留
%% 逗留 N 个 tick ，可以被打断
%% key=tick val=N(-1表示一直逗留)
%%-----------------------------------------------
node_linger(BData, BNode, Parent) ->
    #bnode{id=NodeID, props=Props, nodes=[ChildID]} = BNode,
    Count = case get_node_count(BData, NodeID, ?nil) of
        ?nil ->
            case proplists:get_value(tick, Props) of
                [Mod, Fun, Args] ->
                    Mod:Fun(BData#bdata.ref, Args);
                [Mod, Fun] ->
                    Mod:Fun(BData#bdata.ref);
                Tick0 ->
                    Tick0
            end;
        Cnt  ->
            Cnt
    end,
    case Count of
        0 ->
            Parent(?SUCCESS, BData);
        N ->
            Self = fun
                (?SUCCESS, NewData) ->
                    update_running(NewData, NodeID, Parent);
                (?FAILURE, NewData) ->
                    NewData2 = update_node_count(NewData, NodeID, ?nil),
                    Parent(?FAILURE, NewData2#bdata{running=?nil})
            end,
            BData2 = update_node_count(BData, NodeID, ?_if(N == -1, -1, N-1)),
            run_child(BData2, ChildID, Self)
    end.



%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
-define(k_bdata, {bdata, Ref}).
get_bdata(Ref) ->
    get(?k_bdata).

set_bdata(BData = #bdata{ref=Ref}) ->
    put(?k_bdata, BData).

del_bdata(Ref) ->
    erase(?k_bdata).


-define(k_btree, {btree, TreeID}).
get_btree(TreeID) ->
    get(?k_btree).

set_btree(BTree = #btree{id=TreeID}) ->
    put(?k_btree, BTree).

% del_btree(TreeID) ->
%     erase(?k_btree).

init_bdata(Ref, TreeID) ->
    #bdata{
        ref     = Ref,
        rootree = TreeID,
        curtree = TreeID,
        running = ?nil,
        delay   = [],
        status  = #{},
        counter = #{},
        listen  = #{}
    }.

run_btree(BData) when BData#bdata.running == ?nil ->
    Self  = fun(_Result, NewData) -> NewData end,
    BTree = get_btree(BData#bdata.curtree),
    run_child(BData, BTree#btree.entry, Self);
run_btree(BData) ->
    {TreeID, NodeID, Parent} = BData#bdata.running,
    run_child(BData#bdata{curtree=TreeID}, NodeID, Parent).


run_delay(BData) ->
    #bdata{counter=Counter, delay=Delay} = BData,
    Counter2 = lists:foldl(fun
        ({TreeID,#bnode{id=NodeID}}, Acc) ->
            ut_misc:maps_increase({TreeID,NodeID}, -1, Acc)
    end, Counter, Delay),
    BData2 = BData#bdata{counter=Counter2},
    run_delay2(Delay, BData2).

run_delay2([{TreeID,BNode} | T], BData) ->
    #bdata{status=Status, counter=Counter, delay=Delay} = BData,
    #bnode{id=NodeID, nodes=[ChildID]} = BNode,
    case maps:get({TreeID,NodeID}, Counter) =< 0 of
        true  ->
            % ?debug("~ts ~p", ["执行迟延节点", NodeID]),
            Self = fun(_Result, NewData) ->
                NewData#bdata{
                    curtree = BData#bdata.curtree,
                    status  = maps:remove({TreeID,NodeID}, Status),
                    delay   = lists:delete({TreeID,BNode}, Delay)
                }
            end,
            BData1 = BData#bdata{curtree=TreeID},
            BData2 = run_child(BData1, ChildID, Self),
            case BData2#bdata.running == ?nil of
                true  -> run_delay2(T, BData2);
                false -> BData2
            end;
        false ->
            run_delay2(T, BData)
    end;
run_delay2([], BData) ->
    BData.


run_event([{TreeID,BNode} | T], BData) ->
    % ?debug("~ts ~p", ["执行事件节点", {TreeID, BNode}]),
    Self   = fun(_Result, NewData) ->
        % ?debug("~ts ~p", ["执行完事件节点", NewData]),
        NewData#bdata{curtree=BData#bdata.curtree}
    end,
    #bnode{nodes=[ChildID]} = BNode,
    BData1 = BData#bdata{curtree=TreeID},
    BData2 = run_child(BData1, ChildID, Self),
    case BData2#bdata.running == ?nil of
        true  -> run_event(T, BData2);
        false -> BData2
    end;
run_event([], BData) ->
    BData.

get_node_state(BData, NodeID, Default) ->
    #bdata{curtree=TreeID, status=Status} = BData,
    maps:get({TreeID,NodeID}, Status, Default).

update_node_state(BData, NodeID, State) ->
    #bdata{curtree=TreeID, status=Status} = BData,
    BData#bdata{status=maps:put({TreeID,NodeID}, State, Status)}.

get_node_count(BData, NodeID, Default) ->
    #bdata{curtree=TreeID, counter=Counter} = BData,
    maps:get({TreeID,NodeID}, Counter, Default).

update_node_count(BData, NodeID, Count) ->
    #bdata{curtree=TreeID, counter=Counter} = BData,
    BData#bdata{counter=maps:put({TreeID,NodeID}, Count, Counter)}.

update_running(BData, NodeID, Parent) ->
    BData#bdata{running={BData#bdata.curtree,NodeID,Parent}}.

run_child(BData, NodeID, Parent) when not is_record(NodeID, bnode) ->
    BTree = get_btree(BData#bdata.curtree),
    BNode = maps:get(NodeID, BTree#btree.nodes),
    do_run_child(BData, BNode, Parent);
run_child(BData, BNode, Parent) ->
    do_run_child(BData, BNode, Parent).

do_run_child(BTree, BNode, Parent) ->
    Fun = BNode#bnode.type,
    ?MODULE:Fun(BTree, BNode, Parent).
