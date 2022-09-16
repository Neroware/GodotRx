extends Node

@export var tests : String = "map"

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
		func _init(value):
			self.value = value
	
	var seq : Array
	
	func _init(seq : Array):
		self.seq = seq
		super._init(seq)
	
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
			if expected == check:
				return ETestState.SUCCESS
			print("[ReactiveX]: Equality check failed: ", expected, " != ", check, ".")
			return ETestState.FAILED
		
		var on_next = func(i):
			if seq_remaining.v <= 0:
				return
			
			var expected = self.next()
			if expected is Complete:
				print("[ReactiveX]: Expected end of sequence but got item!")
				end_sequence.call(ETestState.FAIL)
			
			elif expected is Error:
				print("[ReactiveX]: Expected error in sequence but got item!")
				end_sequence.call(ETestState.FAIL)
			
			elif expected is UnsubscribeOn:
				end_sequence.call(cmp.call(expected.value, i))
			
			elif cmp.call(expected, i) == ETestState.FAILED:
				end_sequence.call(ETestState.FAILED)
		
		var on_error = func(__):
			if seq_remaining.v <= 0:
				return
			
			var expected = self.next()
			if expected is ObservableSequence.Error:
				end_sequence.call(ETestState.SUCCESS)
			else:
				print("[ReactiveX]: Expected error as end of sequence!")
				end_sequence.call(ETestState.FAILED)
		
		var on_completed = func():
			if seq_remaining.v <= 0:
				return
			
			var expected = self.next()
			if expected is ObservableSequence.Complete:
				end_sequence.call(ETestState.SUCCESS)
			else:
				print("[ReactiveX]: Expected end of sequence!")
				end_sequence.call(ETestState.FAILED)
		
		obs.subscribe(on_next, on_error, on_completed)

func _ready():
	var test_results = {}
	var test_names = self.tests.split(",")
	for t in test_names:
		test_results[t] = ETestState.SUCCESS
	
	var tests = ArrayIterator.new(test_names)
	var current_test = RefValue.Null()
	var test_counter = RefValue.Set(0)
	var n_tests = test_names.size()
	
	var print_results = func():
		var n_passed = 0
		var n_skipped = 0
		var n_failed = 0
		for t in test_names:
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
	
	var next_test = func():
		current_test.v = tests.next()
		test_counter.v += 1
		if current_test.v is tests.End:
			print_results.call()
			return
		print("[ReactiveX]: Running test '", current_test, "' . . . (", test_counter, " / ", n_tests, ")")
		var method = get("_test_" + current_test.v)
		if method == null:
			sequence_finished.emit(ETestState.MISSING, -1)
		else:
			method.call()
	
	GDRx.FromGodotSignal(self.sequence_finished).subscribe(
		func(tup : Tuple):
			var result : ETestState = tup.at(0)
			var remaining : int = tup.at(1)
			if result == ETestState.FAILED:
				print("[ReactiveX]: FAILED\n")
				test_results[current_test.v] = ETestState.FAILED
				next_test.call()
			elif result == ETestState.MISSING:
				print("[ReactiveX]: SKIPPED\n")
				test_results[current_test.v] = ETestState.MISSING
				next_test.call()
			elif remaining == 0:
				print("[ReactiveX]: SUCCESS\n")
				next_test.call()
	)
	
	next_test.call()

static func UNSUB(v) -> ObservableSequence.UnsubscribeOn:
	return ObservableSequence.UnsubscribeOn.new(v)
var COMPLETE : ObservableSequence.Complete = ObservableSequence.Complete.new()
var ERROR : ObservableSequence.Error = ObservableSequence.Error.new()

# ============================================================================ #
# 								Test Suit									   #
# ============================================================================ #
func _test_map():
	var seq = ObservableSequence.new([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, COMPLETE])
	var obs = GDRx.FromRange(10)
	seq.compare(obs, self.sequence_finished)
