package main

import (
	"log"
	"os"
	"parser"
	"parser/excel"
	"path/filepath"
)

func main() {
	log.SetFlags(log.Lshortfile)

	excelFile, tplFile, xmlFile, convertTo := os.Args[1], os.Args[2], os.Args[3], os.Args[4]

	c := excel.NewConfig(excelFile)
	if convertTo != "never" {
		c.WithDataConverter(parser.InitI18N(filepath.Dir(excelFile), convertTo))
	}

	c, err := c.Parse(1, 1, 2, 3)
	if err != nil {
		log.Fatalf("parse excel error: %v", err)
	}

	b, err := c.Exec("XMLTpl", tplFile, true)
	if err != nil {
		log.Fatalf("exec tpl error: %v", err)
	}

	c.Write(xmlFile, b)
}
