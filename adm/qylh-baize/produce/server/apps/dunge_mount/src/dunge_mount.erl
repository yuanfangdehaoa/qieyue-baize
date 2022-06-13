%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_mount).

-include("bag.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/2]).
-export([enter_opts/2]).
-export([hook_reset/3]).
-export([send_info/2]).
-export([stat/2]).

-define(SCENE_STYPE, ?SCENE_STYPE_DUNGE_MOUNT).


%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
handle(?DUNGE_MOUNT_PANEL, RoleSt) ->
	#role_dunge{star=AllStar, misc=AllMisc} = role_data:get(?DB_ROLE_DUNGE),
	EnterInfo = lists:foldl(fun
		(DungeID, Acc) ->
			Times = role_count:get_scene_enter(DungeID),
			maps:put(DungeID, Times, Acc)
	end, #{}, cfg_dunge:dunge(?SCENE_STYPE)),
	StarInfo  = maps:get(?SCENE_STYPE, AllStar, #{}),
	StarInfo2 = lists:foldl(fun
		(DungeID, Acc) ->
			Star = maps:get(DungeID, StarInfo, 0),
			maps:put(DungeID, dunge_util:normal_star(Star), Acc)
	end, #{}, cfg_dunge:dunge(?SCENE_STYPE)),
	Misc = maps:get(?SCENE_STYPE, AllMisc, #{}),
	?ucast(#m_dunge_mount_panel_toc{
		enter = EnterInfo,
		star  = StarInfo2,
		fetch = maps:get(fetch, Misc, [])
	});

handle({?DUNGE_FETCH, Star}, RoleSt) ->
	RoleDunge = role_data:get(?DB_ROLE_DUNGE),
	#role_dunge{star=AllStar, misc=AllMisc} = RoleDunge,
	StarInfo  = maps:get(?SCENE_STYPE, AllStar, #{}),
	TotalStar = maps:fold(fun
		(_DungeID, OneStar, Acc) ->
			Acc + dunge_util:normal_star(OneStar)
	end, 0, StarInfo),
	?_check(TotalStar >= Star, ?ERR_DUNGE_STAR_NOT_REACH),
	Misc = maps:get(?SCENE_STYPE, AllMisc, #{}),
	FetchList = maps:get(fetch, Misc, []),
	IsFetched = lists:member(Star, FetchList),
	?_check(not IsFetched, ?ERR_DUNGE_HAD_FETCH),
	Gain = cfg_dunge_mount_star_reward:find(Star),
	?_check(Gain /= ?nil, ?ERR_DUNGE_NO_REWARD),
	{ok, Obtain} = role_bag:gain(Gain, ?LOG_DUNGE_MOUNT_STAR, RoleSt),
	Misc2    = maps:put(fetch, [Star | FetchList], Misc),
	AllMisc2 = maps:put(?SCENE_STYPE, Misc2, AllMisc),
	role_data:set(RoleDunge#role_dunge{misc=AllMisc2}),
	?ucast(#m_dunge_fetch_toc{
		stype  = ?SCENE_STYPE,
		type   = Star,
		reward = Obtain
	});

handle({?DUNGE_SWEEP, _FloorID, _Args}, RoleSt) ->
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	RoleDunge = #role_dunge{star=AllStar} = role_data:get(?DB_ROLE_DUNGE),
	StarInfo  = maps:get(?SCENE_STYPE, AllStar, #{}),
	#cfg_dunge_sweep{cost=Cost} = cfg_dunge:sweep(?SCENE_STYPE),
	{Gain, Times} = lists:foldl(fun
		(DungeID, Acc={AccReward, AccTimes}) ->
			Star = maps:get(DungeID, StarInfo, 0),
			case Star < ?STAR3 of
				true  ->
					AccReward2 = calc_reward(RoleLv, DungeID, Star, ?STAR3) ++ AccReward,
					AccTimes2  = AccTimes + 1,
					{AccReward2, AccTimes2};
				false ->
					Acc
			end
	end, {[], 0}, cfg_dunge:dunge(?SCENE_STYPE)),
	{ok, _, Obtain} = role_bag:deal(Cost, Gain, ?LOG_DUNGE_MOUNT_SWEEP, RoleSt),
	StarInfo2 = lists:foldl(fun
		(DungeID, Acc) ->
			Star = maps:get(DungeID, StarInfo, 0),
			Star < ?STAR3 andalso log_api:log_dunge(DungeID,
				?SCENE_STYPE, ?DUNGE_OP_STAR, dunge_util:normal_star(?STAR3), RoleSt),
			role_event:event(?EVENT_DUNGE_STAR, {?SCENE_STYPE, DungeID, 1, 3}),
			maps:put(DungeID, ?STAR3, Acc)
	end, #{}, cfg_dunge:dunge(?SCENE_STYPE)),
	AllStar2  = maps:put(?SCENE_STYPE, StarInfo2, AllStar),
	role_data:set(RoleDunge#role_dunge{star=AllStar2}),
	?ucast(#m_dunge_sweep_toc{
		stype  = ?SCENE_STYPE,
		id     = hd(cfg_dunge:dunge(?SCENE_STYPE)),
		reward = Obtain
	}),
	{times, Times}.

enter_opts(Entry, _RoleSt) ->
	#role_dunge{misc=AllMisc} = role_data:get(?DB_ROLE_DUNGE),
	Misc = maps:get(?SCENE_STYPE, AllMisc, #{}),
	case maps:find(level, Misc) of
		{ok, Level} ->
			#{level=>Level, dunge=>Entry#entry.dunge};
		error ->
			#cfg_scene{reqs=Reqs} = cfg_scene:find(Entry#entry.scene),
			Level = proplists:get_value(level, Reqs),
			#{level=>Level, dunge=>Entry#entry.dunge}
	end.

hook_reset(_DoW, _Hour, _RoleSt) ->
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	RoleDunge = role_data:get(?DB_ROLE_DUNGE),
	#role_dunge{star=AllStar, misc=AllMisc} = RoleDunge,
	Misc  = maps:get(?SCENE_STYPE, AllMisc, #{}),
	Misc1 = maps:remove(fetch, Misc),
	Misc2 = maps:put(level, RoleLv, Misc1),
	AllMisc2 = maps:put(?SCENE_STYPE, Misc2, AllMisc),
	AllStar2 = maps:remove(?SCENE_STYPE, AllStar),
	role_data:set(RoleDunge#role_dunge{star=AllStar2, misc=AllMisc2}).

send_info(RoleID, SceneSt) ->
	#dunge_st{wave=CurWave, kill=Kill} = dunge_util:get_state(),
	?ucast(RoleID, #m_dunge_info_toc{
		stype = SceneSt#scene_st.stype,
		id    = SceneSt#scene_st.dunge,
		info  = #{
			"cur_wave" => CurWave
		},
		count = Kill
	}).

stat(DungeSt, RoleSt) ->
	#dunge_st{id=DungeID, star=NewStar} = DungeSt,
	RoleDunge = #role_dunge{star=AllStar} = role_data:get(?DB_ROLE_DUNGE),
	StarInfo  = maps:get(?SCENE_STYPE, AllStar, #{}),
	OldStar   = maps:get(DungeID, StarInfo, 0),
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	Gain = calc_reward(RoleLv, DungeID, OldStar, NewStar),
	{ok, Obtain} = role_bag:gain(Gain, ?LOG_DUNGE_MOUNT_CLEAR, RoleSt),

	StarInfo2 = maps:put(DungeID, max(OldStar, NewStar), StarInfo),
	AllStar2  = maps:put(?SCENE_STYPE, StarInfo2, AllStar),
	role_data:set(RoleDunge#role_dunge{star=AllStar2}),
	log_api:log_dunge(DungeID, ?SCENE_STYPE, ?DUNGE_OP_STAR, dunge_util:normal_star(NewStar), RoleSt),
	?ucast(#m_dunge_over_toc{
		stype  = ?SCENE_STYPE,
		id     = DungeID,
		clear  = true,
		reward = Obtain,
		stat   = #{"star"=>NewStar}
	}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
calc_reward(RoleLv, DungeID, OldStar, NewStar) ->
	OldStar2 = dunge_util:normal_star(OldStar),
	NewStar2 = dunge_util:normal_star(NewStar),
	DropList = lists:foldl(fun
		(Star, Acc) ->
			cfg_dunge_mount_clear_reward:find(DungeID, Star, RoleLv) ++ Acc
	end, [], lists:seq(OldStar2+1, NewStar2)),
	creep_drop:calc(RoleLv, DropList).
