%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(yunying_dunge_tower).

-include("btree.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").

%% API
-export([handle/2]).
-export([get_entry/1]).
-export([get_next/1]).
-export([stat/1]).
-export([send_info/1]).
-export([send_info/2]).
-export([give_reward/2]).

-define(SCENE_STYPE, ?SCENE_STYPE_DUNGE_YUNYING_TOWER).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 副本面板
handle(?DUNGE_PANEL, RoleSt) ->
	DungeID = dunge_util:get_dunge(?SCENE_STYPE),
	?ucast(#m_dunge_panel_toc{
		stype = ?SCENE_STYPE,
		id    = DungeID,
		info  = #{
			"cur_times" => role_count:get_scene_enter(?SCENE_STYPE),
			"max_times" => dunge_util:max_times(?SCENE_STYPE)
		}
	}).

get_entry(_RoleSt) ->
	DungeID = dunge_util:get_dunge(?SCENE_STYPE),
	#{dunge=>DungeID}.

get_next(RoleSt) ->
	#role_st{stype=SType, floor=FloorID} = RoleSt,
	DungeIDs = cfg_dunge:dunge(?SCENE_STYPE),
	case SType == ?SCENE_STYPE andalso FloorID =< length(DungeIDs) of
		true  ->
			FloorID2 = FloorID + 1,
			DungeID  = lists:nth(FloorID2, DungeIDs),
			#{dunge=>DungeID, floor=>FloorID2};
		false ->
			throw(?err(?ERR_GAME_BAD_ARGS, [?DUNGE_ENTER]))
	end.

stat(SceneSt) ->
	% ?debug("---------结算"),
	#scene_st{dunge=DungeID, floor=FloorID} = SceneSt,
	#dunge_st{clear=IsClear, roles=[RoleID]} = dunge_util:get_state(),
	role:route(RoleID, ?MODULE, give_reward, {IsClear, DungeID, FloorID}).

send_info(SceneSt) ->
	#dunge_st{roles=[RoleID]} = dunge_util:get_state(),
	send_info(RoleID, SceneSt),
	?SUCCESS.

send_info(RoleID, SceneSt) ->
	DungeSt = dunge_util:get_state(),
	?ucast(RoleID, #m_dunge_info_toc{
		stype = ?SCENE_STYPE,
		id    = SceneSt#scene_st.scene,
		info  = #{
			"floor"     => SceneSt#scene_st.dunge,
			"prep_time" => DungeSt#dunge_st.ptime,
			"end_time"  => SceneSt#scene_st.etime
		}
	}).

give_reward({IsClear, DungeID, FloorID}, RoleSt) ->
	Obtain2 = case IsClear of
		true  ->
			Reward = dunge_util:calc_reward(DungeID),
			LogID  = yunying_util:calc_logid(150601),
			{ok, Obtain} = role_bag:gain(Reward, LogID, RoleSt),
			Obtain;
		false ->
			#{}
	end,
	?ucast(#m_dunge_over_toc{
		stype  = ?SCENE_STYPE,
		id     = DungeID,
		clear  = IsClear,
		stat   = #{"floor"=>FloorID},
		reward = Obtain2
	}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
