### Apparently, there is no such thing as a 'Non-Local' in Godot, so I need help!
### Help by a professional psychologist. Why am I even porting this API to Godot!?
### I mean, I must be insane. I did not even know the 'nonlocal'-keyword before I've
### started working on this Plugin and oh jez, now I get it...

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
