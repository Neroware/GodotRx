### RefValue is used to account for Python's 'nonlocal'-keyword
### A for a lambda-function global variable with basic type
### cannot be changed for its parent scopes, so it is wrapped
### and referenced via name.v

class_name RefValue

var v : Variant

func _init(v : Variant = null):
	self.v = v

static func Set(v : Variant = null) -> RefValue:
	return RefValue.new(v)

static func Null() -> RefValue:
	return RefValue.new()

func _to_string():
	return str(v)
