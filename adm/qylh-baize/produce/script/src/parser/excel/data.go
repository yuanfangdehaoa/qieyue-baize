package excel

import (
	"fmt"
	"math"
	"strconv"
	"strings"
)

const (
	TYPE_INT    = "int"
	TYPE_DOUBLE = "double"
	TYPE_BOOL   = "bool"
	TYPE_STRING = "string"
	TYPE_ARRAY  = "array"
)

type DataParser interface {
	ParseData(val string) (interface{}, error)
}

type DataError struct {
	File string
	Row  int
	Col  string
	Msg  string
}

// 解析整数
type intParser struct{}

func (ip intParser) ParseData(val string) (data interface{}, err error) {
	if val == "" {
		err = fmt.Errorf("整数不能为空")
		return
	}

	f, err := strconv.ParseFloat(val, 64)
	if err != nil {
		err = fmt.Errorf("[%v]不是数字", f)
	}

	i := int64(f)
	if f > 0 && i < 0 {
		err = fmt.Errorf("[%v]不能超过最大整数%v", f, math.MaxInt64)
	}
	return i, err
}

// 解析浮点数
type doubleParser struct{}

func (fp doubleParser) ParseData(val string) (data interface{}, err error) {
	if val == "" {
		err = fmt.Errorf("浮点数不能为空")
		return
	}
	data, err = strconv.ParseFloat(val, 64)
	if err != nil {
		err = fmt.Errorf("[%s]不是浮点数", val)
	}
	return data, err
}

// 解析布尔值
type boolParser struct{}

func (bp boolParser) ParseData(val string) (data interface{}, err error) {
	switch strings.ToLower(val) {
	case "0", "false":
		data = "false"
	case "1", "true":
		data = "true"
	default:
		err = fmt.Errorf("[%s]不是布尔值", val)
	}
	return data, err
}

// 解析字符串
type stringParser struct{}

func (sp stringParser) ParseData(val string) (data interface{}, err error) {
	data = fmt.Sprintf(`"%s"`, val)
	return data, err
}

type arrayParser struct{}

func (ap arrayParser) ParseData(val string) (data interface{}, err error) {
	data = fmt.Sprintf(`[%s]`, val)
	return data, err
}
