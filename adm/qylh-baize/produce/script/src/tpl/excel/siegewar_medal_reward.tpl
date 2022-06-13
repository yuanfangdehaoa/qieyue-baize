{{ row . `find('id', Level) when Level >= 'worldlv_min', Level =< 'worldlv_max' -> 'reward';` }}
find(_, _) -> [].

{{ gmax . `max() -> 'id'.` }}
