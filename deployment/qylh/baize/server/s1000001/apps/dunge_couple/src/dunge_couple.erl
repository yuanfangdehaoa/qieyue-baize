%% @author rong
%% @doc 
-module(dunge_couple).

-include("dunge.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("errno.hrl").
-include("table.hrl").

-export([handle/2, send_info/2, buy_times/2, give_reward/2, ask_buy_times/2,
    couple_buy_succ/2]).

%% 副本面板
handle(?DUNGE_PANEL, RoleSt) ->
    #cfg_dunge_enter{times=MaxTimes} = cfg_dunge:enter(?SCENE_STYPE_DUNGE_COUPLE),
    ?ucast(#m_dunge_panel_toc{
        stype = ?SCENE_STYPE_DUNGE_COUPLE,
        id    = 0,
        info  = #{
            "max_times"  => MaxTimes,
            "buy_times"  => role_count:get_scene_buy(?SCENE_STYPE_DUNGE_COUPLE),
            "rest_times" => dunge_util:rest_times(?SCENE_STYPE_DUNGE_COUPLE)
        }
    });

handle({?DUNGE_QUESTION_ANSWER, SType, Answer}, RoleSt) ->
    #role_st{spid=ScenePid, role=RoleID} = RoleSt,
    scene:route(ScenePid, dunge_couple_dungeai, answer, {RoleID, Answer}),
    ?ucast(#m_dunge_question_answer_toc{stype=SType, answer=Answer});

handle({?DUNGE_BUY_TIMES_ASK, SType}, RoleSt) ->
    #role_st{role=RoleID, name=Name} = RoleSt,
    MarryWith = role_marriage:marry_with(RoleID),
    ?_check(MarryWith > 0, ?ERR_MARRIAGE_NOT_MARRY),
    ?_check(role:is_online(MarryWith), ?ERR_DUNGE_COUPLE_NOT_ONLINE),
    role:route(MarryWith, ?MODULE, ask_buy_times, {SType, Name}).

ask_buy_times({SType, Name}, RoleSt) ->
    #role_st{scene=SceneId} = RoleSt,
    MaxBuyTimes = cfg_dunge_couple:buy_times(),
    BuyTimes = role_count:get_scene_buy(?SCENE_STYPE_DUNGE_COUPLE),
    BuyTimeCheck = MaxBuyTimes > BuyTimes,
    #cfg_scene{type=Type} = cfg_scene:find(SceneId),
    SceneCheck = (Type == ?SCENE_TYPE_CITY orelse Type == ?SCENE_TYPE_FIELD),
    case BuyTimeCheck andalso SceneCheck of
        true ->
            ?ucast(#m_dunge_buy_times_ask_toc{stype=SType, ask_name=Name});
        false ->
            ignore
    end.

send_info(RoleID, SceneSt) ->
    DungeSt = dunge_util:get_state(),
    ?ucast(RoleID, #m_dunge_info_toc{
        stype = ?SCENE_STYPE_DUNGE_COUPLE,
        id    = SceneSt#scene_st.scene,
        info  = #{
            "prep_time" => DungeSt#dunge_st.ptime,
            "end_time"  => SceneSt#scene_st.etime
        },
        count = DungeSt#dunge_st.kill
    }).

buy_times(SType, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    CurBuyTimes = role_count:get_scene_buy(SType),
    IsMarried = role_marriage:is_married(RoleID),
    ?_check(IsMarried, ?ERR_DUNGE_BUY_TIMES_NEED_MARRIED),
    MaxBuyTimes = cfg_dunge_couple:buy_times(),
    ?_check(CurBuyTimes < MaxBuyTimes, ?ERR_DUNGE_MAX_BUY_TIMES),
    #cfg_dunge_enter{buy=BuyCost} = cfg_dunge:enter(SType),
    role_bag:cost(BuyCost, ?LOG_DUNGE_BUY_ENTER, RoleSt),
    role_count:add_scene_buy(SType),
    ?ucast(#m_dunge_buytimes_toc{stype=SType}),
    MarryWith = role_marriage:marry_with(RoleID),
    role:route(MarryWith, ?MODULE, couple_buy_succ, SType, {ut_time:date(), SType}),
    log_api:log_dunge(0, SType, ?DUNGE_OP_BUY_TIMES, 1, RoleSt).

couple_buy_succ({Date, SType}, RoleSt) ->
    case Date == ut_time:date() of
        true ->
            couple_buy_succ(SType, RoleSt);
        false ->
            ignore
    end;
couple_buy_succ(SType, RoleSt) ->
    role_count:add_scene_ask_buy(SType),
    handle(?DUNGE_PANEL, RoleSt).

give_reward({IsMatch, Gain, Answer}, RoleSt) ->
    ProgNew = lists:foldl(fun(Gender, Prog0) ->
        Prog1 = ut_misc:maps_increase(Gender, cfg_dunge_couple:base(), Prog0),
        case IsMatch andalso Answer == Gender of
            true -> ut_misc:maps_increase(Gender, cfg_dunge_couple:extra(), Prog1);
            false -> Prog1
        end
    end, #{}, [?GENDER_MALE, ?GENDER_FEMALE]),
    baby_handler:add_baby_progress(ProgNew, RoleSt),
    role_bag:gain(Gain, ?LOG_DUNGE_COUPLE, RoleSt).
