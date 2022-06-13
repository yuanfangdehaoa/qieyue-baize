%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_daily_creep_dungeai).

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
	DungeSt = dunge_util:get_state(),
	#dunge_st{roles=[RoleID], kill=Kill} = DungeSt,
	?ucast(RoleID, #m_dunge_info_toc{
		stype = ?SCENE_STYPE_DUNGE_DAILY,
		id    = SceneSt#scene_st.scene,
		count = Kill
	}),
	?SUCCESS.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
