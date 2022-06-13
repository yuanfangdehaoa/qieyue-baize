%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_daily_wave_dungeai).

-include("btree.hrl").
-include("dunge.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("proto.hrl").

%% API
-export([send_info/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
send_info(SceneSt) ->
	DungeSt = #dunge_st{roles=[RoleID]} = dunge_util:get_state(),
	?ucast(RoleID, #m_dunge_info_toc{
		stype = ?SCENE_STYPE_DUNGE_DAILY,
		id    = SceneSt#scene_st.scene,
		info  = #{
			"cur_wave" => DungeSt#dunge_st.wave,
			"max_wave" => cfg_dunge_wave:max(SceneSt#scene_st.dunge)
		}
	}),
	?SUCCESS.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
