package main

import (
	"encoding/xml"
	"os"
	xml2 "parser/xml"
	"path"
	"strings"
	"text/template"
)

type enums struct {
	XMLName xml.Name `xml:"enums"`
	Enums   []enum   `xml:"enum"`
}

type enum struct {
	XMLName xml.Name `xml:"enum"`
	Name    string   `xml:"name,attr"`
	Elems   []elem   `xml:"elem"`
}

type elem struct {
	XMLName xml.Name `xml:"elem"`
	Name    string   `xml:"name,attr"`
	Code    int      `xml:"code,attr"`
	Desc    string   `xml:"desc,attr"`
}

var tplEnumHrl = `%% Automatically generated, do not edit
%% Generated by parse_enum.go

-ifndef(ENUM_HRL).
-define(ENUM_HRL, true).
{{ range .Enums }}
{{ range .Elems }}
-define({{ .Name }}, {{ .Code }}). % {{ .Desc }}
{{ end }}
{{ end }}
-endif.
`

var tplEnumErl = `%% Automatically generated, do not edit
%% Generated by parse_enum.go

-module(enum).

-include("enum.hrl").
-include("errno.hrl").
-include("proto.hrl").

-compile([export_all]).
-compile(nowarn_export_all).

{{ range .Enums }}
check_{{ toLower .Name }}(E) ->
{{ range $i, $v := .Elems }}
	E == {{ .Code }} orelse
{{ end }}
	throw({error, ?ERR_GAME_BAD_ARGS, []}).
{{ end }}
`

var tplEnumPhp = `<?php
// Automatically generated, do not edit
// Generated by parse_enum.go

return [
{{ range .Enums }}
	'{{ toLower  .Name }}' => [
{{ range .Elems }}
		{{ .Code }} => '{{ .Desc }}',
{{ end }}
	],
{{ end }}
];
`

func main() {
	x := xml2.ParseXML(os.Args[1], &enums{})

	funcs := []template.FuncMap{
		{"toLower": strings.ToLower},
		{"trimLeft": func(s string) string {
			return s[5:]
		}},
	}

	if xml2.IsDirExist(os.Args[2]) {
		x.Exec(tplEnumHrl, nil)
		x.Write(path.Join(os.Args[2], "include", "enum.hrl"))
		x.Clear()

		x.Exec(tplEnumErl, funcs)
		x.Write(path.Join(os.Args[2], "src", "enum.erl"))
		x.Clear()
	}

	if len(os.Args) > 3 && os.Args[3] != "undefined" && xml2.IsDirExist(os.Args[3]) {
		x.Exec(tplEnumPhp, funcs)
		x.Write(path.Join(os.Args[3], "/config/game_enum.php"))
		x.Clear()
	}
}
