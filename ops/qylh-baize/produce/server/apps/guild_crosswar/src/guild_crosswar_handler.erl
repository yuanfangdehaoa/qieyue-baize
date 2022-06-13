%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(guild_crosswar_handler).

-include("cgw.hrl").
-include("game.hrl").
-include("role.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").
-include("table.hrl").

%% API
-export([handle/3]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
handle(?CGW_PANEL, _Tos, RoleSt) ->
	Period = guild_crosswar:get_period(),
	NowDate = ut_time:date(),
	LstDate = ut_time:last_weekday_of_month(NowDate, 7),
	LstTime = ut_time:datetime_to_seconds({LstDate,{0,0,0}}),
	?ucast(#m_cgw_panel_toc{period=Period, next=LstTime});

handle(?CGW_GUILDS, _Tos, RoleSt) ->
	#role_st{guild=GuildID} = RoleSt,
	Guilds = guild_crosswar:get_guilds(),
	case lists:keyfind(GuildID, #cgw_guild.id, Guilds) of
		false ->
			?ucast(#m_cgw_guilds_toc{
				guilds    = [p_cgw_guild(G, Guilds) || G <- Guilds],
				my_rank   = 0,
				my_score  = 0,
				booktimes = 0,
				my_book   = 0
			});
		MyGuild ->
			?ucast(#m_cgw_guilds_toc{
				guilds = [p_cgw_guild(G, Guilds) ||
					G <- Guilds,
					G#cgw_guild.group /= MyGuild#cgw_guild.group
				],
				my_rank   = MyGuild#cgw_guild.rank,
				my_score  = MyGuild#cgw_guild.score,
				booktimes = MyGuild#cgw_guild.book1,
				my_book   = MyGuild#cgw_guild.rival1
			})
	end;

handle(?CGW_BOOK, Tos, RoleSt) ->
	#role_guild{guild=GuildID, post=Post} = role_data:get(?DB_ROLE_GUILD),
	?_check(GuildID > 0, ?ERR_CGW_CANNOT_ENTER),
	?_check(Post == ?GUILD_POST_CHIEF, ?ERR_CGW_POST_NOT_ENOUGH),
	#m_cgw_book_tos{guild_id=RivalID} = Tos,
	ok = guild_crosswar:book(GuildID, RivalID),
	?ucast(#m_cgw_book_toc{guild_id = RivalID});

handle(?CGW_MATCH, _Tos, RoleSt) ->
	Match = guild_crosswar:get_match(),
	{Round1, Round2} = lists:partition(fun
		(B) ->
			B#cgw_battle.round == 1
	end, Match),
	?ucast(#m_cgw_match_toc{
		round1 = [p_cgw_match(B) || B <- Round1],
		round2 = [p_cgw_match(B) || B <- Round2]
	});

handle(?CGW_RANKING, _Tos, RoleSt) ->
	Guilds = guild_crosswar:get_guilds(),
	?ucast(#m_cgw_ranking_toc{
		ranking = [p_cgw_rank(R) || R <- Guilds]
	}).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
p_cgw_guild(Guild, Guilds) ->
	BookGuild = case lists:keyfind(Guild#cgw_guild.rival2, #cgw_guild.id, Guilds) of
		false -> "";
		Rival -> Rival#cgw_guild.name
	end,
	#p_cgw_guild{
		id         = Guild#cgw_guild.id,
		name       = Guild#cgw_guild.name,
		chief      = Guild#cgw_guild.chief,
		score      = Guild#cgw_guild.score,
		book       = Guild#cgw_guild.rival2,
		book_times = Guild#cgw_guild.book2,
		book_time  = Guild#cgw_guild.book_time,
		book_guild = BookGuild,
		book_score = 0
	}.

p_cgw_match(Battle) ->
	#p_cgw_match{
		atk_id   = Battle#cgw_battle.atk_id,
		atk_name = Battle#cgw_battle.atk_name,
		def_id   = Battle#cgw_battle.def_id,
		def_name = Battle#cgw_battle.def_name,
		winner   = Battle#cgw_battle.winner
	}.

p_cgw_rank(Guild) ->
	#p_cgw_rank{
		id    = Guild#cgw_guild.id,
		name  = Guild#cgw_guild.name,
		chief = Guild#cgw_guild.chief,
		score = Guild#cgw_guild.score,
		rank  = Guild#cgw_guild.rank
	}.
