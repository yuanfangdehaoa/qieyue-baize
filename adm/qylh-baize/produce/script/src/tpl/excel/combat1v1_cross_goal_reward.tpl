-include("combat1v1.hrl").

{{ with (filter . "gt min 0") }}
{{ row . `find_by_rank(Rank) when Rank >= 'min', Rank =< 'max' -> 'reward';` }}
find_by_rank(_) -> [].
{{ end }}

{{ with (filter . "gt grade 0") }}
{{ row . `find_by_grade('grade') -> 'reward';` }}
find_by_grade(_) -> [].
{{ end }}
