{{ row . `find(Power) when Power >= 'min', Power < 'max' -> 'rate';` }}
find(_) -> undefined.
