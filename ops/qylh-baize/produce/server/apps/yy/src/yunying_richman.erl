%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(yunying_richman).

-include("game.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/3]).
-export([add_dice/3]).
-export([hook_reset/3]).

% 大富豪活动
-define(YY_ACT_TYPE_RICHMAN, 1150).
-define(YY_ACT_TYPE_PAY, 1151).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
handle(?RICHMAN_INFO, _Tos, RoleSt) ->
	hook_reset(null, null, RoleSt),
	Richman = role_data:get(?DB_ROLE_RICHMAN),
	?ucast(#m_richman_info_toc{
		curr_round  = Richman#role_richman.curr_round,
		curr_grid   = Richman#role_richman.curr_grid,
		lucky_round = Richman#role_richman.lucky_round,
		lucky_fetch = Richman#role_richman.lucky_fetch,
		round_fetch = Richman#role_richman.round_fetch,
		dice_gain   = Richman#role_richman.dice_gain,
		dice_mend   = maps:get(-1, Richman#role_richman.dice_gain, 0),
		act_id      = get_act_id()
	});

handle(?RICHMAN_DICE, Tos, RoleSt) when Tos#m_richman_dice_tos.type == 3 ->
	Point = case Tos#m_richman_dice_tos.point of
		?nil -> ut_rand:weight(cfg_game:richman_dice());
		Val  -> Val
	end,
	set_dice_point(Point),
	?ucast(#m_richman_dice_toc{type=3, point=Point, result=0});
handle(?RICHMAN_DICE, Tos, RoleSt) ->
	hook_reset(null, null, RoleSt),
	YYActID = get_act_id(),
	case is_start(YYActID) of
		true  ->
			#m_richman_dice_tos{type=Type} = Tos,
			Point = get_dice_point(),

			Richman = role_data:get(?DB_ROLE_RICHMAN),
			#role_richman{
				curr_round=Round, curr_grid=Grid, lucky_round=LuckyRound, lucky_fetch=Fetch
			} = Richman,

			Grids0 = cfg_yunying_richman:find(YYActID, Round),
			?_check(
				not (Round == cfg_yunying_richman:max(YYActID) andalso Grid >= length(Grids0)),
				?ERR_RICHMAN_MAX_ROUND
			),

			Grids = lists:keysort(1, Grids0),

			Grid1 = min(length(Grids), Grid+Point),
			{_, ResType, ResArg} = lists:nth(Grid1, Grids),

			Grid2 = ?_if(ResType == 5, max(1,Grid1-ResArg), Grid1),
			{_, ResType2, ResArg2} = lists:nth(Grid2, Grids),
			{Gain, Fetch1} = do_dice(ResType2, YYActID, ResArg2, Fetch, LuckyRound),

			Cost = case Type of
				1 -> [{?ITEM_DICE_RANDOM,1}];
				2 -> [{?ITEM_DICE_FIXED,1}]
			end,
			{ok, _, Obtain} = role_bag:deal(Cost, Gain, ?LOG_RICHMAN_DICE, RoleSt),

			#role_st{role=RoleID, name=RoleName} = RoleSt,
			?_if(
				ResType2 == 4,
				?notify(?MSG_RICHMAN_LUCKY, [{role,RoleID,RoleName}, {item,Obtain}])
			),

			case length(Fetch1) >= length(cfg_yunying_richman_luck:list(YYActID, LuckyRound)) of
				true  ->
					Fetch2 = [],
					LuckyRound2 = LuckyRound+1;
				false ->
					Fetch2 = Fetch1,
					LuckyRound2 = LuckyRound
			end,
%%			{ok, STime, ETime} = yunying:get_act_time(YYActID),
			Richman1 = Richman#role_richman{
				curr_grid   = Grid2,
				lucky_round = LuckyRound2,
				lucky_fetch = Fetch2
%%				act_stime   = STime,
%%				act_etime   = ETime
			},
			Richman2 = case Grid2 >= length(Grids) of
				true  -> Richman1#role_richman{curr_round=Round+1, curr_grid=1};
				false -> Richman1
			end,
			role_data:set(Richman2),

			?_if(
				Grid2 >= length(Grids) orelse LuckyRound /= LuckyRound2,
				?ucast(#m_richman_refrech_toc{})
			),

			?ucast(#m_richman_dice_toc{
				type   = Type,
				point  = Point,
				result = ResType,
				reward = Obtain
			});
		false ->
			ignore
	end;

handle(?RICHMAN_FETCH, Tos, RoleSt) ->
	YYActID = get_act_id(),
	case is_start(YYActID) of
		true  ->
			#m_richman_fetch_tos{round=Round} = Tos,
			Richman = role_data:get(?DB_ROLE_RICHMAN),
			#role_richman{curr_round=CurrRound, round_fetch=Fetch} = Richman,
			?_check(Round =< CurrRound, ?ERR_RICHMAN_CAN_NOT_FETCH),
			?_check(not lists:member(Round, Fetch), ?ERR_RICHMAN_HAD_FETCH),
			All = cfg_yunying_richman_round:list(YYActID),
			?_check(lists:member(Round, All), ?ERR_RICHMAN_CAN_NOT_FETCH),
			Gain = cfg_yunying_richman_round:find(YYActID, Round),
			{ok, Obtain} = role_bag:gain(Gain, ?LOG_RICHMAN_ROUND, RoleSt),
			#role_st{role=RoleID, name=RoleName} = RoleSt,
			?notify(?MSG_RICHMAN_ROUND, [{role,RoleID,RoleName}, {item,Obtain}]),
			Richman2 = Richman#role_richman{round_fetch=[Round | Fetch]},
			role_data:set(Richman2),
			?ucast(#m_richman_fetch_toc{round=Round, reward=Obtain});
		false ->
			ignore
	end;

handle(?RICHMAN_MEND, _Tos, RoleSt) ->
	YYActID = get_act_id(),
	case yunying:get_act_time(YYActID) of
		{ok, StartSecs, _} ->
			Richman  = #role_richman{dice_gain=DiceGain} = role_data:get(?DB_ROLE_RICHMAN),
			NowDate  = ut_time:date(),
			StartDate = ut_time:seconds_to_date(StartSecs),
			DiffDays = abs(ut_time:diff_days(StartDate, NowDate)),
			DiceLim  = cfg_game:richman_dice_limit(),
			MaxMend  = lists:foldl(fun
				(Days, Acc) ->
					MaxNum = proplists:get_value(Days, DiceLim),
					GotNum = maps:get(Days, DiceGain, 0),
					Acc + (MaxNum - GotNum)
			end, 0, lists:seq(1, DiffDays)),

			?_check(MaxMend > 0, ?ERR_RICHMAN_CAN_NOT_MEND),
			MendedNum = maps:get(-1, DiceGain, 0),

			MendPrice = proplists:get_value(MendedNum+1, cfg_game:richman_dice_mend()),

			role_bag:deal([{?ITEM_GOLD,MendPrice}], [{?ITEM_DICE_RANDOM,1}], ?LOG_RICHMAN_MEND, RoleSt),

			DiceGain2 = do_mend(1, DiffDays, DiceGain, DiceLim),

			?debug("MaxMend-----------:~w", [{DiffDays, MaxMend, DiceGain, DiceGain2}]),

			role_data:set(Richman#role_richman{dice_gain=DiceGain2}),
			?ucast(#m_richman_mend_toc{num=1});
		_ ->
			ignore
	end.

add_dice(Num, LogID, _RoleSt) ->
	YYActID = get_act_pay(),
	case YYActID > 0 andalso LogID == yunying_util:calc_logid(YYActID) andalso yunying:get_act_time(YYActID) of
		{ok, StartSecs, _StopSecs} ->
			Richman = #role_richman{dice_gain=DiceGain} = role_data:get(?DB_ROLE_RICHMAN),
			NowDate = ut_time:date(),
			StartDate = ut_time:seconds_to_date(StartSecs),
			DiffDays  = abs(ut_time:diff_days(StartDate, NowDate)) + 1,
			DiceGain2 = ut_misc:maps_increase(DiffDays, Num, DiceGain),
			role_data:set(Richman#role_richman{
				dice_gain = DiceGain2
%%				act_stime = StartSecs,
%%				act_etime = StopSecs
			});
		_ ->
			ignore
	end.

hook_reset(_NowDoW, _NowHour, RoleSt) ->
	YYActID = get_act_id(),
	case is_start(YYActID) of
		true  ->
			Richman = #role_richman{act_stime=STime1, act_etime=ETime1} = role_data:get(?DB_ROLE_RICHMAN),
			{ok, STime2, ETime2} = yunying:get_act_time(YYActID),
			case STime1 == STime2 andalso ETime1 == ETime2 of
				true  ->
					ignore;
				false ->
					role_data:set(#role_richman{id=RoleSt#role_st.role, act_stime=STime2, act_etime=ETime2}),
					?debug("reset11 STime1,STime2, ETime1, ETime2 : ~p~n", [{RoleSt#role_st.role, STime1,STime2, ETime1, ETime2, Richman}])
			end;
		false ->
			?debug("reset22 igore"),
			igore
%%			role_data:set(#role_richman{id=RoleSt#role_st.role})
	end.


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
% 道具奖励
do_dice(3, _YYActID, Reward, Fetch, _LuckyRound) ->
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	{calc_reward(Reward, RoleLv), Fetch};
% 幸运卡
do_dice(4, YYActID, _Arg, Fetch, LuckyRound) ->
	WtList = [{ID,W} ||
		{ID,W} <- cfg_yunying_richman_luck:list(YYActID, LuckyRound),
		not lists:member(ID, Fetch)
	],
	ID   = ut_rand:weight(WtList),
	Gain = cfg_yunying_richman_luck:find(YYActID, ID),
	{Gain, [ID | Fetch]};
% 再掷一次
do_dice(6, _YYActID, _Arg, Fetch, _LuckyRound) ->
	{[{?ITEM_DICE_RANDOM,1}], Fetch};
% 遥控骰子
do_dice(7, _YYActID, _Arg, Fetch, _LuckyRound) ->
	{[{?ITEM_DICE_FIXED,1}], Fetch};
% 空格子
do_dice(8, _YYActID, _Arg, Fetch, _LuckyRound) ->
	{[], Fetch};
do_dice(_, _YYActID, _Arg, Fetch, _LuckyRound) ->
	{[], Fetch}.

calc_reward([{MinLv,MaxLv,Reward} | T], RoleLv) ->
	case RoleLv >= MinLv andalso RoleLv =< MaxLv of
		true  -> Reward;
		false -> calc_reward(T, RoleLv)
	end;
calc_reward([], _RoleLv) ->
	[].

-define(k_dice_point, k_dice_point).
get_dice_point() ->
	erase(?k_dice_point).

set_dice_point(Point) ->
	put(?k_dice_point, Point).

do_mend(MinDays, MaxDays, DiceGain, DiceLim) ->
	MaxNum = proplists:get_value(MinDays, DiceLim),
	GotNum = maps:get(MinDays, DiceGain, 0),
	case GotNum < MaxNum of
		true  ->
			ut_misc:maps_increase(-1, 1, ut_misc:maps_increase(MinDays, 1, DiceGain));
		false ->
			case MinDays > MaxDays of
				true  -> throw(?err(?ERR_RICHMAN_CAN_NOT_MEND));
				false -> do_mend(MinDays+1, MaxDays, DiceGain, DiceLim)
			end
	end.

get_act_id() ->
	get_act_id2(cfg_yunying:type(?YY_ACT_TYPE_RICHMAN)).

get_act_pay() ->
	get_act_id2(cfg_yunying:type(?YY_ACT_TYPE_PAY)).


get_act_id2([YYActID | T]) ->
	case yunying:is_start(YYActID) of
		true  -> YYActID;
		false -> get_act_id2(T)
	end;
get_act_id2([]) ->
	0.

% is_start() ->
% 	is_start(get_act_id()).

is_start(YYActID) ->
	YYActID > 0.
