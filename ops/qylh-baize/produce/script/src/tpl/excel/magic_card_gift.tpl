
{{ row . `gain(Floor) when Floor >= 'min_floor' andalso Floor =< 'max_floor' -> 'gain';` }}
gain(_) -> undefined.
