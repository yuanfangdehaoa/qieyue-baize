package main

import (
	"log"
	"os"
	"parser/excel"
)

func main() {
	log.SetFlags(log.Lshortfile)

	excelFile, tplFile, phpFile := os.Args[1], os.Args[2], os.Args[3]

	c := excel.NewConfig(excelFile)

	c, err := c.Parse(1, 1, 2, 3)
	if err != nil {
		log.Fatalf("parse excel error: %v", err)
	}

	b, err := c.Exec("PHPTpl", tplFile, true)
	if err != nil {
		log.Fatalf("exec tpl error: %v", err)
	}

	c.Write(phpFile, b)
}
