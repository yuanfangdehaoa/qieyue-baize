{{- range .Lines }}
find({{ .id }}, 1, Level) when {{ .minlv }} =< Level, Level =< {{ .maxlv }} ->
	{{ .star1 }};
find({{ .id }}, 2, Level) when {{ .minlv }} =< Level, Level =< {{ .maxlv }} ->
	{{ .star2 }};
find({{ .id }}, 3, Level) when {{ .minlv }} =< Level, Level =< {{ .maxlv }} ->
	{{ .star3 }};
{{- end }}
find(_, _, _) ->
	[].