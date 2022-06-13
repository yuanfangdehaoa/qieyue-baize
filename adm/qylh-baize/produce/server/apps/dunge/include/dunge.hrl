-ifndef(DUNGE_HRL).
-define(DUNGE_HRL, ok).

-define(STAR1, 2#00000001).
-define(STAR2, 2#00000011).
-define(STAR3, 2#00000111).

-record(dunge_st, {
	  id                  % 副本id
	, aiid   :: integer() % 副本ai
	, ptime  :: integer() % 准备结束时间
	, wtime  :: integer() % 波数结束时间
	, roles  :: list()    % [RoleID]
	, over   :: boolean() % 是否结束
	, clear  :: boolean() % 是否通关
	, stat   :: boolean() % 是否结算
	, star   :: integer() % 副本评星
	, wave   :: integer() % 当前波数
	, used   :: integer() % 副本所用时间
	, mod    :: atom()    % 回调模块
	, level  :: integer() % 怪物出生依据等级
	, tref   :: reference() % 怪物波数计时器
	, count  :: any()     % 怪物波数计数器(这里只计算波数里面的怪物)
	, kill   :: map()     % 打怪计数器 key=CreepID, val=KillNum
	, opts   :: map()
}).

-record(cfg_dunge, {
	  id     % 副本id
	, scene  % 场景id
	, name   % 副本名称
	, level  % 等级
	, type   % 副本类型 DUNGE_TYPE_XXX
	, stype  % 副本子类型 SCENE_STYPE_XXX
	, floor  % 层数
	, power  % 战力推荐
	, last   % 副本时长
	, ai_id  % 副本ai
	, aiargs % ai参数
}).

-record(cfg_dunge_cd, {
	  id
	, prep % 准备时长
	, stat % 结算倒计时
	, exit % 退出倒计时
}).

-record(cfg_dunge_enter, {
	  id
	, times  % 次数限制
	, cd     % 进入cd
	, clrcd  % 清除cd消耗
	, buy    % 进入次数购买消耗
}).

%% 奖励
-record(cfg_dunge_reward, {
	  id
	, first  % 首通奖励
	, fixed  % 固定奖励
	, random % 随机奖励
}).

%% 扫荡
-record(cfg_dunge_sweep, {
	  id
	, reqs  % 可扫荡条件
	, times % 可扫荡次数
	, cost  % 扫荡消耗 [{MinTimes,MaxTimes,Cost}]
}).

%% 波数
-record(cfg_dunge_wave, {
	  id
	, wave   % 波数
	, reqs   % 刷新条件
	, creeps % 怪物列表 [{CreepID,X,Y} | {CreepID,X,Y,Sleep}]
	, last   % 波数持续时长
	, reward % 波数奖励
	, first  % 首通奖励
}).


%% 魔法塔副本
-record(cfg_dunge_magic, {
	  floor % 层数
	, dunge % 副本id
	, loto  % 增加的抽奖次数
	, gift  % 每日礼包
	, power % 标准战力
}).

-endif.