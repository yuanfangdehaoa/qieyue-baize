%% @author rong
%% @doc
-module(wedding_handler).

-include("activity.hrl").
-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("log.hrl").

-export([handle/3, fetch_succ/2]).

handle(?WEDDING_INFO, _Tos, RoleSt) ->
    WTime = role_marriage:wtime(RoleSt#role_st.role),
    case wedding_ets:get(WTime) of
        no_book ->
            ?ucast(#m_wedding_info_toc{has_request = false});
        Wedding ->
            ?ucast(#m_wedding_info_toc{
                appointment = wedding_util:p_appointment(Wedding),
                has_request = Wedding#wedding.request =/= []
            })
    end;

handle(?WEDDING_APPOINTMENT_INFO, _Tos, RoleSt) ->
    ?ucast(#m_wedding_appointment_info_toc{
        appointments=wedding_util:all_appointments(),
        remain_times=role_marriage:get_remain_wcount(RoleSt#role_st.role)
    });

handle(?WEDDING_APPOINTMENT_BOOK, Tos, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    #m_wedding_appointment_book_tos{start_time=StartTime, end_time=EndTime} = Tos,
    check_book(StartTime, EndTime),
    ?_check(role_marriage:is_married(RoleID), ?ERR_WEDDING_NOT_MARRIRED),
    ?_check(role_marriage:wtime(RoleID) == ?nil, ?ERR_WEDDING_HAS_APPOINTMENT),
    ?_check(role_marriage:get_remain_wcount(RoleID) > 0, ?ERR_WEDDING_NO_WCOUNT),
    wedding_manager:book(StartTime, EndTime, [RoleID, role_marriage:marry_with(RoleID)]);

handle(?WEDDING_GUEST_LIST, _Tos, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    ?_check(role_marriage:wtime(RoleID) =/= ?nil, ?ERR_WEDDING_NO_APPOINTMENT),
    List = wedding_util:guest_list(RoleSt#role_st.role),
    #wedding{add=Add} = wedding_ets:get(role_marriage:wtime(RoleSt#role_st.role)),
    InviteMax = cfg_marriage:invite(),
    ?ucast(#m_wedding_guest_list_toc{
        guests     = [role:get_base(ID)||ID<-List],
        max_invite = InviteMax+Add
    });

handle(?WEDDING_GUEST_INVITE, Tos, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    ?_check(role_marriage:wtime(RoleID) =/= ?nil, ?ERR_WEDDING_NO_APPOINTMENT),
    #m_wedding_guest_invite_tos{id=InviteID} = Tos,
    Pid = wedding_agent(RoleSt),
    ok = wedding_agent:invite(Pid, InviteID);

handle(?WEDDING_INVITATION_ADD, _Tos, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    ?_check(role_marriage:wtime(RoleID) =/= ?nil, ?ERR_WEDDING_NO_APPOINTMENT),
    Pid = wedding_agent(RoleSt),
    Cost = cfg_marriage:invite_add(),
    Succ = fun() ->
        {ok, Max} = wedding_agent:add_invite(Pid),
        ?ucast(#m_wedding_invitation_add_toc{max_invite=Max})
    end,
    role_bag:cost(Cost, ?LOG_WEDDING_INVITE_ADD, Succ, RoleSt);

handle(?WEDDING_NOTICE, _Tos, RoleSt) ->
    case wedding_ets:current() of
        [Wedding|_] ->
            ?ucast(#m_wedding_notice_toc{wedding=wedding_util:p_wedding(Wedding)});
        _ ->
            ignore
    end;

handle(?WEDDING_INVITATION_REQUEST, Tos, RoleSt) ->
    #m_wedding_invitation_request_tos{start_time=StartTime, end_time=EndTime} = Tos,
    Pid = wedding_agent(StartTime, EndTime),
    ok = wedding_agent:invite_request(Pid, RoleSt#role_st.role),
    ?ucast(#m_wedding_invitation_request_toc{});

handle(?WEDDING_INVITATION_REQUEST_LIST, _Tos, RoleSt) ->
    {List, Remain} = wedding_util:request_list(RoleSt#role_st.role),
    ?ucast(#m_wedding_invitation_request_list_toc{
        guests=[role:get_base(ID)||ID<-List], remain_invite=Remain});

handle(?WEDDING_INVITATION_REQUEST_ACCEPT, Tos, RoleSt) ->
    #m_wedding_invitation_request_accept_tos{ids=IDs} = Tos,
    Pid = wedding_agent(RoleSt),
    ok = wedding_agent:request_accept(Pid, IDs);

handle(?WEDDING_INVITATION_REQUEST_REFUSE, Tos, RoleSt) ->
    #m_wedding_invitation_request_refuse_tos{id=ID} = Tos,
    Pid = wedding_agent(RoleSt),
    ok = wedding_agent:request_refuse(Pid, ID);

handle(?WEDDING_PARTY_INFO, _Tos, RoleSt) ->
    #role_st{spid=ScenePid, role=RoleID, scene=Scene} = RoleSt,
    ?_check(Scene == wedding_util:scene(), ?ERR_WEDDING_NOT_IN_PARTY),
    scene:route(ScenePid, wedding_party, handle, {info, RoleID});

handle(?WEDDING_PARTY_EXP, _Tos, RoleSt) ->
    #role_st{spid=ScenePid, role=RoleID, scene=Scene} = RoleSt,
    ?_check(Scene == wedding_util:scene(), ?ERR_WEDDING_NOT_IN_PARTY),
    scene:route(ScenePid, wedding_party, handle, {exp, RoleID});

handle(?WEDDING_PARTY_FETCH, Tos, RoleSt) ->
    #role_st{spid=ScenePid, role=RoleID, scene=Scene} = RoleSt,
    ?_check(Scene == wedding_util:scene(), ?ERR_WEDDING_NOT_IN_PARTY),
    #m_wedding_party_fetch_tos{hot=Lv} = Tos,
    ?_check(cfg_marriage_hot:find(Lv) =/= ?nil, ?ERR_GAME_BAD_ARGS, [?WEDDING_PARTY_FETCH]),
    scene:route(ScenePid, wedding_party, handle, {fetch, RoleID, Lv}).

fetch_succ(Rewards, RoleSt) ->
    role_bag:gain(Rewards, ?LOG_WEDDING_PARTY_FETCH, RoleSt).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
wedding_agent(RoleSt) ->
    Pid = wedding_util:pid(RoleSt#role_st.role),
    ?_check(erlang:is_pid(Pid) andalso erlang:is_process_alive(Pid), ?ERR_WEDDING_NO_APPOINTMENT),
    Pid.

wedding_agent(StartTime, EndTime) ->
    Pid = wedding_ets:pid(StartTime, EndTime),
    ?_check(erlang:is_pid(Pid) andalso erlang:is_process_alive(Pid), ?ERR_WEDDING_NO_APPOINTMENT),
    Pid.

check_book(StartTime, EndTime) ->
    ActID = cfg_marriage:activity(),
    #cfg_activity{pre=PreSecs, time=TimeList} = cfg_activity:find(ActID),
    Date  = ut_time:date(),
    TimeList2 = [
        {
            ut_time:datetime_to_seconds({Date,S}),
            ut_time:datetime_to_seconds({Date,E})
        } || {S, E} <- TimeList],
    ?_check(lists:member({StartTime,EndTime}, TimeList2), ?ERR_WEDDING_WRONG_TIME),

    #activity{stime=NearSTime, etime=NearETime} = activity:activity(ActID),
    case {StartTime,EndTime} == {NearSTime,NearETime} of
        true  ->
            CanBook = ut_time:seconds() < StartTime - PreSecs,
            ?_check(CanBook, ?ERR_WEDDING_WRONG_TIME);
        false ->
            ok
    end.
