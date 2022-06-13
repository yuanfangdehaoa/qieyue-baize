package main

import (
	"log"
	"os"
	"parser/proto"
	"path/filepath"
)

// proto.lua
var tplProtoLua1 = `-- Automatically generated, do not edit
-- Generated by parse_proto.go

proto = {
{{ range $k, $v := .Meths }}    {{ $k }} = {{ $v }},
{{ end }}
}
`

// require_pb.lua
var tplProtoLua2 = `-- Automatically generated, do not edit
-- Generated by parse_proto.go

{{ range .Mods }}require "proto/{{ . }}_pb"
{{ end }}
`

func main() {
	p := proto.NewProto()
	p, err := p.Parse(os.Args[1])

	if err != nil {
		log.Fatalf("proto解析失败: %v", err)
	}

	// 生成 proto.lua
	p.Generate(tplProtoLua1, filepath.Join(os.Args[2], "proto.lua"))

	// 生成 require_pb.lua
	p.Generate(tplProtoLua2, filepath.Join(os.Args[2], "require_pb.lua"))
}
