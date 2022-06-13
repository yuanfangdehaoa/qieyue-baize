%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_exp_dungeai).

-include("btree.hrl").
-include("dunge.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([update/1]).
-export([stat/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 更新副本信息
update(_SceneSt) ->
	DungeSt = #dunge_st{opts=Opts} = dunge_util:get_state(),
	{hook_drop, [_Defer, Drops]} = dunge_util:get_event(),
	#drop{num=ExpAdd} = lists:keyfind(?ITEM_EXP, #drop.id, Drops),
	Opts2 = ut_misc:maps_increase(exp_gain, ExpAdd, Opts),
	dunge_util:set_state(DungeSt#dunge_st{opts=Opts2}),
	?SUCCESS.

stat(SceneSt) ->
	DungeSt = dunge_util:get_state(),
	#dunge_st{opts=Opts, roles=[RoleID], level=OldLv} = DungeSt,
	CurGain = maps:get(exp_gain, Opts, 0),
	role:route(RoleID, dunge_exp, dunge_clear, CurGain),
	#scene_st{stype=SType, dunge=Dunge, floor=Floor} = SceneSt,
	role_event:event(RoleID, ?EVENT_DUNGE, {SType,Dunge,Floor,[{exp,CurGain}]}),
	case scene_actor:get_actor(RoleID) of
		?nil  ->
			ignore;
		Actor ->
			#actor{enter=EnterOpts, level=NewLv} = Actor,
			LastGain = maps:get(exp_gain, EnterOpts),
			Rise = case LastGain == 0 of
				true  -> 0;
				false -> max(0, round((CurGain-LastGain)/LastGain*10000))
			end,
			?ucast(RoleID, #m_dunge_over_toc{
				stype = ?SCENE_STYPE_DUNGE_EXP,
				id    = SceneSt#scene_st.scene,
				clear = DungeSt#dunge_st.clear,
				stat  = #{
					"exp"   => CurGain, % 获得经验
					"dur"   => ut_time:seconds() - SceneSt#scene_st.stime, % 副本时长
					"star"  => 3,     % 评星
					"rise"  => Rise,  % 经验提升
					"oldlv" => OldLv, % 旧等级
					"newlv" => NewLv  % 新等级
				},
				count = DungeSt#dunge_st.kill
			})
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
