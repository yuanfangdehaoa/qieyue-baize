-include("guild_house.hrl").

{{ row . `point(Duration) when Duration >= 'time_min' andalso Duration =< 'time_max' -> 'point';` }}
point(_) -> undefined.
