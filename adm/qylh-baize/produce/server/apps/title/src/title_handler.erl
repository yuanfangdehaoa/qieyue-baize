%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(title_handler).

-include("equip.hrl").
-include("game.hrl").
-include("title.hrl").
-include("role.hrl").
-include("table.hrl").
-include("log.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("msgno.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%获取信息
handle(?TITLE_INFO, _Tos, RoleSt)->
	#role_title{titles=Titles,puton_id=PutOnId} = role_data:get(?DB_ROLE_TITLE),
	{ok, #m_title_info_toc{titles=Titles, puton_id=PutOnId}, RoleSt};

%激活称号
handle(?TITLE_ACTIVE, Tos, RoleSt)->
	#m_title_active_tos{id=Id}=Tos,
	role_bag:cost([{Id,1}], ?LOG_TITLE_ACTIVE, RoleSt),
	role_title:add_title(Id, RoleSt);


%穿戴称号
handle(?TITLE_PUTON, Tos, RoleSt)->
	#m_title_puton_tos{id=Id}=Tos,
	RoleTitle = role_data:get(?DB_ROLE_TITLE),
	#role_title{titles=Titles,puton_id=PutOnId} = RoleTitle,
	?_check(Id /= PutOnId, ?ERR_TITLE_IS_PUTON),
	case maps:get(Id, Titles, ?nil) of
		?nil->throw(?err(?ERR_TITLE_IS_NOT_EXIST));
		#p_title{etime=ETime}->
			case ETime > 0 of
				true->
					?_check(ETime > ut_time:seconds(), ?ERR_TITLE_IS_EXPIRE);
				false->
					ignor
			end
	end,
	role_data:set(RoleTitle#role_title{puton_id=Id}),
	role_figure:update_title(Id, RoleSt),
	?ucast(#m_title_info_toc{puton_id=Id}),
	{ok, #m_title_puton_toc{}, RoleSt};


%脱下称号
handle(?TITLE_PUTOFF, Tos, RoleSt)->
	#m_title_putoff_tos{id=Id}=Tos,
	RoleTitle = #role_title{puton_id=PutOnId} = role_data:get(?DB_ROLE_TITLE),
	?_check(Id==PutOnId, ?ERR_TITLE_IS_NOT_PUTON),
	role_data:set(RoleTitle#role_title{puton_id=0}),
	role_figure:update_title(0, RoleSt),
	?ucast(#m_title_info_toc{puton_id=0}),
	{ok, #m_title_putoff_toc{}, RoleSt}.


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
