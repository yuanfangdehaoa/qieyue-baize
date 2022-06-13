%% @author rong
%% @doc 镜像管理器
-module(mirror_manager).

-behaviour(gen_server).

-include("game.hrl").
-include("errno.hrl").
-include("mirror.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("skill.hrl").
-include("buff.hrl").
-include("proto.hrl").
-include("figure.hrl").

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).
-export([start_link/0]).
-export([get_mirror/1, update_mirror/1]).
-export([hook_logout/1, hook_upgrade/2]).

-define(SERVER, ?MODULE).
-define(ETS_MIRROR, ets_mirror).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

get_mirror(RoleID) ->
    case ets:lookup(?ETS_MIRROR, RoleID) of
        [Mirror] -> {ok, Mirror};
        _ -> not_found
    end.

update_mirror(RoleSt) ->
    case is_open(RoleSt) of
        true ->
            RoleInfo  = role_data:get(?DB_ROLE_INFO),
            RoleAttr  = role_data:get(?DB_ROLE_ATTR),
            RoleVip   = role_data:get(?DB_ROLE_VIP),
            RoleGuild = role_data:get(?DB_ROLE_GUILD),
            RoleSkill = role_data:get(?DB_ROLE_SKILL),
            update_mirror(RoleInfo, RoleAttr, RoleSkill, RoleVip, RoleGuild);
        false ->
            ignore
    end.

is_open(RoleSt) ->
    role_afk:is_open(RoleSt) orelse role_misc:is_sys_open(arena_handler).

update_mirror(RoleInfo, RoleAttr, RoleSkill, RoleVip, RoleGuild) ->
    Mirror = make_mirror(RoleInfo, RoleAttr, RoleSkill, RoleVip, RoleGuild),
    gen_server:cast(?SERVER, {update_mirror, Mirror}).

hook_logout(RoleSt) ->
    update_mirror(RoleSt).

hook_upgrade(_NewLv, RoleSt) ->
    update_mirror(RoleSt).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init({}) ->
    process_flag(trap_exit, true),
    ets:new(?ETS_MIRROR, [named_table, {keypos, #mirror.id}]),
    Mirrors = db:dirty_match_all(?DB_MIRROR),
    ets:insert(?ETS_MIRROR, Mirrors),
    erlang:send_after(timer:minutes(15), self(), dump),
    {ok, undefined}.

handle_call(Req, From, State) ->
    ?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
    ?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(dump, State) ->
    erlang:send_after(timer:minutes(15), self(), dump),
    dump_mirrors(),
    {noreply, State};

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    dump_mirrors(),
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_handle_call(_Request, _From, State) ->
    {reply, {error, unknown_call}, State}.

do_handle_cast({update_mirror, Mirror}, State) ->
    ets:insert(?ETS_MIRROR, Mirror),
    {noreply, State};

do_handle_cast(_Msg, State) ->
    {noreply, State}.

dump_mirrors() ->
    lists:foreach(fun(R) ->
        db:dirty_write(?DB_MIRROR, R)
    end, ets:tab2list(?ETS_MIRROR)).

make_mirror(RoleInfo, RoleAttr, RoleSkill, RoleVip, RoleGuild) ->
    #role_skill{skills=Skills, puton=Puton} = RoleSkill,
    Passive = maps:filter(fun(SkillID, _) ->
        case cfg_skill:find(SkillID) of
            #cfg_skill{type=?SKILL_TYPE_PASSIVE} -> true;
            _ -> false
        end
    end, Skills),
    Buffs = maps:filter(fun(_, Buff) -> 
        #cfg_buff{mirror=Mirror} = cfg_buff:find(Buff#p_buff.id),
        Mirror
    end, RoleAttr#role_attr.buffs),
    Figure = maps:remove(?FIGURE_MOUNT, RoleInfo#role_info.figure),
    #mirror{
        id     = RoleInfo#role_info.id,
        name   = RoleInfo#role_info.name,
        attr   = RoleAttr#role_attr.attr,
        buffs  = Buffs,
        skills = maps:merge(Puton, Passive),
        power  = mod_attr:power(RoleAttr#role_attr.attr),
        level  = RoleInfo#role_info.level,
        career = RoleInfo#role_info.career,
        gender = RoleInfo#role_info.gender,
        viplv  = RoleVip#role_vip.level,
        figure = Figure,
        guild  = RoleGuild#role_guild.guild,
        gname  = guild:get_name(RoleGuild#role_guild.guild)    
    }.
