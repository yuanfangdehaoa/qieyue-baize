package excel

import (
	"log"
	"strings"
	"text/template"
)

var Funcs []template.FuncMap

func init() {
	Funcs = []template.FuncMap{
		{"lower": Lower},
		{"upper": Upper},
		{"min": Min},
		{"max": Max},
		{"filter": Filter},
		{"distinct": Distinct},
		{"sort": Sort},
	}
}

func Lower(s string) string {
	return strings.ToLower(s)
}

func Upper(s string) string {
	return strings.ToUpper(s)
}

func Max(c *Config, col string) interface{} {
	MustValidCol(c, col)
	return findMost(c, col, "gt")
}

func Min(c *Config, col string) interface{} {
	MustValidCol(c, col)
	return findMost(c, col, "lt")
}

func findMost(c *Config, col string, op string) interface{} {
	most := c.Lines[0][col]
	for _, line := range c.Lines {
		val := line[col]
		if Compare(op, val, most) {
			most = val
		}
	}
	return most
}

func Filter(c *Config, filter string) *Config {
	split := strings.Split(filter, " ")
	if len(split) != 3 {
		log.Fatalf("invalid filter: %s", filter)
	}
	op, col, cmp := split[0], split[1], split[2]
	MustValidCol(c, col)

	dp := dataFilter{cfg: c, op: op, col: col, cmp: cmp}

	return dp.Filter()
}

func Distinct(c *Config, cols string) *Config {
	keyCols := strings.Split(cols, ",")
	MustValidCols(c, keyCols)

	lines := make([]map[string]interface{}, 0, len(c.Lines))
	exist := make(map[string]bool)
	for _, line := range c.Lines {
		k := serialize(line, keyCols)
		if _, ok := exist[k]; !ok {
			exist[k] = true
			lines = append(lines, line)
		}
	}
	ret := *c
	ret.Lines = lines
	return &ret
}

func Sort(c *Config, cols string, desc bool) *Config {
	sortCols := strings.Split(cols, ",")
	MustValidCols(c, sortCols)
	DoSort(c.Lines, sortCols, desc)
	return c
}

func MustValidCols(c *Config, cols []string) {
	for _, col := range cols {
		MustValidCol(c, col)
	}
}

func MustValidCol(c *Config, col string) {

	if _, ok := c.Metas[col]; !ok {
		log.Fatalf("不存在的列: %s", col)
	}
}

func DoSort(data []map[string]interface{}, cols []string, desc bool) {
	ds := dataSorter{cols: cols, desc: desc, lines: data}
	ds.Sort()
}
