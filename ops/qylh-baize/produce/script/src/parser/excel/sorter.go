package excel

import (
	"sort"
)

type DataSorter interface {
	Sort()
}

type dataSorter struct {
	cols  []string
	desc  bool
	lines []map[string]interface{}
}

func (ds dataSorter) Len() int {
	return len(ds.lines)
}

func (ds dataSorter) Swap(i, j int) {
	ds.lines[i], ds.lines[j] = ds.lines[j], ds.lines[i]
}

func (ds dataSorter) Less(i, j int) bool {
	isLess := false
	for _, col := range ds.cols {
		a := ds.lines[i][col]
		b := ds.lines[j][col]
		if Compare("lt", a, b) {
			isLess = true
			break
		}
		if Compare("eq", a, b) {
			continue
		} else {
			break
		}
	}
	if ds.desc {
		return !isLess
	} else {
		return isLess
	}
}

func (ds dataSorter) Sort() {
	sort.Sort(ds)
}
