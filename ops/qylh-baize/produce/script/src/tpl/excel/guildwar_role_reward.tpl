{{ row . `find('field', Rank) when 'min_rank' =< Rank andalso Rank =< 'max_rank' -> 'reward';` }}
find(_, _) -> [].
