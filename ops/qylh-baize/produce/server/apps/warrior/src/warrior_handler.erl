%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(warrior_handler).

-include("proto.hrl").
-include("role.hrl").
-include("warrior.hrl").
-include("enum.hrl").
-include("log.hrl").
-include("ranking.hrl").
-include("bag.hrl").
-include("scene.hrl").

%% API
-export([handle/3]).
-export([change_scene/2]).
-export([floor_gain/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
handle(?WARRIOR_INFO, _Tos, RoleSt)->
	#role_st{spid=ScenePid, role=RoleID, line=Line} = RoleSt,
    scene:route(ScenePid, warrior_war, handle, {?WARRIOR_INFO, RoleID, Line});

handle(?WARRIOR_RANK, _Tos, RoleSt)->
	#role_st{role=RoleID, line=LineID, scene=SceneID} = RoleSt,
	#cfg_scene{stype=SType} = cfg_scene:find(SceneID),
	case SType == ?SCENE_STYPE_WARRIOR of
		true ->
			{RankList, {MySort, MyData}} = case is_cross(SceneID) of
				false  -> warrior_server:get_ranklist(LineID, RoleID);
				true -> warrior_server:get_ranklist_cross(LineID, RoleID)
			end,
			RankList2 = lists:sublist(RankList, 5),
			RankList3 = [p_ranking(Ranking) || Ranking <- RankList2],
			Mine = case lists:keyfind(RoleID, #rankitem.id, RankList) of
				false   ->
					#p_ranking{
						rank = 0,
						sort = MySort,
						data = MyData
					};
				Item ->
					#p_ranking{
						rank = Item#rankitem.rank,
						sort = Item#rankitem.sort,
						data = Item#rankitem.data
					}
			end,
			{ok, #m_warrior_rank_toc{list=RankList3, mine=Mine}, RoleSt};
		false ->
			ignore
	end.


%切换场景
change_scene({SceneID, Floor}, RoleSt)->
	Opts = #{act_id=>?WARRIOR_ACTID, bctype => ?BCTYPE_SCENE},
	Coord = scene_util:get_born(SceneID),
	scene_change:change(?SCENE_CHANGE_ACT, SceneID, Floor, Coord, [], Opts, RoleSt).

%发送层奖励
floor_gain({Gain, Floor}, RoleSt)->
	EmptyNum = role_bag:get_empty(?BAG_ID_MAIN),
	case EmptyNum >= length(Gain) of
		true ->
			role_bag:gain(Gain, ?LOG_WARRIOR_FLOOR_REWARD, RoleSt);
		false ->
			#role_st{role=RoleID} = RoleSt,
			mail:send(RoleID, ?MAIL_WARRIOR_FLOOR, Gain, [Floor])
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
p_ranking(RankItem) ->
	#p_ranking{
		base = role:get_base(RankItem#rankitem.id),
		rank = RankItem#rankitem.rank,
		sort = RankItem#rankitem.sort,
		data = RankItem#rankitem.data
	}.

is_cross(SceneID)->
	#cfg_scene{kind=Kind} = cfg_scene:find(SceneID),
	Kind == ?SCENE_KIND_CROSS.