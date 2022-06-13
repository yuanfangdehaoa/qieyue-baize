-include("guild_house.hrl").

{{ row . `creep('id', Level) when Level >= 'world_level_min' andalso Level =< 'world_level_max'  -> 'creep';` }}
creep(_, _) -> undefined.