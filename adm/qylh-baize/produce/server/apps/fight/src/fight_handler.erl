%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(fight_handler).

-include("creep.hrl").
-include("fight.hrl").
-include("game.hrl").
-include("item.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("skill.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").

%% API
-export([handle/3]).

-define(k_picking, k_picking).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 攻击
handle(?FIGHT_ATTACK, Tos, RoleSt) ->
    #m_fight_attack_tos{unit=Unit, skill=SkillID, defid=DefID} = Tos,
    #cfg_skill{is_hew=IsHew, aim=Aim} = cfg_skill:find(SkillID),
    AtkSelf = Aim == ?SKILL_AIM_ENEMY andalso DefID == RoleSt#role_st.role,
    ?_check(not AtkSelf, ?ERR_FIGHT_ATTACK_SELF),
    RoleSkill = role_data:get(?DB_ROLE_SKILL),
    #role_skill{skills=Skills, puton=PutOn, endcd=EndCDs} = RoleSkill,
    #role_attr{attr=Attr} = role_data:get(?DB_ROLE_ATTR),
    ?_check(maps:is_key(SkillID, PutOn), ?ERR_FIGHT_SKILL_NOT_PUTON),
    SkillLv = maps:get(SkillID, Skills),
    #cfg_skill_level{cd=CD} = cfg_skill_level:find(SkillID, SkillLv),
    Millis = ut_time:milliseconds(),
    OldCD  = maps:get(SkillID, EndCDs, 0),
    NewCD  = Millis + ?_if(IsHew, CD, skill_util:calc_cd(SkillID, CD, Attr)),
    role_data:set(RoleSkill#role_skill{
        endcd = maps:put(SkillID, NewCD, EndCDs)
    }),
    check_attack(Unit, SkillID, OldCD, Millis),
    ?_if(Unit == ?ATTACK_UNIT_ROLE, set_attack_time(Millis)),
    fight_collect:break(RoleSt),
    Opts = case Unit of
        ?ATTACK_UNIT_ROLE ->
            [];
        ?ATTACK_UNIT_PET  ->
            case role_pet:get_fight() of
                {ok, Pet} ->
                    [{pet,Pet}];
                ?nil ->
                    []
            end
    end,
    Attack = #attack{
        atker = RoleSt#role_st.role,
        unit  = Unit,
        skill = fight_util:make_skill(SkillID, SkillLv),
        dir   = Tos#m_fight_attack_tos.dir,
        major = Tos#m_fight_attack_tos.defid,
        coord = Tos#m_fight_attack_tos.coord,
        time  = Millis,
        endcd = NewCD,
        seq   = Tos#m_fight_attack_tos.seq,
        opts  = Opts
    },
    scene:cast(RoleSt#role_st.spid, {fight, Attack});

%% 复活
handle(?FIGHT_REVIVE, Tos, RoleSt) ->
    #m_fight_revive_tos{type=Type} = Tos,
    check_revive(Type, RoleSt),
    #role_st{role=RoleID, scene=SceneID, spid=ScenePid} = RoleSt,
    case Type of
        ?REVIVE_TYPE_SITU ->
            #cfg_revive{cost=Cost} = cfg_scene:revive(SceneID),
            Succ = fun() ->
                ok = scene:call(ScenePid, {revive, RoleID, Type})
            end,
            role_bag:cost(Cost, ?LOG_REVIVE, Succ, RoleSt);
        ?REVIVE_TYPE_SAFE ->
            ok = scene:call(ScenePid, {revive, RoleID, Type})
    end;

%% 切换pk模式
handle(?FIGHT_PKMODE, Tos, RoleSt) ->
    #role_st{role=RoleID, spid=ScenePid} = RoleSt,
    #m_fight_pkmode_tos{pkmode=PKMode} = Tos,
    check_pkmode(PKMode, RoleSt),
    RoleInfo = role_data:get(?DB_ROLE_INFO),
    role_data:set(RoleInfo#role_info{pkmode=PKMode}),
    scene:cast(ScenePid, {chpk, RoleID, PKMode}),
    ?ucast(#m_fight_pkmode_toc{pkmode=PKMode});

%% 采集
handle(?FIGHT_COLLECT, Tos, RoleSt) ->
    #m_fight_collect_tos{uid=CollUid, type=Type} = Tos,
    case Type of
        % 开始采集
        1 -> fight_collect:start(CollUid, RoleSt);
        % 完成采集
        2 -> fight_collect:compl(RoleSt)
    end,
    ?ucast(#m_fight_collect_toc{uid=CollUid, type=Type});

%% 拾取
handle(?FIGHT_PICKUP, Tos, RoleSt) ->
    #m_fight_pickup_tos{uid=DropID, scene=SceneID} = Tos,
    check_pickup(SceneID, RoleSt),
    do_pickup(DropID, RoleSt),
    ?ucast(#m_fight_pickup_toc{uid=DropID, scene=SceneID});

%% 自动拾取
handle(?FIGHT_AUTOPICK, Tos, RoleSt=#role_st{type=SceneType}) ->
    #m_fight_autopick_tos{uids=DropIDs, scene=SceneID} = Tos,
    ?_check(length(DropIDs) =< 5, ?ERR_GAME_BAD_ARGS),
    ?_check(role_equip:has_fairy(pickup), ?ERR_DROP_NO_FAIRY),
    IsLimit = SceneType == ?SCENE_TYPE_ACT,
    ?_check(not IsLimit, ?ERR_GAME_BAD_ARGS),
    check_pickup(SceneID, RoleSt),
    [do_pickup(DropID, RoleSt) || DropID <- DropIDs],
    ?ucast(#m_fight_autopick_toc{uids=DropIDs, scene=SceneID});

%% 新手打怪
handle(?FIGHT_NEWBIE, Tos, RoleSt) ->
    #m_fight_newbie_tos{uid=ActorID, id=CreepID} = Tos,
    #role_info{level=RoleLv} = role_data:get(?DB_ROLE_INFO),
    #cfg_creep{rarity=Rarity, level=Level} = cfg_creep:find(CreepID),
    #{?ATTR_HPMAX:=HpMax} = cfg_creep_attr:find(CreepID, Level),
    ?_if(RoleLv =< 10, role_event:event(?EVENT_CREEP, {CreepID,Rarity})),
    ?ucast(#m_fight_attack_toc{
        atkid = RoleSt#role_st.role,
        unit  = ?ATTACK_UNIT_ROLE,
        skill = Tos#m_fight_newbie_tos.skill,
        level = 1,
        cd    = 0,
        dir   = Tos#m_fight_newbie_tos.dir,
        dmgs1 = [#p_damage{
            uid   = ActorID,
            unit  = ?ATTACK_UNIT_ROLE,
            coord = RoleSt#role_st.coord,
            hp    = 0,
            type  = ?DAMAGE_BLOOD,
            value = HpMax,
            state = ?ACTOR_STATE_NORMAL
        }],
        seq   = Tos#m_fight_newbie_tos.seq,
        combo = 0
    });

%% 敌对列表
handle(?FIGHT_ENEMIES, _Tos, RoleSt) ->
    #role_misc{enemy_suids=Setting} = role_data:get(?DB_ROLE_MISC),
    LocSUIDs = cluster:get_locals(suid),
    Enemies  = lists:foldl(fun
        (SUID, Acc) ->
            maps:put(SUID, maps:get(SUID, Setting, false), Acc)
    end, #{}, LocSUIDs),
    ?ucast(#m_fight_enemies_toc{enemies=Enemies});

%% 设置敌对
handle(?FIGHT_ENEMY, Tos, RoleSt) ->
    #m_fight_enemy_tos{suid=SUID, type=Type} = Tos,
    RoleMisc = #role_misc{enemy_suids=Enemies} = role_data:get(?DB_ROLE_MISC),
    LocSUIDs = cluster_util:get_local_suids(),
    ?_check(lists:member(SUID, LocSUIDs), ?ERR_GAME_BAD_ARGS),
    Enemies2 = maps:put(SUID, Type == 1, Enemies),
    role_data:set(RoleMisc#role_misc{enemy_suids=Enemies2}),
    #role_st{spid=ScenePid, role=RoleID} = RoleSt,
    Hostile  = [ID || {ID,IsEnemy} <- maps:to_list(Enemies2), IsEnemy],
    scene:update_actor(ScenePid, RoleID, [{hostile, Hostile}]),
    ?ucast(#m_fight_enemy_toc{suid=SUID, type=Type}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_attack(Unit, SkillID, EndCD, Millis) ->
    % 是否主动技能
    #cfg_skill{type=Type, group=Group} = cfg_skill:find(SkillID),
    ?_check(Type == ?SKILL_TYPE_ACTIVE, ?ERR_FIGHT_PASSIVE),
    case Unit == ?ATTACK_UNIT_ROLE of
        true  ->
            ?_check(Group /= ?SKILL_GROUP_PET, ?ERR_FIGHT_ROLE_USE_PET_SKILL),
            if
                Group == ?SKILL_GROUP_ANGER;
                Group == ?SKILL_GROUP_MECHA ->
                    ignore;
                true ->
                    % 出手cd
                    AtkTime = get_attack_time(),
                    ?_check(Millis >= AtkTime + 200, ?ERR_FIGHT_TOO_FAST, [SkillID])
            end;
        false ->
            ?_check(Group == ?SKILL_GROUP_PET, ?ERR_FIGHT_PET_USE_ROLE_SKILL)
    end,
    % 技能cd
    ?_check(Millis >= EndCD - 500, ?ERR_FIGHT_SKILL_CD, [SkillID]),
    ok.

check_revive(Type, RoleSt) ->
    enum:check_revive_type(Type),
    CfgRevive = cfg_scene:revive(RoleSt#role_st.scene),
    #cfg_revive{manu=CanManu} = CfgRevive,
    ?_check(CanManu, ?ERR_SCENE_CAN_NOT_REVIVE),
    ok.

check_pkmode(PKMode, RoleSt) ->
    enum:check_pkmode(PKMode),
    #cfg_scene{pkallow=PKAllow} = cfg_scene:find(RoleSt#role_st.scene),
    IsAllow = PKAllow == [] orelse lists:member(PKMode, PKAllow),
    ?_check(IsAllow, ?ERR_FIGHT_BAD_PKMODE),
    ok.

-define(k_attack_time, k_attack_time).
get_attack_time() ->
    Time = get(?k_attack_time),
    ?_if(Time == ?nil, 0, Time).

set_attack_time(Time) ->
    put(?k_attack_time, Time).

check_pickup(SceneID, RoleSt) ->
    ?_check(SceneID == RoleSt#role_st.scene, ?ERR_FIGHT_NO_DROP).

do_pickup(DropID, RoleSt) ->
    #role_st{role=RoleID, spid=ScenePid} = RoleSt,
    {ok, Drop} = scene:get_actor(ScenePid, DropID),
    #actor{id=ItemID, num=Num, exargs=ExArgs} = Drop,
    DropInfo = maps:get(drop, ExArgs),
    % check_can_pickup(DropInfo, RoleSt),
    Gain = [{ItemID, Num, DropInfo#drop.opts}],
    Succ = fun() -> ok = scene:call(ScenePid, {pickup, RoleID, DropID}) end,
    {ok, Obtain, _} = role_bag:gain(Gain, ?LOG_DROP_PICKUP, Succ, RoleSt, true),
    [case is_record(Item, p_item) of
        true  -> scene_hook:hook_pickup(DropInfo, Item, RoleSt);
        false -> ignore
    end || Item <- Obtain].
