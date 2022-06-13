package main

import (
	"bytes"
	"io/ioutil"
	"log"
	"os"
	"regexp"
	"text/template"
)

var tplCheat = `<?xml version="1.0" encoding="UTF-8"?>

<cheats>
{{ range . }}
    <cheat>
    	<name>{{ index . 1 }}</name>
    	<usage>{{ index . 2 }}</usage>
    	<sample>{{ if eq (index . 4) ""}}无{{ else }}{{ index . 4 }}{{ end }}</sample>
    </cheat>
{{ end }}
</cheats>
`

func main() {
	data, err := ioutil.ReadFile(os.Args[1])
	if err != nil {
		log.Fatalf("文件读取失败: %v", err)
	}
	reg := regexp.MustCompile(
		`%%\s*@usage\s*([^\s]+)\s*%%\s*([^\s]*)\s*(%%\s*([^\s]*))*`,
	)
	m := reg.FindAllStringSubmatch(string(data), -1)

	buf := bytes.NewBuffer(make([]byte, 0, 1024))
	t := template.New("tpl")
	t, err = t.Parse(tplCheat)
	if err != nil {
		log.Fatalf("模板文件解析失败: %v", err)
	}
	err = t.Execute(buf, m)
	if err != nil {
		log.Fatalf("GM指令生成失败: %v", err)
	}

	err = ioutil.WriteFile(os.Args[2], buf.Bytes(), 0666)
	if err != nil {
		log.Fatalf("GM指令生成失败: %v", err)
	}
}
