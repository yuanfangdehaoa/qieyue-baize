-ifndef(BOSS_HRL).
-define(BOSS_HRL, ok).

-record(boss, {
	  id                      % BossID
	, type                    % BossType
	, group = 0  :: integer() %
	, floor = 0  :: integer()
	, born  = 0  :: integer() % 出生时间
	, care  = [] :: list()    % 关注的玩家列表
	, tomb  = 0  :: integer() % 墓碑id
	, kill  = 0  :: integer() % 击杀次数
	, klog  = [] :: list()    % 击杀日志
	, weak  = 0  :: integer() % 品质回退时间
	, num   = 0  :: integer() % 当前数量
}).

-record(cfg_boss, {
	  id
	, name
	, kind
	, type
	, group
	, floor  % 第几层
	, qual   % 品质
	, weak   % 退化cd
	, scene  % 所在场景
	, coord  % 刷新坐标
	, reborn % 重生时间
	, reward % 前N次奖励
	, droplv
	, num    % 刷新数量
}).

-endif.