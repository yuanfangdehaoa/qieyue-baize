%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(icon_handler).

-include("fashion.hrl").
-include("game.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/3]).
-export([update_icon/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
handle(?ICON_SETPIC, Tos, RoleSt) ->
	#m_icon_setpic_tos{pic=Pic, md5=MD5} = Tos,
	RoleInfo = #role_info{icon=Icon} = role_data:get(?DB_ROLE_INFO),
	Icon2 = Icon#p_icon{pic=Pic, md5=MD5},
	role_data:set(RoleInfo#role_info{icon=Icon2}),
	#role_st{spid=ScenePid, role=RoleID} = RoleSt,
	scene:update_actor(ScenePid, RoleID, [{icon,Icon2}]),
	?ucast(#m_icon_setpic_toc{pic=Pic, md5=MD5}).

%% 更新头像框/气泡
update_icon(Type, IconID, RoleSt) ->
	RoleInfo = #role_info{icon=Icon} = role_data:get(?DB_ROLE_INFO),
	Icon2 = if
		Type == ?FASHION_STATE_TYPE_FRAME ->
			Icon#p_icon{frame=IconID};
		Type == ?FASHION_STATE_TYPE_BUBBLE ->
			Icon#p_icon{bubble=IconID};
		true ->
			Icon
	end,
	role_data:set(RoleInfo#role_info{icon=Icon2}),
	?ucast(#m_icon_update_toc{
		frame  = Icon2#p_icon.frame,
		bubble = Icon2#p_icon.bubble
	}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
