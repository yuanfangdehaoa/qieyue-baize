-ifndef(LOGIN_HRL).
-define(LOGIN_HRL, ok).

%% 递增id
-record(game_uid, {
	  role_id
	, guild_id
	, trade_id % 市场交易商品id
}).

%% 封号
-record(game_ban, {
	  ip_addr  = [] % 封禁的ip列表
	, account  = [] % 封禁的账号列表
	, role_id  = [] % 封禁的角色id列表
	, white    = [] % 白名单列表
}).

-endif.