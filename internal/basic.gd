func noop(__ = null, ___ = null):
	pass

func identity(x):
	return x

func default_now() -> Dictionary:
	return Time.get_datetime_dict_from_system(true)

func default_comparer(x, y) -> bool:
	return x == y

func default_sub_comparer(x, y):
	return x - y

func default_key_serializer(x) -> String:
	return str(x)

func default_error(err):
	push_error(err)
