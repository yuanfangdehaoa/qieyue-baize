{{ row . `find(Level) when Level >= 'min_lv', Level =< 'max_lv' -> {'win_reward', 'lose_reward'};` }}
find(_) -> undefined.
