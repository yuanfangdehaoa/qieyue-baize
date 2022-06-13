{{ row . `find('id', 'day') -> 'rewards';` }}
find(_, _) -> undefined.

{{ gmax . `max('id') -> 'day';` }}
max(_) -> 0.
