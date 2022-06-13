package parser

import (
	"encoding/json"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"
)

type I18N struct {
	Converter map[string]interface{}
	columns   map[string]interface{} // 需要国际化的配置(配置名+字段名)
}

func (i I18N) Convert(file string, col string, val string) string {
	col = strings.TrimSpace(col)
	key := strings.TrimSuffix(filepath.Base(file), filepath.Ext(file)) + col
	if _, ok := i.columns[key]; ok {
		key2 := strings.Replace(val, "_x000D_", "\n", -1)
		key2 = strings.Replace(key2, "\r\n", "\n", -1)
		key2 = strings.Replace(key2, "\n", "!@#$", -1)
		key2 = strings.TrimSpace(key2)
		if res, ok := i.Converter[key2]; ok {
			return strings.Replace(res.(string), "!@#$", "\n", -1)
		}
		if val != "" {
			log.Printf("convert fail, file=%s, col=%s, val=%s\n", file, col, val)
		}
		return val
	}
	return val
}

func InitI18N(configDir string, convertTo string) I18N {
	//i := I18N{
	//	Converter: make(map[string]string),
	//	columns:   make(map[string]bool),
	//}
	//c1 := excel.NewConfig(filepath.Join(configDir, "i18n.xlsx"))
	//c1.WithDataParser("string", stringParser{})
	//c1, err := c1.Parse(1, 1, 2, 3)
	//if err != nil {
	//	log.Fatalf("parse excel error: %v", err)
	//}
	//for _, line := range c1.Lines {
	//	key := line["zh-cn"].(string)
	//	i.Converter[key] = line[convertTo].(string)
	//}
	//
	//c2 := excel.NewConfig(filepath.Join(configDir, "i18n_cols.xlsx"))
	//c2.WithDataParser("string", stringParser{})
	//c2, err = c2.Parse(1, 1, 2, 3)
	//if err != nil {
	//	log.Fatalf("parse excel error: %v", err)
	//}
	//for _, line := range c2.Lines {
	//	key := line["file"].(string) + line["col"].(string)
	//	i.columns[key] = true
	//}
	//return i

	file, err := os.Open(filepath.Join(configDir, "i18n.json"))
	if err != nil {
		log.Fatalf("open i18n.json error: %v", err)
	}
	defer file.Close()

	data := make(map[string]interface{})
	decoder := json.NewDecoder(file)
	err = decoder.Decode(&data)
	if err != nil {
		fmt.Println("decode i18n.json error: %v", err)
	}

	conv := data["conv"].(map[string]interface{})

	return I18N{
		Converter: conv[convertTo].(map[string]interface{}),
		columns:   data["cols"].(map[string]interface{}),
	}
}

// 解析字符串
type stringParser struct{}

func (sp stringParser) ParseData(val string) (data interface{}, err error) {
	val = strings.Replace(val, "_x000D_", "\n", -1)
	val = strings.Replace(val, "\r\n", "\n", -1)
	return strings.TrimSpace(val), nil
}
