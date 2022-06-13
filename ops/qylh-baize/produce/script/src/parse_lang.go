package main

import (
	"encoding/xml"
	"log"
	"os"
	xml2 "parser/xml"
	"path"
)

type confs struct {
	XMLName xml.Name `xml:"confs"`
	Confs   []conf   `xml:"conf"`
}

type conf struct {
	XMLName xml.Name `xml:"conf"`
	Name    string   `xml:"name,attr"`
	Fields  string   `xml:"fields,attr"`
}

func main() {
	x := xml2.ParseXML(os.Args[1], &confs{})
	log.Println(os.Getenv("GAMELANG"))
	l := x.Data.(*confs)
	for _, c := range l.Confs {
		var file string
		switch path.Ext(c.Name) {
		case ".xlsx":
			file = path.Join(os.Args[2], "excel", c.Name)
		case ".xml":
			file = path.Join(os.Args[2], "xml", c.Name)
		}
		log.Println(file)
		log.Println(c.Name)
		log.Println(c.Fields)
	}
	// todo
	// 从配置中将相应字段抽取出来，放到 i18n.tmp.xlsn 中（分表，每个配置一张表），策划翻译后，提交到 i18n.xlsn
	// 从 i18n.xlsn 中提取，替换相应配置
}
