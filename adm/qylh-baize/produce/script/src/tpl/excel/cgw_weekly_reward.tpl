{{ row . `find(Rank, Level) when Rank >= 'min_rank', Rank =< 'max_rank', Level >= 'min_lv', Level =< 'max_lv' -> {'win_score', 'win_reward', 'lose_score', 'lose_reward'};` }}
find(_, _) -> undefined.
