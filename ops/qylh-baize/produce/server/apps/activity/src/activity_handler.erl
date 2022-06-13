%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(activity_handler).

-include("activity.hrl").
-include("game.hrl").
-include("role.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/3]).
-export([hook_upgrade/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
handle(?ACTIVITY_LIST, _Tos, RoleSt) ->
	#role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
	ActList = get_act_list(all, RoleLv),
	?ucast(#m_activity_list_toc{activities=ActList});

handle(?ACTIVITY_ALL, _Tos, RoleSt) ->
	ActList = get_act_list(),
	?ucast(#m_activity_all_toc{activities=ActList}).

hook_upgrade(NewLv, RoleSt) ->
	ActIDs  = cfg_activity:all(NewLv),
	ActList = get_act_list(ActIDs, NewLv),
	?_if(
		ActList /= [],
		?ucast(#m_activity_list_toc{activities=ActList})
	).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
get_act_list(With, RoleLv) ->
	lists:filtermap(fun
		(Activity) ->
			#activity{id=ActID, state=State, level=JoinLv} = Activity,
			CanJoin = State /= ?ACT_ST_STOPPED andalso
				RoleLv >= JoinLv andalso
				(With == all orelse lists:member(ActID, With)),
			case CanJoin of
				true  ->
					{true, #p_activity{
						id    = ActID,
						stime = Activity#activity.stime,
						etime = Activity#activity.etime,
						state = State
					}};
				false ->
					false
			end
	end, ets:tab2list(?ETS_ACTIVITY)).

get_act_list() ->
	lists:map(fun
		(Activity) ->
			#activity{id=ActID, state=State} = Activity,
			#p_activity{
				id    = ActID,
				stime = Activity#activity.stime,
				etime = Activity#activity.etime,
				state = State
			}
	end, ets:tab2list(?ETS_ACTIVITY)).
