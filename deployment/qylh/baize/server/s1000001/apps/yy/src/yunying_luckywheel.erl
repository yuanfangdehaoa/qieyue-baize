%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(yunying_luckywheel).

-include("game.hrl").
-include("role.hrl").
-include("yunying.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([
	  handle/3
	, hook_reset/3
]).

-define(YY_ACT_TYPE_LUCKYWHEEL, 100).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
handle(?LUCKYWHEEL_INFO, _Tos, RoleSt) ->
	Data = role_data:get(?DB_ROLE_LUCKYWHEEL),
	?ucast(#m_luckywheel_info_toc{
		act_id = get_act_id(),
		round = Data#role_luckywheel.round,
		fetch = Data#role_luckywheel.fetch
	});

handle(?LUCKYWHEEL_TURN, Tos, RoleSt) when Tos#m_luckywheel_turn_tos.type == 0 ->
	#role_luckywheel{round=Round, fetch=Fetch} = role_data:get(?DB_ROLE_LUCKYWHEEL),
	YYActID = get_act_id(),
	{_, Reward, _} = cfg_yunying_luckywheel:find(Round, YYActID),
	Reward1 = [R || R={ID,_,_} <- Reward, not lists:member(ID, Fetch)],
	{Grid, _} = ut_rand:weight(Reward1),
	set_wheel_grid(Grid),
	?ucast(#m_luckywheel_turn_toc{type=0, grid=Grid});
handle(?LUCKYWHEEL_TURN, _Tos, RoleSt) ->
	YYActID = get_act_id(),
	case is_start(YYActID) andalso get_wheel_grid() of
		Grid when is_integer(Grid) ->
			Data = role_data:get(?DB_ROLE_LUCKYWHEEL),
			#role_luckywheel{round=Round, fetch=_Fetch} = Data,
			{Cost, Reward, VipLim} = cfg_yunying_luckywheel:find(Round, YYActID),
			VipLv = role_vip:get_level(),
			?_check(VipLv >= VipLim, ?ERR_VIP_NOT_ENOUGH),
			{_, Gold, _} = lists:keyfind(Grid, 1, Reward),
			LogID = yunying_util:calc_logid(YYActID),
			role_bag:deal(Cost, [{?ITEM_GOLD,Gold}], LogID, RoleSt),
			% Fetch2 = [Grid | Fetch],
			Fetch2 = [],
			Round2 = Round + 1,
			role_data:set(Data#role_luckywheel{round=Round2, fetch=Fetch2}),
			?ucast(#m_luckywheel_turn_toc{type=1, grid=Grid});
		_ ->
			ignore
	end.


hook_reset(_NowDoW, _NowHour, RoleSt) ->
	YYActID = get_act_id(),
	case is_start(YYActID) of
		true  ->
			#role_luckywheel{period=Period1} = role_data:get(?DB_ROLE_LUCKYWHEEL),
			Cfg = yunying_util:cfg_act_mod(YYActID),
			#cfg_yunying{reqs=Reqs} = Cfg:find(YYActID),
			Period2 = proplists:get_value(period, Reqs),
			case Period1 == Period2 of
				true  -> ignore;
				false -> role_data:set(#role_luckywheel{id=RoleSt#role_st.role})
			end;
		false ->
			role_data:set(#role_luckywheel{id=RoleSt#role_st.role})
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
get_act_id() ->
	get_act_id2(cfg_yunying:type(?YY_ACT_TYPE_LUCKYWHEEL)).

get_act_id2([YYActID | T]) ->
	case yunying:is_start(YYActID) of
		true  -> YYActID;
		false -> get_act_id2(T)
	end;
get_act_id2([]) ->
	0.

is_start(YYActID) ->
	YYActID > 0.

-define(k_luckywheel_grid, k_luckywheel_grid).
get_wheel_grid() ->
	get(?k_luckywheel_grid).

set_wheel_grid(Grid) ->
	put(?k_luckywheel_grid, Grid).
