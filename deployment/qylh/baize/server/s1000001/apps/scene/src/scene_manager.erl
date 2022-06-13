%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(scene_manager).

-behaviour(gen_server).

-include("dunge.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("errno.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([create/3]).
-export([destroy/1, destroy/2, destroy/3]).
-export([enter/3]).
-export([change/7]).
-export([switch/5]).
-export([route/2]).
-export([bcast/2, bcast/3, bcast/4]).
-export([kickout/1, kickout/2, kickout/3]).
-export([get_lines/1, get_lines/2]).
-export([is_full/1, is_full/2, is_full/3]).
-export([hook_enter/3]).
-export([hook_leave/3]).

-define(SERVER(SceneID),
    case scene_util:is_same_node(SceneID) of
        true  -> ?MODULE;
        false -> {?MODULE, scene:get_cross(SceneID)}
    end
).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, {}, []).

%% 创建场景
create(SceneID, RoomID, Opts) ->
    case scene_util:is_same_node(SceneID) of
        true  ->
            Req = {create, SceneID, RoomID, Opts},
            gen_server:call(?MODULE, Req);
        false ->
            ignore
    end.

%% 销毁场景
destroy(SceneID) ->
    case scene_util:is_same_node(SceneID) of
        true  ->
            Req = {destroy, SceneID},
            gen_server:cast(?MODULE, Req);
        false ->
            ignore
    end.

destroy(SceneID, RoomID) ->
    case scene_util:is_same_node(SceneID) of
        true  ->
            Req = {destroy, SceneID, RoomID},
            gen_server:cast(?MODULE, Req);
        false ->
            ignore
    end.

destroy(SceneID, RoomID, LineID) ->
    case scene_util:is_same_node(SceneID) of
        true  ->
            Req = {destroy, SceneID, RoomID, LineID},
            gen_server:cast(?MODULE, Req);
        false ->
            ignore
    end.

%% 进入场景
enter(SceneID, RoomID, Actor) ->
    Req = {enter, SceneID, RoomID, Actor#actor.uid},
    {ok, Scene, Line} = gen_server:call(?SERVER(SceneID), Req),
    {ok, Actor2, Actors} = do_enter(Line, Actor, #{}),
    {ok, Actor2, Actors, Scene#scene.lines}.

%% 切换场景
change(NewSID, NewRID, NewLID, OldSPid, RoleID, Coord, Opts) ->
    #cfg_scene{type=Type} = cfg_scene:find(NewSID),
    case Type == ?SCENE_TYPE_DUNGE of
        true  ->
            {ok, Lines} = get_lines(NewSID, NewRID),
            Line = maps:get(?MAIN_LINE, Lines, ?nil),
            ?_check(Line /= ?nil, ?ERR_SCENE_NOT_EXIST),
            {ok, Actor2, Actors} = do_change(
                OldSPid, Line#line.spid, RoleID, Coord, Opts
            ),
            {ok, Actor2, Actors, Lines};
        false ->
            Req = {change, NewSID, NewRID, NewLID, RoleID},
            {ok, Scene, Line} = gen_server:call(?SERVER(NewSID), Req),
            {ok, Actor2, Actors} = do_change(
                OldSPid, Line#line.spid, RoleID, Coord, Opts
            ),
            {ok, Actor2, Actors, Scene#scene.lines}
    end.

%% 切换分线
switch(SceneID, RoomID, NewLID, OldSPid, RoleID) ->
    Req = {switch, SceneID, RoomID, NewLID},
    {ok, Scene, Line} = gen_server:call(?SERVER(SceneID), Req),
    {ok, Actor2, Actors} = do_change(
        OldSPid, Line#line.spid, RoleID, ?nil, #{}
    ),
    {ok, Actor2, Actors, Scene#scene.lines}.

%% 场景路由
route(SceneID, Msg) ->
    gen_server:cast(?SERVER(SceneID), {route, SceneID, Msg}).

%% 场景广播
bcast(SceneID, Toc) ->
    gen_server:cast(?SERVER(SceneID), {bcast, SceneID, Toc}).

bcast(SceneID, RoomID, Toc) ->
    gen_server:cast(?SERVER(SceneID), {bcast, SceneID, RoomID, Toc}).

bcast(SceneID, RoomID, LineID, Toc) ->
    gen_server:cast(?SERVER(SceneID), {bcast, SceneID, RoomID, LineID, Toc}).

%% 踢出场景
kickout(SceneID) ->
    gen_server:cast(?SERVER(SceneID), {kickout, SceneID}).

kickout(SceneID, RoomID) ->
    gen_server:cast(?SERVER(SceneID), {kickout, SceneID, RoomID}).

kickout(SceneID, RoomID, LineID) ->
    gen_server:cast(?SERVER(SceneID), {kickout, SceneID, RoomID, LineID}).

%% 获取分线
get_lines(SceneID) ->
    get_lines(SceneID, 0).

get_lines(SceneID, RoomID) ->
    Req = {get_scene, SceneID, RoomID},
    case gen_server:call(?SERVER(SceneID), Req) of
        ?nil  -> ?err(?ERR_SCENE_NOT_EXIST);
        Scene -> {ok, Scene#scene.lines}
    end.

%% 分线人数是否已满
is_full(SceneID) ->
    is_full(SceneID, 0, ?MAIN_LINE).

is_full(SceneID, LineID) ->
    is_full(SceneID, 0, LineID).

is_full(SceneID, RoomID, LineID) ->
    case get_lines(SceneID, RoomID) of
        {ok, Lines} ->
            case maps:find(LineID, Lines) of
                {ok, Line} ->
                    #cfg_line{hard=Hard} = cfg_scene:line(SceneID),
                    Line#line.num >= Hard;
                error ->
                    ?err(?ERR_SCENE_NO_LINE)
            end;
        Error ->
            Error
    end.

hook_enter(SceneID, RoomID, LineID) ->
    gen_server:cast(?SERVER(SceneID), {hook_enter, SceneID, RoomID, LineID}).

hook_leave(SceneID, RoomID, LineID) ->
    gen_server:cast(?SERVER(SceneID), {hook_leave, SceneID, RoomID, LineID}).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
    {ok, undefined}.

handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
    ?try_handle_info(do_handle_info(Info, State), State).

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%% 获取分线
do_handle_call({get_scene, SceneID, RoomID}, _From, State) ->
    Reply = get_scene(SceneID, RoomID),
    {reply, Reply, State};

%% 创建场景
do_handle_call({create, SceneID, RoomID, Opts}, _From, State) ->
    {ok, Scene, Line} = create_scene(SceneID, RoomID, Opts),
    set_scene(Scene),
    {reply, {ok, Line#line.spid}, State};

%% 进入场景
do_handle_call({enter, SceneID, RoomID, RoleID}, _From, State) ->
    Reply = case get_scene(SceneID, RoomID) of
        ?nil  -> ?err(?ERR_SCENE_NOT_EXIST);
        Scene -> enter_scene(Scene, RoleID)
    end,
    {reply, Reply, State};

%% 切换场景
do_handle_call({change, SceneID, RoomID, RoleID}, _From, State) ->
    NewScene = case get_scene(SceneID, RoomID) of
        ?nil  -> throw(?err(?ERR_SCENE_NOT_EXIST));
        Scene -> Scene
    end,
    Reply = change_scene(NewScene, RoleID),
    {reply, Reply, State};

%% 切换场景(直接进入指定分线)
do_handle_call({change, SceneID, RoomID, LineID, RoleID}, _From, State) ->
    NewScene = case get_scene(SceneID, RoomID) of
        ?nil  -> throw(?err(?ERR_SCENE_NOT_EXIST));
        Scene -> Scene
    end,
    Reply = case LineID == 0 of
        true  -> change_scene(NewScene, RoleID);
        false -> change_scene(NewScene, LineID, RoleID)
    end,
    {reply, Reply, State};

%% 切换分线
do_handle_call({switch, SceneID, RoomID, NewLID}, _From, State) ->
    Reply = case get_scene(SceneID, RoomID) of
        ?nil  -> ?err(?ERR_SCENE_NOT_EXIST);
        Scene -> switch_line(Scene, NewLID)
    end,
    {reply, Reply, State};

do_handle_call(Req, _From, State) ->
    ?error("unhandle call: ~p", [Req]),
    {reply, {error, unknown_call}, State}.


do_handle_cast({hook_enter, SceneID, RoomID, LineID}, State) ->
    case get_scene(SceneID, RoomID) of
        ?nil  ->
            ignore;
        Scene ->
            #scene{lines=Lines} = Scene,
            Line   = maps:get(LineID, Lines),
            Line2  = Line#line{num=Line#line.num+1},
            Scene2 = Scene#scene{
                lines = maps:put(LineID, Line2, Lines)
            },
            set_scene(Scene2)
    end,
    {noreply, State};

do_handle_cast({hook_leave, SceneID, RoomID, LineID}, State) ->
    case get_scene(SceneID, RoomID) of
        ?nil  -> ignore;
        Scene -> free_line(Scene, LineID)
    end,
    {noreply, State};

do_handle_cast({destroy, SceneID}, State) ->
    case get_rooms(SceneID) of
        ?nil  ->
            ignore;
        Rooms ->
            lists:foreach(fun
                (RoomID) ->
                    destroy_scene(SceneID, RoomID)
            end, Rooms)
    end,
    {noreply, State};

do_handle_cast({destroy, SceneID, RoomID}, State) ->
    destroy_scene(SceneID, RoomID),
    {noreply, State};

do_handle_cast({destroy, SceneID, RoomID, LineID}, State) ->
    case get_scene(SceneID, RoomID) of
        ?nil  ->
            ignore;
        Scene ->
            destroy_scene2(Scene, LineID)
    end,
    {noreply, State};

do_handle_cast({kickout, SceneID}, State) ->
    case get_rooms(SceneID) of
        ?nil  ->
            ignore;
        Rooms ->
            lists:foreach(fun
                (RoomID) ->
                    kickout_scene(SceneID, RoomID)
            end, Rooms)
    end,
    {noreply, State};

do_handle_cast({kickout, SceneID, RoomID}, State) ->
    kickout_scene(SceneID, RoomID),
    {noreply, State};

do_handle_cast({kickout, SceneID, RoomID, LineID}, State) ->
    case get_scene(SceneID, RoomID) of
        ?nil  ->
            ignore;
        Scene ->
            kickout_scene2(Scene, LineID)
    end,
    {noreply, State};

do_handle_cast({route, SceneID, Msg}, State) ->
    case get_rooms(SceneID) of
        ?nil  ->
            ignore;
        Rooms ->
            lists:foreach(fun
                (RoomID) ->
                    do_route(SceneID, RoomID, Msg)
            end, Rooms)
    end,
    {noreply, State};


do_handle_cast({bcast, SceneID, Toc}, State) ->
    case get_rooms(SceneID) of
        ?nil  ->
            ignore;
        Rooms ->
            lists:foreach(fun
                (RoomID) ->
                    do_bcast(SceneID, RoomID, Toc)
            end, Rooms)
    end,
    {noreply, State};

do_handle_cast({bcast, SceneID, RoomID, Toc}, State) ->
    do_bcast(SceneID, RoomID, Toc),
    {noreply, State};

do_handle_cast({bcast, SceneID, RoomID, LineID, Toc}, State) ->
    case get_scene(SceneID, RoomID) of
        ?nil  ->
            ignore;
        Scene ->
            do_bcast2(Scene, LineID, Toc)
    end,
    {noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
    {noreply, State}.


do_handle_info({'DOWN', MRef, _, _, Info}, State) ->
    case get_monitor(MRef) of
        {SceneID, RoomID, LineID} ->
            ?debug(
                "scene down, scene=~w, room=~w, line=~w, info=~p",
                [SceneID, RoomID, LineID, Info]
            ),
            case get_scene(SceneID, RoomID) of
                ?nil  -> ignore;
                Scene -> free_line3(Scene, LineID)
            end;
        ?nil ->
            ignore
    end,
    {noreply, State};

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.


create_scene(SceneID, RoomID, Opts) ->
    #cfg_scene{type=Type} = cfg_scene:find(SceneID),
    Line  = start_line(SceneID, RoomID, ?MAIN_LINE, Opts),
    Scene = #scene{
        scene = SceneID,
        room  = RoomID,
        type  = Type,
        opts  = Opts,
        lines = #{?MAIN_LINE=>Line},
        trash = [],
        track = #{}
    },
    {ok, Scene, Line}.

start_line(SceneID, RoomID, LineID, Opts) ->
    case scene_agent_sup:start_scene(SceneID, RoomID, LineID, Opts) of
        {ok, Pid} ->
            add_room(SceneID, RoomID),
            start_line2(SceneID, RoomID, LineID, Pid, Opts);
        {error, {already_started,Pid}} ->
            case SceneID of
                ?SCENE_STYPE_GUILDHOUSE -> ignore;
                _ ->
                    gen_server:cast(Pid, already_started),
                    ?error("repeat start scene: ~p", [{SceneID, RoomID, LineID}]),
                    #cfg_scene{type=SceneType} = cfg_scene:find(SceneID),
                    case SceneType == ?SCENE_TYPE_DUNGE of
                        true  ->
                            throw(?err(?ERR_SCENE_CHANGE_FAIL));
                        false ->
                            start_line2(SceneID, RoomID, LineID, Pid, Opts)
                    end
            end;
        Reason ->
            ?error("start scene error: ~p", [Reason]),
            throw(?err(?ERR_GAME_SYS_ERROR))
    end.

start_line2(SceneID, RoomID, LineID, Pid, Opts) ->
    MRef = erlang:monitor(process, Pid),
    set_monitor(MRef, {SceneID, RoomID, LineID}),
    #line{
        id    = LineID,
        spid  = Pid,
        num   = 0,
        mref  = MRef,
        dunge = maps:get(dunge, Opts, 0),
        floor = maps:get(floor, Opts, 0)
    }.

destroy_scene(SceneID, RoomID) ->
    case get_scene(SceneID, RoomID) of
        ?nil  ->
            ignore;
        Scene ->
            lists:foreach(fun
                (LineID) ->
                    destroy_scene2(Scene, LineID)
            end, maps:keys(Scene#scene.lines))
    end.

destroy_scene2(Scene, LineID) ->
    case maps:find(LineID, Scene#scene.lines) of
        {ok, Line} ->
            del_monitor(Line#line.mref),
            free_line3(Scene, LineID),
            scene_agent_sup:stop_scene(Line#line.spid);
        error ->
            ignore
    end.

enter_scene(Scene, RoleID) ->
    {ok, Scene2, NewLine} = allot_line(Scene, RoleID),
    set_scene(Scene2),
    {ok, Scene2, NewLine}.

allot_line(Scene, RoleID) when Scene#scene.type == ?SCENE_TYPE_ACT ->
    #scene{scene=SceneID, lines=Lines, track=Track} = Scene,
    #cfg_line{keep=IsKeep} = cfg_scene:line(SceneID),
    case IsKeep andalso maps:find(RoleID, Track) of
        {ok, LineID} ->
            {ok, Scene, maps:get(LineID, Lines)};
        _ ->
            do_allot(Scene, RoleID)
    end;
allot_line(Scene, RoleID) ->
    do_allot(Scene, RoleID).

do_allot(Scene, RoleID) ->
    #scene{scene=SceneID, lines=Lines} = Scene,
    #cfg_line{soft=Soft} = cfg_scene:line(SceneID),
    Line = case Soft > 0 of
        true  -> select_line(Scene);
        false -> maps:get(?MAIN_LINE, Lines)
    end,
    do_allot2(Scene, Line, RoleID).

do_allot2(Scene, Line, RoleID) ->
    #scene{scene=SceneID, type=Type, lines=Lines, trash=Trash, track=Track} = Scene,
    #line{id=LineID} = Line,
    % Line2  = Line#line{num=Num+1},
    Scene1 = Scene#scene{
        lines = maps:put(LineID, Line, Lines),
        trash = lists:delete(LineID, Trash)
    },
    #cfg_line{keep=IsKeep} = cfg_scene:line(SceneID),
    Scene2 = case Type == ?SCENE_TYPE_ACT andalso IsKeep of
        true  -> Scene1#scene{track=maps:put(RoleID, LineID, Track)};
        false -> Scene1
    end,
    {ok, Scene2, Line}.

select_line(Scene) ->
    #scene{scene=SceneID, lines=Lines, trash=Trash} = Scene,
    #cfg_line{soft=Soft, max=Max} = cfg_scene:line(SceneID),
    LineList = lists:keysort(#line.id, maps:values(Lines)),
    case select_line2(LineList, Soft) of
        0 ->
            IsFull = Max > 0 andalso maps:size(Lines) >= Max,
            ?_check(not IsFull, ?ERR_SCENE_FULL_SCENE),
            LineID = case length(Trash) == 0 of
                true  -> maps:size(Lines) + 1;
                false -> hd(lists:sort(Trash))
            end,
            #scene{scene=SceneID, room=RoomID, opts=Opts} = Scene,
            start_line(SceneID, RoomID, LineID, Opts);
        L ->
            L
    end.

select_line2([Line | T], Soft) ->
    case Line#line.num < Soft of
        true  -> Line;
        false -> select_line2(T, Soft)
    end;
select_line2([], _) ->
    0.


change_scene(NewScene, RoleID) ->
    {ok, NewScene2, NewLine} = allot_line(NewScene, RoleID),
    set_scene(NewScene2),
    {ok, NewScene2, NewLine}.

change_scene(Scene, LineID, RoleID) ->
    #scene{scene=SceneID, lines=Lines} = Scene,
    #cfg_line{hard=Hard} = cfg_scene:line(SceneID),
    case maps:find(LineID, Lines) of
        error ->
            ?err(?ERR_SCENE_NO_LINE);
        {ok, Line} when Line#line.num >= Hard ->
            ?err(?ERR_SCENE_FULL_LINE);
        {ok, Line} ->
            {ok, Scene2, Line2} = do_allot2(Scene, Line, RoleID),
            set_scene(Scene2),
            {ok, Scene2, Line2}
    end.

switch_line(Scene, LineID) ->
    #scene{scene=SceneID, lines=Lines} = Scene,
    #cfg_line{hard=Hard} = cfg_scene:line(SceneID),
    case maps:find(LineID, Lines) of
        error ->
            ?err(?ERR_SCENE_NO_LINE);
        {ok, Line} when Line#line.num >= Hard ->
            ?err(?ERR_SCENE_FULL_LINE);
        {ok, Line} ->
            % Line2  = Line#line{num=Line#line.num+1},
            % Lines2 = maps:put(LineID, Line2, Lines),
            % Scene2 = Scene#scene{lines=Lines2},
            % set_scene(Scene2),
            {ok, Scene, Line}
    end.

free_line(Scene, LineID) ->
    #scene{scene=SceneID, type=Type} = Scene,
    #cfg_line{keep=IsKeep} = cfg_scene:line(SceneID),
    case Type == ?SCENE_TYPE_ACT andalso IsKeep of
        true  -> ignore;
        false -> free_line2(Scene, LineID)
    end.

free_line2(Scene, LineID) ->
    Line = maps:get(LineID, Scene#scene.lines),
    #line{num=Num, spid=Pid, mref=MRef} = Line,
    case (Num-1 =< 0) andalso can_free(Scene, Line) of
        true  ->
            del_monitor(MRef),
            scene_agent_sup:stop_scene(Pid),
            free_line3(Scene, LineID);
        false ->
            Line2  = Line#line{num=Line#line.num-1},
            Lines2 = maps:put(LineID, Line2, Scene#scene.lines),
            set_scene(Scene#scene{lines=Lines2})
    end.

can_free(_Scene, Line) when Line#line.id /= ?MAIN_LINE ->
    true;
can_free(Scene, Line) when Scene#scene.type == ?SCENE_TYPE_DUNGE ->
    #cfg_dunge{type=Type} = cfg_dunge:find(Line#line.dunge),
    Type /= ?DUNGE_TYPE_GUILD;
can_free(_Scene, _Line) ->
    false.


free_line3(Scene, LineID) ->
    #scene{lines=Lines, trash=Trash} = Scene,
    case maps:size(Lines) == 1 of
        true  ->
            del_scene(Scene);
        false ->
            set_scene(Scene#scene{
                lines = maps:remove(LineID, Lines),
                trash = lists:sort([LineID | Trash])
            })
    end.

kickout_scene(SceneID, RoomID) ->
    case get_scene(SceneID, RoomID) of
        ?nil  ->
            ignore;
        Scene ->
            lists:foreach(fun
                (LineID) ->
                    kickout_scene2(Scene, LineID)
            end, maps:keys(Scene#scene.lines))
    end.

kickout_scene2(Scene, LineID) ->
    case maps:find(LineID, Scene#scene.lines) of
        {ok, Line} ->
            scene:cast(Line#line.spid, kickout);
        error ->
            ignore
    end.

do_route(SceneID, RoomID, Msg) ->
    case get_scene(SceneID, RoomID) of
        ?nil  ->
            ignore;
        Scene ->
            lists:foreach(fun
                (LineID) ->
                    do_route2(Scene, LineID, Msg)
            end, maps:keys(Scene#scene.lines))
    end.

do_route2(Scene, LineID, Msg) ->
    case maps:find(LineID, Scene#scene.lines) of
        {ok, Line} ->
            erlang:send(Line#line.spid, Msg);
        error ->
            ignore
    end.

do_bcast(SceneID, RoomID, Toc) ->
    case get_scene(SceneID, RoomID) of
        ?nil  ->
            ignore;
        Scene ->
            lists:foreach(fun
                (LineID) ->
                    do_bcast2(Scene, LineID, Toc)
            end, maps:keys(Scene#scene.lines))
    end.

do_bcast2(Scene, LineID, Toc) ->
    case maps:find(LineID, Scene#scene.lines) of
        {ok, Line} ->
            scene:cast(Line#line.spid, {bcast, Toc});
        error ->
            ignore
    end.

-define(k_rooms, {k_rooms, SceneID}).
get_rooms(SceneID) ->
    get(?k_rooms).

set_rooms(SceneID, RoomIDs) ->
    put(?k_rooms, RoomIDs).

del_rooms(SceneID) ->
    erase(?k_rooms).

add_room(SceneID, RoomID) ->
    RoomIDs  = case get_rooms(SceneID) of
        ?nil  -> [];
        Rooms -> Rooms
    end,
    RoomIDs2 = lists:usort([RoomID | RoomIDs]),
    set_rooms(SceneID, RoomIDs2).


-define(k_scene, {k_scene, SceneID, RoomID}).
get_scene(SceneID, RoomID) ->
    get(?k_scene).

set_scene(Scene = #scene{scene=SceneID, room=RoomID}) ->
    put(?k_scene, Scene).

del_scene(#scene{scene=SceneID, room=RoomID}) ->
    erase(?k_scene),
    del_rooms(SceneID).


-define(k_monitor, {k_monitor, MRef}).
get_monitor(MRef) ->
    get(?k_monitor).

set_monitor(MRef, {SceneID, RoomID, LineID}) ->
    put(?k_monitor, {SceneID, RoomID, LineID}).

del_monitor(MRef) ->
    erase(?k_monitor).


do_enter(Line, Actor, Opts) ->
    Req = {enter, Actor, Opts},
    scene:call(Line#line.spid, Req).

% do_leave(ScenePid, RoleID) ->
%     scene:call(ScenePid, {leave, RoleID}).

do_change(OldSPid, NewSPid, RoleID, Coord, Opts) ->
    Req = {change, NewSPid, RoleID, Coord, Opts},
    scene:call(OldSPid, Req).
