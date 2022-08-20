## Wraps a value
##
## RefValue is used to account for the Python [code]nonlocal[/code]-keyword.
## A for a lambda-function global variable with basic type
## cannot be changed for its parent scopes, so it is wrapped
## and referenced via [code]refvalue.v[/code]

class_name RefValue

## Wrapped value
var v : Variant

func _init(v : Variant = null):
	self.v = v

## Create a new RefValue with initial value
static func Set(v : Variant = null) -> RefValue:
	return RefValue.new(v)

## Create a new RefValue with initial value [code]null[/code]
static func Null() -> RefValue:
	return RefValue.new()

func _to_string():
	return str(v)
