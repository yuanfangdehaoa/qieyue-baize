%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(compete_util).

-include("activity.hrl").
-include("compete.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").

%% API
-export([get_period/1]).
-export([get_act_enroll/0]).
-export([get_act_select/0]).
-export([get_act_rank/0]).
-export([get_server_by_act/1]).
-export([get_server_by_scene/1]).
-export([in_prepare_scene/1]).
-export([in_battle_scene/1]).
-export([send_prepare_info/1, send_prepare_info/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
get_period(ActID) ->
	#cfg_activity{reqs=Reqs} = cfg_activity:find(ActID),
	proplists:get_value(period, Reqs).

get_act_enroll() ->
	activity:activity( get_actid(?COMPETE_PERIOD_ENROLL) ).

get_act_select() ->
	activity:activity( get_actid(?COMPETE_PERIOD_SELECT) ).

get_act_rank() ->
	activity:activity( get_actid(?COMPETE_PERIOD_RANK) ).

get_server_by_act(ActID) ->
	#cfg_activity{type=ActType} = cfg_activity:find(ActID),
	case ActType == ?ACTIVITY_TYPE_CROSS andalso cluster:is_local() of
		true  -> get_cross_server();
		false -> get_local_server()
	end.

get_server_by_scene(SceneID) ->
	case (not scene_util:is_local(SceneID)) andalso cluster:is_local() of
		true  -> get_cross_server();
		false -> get_local_server()
	end.

in_prepare_scene(SceneID) ->
	#cfg_scene{stype=SceneSType} = cfg_scene:find(SceneID),
	SceneSType == ?SCENE_STYPE_COMPETE_PREPARE.

in_battle_scene(SceneID) ->
	#cfg_scene{stype=SceneSType} = cfg_scene:find(SceneID),
	SceneSType == ?SCENE_STYPE_COMPETE_BATTLE.

send_prepare_info(State) ->
	lists:foreach(fun
		(RoleID) ->
			case ets:lookup(?ETS_COMPETE_ROLE, RoleID) of
				[Role] ->
					send_prepare_info(Role, State);
				[] ->
					ignore
			end
	end, State#compete_st.join).

send_prepare_info(Role, State) ->
	?ucast(Role#compete_role.id, #m_compete_prepare_toc{
		exp    = Role#compete_role.exp,
		rank   = Role#compete_role.rank,
		period = State#compete_st.period,
		round  = State#compete_st.round,
		phase  = State#compete_st.phase,
		next   = State#compete_st.etime,
		miss   = Role#compete_role.miss,
		reward = Role#compete_role.reward
	}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
get_local_server() ->
	compete_server.

get_cross_server() ->
	Cross = cluster:get_cross(?CROSS_RULE_24_8),
	{compete_server, Cross}.

get_actid(Period) ->
	lists:nth(Period, activity:get_acts(?ACTIVITY_GROUP_COMPETE)).
