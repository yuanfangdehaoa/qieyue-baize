{{ row . `exp('level') -> 'exp';` }}
exp(_) -> undefined.

{{ row . `attrs('level') -> 'attrs';` }}
attrs(_) -> undefined.

{{ row . `pool('level') -> 'pool';` }}
pool(_) -> 0.

max() -> {{ max . "level" }}.

{{ with (filter . `gt wake 0`) }}
{{ with (distinct . "wake") }}
{{ row . `wake(Level) when Level >= 'level' -> 'wake';` }}
{{ end }}
wake(_) -> 0.
{{ end }}

{{ with (filter . `gt talent 0`) }}
{{ row . `talent('level') -> 'talent';` }}
talent(_) -> 0.
{{ end }}
