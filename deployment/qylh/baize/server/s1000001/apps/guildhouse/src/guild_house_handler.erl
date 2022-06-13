%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(guild_house_handler).

-include("game.hrl").
-include("guild.hrl").
-include("guild_house.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("table.hrl").
-include("scene.hrl").
-include("item.hrl").
-include("creep.hrl").
-include("msgno.hrl").

%% API
-export([handle/3]).
-export([reward/2]).
-export([add_exp/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%获取题目
handle(?GUILD_HOUSE_QUESTION, _Tos, RoleSt)->
	#role_st{scene=SceneId, guild=Guild, role=RoleID} = RoleSt,
	check_guild(Guild),
	check_scene(SceneId),
	?_check(activity:is_start(?ACTIVITYID), ?ERR_GUILDHOUSE_ACTIVITY_NOT_START),
	{Index, Id, Expire} = guild_question_server:get_question(),
	%?_check(Expire >= ut_time:seconds(), ?ERR_GUILDHOUSE_QUESTION_EXPIRE),
	{_CanAnswer, Score} = guild_question_server:can_answer(RoleID),
	{ok, #m_guild_house_question_toc{id=Id, num=Index, end_time=Expire, score=Score}, RoleSt};

%答题
handle(?GUILD_HOUSE_ANSWER, Tos, RoleSt)->
	#role_st{scene=SceneId, guild=Guild, name=Name, role=RoleID} = RoleSt,
	#m_guild_house_answer_tos{answer=Answer} = Tos,
	check_guild(Guild),
	check_scene(SceneId),
	?_check(activity:is_start(?ACTIVITYID), ?ERR_GUILDHOUSE_ACTIVITY_NOT_START),
	{Index, Id, Expire} = guild_question_server:get_question(),
	?_check(Expire >= ut_time:seconds(), ?ERR_GUILDHOUSE_QUESTION_EXPIRE),
	NeedAnswer = cfg_guild_question:answer(Id),
	{CanAnswer, Score} = guild_question_server:can_answer(RoleID),
	{Right, Score2} = case CanAnswer of
		true  -> 
			case NeedAnswer == Answer of 
				true ->
					NewScore = guild_question_server:add_score(RoleID, Name, Index),
					rank:update_rank(?RANKID, NewScore, RoleSt),
					role_event:event(?EVENT_QUESTION),
					{true, NewScore};
				false ->
					{false, Score}
			end;
		false -> 
			{false, Score}
	end,
	case guild_question_server:is_got_exp(RoleID, Index) of
		true  -> 
			ignore;
		false -> 
			guild_question_server:got_exp(RoleID, Index),
			case Right of
				true ->
					Gain = cfg_game:qes_right_reward(),
					role_bag:gain(Gain, ?LOG_GUILD_HOUSE_RIGHT, RoleSt);
				false ->
					Gain = cfg_game:qes_wrong_reward(),
					role_bag:gain(Gain, ?LOG_GUILD_HOUSE_WRONG, RoleSt)
			end
	end,
	{ok, #m_guild_house_answer_toc{is_right=Right, score=Score2,answer=Answer}, RoleSt};


handle(?GUILD_HOUSE_SCORE, _Tos, RoleSt)->
	#role_st{role=RoleID} = RoleSt,
	{_CanAnswer, Score} = guild_question_server:can_answer(RoleID),
	{ok, #m_guild_house_score_toc{score=Score}, RoleSt};

handle(?GUILD_HOUSE_BOSS_TIME, _Tos, RoleSt)->
	#role_st{spid=ScenePid, role=RoleID} = RoleSt,
	scene:route(ScenePid, guild_house, boss_time, RoleID);

%召唤boss
handle(?GUILD_HOUSE_CALLBOSS, Tos, RoleSt)->
	#m_guild_house_callboss_tos{id=ItemId} = Tos,
	#role_st{scene=SceneId, spid=ScenePid, guild=Guild} = RoleSt,
	check_guild(Guild),
	check_scene(SceneId),
	?_check(activity:is_start(?ACTIVITYID), ?ERR_GUILDHOUSE_ACTIVITY_NOT_START),
	%Todo,是否可以召唤boss
	%检查是否有boss
	ActIds = scene:get_actids(ScenePid, ?ACTOR_TYPE_CREEP),
	?_check(length(ActIds) == 0, ?ERR_GUILDHOUSE_ONLY_CALL_ONE_BOSS),
	WorldLv = world_level:get_level(),
	Creeps = cfg_guild_house_boss:creep(ItemId, WorldLv),
	#cfg_item{stype=SType} = cfg_item:find(ItemId),
	?_check(SType == ?ITEM_STYPE_GUILDBOSS, ?ERR_GUILDHOUSE_CALLBOSS_WRONG),
	role_bag:cost([{ItemId, 1}], ?LOG_GUILD_HOUSE_CALL_BOSS, RoleSt),
	%召唤boss
	Creep = ut_rand:weight(Creeps, 2),
	creep:add([Creep], RoleSt),
	notify_callboss(Creep, RoleSt),
	{ok, #m_guild_house_callboss_toc{}, RoleSt}.


%发奖
reward({Rank, Score, Gain}, RoleSt)->
	OkFun = fun()-> 
		?ucast(#m_guild_question_result_toc{
			 rank    = Rank
		   , score   = Score
		   , rewards = #{}
		})
	end,
	role_bag:gain(Gain, ?LOG_GUILD_HOUSE_QUESTION, OkFun, RoleSt),
	{ok, RoleSt}.

%经验奖励
add_exp(Gain, RoleSt)->
	role_bag:gain(Gain, ?LOG_GUILD_HOUSE_LOOP_EXP, RoleSt),
	{ok, RoleSt}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%检查帮会
check_guild(Guild)->
	?_check(Guild>0, ?ERR_GUILD_NOT_JOIN).

%检查场景
check_scene(SceneId)->
	#cfg_scene{stype=Stype} = cfg_scene:find(SceneId),
	?_check(Stype == ?SCENE_STYPE_GUILDHOUSE, ?ERR_GUILDHOUSE_NOTIN_HOUSE).

%召唤boss公告
notify_callboss(Creep, RoleSt)->
	case Creep of
		{CreepID, _ ,_ ,_ ,_ ,_ ,_} -> 
			#cfg_creep{name=Name} = cfg_creep:find(CreepID),
			#role_st{role=RoleID, name=RoleName, spid=ScenePid} = RoleSt,
			RoleIds = scene:get_roles(ScenePid),
			?notify(RoleIds, ?MSG_GUILDHOUSE_BOSS_CALL, [
				{role, RoleID, RoleName},
				Name]);
		_->
			ignore
	end.

