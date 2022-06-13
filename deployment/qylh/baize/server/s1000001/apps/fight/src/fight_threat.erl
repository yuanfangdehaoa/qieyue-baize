%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(fight_threat).

-include("game.hrl").
-include("fight.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([update/3]).
-export([lose/2]).
-export([stat/2]).
-export([sort/2]).
-export([highest/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 更新仇恨
update(Atker, Defer, Damage) when ?is_creep(Defer) ->
	#damage{value=DmgVal} = Damage,
    #actor{uid=AtkID} = Atker,
    #actor{threat=Threat, exargs=ExArgs} = Defer,
	Defer1 = Defer#actor{threat=ut_misc:maps_increase(AtkID, DmgVal, Threat)},
    case ?is_boss(Defer) orelse ?is_timeboss(Defer) of
    	true  ->
    		JoinRoles  = maps:get(join_roles, ExArgs, #{}),
    		JoinRoles2 = ut_misc:maps_increase(AtkID, DmgVal, JoinRoles),
		    Defer1#actor{exargs=maps:put(join_roles, JoinRoles2, ExArgs)};
		false ->
			Defer1
    end;
update(_Atker, Defer, _Damage) ->
    Defer.

%% 失去目标
lose(Actor, EnemyID) ->
	Actor#actor{threat=maps:remove(EnemyID, Actor#actor.threat)}.

stat(role, Threat) ->
	Threat;
stat(team, Threat) ->
	maps:fold(fun
		(RoleID, DmgVal, Acc) ->
			case scene_actor:get_actor(RoleID) of
				#actor{team=TeamID} when TeamID > 0 ->
					ut_misc:maps_increase(TeamID, DmgVal, Acc);
				_ ->
					Acc
			end
	end, #{}, Threat);
stat(guild, Threat) ->
	maps:fold(fun
		(RoleID, DmgVal, Acc) ->
			case scene_actor:get_actor(RoleID) of
				#actor{guild=GuildID} when GuildID > 0 ->
					ut_misc:maps_increase(GuildID, DmgVal, Acc);
				_ ->
					Acc
			end
	end, #{}, Threat);
stat(group, Threat) ->
	maps:fold(fun
		(RoleID, DmgVal, Acc) ->
			case scene_actor:get_actor(RoleID) of
				#actor{group=GroupID} when GroupID > 0 ->
					ut_misc:maps_increase(GroupID, DmgVal, Acc);
				_ ->
					Acc
			end
	end, #{}, Threat);
stat(hybrid, Threat) ->
	maps:fold(fun
		(RoleID, DmgVal, Acc) ->
			case scene_actor:get_actor(RoleID) of
				#actor{team=TeamID} when TeamID > 0 ->
					ut_misc:maps_increase({team, TeamID}, DmgVal, Acc);
				?nil ->
					Acc;
				_ ->
					maps:put({role, RoleID}, DmgVal, Acc)
			end
	end, #{}, Threat).

sort(role, Threat) ->
	do_sort(Threat);
sort(team, Threat) ->
	do_sort(stat(team, Threat));
sort(guild, Threat) ->
	do_sort(stat(guild, Threat));
sort(group, Threat) ->
	do_sort(stat(group, Threat));
sort(hybrid, Threat) ->
	do_sort(stat(hybrid, Threat)).

highest(Type, Threat) ->
	case sort(Type, Threat) of
		[]    -> 0;
		[{H, _DmgVal}|_] -> H
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_sort(Threat) ->
	Sorted = lists:keysort(2, maps:to_list(Threat)),
    lists:reverse(Sorted).
