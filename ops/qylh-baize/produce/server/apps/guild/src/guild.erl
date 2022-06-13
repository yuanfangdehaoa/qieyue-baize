%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(guild).

-include("game.hrl").
-include("guild.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("table.hrl").
-include("proto.hrl").

%% API
-export([get_ref/1]).
-export([get_pid/1]).
-export([get_data/2]).
-export([is_exist/1]).
-export([get_name/1]).
-export([get_guilds/0, get_guilds/1]).
-export([get_members/1, get_members/2]).
-export([get_membids/1, get_membids/2]).
-export([get_member/2]).
-export([get_post/2]).
-export([get_chief/1]).
-export([get_power/1]).
-export([route/3, route/4]).
-export([cast/2]).
-export([gm_disband/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%%-----------------------------------------------
%% @doc 获取帮派进程引用
-spec get_ref(integer()) ->
	atom().
%%-----------------------------------------------
get_ref(GuildID) ->
	guild_util:reg_name(GuildID).


%%-----------------------------------------------
%% @doc 获取帮派进程pid
-spec get_pid(integer()) ->
	pid() | undefined.
%%-----------------------------------------------

get_pid(GuildID) ->
	case whereis( guild_util:reg_name(GuildID) ) of
		?nil ->
			guild_util:reg_name(GuildID);
		GuildPid ->
			GuildPid
	end.


%%-----------------------------------------------
%% @doc 获取帮派信息
-spec get_data(integer(), [atom()]) ->
	{ok, [tuple()]} | error().
%%-----------------------------------------------
-ifdef(DEBUG).

get_data(GuildID, Keys) ->
	GuildPid = get_pid(GuildID),
    ?_check(GuildPid /= self(), ?ERR_GAME_BAD_CALL),
	guild_agent:get_data(GuildPid, Keys).

-else.

get_data(GuildID, Keys) ->
	guild_agent:get_data(get_ref(GuildID), Keys).

-endif.


%%-----------------------------------------------
%% @doc 帮派是否存在
-spec is_exist(integer()) ->
	boolean().
%%-----------------------------------------------
is_exist(GuildID) ->
	ets:member(?ETS_GUILD, GuildID).


%%-----------------------------------------------
%% @doc 获取帮派名
-spec get_name(integer()) ->
	string().
%%-----------------------------------------------
get_name(GuildID) ->
	case ets:lookup(?ETS_GUILD, GuildID) of
		[]  -> "";
		[G] -> G#p_guild_base.name
	end.


%%-----------------------------------------------
%% 获取帮派列表
-spec get_guilds() ->
	[#p_guild_base{}].
%%-----------------------------------------------
get_guilds() ->
	ets:tab2list(?ETS_GUILD).


%%-----------------------------------------------
%% 获取前N名帮派列表
-spec get_guilds(integer()) ->
	[#p_guild_base{}].
%%-----------------------------------------------
get_guilds(TopN) ->
	List1 = ets:tab2list(?ETS_GUILD),
	List2 = lists:keysort(#p_guild_base.power, List1),
	List3 = lists:reverse(List2),
	lists:sublist(List3, TopN).


%%-----------------------------------------------
%% @doc 获取帮派成员列表
-spec get_members(integer() | pid()) ->
	[#guild_memb{}].
%%-----------------------------------------------
get_members(GuildPid) when is_pid(GuildPid) ->
	do_get_members(GuildPid, ?GUILD_POST_MEMB);
get_members(GuildID) when is_integer(GuildID) ->
	do_get_members(get_pid(GuildID), ?GUILD_POST_MEMB);
get_members(GuildID) ->
	?debug("guild : ~p~n",[{?MODULE,?LINE,GuildID}]),
	[].


%%-----------------------------------------------
%% @doc 获取帮派成员列表
-spec get_members(integer() | pid(), integer()) ->
	[#guild_memb{}].
%%-----------------------------------------------
get_members(GuildPid, Post) when is_pid(GuildPid) ->
	do_get_members(GuildPid, Post);
get_members(GuildID, Post) when is_integer(GuildID) ->
	do_get_members(get_pid(GuildID), Post);
get_members(GuildID, Post) ->
	?debug("guild : ~p~n",[{?MODULE,?LINE,GuildID, Post}]),
	[].

%%-----------------------------------------------
%% @doc 获取帮派成员id列表
-spec get_membids(integer() | pid()) ->
	[RoleID :: integer()].
%%-----------------------------------------------
get_membids(GuildPid) when is_pid(GuildPid) ->
	do_get_membids(GuildPid, ?GUILD_POST_MEMB);
get_membids(GuildID) when is_integer(GuildID) ->
	do_get_membids(get_pid(GuildID), ?GUILD_POST_MEMB);
get_membids(GuildID) ->
	?debug("guild : ~p~n",[{?MODULE,?LINE,GuildID}]),
	[].

%%-----------------------------------------------
%% @doc 获取帮派成员id列表
-spec get_membids(integer() | pid(), integer()) ->
	[RoleID :: integer()].
%%-----------------------------------------------
get_membids(GuildPid, Post) when is_pid(GuildPid) ->
	do_get_membids(GuildPid, Post);
get_membids(GuildID, Post) when is_integer(GuildID) ->
	do_get_membids(get_pid(GuildID), Post);
get_membids(GuildID, Post)  ->
	?debug("guild : ~p~n",[{?MODULE,?LINE,GuildID, Post}]),
	[].


%%-----------------------------------------------
%% @doc 获取成员职位
-spec get_post(integer() | pid(), integer()) ->
	integer().
%%-----------------------------------------------
get_post(GuildPid, RoleID) when is_pid(GuildPid) ->
	do_get_post(GuildPid, RoleID);
get_post(GuildID, RoleID) when is_integer(GuildID) ->
	do_get_post(get_pid(GuildID), RoleID);
get_post(GuildRef, RoleID) when is_atom(GuildRef) ->
	do_get_post(GuildRef, RoleID).


%%-----------------------------------------------
%% @doc 获取帮派成员
-spec get_member(integer() | pid(), integer()) ->
	{ok, #guild_memb{}} | error().
%%-----------------------------------------------
get_member(GuildPid, RoleID) when is_pid(GuildPid) ->
	do_get_member(GuildPid, RoleID);
get_member(GuildID, RoleID) when is_integer(GuildID) ->
	do_get_member(get_pid(GuildID), RoleID);
get_member(GuildRef, RoleID) when is_atom(GuildRef) ->
	do_get_member(GuildRef, RoleID).


%%-----------------------------------------------
%% @doc 获取帮主信息
-spec get_chief(integer() | pid()) ->
	{ok, #guild_memb{}} | error().
%%-----------------------------------------------
get_chief(GuildPid) when is_pid(GuildPid) ->
	do_get_chief(GuildPid);
get_chief(GuildID) when is_integer(GuildID) ->
	do_get_chief(get_pid(GuildID));
get_chief(GuildRef) when is_atom(GuildRef) ->
	do_get_chief(GuildRef).


%%-----------------------------------------------
%% @doc 获取帮派战力
-spec get_power(integer()) ->
	integer().
%%-----------------------------------------------
get_power(GuildID) ->
	case ets:lookup(?ETS_GUILD, GuildID) of
		[]  -> 0;
		[R] -> R#p_guild_base.power
	end.


%%-----------------------------------------------
%% @doc 路由转发
%% 帮派进程会以 Mod:Fun(Args, GuildSt) 进行回调
-spec route(integer() | pid(), module(), function(), any()) ->
    no_return().
%%-----------------------------------------------
route(GuildID, Mod, Fun) when is_integer(GuildID) ->
    gen_server:cast(get_ref(GuildID), {route, Mod, Fun});
route(GuildPid, Mod, Fun) when is_pid(GuildPid) ->
    gen_server:cast(GuildPid, {route, Mod, Fun}).

route(GuildID, Mod, Fun, Args) when is_integer(GuildID) ->
    gen_server:cast(get_ref(GuildID), {route, Mod, Fun, Args});
route(GuildPid, Mod, Fun, Args) when is_pid(GuildPid) ->
    gen_server:cast(GuildPid, {route, Mod, Fun, Args}).


%%-----------------------------------------------
%% @doc cast 帮派进程
-spec cast(integer(), any()) ->
    no_return().
%%-----------------------------------------------
cast(GuildID, Msg) when is_integer(GuildID) ->
    gen_server:cast(get_ref(GuildID), Msg);
cast(GuildPid, Msg) when is_pid(GuildPid) ->
    gen_server:cast(GuildPid, Msg).

gm_disband(GuildID) ->
	?MODULE:cast(GuildID, gm_disband).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
do_get_members(?nil_guild, _Post) ->
	[];
do_get_members(?nil, _Post) ->
	[];
do_get_members(GuildPid, Post) ->
	{ok, [Guild]} = guild_agent:get_data(GuildPid, [?DB_GUILD_INFO]),
	[Memb ||
		Memb <- Guild#guild_info.membs,
		Memb#guild_memb.post >= Post
	].

do_get_membids(?nil_guild, _Post) ->
	[];
do_get_membids(?nil, _Post) ->
	[];
do_get_membids(GuildPid, Post) ->
	{ok, [Guild]} = guild_agent:get_data(GuildPid, [?DB_GUILD_INFO]),
	[Memb#guild_memb.id ||
		Memb <- Guild#guild_info.membs,
		Memb#guild_memb.post >= Post
	].

do_get_member(?nil_guild, _RoleID) ->
	?err(?ERR_GUILD_NOT_EXIST);
do_get_member(?nil, _RoleID) ->
	?err(?ERR_GUILD_NOT_EXIST);
do_get_member(GuildPid, RoleID) ->
	Membs = do_get_members(GuildPid, ?GUILD_POST_MEMB),
	case lists:keyfind(RoleID, #guild_memb.id, Membs) of
		false -> ?err(?ERR_GUILD_NO_MEMBER);
		Memb  -> {ok, Memb}
	end.

do_get_chief(GuildPid) ->
	Membs = do_get_members(GuildPid, ?GUILD_POST_MEMB),
	case lists:keyfind(?GUILD_POST_CHIEF, #guild_memb.post, Membs) of
		false -> ?err(?ERR_GUILD_NO_MEMBER);
		Chief -> {ok, Chief}
	end.

do_get_post(GuildPid, RoleID) ->
	Membs = do_get_members(GuildPid, ?GUILD_POST_MEMB),
	case lists:keyfind(RoleID, #guild_memb.id, Membs) of
		false -> 0;
		Memb  -> Memb#guild_memb.post
	end.
