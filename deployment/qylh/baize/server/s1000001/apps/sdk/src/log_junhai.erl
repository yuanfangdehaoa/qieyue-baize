%%%=============================================================================
%%% @author z.hua
%%% @doc
%%%
%%% @end
%%%=============================================================================

-module(log_junhai).

-include("game.hrl").
-include("item.hrl").
-include("role.hrl").
-include("table.hrl").
-include("enum.hrl").
-include("errno.hrl").
-include("log.hrl").

%% API
-export([log_online/1]).
-export([log_login/4]).
-export([log_create/4]).
-export([log_pay/4]).
-export([log_upgrade/4]).
-export([log_offline/4]).
-export([log_trade/4]).
-export([log_chat/4]).
-export([log_friend/4]).
-export([log_guild/4]).

%%%-----------------------------------------------------------------------------
%%% API Functions
%%%-----------------------------------------------------------------------------
log_online(OnlineStat) ->
	% ?debug("log_online:~w", [OnlineStat]),
	{{Y,M,D},{H,MM,_}} = ut_time:datetime(),
	Time = io_lib:format("~4..0B~2..0B~2..0B~2..0B~2..0B", [Y, M, D, H, MM]),
	maps:fold(fun
		({ChanID,GameChan}, Num, _) ->
			Agent = #{
				<<"channel_id">>      => channel_id(ChanID),
				<<"game_channel_id">> => ut_conv:to_binary(GameChan)
		    },
		    Online  = #{
				<<"time_value">> => ut_conv:to_binary(Time),
				<<"user_cnt">>   => Num
			},
		    Online2 = maps:merge(Online, server_info()),
			add_game_log(<<"online">>, #{
				<<"agent">>  => Agent,
				<<"online">> => Online2
			})
	end, ok, OnlineStat).

%% 登录日志
log_login(User, IP, SDKArgs, _Detail) ->
	% ?debug("log_login"),
	Role = role_data:get(?DB_ROLE_INFO),
	Vip  = role_data:get(?DB_ROLE_VIP),
	add_role_log(<<"login">>, #{}, User, Role, Vip, IP, SDKArgs).

%% 创角日志
log_create(User, IP, SDKArgs, {Role,Vip}) ->
	% ?debug("log_create"),
	add_role_log(<<"create_role">>, #{}, User, Role, Vip, IP, SDKArgs).

%% 充值日志
log_pay(User, IP, SDKArgs, {AppOrder,SDKOrder,TotalFee}) ->
	% ?debug("log_pay"),
	Role  = role_data:get(?DB_ROLE_INFO),
	Vip   = role_data:get(?DB_ROLE_VIP),
	Order = #{
		<<"order_sn">>         => ut_conv:to_binary(AppOrder),
		<<"channel_trade_sn">> => ut_conv:to_binary(SDKOrder),
		<<"currency_type">>    => <<"CNY">>,
		<<"currency_amount">>  => TotalFee,
		<<"order_type">>       => <<"alipay">> % todo
	},
	add_role_log(<<"order">>, #{<<"order">> => Order}, User, Role, Vip, IP, SDKArgs).

%% 升级日志
log_upgrade(User, IP, SDKArgs, _Detail) ->
	% ?debug("log_upgrade"),
	Role = role_data:get(?DB_ROLE_INFO),
	Vip  = role_data:get(?DB_ROLE_VIP),
	add_role_log(<<"role_update">>, #{}, User, Role, Vip, IP, SDKArgs).

%% 离线日志
log_offline(User, IP, SDKArgs, _Detail) ->
	% ?debug("log_offline"),
	Role = role_data:get(?DB_ROLE_INFO),
	Vip  = role_data:get(?DB_ROLE_VIP),
	#role_info{login=Login, logout=Logout} = Role,
	Offline = #{
	    <<"login_time">>  => Login,
	    <<"logout_time">> => Logout,
	    <<"duration">>    => Logout - Login
	},
	add_role_log(<<"offline">>, #{<<"offline">> => Offline}, User, Role, Vip, IP, SDKArgs).

%% 元宝获得与消耗
log_trade(User, IP, SDKArgs, {Log,Spend,Obtain}) ->
	% ?debug("log_trade"),
	Role = role_data:get(?DB_ROLE_INFO),
	Vip  = role_data:get(?DB_ROLE_VIP),
	TradeAmount = case maps:find(?ITEM_GOLD, Spend) of
		{ok, Value} ->
			-Value;
		error ->
			case maps:find(?ITEM_GOLD, Obtain) of
				{ok, Value} ->
					Value;
				_ ->
					0
			end
	end,
	TradeType = if
		Log == ?LOG_PAY ->
			0;
		Log == ?LOG_GM_DO ->
			1;
		Log == ?LOG_MARKET_DEAL ->
			2;
		TradeAmount < 0 ->
			4;
		true ->
			5
	end,
	RemainAmount = role_bag:get_money(?ITEM_GOLD),
	{ItemName, ItemAmount} = case Log == ?LOG_MALL_BUY of
		true  ->
			case maps:to_list(Obtain) of
				[{ItemID, Num}] ->
					#cfg_item{name=Name} = cfg_item:find(ItemID),
					{Name, Num};
				_ ->
					{"", 0}
			end;
		false ->
			{"", 0}
	end,
	Trade = #{
	    <<"trade_type">>    => TradeType,
	    <<"trade_amount">>  => TradeAmount,
	    <<"remain_amount">> => RemainAmount,
	    <<"item_name">>     => ut_conv:to_binary(ItemName),
	    <<"item_amount">>   => ItemAmount,
	    <<"trade_desc">>    => ut_conv:to_binary(log_desc:find(Log))
	},
	add_role_log(<<"coin_trade">>, #{<<"trade">> => Trade}, User, Role, Vip, IP, SDKArgs).

%% 聊天消息
log_chat(User, IP, SDKArgs, {ChanID, Content}) ->
	% ?debug("log_chat"),
	Role = role_data:get(?DB_ROLE_INFO),
	Vip  = role_data:get(?DB_ROLE_VIP),
	Chat = #{
		<<"chat_type">>    => ChanID,
		<<"chat_content">> => ut_conv:to_binary(Content)
	},
	add_role_log(<<"chat">>, #{<<"chat">> => Chat}, User, Role, Vip, IP, SDKArgs).

%% 添加好友
log_friend(User, IP, SDKArgs, FriendID) ->
	% ?debug("log_friend"),
	Role = role_data:get(?DB_ROLE_INFO),
	Vip  = role_data:get(?DB_ROLE_VIP),
	{ok, Cache} = role_cache:get_cache(FriendID),
	Friend = #{
	    <<"role_id">>     => ut_conv:to_binary(FriendID),
	    <<"role_name">>   => ut_conv:to_binary(Cache#role_cache.name),
	    <<"role_level">>  => Cache#role_cache.level,
	    <<"role_type">>   => Cache#role_cache.career,
	    <<"role_sex">>    => role_sex(Cache#role_cache.gender),
	    <<"friend_type">> => 1
	},
	add_role_log(<<"add_friend">>, #{<<"friend">> => Friend}, User, Role, Vip, IP, SDKArgs).

%% 添加公会群
log_guild(User, IP, SDKArgs, {GuildID,GuildName}) ->
	% ?debug("log_guild"),
	Role = role_data:get(?DB_ROLE_INFO),
	Vip  = role_data:get(?DB_ROLE_VIP),
	Faction = #{
		<<"faction_id">>   => ut_conv:to_binary(GuildID),
		<<"faction_name">> => ut_conv:to_binary(GuildName),
		<<"faction_type">> => 1
	},
	add_role_log(<<"add_faction">>, #{<<"faction">> => Faction}, User, Role, Vip, IP, SDKArgs).


%%%-----------------------------------------------------------------------------
%%% Internal Functions
%%%-----------------------------------------------------------------------------
add_game_log(Event, Log) ->
	try
		Log1 = maps:merge(common(), Log),
		Log2 = Log1#{
			<<"event">> => Event,
			<<"game">>  => game_info()
	    },
		junhai_log_server:add_log(Log2)
	catch Class:Reason:Stacktrace ->
        ?stacktrace(Class, Reason, Stacktrace)
	end.

add_role_log(Event, Log, User, Role, Vip, IP, SDKArgs) ->
	try
		IP2 = case inet:ntoa(IP) of
			{error,_} -> <<"">>;
			Address   -> ut_conv:to_binary(Address)
		end,
		Log1 = maps:merge(common(), Log),
		Log2 = Log1#{
			<<"event">>     => Event,
			<<"client_ip">> => IP2,
			<<"game">>      => game_info(),
			<<"agent">>     => agent_info(User, Role, SDKArgs),
			<<"device">>    => device_info(User, Role, SDKArgs),
			<<"user">>      => user_info(User, Role, SDKArgs),
			<<"role">>      => role_info(User, Role, Vip, SDKArgs)
	    },
		junhai_log_server:add_log(Log2, Event == <<"chat">>)
	catch Class:Reason:Stacktrace ->
        ?stacktrace(Class, Reason, Stacktrace)
	end.

common() ->
	#{
		<<"data_ver">>  => 1.6,
		<<"server_ts">> => ut_time:seconds(),
		<<"is_test">>   => is_test()
	}.

-ifdef(DEBUG).
is_test() ->
	<<"test">>.
-else.
is_test() ->
	<<"regular">>.
-endif.

game_info() ->
	#{
		<<"game_id">>  => game_env:get_id(),
		<<"game_ver">> => ut_conv:to_binary(game_env:get_version())
	}.

agent_info(User, _Role, _SDKArgs) ->
	#{
		<<"channel_id">>      => channel_id(User#game_user.chan_id),
		<<"game_channel_id">> => ut_conv:to_binary(User#game_user.gamechan)
	}.

device_info(_User, _Role, SDKArgs) ->
	#{
		<<"device_name">>   => ut_conv:to_binary(maps:get("device_name", SDKArgs, "")),
		<<"os_type">>       => ut_conv:to_binary(maps:get("os_type", SDKArgs, "")),
		<<"net_type">>      => ut_conv:to_binary(maps:get("net_type", SDKArgs, "")),
		<<"os_ver">>        => ut_conv:to_binary(maps:get("os_ver", SDKArgs, "")),
		<<"ios_idfa">>      => ut_conv:to_binary(maps:get("ios_idfa", SDKArgs, "")),
		<<"android_imei">>  => ut_conv:to_binary(maps:get("android_imei", SDKArgs, "")),
		<<"package_name">>  => ut_conv:to_binary(maps:get("package_name", SDKArgs, "")),
		<<"screen_width">>  => ut_conv:to_binary(maps:get("screen_width", SDKArgs, "")),
		<<"screen_height">> => ut_conv:to_binary(maps:get("screen_height", SDKArgs, "")),
		<<"user_agent">>    => ut_conv:to_binary(maps:get("user_agent", SDKArgs, ""))
	}.

user_info(User, _Role, _SDKArgs) ->
	#{
		<<"user_id">> => ut_conv:to_binary(User#game_user.account)
	}.

role_info(_User, Role, Vip, _SDKArgs) ->
	RoleInfo = #{
		<<"role_id">>     => ut_conv:to_binary(Role#role_info.id),
		<<"role_name">>   => ut_conv:to_binary(Role#role_info.name),
		<<"role_level">>  => Role#role_info.level,
		<<"role_type">>   => Role#role_info.career,
		<<"role_sex">>    => role_sex(Role#role_info.gender),
		<<"role_vip_lv">> => role_vip:get_level(Vip)
	},
	ServInfo = server_info(),
	maps:merge(RoleInfo, ServInfo).

role_sex(?GENDER_MALE) ->
	ut_conv:to_binary("男");
role_sex(?GENDER_FEMALE) ->
	ut_conv:to_binary("女");
role_sex(_) ->
	<<"null">>.

channel_id(?nil) ->
	<<"">>;
channel_id(ChanID) ->
	ut_conv:to_binary(ChanID).

server_info() ->
	ServerID = game_env:get_suid(),
	#{
		<<"server_id">>   => ServerID,
		<<"server_name">> => ut_conv:to_binary(lists:concat(['s-', ServerID]))
	}.