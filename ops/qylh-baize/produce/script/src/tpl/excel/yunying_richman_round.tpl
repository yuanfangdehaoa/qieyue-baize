{{ row . `find('actid', 'round') -> 'reward';` }}
find(_, _) -> undefined.

{{ col . `list('actid') -> ['round'];` }}
list(_) -> [].
