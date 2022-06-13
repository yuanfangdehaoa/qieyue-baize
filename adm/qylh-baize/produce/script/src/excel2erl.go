package main

import (
	"fmt"
	"log"
	"os"
	"parser"
	"parser/excel"
	"path"
	"path/filepath"
	"regexp"
	"strings"
	"text/template"
)

func main() {
	log.SetFlags(log.Lshortfile)

	erlFile, convertTo, excelFile, tplFile := os.Args[1], os.Args[2], os.Args[3], os.Args[4]

	c := initErlParser(excelFile)
	if convertTo != "never" {
		c.WithDataConverter(parser.InitI18N(filepath.Dir(excelFile), convertTo))
	}
	c, err := c.Parse(1, 1, 2, 3)
	if err != nil {
		log.Fatalf("parse excel error: %v", err)
	}
	if len(c.Errs) != 0 {
		handleErrors(c.Errs)
	}

	b, err := c.Exec("ErlTpl", tplFile, true)
	if err != nil {
		log.Fatalf("exec tpl error: %v", err)
	}

	tplHeader := `%% Automatically generated, do not edit
-module(cfg_%s).

-compile([export_all]).
-compile(nowarn_export_all).

`
	module := strings.TrimSuffix(path.Base(excelFile), path.Ext(excelFile))
	header := fmt.Sprintf(tplHeader, module)
	b = append([]byte(header), b...)

	c.Write(erlFile, b)
}

func initErlParser(excelFile string) *excel.Config {
	c := excel.NewConfig(excelFile)

	c.WithTypeIndex(1)

	c.WithDataParser("atom", erlAtomParser{})
	c.WithDataParser("list", erlListParser{})
	c.WithDataParser("array", erlListParser{})
	c.WithDataParser("any", erlAnyParser{})

	c.WithFuncMap(template.FuncMap{"row": erlRow})
	c.WithFuncMap(template.FuncMap{"col": erlCol})
	c.WithFuncMap(template.FuncMap{"scol": erlSortCol})
	c.WithFuncMap(template.FuncMap{"gmax": erlGroupMax})
	c.WithFuncMap(template.FuncMap{"gmin": erlGroupMin})

	return c
}

func handleErrors(errs []excel.DataError) {
	for _, err := range errs {
		log.Printf(
			"FILE=[%s], ROW=[%d], COL=[%s], %s",
			path.Base(err.File), err.Row, err.Col, err.Msg,
		)
	}
	os.Exit(9001)
}

// 解析原子
type erlAtomParser struct{}

func (ap erlAtomParser) ParseData(val string) (data interface{}, err error) {
	if val == "" {
		err = fmt.Errorf("atom can not be null")
		return
	}

	data = fmt.Sprintf("%s", val)
	return data, err
}

// 解析列表
type erlListParser struct{}

func (lp erlListParser) ParseData(val string) (data interface{}, err error) {
	data = fmt.Sprintf("[%s]", val)
	return data, err
}

type erlAnyParser struct{}

func (ap erlAnyParser) ParseData(val string) (data interface{}, err error) {
	if val == "" {
		data = "undefined"
	} else {
		data = val
	}
	return data, err
}

func erlRow(c *excel.Config, format string) string {
	format, cols := parseFormat(c, format)

	list := make([]string, 0, len(c.Lines))
	for _, line := range c.Lines {
		args := make([]interface{}, 0, len(cols))
		for _, col := range cols {
			args = append(args, line[col])
		}
		list = append(list, fmt.Sprintf(format, args...))
	}
	return strings.Join(list, "\n")
}

func erlCol(c *excel.Config, format string) string {
	return erlSortCol(c, format, "", false)
}

func erlSortCol(c *excel.Config, format string, cols string, desc bool) string {
	keyFmt, valFmt, connFmt := parseColFormat(format)

	keyFmt, keyCols := parseFormat(c, keyFmt)
	valFmt, valCols := parseFormat(c, valFmt)

	data := c.Group(keyCols, valCols)

	list := make([]string, 0, len(data))
	for _, m := range data {
		vals := m["_vals"].([]map[string]interface{})

		if len(cols) != 0 {
			sortCols := strings.Split(cols, ",")
			excel.MustValidCols(c, sortCols)
			excel.DoSort(vals, sortCols, desc)
		}

		key := formatCols(keyFmt, m, keyCols)

		tmp := make([]string, 0, len(vals))
		for _, mm := range vals {
			tmp = append(tmp, formatCols(valFmt, mm, valCols))
		}
		val := strings.Join(tmp, ",")

		list = append(list, fmt.Sprintf(connFmt, key, val))
	}
	return strings.Join(list, "\n")
}

func erlGroupMax(c *excel.Config, format string) string {
	return groupMost(c, format, "gt")
}

func erlGroupMin(c *excel.Config, format string) string {
	return groupMost(c, format, "lt")
}

func groupMost(c *excel.Config, format string, op string) string {
	keyFmt, valFmt, connFmt := parseColFormat(format)

	keyFmt, keyCols := parseFormat(c, keyFmt)
	valFmt, valCols := parseFormat(c, valFmt)

	data := c.Group(keyCols, valCols)

	list := make([]string, 0, len(data))
	for _, m := range data {
		vals := m["_vals"].([]map[string]interface{})

		key := formatCols(keyFmt, m, keyCols)
		col := valCols[0]

		max := vals[0][col]
		for _, mm := range vals {
			if excel.Compare(op, mm[col], max) {
				max = mm[col]
			}
		}
		val := fmt.Sprintf(valFmt, max)

		list = append(list, fmt.Sprintf(connFmt, key, val))
	}
	return strings.Join(list, "\n")
}

func parseColFormat(format string) (string, string, string) {
	format = strings.TrimSpace(format)
	punct := format[len(format)-1]
	split := strings.Split(format, "->")
	keyFmt := strings.TrimSpace(split[0])
	valFmt := strings.TrimRight(strings.TrimSpace(split[1]), string(punct))
	resFmt := `%s -> %s` + string(punct)
	if valFmt[0] == '[' && valFmt[len(valFmt)-1] == ']' {
		valFmt = strings.Trim(valFmt, "[]")
		resFmt = `%s -> [%s]` + string(punct)
	}

	return keyFmt, valFmt, resFmt
}

func parseFormat(c *excel.Config, format string) (string, []string) {
	re := regexp.MustCompile(`'\w+'`)

	cols := re.FindAllString(format, -1)
	for i := 0; i < len(cols); i++ {
		cols[i] = strings.Trim(cols[i], "'")
	}

	excel.MustValidCols(c, cols)

	format = re.ReplaceAllString(format, "%v")

	return format, cols
}

func formatCols(format string, line map[string]interface{}, cols []string) string {
	args := make([]interface{}, 0, len(cols))
	for _, col := range cols {
		args = append(args, line[col])
	}
	return fmt.Sprintf(format, args...)
}
