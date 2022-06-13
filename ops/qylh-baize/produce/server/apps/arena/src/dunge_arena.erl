%% @author rong
%% @doc
-module(dunge_arena).

-include("arena.hrl").
-include("proto.hrl").
-include("game.hrl").
-include("scene.hrl").
-include("dunge.hrl").

-export([get_entry/1, create_opts/2, pre_enter/3]).
-export([handle/2]).
-export([defender_coord/1]).
-export([send_info/2]).

% 设置出生点
get_entry(_RoleSt) ->
    #{coord=>hd(scene_config:born(cfg_arena:dunge_id()))}.

% 传入地图创建参数
create_opts(_Entry, _RoleSt) ->
    erlang:erase(?ARENA_ENTER_OPTS).

pre_enter(_SceneID, _Args, RoleSt) ->
    role_skill:refresh(RoleSt).

handle({#m_arena_battle_tos{}, RoleID}, _SceneSt) ->
    #cfg_dunge{stype=SType, last=Last} = cfg_dunge:find(cfg_arena:dunge_id()),
    #cfg_dunge_cd{prep=Prep} = cfg_dunge:cd(SType),
    Ptime = case erlang:get({?MODULE, ptime}) of
        ?nil -> ut_time:seconds()+Prep;
        Ptime0 -> Ptime0
    end,
    erlang:put({?MODULE, ptime}, Ptime),
    Etime = case erlang:get({?MODULE, etime}) of
        ?nil -> ut_time:seconds()+Last;
        Etime0 -> Etime0
    end,
    erlang:put({?MODULE, etime}, Etime),
    ?ucast(RoleID, #m_arena_battle_toc{ptime = Ptime, etime = Etime}).

defender_coord(_SceneSt) ->
    cfg_arena:def_rush().

send_info(_RoleID, _SceneSt) ->
    ignore.
