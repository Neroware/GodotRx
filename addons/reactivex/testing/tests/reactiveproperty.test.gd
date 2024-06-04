extends __GDRx_Test__

const TEST_UNIT_NAME = "REACTIVE_PROPERTY"

func test_reactive_property() -> bool:
	var prop = ReactiveProperty.new(0)
	var xs : Array = []
	var __ = prop.subscribe(func(x): xs.append(x))
	
	prop.Value = 1
	prop.Value = 2
	prop.Value = 3
	var correct_value : bool = prop.Value == 3
	prop.dispose()
	
	var result = [0, 1, 2, 3, Comp()]
	return await compare(GDRx.from_array(xs), result) or !correct_value

var _member : int = -1
func test_from_member() -> bool:
	self._member = 0
	var prop = ReactiveProperty.FromMember(self, "_member")
	var xs : Array = []
	var __ = prop.subscribe(func(x): xs.append(x))
	
	prop.Value = 1
	prop.Value = 2
	prop.Value = 3
	var correct_value : bool = prop.Value == 3
	prop.dispose()

	var result = [0, 1, 2, 3, Comp()]
	return await compare(GDRx.from_array(xs), result) or !correct_value or self._member != 3

var _setget_member : int = -1
func _set_member(value : int):
	self._setget_member = value
func _get_member() -> int:
	return self._setget_member
func test_setget_reactive_property() -> bool:
	self._set_member(0)
	var prop = ReactiveProperty.FromGetSet(self._get_member, self._set_member)
	var xs : Array = []
	var __ = prop.subscribe(func(x): xs.append(x))
	
	prop.Value = 1
	prop.Value = 2
	prop.Value = 3
	var correct_value : bool = prop.Value == 3
	prop.dispose()
	
	var result = [0, 1, 2, 3, Comp()]
	return await compare(GDRx.from_array(xs), result) or !correct_value or self._get_member() != 3

func test_readonly_reactive_property() -> bool:
	var prop = ReactiveProperty.new(0)
	var ro_prop = prop.to_readonly()
	var xs : Array = []
	var __ = ro_prop.subscribe(func(x): xs.append(x))
	
	prop.Value = 1
	prop.Value = 2
	prop.Value = 3
	var correct_value : bool = prop.Value == 3
	prop.dispose()
	
	var result = [0, 1, 2, 3, Comp()]
	return await compare(GDRx.from_array(xs), result) or !correct_value

func test_sourced_reactive_property() -> bool:
	var subject = Subject.new()
	var prop = ReactiveProperty.new(0, true, true, subject.as_observable())
	var ro_prop = prop.to_readonly()
	var xs : Array = []
	var __ = ro_prop.subscribe(func(x): xs.append(x))
	
	subject.on_next(1)
	subject.on_next(2)
	subject.on_next(3)
	var correct_value : bool = prop.Value == 3
	subject.dispose()
	
	var result = [0, 1, 2, 3, Comp()]
	return await compare(GDRx.from_array(xs), result) or !correct_value

func test_computed_reactive_property() -> bool:
	var prop1 = ReactiveProperty.new(0)
	var prop2 = ReactiveProperty.new(0)
	var ro_prop1 = prop1.to_readonly()
	var ro_prop2 = prop2.to_readonly()
	var prop = ReactiveProperty.Computed2(ro_prop1, ro_prop2, func(x, y): return x + y)
	var xs : Array = []
	var __ = prop.subscribe(func(x): xs.append(x))
	
	prop1.Value = 1
	prop2.Value = 2
	prop1.Value = 3
	prop2.Value = 4
	var correct_value : bool = prop1.Value == 3 and prop2.Value == 4
	prop1.dispose()
	
	var result = [0, 1, 3, 5, 7, Comp()]
	return await compare(GDRx.from_array(xs), result) or !correct_value
