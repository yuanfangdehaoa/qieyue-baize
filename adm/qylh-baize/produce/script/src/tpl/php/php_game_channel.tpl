<?php
// Automatically generated, do not edit

return [
    {{ range .Lines -}}
    {{ .chan }} => {{ .group }},
    {{ end }}
];
