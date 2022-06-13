package excel

import "strings"

type Meta struct {
	Index int    // 列编号
	Name  string // 字段名
	Type  string // 字段类型
	IsKey bool   // 是否为键
}

type MetaParser interface {
	ParseMeta(colIndex int, name string, typeIndex int, typ string) (Meta, error)
}

type metaParser struct{}

func (mp metaParser) ParseMeta(colIndex int, name string, typeIndex int, typ string) (meta Meta, err error) {
	meta.Index = colIndex

	split := strings.Split(typ, "|")

	if len(split) == 1 {
		typeIndex = 0
	}
	meta.Type = strings.TrimSpace(split[typeIndex])

	if name[0] == '#' {
		meta.Name = strings.TrimSpace(name[1:])
		meta.IsKey = true
	} else {
		meta.Name = strings.TrimSpace(name)
		meta.IsKey = false
	}
	return
}
