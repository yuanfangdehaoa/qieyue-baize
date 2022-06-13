%% @author rong
%% @doc
-module(weekly_handler).

-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("weekly.hrl").
-include("enum.hrl").

-export([hook_login/1, hook_reset/3, handle/3, notify/4]).

hook_login(_RoleSt) ->
    init_listener().

hook_reset(_DoW, _Hour, RoleSt) ->
    role_data:set(#role_weekly{id = RoleSt#role_st.role}),
    init_listener().

handle(?WEEKLY_INFO, _Tos, RoleSt) ->
    #role_weekly{list=List, rewarded=Rewared,
        total=Total} = role_data:get(?DB_ROLE_WEEKLY),
    ?ucast(#m_weekly_info_toc{list=List, rewarded=Rewared, total=Total});

handle(?WEEKLY_FINISH, Tos, RoleSt) ->
    #m_weekly_finish_tos{id=ID} = Tos,
    #role_weekly{list=List, total=Total} = RoleWeekly = role_data:get(?DB_ROLE_WEEKLY),
    Conf = cfg_weekly:find(ID),
    ?_check(Conf =/= ?nil, ?ERR_GAME_BAD_ARGS),
    #cfg_weekly{count=Count, reward=Reward} = Conf,
    Weekly = lists:keyfind(ID, #p_weekly.id, List),
    ?_check(Weekly =/= false, ?ERR_WEEKLY_NOT_FINISH),
    ?_check(Weekly#p_weekly.progress >= Count, ?ERR_WEEKLY_NOT_FINISH),
    ?_check(not Weekly#p_weekly.rewarded, ?ERR_WEEKLY_ALREADY_REWARD),
    {value, {_, Add}, Gain} = lists:keytake(?ITEM_WEEKLY_ACT, 1, Reward),
    Succ = fun() ->
        Weekly2 = Weekly#p_weekly{rewarded=true},
        List2 = lists:keystore(ID, #p_weekly.id, List, Weekly2),
        role_data:set(RoleWeekly#role_weekly{list=List2, total=Total+Add}),
        ?ucast(#m_weekly_finish_toc{weekly=Weekly2, total=Total+Add})
    end,
    role_bag:gain(Gain, ?LOG_WEEKLY_FINISH, Succ, RoleSt);

handle(?WEEKLY_REWARD, Tos, RoleSt) ->
    #m_weekly_reward_tos{id=ID} = Tos,
    #role_weekly{rewarded=Rewarded, total=Total}
        = RoleWeekly = role_data:get(?DB_ROLE_WEEKLY),
    ?_check(not lists:member(ID, Rewarded), ?ERR_WEEKLY_ALREADY_REWARD),
    Conf = cfg_weekly_reward:find(ID),
    ?_check(Conf =/= ?nil, ?ERR_GAME_BAD_ARGS),
    #cfg_weekly_reward{activation=Need, reward=Rewards} = Conf,
    ?_check(Total >= Need, ?ERR_WEEKLY_REWARD_NOT_ENOUGH),
    Succ = fun() ->
        role_data:set(RoleWeekly#role_weekly{rewarded=[ID|Rewarded]}),
        ?ucast(#m_weekly_reward_toc{id=ID})
    end,
    role_bag:gain(Rewards, ?LOG_WEEKLY_REWARD, Succ, RoleSt).

notify(Event, ID, Args, RoleSt) ->
    #role_weekly{list=List} = RoleWeekly = role_data:get(?DB_ROLE_WEEKLY),
    #cfg_weekly{count=Count, target=Target} = cfg_weekly:find(ID),
    [{Event, Goal}] = Target,
    case is_finish(Event, Goal, Args) of
        {true, Op, Num} ->
            Weekly2 = case lists:keyfind(ID, #p_weekly.id, List) of
                #p_weekly{progress = P} = Weekly when P >= Count ->
                    Weekly;
                #p_weekly{progress = P} = Weekly ->
                    WeeklyT = Weekly#p_weekly{progress = calc(P, Op, Num)},
                    role_data:set(RoleWeekly#role_weekly{
                        list  = lists:keystore(ID, #p_weekly.id, List, WeeklyT)
                    }),
                    ?ucast(#m_weekly_update_toc{weekly=WeeklyT}),
                    WeeklyT;
                _ ->
                    Weekly = #p_weekly{id=ID, progress=calc(0, Op, Num), rewarded=false},
                    role_data:set(RoleWeekly#role_weekly{
                        list  = [Weekly|List]
                    }),
                    ?ucast(#m_weekly_update_toc{weekly=Weekly}),
                    Weekly
            end,
            ?_if(Weekly2#p_weekly.progress >= Count,
                role_event:remove(Event, ?MODULE, notify, ID));
        false ->
            ignore
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
init_listener() ->
    #role_weekly{list=List} = role_data:get(?DB_ROLE_WEEKLY),
    lists:foreach(fun(ID) ->
        #cfg_weekly{count=Count, target=Target} = cfg_weekly:find(ID),
        case lists:keyfind(ID, #p_weekly.id, List) of
            #p_weekly{progress = P} when P >= Count ->
                ignore;
            _ ->
                case Target of
                    [{Event, _}] ->
                        role_event:listen(Event, ?MODULE, notify, ID);
                    _ ->
                        ignore
                end
        end
    end, cfg_weekly:list()).

is_finish(?EVENT_DUNGE_FLOOR, SceneSType, {SceneSType, _Dunge, Floor}) ->
    {true, '=', Floor};
is_finish(?EVENT_DUNGE_ENTER, SceneSType, {SceneSType, _Dunge, _Floor}) ->
    {true, '+', 1};
is_finish(?EVENT_TASK, TaskType, {TaskType, _TaskID}) ->
    {true, '+', 1};
is_finish(?EVENT_FLOWER, Target, Flower) when Target == 0; Target == Flower ->
    {true, '+', 1};
is_finish(?EVENT_CREEP, ?CREEP_RARITY_BOSS, {_, ?CREEP_RARITY_BOSS}) ->
    {true, '+', 1};
is_finish(?EVENT_EQUIP_STRENGTH, _, _) ->
    {true, '+', 1};
is_finish(_Event, _Target, _Args) ->
    false.

calc(_P, '=', Num) ->
    Num;
calc(P, '+', Num) ->
    P+Num.
