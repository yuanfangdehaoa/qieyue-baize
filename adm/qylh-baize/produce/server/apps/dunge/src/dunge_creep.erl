%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_creep).

-include("creep.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("proto.hrl").

%% API
-export([summon/2, summon/3]).
-export([is_over/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
summon(Creeps, SceneSt) ->
	summon(Creeps, #{}, SceneSt).

summon(Creeps, AIArgs, SceneSt) ->
	#dunge_st{level=CreepLv} = dunge_util:get_state(),
	Opts = case AIArgs == ?nil of
		true  -> #{};
		false -> #{aiargs=>AIArgs}
	end,
	Creeps2 = lists:map(fun
		({CreepID, X, Y}) ->
			{CreepID, X, Y, Opts};

		({CreepID, X, Y, Delay}) ->
			AIArgs1 = maps:get(aiargs, Opts, #{}),
			AIArgs2 = maps:merge(#{delay=>Delay}, AIArgs1),
			Opts2   = Opts#{aiargs=>AIArgs2},
			{CreepID, #p_coord{x=X, y=Y}, Opts2};

		({CreepID, X, Y, AttrID, worldlv, AttCoef, DefCoef}) ->
			{CreepID, X, Y, AttrID, worldlv, AttCoef, DefCoef};

		({CreepID, X, Y, AttrID, creeplv, AttCoef, DefCoef}) ->
			#cfg_creep{level=CreepLv2} = cfg_creep:find(CreepID),
			{CreepID, X, Y, AttrID, CreepLv2, AttCoef, DefCoef};

		({CreepID, X, Y, AttrID, worldlv, AttCoef, DefCoef, Delay}) ->
			AIArgs1 = maps:get(aiargs, Opts, #{}),
			AIArgs2 = maps:merge(#{delay=>Delay}, AIArgs1),
			Opts2   = Opts#{aiargs=>AIArgs2},
			{CreepID, X, Y, AttrID, worldlv, AttCoef, DefCoef, Opts2};

		({CreepID, X, Y, AttrID, creeplv, AttCoef, DefCoef, Delay}) ->
			#cfg_creep{level=CreepLv2} = cfg_creep:find(CreepID),
			AIArgs1 = maps:get(aiargs, Opts, #{}),
			AIArgs2 = maps:merge(#{delay=>Delay}, AIArgs1),
			Opts2   = Opts#{aiargs=>AIArgs2},
			{CreepID, X, Y, AttrID, CreepLv2, AttCoef, DefCoef, Opts2};

		({CreepID, X, Y, AttrID, AttCoef, DefCoef}) ->
			{CreepID, X, Y, AttrID, CreepLv, AttCoef, DefCoef, Opts};

		({CreepID, X, Y, AttrID, AttCoef, DefCoef, Delay}) ->
			AIArgs1 = maps:get(aiargs, Opts, #{}),
			AIArgs2 = maps:merge(#{delay=>Delay}, AIArgs1),
			Opts2   = Opts#{aiargs=>AIArgs2},
			{CreepID, X, Y, AttrID, CreepLv, AttCoef, DefCoef, Opts2}
	end, Creeps),
	creep_agent:add(Creeps2, SceneSt).

is_over(_Actor, _SceneSt) ->
	DungeSt = dunge_util:get_state(),
	DungeSt#dunge_st.over.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
