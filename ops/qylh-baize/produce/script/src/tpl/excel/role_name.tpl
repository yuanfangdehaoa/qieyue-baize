{{ with (filter . `ne first_name ""`)}}
{{ col . `first_name('gender') -> ['first_name'];` }}
first_name(_) -> undefined.
{{ end }}

{{ with (filter . `ne last_name ""`)}}
{{ col . `last_name('gender') -> ['last_name'];` }}
last_name(_) -> undefined.
{{ end }}
