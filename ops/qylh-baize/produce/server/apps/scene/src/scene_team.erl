%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(scene_team).

%% API
-export([init/0]).
-export([add_memb/2]).
-export([del_memb/2]).
-export([get_membs/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init() ->
	set_team(#{}).

add_memb(TeamID, MembID) ->
	Team   = get_team(),
	Membs2 = lists:usort([MembID | maps:get(TeamID, Team, [])]),
	Team2  = maps:put(TeamID, Membs2, Team),
	set_team(Team2).

del_memb(TeamID, MembID) ->
	Team  = get_team(),
	Team2 = ut_misc:maps_delete(TeamID, MembID, Team),
	set_team(Team2).

get_membs(TeamID) ->
	Team = get_team(),
	maps:get(TeamID, Team, []).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
-define(k_team, '@team').
get_team() ->
	get(?k_team).

set_team(Team) ->
	put(?k_team, Team).