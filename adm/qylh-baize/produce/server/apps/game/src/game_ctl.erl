%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(game_ctl).

-include("game.hrl").
-include("proto.hrl").
-include("yunying.hrl").

%% API
-export([start/0]).
-export([stop/0]).
-export([ping/0]).
-export([hot/0]).
-export([run/0]).
-export([migrate/0]).
-export([backup/0]).
-export([merge/0, merge2/0]).
-export([schema/0]).
-export([do_hot/1]).
-export([do_run/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 启动服务器
start() ->
    Type = get_argument(type, fun ut_conv:to_atom/1),
    game_main:start(Type).

%% 关闭服务器
stop() ->
    Node = get_argument(node, fun ut_conv:to_atom/1),
    rpc:call(Node, game_main, stop, []).

%% 测试连接
ping() ->
    Node = get_argument(node, fun ut_conv:to_atom/1),
    case pong == rpc:call(Node, game_main, ping, []) of
        true  -> erlang:halt(0);
        false -> erlang:halt(1)
    end.

%% 热更
hot() ->
    Node = get_argument(node, fun ut_conv:to_atom/1),
    Mods = get_arguments(mod, fun ut_conv:to_atom/1),
    rpc:call(Node, ?MODULE, do_hot, [Mods]).

%% 执行函数
run() ->
    Node = get_argument(node, fun ut_conv:to_atom/1),
    Mod  = get_argument(mod, fun ut_conv:to_atom/1),
    Fun  = get_argument(func, fun ut_conv:to_atom/1),
    rpc:call(Node, ?MODULE, do_run, [{Mod, Fun}]).

%% 执行mnesia更新脚本
migrate() ->
    Type = get_argument(type, fun ut_conv:to_atom/1),
    game_main:migrate(Type).

%% 备份
backup() ->
    SUID = get_argument(suid, fun ut_conv:to_integer/1),
    Type = get_argument(type, fun ut_conv:to_atom/1),
    game_main:backup(Type, SUID).

%% 合服
merge() ->
    Type  = get_argument(type, fun ut_conv:to_atom/1),
    SUIDs = get_arguments(suids, fun ut_conv:to_integer/1),
    game_main:merge(Type, SUIDs).

merge2() ->
    Type = get_argument(type, fun ut_conv:to_atom/1),
    SUIDs = get_arguments(suids, fun ut_conv:to_integer/1),
    game_main:merge2(Type, SUIDs).

%% 生成schema文件
schema() ->
    Type = get_argument(type, fun ut_conv:to_atom/1),
    game_main:schema(Type).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
get_argument(Key, AsFunc) ->
    {ok, [[Val]]} = init:get_argument(Key),
    AsFunc(Val).

get_arguments(Key, AsFunc) ->
    {ok, [Vals]} = init:get_argument(Key),
    [AsFunc(Val) || Val <- Vals].
do_hot(Mods) ->
    ?info("game_ctl :================> ~p~n", [{?FUNCTION_NAME, Mods}]),
    do_hot2(Mods).

do_hot2([Mod | T]) ->
    catch do_hot_pre(Mod),
    case code:soft_purge(Mod) andalso code:load_file(Mod) of
        {module, _} ->
            case lists:member(Mod, cfg_hotconfig:all()) of
                true  ->
                    case Mod == cfg_yunying orelse Mod == cfg_festival of %%热更重新加载运营活动
                        true ->
                           yunying_manager:reload();
                        _ ->
                           ignore
                    end,
                    ?bcast(#m_game_hotconfig_toc{
                        config = ut_conv:to_list(cfg_hotconfig:client(Mod))
                    });

                false ->
                    ignore
            end,
            catch do_hot_post(Mod),
            ?info("~s reload success", [Mod]);
        {error, Reason} ->
            ?error("~s reload failed, reason: ~w", [Mod, Reason])
    end,
    do_hot2(T);

do_hot2([]) ->
    ok.

do_hot_pre(_Mod) ->
    igore.

do_hot_post(_Mod) ->
    igore.


do_run({Mod, Fun}) ->
    ?info("game_ctl :================> ~p~n", [{?FUNCTION_NAME, Mod, Fun}]),
    try
        Result = apply(Mod, Fun, []),
        ?info(
            "apply ~w:~w/0 success, result: ~w",
            [Mod, Fun, Result]
        )
    catch _:Reason ->
        ?error(
            "apply ~w:~w/0 failed, reason: ~w",
            [Mod, Fun, Reason]
        )
    end.
