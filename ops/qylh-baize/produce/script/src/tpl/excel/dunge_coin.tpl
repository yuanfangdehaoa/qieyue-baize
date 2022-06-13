{{ row . `level('floor') -> 'level';` }}
level(_) -> undefined.

{{ row . `rating('floor') -> 'rating';` }}
rating(_) -> [].

{{ row . `sweep('floor') -> 'sweep';` }}
sweep(_) -> [].

{{ row . `count('floor') -> 'count';` }}
count(_) -> [].
