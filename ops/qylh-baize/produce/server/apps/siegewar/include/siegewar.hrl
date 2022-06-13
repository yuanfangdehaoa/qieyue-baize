-ifndef(SIEGEWAR_HRL).
-define(SIEGEWAR_HRL, ok).

% 排名类型
-define(OWNER_TYPE_ROLE  , 1). % 玩家
-define(OWNER_TYPE_GUILD , 2). % 帮派
-define(OWNER_TYPE_SERVER, 3). % 服务器

% 划分规则
-define(ETS_SIEGEWAR_RULE, ets_siegewar_rule).
% {SUID, RuleID, GroupID}

-define(ETS_SIEGEWAR_CITY, ets_siegewar_city).
-record(siegecity, {
	  scene % 场景id
	, owner % 归属服务器id/帮派id
	, enter % 可进入该场景的服务器/帮派id列表(低、中级城市)
	, temp  % 是否临时占领
	, boss  % boss数量
	, score % 积分信息 #{SUID=>Score}
	, rule  % 划分规则
	, group % 分组id
}).


-define(ETS_SIEGEWAR_BOSS, ets_siegewar_boss).
-record(siegeboss, {
	  key          % {SceneID, BossID}
	, boss         % BossID
	, born   = 0   % 出生时间
	, tomb   = 0   % 墓碑id
	, box    = 0   % 宝箱id
	, role   = 0   % 场景人数
	, owners = []  % 击杀信息 [{SUID/GuildID, RoleID, Name}]
	, opened = #{} % 开启信息 #{RoleID=>Times}
}).

-record(cfg_siegewar_boss, {
	  id
	, name
	, scene
	, coord
	, type  % 1=普通首领; 2=精英首领; 3=大首领
	, score
	, attr
	, level
}).

-record(cfg_siegewar_box, {
	  id
	, type
	, reqs
	, cost
	, reward
}).

-endif.