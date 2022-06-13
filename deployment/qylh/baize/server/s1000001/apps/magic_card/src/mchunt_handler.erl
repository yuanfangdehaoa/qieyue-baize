%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(mchunt_handler).

-include("bag.hrl").
-include("creep.hrl").
-include("game.hrl").
-include("item.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/3]).
-export([hook_sysopen/1]).
-export([hook_login/1]).
-export([notify/3]).
-export([expire/2]).
-export([add_mchunt/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 寻宝信息
handle(?MCHUNT_INFO, _Tos, RoleSt) ->
	RoleMcHunt = role_data:get(?DB_ROLE_MCHUNT),
	?ucast(#m_mchunt_info_toc{
		type  = RoleMcHunt#role_mchunt.hunt,
		dig   = RoleMcHunt#role_mchunt.dig,
		times = RoleMcHunt#role_mchunt.times,
		etime = RoleMcHunt#role_mchunt.etime,
		power = role_bag:get_money(?ITEM_MC_HUNT),
		scene = RoleMcHunt#role_mchunt.scene,
		pos   = RoleMcHunt#role_mchunt.pos
	});

%% 寻宝
handle(?MCHUNT_HUNT, Tos, RoleSt) ->
	#role_st{role=RoleID, state=State} = RoleSt,
	#m_mchunt_hunt_tos{type=Type, skip=Skip} = Tos,
	IsValid = (Type == 1) orelse (Type == 2),
	?_check(IsValid, ?ERR_GAME_BAD_ARGS),
	RoleMcHunt = role_data:get(?DB_ROLE_MCHUNT),
	check_hunt(RoleMcHunt, Type, RoleSt),
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	Scenes = (cfg_scene:scenes(?SCENE_KIND_LOCAL, ?SCENE_TYPE_CITY)
		  ++ cfg_scene:scenes(?SCENE_KIND_LOCAL, ?SCENE_TYPE_FIELD))
		  -- [11001, 11003],
	Scenes2 = [ID || ID <- Scenes,
		ID =< 11008,
		begin
			#cfg_scene{reqs=Reqs} = cfg_scene:find(ID),
			RoleLv >= proplists:get_value(level, Reqs, 0)
		end
	],
	SceneID = ut_rand:choose(Scenes2),
	PosList = scene_config:hunt(SceneID),
	?_check(PosList /= [], ?ERR_MCHUNT_BAD_SCENE),

	role_event:event(?EVENT_MC_HUNT, Type),
	Cost = cfg_mchunt:cost(Type),
	Full = scene_manager:is_full(SceneID),
	case (Full orelse Skip == true andalso RoleLv >= cfg_game:mchunt_skip()) of
		true  ->
			#role_mchunt{times=Times, luck=Luck} = RoleMcHunt,
			{Times2, Luck2, Gain} = calc_reward(Type, 1, Times, Luck, SceneID),
			{ok, _, Obtain} = role_bag:deal(Cost, Gain, ?LOG_MCHUNT_HUNT, RoleSt),
			role_data:set(RoleMcHunt#role_mchunt{
				hunt  = 0,
				times = Times2,
				dig   = 0,
				etime = 0,
				scene = 0,
				pos   = [],
				luck  = Luck2
			}),
			gain_notify(Obtain, RoleSt),
			?_if(Full, ?ucast(#m_game_error_toc{errno=?ERR_MCHUNT_EXPIRED})),
			?ucast(#m_mchunt_stat_toc{reward=Obtain});
		false ->
			role_bag:cost(Cost, ?LOG_MCHUNT_HUNT, RoleSt),
			Last  = cfg_game:mchunt_last(),
			Pos   = ut_rand:choose(PosList, 4, false),
			ETime = ut_time:seconds() + cfg_game:mchunt_last(),
			role_data:set(RoleMcHunt#role_mchunt{
				hunt  = Type,
				etime = ETime,
				scene = SceneID,
				pos   = Pos
			}),
			role_timer:add_task({RoleID,?MODULE,expire}, Last, ?MODULE, expire),
			?ucast(#m_mchunt_hunt_toc{type=Type, scene=SceneID, pos=Pos, etime=ETime}),
			{ok, RoleSt#role_st{state=?_bis(State, ?ROLE_STATE_MCHUNT)}}
	end;

%% 挖宝
handle(?MCHUNT_DIG, Tos, RoleSt) ->
	#m_mchunt_dig_tos{type=Type, num=Num} = Tos,
	RoleMcHunt = role_data:get(?DB_ROLE_MCHUNT),
	check_dig(RoleMcHunt, Num, RoleSt),
	#role_mchunt{scene=SceneID, pos=Pos, etime=ETime} = RoleMcHunt,
	role_data:set(RoleMcHunt#role_mchunt{dig=Type}),
	Coord = lists:nth(Num, Pos),
	case Type of
		1 -> dig_complete(1, RoleSt);
		2 -> dig_by_creep(Type, Num, SceneID, Coord, ETime, RoleSt);
		3 -> dig_by_collect(Type, Num, SceneID, Coord, ETime, RoleSt);
		_ -> throw(?err(?ERR_GAME_BAD_ARGS))
	end;

%% 日志
handle(?MCHUNT_LOG, _Tos, RoleSt) ->
	Logs = game_logger:get_logs(?MODULE),
	?ucast(#m_mchunt_log_toc{logs=Logs}).



hook_sysopen(RoleSt) ->
	MaxPower = cfg_game:mchunt_power_max(),
	role_bag:gain([{?ITEM_MC_HUNT, MaxPower}], 0, RoleSt).

hook_login(RoleSt=#role_st{state=State}) ->
	case role_misc:is_sys_open(mchunt_handler) of
		true  -> add_offline_power(RoleSt);
		false -> ignore
	end,
	RoleMcHunt = role_data:get(?DB_ROLE_MCHUNT),
	#role_mchunt{id=RoleID, hunt=HuntType, etime=ETime} = RoleMcHunt,
	Gap = cfg_game:mchunt_power_gap(),
	role_timer:add_task(
		{RoleID,?MODULE,add_mchunt}, 0, Gap, ?MODULE, add_mchunt
	),
	NTime = ut_time:seconds(),
	case HuntType > 0 of
		true when ETime > NTime ->
			Last = ETime - NTime,
			role_timer:add_task(
				{RoleID,?MODULE,expire}, Last, ?MODULE, expire
			),
			{ok, RoleSt#role_st{state=?_bis(State, ?ROLE_STATE_MCHUNT)}};
		true  ->
			?ucast(#m_game_error_toc{errno=?ERR_MCHUNT_EXPIRED}),
			dig_complete(0, RoleSt, false);
		false ->
			ignore
	end.


notify(?EVENT_CREEP, {_CreepID, Rarity}, RoleSt) ->
	?_if(Rarity == ?CREEP_RARITY_HUNT, dig_complete(2, RoleSt));
notify(?EVENT_COLLECT, {_CollID, Rarity}, RoleSt) ->
	?_if(Rarity == ?CREEP_RARITY_HUNT, dig_complete(3, RoleSt)).

expire(_Ref, RoleSt) ->
	dig_complete(0, RoleSt),
	?ucast(#m_game_error_toc{errno=?ERR_MCHUNT_EXPIRED}).

add_mchunt(_Ref, RoleSt) ->
	AddPower = cfg_game:mchunt_power_add(),
	do_add_mchunt(AddPower, RoleSt).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_hunt(RoleMcHunt, HuntType, _RoleSt) ->
	ValidType = HuntType == 1 orelse HuntType == 2,
	?_check(ValidType, ?ERR_GAME_BAD_ARGS),
	#role_mchunt{times=Times, etime=ETime} = RoleMcHunt,
	?_check(ETime == 0, ?ERR_MCHUNT_HUNTING),
	?_check(Times < cfg_game:mchunt_maxtimes(), ?ERR_MCHUNT_MAX_TIMES),
	ok.

check_dig(RoleMcHunt, Num, RoleSt) ->
	#role_mchunt{hunt=HuntType, scene=SceneID, pos=Pos} = RoleMcHunt,
	?_check(HuntType > 0, ?ERR_MCHUNT_NOT_HUNTING),
	?_check(RoleSt#role_st.scene == SceneID, ?ERR_MCHUNT_NOT_NEARBY),
	?_check(Num > 0 andalso Num =< length(Pos), ?ERR_GAME_BAD_ARGS),
	Coord1 = lists:nth(Num, Pos),
	Coord2 = RoleSt#role_st.coord,
	IsNear = scene_util:is_nearby(Coord1, Coord2, 200),
	?_check(IsNear, ?ERR_MCHUNT_NOT_NEARBY),
	ok.

dig_by_creep(Type, Num, SceneID, Coord, ETime, RoleSt) ->
	Creeps  = cfg_creep:creeps(?CREEP_KIND_MONSTER, ?CREEP_RARITY_HUNT),
	CreepID = ut_rand:choose(Creeps),
	Opts = #{owner=>RoleSt#role_st.role, etime=>ETime},
	[CreepUID] = creep:sync_add(SceneID, 0, ?MAIN_LINE, [{CreepID, Coord, Opts}]),
	?ucast(#m_mchunt_dig_toc{type=Type, num=Num, uid=CreepUID}),
	role_event:listen(?EVENT_CREEP, ?MODULE, notify).

dig_by_collect(Type, Num, SceneID, Coord, ETime, RoleSt) ->
	Colls  = cfg_creep:creeps(?CREEP_KIND_COLLECT, ?CREEP_RARITY_HUNT),
	CollID = ut_rand:choose(Colls),
	Opts   = #{owner=>RoleSt#role_st.role, etime=>ETime},
	[CollUID] = creep:sync_add(SceneID, 0, ?MAIN_LINE, [{CollID, Coord, Opts}]),
	?ucast(#m_mchunt_dig_toc{type=Type, num=Num, uid=CollUID}),
	role_event:listen(?EVENT_COLLECT, ?MODULE, notify).

dig_complete(DigType, RoleSt) ->
	dig_complete(DigType, RoleSt, true).

dig_complete(DigType, RoleSt=#role_st{state=State}, Notify) ->
	RoleMcHunt = role_data:get(?DB_ROLE_MCHUNT),
	#role_mchunt{hunt=HuntType, times=Times, scene=SceneID, luck=Luck} = RoleMcHunt,
	case HuntType > 0 of
		true  ->
			{Times2, Luck2, Gain} = calc_reward(HuntType, DigType, Times, Luck, SceneID),
			{ok, Obtain} = role_bag:gain(Gain, ?LOG_MCHUNT_REWARD, RoleSt),
			RoleMcHunt2 = RoleMcHunt#role_mchunt{
				hunt=0, dig=0, etime=0, scene=0, pos=[], times=Times2, luck=Luck2
			},
			role_data:set(RoleMcHunt2),
			gain_notify(Obtain, RoleSt),
			?_if(Notify, ?ucast(#m_mchunt_stat_toc{reward=Obtain})),
			{ok, RoleSt#role_st{state=?_bic(State, ?ROLE_STATE_MCHUNT)}};
		false ->
			ignore
	end.

gain_notify(Obtain, RoleSt) ->
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	NTime  = ut_time:seconds(),
	maps:fold(fun
		(ItemID, Num, _) ->
			#cfg_item{type=ItemType, notify=Notify2} = cfg_item:find(ItemID),
			case ItemType /= ?ITEM_TYPE_MONEY andalso Notify2 of
				true  ->
					Log = #p_mchunt_log{
						name=RoleName, item=ItemID, num=Num, time=NTime
					},
					game_logger:add_log(?MODULE, Log),
					?notify(?MSG_ITEM_MCHUNT_GAIN, [
						{role, RoleID, RoleName},
						{item, #{ItemID=>Num}}
					]);
				false ->
					ignore
			end
	end, ok, Obtain).


calc_reward(1, DigType, Times, Luck, SceneID) ->
	#dunge_magic{clear_floor=Floor} = role_data:get(?DB_DUNGE_MAGIC),
	Opened  = game_env:get_opened_days(),
	Reward1 = calc_fixed_reward(1, Floor),
	{Luck2, Reward2} = calc_reward2(
		1, Floor, Opened, Times+1, Luck, SceneID, DigType, []
	),
	{Times+1, Luck2, Reward1++Reward2};
calc_reward(2, DigType, Times, Luck, SceneID) ->
	#dunge_magic{clear_floor=Floor} = role_data:get(?DB_DUNGE_MAGIC),
	Opened  = game_env:get_opened_days(),
	Reward1 = calc_fixed_reward(2, Floor),
	case Luck+10 >= 30 of
		true  ->
			{Luck2, Reward2} = calc_reward2(
				10, Floor, Opened, Times+1, Luck, SceneID, DigType, []
			),
			{Times+10, Luck2, Reward1++Reward2};
		false ->
			Reward2 = random_reward(Floor, Opened, Times+1, SceneID, 3, DigType),
			{Luck2, Reward3} = calc_reward2(
				9, Floor, Opened, Times+2, Luck+1, SceneID, DigType, []
			),
			{Times+10, Luck2, Reward1++Reward2++Reward3}
	end.

calc_reward2(0, _Floor, _Opened, _Times, Luck, _SceneID, _DigType, Reward) ->
	{Luck, Reward};
calc_reward2(N, Floor, Opened, Times, Luck, SceneID, DigType, Reward) ->
	case Luck+1 >= 30 of
		true  ->
			Luck1  = 0,
			PoolID = 4;
		false ->
			Luck1  = Luck + 1,
			PoolID = 1
	end,
	Reward1 = random_reward(Floor, Opened, Times, SceneID, PoolID, DigType),
	Times2  = Times + 1,
	Luck2   = case check_reset_luck(Reward1) of
		true  -> 0;
		false -> Luck1
	end,
	calc_reward2(N-1, Floor, Opened, Times2, Luck2, SceneID, DigType, Reward1++Reward).

random_reward(Floor, Opened, Times, SceneID, PoolID, DigType) ->
	WtList = calc_wt_list(Floor, Opened, Times, SceneID, PoolID, DigType),
	cfg_mchunt_reward:reward( ut_rand:weight(WtList) ).

check_reset_luck(Reward) ->
	lists:any(fun
		(ItemInfo) ->
			ItemID = element(1, ItemInfo),
			#cfg_item{color=Color} = cfg_item:find(ItemID),
			Color == ?COLOR_RED
	end, Reward).

calc_fixed_reward(HuntType, Floor) ->
	RewardList = cfg_mchunt:reward(HuntType),
	lists:filtermap(fun
		({ItemID, FloorLim, Min, Max}) ->
			case Floor >= FloorLim of
				true  ->
					{true, {ItemID, ut_rand:random(Min, Max)}};
				false ->
					false
			end
	end, RewardList).

calc_wt_list(Floor, Opened, Times, SceneID, HuntType, DigType) ->
	WtList = cfg_mchunt_reward:weight(HuntType),
	lists:filtermap(fun
		({ID, FloorLim, {OpenedMin,OpenedMax}, TimesWt, {DigTypeLim,SceneIDLim,WtAdd}}) ->
			OpenedMeet = Opened >= OpenedMin andalso Opened =< OpenedMax,
			case Floor >= FloorLim andalso OpenedMeet of
				true  ->
					Wt = calc_weight(TimesWt, Times),
					case
						DigType > 0 andalso
						DigType == DigTypeLim andalso
						SceneID == SceneIDLim
					of
						true  -> {true, {ID, Wt + WtAdd}};
						false -> {true, {ID, Wt}}
					end;
				false ->
					false
			end
	end, WtList).

calc_weight([{Min, Max, Wt} | T], Times) ->
	case Min =< Times andalso Times =< Max of
		true  -> Wt;
		false -> calc_weight(T, Times)
	end.

add_offline_power(RoleSt) ->
	RoleInfo = role_data:get(?DB_ROLE_INFO),
	#role_info{login=Login, logout=Logout} = RoleInfo,
	AddGap   = cfg_game:mchunt_power_gap(),
	AddTimes = max(0, ut_math:floor((Login - Logout) / AddGap)),
	AddPower = cfg_game:mchunt_power_add() * AddTimes,
	do_add_mchunt(AddPower, RoleSt).

do_add_mchunt(AddPower, RoleSt) ->
	CurPower = role_bag:get_money(?ITEM_MC_HUNT),
	MaxPower = cfg_game:mchunt_power_max(),
	case CurPower < MaxPower of
		true  ->
			RealAdd = min(AddPower, MaxPower-CurPower),
			role_bag:gain([{?ITEM_MC_HUNT, RealAdd}], 0, RoleSt);
		false ->
			ignore
	end.