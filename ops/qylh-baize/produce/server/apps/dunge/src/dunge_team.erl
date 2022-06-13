%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_team).

-include("creep.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([enter/2]).
-export([faker/2]).
-export([assist_reward/2]).
-export([calc_belong/0]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
enter({TeamID, SceneID, DungeID, Coord, Merge}, RoleSt)->
	#cfg_scene{stype=SType} = cfg_scene:find(SceneID),

    {ok, MergeTimes, MergeCost} = dunge_util:calc_merge(SceneID, Merge),

	RestTimes = dunge_util:rest_times(SType),
    Opts0 = #{rest_times=>RestTimes, group=>TeamID, merge_times=>MergeTimes},
    case SType of
        ?SCENE_STYPE_DUNGE_COUPLE ->
            role_count:add_scene_enter(SType, MergeTimes),
            #role_dunge{misc=Misc} = RoleDunge = role_data:get(?DB_ROLE_DUNGE),
            Times = maps:get({SType, question_times}, Misc, 0),
            Misc2 = maps:put({SType, question_times}, Times+1, Misc),
            role_data:set(RoleDunge#role_dunge{misc=Misc2}),
            Opts = maps:put(question_times, Times+1, Opts0);
        _ ->
        	case RestTimes > 0 of
        		true  -> role_count:add_scene_enter(SType, MergeTimes);
        		false -> role_count:add_dunge_assist(SType)
        	end,
            Opts = Opts0
    end,
	{ok, RoleSt2} = scene_change:change(
		?SCENE_CHANGE_DUNGE, SceneID, TeamID, Coord, MergeCost, Opts, RoleSt
	),
    log_api:log_dunge(DungeID, SType, ?DUNGE_OP_ENTER, MergeTimes, RoleSt),
	{ok, RoleSt2}.

faker({TeamID, Base, Coord, AttrID}, SceneSt) ->
	Actor = init_actor(TeamID, Base, Coord, AttrID, SceneSt),
    ?debug("faker:~w", [AttrID]),
	creep_agent:add([Actor], SceneSt).

%% 助战奖励
assist_reward(Captain, RoleSt = #role_st{role=RoleID})->
	HonorLimit = cfg_game:assist_honor_limit(),
    HonorGain  = role_count:get_times(?ROLE_COUNT_ASSIST_HONOR),
    case HonorGain < HonorLimit of
        true  ->
            HonorAdd = cfg_game:assist_honor(),
            role_bag:gain([{?ITEM_HONOR,HonorAdd}], ?LOG_DUNGE_ASSIST, RoleSt),
            role_count:add_times(?ROLE_COUNT_ASSIST_HONOR, HonorAdd),
            ?notify(RoleID, ?MSG_DUNGE_ASSIST_ADD_HONOUR, [HonorAdd]);
        false ->
            ignore
    end,
    IntimacyLimit = cfg_game:assist_intimacy_limit(),
    IntimacyGain  = role_count:get_times(?ROLE_COUNT_ASSIST_INTIMACY),
    case IntimacyGain < IntimacyLimit of
        true  ->
            IntimacyAdd = cfg_game:assist_intimacy(),
            friend_server:add_intimacy(RoleID, Captain, IntimacyAdd),
            role_count:add_times(?ROLE_COUNT_ASSIST_INTIMACY, IntimacyAdd);
        false ->
            ignore
    end.

%% 计算掉落归属
calc_belong()->
	RoleIDs = scene_actor:get_actids(?ACTOR_TYPE_ROLE),
	lists:foldl(fun
		(RoleID, Acc) ->
			#actor{enter=EnterOpts} = scene_actor:get_actor(RoleID),
			RestTimes = maps:get(rest_times, EnterOpts),
			case RestTimes > 0 of
				true  -> [RoleID | Acc];
				false -> Acc
			end
	end, [], RoleIDs).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
init_actor(TeamID, Base, Coord, AttrID, SceneSt) ->
	CreepID = if
        SceneSt#scene_st.stype == ?SCENE_STYPE_DUNGE_EQUIP ->
            case Base#p_role_base.gender of
                ?GENDER_MALE   -> 30201001;
                ?GENDER_FEMALE -> 30201002
            end;
        SceneSt#scene_st.stype == ?SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER ->
            case Base#p_role_base.gender of
                ?GENDER_MALE   -> 15070001;
                ?GENDER_FEMALE -> 15070002
            end;
        SceneSt#scene_st.stype == ?SCENE_STYPE_DUNGE_PET ->
            case Base#p_role_base.gender of
                ?GENDER_MALE   -> 8015001;
                ?GENDER_FEMALE -> 8015002
            end
    end,
	CfgCreep = cfg_creep:find(CreepID),
	#actor{
        id     = CreepID,
        type   = ?ACTOR_TYPE_ROBOT,
        bctype = CfgCreep#cfg_creep.bctype,
        kind   = CfgCreep#cfg_creep.kind,
        rarity = CfgCreep#cfg_creep.rarity,
        name   = Base#p_role_base.name,
        state  = ?ACTOR_STATE_NORMAL,
        dir    = ut_rand:random(-180, 180),
        born   = Coord,
        coord  = Coord,
        dest   = Coord,
        etime  = 0,
        buffs  = #{},
        skills = #{},
        endcds = #{},
        attrid = AttrID,
        atcoef = 10000,
        dfcoef = 10000,
        power  = 0,
        level  = Base#p_role_base.level,
        career = Base#p_role_base.career,
        gender = Base#p_role_base.gender,
        viplv  = 0,
        figure = Base#p_role_base.figure,
        team   = TeamID,
        guild  = 0,
        gname  = "",
        marry  = 0,
        mname  = "",
        mtype  = 0,
        group  = TeamID,
        owner  = 0,
        pkmode = ?PKMODE_PEACE,
        crime  = 0,
        atkrad = CfgCreep#cfg_creep.volume,
        aiid   = creep_util:gen_ai(CreepID),
        aidata = #{},
        aiargs = #{
            enemy_type => ?ACTOR_TYPE_CREEP,
            reborn     => CfgCreep#cfg_creep.reborn,
            faker_id   => Base#p_role_base.id
        },
        exargs = #{},
        threat = #{},
        suid   = game_env:get_suid(),
        zoneid = 0
    }.
