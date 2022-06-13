%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(login_server).

-behaviour(gen_server).

-include("game.hrl").
-include("login.hrl").
-include("table.hrl").

%% gen_server callbacks
-export([init/1]).
-export([handle_call/3]).
-export([handle_cast/2]).
-export([handle_info/2]).
-export([terminate/2]).
-export([code_change/3]).
%% API
-export([start_link/0]).
-export([ban_role_id/1]).
-export([ban_account/1]).
-export([ban_ip_addr/1]).
-export([unban_role_id/1]).
-export([unban_account/1]).
-export([unban_ip_addr/1]).
-export([add_white/1]).
-export([del_white/1]).
-export([get_banned/0]).

-define(SERVER, ?MODULE).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
start_link() ->
	gen_server:start_link({local, ?SERVER}, ?MODULE, {}, []).

%% 封禁ID
ban_role_id(RoleID) ->
	gen_server:cast(?SERVER, {ban, #game_ban.role_id, RoleID}).

%% 封禁账号
ban_account(Account) ->
	gen_server:cast(?SERVER, {ban, #game_ban.account, Account}).

%% 封禁IP
ban_ip_addr(IPAddr) ->
	gen_server:cast(?SERVER, {ban, #game_ban.ip_addr, IPAddr}).

%% 解封ID
unban_role_id(RoleID) ->
	gen_server:cast(?SERVER, {unban, #game_ban.role_id, RoleID}).

%% 解封账号
unban_account(Account) ->
	gen_server:cast(?SERVER, {unban, #game_ban.account, Account}).

%% 解封IP
unban_ip_addr(IPAddr) ->
	gen_server:cast(?SERVER, {unban, #game_ban.ip_addr, IPAddr}).

%% 添加到白名单
add_white(RoleID) ->
	gen_server:cast(?SERVER, {add_white, RoleID}).

%% 从白名单删除
del_white(RoleID) ->
	gen_server:cast(?SERVER, {del_white, RoleID}).

%% 获取封号信息
get_banned() ->
	gen_server:call(?SERVER, get_banned).

%%%-----------------------------------------------------------------------------
%%% Callback Functions
%%%-----------------------------------------------------------------------------
init(_Args) ->
	process_flag(trap_exit, true),
	GameBan = game_misc:read(game_ban, #game_ban{}),
	{ok, GameBan}.


handle_call(get_banned, _From, GameBan) ->
	{reply, {ok, GameBan}, GameBan};

handle_call(_Request, _From, GameBan) ->
	{reply, {error, unknown_call}, GameBan}.


%% 封号
handle_cast({ban, Index, Val}, GameBan) ->
	List = element(Index, GameBan),
	case lists:member(Val, List) of
		true  ->
			{noreply, GameBan};
		false ->
			List2   = [Val | List],
			GameBan2 = setelement(Index, GameBan, List2),
			{noreply, GameBan2}
	end;

%% 解封
handle_cast({unban, Index, Val}, GameBan) ->
	List = element(Index, GameBan),
	case lists:member(Val, List) of
		true  ->
			List2   = lists:delete(Val, List),
			GameBan2 = setelement(Index, GameBan, List2),
			{noreply, GameBan2};
		false ->
			{noreply, GameBan}
	end;

%% 添加白名单
handle_cast({add_white, RoleID}, GameBan) ->
	List = GameBan#game_ban.white,
	case lists:member(RoleID, List) of
		true  ->
			{noreply, GameBan};
		false ->
			GameBan2 = GameBan#game_ban{white=[RoleID | List]},
			{noreply, GameBan2}
	end;

%% 删除白名单
handle_cast({del_white, RoleID}, GameBan) ->
	List = GameBan#game_ban.white,
	case lists:member(RoleID, List) of
		true  ->
			List2   = lists:delete(RoleID, List),
			GameBan2 = GameBan#game_ban{white=List2},
			{noreply, GameBan2};
		false ->
			{noreply, GameBan}
	end;

handle_cast(_Msg, GameBan) ->
	{noreply, GameBan}.

handle_info(_Info, GameBan) ->
	{noreply, GameBan}.

terminate(_Reason, GameBan) ->
	game_misc:write(game_ban, GameBan),
	ok.

code_change(_OldVsn, GameBan, _Extra) ->
	{ok, GameBan}.

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
