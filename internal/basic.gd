func noop(__ = null, ___ = null):
	pass

func identity(x, __ = null):
	return x

var _start_time_sec : float = Scheduler.to_seconds(Time.get_datetime_dict_from_system(true))
func default_now() -> float:
	return self._start_time_sec + 1000.0 * Time.get_ticks_msec()

func default_comparer(x, y) -> bool:
	return x.eq(y) if (x is Object and x.has_method("eq")) else x == y

func default_sub_comparer(x, y):
	return x - y

func default_key_serializer(x) -> String:
	return str(x)

func default_error(err):
	if err is ThrowableBase:
		err.throw()
	GDRx.raise(GDRx.exc.Exception.new(err))

func default_crash(e):
	#OS.alert("Unhandled exception: " + str(e))
	push_error("Unhandled exception: " + str(e))
	print_stack()
	GDRx.get_tree().quit(1)

func default_condition(__ = null, ___ = null) -> bool:
	return true

func default_factory(__ : SchedulerBase) -> Observable:
	return GDRx.obs.empty()

func default_type_equality(type, value) -> bool:
	if type is Dictionary:
		return typeof(value) == TYPE_INT and type.find_key(value) != null
	return is_instance_of(value, type)
