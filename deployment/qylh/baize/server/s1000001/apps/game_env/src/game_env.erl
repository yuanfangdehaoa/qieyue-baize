%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(game_env).

-include("game.hrl").
-include("table.hrl").

%% API
-export([get_id/0]).
-export([get_name/0]).
-export([get_type/0]).
-export([get_opened_time/0]).
-export([get_opened_days/0]).
-export([get_merged_time/0]).
-export([get_merged_days/0]).
-export([get_host/0]).
-export([get_port/0]).
-export([get_center/0]).
-export([get_pid/0]).
-export([get_plat/0]).
-export([get_suid/0]).
-export([get_version/0]).
-export([get_admin_host/0]).
-export([get_admin_key/0]).
-export([get_junhai_upload/0]).
-export([get_env/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%%-----------------------------------------------
%% @doc 游戏id
-spec get_id() ->
    integer().
%%-----------------------------------------------
get_id() ->
    get_env(guid).


%%-----------------------------------------------
%% @doc 游戏代号
-spec get_name() ->
    integer().
%%-----------------------------------------------
get_name() ->
    get_env(name).


%%-----------------------------------------------
%% @doc 服务器类型 SERVER_TYPE_XXX
-spec get_type() ->
    atom().
%%-----------------------------------------------
get_type() ->
    get_env(type).


%%-----------------------------------------------
%% @doc 开服时间
-spec get_opened_time() ->
    TimeStamp :: integer().
%%-----------------------------------------------
get_opened_time() ->
    {Date, _} = get_env(opened),
    ut_time:datetime_to_seconds({Date, {0,0,0}}).


%%-----------------------------------------------
%% @doc 开服天数
-spec get_opened_days() ->
    integer().
%%-----------------------------------------------
get_opened_days() ->
    {Date, _} = get_env(opened),
    ut_time:diff_days(Date, ut_time:today()) + 1.


%%-----------------------------------------------
%% @doc 合服时间
-spec get_merged_time() ->
    TimeStamp :: integer().
%%-----------------------------------------------
get_merged_time() ->
    Merge = game_misc:read(merge, #merge{}),
    Merge#merge.time.


%%-----------------------------------------------
%% @doc 合服天数
-spec get_merged_days() ->
    integer().
%%-----------------------------------------------
get_merged_days() ->
    case get_merged_time() of
        0 -> 0;
        N -> ut_time:diff_days(N, ut_time:seconds()) + 1
    end.


%%-----------------------------------------------
%% @doc 服务器ip
-spec get_host() ->
    tuple().
%%-----------------------------------------------
get_host() ->
    {ok, Host} = inet:parse_address(get_env(host)),
    Host.


%%-----------------------------------------------
%% @doc 端口
-spec get_port() ->
    integer().
%%-----------------------------------------------
get_port() ->
    get_env(port).


%%-----------------------------------------------
%% @doc 中心服
-spec get_center() ->
    atom().
%%-----------------------------------------------
get_center() ->
    get_env(center).


%%-----------------------------------------------
%% @doc 平台ID
-spec get_pid() ->
    integer().
%%-----------------------------------------------
get_pid() ->
    get_env(puid).


%%-----------------------------------------------
%% @doc 平台名称
-spec get_plat() ->
    atom().
%%-----------------------------------------------
get_plat() ->
    get_env(plat).


%%-----------------------------------------------
%% @doc 游戏服ID
-spec get_suid() ->
    integer().
%%-----------------------------------------------
get_suid() ->
    get_env(suid).

%%-----------------------------------------------
%% @doc 服务端版本
-spec get_version() ->
    string().
%%-----------------------------------------------
get_version() ->
    get_env(version).

%%-----------------------------------------------
%% @doc 管理后台地址
-spec get_admin_host() ->
    string().
%%-----------------------------------------------
get_admin_host() ->
    get_env(admin_host).

%%-----------------------------------------------
%% @doc 管理后台地址
-spec get_admin_key() ->
    string().
%%-----------------------------------------------
get_admin_key() ->
    get_env(admin_key).

%%-----------------------------------------------
%% @doc sdk日志上传url
-spec get_junhai_upload() ->
    string().
%%-----------------------------------------------
get_junhai_upload() ->
    get_env(junhai_upload).


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
get_env(Key) ->
    case application:get_env(game_env, Key) of
        {ok, Val} ->
            Val;
        _ ->
            ?nil
    end.

