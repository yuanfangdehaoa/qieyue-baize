%%%=============================================================================
%%% @author z.hua
%%% @doc
%%% 打指定怪物副本ai
%%% @end
%%%=============================================================================

-module(dunge_aicreep).

-include("btree.hrl").
-include("dunge.hrl").
-include("scene.hrl").

%% API
-export([is_over/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
is_over(_SceneSt) ->
	#dunge_st{id=DungeID, kill=Kill} = dunge_util:get_state(),
	#cfg_dunge{aiargs=AIArgs} = cfg_dunge:find(DungeID),
	lists:all(fun
		({creep, CreepID, Num}) ->
			maps:get(CreepID, Kill, 0) >= Num
	end, AIArgs).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
