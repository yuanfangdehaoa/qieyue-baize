-include("baby.hrl").

{{ row . `reward(Rank) when Rank >= 'rank_min' andalso Rank =< 'rank_max' -> 'gain';` }}
reward(_) -> [].
