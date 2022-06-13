-include("guild_house.hrl").

{{ row . `score(Rank) when Rank >= 'rank_min' andalso Rank =< 'rank_max' -> 'score';` }}
score(_) -> 1.
