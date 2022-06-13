%% @author rong
%% @doc
-module(role_marriage).

-include("game.hrl").
-include("role.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("marriage.hrl").

-export([hook_login/1, hook_sysopen/2, notify/4]).
-export([is_married/1, replace_ring/1, get_info/1]).
-export([get_remain_wcount/1, has_appointment/1, marry_with/1, wtime/1]).
-export([rename/2, update_name/2]).

hook_login(_RoleSt) ->
    init_listener().

hook_sysopen(step, RoleSt) ->
    RoleMarriage = role_data:get(?DB_ROLE_MARRIAGE),
    Steps = [#p_marriage_step{id=ID, state=?PROGRESS_STATE_UNDONE}
        || ID <- cfg_marriage_step:list()],
    role_data:set(RoleMarriage#role_marriage{steps=Steps}),
    ?ucast(#m_marriage_step_toc{steps=Steps}),
    init_listener();

hook_sysopen(ring, RoleSt) ->
    RoleMarriage = role_data:get(?DB_ROLE_MARRIAGE),
    Ring = #p_marriage_ring{grade=0, level=0, exp=0},
    role_data:set(RoleMarriage#role_marriage{ring=Ring}),
    replace_ring(RoleSt).

init_listener() ->
    #role_marriage{steps=Steps} = role_data:get(?DB_ROLE_MARRIAGE),
    lists:foreach(fun(#p_marriage_step{id=ID, state=State}) ->
        case State of
            ?PROGRESS_STATE_UNDONE ->
                #cfg_marriage_step{target=Target} = cfg_marriage_step:find(ID),
                {Event, _Goal, _Conds, _Num} = Target,
                role_event:listen(Event, ?MODULE, notify, ID);
            _ ->
                ignore
        end
    end, Steps).

notify(Event, ID, Args, RoleSt) ->
    #role_marriage{steps=Steps0} = RoleMarriage = role_data:get(?DB_ROLE_MARRIAGE),
    #cfg_marriage_step{target=Target} = cfg_marriage_step:find(ID),
    {Event, Goal, Conds, _Amount} = Target,
    case task_counter:update(Event, Args, Goal, Conds) of
        {_Op, _Num} ->
            Steps = lists:map(fun(Step) ->
                case Step#p_marriage_step.state of
                    % 后续步骤完成，前置的任务也算完成
                    ?PROGRESS_STATE_UNDONE when ID >= Step#p_marriage_step.id ->
                        role_event:remove(Event, ?MODULE, notify, Step#p_marriage_step.id),
                        Step#p_marriage_step{state=?PROGRESS_STATE_FINISH};
                    _ ->
                        Step
                end
            end, Steps0),
            role_data:set(RoleMarriage#role_marriage{steps=Steps}),
            ?ucast(#m_marriage_step_toc{steps=Steps});
        false ->
            ignore
    end.

is_married(RoleID) ->
    Marriage = marriage_ets:get(RoleID),
    Marriage#marriage.marry_with > 0.

replace_ring(RoleSt) ->
    case role_data:get(?DB_ROLE_MARRIAGE) of
        #role_marriage{ring=Ring} when is_record(Ring, p_marriage_ring) ->
            #role_st{role=RoleID} = RoleSt,
            #p_marriage_ring{grade=Grade, level=Level} = Ring,
            #cfg_marriage_ring{ring=RingID}
                = cfg_marriage_ring:find(Grade, Level),
            Opts = case marriage_ets:get(RoleID) of
                #marriage{marry_with=MarryWith} when MarryWith > 0 ->
                    #role_info{name=Name, gender=Gender} = role_data:get(?DB_ROLE_INFO),
                    {ok, Cache} = role:get_cache(MarryWith),
                    case Gender of
                        ?GENDER_MALE ->
                            #{
                                husband_id => RoleID, husband => Name,
                                wife_id => MarryWith, wife => Cache#role_cache.name
                            };
                        ?GENDER_FEMALE ->
                            #{
                                husband_id => MarryWith, husband => Cache#role_cache.name,
                                wife_id => RoleID,  wife => Name
                            }
                    end;
                _ ->
                    #{}
            end,
            role_equip:puton_ring(RingID, Opts, RoleSt);
        _ ->
            ignore
    end.

get_info(RoleID) ->
    #marriage{marry_with=MarryWith, types=Types} = marriage_ets:get(RoleID),
    case MarryWith > 0 of
        true ->
            Name = role_manager:get_name(MarryWith),
            {MarryWith, Name, lists:max(maps:keys(Types))};
        false ->
            {MarryWith, "", 0}
    end.

get_remain_wcount(RoleID) ->
    #marriage{types=Types, wcount=WCount} = marriage_ets:get(RoleID),
    CanWCount = lists:sum(maps:values(Types)),
    max(0, CanWCount - WCount).

has_appointment(RoleID) ->
    #marriage{wtime=WTime} = marriage_ets:get(RoleID),
    WTime =/= ?nil.

marry_with(RoleID) ->
    #marriage{marry_with=MarryWith} = marriage_ets:get(RoleID),
    MarryWith.

wtime(RoleID) ->
    #marriage{wtime=WTime} = marriage_ets:get(RoleID),
    WTime.

rename(RoleID, Name) ->
    #marriage{marry_with=MarryWith, types=Types} = marriage_ets:get(RoleID),
    case is_integer(MarryWith) andalso MarryWith > 0 andalso role:is_alive(MarryWith) of
        true ->
            MaxType = lists:max(maps:keys(Types)),
            role:route(MarryWith, ?MODULE, update_name, {RoleID, Name, MaxType});
        false ->
            ignore
    end.

update_name({MarryWith, Name, MaxType}, RoleSt) ->
    #role_st{spid=ScenePid, role=RoleID} = RoleSt,
    ?ucast(#m_role_update_toc{
        upint=#{"marry"=>MarryWith, "mtype"=>MaxType},
        upstr=#{"mname"=>Name}
    }),
    Update = [{marriage, 0, Name, MaxType}],
    scene:update_actor(ScenePid, RoleID, Update).
