%% @author rong
%% @doc
-module(dunge_race).

-include("game.hrl").
-include("table.hrl").
-include("proto.hrl").
-include("errno.hrl").
-include("dunge.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("scene.hrl").
-include("log.hrl").

-export([create_opts/2]).
-export([get_entry/1]).
-export([handle/2]).
-export([send_info/2]).
-export([reward/2]).
-export([add_enter_times/0,
    check_enter_times/0,
    check_enter_times/1]).

-define(SCENE_STYPE, ?SCENE_STYPE_DUNGE_RACE).

create_opts(_Entry, _RoleSt) ->
    #role_dunge{misc=AllMisc} = role_data:get(?DB_ROLE_DUNGE),
    Misc = maps:get(?SCENE_STYPE, AllMisc, #{}),
    BestRecord = maps:get(best_record, Misc, 0),
    EnterTimes = maps:get(enter_times, Misc, 1),
    #{best_record => BestRecord, enter_times => EnterTimes, 
        rest_times => max(0, dunge_util:rest_times(?SCENE_STYPE) - 1)}.

% 设置出生点
get_entry(_RoleSt) ->
    {X, Y} = cfg_dunge_race_path:start_point(2),
    #{coord=>#p_coord{x=X, y=Y}, room => ut_time:seconds()}.

handle(?DUNGE_PANEL, RoleSt) ->
    #cfg_dunge_enter{times=MaxTimes} = cfg_dunge:enter(?SCENE_STYPE),
    ?ucast(#m_dunge_panel_toc{
        stype = ?SCENE_STYPE,
        id    = dunge_util:get_dunge(?SCENE_STYPE),
        info  = #{
            "max_times"  => MaxTimes,
            "buy_times"  => role_count:get_scene_buy(?SCENE_STYPE),
            "rest_times" => dunge_util:rest_times(?SCENE_STYPE)
        }
    });

handle({?DUNGE_RACE_RESULT, Tos}, RoleSt) ->
    #m_dunge_race_result_tos{is_finish=IsFinish, rank=Rank, time=Time} = Tos,
    case IsFinish of
        true ->
            #role_dunge{misc=AllMisc} = RoleDunge = role_data:get(?DB_ROLE_DUNGE),
            Misc = maps:get(?SCENE_STYPE, AllMisc, #{}),
            BestRecord = maps:get(best_record, Misc, 9999),
            Misc2 = maps:put(best_record, min(BestRecord, Time), Misc),
            AllMisc2 = maps:put(?SCENE_STYPE, Misc2, AllMisc),
            role_data:set(RoleDunge#role_dunge{misc=AllMisc2});
        false ->
            ignore
    end,
    #role_st{spid=ScenePid} = RoleSt,
    scene:route(ScenePid, dunge_race_dungeai, upload_result, {IsFinish, Rank}).

send_info(RoleID, SceneSt) ->
    DungeSt = dunge_util:get_state(),
    ?ucast(RoleID, #m_dunge_info_toc{
        stype = SceneSt#scene_st.stype,
        id    = SceneSt#scene_st.dunge,
        info  = #{
            "prep_time"    => DungeSt#dunge_st.ptime,
            "end_time"     => SceneSt#scene_st.etime,
            "best_record"  => maps:get(best_record, SceneSt#scene_st.opts, 0),
            "enter_times"  => max(1, maps:get(enter_times, SceneSt#scene_st.opts, 1)),
            "rest_times"   => maps:get(rest_times, SceneSt#scene_st.opts, 0)
        }
    }).

reward(Rewards, RoleSt) ->
    role_bag:gain(Rewards, ?LOG_DUNGE_RACE, RoleSt).

-define(ENTER_TIMES, enter_times).
-define(ENTER_UNIXTIME, enter_unixtime).
-define(ENTER_MAXTIMES_DAY, 6).    %% 一天最大进入5次

add_enter_times() ->
    #role_dunge{misc=AllMisc} = RoleDunge = role_data:get(?DB_ROLE_DUNGE),
    Misc = maps:get(?SCENE_STYPE, AllMisc, #{}),
    EnterTimes = maps:get(?ENTER_TIMES, Misc, 0),
    Misc2 = maps:put(?ENTER_TIMES, EnterTimes+1, Misc),
    Misc3 = maps:put(?ENTER_UNIXTIME, ut_time:seconds(), Misc2),
    AllMisc2 = maps:put(?SCENE_STYPE, Misc3, AllMisc),
    role_data:set(RoleDunge#role_dunge{misc=AllMisc2}).


check_enter_times() ->
    check_enter_times(0).

check_enter_times(ExtraNum) ->
    RoleDunge = #role_dunge{misc = AllMisc} = role_data:get(?DB_ROLE_DUNGE),
    Misc = maps:get(?SCENE_STYPE, AllMisc, #{}),
    EnterTimes = maps:get(?ENTER_TIMES, Misc, 0),
    EnterUnixtime = maps:get(?ENTER_UNIXTIME, Misc, 0),
    Unixtime = ut_time:seconds(),
    case ut_time:is_same_date(Unixtime, EnterUnixtime) of
        true ->
            EnterTimes < (?ENTER_MAXTIMES_DAY + ExtraNum);
        false ->
            Misc2 = maps:put(?ENTER_TIMES, 1, Misc),
            Misc3 = maps:put(?ENTER_UNIXTIME, Unixtime, Misc2),
            AllMisc2 = maps:put(?SCENE_STYPE, Misc3, AllMisc),
            role_data:set(RoleDunge#role_dunge{misc = AllMisc2}),
            true
    end.