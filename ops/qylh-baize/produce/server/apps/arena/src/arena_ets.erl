%% @author rong
%% @doc 
-module(arena_ets).

-include_lib("stdlib/include/ms_transform.hrl").
-include("arena.hrl").
-include("table.hrl").

-export([init/0]).
-export([get_arena/1, set_arena/1, del_arena/1, all_arena/0, get_arena_by_role/1]).
-export([get_role/1, set_role/1]).
-export([get_misc/1, set_misc/1, all_misc/0]).
-export([get_sti_times/1]).

-define(ETS_ARENA, ets_arena). %玩家进入排名才有数据
-define(ETS_ARENA_ROLE, ets_arena_role). %记录玩家
-define(ETS_ARENA_MISC, ets_arena_MISC). %记录玩家杂项数据

init() ->
    ets:new(?ETS_ARENA, [named_table, {keypos, #arena.rank}]),
    ets:new(?ETS_ARENA_ROLE, [named_table, {keypos, #r_arena_role.role_id}]),
    ets:new(?ETS_ARENA_MISC, [named_table, {keypos, #arena_misc.id}]),
    ok.

get_arena(Rank) ->
    ets:lookup(?ETS_ARENA, Rank).

set_arena(Arena) ->
    ets:insert(?ETS_ARENA, Arena).

del_arena(Rank) ->
    ets:delete(?ETS_ARENA, Rank).

all_arena() ->
    ets:tab2list(?ETS_ARENA).

get_arena_by_role(RoleID) ->
    MS = ets:fun2ms(fun(#arena{role_id=R} = E) when R == RoleID -> E end),
    ets:select(?ETS_ARENA, MS).

get_role(RobotID) when ?IS_ROBOT(RobotID) ->
    #r_arena_role{role_id=RobotID, rank=RobotID};
get_role(RoleID) ->
    case ets:lookup(?ETS_ARENA_ROLE, RoleID) of
        [Role] ->
            Role;
        [] ->
            #r_arena_role{role_id=RoleID, rank=0}
    end.

set_role(Role) ->
    ets:insert(?ETS_ARENA_ROLE, Role).


get_misc(RobotID) when ?IS_ROBOT(RobotID) ->
    #arena_misc{id=RobotID};
get_misc(RoleID) ->
    case ets:lookup(?ETS_ARENA_MISC, RoleID) of
        [Misc] ->
            Misc;
        [] ->
            #arena_misc{id=RoleID}
    end.

set_misc(Misc) ->
    ets:insert(?ETS_ARENA_MISC, Misc).

all_misc() ->
    ets:tab2list(?ETS_ARENA_MISC).

get_sti_times(RoleID) ->
    #arena_misc{sti_times=StiTimes, sti_date=StiDate} = get_misc(RoleID),
    case StiDate =/= ut_time:date() of
        true -> 0;
        false -> StiTimes
    end.
