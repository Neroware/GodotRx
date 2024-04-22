extends ReactiveSignal
class_name ReactiveSignalT

var _type_list : Array
var _type_equality : Callable

var _arg_names : Array[StringName]

var _push_type_err : bool

var TList : Array:
	get: return self._type_list

var ArgNames : Array[StringName]:
	get: return self._arg_names

func _init(
	n_args : int,
	type_list_ : Array = [],
	arg_names_ : Array[StringName] = [],
	push_type_err : bool = true,
	type_equality : Callable = GDRx.basic.default_type_equality):
		var type_list = type_list_.duplicate()
		while type_list.size() < n_args:
			type_list.push_back(TYPE_MAX)
		self._type_list = type_list
		self._type_list.make_read_only()
		
		var c = 0
		var arg_names : Array[StringName] = arg_names_.duplicate()
		while arg_names.size() < n_args:
			arg_names.push_back("arg" + str(c))
			c += 1
		self._arg_names = arg_names
		self._arg_names.make_read_only()
		
		self._push_type_err = push_type_err
		self._type_equality = type_equality
		
		super._init(n_args)

func _type_check_fail(value, default = null):
	var exc = TypeMismatchError.new(value)
	if self._push_type_err: push_error(exc)
	exc.throw(value)
	return default

func _emit(args = []):
	var args_valid = RefValue.Set(true)
	GDRx.iter(args).enumerate(func(value, i : int):
		if not self._type_equality.call(self._type_list[i], value):
			args_valid.v = false
			self._type_check_fail(value)
			return false)
	
	if args_valid.v:
		super._emit(args)
