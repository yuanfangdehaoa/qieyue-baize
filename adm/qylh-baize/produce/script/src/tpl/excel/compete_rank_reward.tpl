{{ row . `find('islocal', Rank) when 'min_rank' =< Rank, Rank =< 'max_rank' -> 'reward';` }}
find(_, _) -> [].
