{{ row . `find(Level) when Level >= 'min', Level =< 'max' -> 'num';` }}
find(_) -> 0.

max() -> {{ max . "num"}}.
