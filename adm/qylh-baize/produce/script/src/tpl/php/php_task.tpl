<?php
// Automatically generated, do not edit

return [
    'list' => [
        {{ range .Lines -}}
        {{ .id }} => ['name' => {{ .name }}, 'level' => {{ .minlv }}, 'type' => {{ .type }}],
        {{ end }}
    ]
];