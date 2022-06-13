%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(dunge_equip).

-include("dunge.hrl").
-include("game.hrl").
-include("role.hrl").
-include("scene.hrl").
-include("enum.hrl").
-include("log.hrl").
-include("msgno.hrl").
-include("proto.hrl").
-include("item.hrl").

%% API
-export([handle/2]).
-export([send_info/2]).
-export([give_reward/2]).
-export([hook_pickup/3]).

-define(SCENE_STYPE, ?SCENE_STYPE_DUNGE_EQUIP).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 面板
handle(?DUNGE_PANEL, RoleSt) ->
	#cfg_dunge_enter{times=MaxTimes} = cfg_dunge:enter(?SCENE_STYPE),
	?ucast(#m_dunge_panel_toc{
		stype = ?SCENE_STYPE,
		id    = 0,
		info  = #{
			"max_times"  => MaxTimes,
			"buy_times"  => role_count:get_scene_buy(?SCENE_STYPE),
			"rest_times" => dunge_util:rest_times(?SCENE_STYPE)
		}
	}).

send_info(RoleID, SceneSt)->
	DungeSt = dunge_util:get_state(),
	?ucast(RoleID, #m_dunge_info_toc{
		stype = ?SCENE_STYPE_DUNGE_EQUIP,
		id    = SceneSt#scene_st.dunge,
		info  = #{
			"cur_wave"  => DungeSt#dunge_st.wave,
			"max_wave"  => cfg_dunge_wave:max(SceneSt#scene_st.dunge),
			"prep_time" => DungeSt#dunge_st.ptime,
			"end_time"  => SceneSt#scene_st.etime,
			"wave_etime"=> DungeSt#dunge_st.wtime,
			"level"     => maps:get(dunge_lv, DungeSt#dunge_st.opts)
		}
	}).

give_reward({Captain, RestTimes}, RoleSt) ->
	?_if(RestTimes == 0, dunge_team:assist_reward(Captain, RoleSt)).

hook_pickup(_Drop, Item, RoleSt)->
	#p_item{id=ItemID} = Item,
    #cfg_item{notify=Notify} = cfg_item:find(ItemID),
    case Notify of
    	true ->
            #role_st{role=RoleID, name=RoleName} = RoleSt,
			CacheID = item_cache:add_cache(Item),
			ItemMap = maps:put(CacheID, ItemID, #{}),
			#cfg_scene{name=SceneName} = cfg_scene:find(RoleSt#role_st.scene),
			?notify(?MSG_ITEM_DUNGE_EQUIP_GAIN, [{role, RoleID, RoleName},
				ut_color:format(SceneName, ?COLOR_GREEN), {pitem, ItemMap}]);
		false ->
			ignore
	end.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
