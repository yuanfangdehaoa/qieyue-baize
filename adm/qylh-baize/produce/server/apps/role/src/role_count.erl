%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_count).

-include("game.hrl").
-include("enum.hrl").
-include("table.hrl").
-include("welfare.hrl").

%% API
-export([get_times/1]).
-export([add_times/1, add_times/2]).
-export([del_times/1, del_times/2]).
-export([dirty_get_times/2]).
-export([dirty_add_times/3]).
-export([dirty_del_times/3]).
-export([hook_reset/3]).

-export([get_item_gain/1, add_item_gain/2]).
-export([get_afk_item_gain/1, add_afk_item_gain/2]).
-export([get_guild_welfare/1]).
-export([get_vip_welfare/1]).
-export([get_scene_enter/1, add_scene_enter/1, add_scene_enter/2]).
-export([get_scene_buy/1, add_scene_buy/1, add_scene_buy/2]).
-export([get_scene_itemadd/1, add_scene_itemadd/1, add_scene_itemadd/2]).
-export([get_scene_sweep/1, add_scene_sweep/1]).
-export([get_dunge_assist/1, add_dunge_assist/1]).
-export([get_redenvelope_times/1, add_redenvelope_times/1]).
-export([get_combat1v1_count/1, add_combat1v1_count/1, add_combat1v1_count/2]).
-export([get_beast_summon_bc/1, add_beast_summon_bc/1]).
-export([get_scene_ask_buy/1, add_scene_ask_buy/1]).
-export([get_totem_summon_bc/1, add_totem_summon_bc/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
get_times(Key) ->
	#role_count{counter=Counter} = role_data:get(?DB_ROLE_COUNT),
	maps:get(Key, Counter, 0).

add_times(Key) ->
	add_times(Key, 1).

add_times(Key, Times) ->
	RoleCount  = role_data:get(?DB_ROLE_COUNT),
	RoleCount2 = do_add_times(RoleCount, Key, Times),
	role_data:set(RoleCount2).

del_times(Key) ->
	add_times(Key, -1).

del_times(Key, Times) ->
	add_times(Key, -Times).

dirty_get_times(RoleID, Key) ->
	[RoleCount] = db:dirty_read(?DB_ROLE_COUNT, RoleID),
	maps:get(Key, RoleCount#role_count.counter, 0).

dirty_add_times(RoleID, Key, Times) ->
	[RoleCount] = db:dirty_read(?DB_ROLE_COUNT, RoleID),
	RoleCount2  = do_add_times(RoleCount, Key, Times),
	db:dirty_write(?DB_ROLE_COUNT, RoleCount2).

dirty_del_times(RoleID, Key, Times) ->
	[RoleCount] = db:dirty_read(?DB_ROLE_COUNT, RoleID),
	RoleCount2  = do_add_times(RoleCount, Key, -Times),
	db:dirty_write(?DB_ROLE_COUNT, RoleCount2).

hook_reset(Group, ID, _RoleSt) ->
	RoleCount = role_data:get(?DB_ROLE_COUNT),
	#role_count{counter=Counter} = RoleCount,
	Counter2 = maps:filter(fun
		(Key, _Val) ->
			if
				Group == 0, Key == ID ->
					false;
				Group > 0, ID == 0, Group == element(1, Key) ->
					false;
				Group > 0, ID > 0, Key == {Group,ID} ->
					false;
				true ->
					true
			end
	end, Counter),
	role_data:set(RoleCount#role_count{counter=Counter2}).

get_item_gain(ItemID) ->
	get_times({?ROLE_COUNT_ITEM_GAIN, ItemID}).

add_item_gain(ItemID, Num) ->
	add_times({?ROLE_COUNT_ITEM_GAIN, ItemID}, Num).

get_afk_item_gain(ItemID) ->
	get_times({?ROLE_COUNT_AFK_ITEM_GAIN, ItemID}).

add_afk_item_gain(ItemID, Num) ->
	add_times({?ROLE_COUNT_AFK_ITEM_GAIN, ItemID}, Num).

get_guild_welfare(Type) ->
	get_times({?ROLE_COUNT_GUILD_WELFARE, Type}).

get_vip_welfare(Type) ->
	get_times({?ROLE_COUNT_VIP_WELFARE, Type}).

get_scene_enter(SType) ->
	get_times({?ROLE_COUNT_SCENE_ENTER, SType}).

add_scene_enter(SType) ->
	add_times({?ROLE_COUNT_SCENE_ENTER, SType}).

add_scene_enter(SType, Times) ->
	add_times({?ROLE_COUNT_SCENE_ENTER, SType}, Times).

get_scene_buy(SType) ->
	get_times({?ROLE_COUNT_SCENE_BUY, SType}).

add_scene_buy(SType) ->
	add_times({?ROLE_COUNT_SCENE_BUY, SType}).

add_scene_buy(SType, Times) ->
	add_times({?ROLE_COUNT_SCENE_BUY, SType}, Times).

get_scene_itemadd(SType) ->
	get_times({?ROLE_COUNT_SCENE_ITEMADD, SType}).

add_scene_itemadd(SType) ->
	add_times({?ROLE_COUNT_SCENE_ITEMADD, SType}).

add_scene_itemadd(SType, Times) ->
	add_times({?ROLE_COUNT_SCENE_ITEMADD, SType}, Times).

get_scene_sweep(SType) ->
	get_times({?ROLE_COUNT_SCENE_SWEEP, SType}).

add_scene_sweep(SType) ->
	add_times({?ROLE_COUNT_SCENE_SWEEP, SType}).

get_dunge_assist(SType) ->
	get_times({?ROLE_COUNT_DUNGE_ASSIST, SType}).

add_dunge_assist(SType) ->
	add_times({?ROLE_COUNT_DUNGE_ASSIST, SType}).

get_scene_ask_buy(SType) ->
	get_times({?ROLE_COUNT_SCENE_ASK_BUY, SType}).

add_scene_ask_buy(SType) ->
	add_times({?ROLE_COUNT_SCENE_ASK_BUY, SType}).


get_redenvelope_times(Id) ->
	get_times({?ROLE_COUNT_REDENVELOPE, Id}).

add_redenvelope_times(Id)->
	add_times({?ROLE_COUNT_REDENVELOPE, Id}).

get_combat1v1_count(Type) ->
	get_times({?ROLE_COUNT_COMBAT1V1, Type}).

add_combat1v1_count(Type)->
	add_times({?ROLE_COUNT_COMBAT1V1, Type}).

add_combat1v1_count(Type, Count)->
	add_times({?ROLE_COUNT_COMBAT1V1, Type}, Count).

get_beast_summon_bc(Type) ->
	get_times({?ROLE_COUNT_BEAST_SUMMON_BC, Type}).

add_beast_summon_bc(Type)->
	add_times({?ROLE_COUNT_BEAST_SUMMON_BC, Type}).

get_totem_summon_bc(Type) ->
	get_times({?ROLE_COUNT_TOTEMS_SUMMON_BC, Type}).

add_totem_summon_bc(Type)->
	add_times({?ROLE_COUNT_TOTEMS_SUMMON_BC, Type}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_add_times(RoleCount, Key, Times) ->
	#role_count{counter=Counter} = RoleCount,
	Counter2 = ut_misc:maps_increase(Key, Times, Counter),
	RoleCount#role_count{counter=Counter2}.
