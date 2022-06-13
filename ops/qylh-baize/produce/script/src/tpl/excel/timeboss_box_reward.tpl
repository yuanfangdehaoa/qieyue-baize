{{ row . `find('id', 'type', 'times') -> {'cost', 'reward'};` }}
find(_, _, _) -> undefined.

{{ gmax . `max_times('id') -> 'times';` }}
max_times(_) -> 0.
