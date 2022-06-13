package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"math"
	"os"
	"parser"
	"parser/excel"
	"path"
	"path/filepath"
	"strings"
)

func main() {
	log.SetFlags(log.Lshortfile)

	excelFile, luaFile, isProduct, isSplit, convertTo := os.Args[1], os.Args[2], os.Args[3], os.Args[4], os.Args[5]
	//excelFile, luaFile, isProduct, isSplit, convertTo := `e:\work\qylh-tw\produce\config\excel\wake.xlsx`, "db_wake.lua", "true", "false", "th"

	c := initLuaParser(excelFile)
	if convertTo != "never" {
		c.WithDataConverter(parser.InitI18N(filepath.Dir(excelFile), convertTo))
	}
	c, err := c.Parse(1, 1, 2, 3)
	if err != nil {
		log.Fatalf("parse excel error: %v", err)
	}

	list := toLua(c)

	genLuaFile(excelFile, luaFile, list, isProduct == "true", isSplit == "true")
}

func initLuaParser(excelFile string) *excel.Config {
	c := excel.NewConfig(excelFile)

	c.WithDataParser("bool", luaBoolParser{})
	c.WithDataParser("string", luaStringParser{})
	c.WithDataParser("array", luaArrayParser{})

	return c
}

type luaBoolParser struct{}

func (bp luaBoolParser) ParseData(val string) (data interface{}, err error) {
	switch val {
	case "0", "false":
		data = 0
	case "1", "true":
		data = 1
	default:
		err = fmt.Errorf("unknown bool type: %s", val)
	}
	return data, err
}

type luaStringParser struct{}

func (sp luaStringParser) ParseData(val string) (data interface{}, err error) {
	val = strings.Replace(val, "_x000D_", "\n", -1)
	val = strings.Replace(val, "\r\n", "\n", -1)
	if(len(val) > 0 && val[0] == '[') {
		data = fmt.Sprintf(`[[ %s ]]`, val)
	} else {
		data = fmt.Sprintf(`[[%s]]`, val)
	}
	return data, err
}

type luaArrayParser struct{}

func (ap luaArrayParser) ParseData(val string) (data interface{}, err error) {
	data = fmt.Sprintf(`[[{%s}]]`, val)
	return data, err
}

func toLua(c *excel.Config) []string {
	lines := make([]string, 0, len(c.Lines))

	for i, line := range c.Lines {
		keys := make([]string, 0, len(c.Metas))
		vals := make([]string, 0, len(c.Metas))

		for _, col := range c.Names {
			if c.Metas[col].IsKey {
				if c.Metas[col].Type == excel.TYPE_STRING {
					key := line[col].(string)
					key = strings.Trim(key, " [[]] ")
					keys = append(keys, fmt.Sprintf(`"%v"`, key))
				} else {
					keys = append(keys, fmt.Sprintf("%v", line[col]))
				}
			}
			vals = append(vals, fmt.Sprintf("%s=%v", col, line[col]))
		}

		if len(keys) == 0 {
			keys = append(keys, fmt.Sprintf("%d", i+1))
		}

		var key string
		if len(keys) > 1 {
			for i := 0; i < len(keys); i++ {
				keys[i] = strings.Trim(keys[i], "\"")
			}
			key = fmt.Sprintf(` ["%s"] `, strings.Join(keys, "@"))
		} else {
			key = fmt.Sprintf(` [%s] `, keys[0])
		}

		val := strings.Join(vals, ", ")

		line := fmt.Sprintf(`%s = {%s}`, key, val)

		lines = append(lines, line)
	}
	return lines
}

func genLuaFile(excelFile, luaFile string, list []string, isProduct bool, isSplit bool) {
	module := strings.TrimSuffix(path.Base(excelFile), path.Ext(excelFile))
	pageCap := 500
	if !isProduct && len(list) > pageCap {
		genMultiLuaFile(module, luaFile, list, pageCap, isSplit)
	} else {
		genOneLuaFile(module, luaFile, list)
	}
}

func genOneLuaFile(module, luaFile string, list []string) {
	format := `-- Automatically generated, do not edit
Config = Config or {}
Config.db_%s = {
%s
}
`
	data := strings.Join(list, ",\n")
	res := fmt.Sprintf(format, module, data)
	ioutil.WriteFile(luaFile, []byte(res), os.ModePerm)
}

func genMultiLuaFile(module, luaFile string, list []string, pageCap int, isSplit bool) {
	pageNum := int(math.Ceil(float64(len(list)) / float64(pageCap)))
	genMultiMainFile(module, luaFile, pageNum, isSplit)
	genMultiDataFile(module, path.Dir(luaFile), list, int(pageCap), 1)
}

func genMultiMainFile(module, luaFile string, pageNum int, isSplit bool) {
	format := `-- Automatically generated, do not edit
Config = Config or {}
Config.db_%s = {}
%s
`
	requires := make([]string, 0, pageNum)
	require := ""
	for i := 1; i <= pageNum; i++ {
		if isSplit {
			require = fmt.Sprintf("require('game/config/auto/%s/db_%s_%d')", module, module, i)
		} else {
			require = fmt.Sprintf("require('game/config/auto/db_%s_%d')", module, i)
		}
		requires = append(requires, require)
	}
	res := fmt.Sprintf(format, module, strings.Join(requires, "\n"))
	ioutil.WriteFile(luaFile, []byte(res), os.ModePerm)
}

func genMultiDataFile(module, luaPath string, list []string, pageCap, pageIndex int) {
	if len(list) > pageCap {
		genDataFile(module, luaPath, list[:pageCap], pageIndex)
		genMultiDataFile(module, luaPath, list[pageCap:], pageCap, pageIndex+1)
	} else {
		genDataFile(module, luaPath, list, pageIndex)
	}
}

func genDataFile(module, luaPath string, data []string, pageIndex int) {
	for i := 0; i < len(data); i++ {
		data[i] = fmt.Sprintf("Config.db_%s%s", module, data[i])
	}

	format := `-- Automatically generated, do not edit
%s
`
	res := fmt.Sprintf(format, strings.Join(data, "\n"))
	luaFile := path.Join(luaPath, fmt.Sprintf("db_%s_%d.lua", module, pageIndex))
	ioutil.WriteFile(luaFile, []byte(res), os.ModePerm)
}
