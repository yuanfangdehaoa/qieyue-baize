-ifndef(GUILD_REDENVELOPE_HRL).
-define(GUILD_REDENVELOPE_HRL, ok).

%过期时间
-define(redenvelope_expire, 86400).
-define(redenvelope_records_max, 15).

-record(cfg_guild_redenvelope, {
	  id
	, type_id
	, belong             %红包所属(1-帮会，2-全服)
	, name
	, desc
	, target             %事件{event,goal}
	, is_count           %是否每天发一次
	, limit              %发放条件
	, cost               %消耗货币id，无消耗填0
	, item_id            %货币对应id
	, money              %红包总额度
	, num                %红包个数范围
	, range              %浮动红包额度
	, msgno              %公告消息id
}).

-endif.