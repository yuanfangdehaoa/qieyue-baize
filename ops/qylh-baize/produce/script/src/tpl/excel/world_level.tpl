{{ row . `find(DiffLv) when 'min_lv' =< DiffLv, DiffLv =< 'max_lv' -> 'coef';` }}
find(_) -> 0.
