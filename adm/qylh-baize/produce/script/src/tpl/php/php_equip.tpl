<?php
// Automatically generated, do not edit

return [
    'list' => [
        {{ range .Lines -}}
        {{ .id }} => ['order' => {{ .order }}, 'star' => {{ .star }}],
        {{ end }}
    ]
];