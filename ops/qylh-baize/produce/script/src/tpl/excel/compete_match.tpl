{{ row . `find('round', 'islocal', Num) when 'min_join' =< Num, Num =< 'max_join' -> 'rule';` }}
find(_, _, _) -> [].
