{{ row . `find('id', Rank) when 'min_rank' =< Rank, Rank =< 'max_rank' -> {'reward', 'rare1_drops', 'rare2_drops'};` }}
find(_, _) -> [].
