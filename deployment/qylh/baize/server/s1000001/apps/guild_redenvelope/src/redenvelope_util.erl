%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(redenvelope_util).

-include("proto.hrl").
-include("guild_redenvelope.hrl").
-include("enum.hrl").

%% API
-export([snatch/2]).
-export([is_snatched/2]).
-export([filter_expire/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
snatch(RedEnvelope, RedEnvelopeGot)->
	#p_redenvelope{id=Id, gots=GotList, num=Num, money=TotalMoneyMap, state=State} = RedEnvelope,
	#cfg_guild_redenvelope{type_id=TypeId, range=Range} = cfg_guild_redenvelope:find(Id),
	Money2 = lists:foldl(fun 
			(#p_redenvelope_got{money=Money}, Acc) -> 
				Acc + Money
		end, 0, GotList),
	GotNum = length(GotList),
	LeftNum = Num - GotNum,
	[TotalMoney] = maps:values(TotalMoneyMap),
	LeftMoney = TotalMoney - Money2,
	GotMoney = case TypeId of
		2 -> %手动红包
			get_money(LeftNum, LeftMoney);
		_ -> 
			get_money2(TotalMoney, Num, LeftNum, LeftMoney, GotNum, Money2, Range)
	end,
	RedEnvelopeGot2 = RedEnvelopeGot#p_redenvelope_got{money=GotMoney, time=ut_time:seconds()},
	GotList2 = [RedEnvelopeGot2 | GotList],
	State2 = case length(GotList2) == Num of
		true  -> ?RED_ENVELOPE_STATE_DONE;
		false -> State
	end,
	RedEnvelope2 = RedEnvelope#p_redenvelope{gots=lists:reverse(GotList2), state=State2},
	{RedEnvelope2, RedEnvelopeGot2}.

%是否已抢过
is_snatched(_RoleId, []) ->
	false;
is_snatched(RoleId, [#p_redenvelope_got{role=Role}|Gots])->
	case RoleId == Role#p_rn_role.id of
		true  -> true;
		false -> is_snatched(RoleId, Gots)
	end.

%删除过期的
filter_expire(RedEnvelopes)->
	Now = ut_time:seconds(),
	maps:filter(fun 
			(_K, #p_redenvelope{time=Time})-> 
				Now - Time < ?redenvelope_expire 
		end, RedEnvelopes).


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%手动红包算法
get_money(LeftNum, LeftMoney)->
	AverageC = ut_math:ceil(LeftMoney/LeftNum),
	case LeftNum == 1 of
		true ->
			LeftMoney;
		false ->
			case AverageC == 1 of
				true -> 
					1;
				false ->
					Average = ut_math:floor(LeftMoney/LeftNum),
					Average2 = Average*2,
					ut_rand:random(1, Average2)
			end
	end.

%非手动红包算法
get_money2(TotalMoney, Num, LeftNum, LeftMoney, GotNum, GotMoney, Range)->
	case LeftNum == 1 of
		true -> 
			LeftMoney;
		false ->
			{Min, Max} = Range,
			Average = ut_math:floor(TotalMoney / Num),
			Average2 = Average + Min,
			Average3 = case Average2 < 1 of
				true  -> 1;
				false -> Average2
			end,
			Left = TotalMoney-Average3*Num - (GotMoney-Average3*GotNum),
			Random = ut_rand:random(Average3, Max+Average),
			case Random >= Left of
				true  -> Left;
				false -> Random
			end
	end.
