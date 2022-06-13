%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(guild_util).

-include("game.hrl").
-include("guild.hrl").
-include("role.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").

%% API
-export([reg_name/1]).
-export([get_guild_id/1]).
-export([new_member/3]).
-export([calc_guild_power/1]).
-export([add_guild_log/4]).
-export([get_guild_logs/1]).
-export([add_donate_log/6]).
-export([get_donate_logs/1]).
-export([ensure_exist/1]).
-export([ensure_not_join/1]).
-export([ensure_had_join/1]).
-export([p_guild_member/1]).
-export([p_guild_apply/3]).
-export([p_guild_log/2]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 帮派进程注册名
reg_name(GuildID) ->
    ut_conv:to_atom( lists:concat(["guild-", GuildID]) ).

%%帮派进程注册名获取帮派id
get_guild_id(GuildRef) ->
	ut_conv:to_integer( ut_conv:to_list(GuildRef) -- "guild-").

new_member(RoleID, Name, Post) ->
	#guild_memb{
		id   = RoleID,
		name = Name,
		post = Post,
		ctrb = 0,
		time = ut_time:seconds()
	}.

calc_guild_power(Membs) ->
	lists:foldl(fun
		(Memb, Acc) ->
			Acc + role:get_power(Memb#guild_memb.id)
	end, 0, Membs).

add_guild_log(GuildID, LogID, RoleID, Post) ->
	Log = #p_guild_log{
		log  = LogID,
		time = ut_time:seconds(),
		base = ?_if(RoleID == 0, ?nil, role:get_base(RoleID)),
		post = Post
	},
	game_logger:add_log({guild_log, GuildID}, Log).

get_guild_logs(GuildID) ->
	game_logger:get_logs({guild_log, GuildID}).

add_donate_log(GuildID, Type, RoleID, RoleName, Item, Score) ->
	Log = #p_donate_log{
		type      = Type,
		role_id   = RoleID,
		role_name = RoleName,
		item      = item_util:p_item(Item),
		score     = Score,
		time      = ut_time:seconds()
	},
	game_logger:add_log({guild_donate_log, GuildID}, Log).

get_donate_logs(GuildID) ->
	game_logger:get_logs({guild_donate_log, GuildID}).

ensure_exist(GuildID) ->
	?_check(guild:is_exist(GuildID), ?ERR_GUILD_NOT_EXIST).

ensure_not_join(RoleSt) ->
	?_check(RoleSt#role_st.guild == 0, ?ERR_GUILD_HAD_JOIN).

ensure_had_join(RoleSt) ->
	?_check(RoleSt#role_st.guild /= 0, ?ERR_GUILD_NOT_JOIN).

p_guild_member(Memb) ->
	{ok, Cache} = role:get_cache(Memb#guild_memb.id),
	#p_guild_member{
		base   = role:get_base(Cache),
		post   = Memb#guild_memb.post,
		online = role:is_online(Memb#guild_memb.id),
		ctrb   = Memb#guild_memb.ctrb,
		logout = Cache#role_cache.logout
	}.

p_guild_apply(RoleID, Post, Time) ->
	#p_guild_apply{
		base = role:get_base(RoleID),
		post = Post,
		time = Time
	}.

p_guild_log(RoleBase, LogID) ->
	#p_guild_log{
		base = RoleBase,
		log  = LogID
	}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
