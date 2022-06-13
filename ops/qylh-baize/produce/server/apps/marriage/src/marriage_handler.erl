%% @author rong
%% @doc
-module(marriage_handler).

-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("enum.hrl").
-include("log.hrl").
-include("marriage.hrl").
-include("msgno.hrl").
-include("item.hrl").

-export([handle/3, marriage_succ/2, divorce_succ/2]).

handle(?MARRIAGE_STEP, _Tos, RoleSt) ->
    #role_marriage{steps=Steps} = role_data:get(?DB_ROLE_MARRIAGE),
    ?ucast(#m_marriage_step_toc{steps=Steps});

handle(?MARRIAGE_STEP_REWARD, Tos, RoleSt) ->
    #m_marriage_step_reward_tos{id=ID} = Tos,
    #role_marriage{steps=Steps0} = RoleMarriage = role_data:get(?DB_ROLE_MARRIAGE),
    Step = lists:keyfind(ID, #p_marriage_step.id, Steps0),
    ?_check(Step =/= ?nil, ?ERR_GAME_BAD_ARGS, [?MARRIAGE_STEP_REWARD]),
    case Step#p_marriage_step.state of
        ?PROGRESS_STATE_UNDONE ->
            throw(?err(?ERR_MARRIAGE_STEP_UNDONE));
        ?PROGRESS_STATE_REWARD ->
            throw(?err(?ERR_MARRIAGE_STEP_REWARD));
        _ ->
            ok
    end,
    #cfg_marriage_step{reward=Gain} = cfg_marriage_step:find(ID),
    Succ = fun() ->
        Step1 = Step#p_marriage_step{state=?PROGRESS_STATE_REWARD},
        Steps = lists:keystore(ID, #p_marriage_step.id, Steps0, Step1),
        role_data:set(RoleMarriage#role_marriage{steps=Steps}),
        ?ucast(#m_marriage_step_toc{steps=Steps})
    end,
    role_bag:gain(Gain, ?LOG_MARRIAGE_STEP, Succ, RoleSt);

handle(?MARRIAGE_PROPOSAL_PANEL, Tos, RoleSt) ->
    #m_marriage_proposal_panel_tos{target=TargetID} = Tos,
    #role_info{gender=Gender} = role_data:get(?DB_ROLE_INFO),
    {ok, Cache} = role:get_cache(TargetID),
    ?_check(Cache#role_cache.gender =/= Gender, ?ERR_MARRIAGE_GENDER),
    {ok, Types} = marriage_manager:target_info(RoleSt#role_st.role, TargetID),
    ?ucast(#m_marriage_proposal_panel_toc{types=Types});

handle(?MARRIAGE_PROPOSAL, Tos, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    #m_marriage_proposal_tos{target=TargetID, type=Type, is_aa=IsAA} = Tos,
    #role_info{level=Level, gender=Gender} = role_data:get(?DB_ROLE_INFO),
    ?_check(Level >= cfg_marriage:level(), ?ERR_MARRIAGE_LEVEL),

    {ok, Cache} = role:get_cache(TargetID),
    ?_check(Cache#role_cache.gender =/= Gender, ?ERR_MARRIAGE_GENDER),
    ?_check(Cache#role_cache.level >= cfg_marriage:level(), ?ERR_MARRIAGE_LEVEL),
    ?_check(role:is_online(TargetID), ?ERR_MARRIAGE_NEED_ONLINE),

    Intimacy = friend_server:get_intimacy(RoleID, TargetID),
    ?_check(Intimacy >= cfg_marriage:intimacy(), ?ERR_MARRIAGE_INTIMACY),

    #cfg_marriage_type{cost=Cost0} = cfg_marriage_type:find(Type),
    [{MoneyType, Num}] = Cost0,
    {Cost, NeedGold} = if
        IsAA -> {[{MoneyType, Num div 2}], Num div 2};
        true -> {Cost0, Num}
    end,
    Total = role_bag:get_money(MoneyType),
    ?_check(Total >= NeedGold, ?ERR_ITEM_NOT_ENOUGH, [MoneyType, NeedGold]),

    case marriage_manager:propose(RoleSt#role_st.role, TargetID, Type, IsAA, {MoneyType, NeedGold}) of
        ok ->
            role_bag:cost(Cost, ?LOG_MARRIAGE_PROPOSAL, RoleSt),
            ?ucast(TargetID, #m_marriage_proposal_request_toc{
                role=role:get_base(RoleID), type=Type, is_aa=IsAA,
                endtime=ut_time:seconds()+cfg_marriage:auto_refuse()}),
            ?ucast(#m_marriage_proposal_toc{});
        {error, ErrCode, Args} ->
            ?ucast(#m_game_error_toc{errno=ErrCode, args=Args})
    end;

handle(?MARRIAGE_PROPOSAL_REQUEST, _Tos, RoleSt) ->
    case marriage_manager:get_request(RoleSt#role_st.role) of
        {ok, Proposal} when is_record(Proposal, marriage_proposal) ->
            #marriage_proposal{proposer=Proposer, type=Type, is_aa=IsAA, ts=Ts} = Proposal,
            ?ucast(#m_marriage_proposal_request_toc{
                role=role:get_base(Proposer), type=Type, is_aa=IsAA,
                endtime=Ts+cfg_marriage:auto_refuse()});
        _ ->
            ignore
    end;

handle(?MARRIAGE_PROPOSAL_ACCEPT, Tos, RoleSt) ->
    #m_marriage_proposal_accept_tos{target=TargetID} = Tos,
    #role_st{spid=ScenePid, role=RoleID} = RoleSt,

    #marriage{be_proposed=Proposal} = marriage_ets:get(RoleID),
    ?_check(Proposal =/= ?nil, ?ERR_MARRIAGE_NOT_PROPOSE),
    if
        Proposal#marriage_proposal.is_aa ->
            {MoneyType, NeedGold} = Proposal#marriage_proposal.gold,
            Cost = [{MoneyType, NeedGold}],
            Total = role_bag:get_money(MoneyType),
            ?_check(Total >= NeedGold, ?ERR_ITEM_NOT_ENOUGH, [MoneyType, NeedGold]);
        true ->
            Cost = []
    end,

    case marriage_manager:accept(RoleID, TargetID) of
        {ok, Type, MaxType} ->
            ?ucast(#m_marriage_proposal_accept_toc{}),

            #role_info{name=Name} = role_data:get(?DB_ROLE_INFO),
            {ok, #role_cache{name=TargetName}=Cache} = role:get_cache(TargetID),
            #cfg_marriage_type{name=Wedding, reward=Reward, title=Title} = cfg_marriage_type:find(Type),
            ?notify(?MSG_MARRIAGE_SUCC, [
                {role, TargetID, TargetName},
                {role, RoleID, Name},
                {color, Wedding, wedding_color(Type)}
            ]),

            #role_marriage{history=History} = RoleMarriage = role_data:get(?DB_ROLE_MARRIAGE),
            IsFirtTime = maps:get(Type, History, 0) == 0,
            Gain = if
                IsFirtTime ->
                    [{Title, 1, 1} | Reward];
                true ->
                    Reward
            end,
            role_bag:deal(Cost, Gain, ?LOG_MARRIAGE_SUCC, RoleSt),
            role_data:set(RoleMarriage#role_marriage{
                history=ut_misc:maps_increase(Type, 1, History)}),
            ?ucast(#m_marriage_proposal_succ_toc{
                proposer      = role:get_base(Cache),
                accepter      = role:get_base(RoleID),
                type          = Type,
                wedding_times = role_marriage:get_remain_wcount(RoleID)
            }),
            role_event:event(?EVENT_MARRY, Type),
            role_marriage:replace_ring(RoleSt),
            ?ucast(#m_role_update_toc{
                upint=#{"marry"=>TargetID, "mtype"=>MaxType},
                upstr=#{"mname"=>Cache#role_cache.name}
            }),
            Update = [{marriage, TargetID, Cache#role_cache.name, MaxType}],
            scene:update_actor(ScenePid, RoleID, Update),
            role_cache:update(RoleID, [
                {#role_cache.marry, TargetID},
                {#role_cache.mname, Cache#role_cache.name},
                {#role_cache.mtype, MaxType}
            ]),

            ProposeGold = Proposal#marriage_proposal.gold,
            role:route(TargetID, ?MODULE, marriage_succ,
                {RoleID, Type, MaxType, ProposeGold}, {RoleID, Type, MaxType, ProposeGold});
        {error, ErrCode, Args} ->
            ?ucast(#m_game_error_toc{errno=ErrCode, args=Args})
    end;

handle(?MARRIAGE_PROPOSAL_REFUSE, Tos, RoleSt) ->
    #m_marriage_proposal_refuse_tos{target=TargetID} = Tos,
    #role_st{role=RoleID, name=RoleName} = RoleSt,
    marriage_manager:refuse(RoleID, RoleName, TargetID),
    ?ucast(#m_marriage_proposal_refuse_toc{});

handle(?MARRIAGE_DIVORCE, _Tos, RoleSt) ->
    #role_st{spid=ScenePid, role=RoleID} = RoleSt,
    case marriage_manager:divorce(RoleID) of
        {ok, TargetID} ->
            {ok, Cache} = role:get_cache(TargetID),
            #role_info{name=Name} = role_data:get(?DB_ROLE_INFO),
            mail:send(RoleID, ?MAIL_MARRIAGE_DIVORCE, [], [Cache#role_cache.name, Name]),
            role_marriage:replace_ring(RoleSt),
            ?ucast(#m_role_update_toc{
                upint=#{"marry"=>0, "mtype"=>0},
                upstr=#{"mname"=>""}
            }),
            Update = [{marriage, 0, "", 0}],
            scene:update_actor(ScenePid, RoleID, Update),
            role_cache:update(RoleID, [
                {#role_cache.marry, 0},
                {#role_cache.mname, ""},
                {#role_cache.mtype, 0}
            ]),
            ?ucast(#m_marriage_divorce_toc{}),
            role:route(TargetID, ?MODULE, divorce_succ, RoleID, RoleID);
        {error, ErrCode, Args} ->
            ?ucast(#m_game_error_toc{errno=ErrCode, args=Args})
    end;

handle(?MARRIAGE_INFO, _Tos, RoleSt) ->
    #marriage{marry_with=MarryWith, marry_date=MarryDate, has_marry=HasMarry}
        = marriage_ets:get(RoleSt#role_st.role),
    case MarryWith > 0 of
        true ->
            Base = role:get_base(MarryWith),
            Day = ut_time:diff_days(MarryDate, ut_time:today()) + 1,
            ?ucast(#m_marriage_info_toc{
                marry_with    = Base,
                day           = Day,
                has_marry     = HasMarry,
                intimacy      = friend_server:get_intimacy(RoleSt#role_st.role, MarryWith),
                wedding_times = role_marriage:get_remain_wcount(RoleSt#role_st.role)
            });
        false ->
            ?ucast(#m_marriage_info_toc{day=0, intimacy=0,
                has_marry=HasMarry, wedding_times=0})
    end;

handle(?MARRIAGE_RING_INFO, _Tos, RoleSt) ->
    #role_marriage{ring=Ring} = role_data:get(?DB_ROLE_MARRIAGE),
    ?ucast(#m_marriage_ring_info_toc{ring=Ring});

handle(?MARRIAGE_RING_UPGRADE, _Tos, RoleSt) ->
    #role_marriage{ring=Ring} = RoleMarriage = role_data:get(?DB_ROLE_MARRIAGE),
    #p_marriage_ring{grade=Grade, level=Level, exp=Exp} = Ring,
    #cfg_marriage_ring{exp=NeedExp} = cfg_marriage_ring:find(Grade, Level),
    ?_check(NeedExp > 0, ?ERR_MARRIAGE_RING_MAX),
    Cost = [{cfg_marriage:ring_upitem(), 1}],
    role_bag:cost(Cost, ?LOG_MARRIAGE_RING, RoleSt),
    #cfg_item{effect=Add} = cfg_item:find(cfg_marriage:ring_upitem()),
    {IsUp, Ring2} = if
        Exp + Add >= NeedExp ->
            case cfg_marriage_ring:find(Grade, Level+1) of
                ?nil ->
                    {true, Ring#p_marriage_ring{grade=Grade+1, level=1, exp=Exp+Add-NeedExp}};
                _ ->
                    {true, Ring#p_marriage_ring{level=Level+1, exp=Exp+Add-NeedExp}}
            end;
        true ->
            {false, Ring#p_marriage_ring{exp=Exp+Add}}
    end,
    role_data:set(RoleMarriage#role_marriage{ring=Ring2}),
    IsUp andalso role_marriage:replace_ring(RoleSt),
    ?ucast(#m_marriage_ring_upgrade_toc{ring=Ring2}).

marriage_succ({AcceptID, Type, MaxType, Cost}, RoleSt) ->
    #role_st{spid=ScenePid, role=RoleID} = RoleSt,
    #cfg_marriage_type{reward=Reward, title=Title} = cfg_marriage_type:find(Type),
    #role_marriage{history=History} = RoleMarriage = role_data:get(?DB_ROLE_MARRIAGE),
    IsFirtTime = maps:get(Type, History, 0) == 0,
    Gain = if
        IsFirtTime ->
            [{Title, 1, 1} | Reward];
        true ->
            Reward
    end,
    role_bag:gain(Gain, ?LOG_MARRIAGE_SUCC, RoleSt),
    role_data:set(RoleMarriage#role_marriage{
        history=ut_misc:maps_increase(Type, 1, History)}),
    case Cost of
        {?ITEM_GOLD, _ProposeGold} ->
            ignore;
%%            role_vip:add_exp(ProposeGold, RoleSt);   %% 结婚不加vip经验了 2020.7.12
        _ ->
            ignore
    end,
    role_event:event(?EVENT_MARRY, Type),
    {ok, Cache} = role:get_cache(AcceptID),
    ?ucast(#m_marriage_proposal_succ_toc{
        proposer      = role:get_base(RoleSt#role_st.role),
        accepter      = role:get_base(Cache),
        type          = Type,
        wedding_times = role_marriage:get_remain_wcount(RoleID)
    }),
    ?ucast(#m_role_update_toc{
        upint=#{"marry"=>AcceptID, "mtype"=>MaxType},
        upstr=#{"mname"=>Cache#role_cache.name}
    }),
    Update = [{marriage, AcceptID, Cache#role_cache.name, MaxType}],
    scene:update_actor(ScenePid, RoleID, Update),
    role_cache:update(RoleID, [
        {#role_cache.marry, AcceptID},
        {#role_cache.mname, Cache#role_cache.name},
        {#role_cache.mtype, MaxType}
    ]),

    role_marriage:replace_ring(RoleSt).

divorce_succ(Initiator, RoleSt) ->
    #role_st{spid=ScenePid, role=RoleID} = RoleSt,
    {ok, Cache} = role:get_cache(Initiator),
    mail:send(RoleID, ?MAIL_MARRIAGE_DIVORCE, [], [Cache#role_cache.name, Cache#role_cache.name]),
    role_marriage:replace_ring(RoleSt),
    ?ucast(#m_role_update_toc{
        upint=#{"marry"=>0, "mtype"=>0},
        upstr=#{"mname"=>""}
    }),
    Update = [{marriage, 0, "", 0}],
    scene:update_actor(ScenePid, RoleID, Update),
    role_cache:update(RoleID, [
        {#role_cache.marry, 0},
        {#role_cache.mname, ""},
        {#role_cache.mtype, 0}
    ]),
    ?ucast(#m_marriage_divorce_toc{}),
    ok.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
wedding_color(1) -> ?COLOR_BLUE;
wedding_color(2) -> ?COLOR_PURPLE;
wedding_color(3) -> ?COLOR_RED.
