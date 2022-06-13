%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_magic).

-include("bag.hrl").
-include("dunge.hrl").
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
-export([handle/2]).
-export([pre_enter/3]).
-export([get_entry/1]).
-export([send_info/2]).
-export([dunge_over/2]).
-export([hook_reset/3]).
-export([get_clr_floor/0]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 副本面板
handle(?DUNGE_PANEL, RoleSt) ->
	DungeMagic = role_data:get(?DB_DUNGE_MAGIC),
	#dunge_magic{
		clear_floor=ClrFloor, loto_times=Times, daily_gift=IsFetch
	} = DungeMagic,
	MaxFloor = cfg_dunge_magic:max_floor(),
	case ClrFloor == MaxFloor of
		true  ->
			DungeID = 0;
		false ->
			CfgMagic = cfg_dunge_magic:find(ClrFloor+1),
			#cfg_dunge_magic{dunge=DungeID} = CfgMagic
	end,
	?ucast(#m_dunge_panel_toc{
		stype = ?SCENE_STYPE_DUNGE_MAGICTOWER,
		id    = DungeID,
		clear = ClrFloor == MaxFloor,
		info  = #{
			"cur_floor"  => ClrFloor + 1,
			"loto_times" => Times,
			"daily_gift" => ?_if(IsFetch, 1, 0)
		}
	});
%% 领取每日奖励
handle({?DUNGE_FETCH, 1}, RoleSt) ->
	DungeMagic = role_data:get(?DB_DUNGE_MAGIC),
	#dunge_magic{clear_floor=ClrFloor, daily_gift=IsFetch} = DungeMagic,
	?_check(not IsFetch, ?ERR_DUNGE_HAD_FETCH),
	#cfg_dunge_magic{gift=Gain} = cfg_dunge_magic:find(ClrFloor),
	{ok, Obtain} = role_bag:gain(Gain, ?LOG_DUNGE_MAGIC_DAILY, RoleSt),
	role_data:set(DungeMagic#dunge_magic{daily_gift=true}),
	?ucast(#m_dunge_fetch_toc{
		stype  = ?SCENE_STYPE_DUNGE_MAGICTOWER,
		type   = 1,
		reward = Obtain
	});
%% 抽奖信息
handle(?DUNGE_LOTOINFO, RoleSt) ->
	DungeMagic = role_data:get(?DB_DUNGE_MAGIC),
	?ucast(#m_dunge_lotoinfo_toc{
		stype      = ?SCENE_STYPE_DUNGE_MAGICTOWER,
		loto_times = DungeMagic#dunge_magic.loto_times,
		pool       = DungeMagic#dunge_magic.loto_round,
		hits       = DungeMagic#dunge_magic.loto_hits
	});
%% 抽奖
handle(?DUNGE_LOTO, RoleSt) ->
	DungeMagic = role_data:get(?DB_DUNGE_MAGIC),
	#dunge_magic{
		loto_times=Times, loto_round=Round, loto_hits=Hits
	} = DungeMagic,
	?_check(Times > 0, ?ERR_DUNGE_NO_LOTO_TIMES),
	Reward  = cfg_dunge_magic_loto:find(Round),
	Reward2 = lists:filter(fun
		({SeqID, _, _, _}) ->
			not lists:member(SeqID, Hits)
	end, Reward),
	{SeqID, ItemID, Num} = ut_rand:weight(Reward2),
	role_bag:gain([{ItemID, Num}], ?LOG_DUNGE_MAGIC_LOTO, RoleSt),
	Hits2  = [SeqID | Hits],
	HitNum = length(Hits2),
	role_data:set(DungeMagic#dunge_magic{
		loto_times = Times - 1,
		loto_round = ?_if(HitNum == 8, Round + 1, Round),
		loto_hits  = ?_if(HitNum == 8, [], Hits2)
	}),
	#cfg_item{name=ItemName, color=Color} = cfg_item:find(ItemID),
	case Color >= ?COLOR_ORANGE of
		true  ->
			#role_st{role=RoleID, name=RoleName} = RoleSt,
			?notify(?MSG_DUNGE_LOTO_REWARD, [
				{role, RoleID, RoleName},
				{color, ItemName, Color}
			]);
		false ->
			ok
	end,
	?ucast(#m_dunge_loto_toc{
		stype = ?SCENE_STYPE_DUNGE_MAGICTOWER,
		hit   = SeqID
	}).


pre_enter(_SceneID, _Args, RoleSt) ->
	#dunge_magic{clear_floor=Floor} = role_data:get(?DB_DUNGE_MAGIC),
	?_check(Floor < cfg_dunge_magic:max_floor(), ?ERR_DUNGE_MAX_FLOOR),
	#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
	#cfg_dunge_magic{dunge=DungeID} = cfg_dunge_magic:find(Floor+1),
	#cfg_dunge{level=NeedLv} = cfg_dunge:find(DungeID),
	?_check(Level >= NeedLv, ?ERR_DUNGE_MAGIC_LEVEL_LIMIT),
	role_skill:refresh(RoleSt).

get_entry(_RoleSt) ->
	#dunge_magic{clear_floor=Floor} = role_data:get(?DB_DUNGE_MAGIC),
	#cfg_dunge_magic{dunge=DungeID} = cfg_dunge_magic:find(Floor+1),
	#{dunge=>DungeID, floor=>Floor+1}.

send_info(RoleID, SceneSt) ->
	DungeSt = dunge_util:get_state(),
	?ucast(RoleID, #m_dunge_info_toc{
		stype = ?SCENE_STYPE_DUNGE_MAGICTOWER,
		id    = SceneSt#scene_st.scene,
		info  = #{
			"prep_time" => DungeSt#dunge_st.ptime,
			"end_time"  => SceneSt#scene_st.etime
		}
	}).


dunge_over({IsClear, DungeID, FloorID}, RoleSt) ->
	Obtain2 = case IsClear of
		true  ->
			Reward = dunge_util:calc_reward(DungeID),
			{ok, Obtain} = role_bag:gain(Reward, ?LOG_DUNGE_MAGIC_CLEAR, RoleSt),
			DungeMagic = role_data:get(?DB_DUNGE_MAGIC),
			#dunge_magic{loto_times=OldTimes} = DungeMagic,
			#cfg_dunge_magic{loto=AddTimes} = cfg_dunge_magic:find(FloorID),
			role_data:set(DungeMagic#dunge_magic{
				clear_floor = FloorID,
				loto_times  = OldTimes + AddTimes
			}),
			#role_st{role=RoleID, name=RoleName} = RoleSt,
			?_if(FloorID rem 5 == 0,
				?notify(?MSG_DUNGE_CLEAR_FLOOR, [{role,RoleID,RoleName}, FloorID])
			),
			maps:fold(fun
				(ItemID, _, _) ->
					#cfg_item{stype=SType, name=ItemName, color=Color} = cfg_item:find(ItemID),
					case SType == ?ITEM_STYPE_MAGICCARD andalso Color >= ?COLOR_ORANGE of
						true  ->
							?notify(?MSG_DUNGE_CLEAR_REWARD, [
								{role, RoleID, RoleName},
								FloorID,
								{color, ItemName, Color}
							]);
						false ->
							ignore
					end
			end, ok, Obtain),
			Obtain;
		false ->
			#{}
	end,
	?ucast(#m_dunge_over_toc{
		stype  = ?SCENE_STYPE_DUNGE_MAGICTOWER,
		id     = DungeID,
		clear  = IsClear,
		stat   = #{"floor"=>FloorID},
		reward = Obtain2
	}).


hook_reset(_NowDoW, _NowHour, _RoleSt) ->
	DungeMagic = role_data:get(?DB_DUNGE_MAGIC),
    role_data:set(DungeMagic#dunge_magic{daily_gift=false}).

get_clr_floor() ->
	DungeMagic = role_data:get(?DB_DUNGE_MAGIC),
	DungeMagic#dunge_magic.clear_floor.
%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
