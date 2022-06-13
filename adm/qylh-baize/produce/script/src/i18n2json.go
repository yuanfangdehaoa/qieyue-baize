package main

import (
	"encoding/json"
	"log"
	"os"
	"parser/excel"
	"path/filepath"
	"strings"
)

func main() {
	configDir := os.Args[1]

	//configDir := `e:\work\qylh-tw\produce\config\excel\`

	i18nConv := make(map[string]map[string]string)
	c1 := excel.NewConfig(filepath.Join(configDir, "i18n.xlsx"))
	c1.WithDataParser("string", i18nStringParser{})
	c1, err := c1.Parse(1, 1, 2, 3)
	if err != nil {
		log.Fatalf("parse excel error: %v", err)
	}

	for _, meta := range c1.Metas {
		if meta.Name == "zh-cn" {
			continue
		}
		if _, ok := i18nConv[meta.Name]; !ok {
			i18nConv[meta.Name] = make(map[string]string)
		}
		for _, line := range c1.Lines {
			key := line["zh-cn"].(string)
			val := line[meta.Name].(string)
			if val == "" {
				continue
			}
			i18nConv[meta.Name][key] = val
		}
	}

	i18nCols := make(map[string]bool)
	c2 := excel.NewConfig(filepath.Join(configDir, "i18n_cols.xlsx"))
	c2.WithDataParser("string", i18nStringParser{})
	c2, err = c2.Parse(1, 1, 2, 3)
	if err != nil {
		log.Fatalf("parse excel error: %v", err)
	}
	for _, line := range c2.Lines {
		key := line["file"].(string) + line["col"].(string)
		i18nCols[key] = true
	}

	file, err := os.Create(filepath.Join(configDir, "i18n.json"))
	if err != nil {
		log.Fatalf("create i18n json error: %v", err)
	}
	defer file.Close()

	encoder := json.NewEncoder(file)
	err = encoder.Encode(map[string]interface{}{
		"cols": i18nCols,
		"conv": i18nConv,
	})
	if err != nil {
		log.Fatalf("encode error: %v", err)
	}

}

// 解析字符串
type i18nStringParser struct{}

func (sp i18nStringParser) ParseData(val string) (data interface{}, err error) {
	val = strings.Replace(val, "_x000D_", "\n", -1)
	val = strings.Replace(val, "\r\n", "\n", -1)
	val = strings.Replace(val, "\n", "!@#$", -1)
	val = strings.TrimSpace(val)
	return val, nil
}
