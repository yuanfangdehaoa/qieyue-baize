package excel

import "log"

func Compare(op string, val1, val2 interface{}) bool {
	switch val1.(type) {
	case int64:
		return cmpInt(op, val1.(int64), val2.(int64))
	case float64:
		return cmpDouble(op, val1.(float64), val2.(float64))
	case bool:
		return cmpBool(op, val1.(bool), val2.(bool))
	default:
		return cmpStr(op, val1.(string), val2.(string))
	}
}

func cmpInt(op string, val1, val2 int64) bool {
	switch op {
	case "eq": // ==
		return val1 == val2
	case "ne": // !=
		return val1 != val2
	case "lt": // <
		return val1 < val2
	case "gt": // >
		return val1 > val2
	case "le": // <=
		return val1 <= val2
	case "ge": // >=
		return val1 >= val2
	default:
		log.Fatalf("unsupported operator: %s", op)
		return false
	}
}

func cmpDouble(op string, val1, val2 float64) bool {
	switch op {
	case "eq": // ==
		return val1 == val2
	case "ne": // !=
		return val1 != val2
	case "lt": // <
		return val1 < val2
	case "gt": // >
		return val1 > val2
	case "le": // <=
		return val1 <= val2
	case "ge": // >=
		return val1 >= val2
	default:
		log.Fatalf("unsupported operator: %s", op)
		return false
	}
}

func cmpBool(op string, val1, val2 bool) bool {
	switch op {
	case "eq":
		return val2 == val1
	case "ne":
		return val2 != val1
	default:
		log.Fatalf("unsupported operator: %s", op)
		return false
	}
}

func cmpStr(op string, val2, val1 string) bool {
	switch op {
	case "eq": // ==
		return val1 == val2
	case "ne": // !=
		return val1 != val2
	case "lt": // <
		return val1 < val2
	case "gt": // >
		return val1 > val2
	case "le": // <=
		return val1 <= val2
	case "ge": // >=
		return val1 >= val2
	default:
		log.Fatalf("unsupported operator: %s", op)
		return false
	}
}
