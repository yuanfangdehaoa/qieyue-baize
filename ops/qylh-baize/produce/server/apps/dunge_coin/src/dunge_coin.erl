%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_coin).

-include("dunge.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/2]).
-export([enter_opts/2]).
-export([send_info/2]).
-export([update_star/2]).

-define(SCENE_STYPE, ?SCENE_STYPE_DUNGE_COIN).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 副本面板
handle(?DUNGE_PANEL, RoleSt) ->
	#role_dunge{star=AllStar} = role_data:get(?DB_ROLE_DUNGE),
	#cfg_dunge_enter{times=MaxTimes} = cfg_dunge:enter(?SCENE_STYPE),
	?ucast(#m_dunge_panel_toc{
		stype = ?SCENE_STYPE,
		id    = dunge_util:get_dunge(?SCENE_STYPE),
		info  = #{
			"max_times"  => MaxTimes,
			"buy_times"  => role_count:get_scene_buy(?SCENE_STYPE),
			"rest_times" => dunge_util:rest_times(?SCENE_STYPE)
		},
		level = maps:get(?SCENE_STYPE, AllStar, #{})
	});
%% 副本扫荡
handle({?DUNGE_SWEEP, FloorID, _Args}, RoleSt) ->
	#cfg_dunge_sweep{cost=Cost} = cfg_dunge:sweep(?SCENE_STYPE),
	Gain = cfg_dunge_coin:sweep(FloorID),
    {ok, _, Obtain} = role_bag:deal(Cost, Gain, ?LOG_DUNGE_SWEEP, RoleSt),
	?ucast(#m_dunge_sweep_toc{
		stype  = ?SCENE_STYPE,
		id     = dunge_util:get_dunge(?SCENE_STYPE),
		floor  = FloorID,
		reward = Obtain
	}).

enter_opts(Entry, _RoleSt) ->
	CreepLv = cfg_dunge_coin:level(Entry#entry.floor),
	#{level=>CreepLv}.

send_info(RoleID, SceneSt) ->
	DungeSt = dunge_util:get_state(),
	?ucast(RoleID, #m_dunge_info_toc{
		stype = ?SCENE_STYPE,
		id    = SceneSt#scene_st.scene,
		info  = #{
			"cur_wave"  => DungeSt#dunge_st.wave,
			"max_wave"  => cfg_dunge_wave:max(SceneSt#scene_st.dunge),
			"prep_time" => DungeSt#dunge_st.ptime,
			"end_time"  => SceneSt#scene_st.etime,
			"star"      => DungeSt#dunge_st.star,
			"coin_gain" => maps:get(coin_gain, DungeSt#dunge_st.opts, 0)
		},
		count = maps:without([1100004], DungeSt#dunge_st.kill)
	}).

update_star([FloorID, NewStar], _RoleSt) ->
	RoleDunge = #role_dunge{star=AllStar} = role_data:get(?DB_ROLE_DUNGE),
	StarInfo  = maps:get(?SCENE_STYPE, AllStar, #{}),
	case NewStar > maps:get(FloorID, StarInfo, 0) of
		true  ->
			StarInfo2 = maps:put(FloorID, NewStar, StarInfo),
			AllStar2  = maps:put(?SCENE_STYPE, StarInfo2, AllStar),
			role_data:set(RoleDunge#role_dunge{star=AllStar2});
		false ->
			ignore
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
