%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_god).

-include("game.hrl").
-include("dunge.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/2]).
-export([hook_reset/3]).
-export([pre_enter/3]).
-export([enter_opts/2]).
-export([send_info/2]).
-export([give_reward/2]).
-export([dunge_stat/2]).
-export([calc_clear_reward/4]).

-define(SCENE_STYPE, ?SCENE_STYPE_DUNGE_GOD).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 副本面板
handle(?DUNGE_PANEL, RoleSt) ->
	DungeGod = role_data:get(?DB_DUNGE_GOD),
	?ucast(#m_dunge_panel_toc{
		stype = ?SCENE_STYPE,
		id    = dunge_util:get_dunge(?SCENE_STYPE),
		info  = #{
			"cur_wave"    => DungeGod#dunge_god.cur_wave + 1,
			"max_wave"    => DungeGod#dunge_god.max_wave,
			"sweep_times" => role_count:get_scene_sweep(?SCENE_STYPE),
			"rest_times"  => 0
		},
		level = maps:from_list([{W,1} || W <- DungeGod#dunge_god.rewarded])
	});
%% 副本扫荡
handle({?DUNGE_SWEEP, _FloorID, _Args}, RoleSt) ->
	DungeGod  = role_data:get(?DB_DUNGE_GOD),
	#dunge_god{max_wave=MaxWave, cur_wave=CurWave} = DungeGod,
	SweepWave = calc_sweep_wave(MaxWave, CurWave),
	DungeID   = dunge_util:get_dunge(?SCENE_STYPE_DUNGE_GOD),
	?_check(SweepWave > 0, ?ERR_DUNGE_GOD_CANNOT_SWEEP),
	#cfg_dunge_sweep{cost=Cost} = cfg_dunge:sweep(?SCENE_STYPE),
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	Gain = calc_clear_reward(RoleLv, DungeID, 1, SweepWave),
	?debug("DUNGE_SWEEP--------------:~w", [{SweepWave, Gain}]),
    {ok, _, Obtain} = role_bag:deal(Cost, Gain, ?LOG_DUNGE_SWEEP, RoleSt),
    role_data:set(DungeGod#dunge_god{cur_wave=SweepWave}),
	?ucast(#m_dunge_sweep_toc{
		stype  = ?SCENE_STYPE_DUNGE_GOD,
		id     = DungeID,
		floor  = 0,
		reward = Obtain
	});
%% 领取奖励
handle({?DUNGE_FETCH, Wave}, RoleSt) ->
	DungeGod = role_data:get(?DB_DUNGE_GOD),
	#dunge_god{max_wave=MaxWave, rewarded=Rewarded} = DungeGod,
	?_check(Wave =< MaxWave, ?ERR_DUNGE_GOD_NOT_CLEAR),
	HadFetch = lists:member(Wave, Rewarded),
	?_check(not HadFetch, ?ERR_DUNGE_HAD_FETCH),
	DungeID  = dunge_util:get_dunge(?SCENE_STYPE),
	#cfg_dunge_wave{first=Gain} = cfg_dunge_wave:find(DungeID, Wave, 1),
	{ok, Obtain} = role_bag:gain(Gain, ?LOG_DUNGE_GOD_FIRST, RoleSt),
	role_data:set(DungeGod#dunge_god{rewarded = [Wave | Rewarded]}),
	?ucast(#m_dunge_fetch_toc{stype=?SCENE_STYPE, type=Wave, reward=Obtain}).

hook_reset(_DoW, _Hour, _RoleSt) ->
	DungeGod = role_data:get(?DB_DUNGE_GOD),
	role_data:set(DungeGod#dunge_god{cur_wave=0, barriers=?nil}).

pre_enter(_SceneID, _Args, _RoleSt) ->
	#dunge_god{cur_wave=CurWave} = role_data:get(?DB_DUNGE_GOD),
	DungeID = dunge_util:get_dunge(?SCENE_STYPE),
	MaxWave = cfg_dunge_wave:max(DungeID),
	?_check(CurWave < MaxWave, ?ERR_DUNGE_GOD_MAX_WAVE).

enter_opts(_Entry, _RoleSt) ->
	#dunge_god{cur_wave=CurWave, barriers=Barriers} = role_data:get(?DB_DUNGE_GOD),
	?debug("enter_opts-------------:~w", [CurWave]),
	#{wave=>CurWave+1, barriers=>Barriers, group=>1}.

send_info(RoleID, SceneSt) ->
	#dunge_st{wave=Wave, opts=Opts} = dunge_util:get_state(),
	Barriers = maps:get(barriers, Opts, []),
	% ?debug("send_info--------------:~w", [{Wave, maps:get(Wave, Count, 0), maps:get(escape, Opts, 0)}]),
	SWave = maps:get(wave, Opts, 1),
	case Wave < SWave of
		true  ->
			?ucast(RoleID, #m_dunge_info_toc{
				stype = SceneSt#scene_st.stype,
				id    = SceneSt#scene_st.scene,
				info  = #{
					"start_wave" => SWave,
					"cur_wave"   => SWave,
					"alive"      => 0,
					"escape"     => 0,
					"barrier"    => length(Barriers)
				}
			});
		false ->
			Creeps = scene_actor:get_actids(?ACTOR_TYPE_CREEP) -- Barriers,
			?ucast(RoleID, #m_dunge_info_toc{
				stype = ?SCENE_STYPE_DUNGE_GOD,
				id    = SceneSt#scene_st.scene,
				info  = #{
					"start_wave" => SWave,
					"cur_wave"   => Wave,
					"alive"      => length(Creeps),
					"escape"     => maps:get(escape, Opts, 0),
					"barrier"    => length(Barriers)
				},
				drops = maps:get(drops, Opts, #{})
			})
	end.

give_reward([Gain], RoleSt) ->
	role_bag:gain(Gain, ?LOG_DUNGE_GOD_CLEAR, RoleSt).

dunge_stat([IsClear,EndWave,Barriers], _RoleSt) ->
	DungeGod = role_data:get(?DB_DUNGE_GOD),
	#dunge_god{cur_wave=CurWave, max_wave=MaxWave} = DungeGod,
	case role_count:get_scene_enter(?SCENE_STYPE) > 0 of
		true  ->
			CurWave2  = ?_if(IsClear, EndWave, CurWave),
			Barriers2 = Barriers;
		false ->
			CurWave2  = 0,
			Barriers2 = ?nil
	end,
	role_data:set(DungeGod#dunge_god{
		cur_wave = CurWave2,
		max_wave = max(EndWave, MaxWave),
		barriers = Barriers2
	}),
	IsClear andalso role_event:event(?EVENT_DUNGE, {?SCENE_STYPE,0,0,[{wave,CurWave2}]}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
calc_sweep_wave(MaxWave, MinWave) when MinWave >= MaxWave ->
	0;
calc_sweep_wave(MaxWave, MinWave) ->
	case cfg_dunge_god:checkpoint(MaxWave) of
		true  -> MaxWave;
		false -> calc_sweep_wave(MaxWave-1, MinWave)
	end.

calc_clear_reward(RoleLv, DungeID, SWave, EWave) ->
	lists:foldl(fun
		(Wave, Acc) ->
			#cfg_dunge_wave{reward=DropList} = cfg_dunge_wave:find(DungeID, Wave, 1),
			creep_drop:calc(RoleLv, DropList) ++ Acc
	end, [], lists:seq(SWave, EWave)).