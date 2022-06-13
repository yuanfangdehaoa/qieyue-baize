%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_talent).

-include("game.hrl").
-include("role.hrl").
-include("skill.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([hook_upgrade/2]).
-export([add_talent/2]).
-export([get_attr/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
hook_upgrade(NewLv, RoleSt) ->
	Add = cfg_role_level:talent(NewLv),
	?_if(Add > 0, add_talent(Add, RoleSt)).

add_talent(Add, RoleSt) ->
	Talent  = role_data:get(?DB_ROLE_TALENT),
	Total2  = Talent#role_talent.total + Add,
	Remain2 = Talent#role_talent.remain + Add,
	role_data:set(Talent#role_talent{total=Total2, remain=Remain2}),
	?ucast(#m_talent_point_toc{point=Remain2}).

get_attr(_AttrType) ->
	#role_talent{skills=Skills} = role_data:get(?DB_ROLE_TALENT),
	maps:fold(fun
		(SkillID, SkillLv, Acc) ->
			CfgLevel = cfg_skill_level:find(SkillID, SkillLv),
			#cfg_skill_level{attrs=Attrs} = CfgLevel,
			mod_attr:add(Acc, Attrs)
	end, #{}, Skills).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
