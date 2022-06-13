%% @author rong
%% @doc
-module(yunying_dunge_limit_tower).

-include("table.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("role.hrl").
-include("errno.hrl").
-include("enum.hrl").
-include("scene.hrl").
-include("dunge.hrl").
-include("yunying.hrl").
-include("btree.hrl").

-export([handle/2]).
-export([get_entry/1]).
-export([check_captain/2]).
-export([send_info/1]).
-export([send_info/2]).
-export([is_fail/1]).
-export([stat_one/1]).
-export([stat/1]).
-export([give_reward/2]).
-export([get_clr_floor/1]).

-define(SCENE_STYPE, ?SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER).

%% 副本面板
handle(?DUNGE_PANEL, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    YYActID = yy_actid(),
    #yy_role{extra=Extra} = yunying_agent:get_yy_role(YYActID, RoleID),
    ClrFloor = maps:get(clear_floor, Extra, 0),
    MaxFloor = cfg_yunying_dunge_limit_tower:max_floor(YYActID),
    case ClrFloor == MaxFloor of
        true  ->
            DungeID = 0;
        false ->
            CfgMagic = cfg_yunying_dunge_limit_tower:find(YYActID, ClrFloor+1),
            #cfg_yunying_dunge_limit_tower{dunge=DungeID} = CfgMagic
    end,
    ?ucast(#m_dunge_panel_toc{
        stype = ?SCENE_STYPE,
        id    = DungeID,
        clear = ClrFloor == MaxFloor,
        info  = #{
            "cur_floor"  => ClrFloor + 1
        }
    }).

get_entry(RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    YYActID = yy_actid(),
    #yy_role{extra=Extra} = yunying_agent:get_yy_role(YYActID, RoleID),
    ClrFloor = maps:get(clear_floor, Extra, 0),
    ?_check(ClrFloor < cfg_yunying_dunge_limit_tower:max_floor(YYActID), ?ERR_DUNGE_MAX_FLOOR),
    #cfg_yunying_dunge_limit_tower{dunge=DungeID} = cfg_yunying_dunge_limit_tower:find(YYActID, ClrFloor+1),
    #{dunge=>DungeID, floor=>ClrFloor+1}.

check_captain(DungeID, RoleSt) ->
    #role_st{role=RoleID} = RoleSt,
    YYActID = yy_actid(),
    #yy_role{extra=Extra} = yunying_agent:get_yy_role(YYActID, RoleID),
    ClrFloor = maps:get(clear_floor, Extra, 0),
    EnterFloor = cfg_yunying_dunge_limit_tower:floor(DungeID),
    ?_check(cfg_yunying_dunge_limit_tower:is_open(YYActID, DungeID), ?ERR_DUNGE_YYACT_NOT_START),
    if
        ClrFloor+1 == EnterFloor -> ok;
        ClrFloor >= EnterFloor -> throw(?err(?ERR_DUNGE_MAX_FLOOR));
        ClrFloor+1 < EnterFloor -> throw(?err(?ERR_DUNGE_NOT_CLEAR_PRE));
        true -> throw(?err(?ERR_DUNGE_MAX_FLOOR))
    end,
    ?_check(ClrFloor < cfg_yunying_dunge_limit_tower:max_floor(YYActID), ?ERR_DUNGE_MAX_FLOOR).

send_info(RoleID, SceneSt) ->
    DungeSt = dunge_util:get_state(),
    ?ucast(RoleID, #m_dunge_info_toc{
        stype = ?SCENE_STYPE_DUNGE_MAGICTOWER,
        id    = SceneSt#scene_st.scene,
        info  = #{
            "prep_time" => DungeSt#dunge_st.ptime,
            "end_time"  => SceneSt#scene_st.etime
        }
    }).

send_info(SceneSt) ->
    {hook_enter, [#actor{uid=RoleID}]} = dunge_util:get_event(),
    DungeSt = dunge_util:get_state(),
    ?ucast(RoleID, #m_dunge_info_toc{
        stype = ?SCENE_STYPE_DUNGE_MAGICTOWER,
        id    = SceneSt#scene_st.scene,
        info  = #{
            "prep_time" => DungeSt#dunge_st.ptime,
            "end_time"  => SceneSt#scene_st.etime
        }
    }).

is_fail(_SceneSt) ->
    Roles = scene_actor:get_actids(?ACTOR_TYPE_ROLE),
    IsAllDead = lists:all(fun(RoleID) ->
        Actor = scene_actor:get_actor(RoleID),
        ?is_death(Actor#actor.state)
    end, Roles),
    Roles == [] orelse IsAllDead.

stat_one(SceneSt) ->
    {hook_over, [RoleID]} = dunge_util:get_event(),
    DungeSt  = #dunge_st{roles=RoleIDs} = dunge_util:get_state(),
    RoleIDs2 = lists:delete(RoleID, RoleIDs),
    DungeSt2 = DungeSt#dunge_st{roles=RoleIDs2},
    dunge_util:set_state(DungeSt2),
    Captain = captain(RoleID, SceneSt),
    do_stat(Captain, RoleID, SceneSt),
    ?SUCCESS.

stat(SceneSt) ->
    RoleIDs = scene_actor:get_actids(?ACTOR_TYPE_ROLE),
    case RoleIDs =/= [] of
        true ->
            Captain = captain(hd(RoleIDs), SceneSt),
            lists:foreach(fun
                (RoleID) ->
                    do_stat(Captain, RoleID, SceneSt)
            end, RoleIDs);
        false ->
            ignore
    end,
    ?SUCCESS.

give_reward({Captain, IsClear, DungeID}, RoleSt) ->
    IsCaptain = Captain == RoleSt#role_st.role,
    FloorID = cfg_yunying_dunge_limit_tower:floor(DungeID),
    Obtain2 = case {IsCaptain, IsClear} of
        {true, true}  ->
            #role_st{role=RoleID} = RoleSt,
            case catch yy_actid() of
                YYActID when is_integer(YYActID) ->
                    YYRole = #yy_role{extra=Extra} = yunying_agent:get_yy_role(YYActID, RoleID),
                    YYRole2 = YYRole#yy_role{extra=maps:put(clear_floor, FloorID, Extra)},
                    yunying_agent:set_yy_role(YYActID, YYRole2),
                    LogID  = yunying_util:calc_logid(YYActID);
                _ ->
                    LogID = yunying_util:calc_logid(hd(cfg_yunying_dunge_limit_tower:act_ids()))
            end,
            Reward = dunge_util:calc_reward(DungeID),
            {ok, Obtain} = role_bag:gain(Reward, LogID, RoleSt),
            Obtain;
        {false, true} ->
            dunge_team:assist_reward(Captain, RoleSt),
            #{};
        _ ->
            #{}
    end,
    ?ucast(#m_dunge_over_toc{
        stype  = ?SCENE_STYPE,
        id     = DungeID,
        clear  = IsClear,
        stat   = #{"floor"=>FloorID},
        reward = Obtain2
    }).

get_clr_floor(_YYActID) ->
    RoleID  = role_util:get_id(),
    YYActID = hd(lists:sort(cfg_yunying_dunge_limit_tower:act_ids())),
    #yy_role{extra=Extra} = yunying_agent:get_yy_role(YYActID, RoleID),
    maps:get(clear_floor, Extra, 0).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_stat(Captain, RoleID, SceneSt) ->
    #scene_st{dunge=DungeID} = SceneSt,
    case scene_actor:get_actor(RoleID) of
        ?nil  ->
            ignore;
        _Actor ->
            FloorID = cfg_yunying_dunge_limit_tower:floor(DungeID),
            #dunge_st{clear=IsClear} = dunge_util:get_state(),
            case IsClear of
                true  ->
                    role:route(RoleID, ?MODULE, give_reward, {Captain, IsClear, DungeID});
                false ->
                    ?ucast(RoleID, #m_dunge_over_toc{
                        stype  = ?SCENE_STYPE,
                        id     = DungeID,
                        clear  = IsClear,
                        stat   = #{"floor"=>FloorID}
                    })
            end
    end.

yy_actid() ->
    IDs = cfg_yunying_dunge_limit_tower:act_ids(),
    yy_actid(IDs).

yy_actid([]) ->
    throw(?err(?ERR_DUNGE_YYACT_NOT_START));
yy_actid([H|T]) ->
    case yunying:is_start(H) of
        true ->
            H;
        false ->
            yy_actid(T)
    end.

captain(RoleID, SceneSt) ->
    % 组队进入的才有group
    maps:get(captain, SceneSt#scene_st.opts, RoleID).
