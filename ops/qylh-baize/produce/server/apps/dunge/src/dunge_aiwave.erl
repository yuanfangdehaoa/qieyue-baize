%%%=============================================================================
%%% @author z.hua
%%% @doc
%%% 波数副本ai
%%% @end
%%%=============================================================================

-module(dunge_aiwave).

-include("btree.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("proto.hrl").

%% API
-export([summon/1]).
-export([summon/2]).
-export([is_max/1]).
-export([is_over/1]).
-export([send_info/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
summon(SceneSt) ->
	summon(#{}, SceneSt).

summon(AIArgs, SceneSt) ->
	#scene_st{dunge=DungeID, opts=Opts} = SceneSt,
	DungeSt = dunge_util:get_state(),
	#dunge_st{
		over=IsOver, wave=OldWave, level=CreepLv, tref=OldTRef, count=Count
	} = DungeSt,
	ut_misc:cancel_timer(OldTRef),
	NewWave = OldWave + 1,
	CfgWave = cfg_dunge_wave:find(DungeID, NewWave, CreepLv),
	case IsOver orelse CfgWave == ?nil of
		true  ->
			?SUCCESS;
		false ->
			?debug("~ts:~w", ["生成怪物", {DungeID, NewWave, CreepLv}]),
			#cfg_dunge_wave{creeps=Creeps, last=Last0} = CfgWave,
			Last = maps:get(wave_last, Opts, Last0),
			DungeSt1 = DungeSt#dunge_st{
				wave  = NewWave,
				wtime = ut_time:seconds() + Last
			},
			DungeSt2 = case Last > 0 of
				true  ->
					NewTRef = erlang:send_after(timer:seconds(Last), self(), waveout),
					DungeSt1#dunge_st{tref=NewTRef};
				false ->
					DungeSt1
			end,
			dunge_util:set_state(DungeSt2),
			Creeps2 = dunge_creep:summon(Creeps, maps:merge(#{wave=>NewWave}, AIArgs), SceneSt),
			Count2 = maps:put(NewWave, length(Creeps2), Count),
			dunge_util:set_state(DungeSt2#dunge_st{count = Count2}),
			?SUCCESS
	end.

%% 当前波数是否已是最大波数
is_max(_SceneSt) ->
	#dunge_st{id=DungeID, wave=Wave} = dunge_util:get_state(),
	Wave >= cfg_dunge_wave:max(DungeID).

%% 当前波数是否结束
is_over(_SceneSt) ->
	#dunge_st{wave=Wave, count=Count} = dunge_util:get_state(),
	maps:get(Wave, Count, 0) =< 0.

send_info(SceneSt) ->
	DungeSt = #dunge_st{roles=[RoleID]} = dunge_util:get_state(),
	?ucast(RoleID, #m_dunge_info_toc{
		stype = SceneSt#scene_st.stype,
		id    = SceneSt#scene_st.scene,
		info  = #{
			"cur_wave" => DungeSt#dunge_st.wave,
			"max_wave" => cfg_dunge_wave:max(SceneSt#scene_st.dunge)
		}
	}),
	?SUCCESS.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
