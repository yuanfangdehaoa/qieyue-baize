%% @author rong
%% @doc
-module(melee_war).

-include("enum.hrl").
-include("scene.hrl").
-include("game.hrl").
-include("creep.hrl").
-include("proto.hrl").
-include("activity.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("role.hrl").
-include("item.hrl").

-export([handle/2, reward_now/2, over/1, boss_pre_notify/2]).
-export([hook_start/1, hook_stop/1, hook_init/1, hook_enter/2, hook_revive/3, hook_born/2,
    hook_fight/4, hook_role_dead/3, hook_creep_dead/3, pre_leave/2, hook_leave/2]).

-record(statis, {role_id, name, power, damage = 0, score = 0, kill = 0, total_score = 0}).

-define(VIEW_NUM, 5).

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

handle({?MELEE_INFO, RoleID}, SceneSt) ->
    #scene_st{opts=#{etime := ETime, activity := ActID}} = SceneSt,
    ?ucast(RoleID, #m_melee_info_toc{activity_id=ActID, boss_refresh=next_round(), etime=ETime}),
    notify_score(RoleID, SceneSt);

handle({?MELEE_DAMAGE_RANK, RoleID}, _SceneSt) ->
    {_, Ranks} = lists:foldl(fun(R, {Rank, Acc}) ->
        Statis = role_statis(R),
        Acc2 = if
            Statis#statis.damage > 0 ->
                [#p_melee_rank{rank=Rank, name=Statis#statis.name,
                    val=Statis#statis.damage}|Acc];
            true ->
                Acc
        end,
        {Rank+1, Acc2}
    end, {1, []}, lists:sublist(get_rank(#statis.damage), ?VIEW_NUM)),
    ?ucast(RoleID, #m_melee_damage_rank_toc{ranks = lists:reverse(Ranks)});

handle({?MELEE_SCORE_RANK, RoleID}, _SceneSt) ->
    {_, Ranks} = lists:foldl(fun(R, {Rank, Acc}) ->
        Statis = role_statis(R),
        {Rank+1, [#p_melee_rank{rank=Rank, name=Statis#statis.name, val=Statis#statis.score}|Acc]}
    end, {1, []}, lists:sublist(get_rank(#statis.score), ?VIEW_NUM)),
    ?ucast(RoleID, #m_melee_score_rank_toc{ranks = lists:reverse(Ranks)}).

% 结束发放奖励，推送结算
over(SceneSt) ->
    ?debug("destroy ~w", [scene_actor:get_actids(?ACTOR_TYPE_ROLE)]),
    reward_item(SceneSt),
    reward_total_score_rank(SceneSt),
    [begin
        Rewards = acc_reward(RoleID),
        ?ucast(RoleID, #m_melee_reward_toc{rank=final_rank(RoleID), rewards=Rewards})
    end || RoleID <- scene_actor:get_actids(?ACTOR_TYPE_ROLE)].

boss_pre_notify(Name, _SceneSt) ->
    game_notify:notify(scene_actor:get_actids(?ACTOR_TYPE_ROLE),
        ?MSG_MELEE_PRE_START, [Name, Name]).

%%-----------------------------------------------
%% scene_hook 回调函数
%%-----------------------------------------------
hook_init(SceneSt) ->
    % 初始化怪物数据
    Creeps = cfg_creep_activity:find(SceneSt#scene_st.scene),
    creep_agent:add(Creeps, SceneSt).

hook_enter(Actor, _SceneSt) ->
    #actor{uid=RoleID} = Actor,
    % 第一次进来初始化数据
    case is_first(RoleID) of
        true ->
            add_role(RoleID),
            init_role_statis(Actor);
        false ->
            ignore
    end,
    add_rank(#statis.damage, RoleID),
    add_rank(#statis.score, RoleID),
    update_actor_score(RoleID, 0).

hook_revive(Actor, _Type, _SceneSt) ->
    % 复活添加无敌BUFF
    buff_util:add_buffs(Actor, [cfg_melee:buff_unbeat()]).

hook_born(Actor, SceneSt) ->
    case Actor#actor.rarity of
        ?CREEP_RARITY_BOSS2 ->
            case get_tomb() of
                TombID when is_integer(TombID) ->
                    creep_agent:del(TombID, SceneSt);
                _ ->
                    ignore
            end,
            round_start(Actor, SceneSt);
        _ ->
            ignore
    end.

% 统计伤害
hook_fight(Atker, Defer, DmgVal, _SceneSt) when ?is_role(Atker), ?is_creep(Defer) ->
    case Defer#actor.rarity of
        ?CREEP_RARITY_BOSS2 ->
            Statis = role_statis(Atker#actor.uid),
            set_role_statis(Atker#actor.uid, #statis.damage, Statis#statis.damage+DmgVal),
            update_rank(#statis.damage);
        _ ->
            ignore
    end;
hook_fight(_Atker, _Defer, _DmgVal, _SceneSt) ->
    ignore.

%% 击杀怪
hook_creep_dead(Atker, Defer, SceneSt) when ?is_role(Atker) ->
    case Defer#actor.rarity of
        ?CREEP_RARITY_BOSS2 ->
            #actor{id = CreepID} = Defer,
            #cfg_creep{name=Name, level=Level, reborn=CountDown} = cfg_creep:find(CreepID),
            RebSec = ut_time:seconds() + CountDown div 1000,
            Coord  = Defer#actor.coord,
            Name2  = io_lib:format("~w~ts ~ts", [Level, cfg_lang:find(level), Name]),
            Opts   = #{name=>Name2, exargs=>#{"boss_reborn"=>RebSec}},
            [TombID] = creep_agent:add([{1099999,Coord,Opts}], SceneSt),
            set_tomb(TombID),
            erlang:send_after(max(CountDown - 30000, 0),
                self(), {route, ?MODULE, boss_pre_notify, Name}),
            round_end(CountDown, SceneSt);
        _ ->
            RoleID = Atker#actor.uid,
            add_score(RoleID, cfg_melee:creep_score()),
            Changes = update_rank(#statis.score),
            notify_score([RoleID|lists:delete(RoleID, Changes)], SceneSt)
    end;
hook_creep_dead(_Atker, _Defer, _SceneSt) ->
    ok.

%% 击杀玩家
hook_role_dead(Atker, Defer, SceneSt) when ?is_role(Atker) ->
    AtkRoleID = Atker#actor.uid,
    DefRoleID = Defer#actor.uid,
    Reduce = calc_reduce(AtkRoleID, DefRoleID),
    AtkScore = add_score(AtkRoleID, Reduce),
    reduce_score(DefRoleID, Reduce),
    Changes = update_rank(#statis.score),
    notify_score([AtkRoleID, DefRoleID] ++ (Changes -- [AtkRoleID, DefRoleID]), SceneSt),
    case ?is_role(Defer) of
        true ->
            clear_kill(DefRoleID),
            Kill = add_kill(AtkRoleID),
            AtkScore > 70 andalso lists:member(Kill, cfg_melee:kill()) andalso
                game_notify:notify(scene_actor:get_actids(?ACTOR_TYPE_ROLE),
                    ?MSG_MELEE_KILL, [{role, AtkRoleID, Atker#actor.name}, Kill, AtkScore]);
        false ->
            ignore
    end;
%% 怪击杀玩家
hook_role_dead(Atker, Defer, SceneSt) when ?is_creep(Atker) ->
    RoleID = Defer#actor.uid,
    reduce_score(RoleID, calc_reduce(creep, RoleID)),
    Changes = update_rank(#statis.score),
    notify_score([RoleID|lists:delete(RoleID, Changes)], SceneSt),
    clear_kill(RoleID);
hook_role_dead(_Atker, _Defer, _SceneSt) ->
    ok.

pre_leave(Actor, _SceneSt) ->
    Actor2 = Actor#actor{exargs=maps:remove("melee_score", Actor#actor.exargs)},
    scene_actor:set_actor(Actor2).

hook_leave(Actor, SceneSt) ->
    % 离开场景，积分清零
    set_role_statis(Actor#actor.uid, #statis.score, 0),
    set_role_statis(Actor#actor.uid, #statis.damage, 0),
    update_rank(#statis.damage),
    Changes = update_rank(#statis.score),
    notify_score(Changes, SceneSt).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
round_start(Boss, SceneSt) ->
    game_notify:notify(scene_actor:get_actids(?ACTOR_TYPE_ROLE),
        ?MSG_MELEE_BOSS_BORN, [Boss#actor.name]),

    reward_item(SceneSt),
    accumulate_score(),
    clear_rank(#statis.score),
    reset_all_statis(#statis.score),
    [add_rank(#statis.score, RoleID) || RoleID <- scene_actor:get_actids(?ACTOR_TYPE_ROLE)],
    set_next_round(0),
    scene_util:bc_to_scene(#m_melee_round_begin_toc{}).

% 发奖励
reward_item(SceneSt) ->
    Rank2 = lists:reverse(lists:foldl(fun(RoleId,Acc)->
                    case lists:member(RoleId,Acc) of
                        false ->
                            [RoleId | Acc];
                        _ ->
                            Acc
                    end
                end,[],get_rank(#statis.score))),
    lists:foldl(fun(RoleID, Rank) ->
        MailRewards = mail_reward(Rank, SceneSt),
        #statis{score = Score} = role_statis(RoleID),
        mail:send(RoleID, ?MAIL_MELEE_REWARD, MailRewards, [Score, Rank]),

        Rewards = reward(Rank, SceneSt),
        Exp = calc_exp(RoleID, Rank, SceneSt),
        Rewards2 = [{?ITEM_EXP, Exp} | lists:keydelete(?ITEM_PLAYER_EXP, 1, Rewards)],

        merge_reward(RoleID, Rewards2 ++ MailRewards),

        scene_actor:get_actor(RoleID) =/= ?nil andalso role:route(RoleID, ?MODULE, reward_now, Rewards2),

        Rank == 1 andalso begin
            {ok, #role_cache{name=Name}} = role:get_cache(RoleID),
            game_notify:notify(scene_actor:get_actids(?ACTOR_TYPE_ROLE),
                ?MSG_MELEE_ROUND_END, [{role, RoleID, Name}, Score])
        end,
        Rank+1
    end, 1, Rank2).

reward_now(Rewards, RoleSt) ->
    role_bag:gain(Rewards, ?LOG_MELEEWAR_REWARD, RoleSt).

% 累计玩家总积分
accumulate_score() ->
    [begin
        #statis{score = Score, total_score=Total} = role_statis(RoleID),
        set_role_statis(RoleID, #statis.total_score, Total+Score)
    end || RoleID <- role_list()].

% 最后奖励最终积分排名
reward_total_score_rank(SceneSt) ->
    SortList = lists:sort(fun(R1, R2) ->
        #statis{power = P1, total_score=V1} = role_statis(R1),
        #statis{power = P2, total_score=V2} = role_statis(R2),
        if
            V1 > V2 -> true;
            V1 == V2 -> P1 >= P2;
            true -> false
        end
    end, role_list()),
    lists:foldl(fun(RoleID, Rank) ->
        save_final_rank(RoleID, Rank),
        MailRewards = final_mail_reward(Rank, SceneSt),
        #statis{total_score = Score} = role_statis(RoleID),
        {ok, #role_cache{level=Level}} = role:get_cache(RoleID),
        Rewards = game_util:transform_gain(Level, MailRewards),
        mail:send(RoleID, ?MAIL_MELEE_FINAL_REWARD, Rewards, [Score, Rank]),

        merge_reward(RoleID, Rewards),

        Rank+1
    end, 1, SortList).

round_end(CountDown, SceneSt) ->
    reward_score(SceneSt),
    clear_rank(#statis.damage),
    reset_all_statis(#statis.damage),
    [add_rank(#statis.damage, RoleID) || RoleID <- scene_actor:get_actids(?ACTOR_TYPE_ROLE)],
    set_next_round(ut_time:seconds() + CountDown div 1000),
    scene_util:bc_to_scene(#m_melee_round_end_toc{boss_refresh = next_round()}).

reward_score(SceneSt) ->
    % boss伤害的排名奖励
    lists:foldl(fun(RoleID, Rank) ->
        #statis{damage = Damage} = role_statis(RoleID),
        Damage > 0 andalso add_score(RoleID, cfg_melee_damage:find(Rank)),
        Rank+1
    end, 1, get_rank(#statis.damage)),
    update_rank(#statis.score),
    notify_score(get_rank(#statis.score), SceneSt).

next_round() ->
    case erlang:get({?MODULE, next_round}) of
        ?nil -> 0;
        NextRound -> NextRound
    end.

set_next_round(NextRound) ->
    erlang:put({?MODULE, next_round}, NextRound).

role_list() ->
    case erlang:get({?MODULE, role_list}) of
        ?nil -> [];
        List -> List
    end.

add_role(RoleID) ->
    erlang:put({?MODULE, role_list}, [RoleID|lists:delete(RoleID, role_list())]).

is_first(RoleID) ->
    not lists:member(RoleID, role_list()).

init_role_statis(Actor) ->
    erlang:put({statis, Actor#actor.uid}, #statis{
        role_id = Actor#actor.uid,
        name    = Actor#actor.name,
        power   = Actor#actor.power
    }).

role_statis(RoleID) ->
    erlang:get({statis, RoleID}).

set_role_statis(RoleID, Pos, Val) ->
    Statis = erlang:get({statis, RoleID}),
    erlang:put({statis, RoleID}, setelement(Pos, Statis, Val)),
    Pos == #statis.score andalso update_actor_score(RoleID, Val).

update_actor_score(RoleID, Score) ->
    case scene_actor:get_actor(RoleID) of
        Actor = #actor{exargs=ExArgs} ->
            ExArgs2 = maps:put("melee_score", Score, ExArgs),
            scene_actor:set_actor(Actor#actor{exargs=ExArgs2}),
            Toc = #m_actor_update_toc{uid=RoleID, upint=#{"ext.melee_score" => Score}},
            scene_util:bc_to_grid(Actor#actor.coord, Toc);
        _ ->
            ignore
    end.

reset_all_statis(Pos) ->
    [set_role_statis(RoleID, Pos, 0) || RoleID <- role_list()].

update_rank(Pos) ->
    Ranks = lists:sort(fun(R1, R2) ->
        #statis{power = P1} = S1 = role_statis(R1),
        #statis{power = P2} = S2 = role_statis(R2),
        V1 = element(Pos, S1),
        V2 = element(Pos, S2),
        if
            V1 > V2 -> true;
            V1 == V2 -> P1 >= P2;
            true -> false
        end
    end, get_rank(Pos)),
    Changes = find_rank_change(get_rank(Pos), Ranks),
    erlang:put({?MODULE, Pos}, Ranks),
    Changes.

find_rank_change(Ranks1, Ranks2) ->
    Changes = find_rank_change(Ranks1, Ranks2, []),
    lists:usort(Changes).

find_rank_change([], [], Changes) ->
    Changes;
find_rank_change([], T2, Changes) ->
    T2 ++ Changes;
find_rank_change(T1, [], Changes) ->
    T1 ++ Changes;
find_rank_change([H|T1], [H|T2], Changes) ->
    find_rank_change(T1, T2, Changes);
find_rank_change([H1|T1], [H2|T2], Changes) ->
    find_rank_change(T1, T2, [H1, H2 | Changes]).

add_rank(Pos, RoleID) ->
    Ranks = get_rank(Pos),
    case lists:member(RoleID, Ranks) of
        false ->
            erlang:put({?MODULE, Pos}, get_rank(Pos) ++ [RoleID]);
        true ->
            ignore
    end.

clear_rank(Pos) ->
    erlang:erase({?MODULE, Pos}).

get_rank(Pos) ->
    case erlang:get({?MODULE, Pos}) of
        ?nil -> [];
        Ranks -> Ranks
    end.

add_score(RoleID, Score) ->
    Statis = role_statis(RoleID),
    MaxScore = cfg_melee:max_score(),
    FinalScore = min(MaxScore, Statis#statis.score+Score),
    set_role_statis(RoleID, #statis.score, FinalScore),
    FinalScore.

calc_reduce(creep, DefRoleID) ->
    #statis{score = DefScore} = role_statis(DefRoleID),
    MinScore = cfg_melee:min_score(),
    min(DefScore div 2, max(0, DefScore - MinScore));
calc_reduce(AtkRoleID, DefRoleID) ->
    #statis{score = AtkScore} = role_statis(AtkRoleID),
    #statis{score = DefScore} = role_statis(DefRoleID),
    MaxScore = cfg_melee:max_score(),
    MinScore = cfg_melee:min_score(),
    min(min(DefScore div 2, max(0, DefScore - MinScore)), MaxScore-AtkScore).

reduce_score(RoleID, Score) ->
    Statis = role_statis(RoleID),
    FinalScore = max(0, Statis#statis.score - Score),
    set_role_statis(RoleID, #statis.score, FinalScore).

notify_score(RoleID, SceneSt) when is_integer(RoleID) ->
    case scene_actor:get_actor(RoleID) of
        ?nil  ->
            ignore;
        _ ->
            Statis1 = role_statis(RoleID),
            Rank = rank(RoleID, #statis.score),
            ?ucast(RoleID, #m_melee_self_toc{
                rank=Rank, score=Statis1#statis.score, exp=calc_exp(RoleID, Rank, SceneSt)})
    end;
notify_score(RoleList, SceneSt) when is_list(RoleList) ->
    lists:foreach(fun(RoleID) -> notify_score(RoleID, SceneSt) end, RoleList).

rank(RoleID, Pos) ->
    Ranks = get_rank(Pos),
    rank(RoleID, Ranks, 1).

rank(_RoleID, [], Rank) ->
    Rank;
rank(RoleID, [RoleID|_], Rank) ->
    Rank;
rank(RoleID, [_|T], Rank) ->
    rank(RoleID, T, Rank+1).

merge_reward(RoleID, Rewards) ->
    Save = acc_reward(RoleID),
    Save2 = lists:foldl(fun({ItemID, Num}, Acc) ->
        Old = maps:get(ItemID, Acc, 0),
        maps:put(ItemID, Num+Old, Acc)
    end, Save, Rewards),
    erlang:put({acc_reward, RoleID}, Save2).

acc_reward(RoleID) ->
    case erlang:get({acc_reward, RoleID}) of
        ?nil -> #{};
        Acc -> Acc
    end.

save_final_rank(RoleID, Rank) ->
    erlang:put({final_rank, RoleID}, Rank).

final_rank(RoleID) ->
    case erlang:get({final_rank, RoleID}) of
        ?nil -> 0;
        Rank -> Rank
    end.

add_kill(RoleID) ->
    Statis = role_statis(RoleID),
    set_role_statis(RoleID, #statis.kill, Statis#statis.kill + 1),
    Statis#statis.kill + 1.

clear_kill(RoleID) ->
    set_role_statis(RoleID, #statis.kill, 0).

get_tomb() ->
    erlang:get({?MODULE, tomb}).

set_tomb(Tomb) ->
    erlang:put({?MODULE, tomb}, Tomb).

calc_exp(RoleID, Rank, SceneSt) ->
    {ok, #role_cache{level=Level}} = role:get_cache(RoleID),
    #cfg_exp_acti_base{role_exp=RoleExp} = cfg_exp_acti_base:find(Level),
    Num = proplists:get_value(?ITEM_PLAYER_EXP, reward(Rank, SceneSt), 0),
    trunc(Num * RoleExp).

reward(Rank, SceneSt) ->
    #scene_st{opts=#{mode := Mode}} = SceneSt,
    cfg_melee_score:reward(Mode, Rank).

mail_reward(Rank, SceneSt) ->
    #scene_st{opts=#{mode := Mode}} = SceneSt,
    cfg_melee_score:mail_reward(Mode, Rank).

final_mail_reward(Rank, SceneSt) ->
    #scene_st{opts=#{mode := Mode}} = SceneSt,
    cfg_melee_score:final_mail_reward(Mode, Rank).
