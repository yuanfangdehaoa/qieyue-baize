-ifndef(GUILD_HRL).
-define(GUILD_HRL, ok).

-define(ETS_GUILD, ets_guild).

-record(guild_st, {
	  guild, % GuildID
		active_time = 0  % 帮派活跃时间
}).

%% 帮派成员
-record(guild_memb, {
      id   :: integer() % 角色id
    , name :: string()  % 角色名称
    , post :: integer() % 职位
    , ctrb :: integer() % 帮贡
    , time :: integer() % 入帮时间
}).

-record(cfg_guild, {
	  level % 帮派等级
	, memb  % 成员数量
	, post  % 职位数量 key=Post, val=Num
	, fund  % 消耗资金
	, reqs  % 升级条件
	, cost  % 创建消耗
}).

-record(cfg_guild_boon, {
	  level
	, daily % 每日福利
	, baby  % 宝贝福利
	, post  % 职位福利
}).

-endif.