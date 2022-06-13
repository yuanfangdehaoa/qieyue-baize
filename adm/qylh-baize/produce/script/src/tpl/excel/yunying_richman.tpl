{{ col . `find('actid', 'round') -> [{'grid', 'type','reward'}];` }}
find(_, _) -> undefined.

{{ gmax . `max('actid') -> 'round';` }}
max(_) -> 0.
