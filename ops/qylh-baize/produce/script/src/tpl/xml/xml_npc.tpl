<?xml version="1.0" encoding="UTF-8"?>
<!-- Automatically generated, do not edit -->

<npcs>
{{ range .Lines }}
    <npc id="{{ .id }}" name={{ .name }} avatar="{{ .avatar }}" figure={{ .figure }} />
{{ end }}
</npcs>
