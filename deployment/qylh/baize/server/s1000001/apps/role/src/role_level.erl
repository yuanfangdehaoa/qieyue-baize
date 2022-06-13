%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_level).

-include("game.hrl").
-include("role.hrl").
-include("table.hrl").
-include("errno.hrl").
-include("proto.hrl").

%% API
-export([add_level/2]).
-export([add_exp/2]).
-export([get_attr/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

%%-----------------------------------------------
%% @doc 加经验
%% 请调用 role_bag:gain([{?ITEM_EXP,AddExp}], RoleSt)
-spec add_exp(integer(), #role_info{}) ->
	#role_info{}.
%%-----------------------------------------------
add_exp(AddExp, RoleInfo) ->
	RoleInfo2 = RoleInfo#role_info{
		exp = ut_math:ceil(RoleInfo#role_info.exp + AddExp)
	},
	maybe_upgrade(RoleInfo2).


%%-----------------------------------------------
%% @doc 升级
-spec add_level(integer(), #role_info{}) ->
	#role_info{}.
%%-----------------------------------------------
add_level(AddLv, RoleInfo) ->
	#role_info{level=OldLv, wake=Wake} = RoleInfo,
	NewLv = OldLv + AddLv,
	MinWake = cfg_role_level:wake(NewLv),
	?_check(Wake >= MinWake, ?ERR_ROLE_WAKE_LIMIT),
	MaxLv = cfg_role_level:max(),
	?_check(NewLv =< MaxLv, ?ERR_ROLE_MAX_LEVEL),
	RoleInfo#role_info{level=NewLv}.


%%-----------------------------------------------
%% @doc 计算当前等级所加的属性
%% 由 role_attr 模块调用
-spec get_attr(integer()) ->
	[mod_attr:attr_code()].
%%-----------------------------------------------
%% 玩家当前等级所加的属性
get_attr(_AttrType) ->
	#role_info{level=Level} = role_data:get(?DB_ROLE_INFO),
	cfg_role_level:attrs(Level).

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
maybe_upgrade(RoleInfo) ->
	#role_info{level=Level, exp=Exp, wake=Wake} = RoleInfo,
	MaxLv  = cfg_role_level:max(),
	MaxExp = cfg_role_level:exp(Level),
	case Level < MaxLv andalso Exp >= MaxExp of
		true  ->
			MinWake = cfg_role_level:wake(Level+1),
			case Wake >= MinWake of
				true  ->
					maybe_upgrade(RoleInfo#role_info{
						level = Level + 1,
						exp   = Exp - MaxExp
					});
				false ->
					RoleInfo
			end;
		false ->
			RoleInfo
	end.
