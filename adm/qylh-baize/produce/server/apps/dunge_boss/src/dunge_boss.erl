%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_boss).

-include("dunge.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([handle/2]).
-export([stat/1]).
-export([hook_pickup/3]).

-define(SCENE_STYPE, ?SCENE_STYPE_DUNGE_ROLE_BOSS).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 副本面板
handle(?DUNGE_PANEL, RoleSt) ->
	CurTimes = role_count:get_scene_enter(?SCENE_STYPE),
	?ucast(#m_dunge_panel_toc{
		stype = ?SCENE_STYPE,
		id    = 0,
		info  = #{"cur_times"=>CurTimes}
	}).

stat(SceneSt) ->
	#scene_st{stype=SType, dunge=Dunge, floor=Floor} = SceneSt,
	#dunge_st{clear=IsClear, roles=[RoleID]} = dunge_util:get_state(),
	role_event:event(RoleID, ?EVENT_DUNGE, {SType,Dunge,Floor,[]}),
	?ucast(RoleID, #m_dunge_over_toc{
		stype = SceneSt#scene_st.stype,
		id    = SceneSt#scene_st.dunge,
		clear = IsClear
	}).

hook_pickup(Drop, Item, RoleSt) ->
	boss_server:hook_pickup(Drop, Item, RoleSt).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
