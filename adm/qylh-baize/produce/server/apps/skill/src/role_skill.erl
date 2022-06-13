%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_skill).

-include("game.hrl").
-include("skill.hrl").
-include("table.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("role.hrl").
-include("enum.hrl").

%% API
-export([init/1]).
-export([hook_upgrade/2]).
-export([get_attr/1]).
-export([active/2]).
-export([remove/2]).
-export([replace/3]).
-export([refresh/1]).
-export([update_cds/2]).
-export([set_skills_cd/2]).
-export([hook_login/1]).


%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init(RoleID) ->
	#role_info{career=Career, level=Level} = role_data:get(?DB_ROLE_INFO),
	SkillIDs = cfg_skill_get:find(Career, Level),
	role_data:set(#role_skill{
		id     = RoleID,
		skills = maps:from_list([{SkillID,1} || SkillID <- SkillIDs]),
		puton  = maps:from_list([{SkillID,0} || SkillID <- SkillIDs]),
		auto   = SkillIDs
	}).

hook_login(RoleSt)->
	#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
	#role_skill{skills=Skills} = role_data:get(?DB_ROLE_SKILL),
	case Level >= 24 of
		true ->
			case maps:is_key(205001, Skills) of
				true  -> ignore;
				false -> active(205001, RoleSt)
			end;
		false ->
			ignore
	end.

hook_upgrade(NewLv, RoleSt) ->
	#role_info{career=Career} = role_data:get(?DB_ROLE_INFO),
	SkillIDs = cfg_skill_get:find(Career, NewLv),
	?_if(SkillIDs /= [], active(SkillIDs, RoleSt)).

get_attr(_AttrType) ->
	#role_skill{skills=Skills} = role_data:get(?DB_ROLE_SKILL),
	Attrs = maps:fold(fun
		(SkillID, SkillLv, Acc) ->
			CfgLevel = cfg_skill_level:find(SkillID, SkillLv),
			mod_attr:add(Acc, CfgLevel#cfg_skill_level.attrs)
	end, #{}, Skills),
	maps:without(mod_attr:part_pro_attrs(), Attrs).

%% 激活技能
active(SkillID, RoleSt) when is_integer(SkillID) ->
	do_activie([SkillID], RoleSt);
active(SkillIDs, RoleSt) when is_list(SkillIDs) ->
	do_activie(SkillIDs, RoleSt).

%% 移除技能
remove(SkillID, RoleSt) when is_integer(SkillID) ->
	do_remove([SkillID], RoleSt);
remove(SkillIDs, RoleSt) when is_list(SkillIDs) ->
	do_remove(SkillIDs, RoleSt).

%% 技能替换
replace(OldSkillID, NewSkillID, RoleSt)->
	RoleSkill = role_data:get(?DB_ROLE_SKILL),
	#role_skill{skills=Skills, puton=PutOn, auto=AutoList} = RoleSkill,
	OldPos  = maps:get(OldSkillID, PutOn, 0),
	SkillLv = maps:get(OldSkillID, Skills, 0),
	Skills1 = maps:remove(OldSkillID, Skills),
	Skills2 = maps:put(NewSkillID, 1, Skills1),
	PutOn1  = maps:remove(OldSkillID, PutOn),
	#cfg_skill{is_hew=IsHew} = cfg_skill:find(NewSkillID),
	NewPos  = if
		IsHew ->
			0;
		OldPos > 0 ->
			OldPos;
		true ->
			calc_skill_pos(PutOn1, NewSkillID)
	end,
	PutOn2  = maps:put(NewSkillID, NewPos, PutOn1),
	AutoList2 = lists:delete(OldSkillID, AutoList),
	AutoList3 = case NewPos > 0 of
		true  -> [NewSkillID|AutoList2];
		false -> AutoList2
	end,
	role_data:set(RoleSkill#role_skill{
		skills = Skills2,
		puton  = PutOn2,
		auto   = AutoList3
	}),
	skill_util:del_buffs(OldSkillID, SkillLv, RoleSt),
	skill_util:add_buffs(NewSkillID, SkillLv, RoleSt),
	skill_show(NewSkillID, NewPos, RoleSt).

%% 刷新cd
refresh(RoleSt)->
	RoleSkill = role_data:get(?DB_ROLE_SKILL),
	role_data:set(RoleSkill#role_skill{endcd=#{}}),
	skill_util:send_skills(RoleSt).

%更新技能
update_cds(EndCD, RoleSt)->
	?ucast(#m_skill_update_cds_toc{cds=EndCD}).

set_skills_cd(SkillIDs, RoleSt)->
    RoleSkill = role_data:get(?DB_ROLE_SKILL),
    #role_skill{skills=Skills, endcd=EndCDs} = RoleSkill,
    EndCDs2 = lists:foldl(fun
            (SkillID, Maps)->
                SkillLv = maps:get(SkillID, Skills),
                #cfg_skill_level{cd=CD} = cfg_skill_level:find(SkillID, SkillLv),
                Millis = ut_time:milliseconds(),
                NewCD  = CD + Millis,
                maps:put(SkillID, NewCD, Maps)
        end, EndCDs, SkillIDs),
    role_data:set(RoleSkill#role_skill{
        endcd = EndCDs2
    }),
    role_skill:update_cds(EndCDs2, RoleSt).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_activie(SkillIDs, RoleSt)->
	RoleSkill = role_data:get(?DB_ROLE_SKILL),
	do_active2(SkillIDs, RoleSkill, RoleSt),
	role_attr:recalc(?MODULE, RoleSt),
	#role_st{spid=ScenePid, role=RoleID} = RoleSt,
	Skills = [{addskill,SkillID,1} || SkillID <- SkillIDs],
	scene:update_actor(ScenePid, RoleID, Skills).

do_active2([SkillID | T], RoleSkill, RoleSt) ->
	#role_skill{skills=Skills, puton=PutOn, auto=AutoList} = RoleSkill,
	case maps:is_key(SkillID, Skills) of
		true  ->
			?error("skill active repeat: ~w", [SkillID]),
			do_active2(T, RoleSkill, RoleSt);
		false ->
			Skills2  = maps:put(SkillID, 1, Skills),
			SkillPos = calc_skill_pos(PutOn, SkillID),
			skill_show(SkillID, SkillPos, RoleSt),
			RoleSkill1 = RoleSkill#role_skill{skills=Skills2},
			RoleSkill2 = case SkillPos > 0 of
				true  ->
					#cfg_skill{auto=IsAuto} = cfg_skill:find(SkillID),
					AutoList2 = case IsAuto == 1 of
						true  -> [SkillID | AutoList];
						false -> AutoList
					end,
					RoleSkill1#role_skill{
						puton = maps:put(SkillID, SkillPos, PutOn),
						auto  = AutoList2
					};
				false ->
					RoleSkill1
			end,
			do_active2(T, RoleSkill2, RoleSt)
	end;
do_active2([], RoleSkill, _RoleSt) ->
	role_data:set(RoleSkill).

do_remove(SkillIDs, RoleSt) ->
	RoleSkill = role_data:get(?DB_ROLE_SKILL),
	#role_skill{skills=Skills, auto=Auto, puton=PutOn} = RoleSkill,
	Auto2 = [SkillID || SkillID <- Auto, not lists:member(SkillID, SkillIDs)],
	role_data:set(RoleSkill#role_skill{
		skills = maps:without(SkillIDs, Skills),
		puton  = maps:without(SkillIDs, PutOn),
		auto   = Auto2
	}),
	skills_remove(SkillIDs, RoleSt),
	#role_st{spid=ScenePid, role=RoleID} = RoleSt,
	DelSkills = [{delskill,SkillID} || SkillID <- SkillIDs],
	scene:update_actor(ScenePid, RoleID, DelSkills),
	role_attr:recalc(?MODULE, RoleSt).

calc_skill_pos(PutOn, SkillID) ->
	#cfg_skill{pos=Pos} = cfg_skill:find(SkillID),
	case Pos > 0 of
		true ->
			Pos;
		false ->
			case cfg_skill_show:find(SkillID) of
				#cfg_skill_show{type=1} ->
					Size = puton_size(PutOn),
					?_if(Size < 6, Size+1, 0);
				_ ->
					0
			end
	end.

puton_size(PutOn)->
	maps:fold(fun
			(_SkillID, Pos, Size) ->
				case Pos>0 andalso Pos<8 of
					true  -> Size + 1;
					false -> Size
				end
		end, 0, PutOn).

skill_show(SkillID, Pos, RoleSt) ->
	#cfg_skill{auto=IsAuto} = cfg_skill:find(SkillID),
	?ucast(#m_skill_get_skill_toc{
		skill = skill_util:p_skill(SkillID, 1, 0, Pos, ?_if(IsAuto == 1, 0, 1))
	}).

skills_remove(SkillIDs, RoleSt)->
	?ucast(#m_skill_remove_skills_toc{skill_ids=SkillIDs}).
