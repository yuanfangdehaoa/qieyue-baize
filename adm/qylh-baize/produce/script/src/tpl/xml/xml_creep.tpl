<?xml version="1.0" encoding="UTF-8"?>
<!-- Automatically generated, do not edit -->

<creeps>
{{ range .Lines }}
    <creep id="{{ .id }}" name={{ .name }} level="{{ .level }}" avatar="{{ .avatar }}" figure={{ .figure }} />
{{ end }}
</creeps>
