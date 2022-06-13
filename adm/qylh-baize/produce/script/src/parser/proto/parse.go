package proto

import (
	"bytes"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"text/template"
)

type Proto struct {
	Mods  []string
	Meths map[string]int
	Msgs  []*Message
}

type Message struct {
	MsgType string
	ModID   int
	ModName string
	MsgID   int
	MsgName string
}

func NewProto() *Proto {
	p := new(Proto)
	p.Mods = make([]string, 0)
	p.Meths = make(map[string]int)
	p.Msgs = make([]*Message, 0)
	return p
}

func (p *Proto) Parse(path string) (*Proto, error) {
	reg := regexp.MustCompile(`message\s+(\w+)\s*\{\s*/*\s*(\d*)\s*\n([^}]*)\}`)

	err := filepath.Walk(path, func(path string, f os.FileInfo, err error) error {
		if !f.IsDir() && filepath.Ext(path) == ".proto" {
			data, err := ioutil.ReadFile(path)
			if err != nil {
				log.Fatalf("文件读取失败: %v", err)
			}
			modName := strings.TrimSuffix(f.Name(), ".proto")
			matches := reg.FindAllStringSubmatch(string(data), -1)
			p.Mods = append(p.Mods, modName)
			for _, match := range matches {
				msgName := match[1]
				if msgName[0] != 'p' {
					msg := new(Message)
					if msgName[len(msgName)-1] == 's' {
						msg.MsgType = "s"
					} else {
						msg.MsgType = "c"
					}
					msg.MsgID, _ = strconv.Atoi(match[2])
					msg.MsgName = msgName
					msg.ModID = msg.MsgID / 1000
					msg.ModName = modName
					p.Msgs = append(p.Msgs, msg)

					p.Meths[strings.ToUpper(modName[8:])] = msg.ModID
					p.Meths[strings.ToUpper(msgName[2:len(msgName)-4])] = msg.MsgID
				}
			}
		}
		return nil
	})

	return p, err
}

func (p *Proto) Generate(tpl string, file string) {
	buf := bytes.NewBuffer(make([]byte, 0, 1024))
	t := template.New("tpl")
	t, _ = t.Parse(tpl)
	err := t.Execute(buf, p)
	if err != nil {
		log.Fatalf("协议生成失败: %v", err)
	}

	err = ioutil.WriteFile(file, buf.Bytes(), 0666)
	if err != nil {
		log.Fatalf("协议生成失败: %v", err)
	}
}
