package excel

import (
	"strconv"
)

type DataFilter interface {
	Filter() *Config
}

type dataFilter struct {
	cfg *Config
	op  string
	col string
	cmp string
}

func (df dataFilter) Filter() *Config {
	list := make([]map[string]interface{}, 0, len(df.cfg.Lines))
	for _, line := range df.cfg.Lines {
		var val interface{}
		switch line[df.col].(type) {
		case int64:
			val, _ = strconv.ParseInt(df.cmp, 10, 64)
		case float64:
			val, _ = strconv.ParseFloat(df.cmp, 64)
		case bool:
			val, _ = strconv.ParseBool(df.cmp)
		case string:
			val = df.cmp
		}

		if Compare(df.op, line[df.col], val) {
			list = append(list, line)
		}
	}
	ret := *df.cfg
	ret.Lines = list
	return &ret
}
