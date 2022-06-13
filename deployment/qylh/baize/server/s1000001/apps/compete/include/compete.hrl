-ifndef(COMPETE_HRL).
-define(COMPETE_HRL, ok).

-record(compete_st, {
	  act_id
	, local  % 是否本服
	, season % 赛季
	, period % 当前活动阶段
	, pass   % 可参与玩家 [{RoleID,Power}]
	, join   % 海选赛参与玩家 [RoleID]
	, timer  %
	, round  % 当前第几轮
	, phase  % 当前比赛阶段
	, stime  % 当前比赛阶段开始时间
	, etime  % 当前比赛阶段结束时间
	, match  % 海选赛匹配 [{RoleID1,RoleID2}]
	, rank   % 争霸赛参与玩家 [RoleID]
}).

-define(ETS_COMPETE_ROLE, ets_compete_role).
-record(compete_role, {
	  id     % 玩家id
	, name   % 玩家名称
	, gender
	, suid
	, level
	, power  % 报名结束时的战力
	, score1 % 海选赛积分
	, score2 % 争霸赛积分
	, rank   % 当前排名
	, exp    % 累计经验
	, reward % 已获得奖励
	, miss   % 是否轮空
	, win    % 胜利次数
	, lose   % 失败次数
}).

-define(ETS_COMPETE_GROUP, ets_compete_group).

-record(compete_group, {
	  id
	, type   % COMPETE_BATTLE_XXX
	, round  % 第几轮
	, versus % 对战双方 [{Pos1,RoleID1}, {Pos2,RoleID2}]
	, guess  % {RoleID,GuessID,Type}
	, winner % RoleID
}).

-record(cfg_compete_guess, {
	  type
	, cost
	, right % 猜对奖励
	, wrong % 猜错奖励
}).

-endif.