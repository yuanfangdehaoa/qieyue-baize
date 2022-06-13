%%%=============================================================================
%%% @author lin.jie
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(role_welfare).
-include("game.hrl").
-include("role.hrl").
-include("table.hrl").
-include("welfare.hrl").

%% API
-export([hook_reset/3]).
-export([init/1]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------

init(RoleID)->
	RoleWelfare = #role_welfare{
		  id = RoleID
		, level  = []
		, power  = []
		, online = []
		, sign   = #welfare_sign{signs=0,count=0,update=ut_time:seconds()}
	},
	role_data:set(RoleWelfare).

hook_reset(_DoW, _Hour, _RoleSt)->
	reset_online(),
	reset_sign().

%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
%重置领取的在线奖励
reset_online()->
	RoleWelfare = role_data:get(?DB_ROLE_WELFARE),
	role_data:set(RoleWelfare#role_welfare{online=[]}).

%重置每日签到
reset_sign()->
	RoleWelfare = role_data:get(?DB_ROLE_WELFARE),
	#role_welfare{sign=WelfareSign} = RoleWelfare,
	#welfare_sign{signs=Signs} = WelfareSign,
	Ids = cfg_welfare_sign_reward:ids(),
	WelfareSign2 = case Signs == length(Ids) of
		true  -> #welfare_sign{signs=0,update=ut_time:seconds()};
		false -> WelfareSign
	end,
	role_data:set(RoleWelfare#role_welfare{sign=WelfareSign2}),
	reset_sign_count().

%重置补签次数
reset_sign_count()->
	RoleWelfare = #role_welfare{sign=WelfareSign} = role_data:get(?DB_ROLE_WELFARE),
	WelfareSign2 = WelfareSign#welfare_sign{count=0},
	role_data:set(RoleWelfare#role_welfare{sign=WelfareSign2}).

