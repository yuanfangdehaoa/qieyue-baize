{{ row . `find('id', Level) when Level >= 'worldlv_min', Level =< 'worldlv_max' -> 'reward';` }}
find(_, _) -> [].

{{ row . `drop('id', Level) when Level >= 'worldlv_min', Level =< 'worldlv_max' -> {'drops', 'rare1_drops', 'rare2_drops'};` }}
drop(_, _) -> {[], [], []}.
