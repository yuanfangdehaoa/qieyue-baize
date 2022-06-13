%% @author rong
%% @doc
-module(melee_handler).

-include("proto.hrl").
-include("role.hrl").

-export([handle/3]).

handle(?MELEE_INFO, _Tos, RoleSt) ->
    #role_st{spid=ScenePid, role=RoleID} = RoleSt,
    scene:route(ScenePid, melee_war, handle, {?MELEE_INFO, RoleID});

handle(?MELEE_DAMAGE_RANK, _Tos, RoleSt) ->
    #role_st{spid=ScenePid, role=RoleID} = RoleSt,
    scene:route(ScenePid, melee_war, handle, {?MELEE_DAMAGE_RANK, RoleID});

handle(?MELEE_SCORE_RANK, _Tos, RoleSt) ->
    #role_st{spid=ScenePid, role=RoleID} = RoleSt,
    scene:route(ScenePid, melee_war, handle, {?MELEE_SCORE_RANK, RoleID}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
