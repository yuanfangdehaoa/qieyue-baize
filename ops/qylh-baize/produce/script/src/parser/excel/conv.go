package excel

type DataConverter interface {
	Convert(excelName string, colName string, cellVal string) string
}
