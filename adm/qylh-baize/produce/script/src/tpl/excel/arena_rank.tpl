{{ row . `find(Rank) when Rank >= 'min', Rank =< 'max' -> 'reward';` }}
find(_) -> undefined.
