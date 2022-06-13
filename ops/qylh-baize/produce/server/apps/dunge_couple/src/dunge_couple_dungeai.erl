%% @author rong
%% @doc
-module(dunge_couple_dungeai).

-include("game.hrl").
-include("btree.hrl").
-include("dunge.hrl").
-include("proto.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("role.hrl").

-export([init/1]).
-export([stat/1]).
-export([stat_one/1]).
-export([is_boss_dead/1]).
-export([set_level/1]).
-export([mark_question_times/1]).
-export([send_question/1]).
-export([answer_timeout/1]).
-export([auto_answer/1]).
-export([answer/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init(_SceneSt) ->
    ?SUCCESS.

stat(SceneSt) ->
    #dunge_st{roles=RoleIDs, clear=IsClear} = dunge_util:get_state(),
    DungeSt = dunge_util:get_state(),
    #dunge_st{roles=RoleIDs} = DungeSt,
    Answers = get_answers(),
    [begin
        Actor = scene_actor:get_actor(RoleID),
        IsInScene = Actor =/= ?nil,
        case IsInScene of
            true ->
                case IsClear of
                    true ->
                        IsMatch = maps:values(Answers) == [1,1] orelse maps:values(Answers) == [2,2],
                        Gain0 = case IsMatch of
                            true -> proplists:get_value(1, cfg_dunge_couple:reward());
                            false -> proplists:get_value(2, cfg_dunge_couple:reward())
                        end,
                        Gain = game_util:transform_gain(Actor#actor.level, Gain0),
                        give_reward(RoleID, IsMatch, Gain, SceneSt),
                        Rewards = maps:from_list(lists:map(fun(E) -> {element(1, E), element(2, E)} end, Gain));
                    false ->
                        Rewards = #{}
                end,

                ?ucast(RoleID, #m_dunge_over_toc{
                    stype  = SceneSt#scene_st.stype,
                    id     = SceneSt#scene_st.dunge,
                    clear  = IsClear,
                    reward = Rewards,
                    stat   = maps:from_list(lists:map(
                        fun({K, V}) -> {ut_conv:to_list(K), V} end,
                        maps:to_list(Answers)))
                });
            false ->
                ignore
        end
    end || RoleID <- RoleIDs],
    ?SUCCESS.

stat_one(SceneSt) ->
    {hook_over, [RoleID]} = dunge_util:get_event(),
    DungeSt  = dunge_util:get_state(),
    #dunge_st{clear=IsClear, roles=RoleIDs} = DungeSt,
    RoleIDs2 = lists:delete(RoleID, RoleIDs),
    dunge_util:set_state(DungeSt#dunge_st{roles=RoleIDs2}),
    ?ucast(RoleID, #m_dunge_over_toc{
        stype  = SceneSt#scene_st.stype,
        id     = SceneSt#scene_st.dunge,
        clear  = IsClear,
        reward = #{}
    }),
    ?SUCCESS.

is_boss_dead(_SceneSt) ->
    {hook_creep_dead, [_Atker, Defer]} = dunge_util:get_event(),
    Defer#actor.rarity == ?CREEP_RARITY_BOSS2.

set_level(_SceneSt) ->
    DungeSt = #dunge_st{roles=RoleIDs} = dunge_util:get_state(),
    Level = lists:foldl(fun(RoleID, Acc) ->
        case scene_actor:get_actor(RoleID) of
            ?nil -> Acc;
            Actor -> min(Actor#actor.level, Acc)
        end
    end, 99999, RoleIDs),
    dunge_util:set_state(DungeSt#dunge_st{level=Level}),
    ?SUCCESS.

mark_question_times(_SceneSt) ->
    {hook_enter, [Actor]} = dunge_util:get_event(),
    Times = maps:get(question_times, Actor#actor.enter),
    save_question_times(Times),
    ?SUCCESS.

send_question(SceneSt) ->
    DungeSt = dunge_util:get_state(),
    #dunge_st{roles=RoleIDs} = DungeSt,
    Type = case question_times() > cfg_dunge_couple:answer_protect() of
        true -> 2;
        false -> 1
    end,
    QID = ut_rand:choose(cfg_dunge_couple_question:type(Type)),
    lists:foreach(fun(RoleID) ->
        dunge_couple:send_info(RoleID, SceneSt),
        ?ucast(RoleID, #m_dunge_question_toc{id=QID})
    end, RoleIDs),
    ?SUCCESS.

answer_timeout(_) ->
    cfg_dunge_couple:answer_timeout() + 1.

% 正常是前端超时主动选答案，这里是防止玩家意外断线，卡结算流程
auto_answer(_SceneSt) ->
    DungeSt = dunge_util:get_state(),
    #dunge_st{roles=RoleIDs} = DungeSt,
    Answers = get_answers(),
    case maps:size(Answers) =/= 2 of
        true ->
            [begin
                case maps:is_key(RoleID, get_answers()) of
                    false ->
                        save_answer(RoleID, 1);
                    true ->
                        ignore
                end
            end || RoleID <- RoleIDs],
            dunge_agent:event(hook_answer_all, ?nil);
        false ->
            ignore
    end,
    ?SUCCESS.

answer({RoleID, Answer}, _SceneSt) ->
    save_answer(RoleID, Answer),
    Answers = get_answers(),
    case maps:size(Answers) == 2 of
        true ->
            dunge_agent:event(hook_answer_all, ?nil);
        false ->
            ignore
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
question_times() ->
    case erlang:get(question_times) of
        ?nil -> 9999;
        T -> T
    end.

save_question_times(Times) ->
    erlang:put(question_times, min(question_times(), Times)).

save_answer(RoleID, Answer) ->
    Answers = get_answers(),
    erlang:put(answer, maps:put(RoleID, Answer, Answers)).

get_answers() ->
    case erlang:get(answer) of
        ?nil -> #{};
        Answers -> Answers
    end.

give_reward(RoleID, IsMatch, Gain, _SceneSt) ->
    Answers = get_answers(),
    role:route(RoleID, dunge_couple, give_reward, {IsMatch, Gain, maps:get(RoleID, Answers)}).
