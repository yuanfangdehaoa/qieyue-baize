-ifndef(COMBAT_HRL).
-define(COMBAT_HRL, ok).

-define(COMBAT1V1_COUNT_DAILY_REWARD, 1).

-record(match_role, {role_id, type, level, grade, score, power, 
    mode, rank, today_join, join, keep_lose, stage, min, max, check}).

-define(ETS_COMBAT1V1, ets_combat1v1).
-define(KEY, 1).
-record(combat1v1_mode, {key, activity}).

-define(ETS_COMBAT1V1_ROLE, ets_combat1v1_role).

-define(SCENE_ROBOT_ID, 10000).

-record(cfg_combat1v1_grade, {name, grade, score, win_score, lose_score, win_merit, lose_merit, win_reward, lose_reward, daily_reward}).
-record(cfg_combat1v1_limit, {buy, has_reward}).

-define(INITIAL_GRADE, 11).

-define(COMBAT1V1_MISC_SEASON, combat1v1_misc_season).
-define(COMBAT1V1_MISC_MODE,   combat1v1_misc_mode).
-define(COMBAT1V1_MISC_REWARD, combat1v1_misc_reward).

-define(REWARD_NONE, 0).
-define(REWARD_CAN_FETCH, 1).
-define(REWARD_ALREADY_FETCHED, 2).

-define(MODE_LOCAL, local).
-define(MODE_CROSS, cross).

-endif.