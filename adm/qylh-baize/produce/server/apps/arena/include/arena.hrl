-ifndef(ARENA_HRL).
-define(ARENA_HRL, ok).

-define(ARENA_ENTER_OPTS, arena_enter_opts).

-record(cfg_arena_stimulate, {cost, stimulate}).
-record(cfg_arena_challenge, {win, lose}).
-record(cfg_arena_high_rank, {rank, reward}).

-record(r_arena_role, {role_id, rank=0, watch=[]}).

-define(MAX_ROBOTID, 3000). %最大机器人ID, 机器人ID取值跟排名一样
-define(IS_ROBOT(ID), (ID =< 3000)).

-endif.