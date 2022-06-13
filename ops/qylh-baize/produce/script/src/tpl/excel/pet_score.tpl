{{ with (filter . `gt ratio 0`)}}
{{ row . `ratio('id') -> 'ratio';` }}
ratio(_) -> 0.
{{ end }}

{{ with (filter . `eq ratio 0`)}}
{{ row . `quality_ratio('id') -> 'quality_ratio';` }}
quality_ratio(_) -> [].
{{ end }}
