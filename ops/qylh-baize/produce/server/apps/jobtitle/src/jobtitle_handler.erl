%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(jobtitle_handler).

-include("figure.hrl").
-include("game.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("table.hrl").
-include("jobtitle.hrl").
-include("role.hrl").
-include("log.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

handle(?JOBTITLE_UPLEVEL, _Tos, RoleSt)->
	#role_info{figure=Figure} = role_data:get(?DB_ROLE_INFO),
	Aspect = maps:get(?FIGURE_JOBTITLE, Figure, #p_aspect{}),
	#p_aspect{model=JobTitleId} = Aspect,
	Power = role_util:get_power(),
	CfgJobtitle = cfg_jobtitle:find(JobTitleId),
	#cfg_jobtitle{need_power=NeedPower, cost=Cost, next_id=NextId} = CfgJobtitle,
	?_check(NextId > 0, ?ERR_JOBTITLE_MAX),
	?_check(Power >= NeedPower, ?ERR_JOBTITLE_POWER_NOT_ENOUGH),
	role_bag:cost(Cost, ?LOG_JOGTITLE_UPLEVEL, RoleSt),

	role_figure:update_jobtitle(NextId, RoleSt),
	role_attr:recalc(role_jobtitle, RoleSt),
	{ok, #m_jobtitle_uplevel_toc{id=NextId}, RoleSt}.



%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
