%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(guild_skill_handler).

-include("game.hrl").
-include("role.hrl").
-include("skill.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 技能列表
handle(?GUILD_SKILL_SKILLS, _Tos, RoleSt) ->
	#role_skill{skills=Skills} = role_data:get(?DB_ROLE_SKILL),
	GuildSkills = cfg_skill:skills(?SKILL_GROUP_GUILD),
	Skills2 = maps:filter(fun
		(SkillID, _SkillLv) ->
			lists:member(SkillID, GuildSkills)
	end, Skills),
	?ucast(#m_guild_skill_skills_toc{skills=Skills2});

%% 技能升级
handle(?GUILD_SKILL_UPGRADE, Tos, RoleSt) ->
	#m_guild_skill_upgrade_tos{id=SkillID} = Tos,
	GuildSkills  = cfg_skill:skills(?SKILL_GROUP_GUILD),
	IsGuildSkill = lists:member(SkillID, GuildSkills),
	?_check(IsGuildSkill, ?ERR_GUILD_NOT_GUILD_SKILL),
	RoleSkill = #role_skill{skills=Skills} = role_data:get(?DB_ROLE_SKILL),
	OldLv = maps:get(SkillID, Skills, 0),
	NewLv = OldLv + 1,
	CfgNew = cfg_skill_level:find(SkillID, NewLv),
	?_check(CfgNew /= ?nil, ?ERR_GUILD_SKILL_MAX_LEVEL),
	CfgOld = cfg_skill_level:find(SkillID, OldLv),
	#cfg_skill_level{reqs=Reqs, learn=Cost} = CfgOld,
	?_check(check_reqs(Reqs), ?ERR_GUILD_SKILL_CANNOT_LEARN),
	role_bag:cost(Cost, ?LOG_GUILD_SKILL, RoleSt),
	role_data:set(RoleSkill#role_skill{
		skills = maps:put(SkillID, NewLv, Skills)
	}),
	role_attr:recalc(role_skill, RoleSt),
	#cfg_skill{name=SkillName} = cfg_skill:find(SkillID),
	#role_st{role=RoleID, name=RoleName} = RoleSt,
	?_if(NewLv rem 10 == 0, ?notify(?MSG_GUILD_UPSKILL, [
		{role, RoleID, RoleName},
		SkillName,
		NewLv
	])),
	?ucast(#m_guild_skill_upgrade_toc{id=SkillID, level=NewLv}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_reqs([{lv, LvLim} | T]) ->
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	case RoleLv >= LvLim of
		true  -> check_reqs(T);
		false -> false
	end;
check_reqs([]) ->
	true.
