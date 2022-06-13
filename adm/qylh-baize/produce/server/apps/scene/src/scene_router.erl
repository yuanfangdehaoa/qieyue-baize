%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(scene_router).

-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").

%% API
-export([route/1, route/2]).
-export([event/1, event/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
route(SceneSt) when is_record(SceneSt, scene_st) ->
	#scene_st{type=Type, stype=SType} = SceneSt,
	do_route(Type, SType);
route(SceneID) ->
	#cfg_scene{type=Type, stype=SType} = cfg_scene:find(SceneID),
	do_route(Type, SType).

route(Type, SType) ->
	do_route(Type, SType).

event(SceneSt) when is_record(SceneSt, scene_st)  ->
	#scene_st{type=Type, stype=SType} = SceneSt,
	do_event(Type, SType);
event(SceneID) ->
	#cfg_scene{type=Type, stype=SType} = cfg_scene:find(SceneID),
	do_event(Type, SType).

event(Type, SType) ->
	do_event(Type, SType).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
% 经验副本
do_route(_Type, ?SCENE_STYPE_DUNGE_EXP) ->
	dunge_exp;
% 金币副本
do_route(_Type, ?SCENE_STYPE_DUNGE_COIN) ->
	dunge_coin;
% 魔法塔副本
do_route(_Type, ?SCENE_STYPE_DUNGE_MAGICTOWER) ->
	dunge_magic;
% 装备副本
do_route(_Type, ?SCENE_STYPE_DUNGE_EQUIP)->
	dunge_equip;
% 日常副本
do_route(_Type, ?SCENE_STYPE_DUNGE_DAILY)->
	dunge_daily;
% 个人Boss
do_route(_Type, ?SCENE_STYPE_DUNGE_ROLE_BOSS)->
	dunge_boss;
% 进阶副本
do_route(_Type, ?SCENE_STYPE_DUNGE_MOUNT)->
	dunge_mount;
% 竞技场
do_route(_Type, ?SCENE_STYPE_DUNGE_ARENA) ->
	dunge_arena;
% 宠物副本
do_route(_Type, ?SCENE_STYPE_DUNGE_PET)->
	dunge_pet;
% 结婚副本
do_route(_Type, ?SCENE_STYPE_DUNGE_COUPLE)->
	dunge_couple;
% 圣痕秘境
do_route(_Type, ?SCENE_STYPE_DUNGE_SOUL)->
	dunge_soul;
% Boss地图
do_route(?SCENE_TYPE_BOSS, _SType) ->
	boss_server;
% 公会乱斗
do_route(_Type, ?SCENE_STYPE_GUILD_WAR) ->
	guild_war_server;
% 乱斗战场
do_route(_Type, ?SCENE_STYPE_MELEEWAR) ->
	melee_war;
% 糖果屋
do_route(_Type, ?SCENE_STYPE_CANDYROOM) ->
	candyroom;
%公会驻地
do_route(_Type, ?SCENE_STYPE_GUILDHOUSE) ->
	guild_house;
% 公会守卫
do_route(_Type, ?SCENE_STYPE_GUILDGUARD) ->
	guild_guard;
do_route(_Type, ?SCENE_STYPE_WEDDINGPARTY) ->
	wedding_party;
do_route(_Type, ?SCENE_STYPE_COMBAT1V1) ->
	combat1v1;
%勇者圣坛
do_route(_Type, ?SCENE_STYPE_WARRIOR) ->
	warrior_war;
% 运营爬塔副本
do_route(_Type, ?SCENE_STYPE_DUNGE_YUNYING_TOWER) ->
	yunying_dunge_tower;
do_route(_Type, ?SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER) ->
	yunying_dunge_limit_tower;
% 神灵副本
do_route(_Type, ?SCENE_STYPE_DUNGE_GOD) ->
	dunge_god;
% 新手人鱼副本
do_route(_Type, ?SCENE_STYPE_DUNGE_NEWBIE_SUMMON) ->
	dunge_newbie_summon_dungeai;
% 钻石擂台准备场景
do_route(_Type, ?SCENE_STYPE_COMPETE_PREPARE) ->
	compete_prepare;
% 钻石擂台战斗场景
do_route(_Type, ?SCENE_STYPE_COMPETE_BATTLE) ->
	compete_battle;
% 机甲竞速
do_route(_Type, ?SCENE_STYPE_DUNGE_RACE)->
	dunge_race;
% 限时Boss
do_route(_Type, ?SCENE_STYPE_TIMEBOSS)->
	timeboss_server;
% 夺城战
do_route(_Type, ?SCENE_STYPE_SIEGEWAR)->
	siegewar_server;
% 星之王座
do_route(_Type, ?SCENE_STYPE_THRONE)->
	throne_server;
% 跨服公会战
do_route(_Type, ?SCENE_STYPE_CROSS_GUILDWAR)->
	guild_crosswar;
do_route(_, _) ->
	?nil.


do_event(?SCENE_TYPE_DUNGE, _) ->
	dunge_agent;
do_event(_, ?SCENE_STYPE_GUILDGUARD) ->
	dunge_agent;
do_event(_, _) ->
	?nil.
