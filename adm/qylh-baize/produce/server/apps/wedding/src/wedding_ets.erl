%% @author rong
%% @doc 
-module(wedding_ets).

-include_lib("stdlib/include/ms_transform.hrl").
-include("game.hrl").
-include("table.hrl").
-include("wedding.hrl").

-export([init/0, clear/0]).
-export([get/1, get/2, set/1, del/1, del/2, all/0, current/0]).
-export([pid/1, pid/2, set_idx/1, del_idx/1, del_idx/2, all_idx/0]).

-define(ETS_WEDDING, ets_wedding). 
-define(ETS_WEDDING_IDX, ets_wedding_idx). 

init() ->
    % 表设置public
    % 由wedding_manager插入新的数据
    % 之后由wedding_agent来单独管理对应婚礼的数据，不同时间的婚礼数据互不影响
    ets:new(?ETS_WEDDING, [named_table, public, {keypos, #wedding.time}]),
    ets:new(?ETS_WEDDING_IDX, [named_table, public, {keypos, #wedding_idx.time}]),
    ok.

clear() ->
    ets:delete_all_objects(?ETS_WEDDING),
    ets:delete_all_objects(?ETS_WEDDING_IDX).

get(StartTime, EndTime) ->
    ?MODULE:get(key(StartTime, EndTime)).
get(WTime) ->
    case ets:lookup(?ETS_WEDDING, WTime) of
        [Wedding] -> Wedding;
        _ -> no_book
    end.

set(Wedding) ->
    ets:insert(?ETS_WEDDING, Wedding).

del(StartTime, EndTime) ->
    del(key(StartTime, EndTime)).

del(WTime) ->
    ets:delete(?ETS_WEDDING, WTime),
    db:dirty_delete(?DB_WEDDING, WTime).

all() ->
    ets:tab2list(?ETS_WEDDING).

% 当前正在或即将举行的婚礼
current() ->
    PreNotice = wedding_util:pre(),
    Now = ut_time:seconds(),
    MS = ets:fun2ms(fun(#wedding{time={StartTime, EndTime}} = E) when 
        Now >= StartTime - PreNotice, EndTime >= Now -> E end),
    ets:select(?ETS_WEDDING, MS).   

pid(StartTime, EndTime) ->
    pid(key(StartTime, EndTime)).

pid(WTime) ->
    case ets:lookup(?ETS_WEDDING_IDX, WTime) of
        [WeddingIdx] -> WeddingIdx#wedding_idx.pid;
        _ -> ?nil
    end.

set_idx(WeddingIdx) ->
    ets:insert(?ETS_WEDDING_IDX, WeddingIdx).

del_idx(StartTime, EndTime) ->
    del_idx(key(StartTime, EndTime)).

del_idx(WTime) ->
    ets:delete(?ETS_WEDDING_IDX, WTime).

all_idx() ->
    ets:tab2list(?ETS_WEDDING_IDX).

key(StartTime, EndTime) ->
    {StartTime, EndTime}.
