<?php
// Automatically generated, do not edit

return [
    'list' => [
        {{ range .Lines -}}
        {{ .goods_type }} => {{ .type_name }},
        {{ end }}
    ]
];