<?php
// Automatically generated, do not edit

return [
    'list' => [
        {{ range .Lines -}}
        {{ .id }} => {{ .name }},
        {{ end }}
    ]
];