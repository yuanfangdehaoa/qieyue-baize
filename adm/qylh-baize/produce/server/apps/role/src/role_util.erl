%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_util).

-include("game.hrl").
-include("role.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").

%% API
-export([reg_name/1]).
-export([get_id/0]).
-export([set_id/1]).
-export([is_local/1]).
-export([get_attr/0]).
-export([set_attr/1]).
-export([get_power/0]).
-export([set_power/1]).
-export([make_cache/0, make_cache/1]).
-export([default_icon/1]).
-export([make_dummy/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
%% 玩家进程注册名
reg_name(RoleID) ->
	game_util:reg_name("role", [RoleID]).

-define(k_role_id, '@roleid').
get_id() ->
	get(?k_role_id).

set_id(RoleID) ->
	put(?k_role_id, RoleID).


%% 是否本服玩家
is_local(RoleID) ->
	case game_env:get_type() == ?SERVER_TYPE_LOCAL of
		true  ->
			role_manager:is_local(RoleID) orelse
			cluster:is_same(game_uid:guid2suid(RoleID), game_env:get_suid()) orelse
			faker:is_fake(RoleID);
		false ->
			false
	end.

-define(k_attr, k_init_attr).
get_attr() ->
	get(?k_attr).

set_attr(Attr) ->
	put(?k_attr, Attr).

-define(k_power, k_cur_power).
get_power() ->
	get(?k_power).

set_power(Power) ->
	put(?k_power, Power).

make_cache() ->
	Cache = role_util:make_cache([
        role_data:get(?DB_ROLE_INFO),
        role_data:get(?DB_ROLE_ATTR),
        role_data:get(?DB_ROLE_VIP),
        role_data:get(?DB_ROLE_GUILD)
    ]),
    Cache#role_cache{online=true}.

make_cache([RoleInfo, RoleAttr, RoleVip, RoleGuild]) ->
	{Marry, MName, MType} = role_marriage:get_info(RoleInfo#role_info.id),
	#role_cache{
		id     = RoleInfo#role_info.id,
		name   = RoleInfo#role_info.name,
		career = RoleInfo#role_info.career,
		gender = RoleInfo#role_info.gender,
		level  = RoleInfo#role_info.level,
		power  = mod_attr:power(RoleAttr#role_attr.attr),
		viplv  = role_vip:get_level(RoleVip),
		guild  = RoleGuild#role_guild.guild,
		gpost  = RoleGuild#role_guild.post,
		gname  = guild:get_name(RoleGuild#role_guild.guild),
		figure = RoleInfo#role_info.figure,
		login  = RoleInfo#role_info.login,
		logout = RoleInfo#role_info.logout,
		charm  = RoleInfo#role_info.charm,
		wake   = RoleInfo#role_info.wake,
		icon   = RoleInfo#role_info.icon,
		marry  = Marry,
        mname  = MName,
        mtype  = MType,
        suid   = RoleInfo#role_info.suid,
        zoneid = RoleInfo#role_info.zoneid,
        team   = RoleInfo#role_info.team
	}.

default_icon(Gender) ->
	#p_icon{
		pic    = ?_if(Gender == ?GENDER_MALE, "11", "21"),
		md5    = "",
		frame  = 0,
		bubble = 0
	}.

make_dummy(Num) ->
	lists:map(fun
		(RoleID) ->
			#p_role_base{
				id     = RoleID,
				name   = io_lib:format("dummy-~w", [RoleID]),
				career = ut_rand:choose([1, 2]),
				gender = ut_rand:choose([1, 2]),
				level  = ut_rand:random(1, 100),
				viplv  = ut_rand:random(1, 12),
				power  = ut_rand:random(100, 10000000),
				figure = #{},
				guild  = 0,
				gname  = "",
				charm  = ut_rand:random(0, 100),
				marry  = 0,
				mname  = "",
				mtype  = 0
			}
	end, lists:seq(1, Num)).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------


