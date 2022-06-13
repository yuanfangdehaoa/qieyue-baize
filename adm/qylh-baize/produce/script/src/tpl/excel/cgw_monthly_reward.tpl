{{ row . `find(Rank, Level) when Rank >= 'min_rank', Rank =< 'max_rank', Level >= 'min_lv', Level =< 'max_lv' -> 'reward';` }}
find(_, _) -> [].
