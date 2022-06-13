{{ row . `find('actid', 'id') -> 'reward';` }}
find(_, _) -> [].

{{ col . `list('actid', 'round') -> [{'id','weight'}];` }}
list(_, _) -> [].
