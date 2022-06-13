%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(game_start).

-include("game.hrl").
-include("enum.hrl").

%% API
-export([mods/1]).
-export([post/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 需要启动的模块
mods(?SERVER_TYPE_LOCAL) ->
    [
          game_misc
        , game_logger
        , role_cache
        , item_cache
        , cluster_cache
        , role_logger
        , login_server
        , online_server
        , chime_server
        , marriage_manager
        , mail_server
        , boss_server
        , friend_server
        , friend_recommend
        , market_server
        , guild_war_server
        , order_server
        , junhai_log_server
        , world_level
        , afk_server
        , mirror_manager
        , arena_manager
        , redenvelope_server
        , faker_manager
        , dating_manager
        , wedding_agent_sup
        , wedding_manager
        , activity_manager
        , activity_stat
        , marquee_manager
        , combat1v1_matcher
        , combat1v1_server
        , combat1v1_settle
        , baby_server
        , compete_server
        , siegewar_server
    ];
mods(?SERVER_TYPE_CROSS) ->
    [
          game_misc
        , game_logger
        , role_cache
        , role_logger
        , online_server
        , chime_server
        , activity_manager
        , world_level
        , boss_server
        , chat_server
        , faker_manager
        , warrior_server
        , combat1v1_matcher
        , combat1v1_settle
        , compete_server
        , timeboss_server
        , siegewar_server
        , yunying_shop_manager
        , throne_server
        , guild_crosswar
    ];
mods(?SERVER_TYPE_CENTER) ->
    [
          game_misc
        , item_cache
        , activity_manager
        , online_server
    ].

%% 启动完成
post(?SERVER_TYPE_LOCAL) ->
    lists:foreach(fun
        (ServRef) ->
            gen_server:cast(ServRef, started)
    end, [
          world_level
        , activity_manager
        , afk_server
        , guild_manager
        , yunying_manager
        , dating_manager
        , marriage_manager
        , marquee_manager
        , market_server
        , faker_manager
        , combat1v1_settle
        , wedding_manager
        , compete_server
        , siegewar_server
    ]);
post(?SERVER_TYPE_CROSS) ->
    lists:foreach(fun
        (ServRef) ->
            gen_server:cast(ServRef, started)
    end, [
          world_level
        , faker_manager
        , yunying_shop_manager
        , yunying_manager
        , compete_server
        , timeboss_server
        , siegewar_server
        , activity_manager
        , guild_crosswar
    ]);
post(?SERVER_TYPE_CENTER) ->
    lists:foreach(fun
        (ServRef) ->
            gen_server:cast(ServRef, started)
    end, [
    ]).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
