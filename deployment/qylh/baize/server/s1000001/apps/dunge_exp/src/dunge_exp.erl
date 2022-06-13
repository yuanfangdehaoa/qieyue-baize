%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_exp).

-include("attr.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/2]).
-export([create_opts/2]).
-export([enter_opts/2]).
-export([send_info/2]).
-export([dunge_clear/2]).

-define(MAX_GOLD_INSPIRE, 5). % 元宝鼓舞最大次数
-define(MAX_COIN_INSPIRE, 5). % 金币鼓舞最大次数

-define(SCENE_STYPE, ?SCENE_STYPE_DUNGE_EXP).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 副本面板
handle(?DUNGE_PANEL, RoleSt) ->
	RoleDunge = role_data:get(?DB_ROLE_DUNGE),
	EnterTime = maps:get(?SCENE_STYPE, RoleDunge#role_dunge.enter, 0),
	DungeID   = dunge_util:get_dunge(?SCENE_STYPE),
	#cfg_dunge_enter{cd=CD, times=MaxTimes} = cfg_dunge:enter(?SCENE_STYPE),
	?ucast(#m_dunge_panel_toc{
		stype = ?SCENE_STYPE,
		id    = DungeID,
		info  = #{
			"enter_cd"   => ?_if(EnterTime == 0, 0, EnterTime+CD),
			"max_times"  => MaxTimes,
			"buy_times"  => role_count:get_scene_buy(?SCENE_STYPE),
			"rest_times" => dunge_util:rest_times(?SCENE_STYPE)
		}
	});
%% 获取鼓舞剩余次数、消耗、增加的buff
handle({?DUNGE_INSPIRE, get, Type}, _SceneSt) ->
	#dunge_st{opts=Opts} = dunge_util:get_state(),
	CoinInsp = maps:get(coin_inspire, Opts, 0),
	GoldInsp = maps:get(gold_inspire, Opts, 0),
	case Type of
		1 ->
			{ok, ?MAX_COIN_INSPIRE-CoinInsp, {'OR', [{?ITEM_COIN,100}], [{?ITEM_GOLD,5}]}};
		2 ->
			{ok, ?MAX_GOLD_INSPIRE-GoldInsp, [{?ITEM_BGOLD, 10}]};
		_ ->
			?err(?ERR_GAME_BAD_ARGS)
	end;
%% 鼓舞
handle({?DUNGE_INSPIRE, do, Type}, _SceneSt) ->
	DungeSt = #dunge_st{roles=[RoleID], opts=Opts} = dunge_util:get_state(),
	Opts2 = case Type of
		1 -> ut_misc:maps_increase(coin_inspire, 1, Opts);
		2 -> ut_misc:maps_increase(gold_inspire, 1, Opts)
	end,
	dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
	Actor = scene_actor:get_actor(RoleID),
	Times = maps:get(coin_inspire, Opts2, 0)
		  + maps:get(gold_inspire, Opts2, 0),
	Buffs = cfg_dunge_exp_buff:find(Times),
	buff_util:add_buffs(Actor, Buffs).

create_opts(_Entry, _RoleSt) ->
	#role_dunge{misc=Misc} = role_data:get(?DB_ROLE_DUNGE),
	ExpMisc = maps:get(?SCENE_STYPE, Misc, #{}),
	case maps:is_key(exp_gain, ExpMisc) of
		true  ->
			#{};
		false ->
			#cfg_dunge_cd{prep=Prep} = cfg_dunge:cd(?SCENE_STYPE),
			#{dunge_last=>3*60+Prep, wave_last=>1*60}
	end.

enter_opts(_Entry, _RoleSt) ->
	#role_dunge{misc=Misc} = role_data:get(?DB_ROLE_DUNGE),
	ExpMisc = maps:get(?SCENE_STYPE, Misc, #{}),
	ExpGain = maps:get(exp_gain, ExpMisc, 0),
	#{exp_gain=>ExpGain, is_first=>(not maps:is_key(exp_gain, ExpMisc))}.

send_info(RoleID, SceneSt) ->
	DungeSt  = #dunge_st{opts=Opts} = dunge_util:get_state(),
	GoldInsp = maps:get(gold_inspire, Opts, 0),
	CoinInsp = maps:get(coin_inspire, Opts, 0),
	#actor{level=RoleLv, attr=Attr, enter=EnterOpts} = scene_actor:get_actor(RoleID),
	?ucast(RoleID, #m_dunge_info_toc{
		stype = ?SCENE_STYPE_DUNGE_EXP,
		id    = SceneSt#scene_st.scene,
		info  = #{
			"cur_wave"     => DungeSt#dunge_st.wave,
			"max_wave"     => cfg_dunge_wave:max(SceneSt#scene_st.dunge),
			"prep_time"    => DungeSt#dunge_st.ptime,
			"end_time"     => SceneSt#scene_st.etime,
			"inspire"      => 10 * (GoldInsp + CoinInsp),
			"exp_elixir"   => round(?_attr(Attr,?ATTR_EXP_PER)),
			"exp_team"     => 30,
			"exp_activity" => 0,
			"world_level"  => world_level:exp_coef(RoleLv),
			"exp_gain"     => maps:get(exp_gain, Opts, 0),
			"gold_inspire" => ?MAX_GOLD_INSPIRE - GoldInsp,
			"coin_inspire" => ?MAX_COIN_INSPIRE - CoinInsp,
			"first_enter"  => ?_if(maps:get(is_first, EnterOpts), 1, 0)
		},
		count = DungeSt#dunge_st.kill
	}).

dunge_clear(ExpGain, _RoleSt) ->
	RoleDunge = #role_dunge{misc=Misc} = role_data:get(?DB_ROLE_DUNGE),
	ExpMisc   = maps:get(?SCENE_STYPE, Misc, #{}),
	ExpMisc2  = maps:put(exp_gain, ExpGain, ExpMisc),
	Misc2 = maps:put(?SCENE_STYPE, ExpMisc2, Misc),
	role_data:set(RoleDunge#role_dunge{misc=Misc2}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
