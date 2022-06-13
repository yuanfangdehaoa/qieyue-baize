%% @author rong
%% @doc
-module(afk_handler).

-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("afk.hrl").

-export([handle/3]).

handle(?AFK_INFO, _Tos, RoleSt) ->
    #role_afk{time=Time} = role_data:get(?DB_ROLE_AFK),
    ?ucast(#m_afk_info_toc{time = Time}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------


