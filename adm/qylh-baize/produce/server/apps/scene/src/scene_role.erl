%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(scene_role).

-include("attr.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").

%% API
-export([enter/3]).
-export([leave/2]).
-export([pre_leave/2]).
-export([post_leave/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
enter(Actor, Opts, SceneSt = #scene_st{scene=SceneID}) ->
    #cfg_scene{pkmode=PKMode, buffs=Buffs} = cfg_scene:find(SceneID),
    #actor{uid=ActorID, team=TeamID, attr=Attr} = Actor,
    NowSecs = ut_time:seconds(),
    Actor1  = Actor#actor{
        spid   = self(),
        scene  = SceneID,
        room   = SceneSt#scene_st.room,
        dunge  = SceneSt#scene_st.dunge,
        floor  = SceneSt#scene_st.floor,
        line   = SceneSt#scene_st.line,
        dest   = Actor#actor.coord,
        pkmode = ?_if(PKMode > 0, PKMode, Actor#actor.pkmode),
        attr   = ?_setattr(Attr, ?ATTR_HP, ?_attr(Attr,?ATTR_HPMAX)),
        group  = maps:get(group, Opts, 0),
        state  = ?_bic(Actor#actor.state, ?ACTOR_STATE_DEATH),
        bctype = maps:get(bctype, Opts, ?BCTYPE_GRID),
        enter  = Opts
    },
    Expired = [ID
        || #p_buff{id=ID, etime=ETime} <- maps:values(Actor#actor.buffs),
        ETime > 0 andalso NowSecs >= ETime
    ],
    Actor2  = buff_util:del_buffs(Actor1, Expired),
    WorldLv = world_level:get_level(),
    Buffs2  = lists:filtermap(fun
        ({BuffID, Reqs}) ->
            case check_scene_buff_reqs(Reqs, Actor2, WorldLv) of
                true  -> {true, BuffID};
                false -> false
            end;
        (BuffID) ->
            {true, BuffID}
    end, Buffs),
    Actor3 = buff_util:add_buffs(Actor2, Buffs2, NowSecs, false),
    buff_timer:add(Actor3),
    scene_grid:enter(Actor3, SceneSt),
    ?_if(TeamID > 0, scene_team:add_memb(TeamID, ActorID)),
    ?_if(cluster:is_cross(), role_cache:insert(#role_cache{
        id     = Actor#actor.uid,
        name   = Actor#actor.name,
        career = Actor#actor.career,
        gender = Actor#actor.gender,
        level  = Actor#actor.level,
        power  = Actor#actor.power,
        viplv  = Actor#actor.viplv,
        guild  = Actor#actor.guild,
        gname  = Actor#actor.gname,
        gpost  = Actor#actor.gpost,
        figure = Actor#actor.figure,
        icon   = Actor#actor.icon,
        marry  = Actor#actor.marry,
        mname  = Actor#actor.mname,
        mtype  = Actor#actor.mtype,
        suid   = Actor#actor.suid,
        zoneid = Actor#actor.zoneid,
        charm  = 0,
        wake   = 0,
        team   = 0,
        online = true
    })),
    {ok, Actor3}.

leave(RoleID, SceneSt) ->
    case scene_actor:get_actor(RoleID) of
        ?nil  ->
            ?err(?ERR_SCENE_NO_ACTOR);
        Actor ->
            {ok, Actor2} = pre_leave(Actor, SceneSt),
            post_leave(Actor, SceneSt),
            {ok, Actor2}
    end.

pre_leave(Actor, SceneSt) ->
    Actor1 = buff_util:del_buffs(Actor, cfg_buff:remove(leave)),
    scene_hook:pre_leave(Actor1, SceneSt),
    Actor2 = scene_actor:get_actor(Actor#actor.uid),
    {ok, Actor2}.

post_leave(Actor, SceneSt) ->
    #scene_st{scene=SceneID, room=RoomID, line=LineID} = SceneSt,
    scene_grid:leave(Actor, SceneSt),
    #actor{uid=RoleID, team=TeamID} = Actor,
    ?_if(TeamID > 0, scene_team:del_memb(TeamID, RoleID)),
    scene_hook:hook_leave(Actor, SceneSt),
    scene_actor:del_actor(RoleID),
    scene_manager:hook_leave(SceneID, RoomID, LineID).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
check_scene_buff_reqs([{worldlv, MinLv} | T], Actor, WorldLv) ->
    DiffLv = Actor#actor.level - WorldLv,
    case DiffLv >= MinLv of
        true  -> check_scene_buff_reqs(T, Actor, WorldLv);
        false -> false
    end;
check_scene_buff_reqs([{worldlv, MinLv, MaxLv} | T], Actor, WorldLv) ->
    DiffLv = Actor#actor.level - WorldLv,
    case MinLv =< DiffLv andalso DiffLv =< MaxLv of
        true  -> check_scene_buff_reqs(T, Actor, WorldLv);
        false -> false
    end;
check_scene_buff_reqs([{level, Level} | T], Actor, WorldLv) ->
    case Actor#actor.level >= Level of
        true  ->
            check_scene_buff_reqs(T, Actor, WorldLv);
        false -> false
    end;
check_scene_buff_reqs([], _Actor, _WorldLv) ->
    true.
