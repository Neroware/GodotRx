extends RefCounted
class_name __GDRx_Test__

var test_results : Array = []

func _init():
	test_results = []

func run_tests():
	var test_unit_name = self.get("TEST_UNIT_NAME") if self.get("TEST_UNIT_NAME") \
		 != null else "<<test>>"
	print("[ReactiveX]: Running tests for: ", test_unit_name)
	var method_list = get_method_list()
	for method in method_list:
		if method.name.begins_with("test_"):
			print("[ReactiveX]: Running ", method.name)
			var result = await call(method.name)
			test_results.append({method.name: result})
	_print_results()
	print("[ReactiveX]: ----------------")

func _print_results():
	for result in test_results:
		for test_name in result.keys():
			if result[test_name]:
				print("[ReactiveX]: > ", test_name, ": FAIL")
			else:
				print("[ReactiveX]: > ", test_name, ": PASS")

class _Error extends Comparable:
	var type : String
	func _init(type_ : String):
		self.type = type_
	
	func eq(other) -> bool:
		return other is _Error and other.type == self.type

class _Completed extends Comparable:
	func eq(other) -> bool:
		return other is _Completed

static func Err(type : String = "RxBaseError") -> _Error:
	return _Error.new(type)

static func Comp() -> _Completed:
	return _Completed.new()

static func to_history() -> Callable:
	var to_history_ = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			
			var result = []
			
			var on_next = func(i):
				result.append(i)
			var on_error = func(e):
				result.append(_Error.new(e.tags().back()))
				observer.on_next(result)
				observer.on_completed()
			var on_completed = func():
				result.append(_Completed.new())
				observer.on_next(result)
				observer.on_completed()
			
			return source.subscribe(on_next, on_error, on_completed, scheduler)
			
		return Observable.new(subscribe)
		
	return to_history_

static func is_equals(obs : Observable, seq : Array) -> bool:
	var history : Observable = to_history().call(obs)
	var result : Array = await history.next()
	for i in range(seq.size()):
		if i >= result.size() or not GDRx.eq(seq[i], result[i]):
			return true
	return false
