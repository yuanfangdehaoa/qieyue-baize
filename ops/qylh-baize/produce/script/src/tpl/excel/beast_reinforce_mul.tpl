-include("beast.hrl").

{{ row . `find(Exp) when Exp >= 'exp_start', Exp =< 'exp_fin' -> 'cost';` }}
find(_) -> undefined.
