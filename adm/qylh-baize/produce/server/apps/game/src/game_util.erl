%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(game_util).

-include("game.hrl").
-include("role.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("proto.hrl").
-include("item.hrl").

%% API
-export([is_exported/3]).
-export([reg_name/2]).

-export([mnesia_opaque/1]).

-export([transform_gain/2]).
-export([normalize_gain/2]).

% 序列号位数
-define(DIG_ITEM , 1000000).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
is_exported(?nil, _Func, _Arity) ->
	false;
is_exported(Mod, Func, Arity) ->
	case code:ensure_loaded(Mod) of
		{module, Mod} ->
		    erlang:function_exported(Mod, Func, Arity);
		_ ->
			false
	end.

reg_name(Prefix, Elems0) ->
	Elems = [ut_conv:to_list(E) || E <- Elems0],
	ut_conv:to_atom(string:join([Prefix | Elems], "-")).

mnesia_opaque(SUID) ->
	MergeDir = "/data/merge",
	filelib:ensure_dir(MergeDir),
	MergeDir ++ io_lib:format("/data.~w", [SUID]).


% 获得道具转化
transform_gain(RoleLv, Gain) ->
	lists:map(fun
		({?ITEM_PLAYER_EXP, Num}) ->
			#cfg_exp_acti_base{role_exp=RoleExp} = cfg_exp_acti_base:find(RoleLv),
			{?ITEM_EXP, trunc(Num * RoleExp)};
		({?ITEM_PLAYER_EXP, Num, _}) ->
			#cfg_exp_acti_base{role_exp=RoleExp} = cfg_exp_acti_base:find(RoleLv),
			{?ITEM_EXP, trunc(Num * RoleExp)};
		({?ITEM_WORLDLV_EXP, Num}) ->
			WorldLv = world_level:get_level(),
    		#cfg_exp_acti_base{world_exp=WorldExp} = cfg_exp_acti_base:find(WorldLv),
    		{?ITEM_EXP, trunc(Num * WorldExp)};
    	({?ITEM_WORLDLV_EXP, Num, _}) ->
			WorldLv = world_level:get_level(),
    		#cfg_exp_acti_base{world_exp=WorldExp} = cfg_exp_acti_base:find(WorldLv),
    		{?ITEM_EXP, trunc(Num * WorldExp)};
		(I) -> I
	end, Gain).

normalize_gain(RoleID, Gain) when is_integer(RoleID) ->
	case role:get_cache(RoleID) of
		{ok, Cache} ->
			normalize_gain(Cache, Gain);
		_ ->
			?error("role not exist: ~w", [RoleID])
	end;
normalize_gain(Cache, Gain) ->
	lists:map(fun
		({ItemIDs, Num}) when is_list(ItemIDs) ->
		    ItemID = lists:nth(Cache#role_cache.gender, ItemIDs),
		    {ItemID, Num, #{}};
		({ItemIDs, Num, Opts}) when is_list(ItemIDs) ->
		    ItemID = lists:nth(Cache#role_cache.gender, ItemIDs),
		    Opts2  = case is_integer(Opts) of
	            true  -> #{bind => item_util:calc_bind(Opts)};
	            false -> Opts
	        end,
		    {ItemID, Num, Opts2};
		({ItemID, Num}) when is_integer(ItemID) ->
			{ItemID, Num, #{}};
		({ItemID, Num, Opts}) when is_integer(ItemID) ->
			Opts2  = case is_integer(Opts) of
	            true  -> #{bind => item_util:calc_bind(Opts)};
	            false -> Opts
	        end,
			{ItemID, Num, Opts2}
	end, Gain).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
