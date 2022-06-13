-include("combat1v1.hrl").

{{ row . `find(Times) when Times >= 'min', Times =< 'max' -> #cfg_combat1v1_limit{buy='buy', has_reward='has_reward'};` }}
find(_) -> undefined.

max() -> {{ max . "max"  }}.

{{ with (filter . `eq buy []`) }}
max_free() -> {{ max . "max"  }}.
{{- end }}
