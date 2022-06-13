{{ row . `find('type', 'creep', Diff) when 'min' =< Diff, Diff =< 'max' -> 'coef';` }}
find(_, _, _) -> 0.
