{{ row . `find(Rank) when 'min' =< Rank; Rank =< 'max' -> 'reward';` }}
find(_) -> [].
