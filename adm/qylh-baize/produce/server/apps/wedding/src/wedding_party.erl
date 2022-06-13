%% @author rong
%% @doc
-module(wedding_party).

-include("activity.hrl").
-include("creep.hrl").
-include("game.hrl").
-include("item.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").
-include("table.hrl").

-export([hook_start/1, hook_stop/1, handle/2, create_coll/2, over/1]).
-export([pre_enter/3, pre_collect/3, finish_collect/3]).
-export([hook_init/1, hook_enter/2, hook_loopsec/2]).

-record(wedding_role, {role_id, exp=0, food=0, candy=0, fetch=[]}).

hook_start(ActID) ->
    ?debug("=======start ~w", [ActID]),
    #activity{stime=STime, etime=ETime} = activity:activity(ActID),
    Pid = wedding_ets:pid(STime, ETime),
    wedding_agent:start_wedding(Pid).

hook_stop(ActID) ->
    ?debug("=======stop ~w", [ActID]),
    #cfg_activity{scene = SceneID} = cfg_activity:find(ActID),
    scene:route(SceneID, ?MODULE, over),
    #activity{stime=STime, etime=ETime} = activity:activity(ActID),
    Pid = wedding_ets:pid(STime, ETime),
    wedding_agent:stop_wedding(Pid).

handle({use_firework, RoleID, RoleName, ItemID, Num}, SceneSt) ->
    #cfg_item{effect=Add} = cfg_item:find(ItemID),
    AddHot  = trunc(Add*Num),
    RoleIDs = scene_actor:get_actids(?ACTOR_TYPE_ROLE),
    ?notify(RoleIDs, ?MSG_MARRIAGE_FIREWORK, [
        {role,RoleID,RoleName},
        {item,#{ItemID=>Num}},
        AddHot
    ]),
    add_hot(AddHot, SceneSt);

handle({info, RoleID}, SceneSt) ->
    notify_info(RoleID, SceneSt);

handle({exp, RoleID}, _SceneSt) ->
    #wedding_role{exp=Exp} = get_info(RoleID),
    ?ucast(RoleID, #m_wedding_party_exp_toc{exp=Exp});

handle({fetch, RoleID, Lv}, SceneSt) ->
    Reward = cfg_marriage_hot:find(Lv),
    #wedding_role{fetch=Fetch} = WeddingRole = get_info(RoleID),
    case lists:member(Lv, Fetch) of
        true ->
            ?ucast(RoleID, #m_game_error_toc{errno=?ERR_WEDDING_PARTY_ALREADY_FETCH});
        false ->
            case hot() >= Lv of
                true ->
                    set_info(WeddingRole#wedding_role{fetch=[Lv|Fetch]}),
                    role:route(RoleID, wedding_handler, fetch_succ, Reward),
                    notify_info(RoleID, SceneSt);
                false ->
                    ?ucast(RoleID, #m_game_error_toc{errno=?ERR_WEDDING_HOT_NOT_MEET})
            end
    end.

create_coll(Creeps, SceneSt) ->
    creep_agent:add(Creeps, SceneSt).

over(SceneSt) ->
    #scene_st{opts=Opts} = SceneSt,
    #{couple := Couple} = Opts,
    Names = lists:map(fun(ID) ->
        {ok, Cache} = role:get_cache(ID),
        Cache#role_cache.name
    end, Couple),
    MaxLv = cur_lv(hot()),
    lists:foreach(fun(RoleID) ->
        #wedding_role{fetch=Fetch} = get_info(RoleID),
        Remains = cfg_marriage_hot:all() -- Fetch,
        Rewards = lists:foldl(fun(Lv, Acc) ->
            case Lv =< MaxLv of
                true ->
                    cfg_marriage_hot:find(Lv) ++ Acc;
                false ->
                    Acc
            end
        end, [], Remains),
        Rewards =/= [] andalso mail:send(RoleID, ?MAIL_WEDDING_PARTY, Rewards, Names)
    end, all_roles()).

%%-----------------------------------------------
%% scene_hook 回调函数
%%-----------------------------------------------
%% 玩家进入场景前
pre_enter(_SceneID, _Args, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    case wedding_ets:current() of
        [Wedding|_] ->
            #wedding{time={StartTime, EndTime}, invite=Invite, couple=Couple} = Wedding,
            Now = ut_time:seconds(),
            ?_check(Now >= StartTime andalso EndTime > Now, ?ERR_WEDDING_NOT_START),
            ?_check(lists:member(RoleID, Invite) orelse
                lists:member(RoleID, Couple), ?ERR_WEDDING_NOT_INVITED),
            ok;
        _ ->
            throw(?err(?ERR_WEDDING_NOT_START))
    end.

pre_collect(Actor, Collect, _SceneSt) ->
    #actor{uid=RoleID} = Actor,
    #wedding_role{food=Food, candy=Candy} = get_info(RoleID),
    FoodID = food_id(),
    CandyID = candy_id(),
    case Collect of
        #actor{id=FoodID} ->
            ?_check(Food < cfg_marriage:food_limit(), ?ERR_WEDDING_MAX_FOOD);
        #actor{id=CandyID} ->
            ?_check(Candy < cfg_marriage:candy_limit(), ?ERR_WEDDING_MAX_CANDY);
        _ ->
            ok
    end.

% 采集完
finish_collect(Actor, Collect, SceneSt) ->
    FoodID = food_id(),
    CandyID = candy_id(),
    #actor{uid=RoleID} = Actor,
    case Collect of
        #actor{id=FoodID} ->
            add_hot(cfg_marriage:food_add(), SceneSt),
            NewVal = update_info(RoleID, #wedding_role.food, '+', 1),
            notify_info(RoleID, SceneSt),
            ?notify(RoleID, ?MSG_WEDDING_COLLECT, [NewVal, cfg_marriage:food_limit()]),
            IsNoFood = not lists:any(fun(ID) ->
                #actor{id=FID} = scene_actor:get_actor(ID),
                FoodID == FID
            end, scene_actor:get_actids(?ACTOR_TYPE_CREEP)),
            #cfg_creep{reborn=Reborn} = cfg_creep:find(FoodID),
            IsNoFood andalso erlang:send_after(Reborn, self(),
                {route, ?MODULE, create_coll, cfg_marriage:food()});
        #actor{id=CandyID} ->
            IsNoCandy = not lists:any(fun(ID) ->
                #actor{id=FID} = scene_actor:get_actor(ID),
                CandyID == FID
            end, scene_actor:get_actids(?ACTOR_TYPE_CREEP)),
            IsNoCandy andalso set_refresh(false, SceneSt),
            NewVal = update_info(RoleID, #wedding_role.candy, '+', 1),
            notify_info(RoleID, SceneSt),
            ?notify(RoleID, ?MSG_WEDDING_COLLECT, [NewVal, cfg_marriage:candy_limit()]),
            add_hot(cfg_marriage:candy_add(), SceneSt);
        _ ->
            ignore
    end.

hook_init(SceneSt) ->
    % 创建美食
    creep_agent:add(cfg_marriage:food(), SceneSt).

hook_enter(Actor, _SceneSt) ->
    #actor{uid=RoleID} = Actor,
    add_role(RoleID),
    case get_info(RoleID) of
        ?nil ->
            WeddingRole = #wedding_role{role_id=RoleID},
            erlang:put({?MODULE, RoleID}, WeddingRole);
        _ ->
            ignore
    end.

hook_loopsec(NowSec, _SceneSt) ->
    case erlang:get({?MODULE, next_add_time}) of
        NextSec when NextSec == ?nil ; (is_integer(NextSec) andalso NowSec >= NextSec) ->
            erlang:put({?MODULE, next_add_time}, NowSec+cfg_marriage:exp_interval()),
            [begin
                #actor{level=Level} = scene_actor:get_actor(RoleID),
                #cfg_exp_acti_base{role_exp=RoleExp} = cfg_exp_acti_base:find(Level),
                Coef = cfg_marriage:exp_coef(),
                Exp = trunc(RoleExp*Coef),
                role:add_exp(RoleID, Exp, ?LOG_WEDDING_PARTY),
                update_info(RoleID, #wedding_role.exp, '+', Exp)
            end || RoleID <- scene_actor:get_actids(?ACTOR_TYPE_ROLE)];
        _ ->
            ignore
    end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
all_roles() ->
    case erlang:get({?MODULE, all_roles}) of
        ?nil -> [];
        List -> List
    end.

add_role(RoleID) ->
    erlang:put({?MODULE, all_roles}, [RoleID|all_roles()]).

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
    set_info(Info2),
    FinVal.

set_info(WeddingRole) ->
    erlang:put({?MODULE, WeddingRole#wedding_role.role_id}, WeddingRole).

food_id() ->
    element(1, hd(cfg_marriage:food())).

candy_id() ->
    element(1, hd(cfg_marriage:candy())).

hot() ->
    case erlang:get({?MODULE, hot}) of
        ?nil -> 0;
        Hot -> Hot
    end.

add_hot(Add, SceneSt) ->
    Pre = hot(),
    Hot = min(cfg_marriage_hot:max(), hot() + Add),
    erlang:put({?MODULE, hot}, Hot),
    Pre =/= Hot andalso bc(#m_wedding_party_hot_toc{hot=Hot}),
    Lv = cur_lv(Hot),
    Lv > Pre andalso begin
        set_refresh(true, SceneSt),
        create_coll(cfg_marriage:candy(), SceneSt),
        RoleIDs = scene_actor:get_actids(?ACTOR_TYPE_ROLE),
        ?notify(RoleIDs, ?MSG_MARRIAGE_HOT, [Hot])
    end.

% 当前热度达到的档位
cur_lv(Hot) ->
    cur_lv_2(Hot, cfg_marriage_hot:all(), 0).

cur_lv_2(_, [], Lv) ->
    Lv;
cur_lv_2(Hot, [Lv |T], Acc) ->
    if
        Hot > Lv ->
            cur_lv_2(Hot, T, Lv);
        Hot == Lv ->
            Lv;
        true ->
            Acc
    end.

is_refresh() ->
    case erlang:get({?MODULE, refresh}) of
        ?nil -> false;
        Val -> Val
    end.

set_refresh(Val, SceneSt) ->
    erlang:put({?MODULE, refresh}, Val),
    [notify_info(RoleID, SceneSt) || RoleID <- scene_actor:get_actids(?ACTOR_TYPE_ROLE)].

bc(Msg) ->
    ?bcast(scene_actor:get_actids(?ACTOR_TYPE_ROLE), Msg).

notify_info(RoleID, SceneSt) ->
    WeddingRole = get_info(RoleID),
    ?ucast(RoleID, #m_wedding_party_info_toc{
        etime   = maps:get(end_time, SceneSt#scene_st.opts),
        exp     = WeddingRole#wedding_role.exp,
        food    = WeddingRole#wedding_role.food,
        candy   = WeddingRole#wedding_role.candy,
        hot     = hot(),
        fetch   = WeddingRole#wedding_role.fetch,
        refresh = is_refresh()
    }).
