%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(fight_collect).

-include("creep.hrl").
-include("game.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").

%% API
-export([start/2]).
-export([compl/1]).
-export([break/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 开始采集
start(CollUid, RoleSt) ->
	#role_st{role=RoleID, spid=ScenePid} = RoleSt,
    break(RoleSt),
    % ?debug("---------------start collect"),
    {ok, CollID} = scene:call(ScenePid, {coll_start, RoleID, CollUid}),
    set_collect(CollUid, CollID, ut_time:seconds()).

%% 完成采集
compl(RoleSt) ->
	case del_collect() of
        {CollUid, CollID, STime} ->
            #cfg_creep{collect=CollTime, rarity=Rarity} = cfg_creep:find(CollID),
            IsCompl = ut_time:seconds() - STime >= CollTime - 5,
            ?_check(IsCompl, ?ERR_COLLECT_NOT_COMPL),
            #role_st{role=RoleID, spid=ScenePid} = RoleSt,
            ok = scene:call(ScenePid, {coll_compl, RoleID, CollUid}),
            role_event:event(?EVENT_COLLECT, {CollID,Rarity});
        ?nil ->
            throw(?err(?ERR_COLLECT_NOT_START))
    end.

%% 中断采集
break(_RoleSt) ->
    ok.
	% case del_collect() of
	% 	{CollUid, _, _} ->
	% 	    #role_st{role=RoleID, spid=ScenePid} = RoleSt,
 %            scene:cast(ScenePid, {coll_break, RoleID, CollUid}),
 %            ?ucast(#m_fight_collect_toc{uid=CollUid, type=3});
	% 	?nil ->
	% 		ignore
	% end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
-define(k_collect, k_collect).
% get_collect() ->
% 	get(?k_collect).

set_collect(CollUid, CollID, STime) ->
    put(?k_collect, {CollUid, CollID, STime}).

del_collect() ->
    erase(?k_collect).