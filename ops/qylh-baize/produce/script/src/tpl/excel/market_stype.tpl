{{ row . `limit('type', 'stype') -> 'limit';` }}
limit(_, _) -> 0.

{{ with (filter . `ne stype 0`)}}
{{ col . `stype('type') -> ['stype'];` }}
stype(_) -> [].
{{ end }}