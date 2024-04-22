func noop(__ = null, ___ = null):
	pass

func identity(x, __ = null):
	return x

func default_now() -> float:
	return Time.get_unix_time_from_datetime_dict(
		Time.get_datetime_dict_from_system(true))

func default_comparer(x, y) -> bool:
	return x.eq(y) if (x is Object and x.has_method("eq")) else x == y

func default_sub_comparer(x, y):
	return x - y

func default_key_serializer(x) -> String:
	return str(x)

func default_error(err):
	if err is ThrowableBase:
		err.throw()
	GDRx.raise(RxBaseError.new(err))

func default_crash(e):
	#OS.alert("Unhandled error: " + str(e))
	push_error("Unhandled error: " + str(e))
	print_stack()
	GDRx.get_tree().quit(1)

func default_condition(__ = null, ___ = null) -> bool:
	return true

func default_factory(__ : SchedulerBase): # -> Observable: # TODO
	return GDRx.obs.empty()

func default_type_equality(type, value) -> bool:
	if type is Dictionary:
		return typeof(value) == TYPE_INT and type.find_key(value) != null
	return is_instance_of(value, type)
