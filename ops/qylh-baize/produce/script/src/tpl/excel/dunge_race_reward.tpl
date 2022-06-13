{{ row . `find(Level, 'rank') when Level >= 'min', Level =< 'max' -> 'reward';` }}
find(_, _) -> undefined.
