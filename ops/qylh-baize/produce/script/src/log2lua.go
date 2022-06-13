package main

import (
	"encoding/xml"
	"os"
	xml2 "parser/xml"
	"path"
)

type glogs struct {
	XMLName xml.Name `xml:"logs"`
	GLogs   []glog   `xml:"log"`
}

type glog struct {
	XMLName xml.Name `xml:"log"`
	Name    string   `xml:"name,attr"`
	Code    int      `xml:"code,attr"`
	Notify  int      `xml:"notify,attr"`
	Desc    string   `xml:"desc,attr"`
}

var tplLogLua = `-- Automatically generated, do not edit
-- Generated by parse_log.go

logConsume = {
{{ range .GLogs }}
	[{{ .Code }}] = { notify={{ .Notify }}, desc=[[ {{ .Desc }} ]] },
{{ end }}
}

logConsumeDef = {
{{ range .GLogs }}
	{{ .Name }} = {{ .Code }},
{{ end }}
}
`

func main() {
	x := xml2.ParseXML(os.Args[1], &glogs{})

	if xml2.IsDirExist(os.Args[2]) {
		x.Exec(tplLogLua, nil)
		x.Write(path.Join(os.Args[2], "logConsume.lua"))
		x.Clear()
	}
}