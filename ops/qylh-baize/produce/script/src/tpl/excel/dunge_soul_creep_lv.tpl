{{ row . `find(Level) when Level >= 'min', Level =< 'max' -> 'creep_lv';` }}
find(_) -> 0.
