package excel

import (
	"bytes"
	"encoding/json"
	"fmt"
	"github.com/360EntSecGroup-Skylar/excelize"
	"io/ioutil"
	"log"
	"os"
	"strings"
	"text/template"
)

type Config struct {
	excel string
	typ   int
	mp    MetaParser
	dp    map[string]DataParser
	funcs []template.FuncMap
	dc    DataConverter
	Names []string
	Metas map[string]Meta
	Lines []map[string]interface{}
	Errs  []DataError
}

func NewConfig(excel string) *Config {
	c := &Config{
		excel: excel,
		dp:    make(map[string]DataParser),
		funcs: Funcs,
		Names: make([]string, 0, 8),
		Metas: make(map[string]Meta),
		Lines: make([]map[string]interface{}, 0, 64),
		Errs:  make([]DataError, 0),
	}
	c.WithTypeIndex(0)
	c.WithMetaParser(metaParser{})
	c.WithDataParser(TYPE_INT, intParser{})
	c.WithDataParser(TYPE_DOUBLE, doubleParser{})
	c.WithDataParser(TYPE_BOOL, boolParser{})
	c.WithDataParser(TYPE_STRING, stringParser{})
	c.WithDataParser(TYPE_ARRAY, arrayParser{})
	return c
}

func (c *Config) WithTypeIndex(index int) {
	c.typ = index
}

func (c *Config) WithMetaParser(mp MetaParser) {
	c.mp = mp
}

func (c *Config) WithDataParser(typ string, dp DataParser) {
	c.dp[typ] = dp
}

func (c *Config) WithFuncMap(funcMap template.FuncMap) {
	c.funcs = append(c.funcs, funcMap)
}

func (c *Config) WithDataConverter(dc DataConverter) {
	c.dc = dc
}

func (c *Config) Parse(sheetIndex, nameLine, typeLine, dataLine int) (*Config, error) {
	file, err := excelize.OpenFile(c.excel)
	if err != nil {
		return nil, err
	}

	rows, err := file.GetRows(file.GetSheetName(sheetIndex))
	if err != nil {
		return nil, err
	}

	err = parseMeta(c, rows, nameLine, typeLine)
	if err != nil {
		return nil, err
	}

	err = parseData(c, rows, dataLine)
	if err != nil {
		return nil, err
	}

	return c, nil
}

func parseMeta(c *Config, rows [][]string, nl, tl int) error {
	for j, name := range rows[nl] {
		name = strings.TrimSpace(name)
		if name == "" {
			break
		}

		typ := strings.TrimSpace(rows[tl][j])
		if typ == "" {
			break
		}

		meta, err := c.mp.ParseMeta(j, name, c.typ, typ)
		if err != nil {
			return err
		}
		c.Names = append(c.Names, meta.Name)
		c.Metas[meta.Name] = meta
	}
	return nil
}

func parseData(c *Config, rows [][]string, dl int) error {
	for i, row := range rows[dl:] {
		if strings.TrimSpace(row[0]) == "" {
			continue
		}
		line := make(map[string]interface{})

		for name, meta := range c.Metas {
			dp, ok := c.dp[meta.Type]
			if !ok {
				return fmt.Errorf("不支持的类型: %s", meta.Type)
			}

			val := row[meta.Index]
			if _, ok := c.dc.(DataConverter); ok {
				val = c.dc.Convert(c.excel, meta.Name, val)
			}
			data, err := dp.ParseData(val)
			if err != nil {
				c.Errs = append(c.Errs, DataError{
					Msg:  err.Error(),
					File: c.excel,
					Row:  i + dl + 1,
					Col:  meta.Name,
				})
			}
			line[name] = data
		}
		c.Lines = append(c.Lines, line)
	}
	return nil
}

func (c *Config) Exec(name, tpl string, isFile bool) ([]byte, error) {
	t := template.New(name)
	for _, f := range c.funcs {
		t.Funcs(f)
	}

	if isFile {
		b, err := ioutil.ReadFile(tpl)
		if err != nil {
			log.Fatalf("read tpl error: %v", err)
		}
		tpl = string(b)
	}

	t, err := t.Parse(tpl)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	buf := bytes.NewBuffer(make([]byte, 0, 1024))
	err = t.Execute(buf, c)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	return buf.Bytes(), nil
}

func (c *Config) Write(outFile string, data []byte) {
	err := ioutil.WriteFile(outFile, data, os.ModePerm)
	if err != nil {
		log.Fatalf("write file error: %v", err)
	}
}

func (c *Config) Group(keyCols, valCols []string) []map[string]interface{} {
	keys := make([]string, 0, 64)

	exist := make(map[string]map[string]bool)

	for _, line := range c.Lines {
		k := serialize(line, keyCols)
		v := serialize(line, valCols)

		if _, ok := exist[k]; !ok {
			keys = append(keys, k)
			exist[k] = make(map[string]bool)
		}

		exist[k][v] = true
	}

	ret := make([]map[string]interface{}, 0, len(keys))
	for _, k := range keys {
		m := deserialize(k, c.Metas)
		l := make([]map[string]interface{}, 0, 64)
		for e := range exist[k] {
			l = append(l, deserialize(e, c.Metas))
		}
		m["_vals"] = l
		ret = append(ret, m)
	}

	return ret
}

func serialize(line map[string]interface{}, cols []string) string {
	tmp := make(map[string]interface{})
	for _, col := range cols {
		tmp[col] = line[col]
	}
	b, _ := json.Marshal(tmp)
	return string(b)
}

func deserialize(val string, metas map[string]Meta) map[string]interface{} {
	m := make(map[string]interface{})
	decoder := json.NewDecoder(bytes.NewReader([]byte(val)))
	decoder.UseNumber()
	decoder.Decode(&m)
	for k, v := range m {
		switch metas[k].Type {
		case TYPE_INT:
			m[k], _ = v.(json.Number).Int64()
		case TYPE_DOUBLE:
			m[k], _ = v.(json.Number).Float64()
		}
	}
	return m
}

func (c *Config) Sort(cols string, desc bool) {
	sortCols := strings.Split(cols, ",")
	MustValidCols(c, sortCols)
	ds := dataSorter{cols: sortCols, desc: desc, lines: c.Lines}
	ds.Sort()
}
