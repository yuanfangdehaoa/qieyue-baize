-include("warrior.hrl").

{{ row . `gain(Rank) when Rank >= 'rank_min' andalso Rank =< 'rank_max' -> 'gain';` }}
gain(_) -> [].

{{ row . `cross_gain(Rank) when Rank >= 'rank_min' andalso Rank =< 'rank_max' -> 'cross_gain';` }}
cross_gain(_) -> [].
