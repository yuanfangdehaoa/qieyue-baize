{{ with (filter . `ne coef 0`) }}
{{ row . `coef('id') -> 'coef';` }}
coef(_) -> 0.
{{ end }}
