-include("combat1v1.hrl").

{{ with (filter . "gt nextgrade 0") }}
{{ row . `grade(Score) when Score < 'score' -> 'grade';` }}
{{- end }}
{{- with (filter . "eq nextgrade 0") }}
{{ row . `grade(Score) when Score < 999999999 -> 'grade'.` }}
{{- end }}

{{ row . `find('grade') -> #cfg_combat1v1_grade{name='name', grade='grade', score='score',  win_score='win_score', lose_score='lose_score', win_merit='win_merit', lose_merit='lose_merit', win_reward='win_reward', lose_reward='lose_reward', daily_reward='daily_reward'};` }}
find(_) -> undefined.
