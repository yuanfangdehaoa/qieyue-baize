{{ row . `find('creep', WorldLv) when WorldLv >= 'min', WorldLv =< 'max' -> {'attr', 'atk', 'def'};` }}
find(_, _) -> undefined.
