%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(skill_handler).

-include("game.hrl").
-include("role.hrl").
-include("table.hrl").
-include("proto.hrl").
-include("errno.hrl").
-include("skill.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 技能列表
handle(?SKILL_LIST, _Tos, RoleSt) ->
	skill_util:send_skills(RoleSt);

%% 获取自动释放配置
handle(?SKILL_AUTO_USE, _Tos, RoleSt)->
	#role_skill{puton=PutOn, auto=AutoList} = role_data:get(?DB_ROLE_SKILL),
	SkillsAuto = maps:map(fun
		(SkillID, _Pos) ->
			?_if(lists:member(SkillID, AutoList), 0, 1)
	end, PutOn),
	?ucast(#m_skill_auto_use_toc{auto_use=SkillsAuto});

%% 设置自动释放
handle(?SKILL_SET_AUTO_USE, Tos, RoleSt)->
	#m_skill_set_auto_use_tos{id=SkillID, auto_use=AutoUse} = Tos,
	RoleSkill = #role_skill{auto=AutoList} = role_data:get(?DB_ROLE_SKILL),
	AutoList2 = case AutoUse of
		0 -> [SkillID | lists:delete(SkillID, lists:usort(AutoList))];
		1 -> lists:delete(SkillID, AutoList)
	end,
	role_data:set(RoleSkill#role_skill{auto=AutoList2}),
	?ucast(#m_skill_set_auto_use_toc{id=SkillID, auto_use=AutoUse});

%% 技能装配
handle(?SKILL_PUTON, Tos, RoleSt)->
	#m_skill_puton_tos{id=SkillID1, pos=Pos2} = Tos,
	CfgShow = cfg_skill_show:find(SkillID1),
	?_check(CfgShow /= ?nil, ?ERR_GAME_BAD_ARGS),
	?_check(CfgShow#cfg_skill_show.type == 1, ?ERR_GAME_BAD_ARGS),
	RoleSkill = role_data:get(?DB_ROLE_SKILL),
	#role_skill{skills=Skills, puton=PutOn, auto=AutoList} = RoleSkill,
	?_check(maps:is_key(SkillID1, Skills), ?ERR_GAME_BAD_ARGS),
	Pos0 = maps:get(SkillID1, PutOn, 0),
	case Pos0 == Pos2 of
		true  ->
			ignore;
		false ->
			Pos1 = Pos0,
			PutOn1 = maps:put(SkillID1, Pos2, PutOn),
			PutOn2 = case lists:keyfind(Pos2, 2, maps:to_list(PutOn)) of
				false -> PutOn1;
				{SkillID2, _} -> maps:put(SkillID2, Pos1, PutOn1)
			end,
			role_data:set(RoleSkill#role_skill{
				puton = PutOn2,
				auto  = [SkillID1 | lists:delete(SkillID1, lists:usort(AutoList))]
			}),
			skill_util:send_skills(RoleSt)
	end;

%% 设置推荐技能
handle(?SKILL_SET_RECOMMEND, Tos, RoleSt)->
	#m_skill_set_recommend_tos{id=Id} = Tos,
	Recommend2 = cfg_skill_recommend:find(Id),
	#role_info{gender=Gender} = role_data:get(?DB_ROLE_INFO),
	Recommend = lists:nth(Gender, Recommend2),
	RoleSkill = #role_skill{puton=PutOn} = role_data:get(?DB_ROLE_SKILL),
	PutOn1 = maps:filter(fun(_, Pos) -> Pos == 0 end, PutOn),
	PutOn2 = do_recommend(Recommend, 1, PutOn1),
	AutoList = [SkillID || {SkillID,0} <- Recommend],
	role_data:set(RoleSkill#role_skill{puton=PutOn2, auto=AutoList}),
	skill_util:send_skills(RoleSt).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_recommend([{SkillID, _} | T], Pos, PutOn) ->
	PutOn2 = maps:put(SkillID, Pos, PutOn),
	do_recommend(T, Pos, PutOn2);
do_recommend([], _Pos, PutOn) ->
	PutOn.
