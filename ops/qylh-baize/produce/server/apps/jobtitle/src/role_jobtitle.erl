%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_jobtitle).
-include("game.hrl").
-include("table.hrl").
-include("proto.hrl").
-include("role.hrl").
-include("figure.hrl").
-include("jobtitle.hrl").

%% API
-export([hook_upgrade/2]).
-export([get_attr/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

get_attr(_AttrType)->
	#role_info{figure=Figure} = role_data:get(?DB_ROLE_INFO),
	Aspect = maps:get(?FIGURE_JOBTITLE, Figure, #p_aspect{}),
	#p_aspect{model=JobTitleId} = Aspect,
	CfgJobtitle = cfg_jobtitle:find(JobTitleId),
	case CfgJobtitle == ?nil of
		true  -> [];
		false -> CfgJobtitle#cfg_jobtitle.attr
	end.


hook_upgrade(NewLv, RoleSt)->
	case NewLv == cfg_game:jobtitle_openlv() of
		true  ->
			role_figure:update_jobtitle(1, RoleSt),
			role_attr:recalc(role_jobtitle, RoleSt);
		false ->
			ignore
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
