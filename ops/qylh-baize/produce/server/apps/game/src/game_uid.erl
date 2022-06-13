%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(game_uid).

%% API
-export([gen_guid/0]).
-export([guid2suid/1]).
-export([guid2ssid/1]).
-export([suid2ssid/0, suid2ssid/1]).
-export([guid2seqid/1]).

-define(DIG_COMMON, 100000000000).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 生成全服唯一的id
%% 游戏服id(8位) + 序列号(11位)
gen_guid() ->
	game_env:get_suid() * ?DIG_COMMON + 1.

%% 根据全服唯一id获取服务器id
guid2suid(GUID) ->
	GUID div ?DIG_COMMON.

guid2ssid(GUID) ->
	suid2ssid(guid2suid(GUID)).

%% 根据服务器id获取区服id
suid2ssid() ->
	suid2ssid(game_env:get_suid()).

suid2ssid(SUID) ->
	SUID rem 100000.

guid2seqid(GUID) ->
	GUID rem ?DIG_COMMON.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
