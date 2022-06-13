%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(fight_dead).

-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([notify/3, notify/4]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 死亡弹窗通知
notify(Atker, Defer, SceneSt) ->
	#scene_st{scene=SceneID} = SceneSt,
    #cfg_revive{notify=Notify, manu=Manu} = cfg_scene:revive(SceneID),
    case Manu of
        true  ->
        	notify(?DEAD_TYPE_NORM, Atker, Defer, SceneSt);
        false ->
        	?_if(Notify, notify(?DEAD_TYPE_AUTO, Atker, Defer, SceneSt)),
        	fight_revive:auto(Defer, SceneSt)
    end.

%% 死亡弹窗通知(手动复活)
notify(?DEAD_TYPE_NORM, Atker, Defer, SceneSt) ->
	?ucast(Defer#actor.uid, #m_fight_dead_toc{
	    uid  = Defer#actor.uid,
	    type = ?DEAD_TYPE_NORM,
	    who  = get_killer_name(Atker),
	    args = #{"auto_revive"=>get_revive_time(SceneSt)}
	});
%% 死亡弹窗通知(自动复活)
notify(?DEAD_TYPE_AUTO, Atker, Defer, SceneSt) ->
	?ucast(Defer#actor.uid, #m_fight_dead_toc{
	    uid  = Defer#actor.uid,
	    type = ?DEAD_TYPE_AUTO,
	    who  = get_killer_name(Atker),
	    args = #{"auto_revive"=>get_revive_time(SceneSt)}
	});
%% 死亡弹窗通知(世界Boss)
notify(?DEAD_TYPE_TIRED, Atker, Defer, _SceneSt) ->
	Revive = cfg_game:revive_tired() + ut_time:seconds(),
	?ucast(Defer#actor.uid, #m_fight_dead_toc{
		uid  = Defer#actor.uid,
		type = ?DEAD_TYPE_TIRED,
		who  = get_killer_name(Atker),
		args = #{"auto_revive"=>ut_conv:to_list(Revive)}
	}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
get_killer_name(Atker) ->
	#actor{name=AtkName, level=AtkLv} = Atker,
	case AtkLv > 370 of
		true  ->
			lists:concat([AtkName, "(", cfg_lang:find(peak), AtkLv-370, ")"]);
		false ->
			lists:concat([AtkName, "(", AtkLv, ")"])
	end.

get_revive_time(SceneSt) ->
    CfgRevive = cfg_scene:revive(SceneSt#scene_st.scene),
    ut_conv:to_list(ut_time:seconds() + CfgRevive#cfg_revive.time).