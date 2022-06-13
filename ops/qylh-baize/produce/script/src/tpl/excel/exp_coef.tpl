{{ row . `find(DiffLv) when 'min_difflv' =< DiffLv, DiffLv =< 'max_difflv' -> 'coef';` }}
find(_) ->
	10000.