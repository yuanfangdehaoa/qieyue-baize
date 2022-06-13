{{ row . `find('chan') -> 'group';` }}
find(_) -> undefined.

{{ col . `group('group') -> ['chan'];` }}
group(_) -> [].
