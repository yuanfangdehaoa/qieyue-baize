%% @author rong
%% @doc
-module(daily_handler).

-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("daily.hrl").
-include("enum.hrl").
-include("boss.hrl").

-export([hook_sysopen/1, hook_login/1, hook_reset/3, handle/3, notify/4]).
-export([get_total/0]).

hook_sysopen(RoleSt) ->
    role_illusion:sysopen(RoleSt).

hook_login(_RoleSt) ->
    init_listener().

hook_reset(DoW, _Hour, RoleSt) ->
    reset(DoW, RoleSt).

% 当前累计的活跃度
get_total() ->
    #role_daily{total=Total} = role_data:get(?DB_ROLE_DAILY),
    Total.

handle(?DAILY_INFO, _Tos, RoleSt) ->
    #role_daily{list=List, rewarded=Rewared,
        total=Total} = role_data:get(?DB_ROLE_DAILY),
    ?ucast(#m_daily_info_toc{list=List, rewarded=Rewared, total=Total});

handle(?DAILY_REWARD, Tos, RoleSt) ->
    #m_daily_reward_tos{id=ID} = Tos,
    #role_daily{rewarded=Rewarded, total=Total}
        = RoleDaily = role_data:get(?DB_ROLE_DAILY),
    ?_check(not lists:member(ID, Rewarded), ?ERR_DAILY_ALREADY_REWARD),
    Conf = cfg_daily_reward:find(ID),
    ?_check(Conf =/= ?nil, ?ERR_GAME_BAD_ARGS),
    #cfg_daily_reward{activation=Need, reward=Rewards} = Conf,
    ?_check(Total >= Need, ?ERR_DAILY_REWARD_NOT_ENOUGH),
    Succ = fun() ->
        role_data:set(RoleDaily#role_daily{rewarded=[ID|Rewarded]}),
        ?ucast(#m_daily_reward_toc{id=ID})
    end,
    role_bag:gain(Rewards, ?LOG_DAILY_REWARD, Succ, RoleSt);

handle(?DAILY_ILLUSION, Tos, RoleSt) ->
    role_illusion:handle(Tos, RoleSt);

handle(?DAILY_ILLUSION_UPGRADE, Tos, RoleSt) ->
    role_illusion:handle(Tos, RoleSt);

handle(?DAILY_ILLUSION_SELECT, Tos, RoleSt) ->
    role_illusion:handle(Tos, RoleSt);

handle(?DAILY_ILLUSION_SHOW, Tos, RoleSt) ->
    role_illusion:handle(Tos, RoleSt).

notify(Event, ID, Args, RoleSt) ->
    #cfg_daily{reqs=Reqs} = cfg_daily:find(ID),
    case check_reqs(Reqs) of
        ok ->
            notify_2(Event, ID, Args, RoleSt);
        _ ->
            ignore
    end.

notify_2(Event, ID, Args, RoleSt) ->
    #role_daily{list=List, total=Total} = RoleDaily = role_data:get(?DB_ROLE_DAILY),
    #cfg_daily{count=Count, target=Target, activation=Add} = cfg_daily:find(ID),
    [{Event, Goal}] = Target,
    case is_finish(Event, Goal, Args) of
        {true, Op, Num} ->
            Daily2 = case lists:keyfind(ID, #p_daily.id, List) of
                #p_daily{progress = P} = Daily when P >= Count ->
                    Daily;
                #p_daily{progress = P} = Daily ->
                    DailyT = Daily#p_daily{progress = ut_math:calc(P, Op, Num)},
                    role_data:set(RoleDaily#role_daily{
                        list  = lists:keystore(ID, #p_daily.id, List, DailyT),
                        total = Total+Add
                    }),
                    role_illusion:add_exp(Add),
                    role_event:event(?EVENT_LIVENESS, Total+Add),
                    ?ucast(#m_daily_update_toc{daily=DailyT, total=Total+Add}),
                    DailyT;
                _ ->
                    Daily = #p_daily{id = ID, progress = ut_math:calc(0, Op, Num)},
                    role_data:set(RoleDaily#role_daily{
                        list  = [Daily|List],
                        total = Total+Add
                    }),
                    role_illusion:add_exp(Add),
                    role_event:event(?EVENT_LIVENESS, Total+Add),
                    ?ucast(#m_daily_update_toc{daily=Daily, total=Total+Add}),
                    Daily
            end,
            ?_if(Daily2#p_daily.progress >= Count,
                role_event:remove(Event, ?MODULE, notify, ID));
        false ->
            ignore
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
reset(DoW, RoleSt) ->
    #role_daily{list = List} = role_data:get(?DB_ROLE_DAILY),
    List2 = lists:filter(fun(#p_daily{id=ID}) ->
        #cfg_daily{reset=Reset} = cfg_daily:find(ID),
        Reset == never orelse (Reset == weekly andalso DoW =/= 1)
    end, List),
    role_data:set(#role_daily{id = RoleSt#role_st.role, list = List2}),
    init_listener().

init_listener() ->
    #role_daily{list=List} = role_data:get(?DB_ROLE_DAILY),
    lists:foreach(fun(ID) ->
        #cfg_daily{count=Count, target=Target} = cfg_daily:find(ID),
        case lists:keyfind(ID, #p_daily.id, List) of
            #p_daily{progress = P} when P >= Count ->
                ignore;
            _ ->
                case Target of
                    [{Event, _}] ->
                        role_event:listen(Event, ?MODULE, notify, ID);
                    _ ->
                        ignore
                end
        end
    end, cfg_daily:list()).

is_finish(?EVENT_DUNGE, SceneSType, {SceneSType, _Dunge, _Floor, _Args}) ->
    {true, '+', 1};
is_finish(?EVENT_DUNGE_FLOOR, SceneSType, {SceneSType, _Dunge, Floor}) ->
    {true, '=', Floor};
is_finish(?EVENT_DUNGE_ENTER, SceneSType, {SceneSType, _Dunge, _Floor}) ->
    {true, '+', 1};
is_finish(?EVENT_TASK, TaskType, {TaskType, _TaskID}) ->
    {true, '+', 1};
is_finish(?EVENT_FLOWER, Target, Flower) when Target == 0; Target == Flower ->
    {true, '+', 1};
is_finish(?EVENT_CREEP, BossType, {CreepID, _Rarity}) when is_list(BossType) ->
    case cfg_boss:find(CreepID) of
        #cfg_boss{type=BossType0} -> 
            case lists:member(BossType0, BossType) of
                true -> {true, '+', 1};
                false -> false
            end;
        _   -> false
    end;
is_finish(?EVENT_CREEP, BossType, {CreepID, _Rarity}) when is_integer(BossType) ->
    case cfg_boss:find(CreepID) of
        #cfg_boss{type=BossType} -> {true, '+', 1};
        _                        -> false
    end;
is_finish(?EVENT_EQUIP_STRENGTH, _, _) ->
    {true, '+', 1};
is_finish(?EVENT_ESCORT, _, _Quality) ->
    {true, '+', 1};
is_finish(_Event, _Target, _Args) ->
    false.

check_reqs([]) ->
    ok;
check_reqs([{level, NeedLv}|T]) ->
    #role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
    if
        Level >= NeedLv ->
            check_reqs(T);
        true ->
            error
    end.
