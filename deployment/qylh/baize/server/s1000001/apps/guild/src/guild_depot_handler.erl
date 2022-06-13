%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(guild_depot_handler).

-include("bag.hrl").
-include("game.hrl").
-include("item.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([init/1]).
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
init(GuildID) ->
	GuildDepot = #guild_depot{
		id    = GuildID,
		cells = lists:seq(1, 200),
		items = #{}
	},
	guild_data:set(GuildDepot).

%% 仓库信息
handle(?GUILD_DEPOT_INFO, _Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	#role_guild{guild=GuildID, score=Score} = role_data:get(?DB_ROLE_GUILD),
	GuildDepot = get_guild_depot(RoleSt#role_st.gpid),
	Items = [
		item_util:p_item_base(Item)
		|| Item <- maps:values(GuildDepot#guild_depot.items)
	],
	?ucast(#m_guild_depot_info_toc{
		score = Score,
		items = Items,
		logs  = guild_util:get_donate_logs(GuildID)
	});

%% 物品信息
handle(?GUILD_DEPOT_DETAIL, Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	#m_guild_depot_detail_tos{uid=UID} = Tos,
	#role_st{gpid=GuildPid} = RoleSt,
	#guild_depot{items=Items} = get_guild_depot(GuildPid),
	Item = maps:get(UID, Items, ?nil),
	?_check(Item /= ?nil, ?ERR_GUILD_DEPOT_NO_ITEM),
	?ucast(#m_guild_depot_detail_toc{item=item_util:p_item(Item)});

%% 捐献
handle(?GUILD_DEPOT_DONATE, Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	#m_guild_depot_donate_tos{uid=UID} = Tos,
	{ok, Item} = role_bag:get_item(UID),
	Score = cfg_equip:donate(Item#p_item.id),
	?_check(Score > 0, ?ERR_GUILD_CANNOT_DONATE),
	#role_st{role=RoleID, name=RoleName, guild=GuildID, gpid=GuildPid} = RoleSt,
	Succ = fun() ->
		{ok, Item2} = guild_agent:donate(GuildPid, RoleID, RoleName, Item, Score),
		Item2
	end,
	{ok, _, Item2} = role_bag:cost([{cellid, UID}], ?LOG_GUILD_DONATE, Succ, RoleSt),
	RoleGuild = #role_guild{score=OldScore} = role_data:get(?DB_ROLE_GUILD),
	role_data:set(RoleGuild#role_guild{score=OldScore+Score}),
	role_event:event(?EVENT_GUILD_DONATE, Item#p_item.id),
	guild_util:add_donate_log(GuildID, 1, RoleID, RoleName, Item2, Score);

%% 兑换
handle(?GUILD_DEPOT_EXCH, Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	#m_guild_depot_exch_tos{uid=UID} = Tos,
	#role_st{role=RoleID, name=RoleName, guild=GuildID, gpid=GuildPid} = RoleSt,
	#guild_depot{items=Items} = get_guild_depot(GuildPid),
	Item  = maps:get(UID, Items, ?nil),
	?_check(Item /= ?nil, ?ERR_GUILD_DEPOT_NO_ITEM),
	#cfg_item{bag=BagID} = cfg_item:find(Item#p_item.id),
	?_check(role_bag:get_empty(BagID) > 0, ?ERR_BAG_NO_SPACE),
	Score = cfg_equip:donate(Item#p_item.id),
	RoleGuild = #role_guild{score=HadScore} = role_data:get(?DB_ROLE_GUILD),
	?_check(HadScore >= Score, ?ERR_GUILD_EXCH_LACK_SCORE),
	ok = guild_agent:exch(GuildPid, 1, RoleID, RoleName, Item, Score),
	role_bag:gain([Item], ?LOG_GUILD_EXCH, RoleSt),
	role_data:set(RoleGuild#role_guild{score=HadScore-Score}),
	guild_util:add_donate_log(GuildID, 2, RoleID, RoleName, Item, Score);

%% 换购
handle(?GUILD_DEPOT_BUY, Tos, RoleSt) ->
	guild_util:ensure_had_join(RoleSt),
	#m_guild_depot_buy_tos{item_id=ItemID, num=Num} = Tos,
	Score = cfg_guild_exch:find(ItemID)*Num,
	?_check(Score > 0, ?ERR_GAME_BAD_ARGS),
	RoleGuild = #role_guild{score=HadScore} = role_data:get(?DB_ROLE_GUILD),
	?_check(HadScore >= Score, ?ERR_GUILD_EXCH_LACK_SCORE),
	role_bag:gain([{ItemID, Num}], ?LOG_GUILD_EXCH, RoleSt),
	role_data:set(RoleGuild#role_guild{score=HadScore-Score}),
	#role_st{role=RoleID, name=RoleName, guild=GuildID, gpid=GuildPid} = RoleSt,
	Item = item_util:new_item(ItemID, Num, #{}),
	guild_agent:exch(GuildPid, 2, RoleID, RoleName, Item, Score),
	guild_util:add_donate_log(GuildID, 2, RoleID, RoleName, Item, Score);

%% 销毁
handle(?GUILD_DEPOT_DESTROY, Tos, RoleSt) ->
	#m_guild_depot_destroy_tos{uids=UIDs} = Tos,
	?_check(ut_misc:is_unique(UIDs), ?ERR_GAME_BAD_ARGS),
	#role_st{role=RoleID, gpid=GuildPid} = RoleSt,
	ok = guild_agent:destroy(GuildPid, RoleID, UIDs).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
get_guild_depot(GuildPid) ->
	{ok, [GuildDepot]} = guild_agent:get_data(GuildPid, [?DB_GUILD_DEPOT]),
	GuildDepot.
