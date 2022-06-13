package main

import (
	"io/ioutil"
	"log"
	"os"
	"parser/excel"
	"path/filepath"
	"strings"
)

var inneed []string
var distinct map[string]bool

func main() {
	configDir := os.Args[1]
	//configDir := `e:\work\qylh\develop\config\excel\`
	c := excel.NewConfig(filepath.Join(configDir, "i18n_cols.xlsx"))
	c.WithDataParser("string", stringParser{})
	c, err := c.Parse(1, 1, 2, 3)
	if err != nil {
		log.Fatalf("parse excel error: %v", err)
	}

	inneed = make([]string, 0)
	distinct = make(map[string]bool)

	for _, line := range c.Lines {
		file := line["file"].(string)
		col := line["col"].(string)
		extract(filepath.Join(configDir, file)+".xlsx", strings.TrimSpace(col))
	}

	res := []byte(strings.Join(inneed, "\n"))
	ioutil.WriteFile(filepath.Join(configDir, "i18n-zh-cn.txt"), res, os.ModePerm)
}

func extract(file string, col string) {
	c := excel.NewConfig(file)
	c.WithDataParser("string", stringParser{})
	c, err := c.Parse(1, 1, 2, 3)
	if err != nil {
		log.Printf("parse excel error: %v", err)
		return
	}
	inneed = append(inneed, "=============" + filepath.Base(file) + "(" + col + ")=============")
	for _, line := range c.Lines {
		if v, ok := line[col].(string); ok {
			if strings.TrimSpace(v) != "" {
				if _, ok := distinct[v]; !ok {
					distinct[v] = true
					inneed = append(inneed, v)
				}
			}
		}
	}
}

// 解析字符串
type stringParser struct{}

func (sp stringParser) ParseData(val string) (data interface{}, err error) {
	return val, nil
}
