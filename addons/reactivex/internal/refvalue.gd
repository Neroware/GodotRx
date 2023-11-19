## Wraps a value
## 
## RefValue is used to account for the Python [code]nonlocal[/code]-keyword.
## A for a lambda-function global variable with basic type
## cannot be changed for its parent scopes, so it is wrapped
## and referenced via [code]refvalue.v[/code]

class_name RefValue

## Wrapped value
var v : Variant

func _init(v_ : Variant = null):
	self.v = v_

## Create a new RefValue with initial value
static func Set(v_ : Variant = null) -> RefValue:
	return RefValue.new(v_)

## Create a new RefValue with initial value [code]null[/code]
static func Null() -> RefValue:
	return RefValue.new()

func eq(other) -> bool:
	return GDRx.eq(v, other.v) if other is RefValue else GDRx.eq(v, other)

func _to_string():
	return str(v)
