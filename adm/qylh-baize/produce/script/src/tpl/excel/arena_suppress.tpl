{{ row . `find(Power) when Power >= 'min', Power < 'max' -> 'buff';` }}
find(_) -> undefined.
