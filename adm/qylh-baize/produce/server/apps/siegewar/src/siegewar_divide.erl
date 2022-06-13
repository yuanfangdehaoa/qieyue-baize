%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(siegewar_divide).

-include("game.hrl").
-include("siegewar.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("table.hrl").

-include_lib("eunit/include/eunit.hrl").

%% API
-export([divide_local/0]).
-export([divide_cross/0]).
-export([is_8group/0]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
divide_local() ->
	do_init(),
	Guilds = guild:get_guilds(3),
	% ?debug("divide_local--------------------------:~w", [Guilds]),
	Scenes = cfg_siegewar_boss:scenes(0),
	do_divide_local(Scenes, Guilds),
	clr_boss_info(),
	ok.

divide_cross() ->
	do_init(),
	Nodes  = cluster:get_locals(?CROSS_RULE_24_8),
	Scenes = #{
		1 => cfg_siegewar_boss:scenes(1),
		2 => cfg_siegewar_boss:scenes(2),
		3 => cfg_siegewar_boss:scenes(3)
	},
	set_group(1),
	do_divide_cross(Nodes, Scenes),
	clr_boss_info(),
	ok.

is_8group() ->
	get_8group() == true.


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_init() ->
	set_boss_info(),
	ets:delete_all_objects(?ETS_SIEGEWAR_CITY),
	SceneIDs = case cluster:is_local() of
		true  ->
			cfg_siegewar_boss:scenes(0);
		false ->
			cfg_siegewar_boss:scenes(1) ++
			cfg_siegewar_boss:scenes(2) ++
			cfg_siegewar_boss:scenes(3)
	end,
	lists:foreach(fun
		(SceneID) ->
			insert_into_city(SceneID, 0, [], 0, 0)
	end, SceneIDs).

do_divide_local([SceneID | T1], [Guild | T2]) ->
	#p_guild_base{id=GuildID} = Guild,
	insert_into_city(SceneID, GuildID, [GuildID], 0, GuildID),
	GroupID = game_uid:guid2ssid(GuildID),
	scene:route(SceneID, siegewar_server, set_creep_group, GroupID),
	do_divide_local(T1, T2);
do_divide_local([SceneID | T], []) ->
	insert_into_city(SceneID, 0, [], 0, 0),
	do_divide_local(T, []);
do_divide_local([], []) ->
	ok.

do_divide_cross(Nodes, Scenes) ->
	Sorted = lists:keysort(#cls_node.otime, Nodes),
	Today  = ut_time:date(),
	Rule   = lists:reverse(lists:keysort(1, cfg_game:siegewar_divide())),
	Divide = divide_by_mindays(Sorted, Rule, Today, #{}),
	% ?debug("do_divide_cross-----:~w", [Divide]),
	divide_into_8group(Divide, Scenes, Rule, Today).

divide_by_mindays([Node | T], Rule, Today, Divide) ->
	Opdays  = calc_open_days(Node, Today),
	% ?debug("Opdays: ~w", [{Node#cls_node.suid, Opdays}]),
	Divide2 = divide_by_mindays2(Rule, Node, Opdays, Divide),
	divide_by_mindays(T, Rule, Today, Divide2);
divide_by_mindays([], _Rule, _Today, Divide) ->
	maps:map(fun(_, SUIDs) -> lists:sort(SUIDs) end, Divide).

divide_by_mindays2([{RuleID, {MinDays, _}} | T], Node, Opdays, Divide) ->
	case Opdays >= MinDays of
		true  -> ut_misc:maps_append(RuleID, Node, Divide);
		false -> divide_by_mindays2(T, Node, Opdays, Divide)
	end;
divide_by_mindays2([], _Node, _Opdays, Divide) ->
	Divide.


%% 分为两部分
%% 1. 满足最大开服天数 Nodes1
%% 2. 其它 Nodes2
divide_by_maxdays(Divide, Scenes, Rule, RuleID, Nodes, Today) ->
	{Nodes1, Nodes2} = split_by_maxdays(Nodes, Rule, RuleID, Today),
	% ?debug("divide_by_maxdays----------------:~w", [{RuleID, Nodes1, Nodes2}]),
	Scenes2 = divide_city(Nodes1, Scenes, RuleID),
	Rule2   = lists:keydelete(RuleID, 1, Rule),
	Divide2 = divide_by_mindays(Nodes2, Rule2, Today, Divide),
	% ?debug("--------:~w", [{Rule2, Divide2}]),
	{Divide2, Scenes2, Rule2}.


%% 划分8跨服组
divide_into_8group(Divide, Scenes, Rule, Today) ->
	RuleID = 3,
	Nodes  = maps:get(RuleID, Divide, []),
	case length(Nodes) >= 8 of
		true  ->
			% 所有服都满足最小开服天数限制，全部进入8跨服
			set_8group(),
			divide_city(Nodes, Scenes, RuleID);
		false ->
			% 满足最大开服天数限制的服进入8跨服组
			{Divide2, Scenes2, Rule2} =
				divide_by_maxdays(Divide, Scenes, Rule, RuleID, Nodes, Today),
			% ?debug("aaaaaaaa: ~w", [Divide2]),
			% 其它进入4跨服组
			divide_into_4group(Divide2, Scenes2, Rule2, Today)
	end.

%% 划分4跨服组
divide_into_4group(Divide, Scenes, Rule, Today) ->
	RuleID = 2,
	Nodes  = lists:keysort(#cls_node.otime, maps:get(RuleID, Divide, [])),
	if
		length(Nodes) >= 8 ->
			% 所有服都满足最小开服天数限制，进入4跨服组
			{Nodes1, Nodes2} = lists:split(4, Nodes),
			Scenes1 = divide_city(Nodes1, Scenes, RuleID),
			% ?debug("divide_into_4group----------------------:~w", [{Scenes, Scenes1}]),
			divide_city(Nodes2, Scenes1, RuleID);
		length(Nodes) >= 4 ->
			% 前4个服进入4跨服组
			{Nodes1, Nodes2} = lists:split(4, Nodes),
			Scenes1 = divide_city(Nodes1, Scenes, RuleID),
			% 满足最大开服天数限制的服进入4跨服组
			{Divide2, Scenes2, Rule2} =
				divide_by_maxdays(Divide, Scenes1, Rule, RuleID, Nodes2, Today),
			% 其它进入2跨服组
			divide_into_2group(Divide2, Scenes2, Rule2, Today);
		true ->
			% 满足最大开服天数限制的服进入4跨服组
			{Divide2, Scenes2, Rule2} =
				divide_by_maxdays(Divide, Scenes, Rule, RuleID, Nodes, Today),
			% ?debug("bbbbbbbbbbb: ~w", [Divide2]),
			% 其它进入2跨服组
			divide_into_2group(Divide2, Scenes2, Rule2, Today)
	end.

divide_into_2group(Divide, Scenes, Rule, Today) ->
	RuleID = 1,
	Nodes  = lists:keysort(#cls_node.otime, maps:get(RuleID, Divide, [])),
	if
		length(Nodes) >= 8 ->
			% 所有服都满足最小开服天数限制，进入2跨服组
			[N1, N2, N3, N4, N5, N6, N7, N8] = Nodes,
			Scenes1 = divide_city([N1, N2], Scenes, RuleID),
			Scenes2 = divide_city([N3, N4], Scenes1, RuleID),
			Scenes3 = divide_city([N5, N6], Scenes2, RuleID),
			divide_city([N7, N8], Scenes3, RuleID);
		length(Nodes) >= 6 ->
			% 前6个服进入2跨服组
			[N1, N2, N3, N4, N5, N6 | T] = Nodes,
			Scenes1 = divide_city([N1, N2], Scenes, RuleID),
			Scenes2 = divide_city([N3, N4], Scenes1, RuleID),
			Scenes3 = divide_city([N5, N6], Scenes2, RuleID),
			% 满足最大开服天数限制的服进入2跨服组
			{_, Scenes4, _} = divide_by_maxdays(Divide, Scenes3, Rule, RuleID, T, Today),
			case T of
				[N7] -> divide_city([N7], Scenes4, RuleID);
				_    -> ignore
			end;
		length(Nodes) >= 4 ->
			% 前4个服进入2跨服组
			[N1, N2, N3, N4 | T] = Nodes,
			Scenes1 = divide_city([N1, N2], Scenes, RuleID),
			Scenes2 = divide_city([N3, N4], Scenes1, RuleID),
			% 满足最大开服天数限制的服进入2跨服组
			{_, Scenes3, _} = divide_by_maxdays(Divide, Scenes2, Rule, RuleID, T, Today),
			case T of
				[N5] -> divide_city([N5], Scenes3, RuleID);
				_    -> ignore
			end;
		length(Nodes) >= 2 ->
			% 前2个服进入2跨服组
			[N1, N2 | T] = Nodes,
			Scenes1 = divide_city([N1, N2], Scenes, RuleID),
			% ?debug("ccccccccccc: ~w", [{N1, N2, T}]),
			% 满足最大开服天数限制的服进入2跨服组
			{_, Scenes2, _} = divide_by_maxdays(Divide, Scenes1, Rule, RuleID, T, Today),
			case T of
				[N3] -> divide_city([N3], Scenes2, RuleID);
				_    -> ignore
			end;
		length(Nodes) == 1 ->
			divide_city(Nodes, Scenes, RuleID);
		true ->
			divide_by_maxdays(Divide, Scenes, Rule, RuleID, Nodes, Today)
	end.

split_by_maxdays(Nodes, Rule, RuleID, Today) ->
	{_, MaxDays} = proplists:get_value(RuleID, Rule),
	lists:partition(fun
		(Node) ->
			calc_open_days(Node, Today) >= MaxDays
	end, Nodes).

calc_open_days(Node, Today) ->
	OpDate = ut_time:seconds_to_date(Node#cls_node.otime),
	abs(ut_time:diff_days(Today, OpDate)) + 1.


divide_city(Nodes, Scenes, RuleID) ->
	GroupID = get_group(),
	Scenes1 = divide_lv1_city(Nodes, Scenes, RuleID, GroupID),
	Scenes2 = divide_lv2_city(Nodes, Scenes1, RuleID, GroupID),
	Scenes3 = divide_lv3_city(Nodes, Scenes2, RuleID, GroupID),
	set_group(GroupID + 1),
	lists:foreach(fun
		(Node) ->
			#cls_node{suid=SUID, name=Name} = Node,
			ets:insert(?ETS_SIEGEWAR_RULE, {SUID, RuleID, GroupID}),
			cluster:rpc_cast_node(Name, siegewar_server, set_divide_rule, [RuleID])
	end, Nodes),
	% ?debug("divide_city: ~n~w~n~w~n~w~n~w~n", [RuleID, Scenes1, Scenes2, Scenes3]),
	Scenes3.

%% 划分1级城市
divide_lv1_city(Nodes, Scenes, RuleID, GroupID) ->
	SceneIDs  = maps:get(1, Scenes),
	SceneIDs2 = divide_lv1_city2(Nodes, SceneIDs, RuleID, GroupID),
	maps:put(1, SceneIDs2, Scenes).

divide_lv1_city2([Node | T1], [SceneID | T2], RuleID, GroupID) ->
	insert_into_city(SceneID, Node#cls_node.suid, [Node#cls_node.suid], RuleID, GroupID),
	divide_lv1_city2(T1, T2, RuleID, GroupID);
divide_lv1_city2([], Scenes, _RuleID, _GroupID) ->
	Scenes.


%% 划分2级城市
divide_lv2_city(Nodes, Scenes, RuleID, GroupID) ->
	SceneIDs  = maps:get(2, Scenes),
	SceneIDs2 = case RuleID of
		1 -> divide_lv2_city_2group(Nodes, SceneIDs, RuleID, GroupID);
		2 -> divide_lv2_city_4group(Nodes, SceneIDs, RuleID, GroupID);
		3 -> divide_lv2_city_8group(Nodes, SceneIDs, RuleID, GroupID)
	end,
	maps:put(2, SceneIDs2, Scenes).


%% 2跨服阶段
divide_lv2_city_2group([Node1, Node2 | T1], [SceneID1, SceneID2 | T2], RuleID, GroupID) ->
	insert_into_city(SceneID1, 0, [Node1#cls_node.suid, Node2#cls_node.suid], RuleID, GroupID),
	insert_into_city(SceneID2, 0, [Node1#cls_node.suid, Node2#cls_node.suid], RuleID, GroupID),
	divide_lv2_city_2group(T1, T2, RuleID, GroupID);
divide_lv2_city_2group([Node | T1], [SceneID1, SceneID2 | T2], RuleID, GroupID) ->
	insert_into_city(SceneID1, 0, [Node#cls_node.suid], RuleID, GroupID),
	insert_into_city(SceneID2, 0, [Node#cls_node.suid], RuleID, GroupID),
	divide_lv2_city_2group(T1, T2, RuleID, GroupID);
divide_lv2_city_2group([], SceneIDs, _RuleID, _GroupID) ->
	SceneIDs.

%% 4跨服阶段
divide_lv2_city_4group([], SceneIDs, _RuleID, _GroupID) ->
	SceneIDs;
divide_lv2_city_4group(Nodes, [SceneID1, SceneID2, SceneID3, SceneID4 | T2], RuleID, GroupID) ->
	case length(Nodes) >= 4 of
		true  ->
			{Nodes1, Nodes2} = lists:split(4, Nodes),
			divide_lv2_city_4group2(Nodes1, [SceneID1, SceneID2], RuleID, GroupID),
			case length(Nodes2) > 0 of
				true  ->
					divide_lv2_city_4group2(Nodes2, [SceneID3, SceneID4], RuleID, GroupID),
					T2;
				false ->
					[SceneID3, SceneID4 | T2]
			end;
		false ->
			divide_lv2_city_4group2(Nodes, [SceneID1, SceneID2], RuleID, GroupID),
			[SceneID3, SceneID4 | T2]
	end.

divide_lv2_city_4group2([], SceneIDs, _RuleID, _GroupID) ->
	SceneIDs;
divide_lv2_city_4group2(Nodes, SceneIDs, RuleID, GroupID) ->
	lists:foldl(fun
		(SceneID, N) ->
			{N1, N2, N3, N4} = {1, 2, 3, 4},
			SUIDs1 = case length(Nodes) >= N1 of
				true  -> [(lists:nth(N1, Nodes))#cls_node.suid];
				false -> []
			end,
			SUIDs2 = case length(Nodes) >= N2 of
				true  -> [(lists:nth(N2, Nodes))#cls_node.suid | SUIDs1];
				false -> SUIDs1
			end,
			SUIDs3 = case length(Nodes) >= N3 of
				true  -> [(lists:nth(N3, Nodes))#cls_node.suid | SUIDs2];
				false -> SUIDs2
			end,
			SUIDs4 = case length(Nodes) >= N4 of
				true  -> [(lists:nth(N4, Nodes))#cls_node.suid | SUIDs3];
				false -> SUIDs3
			end,
			insert_into_city(SceneID, 0, SUIDs4, RuleID, GroupID),
			N + 1
	end, 1, SceneIDs).


%% 8跨服阶段
divide_lv2_city_8group([], SceneIDs, _RuleID, _GroupID) ->
	SceneIDs;
divide_lv2_city_8group(Nodes, [SceneID1, SceneID2, SceneID3, SceneID4 | T2], RuleID, GroupID) ->
	% Nodes = ut_rand:shuffle(Nodes0),
	lists:foldl(fun
		(SceneID, N) ->
			{N1, N2, N3, N4} = case N of
				1 -> {7, 8, 1, 2};
				2 -> {1, 2, 3, 4};
				3 -> {3, 4, 5, 6};
				4 -> {5, 6, 7, 8}
			end,
			SUIDs1 = case length(Nodes) >= N1 of
				true  -> [(lists:nth(N1, Nodes))#cls_node.suid];
				false -> []
			end,
			SUIDs2 = case length(Nodes) >= N2 of
				true  -> [(lists:nth(N2, Nodes))#cls_node.suid | SUIDs1];
				false -> SUIDs1
			end,
			SUIDs3 = case length(Nodes) >= N3 of
				true  -> [(lists:nth(N3, Nodes))#cls_node.suid | SUIDs2];
				false -> SUIDs2
			end,
			SUIDs4 = case length(Nodes) >= N4 of
				true  -> [(lists:nth(N4, Nodes))#cls_node.suid | SUIDs3];
				false -> SUIDs3
			end,
			insert_into_city(SceneID, 0, SUIDs4, RuleID, GroupID),
			N + 1
	end, 1, [SceneID1, SceneID2, SceneID3, SceneID4]),
	T2.


divide_lv3_city([], Scenes, _RuleID, _GroupID) ->
	Scenes;
divide_lv3_city(_Nodes, Scenes, RuleID, GroupID) ->
	[SceneID | T2] = maps:get(3, Scenes),
	insert_into_city(SceneID, 0, [], RuleID, GroupID),
	maps:put(3, T2, Scenes).

insert_into_city(SceneID, Owner, SUIDs, RuleID, GroupID) ->
	BossInfo = get_boss_info(),
	BossNum  = maps:get(SceneID, BossInfo, length(cfg_siegewar_boss:bosses(SceneID))),
	ets:insert(?ETS_SIEGEWAR_CITY, #siegecity{
		scene = SceneID,
		owner = Owner,
		enter = lists:sort(SUIDs),
		temp  = false,
		boss  = BossNum,
		score = #{},
		rule  = RuleID,
		group = GroupID
	}).

-define(k_8group, {?MODULE,'8group'}).
get_8group() ->
	get(?k_8group).

set_8group() ->
	put(?k_8group, true).

-define(k_group, {?MODULE,group}).
get_group() ->
	get(?k_group).

set_group(GroupID) ->
	put(?k_group, GroupID).

-define(k_boss_info, {?MODULE,boss_info}).
get_boss_info() ->
	get(?k_boss_info).

set_boss_info() ->
	BossInfo = lists:foldl(fun
		(City, Acc) ->
			#siegecity{scene=SceneID, boss=BossNum} = City,
			maps:put(SceneID, BossNum, Acc)
	end, #{}, ets:tab2list(?ETS_SIEGEWAR_CITY)),
	put(?k_boss_info, BossInfo).

clr_boss_info() ->
	erase(?k_boss_info).

%%%-----------------------------------------------------------------------------
%%% Test Functions
%%%-----------------------------------------------------------------------------
divide_test_() ->
	Date = ut_time:date(),
	Rule = cfg_game:siegewar_divide(),
	{Min1, Max1} = proplists:get_value(1, Rule),
	{Min2, Max2} = proplists:get_value(2, Rule),
	{Min3, Max3} = proplists:get_value(3, Rule),
	Scenes1 = maps:get(1, test_scenes()),
	Scenes2 = maps:get(2, test_scenes()),
	Scenes3 = maps:get(3, test_scenes()),
	_ = {Min1, Max1, Min2, Max2, Min3, Max3, length(Scenes1), length(Scenes2), length(Scenes3)},
	[
		?_assertEqual(
			[],
			do_test(Date, [1,1,1,1,1,1,1,1])
		),
		?_assertEqual(
			[],
			do_test(Date, [Min1,1,1,1,1,1,1,1])
		),
		?_assertEqual(
			[
				{1, lists:nth(1, Scenes1), 1, [1]},
				{1, lists:nth(1, Scenes2), 0, [1]},
				{1, lists:nth(2, Scenes2), 0, [1]},
				{1, lists:nth(1, Scenes3), 0, []}
			],
			do_test(Date, [Max1,1,1,1,1,1,1,1])
		),
		?_assertEqual(
			[
				{1, lists:nth(1, Scenes1), 1, [1]},
				{1, lists:nth(2, Scenes1), 2, [2]},
				{1, lists:nth(1, Scenes2), 0, [1,2]},
				{1, lists:nth(2, Scenes2), 0, [1,2]},
				{1, lists:nth(1, Scenes3), 0, []}
			],
			do_test(Date, [Min1,Min1,1,1,1,1,1,1])
		),
		?_assertEqual(
			[
				{1, lists:nth(1, Scenes1), 1, [1]},
				{1, lists:nth(2, Scenes1), 2, [2]},
				{1, lists:nth(1, Scenes2), 0, [1,2]},
				{1, lists:nth(2, Scenes2), 0, [1,2]},
				{1, lists:nth(1, Scenes3), 0, []}
			],
			do_test(Date, [Max1,Min1,1,1,1,1,1,1])
		),
		?_assertEqual(
			[
				{1, lists:nth(1, Scenes1), 1, [1]},
				{1, lists:nth(2, Scenes1), 2, [2]},
				{1, lists:nth(1, Scenes2), 0, [1,2]},
				{1, lists:nth(2, Scenes2), 0, [1,2]},
				{1, lists:nth(1, Scenes3), 0, []}
			],
			do_test(Date, [Min2,Min1,1,1,1,1,1,1])
		),
		?_assertEqual(
			[
				{1, lists:nth(1, Scenes1), 1, [1]},
				{1, lists:nth(2, Scenes1), 2, [2]},
				{1, lists:nth(1, Scenes2), 0, [1,2]},
				{1, lists:nth(2, Scenes2), 0, [1,2]},
				{1, lists:nth(1, Scenes3), 0, []}
			],
			do_test(Date, [Min1,Min1,Min1,1,1,1,1,1])
		),
		?_assertEqual(
			[
				{1, lists:nth(1, Scenes1), 1, [1]},
				{1, lists:nth(2, Scenes1), 2, [2]},
				{1, lists:nth(1, Scenes2), 0, [1,2]},
				{1, lists:nth(2, Scenes2), 0, [1,2]},
				{1, lists:nth(1, Scenes3), 0, []}
			],
			do_test(Date, [Max1,Min1,Min1,1,1,1,1,1])
		),
		?_assertEqual(
			[
				{1, lists:nth(1, Scenes1), 1, [1]},
				{1, lists:nth(2, Scenes1), 2, [2]},
				{1, lists:nth(1, Scenes2), 0, [1,2]},
				{1, lists:nth(2, Scenes2), 0, [1,2]},
				{1, lists:nth(1, Scenes3), 0, []}
			],
			do_test(Date, [Min2,Min1,Min1,1,1,1,1,1])
		),
		?_assertEqual(
			[
				{2, lists:nth(1, Scenes1), 1, [1]},
				{1, lists:nth(2, Scenes1), 2, [2]},
				{1, lists:nth(3, Scenes1), 3, [3]},
				{2, lists:nth(1, Scenes2), 0, [1]},
				{2, lists:nth(2, Scenes2), 0, [1]},
				{1, lists:nth(3, Scenes2), 0, [2,3]},
				{1, lists:nth(4, Scenes2), 0, [2,3]},
				{2, lists:nth(1, Scenes3), 0, []},
				{1, lists:nth(2, Scenes3), 0, []}
			],
			do_test(Date, [Max2,Min1,Min1,1,1,1,1,1])
		),
		?_assertEqual(
			[
				{1, lists:nth(1, Scenes1), 1, [1]},
				{1, lists:nth(2, Scenes1), 2, [2]},
				{1, lists:nth(3, Scenes1), 3, [3]},
				{1, lists:nth(4, Scenes1), 4, [4]},
				{1, lists:nth(1, Scenes2), 0, [1,2]},
				{1, lists:nth(2, Scenes2), 0, [1,2]},
				{1, lists:nth(3, Scenes2), 0, [3,4]},
				{1, lists:nth(4, Scenes2), 0, [3,4]},
				{1, lists:nth(1, Scenes3), 0, []},
				{1, lists:nth(2, Scenes3), 0, []}
			],
			do_test(Date, [Min1,Min1,Min1,Min1,1,1,1,1])
		),
		?_assertEqual(
			[
				{1, lists:nth(1, Scenes1), 1, [1]},
				{1, lists:nth(2, Scenes1), 2, [2]},
				{1, lists:nth(3, Scenes1), 3, [3]},
				{1, lists:nth(4, Scenes1), 4, [4]},
				{1, lists:nth(5, Scenes1), 5, [5]},
				{1, lists:nth(6, Scenes1), 6, [6]},
				{1, lists:nth(7, Scenes1), 7, [7]},
				{1, lists:nth(8, Scenes1), 8, [8]},
				{1, lists:nth(1, Scenes2), 0, [1,2]},
				{1, lists:nth(2, Scenes2), 0, [1,2]},
				{1, lists:nth(3, Scenes2), 0, [3,4]},
				{1, lists:nth(4, Scenes2), 0, [3,4]},
				{1, lists:nth(5, Scenes2), 0, [5,6]},
				{1, lists:nth(6, Scenes2), 0, [5,6]},
				{1, lists:nth(7, Scenes2), 0, [7,8]},
				{1, lists:nth(8, Scenes2), 0, [7,8]},
				{1, lists:nth(1, Scenes3), 0, []},
				{1, lists:nth(2, Scenes3), 0, []},
				{1, lists:nth(3, Scenes3), 0, []},
				{1, lists:nth(4, Scenes3), 0, []}
			],
			do_test(Date, [Min1,Min1,Min1,Min1,Min1,Min1,Min1,Min1])
		),
		?_assertEqual(
			[
				{2, lists:nth(1, Scenes1), 1, [1]},
				{2, lists:nth(2, Scenes1), 2, [2]},
				{2, lists:nth(3, Scenes1), 3, [3]},
				{2, lists:nth(4, Scenes1), 4, [4]},
				{2, lists:nth(1, Scenes2), 0, [1,2,3,4]},
				{2, lists:nth(2, Scenes2), 0, [1,2,3,4]},
				{2, lists:nth(1, Scenes3), 0, []}
			],
			do_test(Date, [Min2,Min2,Min2,Min2,1,1,1,1])
		),
		?_assertEqual(
			[
				{2, lists:nth(1, Scenes1), 1, [1]},
				{2, lists:nth(2, Scenes1), 2, [2]},
				{2, lists:nth(3, Scenes1), 3, [3]},
				{2, lists:nth(4, Scenes1), 4, [4]},
				{1, lists:nth(5, Scenes1), 5, [5]},
				{2, lists:nth(1, Scenes2), 0, [1,2,3,4]},
				{2, lists:nth(2, Scenes2), 0, [1,2,3,4]},
				{1, lists:nth(3, Scenes2), 0, [5]},
				{1, lists:nth(4, Scenes2), 0, [5]},
				{2, lists:nth(1, Scenes3), 0, []},
				{1, lists:nth(2, Scenes3), 0, []}
			],
			do_test(Date, [Min2,Min2,Min2,Min2,Min2,1,1,1])
		),
		?_assertEqual(
			[
				{2, lists:nth(1, Scenes1), 1, [1]},
				{2, lists:nth(2, Scenes1), 2, [2]},
				{2, lists:nth(3, Scenes1), 3, [3]},
				{2, lists:nth(4, Scenes1), 4, [4]},
				{1, lists:nth(5, Scenes1), 5, [5]},
				{1, lists:nth(6, Scenes1), 6, [6]},
				{2, lists:nth(1, Scenes2), 0, [1,2,3,4]},
				{2, lists:nth(2, Scenes2), 0, [1,2,3,4]},
				{1, lists:nth(3, Scenes2), 0, [5,6]},
				{1, lists:nth(4, Scenes2), 0, [5,6]},
				{2, lists:nth(1, Scenes3), 0, []},
				{1, lists:nth(2, Scenes3), 0, []}
			],
			do_test(Date, [Min2,Min2,Min2,Min2,Min2,Min2,1,1])
		),
		?_assertEqual(
			[
				{2, lists:nth(1, Scenes1), 1, [1]},
				{2, lists:nth(2, Scenes1), 2, [2]},
				{2, lists:nth(3, Scenes1), 3, [3]},
				{2, lists:nth(4, Scenes1), 4, [4]},
				{1, lists:nth(5, Scenes1), 5, [5]},
				{1, lists:nth(6, Scenes1), 6, [6]},
				{1, lists:nth(7, Scenes1), 7, [7]},
				{2, lists:nth(1, Scenes2), 0, [1,2,3,4]},
				{2, lists:nth(2, Scenes2), 0, [1,2,3,4]},
				{1, lists:nth(3, Scenes2), 0, [5,6]},
				{1, lists:nth(4, Scenes2), 0, [5,6]},
				{1, lists:nth(5, Scenes2), 0, [7]},
				{1, lists:nth(6, Scenes2), 0, [7]},
				{2, lists:nth(1, Scenes3), 0, []},
				{1, lists:nth(2, Scenes3), 0, []},
				{1, lists:nth(3, Scenes3), 0, []}
			],
			do_test(Date, [Min2,Min2,Min2,Min2,Min2,Min2,Min2,1])
		),
		?_assertEqual(
			[
				{2, lists:nth(1, Scenes1), 1, [1]},
				{2, lists:nth(2, Scenes1), 2, [2]},
				{2, lists:nth(3, Scenes1), 3, [3]},
				{2, lists:nth(4, Scenes1), 4, [4]},
				{1, lists:nth(5, Scenes1), 5, [5]},
				{1, lists:nth(6, Scenes1), 6, [6]},
				{1, lists:nth(7, Scenes1), 7, [7]},
				{2, lists:nth(1, Scenes2), 0, [1,2,3,4]},
				{2, lists:nth(2, Scenes2), 0, [1,2,3,4]},
				{1, lists:nth(3, Scenes2), 0, [5,6]},
				{1, lists:nth(4, Scenes2), 0, [5,6]},
				{1, lists:nth(5, Scenes2), 0, [7]},
				{1, lists:nth(6, Scenes2), 0, [7]},
				{2, lists:nth(1, Scenes3), 0, []},
				{1, lists:nth(2, Scenes3), 0, []},
				{1, lists:nth(3, Scenes3), 0, []}
			],
			do_test(Date, [Max2,Min2,Min2,Min2,Min2,Min2,Min2,1])
		),
		?_assertEqual(
			[
				{2, lists:nth(1, Scenes1), 1, [1]},
				{2, lists:nth(2, Scenes1), 2, [2]},
				{2, lists:nth(3, Scenes1), 3, [3]},
				{2, lists:nth(4, Scenes1), 4, [4]},
				{1, lists:nth(5, Scenes1), 5, [5]},
				{1, lists:nth(6, Scenes1), 6, [6]},
				{1, lists:nth(7, Scenes1), 7, [7]},
				{2, lists:nth(1, Scenes2), 0, [1,2,3,4]},
				{2, lists:nth(2, Scenes2), 0, [1,2,3,4]},
				{1, lists:nth(3, Scenes2), 0, [5,6]},
				{1, lists:nth(4, Scenes2), 0, [5,6]},
				{1, lists:nth(5, Scenes2), 0, [7]},
				{1, lists:nth(6, Scenes2), 0, [7]},
				{2, lists:nth(1, Scenes3), 0, []},
				{1, lists:nth(2, Scenes3), 0, []},
				{1, lists:nth(3, Scenes3), 0, []}
			],
			do_test(Date, [Min3,Min2,Min2,Min2,Min2,Min2,Min2,1])
		),
		?_assertEqual(
			[
				{2, lists:nth(1, Scenes1), 1, [1]},
				{2, lists:nth(2, Scenes1), 2, [2]},
				{2, lists:nth(3, Scenes1), 3, [3]},
				{2, lists:nth(4, Scenes1), 4, [4]},
				{2, lists:nth(5, Scenes1), 5, [5]},
				{2, lists:nth(6, Scenes1), 6, [6]},
				{2, lists:nth(7, Scenes1), 7, [7]},
				{2, lists:nth(8, Scenes1), 8, [8]},
				{2, lists:nth(1, Scenes2), 0, [1,2,3,4]},
				{2, lists:nth(2, Scenes2), 0, [1,2,3,4]},
				{2, lists:nth(3, Scenes2), 0, [5,6,7,8]},
				{2, lists:nth(4, Scenes2), 0, [5,6,7,8]},
				{2, lists:nth(1, Scenes3), 0, []},
				{2, lists:nth(2, Scenes3), 0, []}
			],
			do_test(Date, [Min2,Min2,Min2,Min2,Min2,Min2,Min2,Min2])
		),
		?_assertEqual(
			[
				{2, lists:nth(1, Scenes1), 1, [1]},
				{2, lists:nth(2, Scenes1), 2, [2]},
				{2, lists:nth(3, Scenes1), 3, [3]},
				{2, lists:nth(4, Scenes1), 4, [4]},
				{1, lists:nth(5, Scenes1), 5, [5]},
				{1, lists:nth(6, Scenes1), 6, [6]},
				{1, lists:nth(7, Scenes1), 7, [7]},
				{2, lists:nth(1, Scenes2), 0, [1,2,3,4]},
				{2, lists:nth(2, Scenes2), 0, [1,2,3,4]},
				{1, lists:nth(3, Scenes2), 0, [5,6]},
				{1, lists:nth(4, Scenes2), 0, [5,6]},
				{1, lists:nth(5, Scenes2), 0, [7]},
				{1, lists:nth(6, Scenes2), 0, [7]},
				{2, lists:nth(1, Scenes3), 0, []},
				{1, lists:nth(2, Scenes3), 0, []},
				{1, lists:nth(3, Scenes3), 0, []}
			],
			do_test(Date, [Min2,Min2,Min2,Min2,Max1,Max1,Max1,1])
		),
		?_assertEqual(
			[
				{3, lists:nth(1, Scenes1), 1, [1]},
				{3, lists:nth(2, Scenes1), 2, [2]},
				{3, lists:nth(3, Scenes1), 3, [3]},
				{3, lists:nth(4, Scenes1), 4, [4]},
				{3, lists:nth(5, Scenes1), 5, [5]},
				{3, lists:nth(6, Scenes1), 6, [6]},
				{3, lists:nth(7, Scenes1), 7, [7]},
				{3, lists:nth(8, Scenes1), 8, [8]},
				{3, lists:nth(1, Scenes2), 0, [1,2,7,8]},
				{3, lists:nth(2, Scenes2), 0, [1,2,3,4]},
				{3, lists:nth(3, Scenes2), 0, [3,4,5,6]},
				{3, lists:nth(4, Scenes2), 0, [5,6,7,8]},
				{3, lists:nth(1, Scenes3), 0, []}
			],
			do_test(Date, [Min3,Min3,Min3,Min3,Min3,Min3,Min3,Min3])
		),
		?_assertEqual(
			[
				{3, lists:nth(1, Scenes1), 1, [1]},

				{2, lists:nth(2, Scenes1), 2, [2]},
				{2, lists:nth(3, Scenes1), 3, [3]},
				{2, lists:nth(4, Scenes1), 4, [4]},

				{1, lists:nth(5, Scenes1), 5, [5]},
				{1, lists:nth(6, Scenes1), 6, [6]},

				{1, lists:nth(7, Scenes1), 7, [7]},

				{3, lists:nth(1, Scenes2), 0, [1]},
				{3, lists:nth(2, Scenes2), 0, [1]},
				{3, lists:nth(3, Scenes2), 0, []},
				{3, lists:nth(4, Scenes2), 0, []},

				{2, lists:nth(5, Scenes2), 0, [2,3,4]},
				{2, lists:nth(6, Scenes2), 0, [2,3,4]},

				{1, lists:nth(7, Scenes2), 0, [5,6]},
				{1, lists:nth(8, Scenes2), 0, [5,6]},

				{1, lists:nth(9, Scenes2), 0, [7]},
				{1, lists:nth(10, Scenes2), 0, [7]},

				{3, lists:nth(1, Scenes3), 0, []},
				{2, lists:nth(2, Scenes3), 0, []},
				{1, lists:nth(3, Scenes3), 0, []},
				{1, lists:nth(4, Scenes3), 0, []}
			],
			do_test(Date, [Max3, Min3,Max2,Max2, Max1,Max1, Max1, 1])
		),
		?_assertEqual(
			[
				{3, lists:nth(1, Scenes1), 1, [1]},

				{2, lists:nth(2, Scenes1), 2, [2]},
				{2, lists:nth(3, Scenes1), 3, [3]},
				{2, lists:nth(4, Scenes1), 4, [4]},
				{2, lists:nth(5, Scenes1), 5, [5]},

				{2, lists:nth(6, Scenes1), 6, [6]},

				{1, lists:nth(7, Scenes1), 7, [7]},
				{1, lists:nth(8, Scenes1), 8, [8]},

				{3, lists:nth(1, Scenes2), 0, [1]},
				{3, lists:nth(2, Scenes2), 0, [1]},
				{3, lists:nth(3, Scenes2), 0, []},
				{3, lists:nth(4, Scenes2), 0, []},

				{2, lists:nth(5, Scenes2), 0, [2,3,4,5]},
				{2, lists:nth(6, Scenes2), 0, [2,3,4,5]},

				{2, lists:nth(7, Scenes2), 0, [6]},
				{2, lists:nth(8, Scenes2), 0, [6]},

				{1, lists:nth(9, Scenes2), 0, [7,8]},
				{1, lists:nth(10, Scenes2), 0, [7,8]},

				{3, lists:nth(1, Scenes3), 0, []},
				{2, lists:nth(2, Scenes3), 0, []},
				{2, lists:nth(3, Scenes3), 0, []},
				{1, lists:nth(4, Scenes3), 0, []}
			],
			do_test(Date, [Max3, Min3,Max2,Max2,Max2, Max2, Max1, Min1])
		),
		?_assertEqual(ok, ok)
	].


do_test(Date, OpdaysList) ->
	ets:delete_all_objects(?ETS_SIEGEWAR_CITY),
	% ?debug("~n~n~nbegin-----------------------------------"),
	Nodes = [
		#cls_node{
			suid  = SUID,
			otime = ut_time:datetime_to_seconds({ut_time:add_days(Date, 1-Opdays),{10,0,0}})
		} || {SUID, Opdays} <- lists:zip(lists:seq(1, 8), OpdaysList)
	],
	do_divide_cross(Nodes, test_scenes()),
	CityList = lists:keysort(#siegecity.scene, ets:tab2list(?ETS_SIEGEWAR_CITY)),
	% ?debug("CityList: ~w", [CityList]),
	% ?debug("~nend-----------------------------------"),
	[{RuleID, SceneID, Owner, SUIDs} || #siegecity{
		scene = SceneID,
		owner = Owner,
		enter = SUIDs,
		rule  = RuleID
	} <- CityList].

test_scenes() ->
	#{
		1 => [101,102,103,104,105,106,107,108],
		2 => [201,202,203,204,205,206,207,208,209,210,211,212,213,214,215,216],
		3 => [301,302,303,304,305,306,307,308]
	}.
