package xml

import (
	"bytes"
	"encoding/xml"
	"io/ioutil"
	"log"
	"os"
	"text/template"
)

type XML struct {
	Data  interface{}
	Bytes []byte
}

func ParseXML(input string, v interface{}) *XML {
	x := &XML{
		Data:  v,
		Bytes: make([]byte, 0, 1024),
	}

	data, err := ioutil.ReadFile(input)
	if err != nil {
		log.Fatalf("文件读取失败: %v", err)
	}

	err = xml.Unmarshal(data, &x.Data)
	if err != nil {
		log.Fatalf("文件解析失败: %v", err)
	}

	return x
}

func (x *XML) Exec(tpl string, funcs []template.FuncMap) *XML {
	buf := bytes.NewBuffer(make([]byte, 0, 1024))
	t := template.New("tpl")
	for _, fun := range funcs {
		t.Funcs(fun)
	}
	t, _ = t.Parse(tpl)
	t.Execute(buf, x.Data)
	x.Bytes = append(x.Bytes, buf.Bytes()...)
	return x
}

func (x *XML) Clear() *XML {
	x.Bytes = []byte{}
	return x
}

func (x *XML) Write(file string) {
	ioutil.WriteFile(file, x.Bytes, 0666)
}

func IsDirExist(path string) bool {
	_, err := os.Stat(path)
	return err == nil
}
