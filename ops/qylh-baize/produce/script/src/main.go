package main

import (
	"encoding/xml"
	"io/ioutil"
	"log"
)

func main() {
	file := "E:\\work\\xw01\\config\\xml\\errno.xml"
	data, _ := ioutil.ReadFile(file)

	log.Println(data)

	m := make(map[string]string)
	err := xml.Unmarshal(data, m)
	log.Println(err)
	log.Println(m)
}
