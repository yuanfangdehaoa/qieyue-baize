%% @author rong
%% @doc

-module(dunge_arena_dungeai).

-include("arena.hrl").
-include("attr.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("btree.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

-export([init/1]).
-export([enter/1]).
-export([rush/1, rush/2]).
-export([timeout_judge/2]).
-export([skip_judge/1]).
-export([skip_result/2]).
-export([stat/1]).

-record(result, {winner, loser}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init(SceneSt) ->
    arena_robot:summon(SceneSt),
    ?SUCCESS.

enter(SceneSt) ->
    add_buff(SceneSt),
    ?SUCCESS.

rush(SceneSt) ->
    Defender = get_defender(SceneSt),
    Actor = scene_actor:get_actor(Defender#p_arena.id),
    creep_agent:event(Actor, hook_enter, ?nil),
    Attacker = get_attacker(SceneSt),
    {X, Y} = cfg_arena:rush(),
    Dest = #p_coord{x=X, y=Y},
    role:route(Attacker#p_arena.id, ?MODULE, rush, Dest),
    ?SUCCESS.

rush(Dest, RoleSt) ->
    scene_handler:handle(?SCENE_RUSH, #m_scene_rush_tos{coord=Dest}, RoleSt).

timeout_judge(IsWin, SceneSt) ->
    Attacker = get_attacker(SceneSt),
    Defender = get_defender(SceneSt),
    AttActor = scene_actor:get_actor(Attacker#p_arena.id),
    DefActor = scene_actor:get_actor(Defender#p_arena.id),
    IsAttWin = case {AttActor, DefActor} of
        {_, ?nil} ->
            true;
        {?nil, _} ->
            false;
        _ ->
            AttHp = ?_attr(AttActor#actor.attr, ?ATTR_HP),
            DefHp = ?_attr(DefActor#actor.attr, ?ATTR_HP),
            AttHp > DefHp
    end,
    if
        IsAttWin == IsWin -> ?SUCCESS;
        true -> ?FAILURE
    end.

skip_judge(SceneSt) ->
    case get_result() of
        ?nil ->
            Attacker = get_attacker(SceneSt),
            Defender = get_defender(SceneSt),
            case arena_util:is_skip_win(Attacker, Defender) of
                true ->
                    save_result(Attacker, Defender);
                false ->
                    save_result(Defender, Attacker)
            end,
            ?SUCCESS;
        _ ->
            ?FAILURE
    end.

skip_result(IsWin, SceneSt) ->
    #result{winner=Winner} = get_result(),
    Attacker = get_attacker(SceneSt),
    IsAttWin = Attacker#p_arena.id == Winner#p_arena.id,
    if
        IsAttWin == IsWin -> ?SUCCESS;
        true -> ?FAILURE
    end.

stat(SceneSt) ->
    DungeSt = dunge_util:get_state(),
    #dunge_st{clear=Clear} = DungeSt,
    Attacker = get_attacker(SceneSt),
    Defender = get_defender(SceneSt),
    if
        Clear -> save_result(Attacker, Defender);
        true ->  save_result(Defender, Attacker)
    end,

    Actor = scene_actor:get_actor(Defender#p_arena.id),
    creep_agent:event(Actor, hook_scene_over, ?nil),
    notify_result(Attacker, SceneSt),
    dunge_ai:clear_sleep(),
    ?SUCCESS.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
get_result() ->
    erlang:get({?MODULE, result}).

save_result(Winner, Loser) ->
    erlang:put({?MODULE, result}, #result{winner=Winner, loser=Loser}).

get_defender(SceneSt) ->
    #scene_st{opts=Opts} = SceneSt,
    maps:get(defender, Opts).

get_attacker(SceneSt) ->
    #scene_st{opts=Opts} = SceneSt,
    maps:get(attacker, Opts).

notify_result(Attacker, SceneSt) ->
    #result{winner=Winner, loser=Loser} = get_result(),
    #scene_st{opts=Opts} = SceneSt,
    Challenge = maps:get(challenge, Opts),
    arena_util:notify_result(Attacker, Winner, Loser, Challenge).

add_buff(SceneSt) ->
    {_, [Actor]} = dunge_util:get_event(),
    Attacker = get_attacker(SceneSt),
    Defender = get_defender(SceneSt),
    Diff = arena_util:calc_power_diff(Attacker, Defender),
    case cfg_arena_suppress:find(Diff) of
        BuffIDs when is_list(BuffIDs) ->
            buff_util:add_buffs(Actor, BuffIDs);
        _ ->
            ignore
    end.
