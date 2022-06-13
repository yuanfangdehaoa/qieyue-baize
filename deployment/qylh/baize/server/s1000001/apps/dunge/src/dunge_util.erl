%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_util).

-include("dunge.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").

%% API
-export([get_state/0]).
-export([set_state/1]).

-export([get_event/0]).
-export([set_event/2]).

-export([get_events/0]).
-export([set_events/1]).
-export([clr_events/0]).
-export([add_event/2]).

-export([get_entry/2]).
-export([get_next/1]).
-export([get_dunge/1]).
-export([get_cd/2]).

-export([get_star/2, get_star/3]).
-export([max_times/1]).
-export([rest_times/1]).
-export([merge_times/1]).

-export([max_boss_times/1]).
-export([normal_star/1]).
-export([calc_reward/1]).
-export([calc_merge/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
-define(k_dunge_state, dunge_state).
get_state() ->
	get(?k_dunge_state).

set_state(DungeSt) ->
	put(?k_dunge_state, DungeSt).

-define(k_dunge_event, dunge_event).
get_event() ->
	get(?k_dunge_event).

set_event(Event, Args) ->
	put(?k_dunge_event, {Event, Args}).


-define(k_dunge_events, dunge_events).
get_events() ->
	get(?k_dunge_events).

set_events(Events) ->
	put(?k_dunge_events, Events).

clr_events() ->
	erase(?k_dunge_events).

add_event(Event, Args) ->
	Events = case get_events() of
		?nil -> [];
		List -> List
	end,
	set_events([{Event,Args} | Events]).


get_entry(Opts, RoleSt) ->
	case maps:find(dunge, Opts) of
		{ok, DungeID} when is_integer(DungeID) ->
			#cfg_dunge{stype=SType} = cfg_dunge:find(DungeID);
		_ ->
			case maps:find(stype, Opts) of
				{ok, SType} when is_integer(SType) ->
					DungeID = get_dunge(SType);
				_ ->
					SType = DungeID = ?nil,
					throw(?err(?ERR_GAME_BAD_ARGS))
			end
	end,
	case maps:find(floor, Opts) of
		{ok, FloorID} when is_integer(FloorID) ->
			ok;
		_ ->
			FloorID = 1
	end,
	Entry = scene_hook:get_entry(SType, RoleSt),
	NewDunge = maps:get(dunge, Entry, DungeID),
	NewFloor = maps:get(floor, Entry, FloorID),
	NewRoom  = maps:get(room, Entry, RoleSt#role_st.role*10000+NewFloor),
	#cfg_dunge{scene=SceneID} = cfg_dunge:find(NewDunge),
	NewCoord = maps:get(coord, Entry, scene_util:get_born(SceneID)),
	#entry{
		scene = SceneID,
		stype = SType,
		dunge = NewDunge,
		floor = NewFloor,
		room  = NewRoom,
		coord = NewCoord
	}.

get_next(RoleSt) ->
	scene_hook:get_next(RoleSt).

get_dunge(SType) ->
	hd(cfg_dunge:dunge(SType)).

get_cd(_, CDType) ->
	#scene_st{stype=SType} = scene_util:get_state(),
	CfgCD = cfg_dunge:cd(SType),
	case CDType of
		prep -> CfgCD#cfg_dunge_cd.prep + 1;
		stat -> CfgCD#cfg_dunge_cd.stat;
		exit -> CfgCD#cfg_dunge_cd.exit + 30
	end.

%% 获取副本星数
get_star(SType, DungeID) ->
	RoleDunge = role_data:get(?DB_ROLE_DUNGE),
	get_star(SType, DungeID, RoleDunge).

get_star(SType, DungeID, RoleDunge) ->
	#role_dunge{star=AllStar} = RoleDunge,
	StarInfo = maps:get(SType, AllStar, #{}),
	normal_star( maps:get(DungeID, StarInfo, 0) ).

max_times(SType) ->
	#cfg_dunge_enter{times=MaxTimes} = cfg_dunge:enter(SType),
	VipTimes    = vip_times(SType),
	BuyTimes    = role_count:get_scene_buy(SType),
	AddTimes    = role_count:get_scene_itemadd(SType),
	AskBuyTimes = role_count:get_scene_ask_buy(SType),
	MaxTimes + VipTimes + BuyTimes + AddTimes + AskBuyTimes.

rest_times(#actor{enter=EnterOpts}) ->
	maps:get(rest_times, EnterOpts);
rest_times(SType) when is_integer(SType) ->
	MaxTimes   = max_times(SType),
	CurTimes   = role_count:get_scene_enter(SType),
	SweepTimes = role_count:get_scene_sweep(SType),
	max(0, MaxTimes-CurTimes-SweepTimes).

merge_times(#actor{enter=EnterOpts}) ->
	maps:get(merge_times, EnterOpts, 1).

max_boss_times(SType) when SType == ?SCENE_STYPE_BOSS_WILD;
                           SType == ?SCENE_STYPE_BOSS_PET;
                           SType == ?SCENE_STYPE_BOSS_FISSURE ->
	RightsKey = case SType of
	    ?SCENE_STYPE_BOSS_WILD -> ?VIP_RIGHTS_WILD_BOSS;
	    ?SCENE_STYPE_BOSS_PET  -> ?VIP_RIGHTS_PET_BOSS;
	    ?SCENE_STYPE_BOSS_FISSURE -> ?VIP_RIGHTS_SPATIOTEMPORAL_BOSS
	end,
	VipLv = role_vip:get_level(),
	MaxTimes = cfg_vip_rights:find(RightsKey, VipLv, 0),
	AddTimes = role_count:get_scene_itemadd(SType),
	MaxTimes + AddTimes;
max_boss_times(_) ->
	0.

normal_star(BitStar) ->
	(BitStar band 2#00000100 bsr 2) +
	(BitStar band 2#00000010 bsr 1) +
	(BitStar band 2#00000001).

calc_reward(DungeID) ->
	CfgReward = cfg_dunge:reward(DungeID),
	#cfg_dunge_reward{fixed=Fixed, random=Random} = CfgReward,
	case Random == [] of
		true  ->
			Fixed;
		false ->
			[{MinNum, MaxNum, WtList}] = Random,
			Num = ut_rand:random(MinNum, MaxNum),
			Fixed ++ ut_rand:weight(WtList, Num, true)
	end.

calc_merge(_SceneID, MergeTimes) when MergeTimes =< 1 ->
	{ok, 1, []};
calc_merge(SceneID, MergeTimes) ->
	#cfg_scene{stype=SType} = cfg_scene:find(SceneID),

	CanMerge = [
	    ?SCENE_STYPE_DUNGE_EXP,
	    ?SCENE_STYPE_DUNGE_EQUIP,
	    ?SCENE_STYPE_DUNGE_PET,
	    ?SCENE_STYPE_DUNGE_ARENA
	],
	?_check(lists:member(SType, CanMerge), ?ERR_DUNGE_CAN_NOT_MERGE),

	RestTimes = dunge_util:rest_times(SType),

	?_check(MergeTimes =< RestTimes, ?ERR_DUNGE_NOT_ENOUGH_TIMES),

	MergePrice = cfg_game:dunge_merge_cost(),
	MergeCost  = [{ID, N*(MergeTimes-1)} || {ID,N} <- MergePrice],

    {ok, MergeTimes, MergeCost}.


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
vip_times(?SCENE_STYPE_DUNGE_ROLE_BOSS) ->
    VipLv = role_vip:get_level(),
    cfg_vip_rights:find(?VIP_RIGHTS_ROLE_BOSS, VipLv, 0);
vip_times(_) ->
	0.
