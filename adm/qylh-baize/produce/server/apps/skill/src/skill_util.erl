%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(skill_util).

-include("attr.hrl").
-include("game.hrl").
-include("role.hrl").
-include("skill.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([add_buffs/3]).
-export([del_buffs/3]).
-export([send_skills/1]).
-export([p_skill/5]).
-export([calc_cd/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
add_buffs(SkillID, SkillLv, RoleSt) ->
	#cfg_skill_level{buffs=BuffIDs} = cfg_skill_level:find(SkillID, SkillLv),
	?_if(BuffIDs /= [], buff:add(BuffIDs, RoleSt)).

del_buffs(SkillID, SkillLv, RoleSt) ->
	#cfg_skill_level{buffs=BuffIDs} = cfg_skill_level:find(SkillID, SkillLv),
	?_if(BuffIDs /= [], buff:del(BuffIDs, RoleSt)).

send_skills(RoleSt) ->
	RoleSkill = role_data:get(?DB_ROLE_SKILL),
	#role_skill{
		skills=Skills, puton=PutOn, auto=AutoList, endcd=EndCDs
	} = RoleSkill,
	SkillList = maps:fold(fun
		(SkillID, Level, Acc) ->
			#cfg_skill{group=Group} = cfg_skill:find(SkillID),
			if
				Group == ?SKILL_GROUP_NORMAL;
				Group == ?SKILL_GROUP_PET;
				Group == ?SKILL_GROUP_WAKE;
				Group == ?SKILL_GROUP_ANGER;
				Group == ?SKILL_GROUP_MECHA ->
					Pos   = maps:get(SkillID, PutOn, 0),
					EndCD = maps:get(SkillID, EndCDs, 0),
					Auto  = ?_if(lists:member(SkillID, AutoList), 0, 1),
					Skill = p_skill(SkillID, Level, EndCD, Pos, Auto),
					[Skill | Acc];
				true ->
					Acc
			end
	end, [], Skills),
	SkillList1 = lists:reverse(SkillList),
	SkillList2 = lists:keysort(#p_skill.pos, SkillList1),
	?ucast(#m_skill_list_toc{skills=SkillList2}).

p_skill(SkillID, Level, EndCD, Pos, AutoUse)->
	#p_skill{
		id       = SkillID,
		lv       = Level,
		cd       = EndCD,
		pos      = Pos,
		auto_use = AutoUse
	}.

calc_cd(SkillID, CD, Attr) ->
	Triggered = if
		SkillID == 101010 -> 831016;
		SkillID == 201010 -> 832016;
		true -> 0
	end,
	#role_talent{skills=Skills} = role_data:get(?DB_ROLE_TALENT),
	CD2 = case Triggered > 0 andalso maps:find(Triggered, Skills) of
		{ok, TriggerLv}  ->
			#cfg_skill_level{cd=RedCD} = cfg_skill_level:find(Triggered, TriggerLv),
			CD - RedCD;
		_ ->
			CD
	end,
	max(0, ut_math:ceil(CD2 * (1 - ?_attrper(Attr, ?ATTR_SKILLCD_RED, 0)))).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
