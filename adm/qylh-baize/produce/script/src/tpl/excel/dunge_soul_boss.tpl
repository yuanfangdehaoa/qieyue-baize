{{ row . `find(Level) when Level >= 'minlv', Level =< 'maxlv' -> 'boss';` }}
find(_) -> [].
