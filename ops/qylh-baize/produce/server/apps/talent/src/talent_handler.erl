%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(talent_handler).

-include("game.hrl").
-include("role.hrl").
-include("skill.hrl").
-include("talent.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
handle(?TALENT_INFO, _Tos, RoleSt) ->
	#role_talent{skills=Skills, remain=Remain} = role_data:get(?DB_ROLE_TALENT),
	?ucast(#m_talent_info_toc{point=Remain, skills=Skills});

handle(?TALENT_UPGRADE, Tos, RoleSt) ->
	#m_talent_upgrade_tos{id=SkillID} = Tos,
	#cfg_talent{group=Group, reqs=Reqs, point=Need} = cfg_talent:find(SkillID),
	Talent = role_data:get(?DB_ROLE_TALENT),
	#role_talent{remain=Remain, allot=Allot, skills=Skills} = Talent,
	?_check(Remain >= Need, ?ERR_TALENT_POINT_LIMIT),
	OldLv = maps:get(SkillID, Skills, 0),
	MaxLv = cfg_skill_level:max(SkillID),
	?_check(OldLv < MaxLv, ?ERR_SKILL_MAX_LEVEL),
	check_upgrade(Reqs, Talent, RoleSt),
	Remain2 = Remain - Need,
	role_data:set(Talent#role_talent{
		allot  = ut_misc:maps_increase(Group, Need, Allot),
		skills = ut_misc:maps_increase(SkillID, 1, Skills),
		remain = Remain2
	}),
	#cfg_skill{group=SkillGroup} = cfg_skill:find(SkillID),
	if
		SkillGroup == ?SKILL_GROUP_TALENT_MOUNT ->
			role_attr:recalc({mount_handler,?TRAIN_MOUNT}, RoleSt);
		SkillGroup == ?SKILL_GROUP_TALENT_OFFHAND ->
			role_attr:recalc({mount_handler,?TRAIN_OFFHAND}, RoleSt);
		SkillGroup == ?SKILL_GROUP_TALENT_WING  ->
			role_attr:recalc({morph_handler,?TRAIN_WING}, RoleSt);
		SkillGroup == ?SKILL_GROUP_TALENT_TALIS ->
			role_attr:recalc({morph_handler,?TRAIN_TALIS}, RoleSt);
		true ->
			role_attr:recalc(role_talent, RoleSt)
	end,
	#role_st{spid=ScenePid, role=RoleID} = RoleSt,
	scene:update_actor(ScenePid, RoleID, [{addskill, SkillID, OldLv+1}]),
	?ucast(#m_talent_upgrade_toc{id=SkillID, point=Remain2});

handle(?TALENT_RESET, _Tos, RoleSt) ->
	Talent = role_data:get(?DB_ROLE_TALENT),
	#role_talent{total=Total, skills=Skills} = Talent,
	role_bag:cost([{11154,1}], ?LOG_TALENT_RESET, RoleSt),
	role_data:set(Talent#role_talent{remain=Total, allot=#{}, skills=#{}}),
	role_attr:del_cache(role_talent),
	role_attr:del_cache({mount_handler,?TRAIN_MOUNT}),
	role_attr:del_cache({mount_handler,?TRAIN_OFFHAND}),
	role_attr:del_cache({morph_handler,?TRAIN_WING}),
	role_attr:del_cache({morph_handler,?TRAIN_TALIS}),
	role_attr:recalc(role_talent, RoleSt),
	#role_st{spid=ScenePid, role=RoleID} = RoleSt,
	DelSkills = [{delskill, SkillID} || SkillID <- maps:keys(Skills)],
	scene:update_actor(ScenePid, RoleID, DelSkills),
	?ucast(#m_talent_reset_toc{}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_upgrade([{role_lv, CfgLv} | T], Talent, RoleSt) ->
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	case RoleLv >= CfgLv of
		true  -> check_upgrade(T, Talent, RoleSt);
		false -> throw(?err(?ERR_TALENT_ROLE_LEVEL_LIMIT))
	end;
check_upgrade([{skill_lv, SkillID, CfgLv} | T], Talent, RoleSt) ->
	SkillLv = maps:get(SkillID, Talent#role_talent.skills, 0),
	case SkillLv >= CfgLv of
		true  -> check_upgrade(T, Talent, RoleSt);
		false -> throw(?err(?ERR_TALENT_SKILL_LEVEL_LIMIT, SkillID))
	end;
check_upgrade([{allot, Group, CfgPt} | T], Talent, RoleSt) ->
	AllotPt = maps:get(Group, Talent#role_talent.allot, 0),
	case AllotPt >= CfgPt of
		true  -> check_upgrade(T, Talent, RoleSt);
		false -> throw(?err(?ERR_TALENT_ALLOT_LIMIT, Group))
	end;
check_upgrade([], _Talent, _RoleSt) ->
	ok.
