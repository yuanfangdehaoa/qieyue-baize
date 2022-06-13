%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%% 帮会领地
%%% @end
%%%=============================================================================

-module(guild_house).

-include("game.hrl").
-include("role.hrl").
-include("guild.hrl").
-include("errno.hrl").
-include("enum.hrl").
-include("scene.hrl").
-include("guild_house.hrl").
-include("activity.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("msgno.hrl").
-include("item.hrl").

%% API
-export([get_entry/3]).
-export([hook_start/1]).
-export([hook_stop/1]).
-export([pre_enter/3]).
-export([hook_loopsec/2]).
-export([create_scene/1]).
-export([delete_scene/1]).
-export([hook_born/2]).
-export([get_drops/2]).
-export([hook_pickup/3]).
-export([start/1]).
-export([stop/1]).
-export([clear_creep/1]).
-export([hook_creep_dead/3]).
-export([boss_time/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
get_entry(_ActID, _SceneID, RoleSt)->
	#role_st{guild=GuildID} = RoleSt,
  create_scene(GuildID),
	#{room=>GuildID}.

%活动开始
hook_start(ActID)->
    [guild_house:create_scene(GuildInfo#p_guild_base.id) || GuildInfo <- ets:tab2list(?ETS_GUILD)],
    guild_question_server:start(),
    #cfg_activity{scene = SceneID} = cfg_activity:find(ActID),
    scene:route(SceneID, ?MODULE, start).

%活动结束
hook_stop(ActID)->
    guild_question_server:stop(),
    #cfg_activity{scene = SceneID} = cfg_activity:find(ActID),
    scene:route(SceneID, ?MODULE, stop),
    timer:sleep(5000),
    [guild_house:delete_scene(GuildInfo#p_guild_base.id) || GuildInfo <- ets:tab2list(?ETS_GUILD)].

%% 玩家进入场景前
pre_enter(_SceneID, _Args, RoleSt) ->
	#role_st{guild=Guild, role=RoleID} = RoleSt,
	?_check(Guild > 0, ?ERR_SCENE_NO_GUILD),
	{ok, #guild_memb{time=Time}} = guild:get_member(Guild, RoleID),
	NeedTime = cfg_game:guild_house_enter_time(),
	?_check(ut_time:seconds()-Time >= NeedTime, ?ERR_GUILDHOUSE_ENTER_LIMIT_TIME).

boss_time(RoleID, _SceneSt)->
    BornTime = erlang:get({?MODULE, boss_born_time}),
    BornTime2 = case BornTime of
        ?nil -> 0;
        _    -> BornTime
    end,
    ?ucast(RoleID, #m_guild_house_callboss_bc_toc{start_time=BornTime2}).

create_scene(GuildID)->
    scene:create(?GUILD_HOUSE_SCENEID, GuildID).

delete_scene(GuildID)->
    scene:destroy(?GUILD_HOUSE_SCENEID, GuildID).

%怪物出生
hook_born(_Actor, SceneSt)->
    BornTime = ut_time:seconds(),
    erlang:put({?MODULE, boss_born_time}, BornTime),
    #scene_st{scene=SceneID, room=RoomID} = SceneSt,
    scene:bcast(SceneID, RoomID, #m_guild_house_callboss_bc_toc{start_time=BornTime}).



%获取掉落
get_drops(Actor, _SceneSt)->
    BornTime = erlang:get({?MODULE, boss_born_time}),
    erlang:erase({?MODULE, boss_born_time}),
    DeadTime = ut_time:seconds(),
    Duration = DeadTime - BornTime,
    Point = cfg_guild_house_kill:point(Duration),
    Drop = cfg_guild_house_drop:find(Actor#actor.id),
    DropMaps = maps:from_list(Drop),
    maps:get(Point, DropMaps, []).


%拾取掉落
hook_pickup(_Drop, Item, RoleSt)->
    #p_item{id=ItemID} = Item,
    #cfg_item{notify=Notify} = cfg_item:find(ItemID),
    case Notify of
        true ->
            CacheID = item_cache:add_cache(Item),
            ItemMap = maps:put(CacheID, ItemID, #{}),
            #role_st{role=RoleID, name=RoleName} = RoleSt,
            ?notify(?MSG_GUILDHOUSE_BOSS_PICKUP,[
                {role, RoleID, RoleName},
                {pitem, ItemMap}]);
        false ->
            igore
    end.


start(_SceneSt)->
    erlang:put({?MODULE, next_add_time}, ut_time:seconds()+10).


stop(_SceneSt)->
    erlang:erase({?MODULE, next_add_time}),
    erlang:erase({?MODULE, exp_maps}),
    erlang:send_after(timer:seconds(600), self(), {route, ?MODULE, clear_creep}).



hook_creep_dead(_Atker, _Defer, SceneSt)->
    #scene_st{scene=SceneID, room=RoomID} = SceneSt,
    scene:bcast(SceneID, RoomID, #m_guild_house_boss_finish_toc{}).

clear_creep(SceneSt)->
    #scene_st{scene=SceneID, room=RoomID, line=LineID} = SceneSt,
    creep:clear(SceneID, RoomID, LineID),
    erlang:erase({?MODULE, boss_born_time}),
    scene:bcast(SceneID, RoomID, #m_guild_house_boss_finish_toc{}).


hook_loopsec(NowSec, _SceneSt)->
    case activity:is_start(?ACTIVITYID) of
        true ->
            case erlang:get({?MODULE, next_add_time}) of
                ?nil ->
                   erlang:put({?MODULE, next_add_time}, NowSec+10);
                _ ->
                    igore
            end;
        false ->
            igore
    end,
	case erlang:get({?MODULE, next_add_time}) of
        NextSec when is_integer(NextSec), NowSec >= NextSec ->
            erlang:put({?MODULE, next_add_time}, NowSec+10),
            [begin
                #actor{level=Level} = scene_actor:get_actor(RoleID),
                Exp = cfg_guild_house_exp:find(Level),
                role:add_exp(RoleID, Exp, ?LOG_GUILD_HOUSE_LOOP_EXP),
                update_exp(RoleID, Exp)
            end || RoleID <- scene_actor:get_actids(?ACTOR_TYPE_ROLE)];
        _ ->
            igore
    end.


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%更新累计经验
update_exp(RoleID, Exp)->
    ExpMaps = case erlang:get({?MODULE, exp_maps}) of
        ?nil -> #{};
        Maps -> Maps
    end,
    Total = maps:get(RoleID, ExpMaps, 0),
    Total2 = Total + Exp,
    ExpMaps2 = maps:put(RoleID, Total2, ExpMaps),
    erlang:put({?MODULE, exp_maps}, ExpMaps2),
    ?ucast(RoleID, #m_guild_house_exp_toc{exp=Total2}).

