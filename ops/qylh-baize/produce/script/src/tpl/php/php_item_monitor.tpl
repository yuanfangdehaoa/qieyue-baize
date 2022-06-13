<?php
// Automatically generated, do not edit

return [
    'list' => [
        {{ range .Lines -}}
        {{ .id }} => ['alert' => {{ .alert }}, 'exception' => {{ .exception }}],
        {{ end }}
    ]
];