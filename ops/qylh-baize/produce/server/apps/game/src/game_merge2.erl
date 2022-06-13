%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(game_merge2).

-include("friend.hrl").
-include("game.hrl").
-include("guild.hrl").
-include("guildwar.hrl").
-include("market.hrl").
-include("ranking.hrl").
-include("enum.hrl").
-include("table.hrl").

%% API
-export([merge/1]).
-export([post/0]).
-export([dir_merge/1, dir_merge_subffix/1]).

-record(mergeing, {
	merge_to            % 合到哪个服
	, role_names    = #{} % 玩家名称 RoleName => true
	, dup_roles     = []  % 重名玩家 [RoleID]
	, guild_names   = #{} % 帮派名称 GuildName => true
	, dup_guilds    = []  % 重名公会 [GuildID]
	, del_roles     = #{} % 删号玩家 RoleID => [{level,Level},{login,Login},{vip,Vip}]
	, gw_results    = []  % 公会战结果
	, compete_roles = []  % 钻石擂台报名
}).
-define(ETS_TAB(TAB, SUID), ut_conv:to_atom( lists:concat(["merge_", Tab, "_", SUID]) )).
%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
dir_merge() ->
	filename:dirname(db:system_info(directory)) ++ "/data/".

dir_merge(SUID) ->
	filename:dirname(db:system_info(directory)) ++ "/data" ++ dir_merge_subffix(SUID).

dir_merge_subffix(SUID) ->
	"_" ++ ut_conv:to_list(SUID) ++ "/".

merge(SUIDs) ->
	?info("~ts", ["正在准备合服数据..."]),
	Fun =
		fun(#r_tab{name = Tab}) ->
			[ets:new(?ETS_TAB(Tab, SUID), [public, named_table,compressed, set, {keypos, 2}]) || SUID <- SUIDs]
		end,
	lists:foreach(Fun, table:tabs()),
	set_merge_info(#mergeing{merge_to=lists:last(SUIDs)}),
	% 读取并处理数据
	[ok = read_data(SUID) || SUID <- SUIDs],
	% 删号
	delete_role(),
	% 合服
	?info("~ts", ["开始合服..."]),
	Dir = dir_merge(),
	db:stop(),
	db:start([{dir, Dir}]),
	ok = db:wait_for_tables(db:system_info(local_tables), infinity),
	[ok = merge_data(SUID) || SUID <- SUIDs],
	post_merge(SUIDs),
	?info("~ts", ["合服成功！"]),
	ok.

post() ->
	case not cluster:is_cross() of
		true  ->
			PostMerge = game_misc:read(post_merge, []),
			case PostMerge == [] of
				true  ->
					ignore;
				false ->
					rank:clear_rank(180501),
					rank:clear_rank(180502),
					rank:clear_rank(180503),
					rank:clear_rank(180504),
					rank:clear_rank(180505),
					rank:clear_rank(180506),
					[do_post(E) || E <- PostMerge],
					?_if(not cluster:is_center(), do_post(rank)),
					?_if(cluster:is_local(), do_post(guild)),
					#merge{suids=MergedSUIDs} = game_misc:read(merge, #merge{}),
					MergeTo = game_env:get_suid(),
					lists:foreach(fun
													(SUID) ->
														web_request:get("/api/server/merged/~w/~w", [SUID, MergeTo])
												end, MergedSUIDs),
					game_misc:delete(post_merge)
			end;
		false ->
			ignore
	end,
	ok.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
-define(k_merge, {?MODULE, merge}).
get_merge_info() ->
	get(?k_merge).

set_merge_info(Merge) ->
	put(?k_merge, Merge).

-define(k_data, {?MODULE, SUID, Tab}).
%%get_data(SUID, Tab) ->
%%	ets:tab2list(?ETS_TAB(Tab, SUID)).
%%	get(?k_data).

set_data(SUID, Tab, Data) ->
	ets:insert(?ETS_TAB(Tab, SUID), Data),
	erlang:garbage_collect().
%%	put(?k_data, Data).


read_data(SUID) ->
	Dir = dir_merge(SUID),
	db:stop(),
	db:start([{dir, Dir}]),
	ok = db:wait_for_tables(db:system_info(local_tables), infinity),
%%	clear_table(),
%%	?info("~ts", ["正在还原数据库..."]),
%%	Opaque = game_util:mnesia_opaque(SUID),
%%	{atomic, _} = mnesia:restore(Opaque, []),
%%	?info("~ts", ["数据库还原成功"]),
	?info("~ts~w~ts", ["正在读取【", SUID, "】服数据..."]),
	% 处理玩家表
	read_data2(SUID, table:role_tabs()),
	% 处理公会表
	read_data2(SUID, table:guild_tabs()),
	% 处理全局表
	read_data2(SUID, table:game_tabs()),
%%	clear_table(),
	?info("~ts~w~ts~n", ["【", SUID, "】服数据读取完毕"]),
	ok.

%%clear_table() ->
%%	lists:foreach(fun
%%		(#r_tab{name=Tab}) ->
%%			db:clear_table(Tab)
%%	end, table:tabs()).

read_data2(SUID, Tabs) ->
	lists:foreach(fun
									(#r_tab{rec=Tab}) ->
										Data   = db:dirty_match_all(Tab),
										Merge  = get_merge_info(),
										Merge2 = read_data3(Tab, Data, Merge),
										set_merge_info(Merge2),
										set_data(SUID, Tab, Data)
								end, Tabs).

read_data3(role_info, Data, Merge) ->
	DelConds = delete_conds(),
	LimLevel = proplists:get_value(level, DelConds),
	LimLogin = proplists:get_value(login, DelConds),
	lists:foldl(fun
								(Info, AccMerge) ->
									#role_info{id=RoleID, name=Name, level=Level, login=Login} = Info,
									#mergeing{role_names=Names, dup_roles=Dup, del_roles=Del} = AccMerge,
									Dup2 = case maps:is_key(Name, Names) of
													 true  -> [RoleID | Dup];
													 false -> Dup
												 end,

									Flag1 = case Level =< LimLevel of
														true  -> [{level,Level}];
														false -> []
													end,
									Flag2 = case ut_time:seconds() - Login >= LimLogin*24*60*60 of
														true  -> [{login,Login} | Flag1];
														false -> Flag1
													end,
									Del2 = case Flag2 == [] of
													 true  -> Del;
													 false -> ut_misc:maps_append(RoleID, Flag2, Del)
												 end,

									AccMerge#mergeing{
										role_names = maps:put(Name, true, Names),
										dup_roles  = Dup2,
										del_roles  = Del2
									}
							end, Merge, Data);
read_data3(role_vip, Data, Merge) ->
	DelConds = delete_conds(),
	LimVip   = proplists:get_value(vip, DelConds),
	lists:foldl(fun
								(Vip, AccMerge) ->
									#role_vip{id=RoleID, level=VipLv} = Vip,
									#mergeing{del_roles=Del} = AccMerge,
									Flag = case VipLv =< LimVip of
													 true  -> [{vip,VipLv}];
													 false -> []
												 end,
									Del2 = case Flag == [] of
													 true  -> Del;
													 false -> ut_misc:maps_append(RoleID, Flag, Del)
												 end,
									AccMerge#mergeing{del_roles=Del2}
							end, Merge, Data);
read_data3(guild_info, Data, Merge) ->
	lists:foldl(fun(#guild_info{id=ID},AccMerge) when ID == ?nil orelse ID == 0-> AccMerge;
								(Info, AccMerge) ->
									#guild_info{id=GuildID, name=Name} = Info,
									#mergeing{guild_names=Names, dup_guilds=Dup} = AccMerge,
									Dup2 = case maps:is_key(Name, Names) of
													 true  -> [GuildID | Dup];
													 false -> Dup
												 end,

									AccMerge#mergeing{
										guild_names = maps:put(Name, true, Names),
										dup_guilds  = Dup2
									}
							end, Merge, Data);
read_data3(_Tab, _Data, Merge) ->
	Merge.

delete_conds() ->
	cfg_game:merge_delete().

delete_role() ->
	?info("~ts", ["以下玩家将被删除"]),
	Merge = #mergeing{del_roles=Del, dup_roles=DupRoleIDs} = get_merge_info(),
	Del2  = maps:filter(fun
												(RoleID, Flags) ->
													CanDel = proplists:is_defined(level, Flags) andalso
														proplists:is_defined(login, Flags) andalso
														proplists:is_defined(vip, Flags),
													?_if(
														CanDel,
														?info("role=~w  level=~-4w vip=~-2w login=~s", [
															RoleID,
															proplists:get_value(level, Flags),
															proplists:get_value(vip, Flags),
															ut_time:seconds_to_string(proplists:get_value(login, Flags))
														])
													),
													CanDel
											end, Del),
	DupRoleIDs2 = DupRoleIDs -- maps:keys(Del2),
	?info("~ts ~w ~ts", ["共计 ", maps:size(Del2), " 个玩家被删除"]),
	set_merge_info(Merge#mergeing{del_roles=Del2, dup_roles=DupRoleIDs2}).

merge_data(SUID) ->
	erlang:garbage_collect(),
	?info("~ts~w~ts", ["正在合并【", SUID, "】服数据..."]),
	% 合并玩家表
	merge_role_tab(SUID),
	% 合并公会表
	merge_guild_tab(SUID),
	% 合并全局表
	merge_game_tab(SUID),
	?info("~ts~w~ts~n", ["【", SUID, "】服合并完成"]),
	ok.

merge_role_tab(SUID) ->
	#mergeing{del_roles=Del} = get_merge_info(),
	lists:foreach(fun
									(#r_tab{rec=Tab}) ->
											ets:foldl(fun
																(Rec,_) ->
																			RoleID = element(2, Rec),
																			case maps:is_key(RoleID, Del) of
																				true  ->
																					ignore;
																				false ->
																					Rec2 = merge_role_tab2(Tab, Rec),
																					db:dirty_write(Tab, Rec2)
																			end
															end,[],?ETS_TAB(Tab, SUID))
								end, table:role_tabs()).

merge_role_tab2(role_info, Info) ->
	#mergeing{dup_roles=Dup} = get_merge_info(),
	#role_info{id=RoleID, name=Name, zoneid=ZoneID} = Info,
	case lists:member(RoleID, Dup) of
		true  ->
			Name2 = new_role_name(ZoneID, Name),
			Info#role_info{name=Name2};
		false ->
			Info
	end;
merge_role_tab2(role_misc, Misc) ->
	Misc#role_misc{enemy_suids=#{}};
merge_role_tab2(role_arena, Arena) ->
	Arena#role_arena{rank=0};
merge_role_tab2(_Tab, Rec) ->
	Rec.

new_role_name(ZoneID, Name) ->
	"s" ++ ut_conv:to_list(ZoneID) ++ "." ++ Name.


merge_guild_tab(SUID) ->
	lists:foreach(fun
									(#r_tab{rec=Tab}) ->
											ets:foldl(fun
																		(Rec,_) ->
																			Rec2 = merge_guild_tab2(Tab, Rec),
																			case merge_guild_tab2(Tab, Rec) of
																				#guild_info{} = Rec2 ->
																					db:dirty_write(Tab, Rec2);
																				#guild_depot{} = Rec2 ->
																					db:dirty_write(Tab, Rec2);
																				#guild_redenvelope{} = Rec2 ->
																					db:dirty_write(Tab, Rec2);
																				_ ->
																					ignore
																			end

																	end,[], ?ETS_TAB(Tab, SUID))
								end, table:guild_tabs()).

merge_guild_tab2(guild_info, Info) ->
	#mergeing{del_roles=Del, dup_guilds=Dup} = get_merge_info(),
	#guild_info{
		id     = GuildID,
		name   = Name,
		membs  = Membs,
		apply  = Apply,
		runfor = Runfor
	} = Info,
	case is_integer(GuildID) andalso GuildID > 0   of
		true ->
			Name2 = case lists:member(GuildID, Dup) of
								true  ->
									ZoneID = game_uid:guid2ssid(GuildID),
									new_guild_name(ZoneID, Name);
								false ->
									Name
							end,
			Membs2  = [Memb || Memb <- Membs, not maps:is_key(Memb#guild_memb.id, Del)],
			Apply2  = [ID || ID <- Apply, not maps:is_key(ID, Del)],
			Runfor2 = [{ID,Post} || {ID,Post} <- Runfor, not maps:is_key(ID, Del)],
			Info#guild_info{name=Name2, membs=Membs2, apply=Apply2, runfor=Runfor2};
		_ ->
			ignore
	end;

merge_guild_tab2(_Tab, Data) ->
	Data.

new_guild_name(ZoneID, Name) ->
	"s" ++ ut_conv:to_list(ZoneID) ++ "." ++ Name.


merge_game_tab(SUID) ->
	lists:foreach(fun
									(#r_tab{rec=Tab}) ->
										case lists:member(Tab, clear_tabs()) of
											true  ->
												ignore;
											false ->
												ets:foldl(fun
																		(Rec,_) ->
																			case merge_game_tab2(Tab,Rec) of
																				false -> ignore;
																				Rec2 ->db:dirty_write(Tab, Rec2)
																			end
																	end,[], ?ETS_TAB(Tab, SUID))
										end
								end, table:game_tabs()).

clear_tabs() ->
	[
		arena
		, arena_misc
		, redenvelope
		, gw_field
		, gw_guild
	].

merge_game_tab2(game_user, Rec) ->
	#mergeing{del_roles=Del} = get_merge_info(),
	 #game_user{id=UserID, roles=RoleIDs0} = Rec ,
								RoleIDs1 = [ID || ID <- RoleIDs0, not maps:is_key(ID, Del)],
								case db:dirty_read(?DB_GAME_USER, UserID) of
									[User2 = #game_user{roles=RoleIDs2}] ->
										User2#game_user{roles=RoleIDs1++RoleIDs2};
									[] ->
		Rec#game_user{roles=RoleIDs1}
	end;

merge_game_tab2(game_rank, Rec) ->
	#mergeing{del_roles=Del} = get_merge_info(),
	#game_rank{id=RankID, ranklist=RankList0, alldata=AllData0} = Rec ,
								RankList1 = [R || R <- RankList0, not maps:is_key(R#rankitem.id, Del)],
								AllData1  = maps:without(maps:keys(Del), AllData0),
								case db:dirty_read(?DB_GAME_RANK, RankID) of
									[Rank2 = #game_rank{ranklist=RankList2, alldata=AllData2}] ->
										Rank2#game_rank{
											ranklist = RankList1 ++ RankList2,
											alldata  = maps:merge(AllData1, AllData2)
										};
									[] ->
			Rec#game_rank{ranklist=RankList1, alldata=AllData1}
	end;

merge_game_tab2(mailbox, Rec) ->
	#mergeing{del_roles=Del} = get_merge_info(),
	case not maps:is_key(Rec#mailbox.owner, Del) of
		true -> Rec;
		_ -> false
	end;
merge_game_tab2(friend, Rec) ->
	#mergeing{del_roles=Del} = get_merge_info(),
	case maps:is_key(Rec#friend.id, Del) of
												true  ->
													false;
												false ->
			#friend{applied=Applied, roles=Roles} = Rec,
													Roles2 = maps:without(maps:keys(Del), Roles),
													Num2   = length([R ||
														R <- maps:values(Roles2),
														R#friend_info.relation==?RELATION_FRIEND
													]),
			Rec#friend{
														applied    = Applied -- maps:keys(Del),
														friend_num = Num2,
														roles      = Roles2
			}
	end;

merge_game_tab2(chat_contact, Rec) ->
	#mergeing{del_roles=Del} = get_merge_info(),
	case maps:is_key(Rec#chat_contact.id, Del) of
												true  ->
													false;
												false ->
			Rec#chat_contact{
				contacts = Rec#chat_contact.contacts -- maps:keys(Del)
			}
	end;

merge_game_tab2(trade, Rec) ->
	#mergeing{del_roles=Del} = get_merge_info(),
	case not maps:is_key(Rec#trade.owner, Del) of
		true -> Rec;
		false -> false
	end;
merge_game_tab2(yy_role, Rec) ->
	#mergeing{del_roles=Del} = get_merge_info(),
	#yy_role{key={_,RoleID}} = Rec,
	case not maps:is_key(RoleID, Del) of
		true -> Rec;
		false -> false
	end;
merge_game_tab2(mirror, Rec) ->
	#mergeing{del_roles=Del} = get_merge_info(),
	case not maps:is_key(Rec#mirror.id, Del) of
		true -> Rec;
		false -> false
	end;
merge_game_tab2(dating, Rec) ->
	#mergeing{del_roles=Del} = get_merge_info(),
	case not maps:is_key(Rec#dating.id, Del) of
		true -> Rec ;
		false -> false
	end;
merge_game_tab2(yy_shop_act, Rec) ->
	#yy_shop_act{act_id=ActID, world_lv=WorldLv1, day=Day1} = Rec,
								case db:dirty_read(?DB_YY_SHOP_ACT, ActID) of
									[YYShopAct2] ->
										#yy_shop_act{world_lv=WorldLv2, day=Day2} = YYShopAct2,
			Rec#yy_shop_act{
											world_lv   = min(WorldLv1, WorldLv2),
											day        = min(Day1, Day2),
											shop       = #{},
											join_log   = [],
											reward_log = []
										};
									[] ->
			Rec#yy_shop_act{
											shop       = #{},
											join_log   = [],
											reward_log = []
										}
	end;

merge_game_tab2(game_misc, Rec) ->
	#mergeing{del_roles=Del, merge_to=SUID} = get_merge_info(),
	(#game_misc{key=Key, val=Val}) = Rec ,
											Result = case Key of
																 role_id ->
																	 case game_uid:guid2suid(Val) == SUID of
																		 true  -> {true, Val};
																		 false -> false
																	 end;
																 guild_id ->
																	 case game_uid:guid2suid(Val) == SUID of
																		 true  -> {true, Val};
																		 false -> false
																	 end;
																 trade_id ->
																	 case game_uid:guid2suid(Val) == SUID of
																		 true  -> {true, Val};
																		 false -> false
																	 end;
																 merge ->
																	 case db:dirty_read(?DB_GAME_MISC, merge) of
																		 [#game_misc{val=Val2}] ->
																			 {true, #merge{
																				 time  = ut_time:seconds(),
																				 suids = Val#merge.suids ++ Val2#merge.suids
																			 }};
																		 [] ->
																			 {true, Val}
																	 end;
																 market ->
																	 Dealing1 = [R || R={ID1,ID2,_} <- Val#market.dealing,
																		 not maps:is_key(ID1, Del),
																		 not maps:is_key(ID2, Del)
																	 ],
																	 case db:dirty_read(?DB_GAME_MISC, market) of
																		 [#game_misc{val=Val2}] ->
																			 {true, #market{dealing=Dealing1++Val2#market.dealing}};
																		 [] ->
																			 {true, #market{dealing=Dealing1}}
																	 end;
																 gw_result ->
																	 Merge  = get_merge_info(),
																	 Merge2 = Merge#mergeing{
																		 gw_results = [Val | Merge#mergeing.gw_results]
																	 },
																	 set_merge_info(Merge2),
																	 false;
																 compete_roles ->
																	 Merge  = get_merge_info(),
																	 Merge2 = Merge#mergeing{
																		 compete_roles = [Val | Merge#mergeing.compete_roles]
																	 },
																	 set_merge_info(Merge2),
																	 false;
																 _ ->
																	 false
															 end,
											case Result of
												{true, NewVal} ->
			#game_misc{key=Key, val=NewVal};
												false ->
													false
	end;
merge_game_tab2(_Tab, Data) ->
	Data.


post_merge(SUIDs) ->
	#mergeing{
		merge_to      = MergeTo,
		dup_roles     = RoleIDs,
		dup_guilds    = GuildIDs,
		gw_results    = GWResults,
		compete_roles = CompeteRoles
	} = get_merge_info(),
	case db:dirty_read(?DB_GAME_MISC, merge) of
		[#game_misc{val=Old}] ->
			db:dirty_write(?DB_GAME_MISC, #game_misc{
				key = merge,
				val = #merge{
					time  = ut_time:seconds(),
					suids = lists:delete(MergeTo, SUIDs ++ Old#merge.suids)
				}
			});
		[] ->
			db:dirty_write(?DB_GAME_MISC, #game_misc{
				key = merge,
				val = #merge{
					time  = ut_time:seconds(),
					suids = lists:delete(MergeTo, SUIDs)
				}
			})
	end,

	db:dirty_write(?DB_GAME_MISC, #game_misc{
		key = post_merge,
		val = [
			rank,
			{dup_role, RoleIDs},
			{dup_guild, GuildIDs},
			{gw_result, GWResults},
			{compete, CompeteRoles}
		]
	}),
	ok.

do_post(rank) ->
	RankServers = supervisor:which_children(rank_sup),
	lists:foreach(fun
									({_, Pid, _, _}) ->
										gen_server:cast(Pid, resort)
								end, RankServers);
do_post(guild) ->
	guild_manager:ranking();
do_post({dup_role, RoleIDs}) ->
	lists:foreach(fun
									(RoleID) ->
										mail:send(RoleID, ?MAIL_GUILD_MERGE_ROLE_RENAME, [{11002,1}])
								end, RoleIDs);
do_post({dup_guild, GuildIDs}) ->
	lists:foreach(fun
									(GuildID) ->
										case guild:get_chief(GuildID) of
											{ok, #guild_memb{id=RoleID}} ->
												mail:send(RoleID, ?MAIL_GUILD_MERGE_GUILD_RENAME, [{11003,1}]);
											_ ->
												?error("guild(~w) had no chief", [GuildID])
										end
								end, GuildIDs);
do_post({gw_result, Results}) ->
	{FinResult, _} = lists:foldl(fun
																 (Result, Acc={_,AccPower}) ->
																	 #gw_result{winner=WinGuild} = Result,
																	 case guild:get_chief(WinGuild) of
																		 {ok, #guild_memb{id=RoleID}} ->
																			 case db:dirty_read(?DB_ROLE_ATTR, RoleID) of
																				 [#role_attr{power=Power}] when Power > AccPower ->
																					 {Result,Power};
																				 _ ->
																					 Acc
																			 end;
																		 _ ->
																			 Acc
																	 end
															 end, {#gw_result{},0}, Results),
	game_misc:write(gw_result, FinResult, true);
do_post({compete, CompeteRoles}) ->
	game_misc:write(compete_roles, CompeteRoles).

