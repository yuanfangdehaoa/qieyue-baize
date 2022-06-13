%% @author rong
%% @doc
-module(candyroom).

-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("log.hrl").
-include("activity.hrl").
-include("proto.hrl").
-include("errno.hrl").
-include("candyroom.hrl").
-include("role.hrl").
-include("msgno.hrl").
-include("item.hrl").

-export([handle/2, get_buy_times/2, over/1]).
-export([hook_start/1, hook_stop/1]).
-export([hook_init/1, hook_enter/2, hook_loopsec/2]).

-record(candyroom_info, {name, exp = 0, gift_num = 0, pop = 0, buy_times = 0,
    recv_log = #{}, send_log = #{}}).

hook_start(ActID) ->
    ?debug("=======start ~w", [ActID]),
    #cfg_activity{scene = SceneID, type=ActType} = cfg_activity:find(ActID),
    Mode = case ActType of
        ?ACTIVITY_TYPE_LOCAL -> local;
        ?ACTIVITY_TYPE_CROSS -> cross
    end,
    scene:create(SceneID, 0, #{
        activity => ActID, 
        mode     => Mode,
        etime    => activity:etime(ActID)
    }).

hook_stop(ActID) ->
    ?debug("=======stop ~w", [ActID]),
    #cfg_activity{scene = SceneID} = cfg_activity:find(ActID),
    scene:route(SceneID, ?MODULE, over),
    scene:destroy(SceneID).

handle({#m_candyroom_info_tos{}, RoleID}, SceneSt) ->
    #scene_st{opts=#{etime := ETime, activity := ActID}} = SceneSt,
    #candyroom_info{exp = Exp} = get_info(RoleID),
    Top = hd(get_rank()),
    ?ucast(RoleID, #m_candyroom_info_toc{activity_id=ActID, etime=ETime, exp=Exp, top=p_rank(1, Top)});

handle({#m_candyroom_gift_info_tos{}, RoleID}, _SceneSt) ->
    #candyroom_info{gift_num = GiftNum} = get_info(RoleID),
    ?ucast(RoleID, #m_candyroom_gift_info_toc{num = GiftNum});

handle({#m_candyroom_send_gift_tos{id=TargetID, gift_id=GiftID}, RoleID}, SceneSt) ->
    case scene_actor:get_actor(TargetID) of
        ?nil ->
            ?ucast(RoleID, #m_game_error_toc{errno=?ERR_CANDYROOM_NOT_HERE});
        #actor{name=TargetName} ->
            case get_info(RoleID) of
                #candyroom_info{gift_num = GiftNum} when GiftNum > 0 ->
                    #cfg_candyroom_gift{pop=Add, msg_no=MsgNo}
                        = cfg_candyroom_gift:find(GiftID),
                    update_info(TargetID, #candyroom_info.pop, '+', Add),
                    update_info(RoleID, #candyroom_info.gift_num, '-', 1),
                    add_log(RoleID, TargetID),
                    do_rank(),

                    #actor{name=SendName, level=Level} = scene_actor:get_actor(RoleID),
                    Exp = gift_exp(Level, SceneSt),
                    role:add_exp(RoleID, Exp, ?LOG_CANDYROOM_GIFT),
                    ?ucast(RoleID, #m_candyroom_send_gift_toc{num = GiftNum-1}),
                    ?ucast(TargetID, #m_candyroom_receive_gift_toc{}),
                    ?notify(scene_actor:get_actids(?ACTOR_TYPE_ROLE), MsgNo, [SendName, TargetName]);
                _ ->
                    ?ucast(RoleID, #m_game_error_toc{errno=?ERR_CANDYROOM_GIFTNUM_NOT_ENOUGH})
            end
    end;

handle({#m_candyroom_rank_tos{num=Top}, RoleID}, _SceneSt) ->
    ?ucast(RoleID, #m_candyroom_rank_toc{ranks=p_rank(lists:sublist(get_rank(), Top))});

handle({#m_candyroom_gift_log_tos{type=Type}, RoleID}, _SceneSt) ->
    ?ucast(RoleID, #m_candyroom_gift_log_toc{type=Type, logs=p_logs(RoleID, Type)});

handle({buy, RoleID, Num}, _SceneSt) ->
    update_info(RoleID, #candyroom_info.gift_num, '+', Num),
    #candyroom_info{gift_num = GiftNum} = get_info(RoleID),
    update_info(RoleID, #candyroom_info.buy_times, '+', Num),
    ?ucast(RoleID, #m_candyroom_buy_toc{num = GiftNum}).

get_buy_times(RoleID, _SceneSt) ->
    Info = get_info(RoleID),
    Info#candyroom_info.buy_times.

% 结束发放奖励
over(SceneSt) ->
    ?debug("over ~w", [get_rank()]),
    lists:foldl(fun(RoleID, Rank) ->
        Rewards0 = reward(Rank, SceneSt),
        {ok, #role_cache{name=Name, level=RoleLv}} = role:get_cache(RoleID),
        Rewards = lists:map(fun
            ({?ITEM_PLAYER_EXP, Num}) -> 
                #cfg_exp_acti_base{role_exp=RoleExp} = cfg_exp_acti_base:find(RoleLv),
                {?ITEM_EXP, trunc(Num * RoleExp)};
            (I) -> I
        end, Rewards0),
        #candyroom_info{pop=Pop} = get_info(RoleID),
        mail:send(RoleID, ?MAIL_CANDYROOM_REWARD, Rewards, [Pop, Rank]),
        case scene_actor:get_actor(RoleID) of
            Actor when Actor =/= ?nil ->
                #candyroom_info{exp=Exp} = get_info(RoleID),
                ?ucast(RoleID, #m_candyroom_over_toc{rank=Rank, exp=Exp});
            _ ->
                ignore
        end,
        Rank =< 3 andalso ?notify(scene_actor:get_actids(?ACTOR_TYPE_ROLE), 
            ?MSG_CANDYROOM_OVER, [{role, RoleID, Name}, Rank]),
        Rank+1
    end, 1, get_rank()).

%%-----------------------------------------------
%% scene_hook 回调函数
%%-----------------------------------------------
hook_init(_SceneSt) ->
    erlang:put({?MODULE, next_add_time}, ut_time:seconds()+cfg_candyroom:exp_interval()).

hook_enter(Actor, _SceneSt) ->
    #actor{uid=RoleID} = Actor,
    role_event:event(RoleID, ?EVENT_ATTEND_ACTIVITY, ?ACTIVITY_GROUP_CANDYROOM),
    init_data(RoleID).

hook_loopsec(NowSec, SceneSt) ->
    case erlang:get({?MODULE, next_add_time}) of
        NextSec when is_integer(NextSec), NowSec >= NextSec ->
            erlang:put({?MODULE, next_add_time}, NowSec+cfg_candyroom:exp_interval()),
            [begin
                #actor{level=Level} = scene_actor:get_actor(RoleID),
                Exp = loop_exp(Level, SceneSt),
                role:add_exp(RoleID, Exp, ?LOG_CANDYROOM_EXP),
                update_info(RoleID, #candyroom_info.exp, '+', Exp)
            end || RoleID <- scene_actor:get_actids(?ACTOR_TYPE_ROLE)];
        _ ->
            ignore
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
init_data(RoleID) ->
    case get_info(RoleID) of
        ?nil ->
            #actor{name=Name} = scene_actor:get_actor(RoleID),
            erlang:put({?MODULE, RoleID}, #candyroom_info{
                name     = Name,
                gift_num = cfg_candyroom:gift_num()
            }),
            join_rank(RoleID);
        _ ->
            ignore
    end.

get_info(RoleID) ->
    erlang:get({?MODULE, RoleID}).

update_info(RoleID, Pos, Op, Val) ->
    Info = get_info(RoleID),
    FinVal = case Op of
        '+' -> erlang:element(Pos, Info) + Val;
        '-' -> erlang:element(Pos, Info) - Val;
        '=' -> Val
    end,
    Info2 = erlang:setelement(Pos, Info, FinVal),
    erlang:put({?MODULE, RoleID}, Info2),
    case Pos of
        #candyroom_info.pop ->
            if
                FinVal rem 100 == 0 ->
                    {ok, #role_cache{name=Name}} = role:get_cache(RoleID),
                    ?notify(scene_actor:get_actids(?ACTOR_TYPE_ROLE), 
                        ?MSG_CANDYROOM_POP, [{role, RoleID, Name}, FinVal]);
                true ->
                    ignore
            end;
        _ ->
            ignore
    end.

% 排名
do_rank() ->
    Ranks = lists:sort(fun(R1, R2) ->
        #candyroom_info{pop=P1} = get_info(R1),
        #candyroom_info{pop=P2} = get_info(R2),
        P1 >= P2
    end, get_rank()),
    erlang:put({?MODULE, rank}, Ranks).

join_rank(RoleID) ->
    erlang:put({?MODULE, rank}, get_rank() ++ [RoleID]).

get_rank() ->
    case erlang:get({?MODULE, rank}) of
        ?nil -> [];
        List -> List
    end.

p_rank(Rank, RoleID) ->
    #candyroom_info{name=Name, pop=Pop} = get_info(RoleID),
    #p_candyroom_rank{
        rank = Rank,
        id   = RoleID,
        name = Name,
        pop  = Pop
    }.

p_rank(Ranks) when is_list(Ranks) ->
    {_, TopRanks} = lists:foldl(fun(RoleID, {Rank, Acc}) ->
        PRank = p_rank(Rank, RoleID),
        {Rank+1, [PRank|Acc]}
    end, {1, []}, Ranks),
    lists:reverse(TopRanks).

add_log(RoleID, TargetID) ->
    #candyroom_info{send_log = SendLog} = Info1 = get_info(RoleID),
    #candyroom_info{recv_log = RecvLog} = Info2 = get_info(TargetID),
    SendTimes = maps:get(TargetID, SendLog, 0),
    SendLog2 = maps:put(TargetID, SendTimes+1, SendLog),
    RecvTimes = maps:get(RoleID, RecvLog, 0),
    RecvLog2 = maps:put(RoleID, RecvTimes+1, RecvLog),
    erlang:put({?MODULE, RoleID}, Info1#candyroom_info{send_log = SendLog2}),
    erlang:put({?MODULE, TargetID}, Info2#candyroom_info{recv_log = RecvLog2}).

p_logs(RoleID, 1) ->
    #candyroom_info{recv_log = RecvLog} = get_info(RoleID),
    p_log(RecvLog);
p_logs(RoleID, 2) ->
    #candyroom_info{send_log = SendLog} = get_info(RoleID),
    p_log(SendLog).

p_log(Logs) ->
    [begin
        #candyroom_info{name=Name} = get_info(RoleID),
        #p_candyroom_log{id=RoleID, name=Name, num=Num}
    end || {RoleID, Num} <- maps:to_list(Logs)].

reward(Rank, SceneSt) ->
    #scene_st{opts=#{mode := Mode}} = SceneSt,
    cfg_candyroom_reward:find(Mode, Rank).

gift_exp(Level, SceneSt) ->
    #scene_st{opts=#{mode := Mode}} = SceneSt,
    cfg_candyroom_exp:gift_exp(Mode, Level).

loop_exp(Level, SceneSt) ->
    #scene_st{opts=#{mode := Mode}} = SceneSt,
    cfg_candyroom_exp:loop_exp(Mode, Level).
