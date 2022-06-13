%% @author rong
%% @doc 
-module(dunge_race_dungeai).

-include("scene.hrl").
-include("game.hrl").
-include("btree.hrl").
-include("enum.hrl").
-include("dunge.hrl").
-include("proto.hrl").
-include("errno.hrl").
-include("role.hrl").

-export([upload_result/2]).
-export([stat/1]).

upload_result({IsFinish, Rank}, _SceneSt) ->
    erlang:put(rank, Rank),
    erlang:put(is_finish, IsFinish).

stat(SceneSt) ->
    #dunge_st{roles=[RoleID], level=Level} = dunge_util:get_state(),
    IsClear = erlang:get(is_finish) == true,
    Rank = case erlang:get(rank) of
        undefined -> 3;
        Rank0 -> Rank0
    end,
    {ok, #role_cache{level=RoleLv}} = role:get_cache(RoleID),
    Rewards = game_util:transform_gain(RoleLv, cfg_dunge_race_reward:find(Level, Rank)),
    case role:is_alive(RoleID) of
        true ->
            role:route(RoleID, dunge_race, reward, Rewards);
        false ->
            mail:send(RoleID, ?MAIL_DUNGE_RACE, Rewards, [Rank])
    end,
    ?ucast(RoleID, #m_dunge_over_toc{
        stype  = SceneSt#scene_st.stype,
        id     = SceneSt#scene_st.dunge,
        clear  = IsClear,
        reward = to_map(Rewards)
    }),
    ?SUCCESS.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
to_map(Rewards) ->
    maps:from_list(lists:map(fun
        ({ItemID, Num}) -> {ItemID, Num};
        ({ItemID, Num, _}) -> {ItemID, Num}
    end, Rewards)).
