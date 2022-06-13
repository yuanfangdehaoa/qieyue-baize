%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(guild_manager).

-behaviour(gen_server).

-include("game.hrl").
-include("guild.hrl").
-include("role.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([create/5]).
-export([rename/2]).
-export([disband/1]).
-export([demise/2]).
-export([approve/2]).
-export([add_memb/3]).
-export([del_memb/3]).
-export([upgrade/2]).
-export([ranking/0]).
-export([hook_chime/1]).

-define(SERVER, ?MODULE).

-record(state, {id}).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

%% 创建帮派
create(ChiefID, ChiefName, Power, GuildName, GuildLv) ->
	Req = {create, ChiefID, ChiefName, Power, GuildName, GuildLv},
	gen_server:call(?SERVER, Req).

%% 帮派改名
rename(GuildID, GuildName) ->
	gen_server:call(?SERVER, {rename, GuildID, GuildName}).

%% 解散帮派
disband(GuildID) ->
	gen_server:cast(?SERVER, {disband, GuildID}).

%% 转让帮主
demise(GuildID, Chief) ->
	gen_server:cast(?SERVER, {demise, GuildID, Chief}).

%% 同意加入
approve(GuildID, RoleID) ->
	gen_server:call(?SERVER, {approve, GuildID, RoleID}).

%% 增加成员
add_memb(GuildID, NewNum, NewPower) ->
	gen_server:cast(?SERVER, {add_memb, GuildID, NewNum, NewPower}).

%% 减少成员
del_memb(GuildID, NewNum, NewPower) ->
	gen_server:cast(?SERVER, {del_memb, GuildID, NewNum, NewPower}).

%% 帮派升级
upgrade(GuildID, NewLv) ->
	gen_server:cast(?SERVER, {upgrade, GuildID, NewLv}).

%% 更新排行榜
ranking() ->
	erlang:send(?SERVER, ranking).

hook_chime(Hour) ->
	gen_server:cast(?SERVER, {chime, Hour}).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	process_flag(trap_exit, true),
	ets:new(?ETS_GUILD, [named_table, {keypos, #p_guild_base.id}]),
	Guilds  = db:dirty_match_all(?DB_GUILD_INFO),
	[insert_guild_cache(Guild) || Guild <- Guilds],
	loop_ranking(),
	GuildID = game_misc:read(guild_id, game_uid:gen_guid()),
	{ok, #state{id=GuildID}}.

handle_call(Req, From, State) ->
	?try_handle_call(do_handle_call(Req, From, State), State).

handle_cast(Msg, State) ->
	?try_handle_cast(do_handle_cast(Msg, State), State).

handle_info(Info, State) ->
	?try_handle_info(do_handle_info(Info, State), State).


terminate(_Reason, _State) ->
	ok.

code_change(_OldVsn, State, _Extra) ->
	{ok, State}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%% 创建帮派
do_handle_call(
	{create, ChiefID, ChiefName, Power, GuildName, GuildLv},
	_From,
	State
) ->
	?_check(get_gid(GuildName) == ?nil, ?ERR_GUILD_NAME_EXIST),
	GuildID = State#state.id,
	game_misc:write(guild_id, GuildID+1, true),
	Reply = create_guild(ChiefID, ChiefName, Power, GuildID, GuildName, GuildLv),
	do_ranking(false),
	{reply, Reply, State#state{id=GuildID+1}};

%% 帮派改名
do_handle_call({rename, GuildID, GuildName}, _From, State) ->
	?_check(get_gid(GuildName) == ?nil, ?ERR_GUILD_NAME_EXIST),
	[Guild] = ets:lookup(?ETS_GUILD, GuildID),
	ets:insert(?ETS_GUILD, Guild#p_guild_base{name=GuildName}),
	del_gid(Guild#p_guild_base.name),
	{reply, ok, State};

do_handle_call({approve, GuildID, RoleID}, _From, State) ->
	Reply = case db:dirty_read(?DB_ROLE_GUILD, RoleID) of
		[RoleGuild = #role_guild{guild=0}] ->
			db:dirty_write(?DB_ROLE_GUILD, RoleGuild#role_guild{
				guild = GuildID,
				post  = ?GUILD_POST_MEMB,
				apply = []
			}),
			ok;
		_ ->
			?err(?ERR_GUILD_HAD_JOIN_OTHER)
	end,
	{reply, Reply, State};

do_handle_call(Req, _From, State) ->
    ?error("unhandle cast: ~p", [Req]),
	{reply, {error, unknown_call}, State}.


%% 解散帮派
do_handle_cast({disband, GuildID}, State) ->
	[Guild] = ets:lookup(?ETS_GUILD, GuildID),
	ets:delete(?ETS_GUILD, GuildID),
	del_gid(Guild#p_guild_base.name),
	{noreply, State};

%% 转让帮主
do_handle_cast({demise, GuildID, Chief}, State) ->
	[Guild] = ets:lookup(?ETS_GUILD, GuildID),
	ets:insert(?ETS_GUILD, Guild#p_guild_base{chief=Chief#guild_memb.name}),
	{noreply, State};

%% 新增成员
do_handle_cast({add_memb, GuildID, NewNum, NewPower}, State) ->
	ets:update_element(?ETS_GUILD, GuildID, [
		{#p_guild_base.num, NewNum},
		{#p_guild_base.power, NewPower}
	]),
	{noreply, State};

%% 减少成员
do_handle_cast({del_memb, GuildID, NewNum, NewPower}, State) ->
	ets:update_element(?ETS_GUILD, GuildID, [
		{#p_guild_base.num, NewNum},
		{#p_guild_base.power, NewPower}
	]),
	{noreply, State};

%% 升级
do_handle_cast({upgrade, GuildID, NewLv}, State) ->
	ets:update_element(?ETS_GUILD, GuildID, {#p_guild_base.level, NewLv}),
	{noreply, State};

%% 更新战力
do_handle_cast({update_power, GuildID, Power}, State) ->
	ets:update_element(?ETS_GUILD, GuildID, {#p_guild_base.power, Power}),
	{noreply, State};

do_handle_cast(started, State) ->
	do_ranking(false),
	{noreply, State};

do_handle_cast({chime, Hour}, State) ->
	lists:foreach(fun
		(#p_guild_base{id=GuildID}) ->
			GuildRef = guild_util:reg_name(GuildID),
			guild_agent:hook_chime(GuildRef, Hour)
	end, ets:tab2list(?ETS_GUILD)),
	{noreply, State};

do_handle_cast(Msg, State) ->
    ?error("unhandle cast: ~p", [Msg]),
	{noreply, State}.

do_handle_info(loop_ranking, State) ->
	loop_ranking(),
	do_ranking(true),
	{noreply, State};

do_handle_info(ranking, State) ->
	do_ranking(true),
	{noreply, State};

do_handle_info(Info, State) ->
    ?error("unhandle info: ~p", [Info]),
    {noreply, State}.


loop_ranking() ->
	erlang:send_after(timer:minutes(15), self(), loop_ranking).

do_ranking(Recalc) ->
	GuildList  = ets:tab2list(?ETS_GUILD),
	GuildList1 = ?_if(Recalc, recalc_power(GuildList), GuildList),
	GuildList2 = lists:keysort(#p_guild_base.power, GuildList1),
	RankList   = lists:seq(length(GuildList2), 1, -1),
	GuildList3 = lists:map(fun
		({Rank, Guild}) ->
			#p_guild_base{id=GuildID, power=Power} = Guild,
			guild_agent:update_guild_rank(GuildID,Rank, Power),
			Guild#p_guild_base{rank=Rank}
	end, lists:zip(RankList, GuildList2)),
	ets:insert(?ETS_GUILD, GuildList3).


recalc_power(GuildList) ->
	lists:map(fun
		(GuildBase = #p_guild_base{id=GuildID}) ->
			GuildInfo =
        case whereis(guild_util:reg_name(GuildID)) of
          ?nil ->
            [GuildInfo0] = db:dirty_read(?DB_GUILD_INFO,GuildID),
            GuildInfo0;
          _ ->
            {ok, [GuildInfo1]} = guild:get_data(GuildID, [guild_info]),
            GuildInfo1
        end,
			Power = guild_util:calc_guild_power(GuildInfo#guild_info.membs),
			GuildBase#p_guild_base{power=Power}
	end, GuildList).


create_guild(ChiefID, ChiefName, Power, GuildID, GuildName, GuildLv) ->
	Guild = init_guild(
		ChiefID, ChiefName, Power, GuildID, GuildName, GuildLv
	),
	Fun = fun() ->
		db:write(?DB_GUILD_INFO, Guild, write)
	end,
	case db:transaction(Fun) of
		{atomic, ok} ->
			{ok, GuildPid} = start_guild(Guild),
			{ok, GuildID, GuildPid};
		{aborted, R} ->
			?error("create guild error: ~p", [R]),
			?err(?ERR_GAME_SYS_ERROR)
	end.


insert_guild_cache(Guild) ->
	#guild_info{id=GuildID, name=GuildName, membs=Membs} = Guild,
	case Membs == [] of
		true  ->
			ignore;
		false when is_list(Membs)->
			set_gid(GuildName, GuildID),
%%		{ok, GuildPid} = guild_agent_sup:start_guild(GuildID),
			ChiefName =
				case lists:keyfind(?GUILD_POST_CHIEF, #guild_memb.post, Membs) of
					false -> "";
					Chief -> Chief#guild_memb.name
				end,
			ets:insert(?ETS_GUILD, #p_guild_base{
				id    = GuildID,
				name  = GuildName,
				chief = ChiefName,
				level = Guild#guild_info.level,
				num   = length(Membs),
				power = Guild#guild_info.power,
				rank  = Guild#guild_info.rank,
				reqs  = maps:without(["auto"], Guild#guild_info.setting)
			});
	  _ ->
			ignore
	end.


start_guild(Guild) ->
	#guild_info{id=GuildID, name=GuildName, membs=Membs} = Guild,
	case Membs == [] of
		true  ->
			ignore;
		false ->
			set_gid(GuildName, GuildID),
			{ok, GuildPid} = guild_agent_sup:start_guild(GuildID),
			ChiefName = case lists:keyfind(?GUILD_POST_CHIEF, #guild_memb.post, Membs) of
				false -> "";
				Chief -> Chief#guild_memb.name
			end,
			ets:insert(?ETS_GUILD, #p_guild_base{
				id    = GuildID,
				name  = GuildName,
				chief = ChiefName,
				level = Guild#guild_info.level,
				num   = length(Membs),
				power = Guild#guild_info.power,
				rank  = 0,
				reqs  = maps:without(["auto"], Guild#guild_info.setting)
			}),
			{ok, GuildPid}
	end.

init_guild(ChiefID, ChiefName, Power, GuildID, GuildName, GuildLv) ->
	Chief = guild_util:new_member(ChiefID, ChiefName, ?GUILD_POST_CHIEF),
	#guild_info{
		id      = GuildID,
		name    = GuildName,
		ctime   = ut_time:seconds(),
		level   = GuildLv,
		fund    = 0,
		notice  = cfg_game:guild_notice(),
		modify  = 0,
		membs   = [Chief],
		power   = Power,
		rank    = 1,
		apply   = [],
		runfor  = [],
		setting = #{"auto"=>true, "level"=>1, "power"=>1}
	}.

get_gid(Name) ->
    get({k_name, Name}).

set_gid(Name, GuildID) ->
    put({k_name, Name}, GuildID).

del_gid(Name) ->
	erase({k_name, Name}).
