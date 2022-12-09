extends Node

@export var tests : String = "amb,throw,range,window_with_count,compare_array,new_thread_scheduler,faulty_map,coroutine,separate_thread,threaded_try_catch,faulty_map_new_thread,timer_faulty_filter,reactive_property,fix_type_basic,fix_type_class,fix_type_mismatch_basic"

enum ETestState {
	SUCCESS = 1,
	FAILED = 0,
	MISSING = -1
}

signal sequence_finished(result : ETestState, remaining : int)

class ObservableSequence extends ArrayIterator:
	class Error:
		pass
	class Complete:
		pass
	class UnsubscribeOn:
		var value = null
		func _init(value_):
			self.value = value_
	
	var seq : Array
	
	func _init(seq_ : Array):
		self.seq = seq_
		super._init(seq_)
	
	func count_internal_sequences() -> int:
		var count = 0
		for elem in self.seq:
			if elem is ObservableSequence.Complete:
				break
			elif elem is ObservableSequence.Error:
				break
			elif elem is ObservableSequence.UnsubscribeOn:
				if elem.value is ObservableSequence:
					count = count + 1 + elem.value.count_internal_sequences()
				break
			elif elem is ObservableSequence:
				count += 1 + elem.count_internal_sequences()
		return count
	
	func compare(obs : Observable, result : Signal, remaining : RefValue = null):
		var seq_remaining : RefValue = RefValue.Set(1 + self.count_internal_sequences()) if remaining == null else remaining
		
		var end_sequence = func(state : ETestState):
			seq_remaining.v = seq_remaining.v - 1 if state == ETestState.SUCCESS else -1
			result.emit(state, seq_remaining.v)
		
		var cmp = func(expected, check) -> ETestState:
			if expected is ObservableSequence and check is Observable:
				expected.compare(check, result, seq_remaining)
				return ETestState.SUCCESS
			if expected is Array and expected.hash() == check.hash():
				return ETestState.SUCCESS
			if expected is Comparable and expected.eq(check):
				return ETestState.SUCCESS
			if expected == check:
				return ETestState.SUCCESS
			print("[ReactiveX]: Equality check failed: ", expected, " != ", check, ".")
			return ETestState.FAILED
		
		var on_next = func(i):
			if seq_remaining.v <= 0:
				return
			
			var expected = self.next()
			if expected is Complete:
				print("[ReactiveX]: Expected end of sequence but got item: ", i)
				end_sequence.call(ETestState.FAILED)
			
			elif expected is Error:
				print("[ReactiveX]: Expected error in sequence but got item: ", i)
				end_sequence.call(ETestState.FAILED)
			
			elif expected is UnsubscribeOn:
				end_sequence.call(cmp.call(expected.value, i))
			
			elif cmp.call(expected, i) == ETestState.FAILED:
				end_sequence.call(ETestState.FAILED)
		
		var on_error = func(err):
			if seq_remaining.v <= 0:
				return
			
			var expected = self.next()
			if expected is ObservableSequence.Error:
				end_sequence.call(ETestState.SUCCESS)
			else:
				print("[ReactiveX]: Sequence failed with unexpected error: ", err)
				end_sequence.call(ETestState.FAILED)
		
		var on_completed = func():
			if seq_remaining.v <= 0:
				return
			
			var expected = self.next()
			if expected is ObservableSequence.Complete:
				end_sequence.call(ETestState.SUCCESS)
			else:
				print("[ReactiveX]: Sequence completed unexpected!")
				end_sequence.call(ETestState.FAILED)
		
		obs.subscribe(on_next, on_error, on_completed)

var _next_sequence : bool

var _test_names : PackedStringArray
var _test_it : ArrayIterator
var _current_test
var _test_counter : int
var _n_tests : int

var test_results : Dictionary = {}

func _ready():
	self._test_names = self.tests.split(",", false)
	for t in self._test_names:
		test_results[t] = ETestState.SUCCESS
	
	self._next_sequence = false
	
	self._test_it = ArrayIterator.new(self._test_names)
	self._current_test = ""
	self._test_counter = 0
	self._n_tests = self._test_names.size()
	
	self.sequence_finished.connect(
		func(result : ETestState, remaining : int):
			if result == ETestState.FAILED:
				print("[ReactiveX]: FAILED\n")
				self.test_results[self._current_test] = ETestState.FAILED
				_next_test()
			elif result == ETestState.MISSING:
				print("[ReactiveX]: SKIPPED\n")
				self.test_results[self._current_test] = ETestState.MISSING
				_next_test()
			elif remaining == 0:
				print("[ReactiveX]: SUCCESS\n")
				_next_test()
			)
	
	self._next_test()

func _print_results():
	var n_passed = 0
	var n_skipped = 0
	var n_failed = 0
	for t in self._test_names:
		var res = "success"
		if test_results[t] == ETestState.FAILED:
			res = "failed"
			n_failed += 1
		elif test_results[t] == ETestState.MISSING:
			res = "skipped"
			n_skipped += 1
		else:
			n_passed += 1
		print("[ReactiveX]: ", t, ": ", res)
	print("\n[ReactiveX]: =====================")
	print("[ReactiveX]: PASSED ", n_passed)
	print("[ReactiveX]: FAILED ", n_failed)
	print("[ReactiveX]: SKIPPED ", n_skipped)

func _next_test():
	self._current_test = self._test_it.next()
	self._test_counter += 1
	if self._current_test is self._test_it.End:
		_print_results()
		return
	print("[ReactiveX]: Running test '", self._current_test, "' . . . (", self._test_counter, " / ", self._n_tests, ")")
	self._next_sequence = true

func _process(_delta):
	if self._next_sequence:
		self._next_sequence = false
		var method = get("_test_" + self._current_test)
		if method == null:
			sequence_finished.emit(ETestState.MISSING, -1)
		else:
			method.call()

static func UNSUB(v) -> ObservableSequence.UnsubscribeOn:
	return ObservableSequence.UnsubscribeOn.new(v)
var COMPLETE : ObservableSequence.Complete = ObservableSequence.Complete.new()
var ERROR : ObservableSequence.Error = ObservableSequence.Error.new()

# ============================================================================ #
# 								Test Suit									   #
# ============================================================================ #

func _test_amb():
	var obs1 : Observable = GDRx.start_periodic_timer(1.0).map(func(i): return "T1")
	var obs2 : Observable = GDRx.start_timer(0.5).map(func(i): return "T2")
	var obs3 : Observable = GDRx.start_periodic_timer(2.5).map(func(i): return "T3")
	var obs = GDRx.amb([obs1, obs2, obs3])
	var seq = ObservableSequence.new(["T2", COMPLETE])
	seq.compare(obs, self.sequence_finished)

func _test_throw():
	var obs = GDRx.throw(GDRx.exc.Exception.new("Kill sequence"))
	var seq = ObservableSequence.new([ERROR])
	seq.compare(obs, self.sequence_finished)

func _test_range():
	var seq = ObservableSequence.new([1, 3, 5, 7, 9, 11, COMPLETE])
	var obs = GDRx.range(1, 13, 2)
	seq.compare(obs, self.sequence_finished)

func _test_window_with_count():
	var obs = GDRx.range(16).window_with_count(5)
	var seq = ObservableSequence.new([
		ObservableSequence.new([0, 1, 2, 3, 4, COMPLETE]),
		ObservableSequence.new([5, 6, 7, 8, 9, COMPLETE]),
		ObservableSequence.new([10, 11, 12, 13, 14, COMPLETE]),
		ObservableSequence.new([15, COMPLETE]),
		COMPLETE
	])
	seq.compare(obs, self.sequence_finished)

func _test_compare_array():
	var obs = GDRx.just([1, 2, 3])
	var seq = ObservableSequence.new([[1, 2, 3], COMPLETE])
	seq.compare(obs, self.sequence_finished)

func _test_new_thread_scheduler():
	var scheduler : NewThreadScheduler = NewThreadScheduler.new()
	
	var foo = GDRx.return_value("foo").delay(10.0)
	foo.subscribe(
		func(i): print("[ReactiveX]: This element was delayed by 10 seconds on a separate thread: ", i), 
		func(e): return, 
		func(): return, 
		scheduler
	)
	
	var obs = GDRx.return_value(42, scheduler)
	var seq = ObservableSequence.new([42, COMPLETE])
	seq.compare(obs, self.sequence_finished)

func _test_separate_thread():
	var run = func():
		var id = OS.get_thread_caller_id()
		
		var obs = GDRx.return_value(0).map(func(__): return OS.get_thread_caller_id())
		var seq = ObservableSequence.new([id, COMPLETE])
		seq.compare(obs, self.sequence_finished)
	
	var thread = GDRx.concur.StartableThread.new(run)
	thread.start()

func _test_threaded_try_catch():
	GDRx.try(func():
		GDRx.raise_message("Outer Error!")
		var run = func():
			var id = OS.get_thread_caller_id()
			GDRx.try(func():
				GDRx.raise_message("Error on Thread!")
				var obs = GDRx.return_value(0).map(func(__): return OS.get_thread_caller_id())
				var seq = ObservableSequence.new([id, COMPLETE])
				seq.compare(obs, self.sequence_finished)
			) \
			.end_try_catch()
	
		GDRx.try(func():
			GDRx.raise_message("Inner Error!")
			var thread = GDRx.concur.StartableThread.new(run)
			thread.start()
		) \
		.catch("Exception", func(e): print("[ReactiveX]: Inner ERROR: ", e)) \
		.end_try_catch()
	) \
	.catch("Exception", func(e): print("[ReactiveX]: Outer ERROR: ", e)) \
	.end_try_catch()

func _test_faulty_map():
	var obs = GDRx.from_array([1, 2, 3, 4, 5, 6]) \
	.map(func(i):
		if i < 5:
			return 2 * i
		else:
			return GDRx.exc.Exception.new("Expected Error!").throw(-1)
		)
	var seq = ObservableSequence.new([2, 4, 6, 8, ERROR])
	seq.compare(obs, self.sequence_finished)

func _test_faulty_map_new_thread():
	var obs = GDRx.from_iterable(GDRx.iter([1, 2, 3, 4, 5, 6]), NewThreadScheduler.new()) \
	.map(func(i):
		if i < 5:
			return 2 * i
		else:
			return GDRx.exc.Exception.new("Expected Error!").throw(-1)
		)
	var seq = ObservableSequence.new([2, 4, 6, 8, ERROR])
	seq.compare(obs, self.sequence_finished)

func _test_coroutine():
	var coroutine = func(a, b, c):
		print("[ReactiveX]: Running Coroutine before await...")
		await get_tree().create_timer(0.05).timeout
		print("[ReactiveX]: Continue Coroutine after await...")
		return a < b and b < c
	
	var obs = GDRx.from_coroutine(coroutine, [1, 2, 3])
	var seq = ObservableSequence.new([true, COMPLETE])
	seq.compare(obs, self.sequence_finished)

func _test_timer_faulty_filter():
	var obs = GDRx.start_periodic_timer(0.05).filter(
		func(i):
			if i == 3:
				GDRx.raise_message("Expected Error in Filter")
				return false
			return true
	)
	var seq = ObservableSequence.new([0, 1, 2, ERROR])
	seq.compare(obs, self.sequence_finished)

func _test_reactive_property():
	var prop1 = ReactiveProperty.new(10)
	var prop2 = ReactiveProperty.new(20)
	var prop3 = ReactiveProperty.new(30)
	
	var obs = ReactiveProperty.Computed3(
		prop1.to_readonly(),
		prop2.to_readonly(),
		prop3.to_readonly(),
		func(x, y, z): return x + y + z
	)
	var seq = ObservableSequence.new([UNSUB(60)])
	seq.compare(obs, self.sequence_finished)

func _test_fix_type_basic():
	var prop = ReactiveProperty.new(42).oftype(TYPE_INT)
	var seq = ObservableSequence.new([UNSUB(42)])
	seq.compare(prop, self.sequence_finished)

func _test_fix_type_class():
	var obs = GDRx.from_array([
		RefValue.Set(0), 
		RefValue.Set(1), 
		RefValue.Set(2),
		func(): return 3,
		RefValue.Set(4)
	]).oftype(RefValue, false).map(func(i : RefValue): return i.v)
	var seq = ObservableSequence.new([0, 1, 2, ERROR])
	seq.compare(obs, self.sequence_finished)

func _test_fix_type_mismatch_basic():
	var obs = GDRx.from_array([1, 2, 3, "4", 5, 6]).oftype(TYPE_INT, false)
	var seq = ObservableSequence.new([1, 2, 3, ERROR])
	seq.compare(obs, self.sequence_finished)
