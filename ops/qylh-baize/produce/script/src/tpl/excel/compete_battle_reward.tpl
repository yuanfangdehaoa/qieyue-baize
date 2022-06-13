{{ row . `win('round', 'islocal', 'type') -> 'win';` }}
win(_, _, _) -> [].

{{ row . `lose('round', 'islocal', 'type') -> 'lose';` }}
lose(_, _, _) -> [].
