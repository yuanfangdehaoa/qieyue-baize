%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(game_main).

-include("game.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").

%% API
-export([start/1]).
-export([stop/0]).
-export([ping/0]).
-export([kick/1]).
-export([migrate/1]).
-export([backup/2]).
-export([merge/2, merge2/2]).
-export([schema/1]).

-export([start_mnesia/0, start_mnesia/1, start_mnesia_merge/0]).

-export([fix_fragment/0]).


%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start(?SERVER_TYPE_LOCAL) ->
	ok = game_code:clash(),
	set_version(),
	ok = start_app(os_mon),
	ok = start_app(lager),
	ok = start_app(poolboy),
	ok = start_app(ranch),
	ok = start_app(hackney),
	ok = start_app(game_env),
	{_, _} = sdk:route(), %% 确保下充值不掉单
	ok = start_mnesia(),
	ok = mnesia_migrate(),
	ok = start_app(log),
	ok = start_app(yunying),
	ok = start_app(game),
	ok = start_app(rank),
	ok = start_ranks(),
	ok = start_app(cluster),
	ok = start_app(chat),
	ok = start_app(scene),
	ok = start_scenes(),
	ok = start_app(guild),
	ok = start_app(team),
	ok = start_app(role),
	ok = start_app(web),
	init_dbgtools(),
	ok = start_complete(),
	ok = start_gateway(),
	game_entry:open(),
	started_notify(),
	ok;
start(?SERVER_TYPE_CROSS) ->
	ok = game_code:clash(),
	ok = start_app(os_mon),
	ok = start_app(lager),
	ok = start_app(poolboy),
	ok = start_app(hackney),
	ok = start_app(game_env),
	ensure_center_started(),
	ok = start_mnesia(),
	ok = start_app(game),
	ok = start_app(yunying),
	ok = start_app(rank),
	ok = start_app(cluster),
	ok = start_app(scene),
	ok = start_scenes(),
	init_dbgtools(),
	ok = start_complete(),
	started_notify(),
	ok;
start(?SERVER_TYPE_CENTER) ->
	ok = game_code:clash(),
	ok = start_app(os_mon),
	ok = start_app(lager),
	ok = start_app(poolboy),
	ok = start_app(hackney),
	ok = start_app(game_env),
	ok = start_mnesia(),
	ok = mnesia_migrate(),
	ok = start_app(game),
	ok = start_app(cluster),
	init_dbgtools(),
	ok = start_complete(),
	started_notify(),
	ok.

stop() ->
	stop(game_env:get_type()).

stop(?SERVER_TYPE_LOCAL) ->
	game_entry:close(),
	game_stop:pre(),
	stop_gateway(),
	stop_app(role),
	stop_app(guild),
	stop_app(scene),
	stop_app(chat),
	stop_app(game),
	stop_app(team),
	stop_app(rank),
	stop_app(yunying),
	stop_app(log),
	stop_app(mnesia),
	catch stopped_notify(),
	init:stop(),
	ok;
stop(?SERVER_TYPE_CROSS) ->
	stop_app(scene),
	stop_app(chat),
	stop_app(game),
	stop_app(team),
	stop_app(rank),
	catch stopped_notify(),
	init:stop(),
	ok;
stop(?SERVER_TYPE_CENTER) ->
	stop_app(game),
	catch stopped_notify(),
	init:stop(),
	ok.

ping() ->
	case ut_time:is_debug() of
		true  -> pang;
		false -> pong
	end.

kick(Reqs) ->
	kickout_roles(Reqs).

migrate(ServerType) ->
	set_version(),
	ok = start_app(lager),
	ok = start_app(game_env),
	ok = start_mnesia(ServerType),
	Version = ut_conv:to_list( game_env:get_version() ),
	ok = mnesia_migrate(Version).

backup(ServerType, SUID) ->
	ok = start_app(lager),
	ok = start_mnesia(ServerType),
	ok = mnesia:backup(game_util:mnesia_opaque(SUID)),
	?info("backup succ").

merge(_ServerType, SUIDs) ->
	ok = start_app(lager),
	ok = start_app(game_env),
	ok = start_mnesia_merge(),
	ok = game_merge:merge(SUIDs),
	?info("merge succ").

merge2(_ServerType, SUIDs) ->
	Pred =
		fun(SUID) ->
			makesure_data(SUID)
		end,
	case lists:all(Pred, SUIDs) of
		true ->
			ok = start_app(lager),
			ok = start_app(game_env),
			ok = start_mnesia_merge2(),
			ok = game_merge2:merge(SUIDs),
			?info("merge succ");
		false ->
			?info("merge data not prepare")
	end.

makesure_data(SUID) ->
	Dir = game_merge:dir_merge(SUID),
	filelib:is_dir(Dir).

schema(ServerType) ->
	ok = start_mnesia(ServerType).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
start_app(App) ->
    {ok, _} = application:ensure_all_started(App),
	?info("start ~w", [App]),
	ok.

stop_app(App) ->
	application:stop(App),
	?info("stop ~w", [App]),
	ok.

set_version() ->
    {ok, [[Vsn]]} = init:get_argument(vsn),
    application:set_env(game_env, version, ut_conv:to_binary(Vsn)).

start_mnesia() ->
	start_mnesia(game_env:get_type()).

start_mnesia(?SERVER_TYPE_CROSS) ->
	ok = db:start(),
	mnesia:change_config(extra_db_nodes, [game_env:get_center()]),
	db:on_game_start(),
	?info("start mnesia"),
	ok;
start_mnesia(ServerType) ->
	filelib:ensure_dir( db:system_info(directory) ++ "/" ),
	db:create_schema([node()]),
	ok = db:start(),
	TabList = case ServerType of
							?SERVER_TYPE_LOCAL  ->
								table:role_tabs() ++ table:guild_tabs() ++ table:game_tabs();
							?SERVER_TYPE_CENTER ->
								table:cross_tabs() ++ table:game_tabs()
						end,
	[create_mnesia_table(Tab) || Tab <- TabList],
	ok = db:wait_for_tables(db:system_info(local_tables), infinity),
	db:on_game_start(),
	migrate_db_table(),
	?info("start mnesia"),
	ok.


start_mnesia_merge() ->
	filelib:ensure_dir( db:system_info(directory) ++ "/" ),
	db:create_schema([node()]),
	ok = db:start(),
	TabList = table:role_tabs() ++ table:guild_tabs() ++ table:game_tabs(),
	Fun =
		fun(Tab) ->
			Opts = lists:keydelete(disc_only_copies, 1, Tab#r_tab.opts),
			Opts2 = lists:keydelete(disc_copies, 1, Opts),
			Opts3 = [{disc_copies, [node()]} | Opts2],
			db:create_table(Tab#r_tab.name, Opts3)
		end,
	lists:foreach(Fun, TabList),
	ok = db:wait_for_tables(db:system_info(local_tables), infinity),
	db:on_game_start(),
	?info("start mnesia"),
	ok.


start_mnesia_merge2() ->
	filelib:ensure_dir( db:system_info(directory) ++ "/" ),
	db:create_schema([node()]),
	ok = db:start(),
	TabList = table:role_tabs() ++ table:guild_tabs() ++ table:game_tabs(),
	Fun =
		fun(Tab) ->
			create_mnesia_table(Tab)
		end,
	lists:foreach(Fun, TabList),
	ok = db:wait_for_tables(db:system_info(local_tables), infinity),
	db:on_game_start(),
	?info("start mnesia"),
	ok.


create_mnesia_table(Tab) ->
	L = tables_fragment(),
	FragmentCount = table_fragment_count(),
	Opts =
		case lists:member(Tab#r_tab.name, L) of
			true ->
				Opt =
					{frag_properties,
						[
							{node_pool,[node()]},
							{n_fragments, FragmentCount},
							{n_disc_only_copies,1}
						]
					},
				[Opt|Tab#r_tab.opts];
			_ ->
				Tab#r_tab.opts
		end,
	db:create_table(Tab#r_tab.name, Opts).

tables_fragment() ->
	[?DB_ROLE_BAG, ?DB_MAILBOX].

table_fragment_count() ->
	8.

migrate_db_table() ->
	[migrate_db_table(Tab) || Tab <- tables_fragment()].

%% 手动修复未分片的表
fix_fragment() ->
	[do_migrate_db_table(Tab) || Tab <- tables_fragment()].


migrate_db_table(Tab) ->
	case lists:member(Tab, tables_fragment()) of
		true ->
			case mnesia:table_info(Tab, size) > 0 of
				true ->
					Nl = lists:seq(2, table_fragment_count()),
					Pred =
						fun(N) ->
							TabFrag = ut_conv:to_atom(lists:concat([Tab, "_frag", N])),
							mnesia:table_info(TabFrag, size) == 0
						end,
					case lists:all(Pred, Nl) of
						true ->
							do_migrate_db_table(Tab);
						false ->
							igore
					end;
				false ->
					igore
			end;
		false ->
			igore
	end.

do_migrate_db_table(Tab) ->
	Keys = mnesia:dirty_all_keys(Tab),
	F =
		fun(Key) ->
			case db:dirty_read(Tab, Key) of
				[] ->
					[Rec] = mnesia:dirty_read(Tab, Key),
					mnesia:dirty_delete(Tab, Key),
					db:dirty_write(Rec);
				_ ->
					igore
			end
		end,
	lists:foreach(F, Keys).

start_ranks() ->
	[rank_sup:start_rank(RankID) || RankID <- cfg_rank:local()],
	ok.

start_scenes() ->
	start_scenes(game_env:get_type()).

start_scenes(ServerType) ->
	Kind = case ServerType of
		?SERVER_TYPE_LOCAL -> ?SCENE_KIND_LOCAL;
		?SERVER_TYPE_CROSS -> ?SCENE_KIND_CROSS
	end,
	Scenes = cfg_scene:scenes(Kind, ?SCENE_TYPE_CITY)
		  ++ cfg_scene:scenes(Kind, ?SCENE_TYPE_FIELD)
		  ++ cfg_scene:scenes(Kind, ?SCENE_TYPE_BOSS),
	[scene:create(SceneID) || SceneID <- Scenes],
	ok.

start_gateway() ->
	Host = game_env:get_host(),
	Port = game_env:get_port(),
	Opts = [{ip,Host}, {port,Port}],
	{ok, _} = ranch:start_listener(
		gateway, ranch_tcp, Opts, gateway_agent, #{}
	),
	ranch:set_max_connections(gateway, 5000),
	?info("start gateway(~s:~w)", [game_env:get_env(host), Port]),
	ok.

start_complete() ->
	game_alarm:start(),
	start_complete(game_env:get_type()).

start_complete(?SERVER_TYPE_CROSS) ->
	gen_server:cast(cluster_cross, started);
start_complete(ServerType) ->
	game_start:post(ServerType),
	game_merge:post(),
	ok.

stop_gateway() ->
	ranch:stop_listener(gateway),
	?info("stop gateway"),
	ok.

mnesia_migrate() ->
	mnesia_migrate(?nil).

mnesia_migrate(MigrateVsn) ->
	Fun = fun(File, Acc) ->
		Mod = ut_conv:to_atom(filename:basename(File, ".beam")),
		[Mod | Acc]
	end,
	ModList1 = filelib:fold_files(
		"ebin", "update_mnesia_.*\.beam", false, Fun, []
	),
	ModList2 = lists:sort(ModList1),
	case do_migrate(ModList2, MigrateVsn) of
		ok -> ignore;
		_  -> ?MODULE:stop()
	end,
	ok.

do_migrate([], _MigrateVsn) ->
	ok;
do_migrate([Mod | T], MigrateVsn) ->
	Migration = game_misc:dirty_read(migration, []),
	Version   = Mod:vsn(),
	RunBefore = lists:member(Version, Migration),
	case MigrateVsn == Version orelse (not RunBefore) of
		true  ->
			case catch Mod:run() of
				ok ->
					game_misc:dirty_write(migration, [Version | Migration]),
					?info("~s migrate run succ", [Version]),
					RunOnce = (not RunBefore) andalso erlang:function_exported(Mod, once, 0),
					case RunOnce of
						true  ->
							case catch Mod:once() of
								ok -> ?info("~s migrate once succ", [Version]);
								R  -> ?error("~s migrate once fail: ~p", [Version, R])
							end;
						false ->
							ignore
					end,
					do_migrate(T, MigrateVsn);
				R  ->
					?error("~s migrate run fail: ~p", [Version, R])
			end;
		false ->
			do_migrate(T, MigrateVsn)
	end.

kickout_roles(Reqs) ->
	lists:foreach(fun
		(RoleID) ->
			role:kickout(RoleID, Reqs, ?ERR_GAME_MAINTAIN)
	end, online_server:get_roles()).

started_notify() ->
	ok.
% started_notify() ->
% 	Type = game_env:get_type(),
% 	SUID = game_env:get_suid(),
%   web_request:get("/api/server/started/~w/~w", [Type,SUID]).

stopped_notify() ->
	Type = game_env:get_type(),
	SUID = game_env:get_suid(),
    web_request:get("/api/server/stopped/~w/~w", [Type,SUID]).

ensure_center_started() ->
	Center = game_env:get_center(),
	case Center == ?nil of
		true  ->
			ok;
		false ->
			case net_kernel:connect_node(Center) of
				true  -> ok;
				false -> ?fatal("center not start: ~w", [Center]), init:stop()
			end
	end.


-ifdef(DEBUG).

init_dbgtools() ->
	mochiglobal:put(gm_time, game_misc:read(gm_time)),
	{ok, _} = reloader:start_link(),
	mochiglobal:put(gateway_trace_role, ?nil),
	mochiglobal:put(gateway_trace_all, false),
	mochiglobal:put(gateway_trace_pkg, []),
	?_if(
		game_util:is_exported(trace_package, load, 0),
		trace_package:load()
	),
	ok.

-else.

init_dbgtools() ->
	mochiglobal:put(gm_time, ?nil),
	mochiglobal:put(gateway_trace_role, []),
	mochiglobal:put(gateway_trace_all, false),
	mochiglobal:put(gateway_trace_pkg, []),
	ok.

-endif.
