class_name Comparable

func eq(other) -> bool:
	push_error("No implementation here!")
	return false

func lt(other) -> bool:
	push_error("No implementation here!")
	return false

func gt(other) -> bool:
	push_error("No implementation here!")
	return false

func gte(other) -> bool:
	return eq(other) or gt(other)

func lte(other) -> bool:
	return eq(other) or lt(other)

func neq(other) -> bool:
	return not eq(other)
