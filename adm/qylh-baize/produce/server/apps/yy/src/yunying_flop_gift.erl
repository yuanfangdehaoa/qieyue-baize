%%%=============================================================================
%%% @author zhengjingyi
%%% @doc
%%% 翻牌好礼
%%% @end
%%%=============================================================================

-module(yunying_flop_gift).

-include("game.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").
-include("table.hrl").
-include("yunying.hrl").


%% API
-export([handle/3]).
-export([hook_reset/3, get_cost/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 请求翻牌活动信息
handle(?FLOPGIFT_INFO, _Tos, RoleSt) ->
	check_open(RoleSt#role_st.role),
	%% 前端请求翻牌信息
	#role_flop_gift{
		level = Level,
		cur_round = CurRound,
		rewards_round = RewardsRound
	} = get_flopgift_data(),
	FlopRoundData =
		maps:fold(
			fun(Round, FlopDatas, Acc) ->
				Fetch =
					lists:foldl(
						fun({Pos, _PosFlop, ItemID, ItemCount}, AccIn) ->
							[#p_flop_data{pos = Pos, item_id = ItemID, item_count = ItemCount}|AccIn]
						end, [], FlopDatas),
				[#p_flop_round_data{round = Round, fetch = Fetch}|Acc]
			end, [], RewardsRound),
	Toc = #m_flopgift_info_toc{
		level = Level,
		cur_round = CurRound,
		flop_round_data = FlopRoundData
	},
	{ok, Toc , RoleSt};

%% 翻牌
handle(?FLOPGIFT_TURN, Tos, RoleSt) ->
	check_open(RoleSt#role_st.role),
	check_bag(),
	#m_flopgift_turn_tos{pos = Pos} = Tos,
	RoleFlopGift =
		#role_flop_gift{
			level = Level,
			cur_round = CurRound,
			rewards_round = RewardsRound
		} = get_flopgift_data(),
	ItemList = get_round_reward(CurRound, Level),    %% 获取当前轮的奖池数据
	%% 检查前端发过来的牌位是否已抽取或者是否在奖池范围内
	CurRewards = maps:get(CurRound, RewardsRound, []),
	IsPosValid = lists:keymember(Pos, 1, ItemList),
	IsPosHasReward = lists:keymember(Pos, 1, CurRewards),
	%% 位置在奖池内且未抽取该位置
	?_check(IsPosValid andalso (not IsPosHasReward), ?ERR_GAME_BAD_ARGS),
	ItemList2 =
		lists:foldl(
			fun({_Pos, PosFlop, _ItemId, _ItemCount}, Acc) ->
				lists:keydelete(PosFlop, 1, Acc)
			end, ItemList, CurRewards),
	?_check(length(ItemList2) > 0, ?ERR_GAME_BAD_PKG),
	CostPos = erlang:length(ItemList) - erlang:length(ItemList2) + 1,
	{PosFlop, ItemId, ItemCount, IsBind, IsLuck} = ut_rand:weight(ItemList2, 5),
	Gain = [{ItemId, ItemCount, IsBind}],
	Cost = get_cost(CurRound, CostPos),
	Succ =
		fun() ->
			CurRewards2 = [{Pos, PosFlop, ItemId, ItemCount}|CurRewards],
			RewardsRound2 = maps:put(CurRound, CurRewards2, RewardsRound),
			RoleFlopGift2 = RoleFlopGift#role_flop_gift{last_secs = ut_time:seconds(), rewards_round = RewardsRound2},
			role_data:set(RoleFlopGift2),
			case erlang:is_integer(IsLuck) andalso IsLuck > 0 of
				true ->
					#role_st{role=RoleID, name=RoleName} = RoleSt,
					ItemMaps = maps:put(ItemId, 0, #{}),
					Args = [{role, RoleID, RoleName}, {item, ItemMaps}],
					?notify(?MSG_FLOP_GIFT, Args);
				false ->
					igore
			end
		end,
	role_bag:deal(Cost, Gain, ?LOG_YYLOGIN_FLOP_GIFT, Succ, RoleSt),
	FlopData = #p_flop_data{pos = Pos, item_id = ItemId, item_count = ItemCount},
	Toc = #m_flopgift_turn_toc{flop_data = FlopData},
	{ok, Toc, RoleSt};


%% 刷新下一轮
handle(?FLOPGIFT_NEXT_ROUND, _Tos, RoleSt) ->
	check_open(RoleSt#role_st.role),
	RoleFlopGift =
		#role_flop_gift{
			level = Level,
			cur_round = CurRound,
			rewards_round = RewardsRound
		} = get_flopgift_data(),
	NextRound = CurRound + 1,
	CfgNextRound = cfg_yunying_flop_gift:find(NextRound),
	?_check(erlang:is_record(CfgNextRound, cfg_yunying_flop_gift), ?ERR_GAME_SYS_ERROR),
	Cost = get_reset(CurRound),
	Gain = [],
	CurRoundRewards = maps:get(CurRound, RewardsRound, []),
	CurRoundRewardsCfg = get_round_reward(CurRound, Level),
	Pred =
		fun({_Pos, PosFlop, _ItemId, _ItemCount}) ->
			case lists:keyfind(PosFlop, 1, CurRoundRewardsCfg) of
				{PosFlop, _ItemID, _ItemCount, _IsBind, _Weight, IsLuck} when erlang:is_integer(IsLuck), IsLuck > 0 ->
					true;
				_ ->
					false
			end
		end,
	IsLuck = lists:any(Pred, CurRoundRewards),
	%% 是否抽到大奖或者全部抽完了
	?_check(IsLuck orelse (erlang:length(CurRoundRewards) == erlang:length(CurRoundRewardsCfg)), ?ERR_GAME_BAD_PKG),
	?_if(IsLuck, ok, role_bag:deal(Cost, Gain, ?LOG_YYLOGIN_FLOP_GIFT, RoleSt)),
	RoleFlopGift2 = RoleFlopGift#role_flop_gift{last_secs = ut_time:seconds(), cur_round = NextRound},
	role_data:set(RoleFlopGift2),
	Toc = #m_flopgift_next_round_toc{round = NextRound},
	{ok, Toc, RoleSt}.


% 重置
hook_reset(_NowDoW, _NowHour, _RoleSt) ->
	#role_info{id=RoleID, level = Level} = role_data:get(?DB_ROLE_INFO),
	NowSecs = ut_time:seconds(),
	RoleFlopFigtReset = #role_flop_gift{id = RoleID, level = Level, last_secs = NowSecs},
	role_data:set(RoleFlopFigtReset),
	?debug("flop gift reset RoleID, NowSecs, LastSecs : ~p~n", [{RoleID, Level, NowSecs}]).



%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
get_flopgift_data() ->
	role_data:get(?DB_ROLE_FLOP_GIFT).


%% @doc 获取该轮奖励
%% @return: list()
get_round_reward(Round, Level) ->
	case cfg_yunying_flop_gift:find(Round) of
		#cfg_yunying_flop_gift{reward = Reward} ->
			get_round_reward2(Reward, Level);
		_ ->
			[]
	end.


get_round_reward2([{ {LevelMin, LevelMax}, ItemList} | _L], Level) when Level >= LevelMin, Level =< LevelMax ->
	ItemList;
get_round_reward2([_|L], Level) ->
	get_round_reward2(L, Level);
get_round_reward2([], Level) ->
	?error("Err level flop gift reward : ~p~n", [Level]),
	throw(?err(?ERR_GAME_SYS_ERROR)).


get_cost(Round, CostPos) ->
	CostL = get_cfg_data(Round, #cfg_yunying_flop_gift.cost),
	[lists:nth(CostPos, CostL)].

get_reset(Round) ->
	get_cfg_data(Round, #cfg_yunying_flop_gift.reset).

get_cfg_data(Round, RecPos) ->
	CfgData = cfg_yunying_flop_gift:find(Round),
	erlang:element(RecPos, CfgData).


check_open(RoleID) ->
	{ok, #role_cache{level=RequestLv}} = role:get_cache(RoleID),
	SysID = cfg_sysopen:sysid(?MODULE),
	case lists:keyfind(SysID, 1, cfg_sysopen:syslist()) of
		{_, NeedLv, _} ->
			?_check(RequestLv >= NeedLv, ?ERR_GAME_SYS_NOT_OPEN);
		false ->
			throw(?err(?ERR_GAME_SYS_NOT_OPEN))
	end.

check_bag() ->
	BagIds = cfg_game:flop_gift(),
	check_bag(BagIds).

check_bag([BagID|BagIds]) ->
	?_check(role_bag:get_empty(BagID) > 0, ?ERR_BAG_NO_SPACE, [BagID]),
	check_bag(BagIds);

check_bag([]) ->
	true.