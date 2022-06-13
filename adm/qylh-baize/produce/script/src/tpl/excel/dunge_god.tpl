{{ row . `max_escape('wave') -> 'escape';` }}
max_escape(_) -> 0.

{{ with (filter . "eq record true") }}
{{ row . `checkpoint('wave') -> true;` }}
checkpoint(_) -> false.
{{ end}}
