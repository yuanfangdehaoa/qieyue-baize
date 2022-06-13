-ifndef(GUILD_HOUSE_HRL).
-define(GUILD_HOUSE_HRL, ok).


-define(questions, '@questions').
-define(index, '@index').
-define(score, {'@score', RoleID}).
-define(rank, '@rank').
-define(answer, {'@answer', RoleID}).
-define(exp, {'@exp', RoleID}).

-define(RANKID, 1010).
-define(GUILD_HOUSE_SCENEID, 30361).
-define(ACTIVITYID, 10211).

%答题
-record(cfg_guild_question, {
	  id
	, content      %题目
	, options      %选项
	, answer       %答案
}).

%答题积分计算
-record(cfg_guild_question_score, {
	  rank_min     %答题名次上限
	, rank_max     %答题名次下线
	, score        %获得积分
}).

%答题奖励
-record(cfg_guild_question_reward, {
	  rank_min
	, rank_max
	, gain
}).

%公会驻地经验
-record(cfg_guild_house_exp, {
	  level
	, gain
}).

%召唤boss
-record(cfg_guild_house_boss, {
	  id               %召唤卡id
	, world_level_min  %世界等级下限
	, world_level_max  %世界等级上限
	, order            %boss阶数
	, creep            %怪物对应权重{creep_id, 权重}
}).

%杀怪评级
-record(cfg_guild_house_kill, {
	  time_min        %时间下限
	, time_max        %时间上限
	, point           %评级("S", "A", ...)      
}).

%boss掉落
-record(cfg_guild_house_drop, {
	  creep            %怪物id
	, drop             %评级掉落{S, [{drop_id,num}, {drop_id,num}]}, ...
}).

-endif.

