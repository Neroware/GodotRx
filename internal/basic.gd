func noop(__ = null, ___ = null):
	pass

func identity(x):
	return x

func default_now() -> Dictionary:
	return Time.get_datetime_dict_from_system(true)

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
