{{ row . `find(Time) when 'min_time' =< Time andalso Time =< 'max_time' -> 'score';` }}
find(_) -> 0.