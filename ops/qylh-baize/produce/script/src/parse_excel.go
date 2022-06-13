package main

import (
	"io/ioutil"
	"log"
	"os"
	"parser"
	"path"
	"path/filepath"
	"strconv"
	"strings"
)

var tplCreep string = `<?xml version="1.0" encoding="UTF-8"?>

<creeps>
{{ range . }}
    <creep id="{{ .id }}" name="{{ .name }}" level="{{ .level }}" avatar="{{ .avatar }}" figure="{{ .figure }}" />
{{ end }}
</creeps>
`

var tplNPC string = `<?xml version="1.0" encoding="UTF-8"?>

<npcs>
{{ range . }}
    <npc id="{{ .id }}" name="{{ .name }}" avatar="{{ .avatar }}" figure="{{ .figure }}" />
{{ end }}
</npcs>
`

func main() {
	e := parser.ParseExcel(os.Args[1])

	var lines []string

	for i, row := range e.Cells {
		var key string
		var val string

		switch len(e.Keys) {
		case 0:
			key = strconv.Itoa(i + 1)
		case 1:
			switch e.Keys[0]["type"] {
			case "string":
				key = "\"" + row[e.Keys[0]["name"]] + "\""
			default:
				key = row[e.Keys[0]["name"]]
			}
		default:
			var arr []string
			for _, k := range e.Keys {
				arr = append(arr, row[k["name"]])
			}
			key = "\"" + strings.Join(arr, "@") + "\""
		}
		key = "[" + key + "]"

		var arr []string
		for j, n := range e.Names {
			var item string
			switch e.Types[j] {
			case "time":
				fallthrough
			case "string":
				item = n + " = [[" + row[n] + "]]"
			case "bool":
				if row[n] == "true" {
					item = n + " = 1"
				} else {
					item = n + " = 0"
				}
			case "array":
				item = n + " = [[{" + row[n] + "}]]"
			default:
				item = n + " = " + row[n]
			}
			arr = append(arr, item)
		}
		val = strings.Join(arr, ", ")
		lines = append(lines, key+" = {"+val+"}")
	}

	var filenameWithSuffix string
	_, filenameWithSuffix = filepath.Split(os.Args[1])
	module := strings.TrimSuffix(filenameWithSuffix, path.Ext(filenameWithSuffix))

	var err error
	var max_line = 500
	if len(lines) > max_line{
		var sub_lines []string
		var indexs []int
		var index = 0
		for i:=0;i<len(lines) ;i++  {
			sub_lines = append(sub_lines,"Config.db_" + module + lines[i])
			if (i+1)%max_line == 0{
				content := strings.Join(sub_lines, "\n")
				sub_lines = make([]string,max_line)
				index ++
				indexs = append(indexs, index)
				err := ioutil.WriteFile(path.Join(os.Args[2], "db_" + module + "_" + strconv.Itoa(index) +".lua"), parser.TrimEmptyLine([]byte(content)), 0666)
				if err != nil {
					log.Fatalf("配置生成失败: %v", err)
				}
			}
		}

		if len(sub_lines) > 0{
			content := strings.Join(sub_lines, "\n")
			sub_lines = make([]string,max_line)
			index ++
			indexs = append(indexs, index)
			err := ioutil.WriteFile(path.Join(os.Args[2], "db_" + module + "_" + strconv.Itoa(index) +".lua"), parser.TrimEmptyLine([]byte(content)), 0666)
			if err != nil {
				log.Fatalf("配置生成失败: %v", err)
			}
		}


		content := "Config = Config or {}\nConfig.db_" + module + " = {}\n"
		for _,index := range indexs{
			content = content + "require('game/config/auto/db_" + module+ "_" + strconv.Itoa(index) + "')\n"
		}
		err = ioutil.WriteFile(path.Join(os.Args[2], "db_"+module+".lua"), parser.TrimEmptyLine([]byte(content)), 0666)
		if err != nil {
			log.Fatalf("配置生成失败: %v", err)
		}
	} else {
		content := "Config = Config or {}\nConfig.db_" + module + " = {\n" + strings.Join(lines, ",\n") + "\n}"

		err := ioutil.WriteFile(path.Join(os.Args[2], "db_"+module+".lua"), parser.TrimEmptyLine([]byte(content)), 0666)
		if err != nil {
			log.Fatalf("配置生成失败: %v", err)
		}
	}

	switch module {
	case "creep":
		e.Exec(tplCreep, nil)
		err = ioutil.WriteFile(path.Join(path.Dir(os.Args[1]), "../xml", "creep.xml"), e.Bytes, 0666)
		if err != nil {
			log.Fatalf("配置生成失败: %v", err)
		}
	case "npc":
		e.Exec(tplNPC, nil)
		err = ioutil.WriteFile(path.Join(path.Dir(os.Args[1]), "../xml", "npc.xml"), e.Bytes, 0666)
		if err != nil {
			log.Fatalf("配置生成失败: %v", err)
		}
	}
}
