%% @author rong
%% @doc 
-module(wedding_util).

-include("wedding.hrl").
-include("table.hrl").
-include("proto.hrl").
-include("activity.hrl").
-include("game.hrl").
-include("errno.hrl").

-export([pid/1, guest_list/1, request_list/1, p_wedding/1]).
-export([all_appointments/0, p_appointment/1]).
-export([scene/0, times/0, pre/0, can_start/2]).

pid(RoleID) ->
    #marriage{wtime=WTime} = marriage_ets:get(RoleID),
    wedding_ets:pid(WTime).

guest_list(RoleID) ->
    #marriage{wtime=WTime} = marriage_ets:get(RoleID),
    #wedding{invite=Invite} = wedding_ets:get(WTime),
    Invite.

request_list(RoleID) ->
    #marriage{wtime=WTime} = marriage_ets:get(RoleID),
    case wedding_ets:get(WTime) of
        no_book ->
            throw(?err(?ERR_WEDDING_NO_APPOINTMENT));
        #wedding{request=Requests, add=Add, invite=Invite} ->
            Max = Add + cfg_marriage:invite(),
            Remain = max(0, Max - length(Invite)),
            {Requests, Remain}
    end.

p_wedding(Wedding) ->
    #p_wedding{
        start_time = element(1, Wedding#wedding.time),
        end_time   = element(2, Wedding#wedding.time),
        couple     = [role:get_base(ID) || ID <- Wedding#wedding.couple]
    }.

all_appointments() ->
    lists:map(fun({S, E}) ->
        STime = ut_time:time_to_seconds(S),
        ETime = ut_time:time_to_seconds(E),
        case wedding_ets:get(STime, ETime) of
            no_book ->
                #p_wedding_appointment{
                    start_time = STime,
                    end_time   = ETime,        
                    couple     = []
                };
            Wedding ->
                p_appointment(Wedding)
        end
    end, times()).

p_appointment(List) when is_list(List) ->
    [p_appointment(E) || E <- List];
p_appointment(E) ->
    #p_wedding_appointment{
        start_time = element(1, E#wedding.time),
        end_time = element(2, E#wedding.time),        
        couple = [role:get_base(I) || I <- E#wedding.couple]
    }.

scene() ->
    ID = cfg_marriage:activity(),
    #cfg_activity{scene=SceneID} = cfg_activity:find(ID),
    SceneID.

times() ->
    ID = cfg_marriage:activity(),
    #cfg_activity{time=Time} = cfg_activity:find(ID),
    Time.

pre() ->
    ID = cfg_marriage:activity(),
    #cfg_activity{pre=Pre} = cfg_activity:find(ID),
    Pre.

can_start(STime, ETime) ->
    case wedding_ets:get(STime, ETime) of
        no_book ->
            false;
        _ ->
            true
    end.
