%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(guild_war_handler).

-include("game.hrl").
-include("guild.hrl").
-include("guildwar.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 赛区信息
handle(?GUILD_WAR_FIELDS, _Tos, RoleSt) ->
	Fields = lists:foldl(fun
		(Field = #gw_field{zoneid=ZoneID}, AccFields) ->
			case lists:keyfind(ZoneID, #p_gw_field.id, AccFields) of
				false  ->
					[#p_gw_field{
						id = ZoneID,
						vs = [p_gw_versus(Field)]
					} | AccFields];
				PField ->
					PField2 = PField#p_gw_field{
						vs = lists:reverse(
							[p_gw_versus(Field) | PField#p_gw_field.vs]
						)
					},
					lists:keystore(ZoneID, #p_gw_field.id, AccFields, PField2)
			end
	end, [], lists:keysort(#gw_field.id, ets:tab2list(?ETS_GW_FIELD))),
	#gw_result{winner=Winner} = game_misc:read(gw_result, #gw_result{}),
	Chief = case Winner == 0 of
		true  ->
			?nil;
		false ->
			{ok, #guild_memb{id=ChiefID}} = guild:get_chief(Winner),
			role:get_base(ChiefID)
	end,
	?ucast(#m_guild_war_fields_toc{fields=Fields, role=Chief});

%% 主宰公会
handle(?GUILD_WAR_WINNER, _Tos, RoleSt) ->
	Result = game_misc:read(gw_result, #gw_result{}),
	Winner = Result#gw_result.winner,
	?ucast(#m_guild_war_winner_toc{
		guild   = Winner,
		victory = Result#gw_result.victory,
		breakup = Result#gw_result.breakup,
		roles   = [role:get_base(RoleID)
			|| RoleID <- guild:get_membids(Winner, ?GUILD_POST_VICE)
		],
		fetch   = role_count:get_times(?ROLE_COUNT_GW_REWARD) >= 1,
		v_allot = Result#gw_result.v_allot > 0,
		b_allot = Result#gw_result.b_allot > 0
	});

%% 分配奖励
handle(?GUILD_WAR_ALLOT, Tos, RoleSt) ->
	#m_guild_war_allot_tos{type=Type, role=ToRole} = Tos,
	#role_st{guild=GuildID, gpid=GuildPid, role=RoleID} = RoleSt,
	{ok, #guild_memb{post=Post}} = guild:get_member(GuildPid, RoleID),
	?_check(Post == ?GUILD_POST_CHIEF, ?ERR_GUILD_PERM_DENY),
	Result = game_misc:read(gw_result),
	?_check(Result /= ?nil, ?ERR_GUILDWAR_NOT_WINNER),
	#gw_result{
		winner=Winner, victory=Victory, breakup=Breakup,
		v_allot=VAllot, b_allot=BAllot
	} = Result,
	?_check(Winner == GuildID, ?ERR_GUILDWAR_NOT_WINNER),
	case Type of
		1 ->
			?_check(Victory >= 2, ?ERR_GUILDWAR_NEVER_VICTORY),
			?_check(VAllot == 0, ?ERR_GUILDWAR_HAD_ALLOTED),
			Reward  = cfg_guildwar_victory_reward:victory_reward(Victory),
			MailID  = ?MAIL_GUILDWAR_VICTORY_REWARD,
			Result2 = Result#gw_result{v_allot=VAllot+1};
		2 ->
			?_check(Breakup >= 2, ?ERR_GUILDWAR_NEVER_BREAKUP),
			?_check(BAllot == 0, ?ERR_GUILDWAR_HAD_ALLOTED),
			Reward  = cfg_guildwar_victory_reward:breakup_reward(Breakup),
			MailID  = ?MAIL_GUILDWAR_BREAKUP_REWARD,
			Result2 = Result#gw_result{b_allot=BAllot+1}
	end,
	{ok, _} = guild:get_member(GuildPid, ToRole),
	WorldLv = world_level:get_level(),
	Reward2 = calc_reward_by_worldlv(Reward, WorldLv),
	mail:send(ToRole, MailID, Reward2),
	game_misc:write(gw_result, Result2, true),
	?ucast(#m_guild_war_allot_toc{type=Type, role=ToRole});

%% 领取奖励
handle(?GUILD_WAR_FETCH, _Tos, RoleSt) ->
	#gw_result{winner=Winner} = game_misc:read(gw_result, #gw_result{}),
	?_check(Winner == RoleSt#role_st.guild, ?ERR_GUILDWAR_NOT_WINNER),
	IsFetch = role_count:get_times(?ROLE_COUNT_GW_REWARD) >= 1,
	?_check(not IsFetch, ?ERR_GUILDWAR_HAD_FETCH),
	Reward  = cfg_game:guildwar_daily_reward(),
	{ok, Obtain} = role_bag:gain(Reward, ?LOG_GUILDWAR_DAILY, RoleSt),
	role_count:add_times(?ROLE_COUNT_GW_REWARD),
	?ucast(#m_guild_war_fetch_toc{reward=Obtain}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
p_gw_versus(Field) ->
	Guilds = lists:map(fun
		(GuildID) ->
			[Guild] = ets:lookup(?ETS_GW_GUILD, GuildID),
			p_gw_guild(Guild)
	end, Field#gw_field.guilds),
	#p_gw_versus{guilds=Guilds, winner=Field#gw_field.winner}.

p_gw_guild(Guild) ->
	#p_gw_guild{
		id   = Guild#gw_guild.id,
		name = guild:get_name(Guild#gw_guild.id)
	}.

calc_reward_by_worldlv([{Min, Max, Reward} | T], WorldLv) ->
	case Min =< WorldLv andalso WorldLv =< Max of
		true  -> Reward;
		false -> calc_reward_by_worldlv(T, WorldLv)
	end.
