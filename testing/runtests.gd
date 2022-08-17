extends Node

enum ETestState {
	RUNNING = 0,
	SUCCESS = 1,
	FAILED = -1
}

func _assert(pred : bool, test_id : int, succ : Array[ETestState], succ_idx : int = 0):
	if pred: succ[succ_idx] = ETestState.SUCCESS
	else: succ[succ_idx] = ETestState.FAILED
	emit_signal("on_assert", test_id, succ)

func _fail(test_id : int, succ : Array[ETestState], succ_idx : int = 0):
	succ[succ_idx] = ETestState.FAILED
	emit_signal("on_assert", test_id, succ)

func _success(test_id : int, succ : Array[ETestState], succ_idx : int = 0):
	succ[succ_idx] = ETestState.SUCCESS
	emit_signal("on_assert", test_id, succ)

func _launch_next_test(test_id : int, test_callbacks : Array, n_succ = 0, n_fail = 0):
	if test_id >= test_callbacks.size():
		print("Finished all tests!")
		print("FAILED: ", n_fail)
		print("SUCCESS: ", n_succ)
	else:
		#print("[ReactiveX]: '", test_callbacks[test_id] + "'")
		print("[ReactiveX]: " + test_callbacks[test_id].substr(6), " (", (test_id + 1), " / ", test_callbacks.size(), ")")
		call(test_callbacks[test_id], test_id)

func _ready():
	var test_callbacks = []
	for m in get_method_list():
		if not m["name"].begins_with("_test_"):
			continue
		test_callbacks.append(m["name"])

	var on_assert = GDRx.CreateGodotUserSignal(self, "on_assert", 2)
	var current_test = RefValue.Set(0)

	var success_count = RefValue.Set(0)
	var fail_count = RefValue.Set(0)

	on_assert.subscribe(
		func(t : Tuple):
			var test_id : int = t.at(0)
			var succ : Array[ETestState] = t.at(1)
			if test_id != current_test.v:
				return

			if succ.all(func(elem): return elem == ETestState.SUCCESS):
				print("[ReactiveX]: Success\n")
				success_count.v += 1
				current_test.v += 1
				_launch_next_test(current_test.v, test_callbacks, success_count.v, fail_count.v)
			elif succ.any(func(elem): return elem == ETestState.FAILED):
				print("[ReactiveX]: Failed\n")
				fail_count.v += 1
				current_test.v += 1
				_launch_next_test(current_test.v, test_callbacks, success_count.v, fail_count.v)
	)
	print("[ReactiveX]: Running tests . . .\n")
	_launch_next_test(current_test.v, test_callbacks)

func _test_op_all(test_id : int):
	var succ : Array[ETestState] = [0, 0]

	var stream = GDRx.FromRange(0, 100, 3).pipe1(
		GDRx.op.all(func(i : int): return i % 3 == 0)
	)
	var v1 = RefValue.Set(false)
	stream.subscribe(
		func(b : bool): v1.v = b,
		func(__): _fail(test_id, succ, 0),
		func(): _assert(v1.v, test_id, succ, 0)
	)
	var stream2 = GDRx.FromRange(0, 100, 3).pipe1(
		GDRx.op.all(func(i : int): return i % 2 == 0)
	)
	var v2 = RefValue.Set(false)
	stream2.subscribe(
		func(b : bool): v2.v = not b,
		func(__): _fail(test_id, succ, 1),
		func(): _assert(v2.v, test_id, succ, 1)
	)

func _test_op_amb(test_id : int):
	var succ : Array[ETestState] = [0]

	var timer1 = GDRx.StartTimespan(1.0)
	var timer2 = GDRx.StartPeriodicTimer(0.5)
	var ret = GDRx.ReturnValue(42)
	var stream = timer1.pipe2(
		GDRx.op.amb(ret),
		GDRx.op.amb(timer2)
	)

	var res = RefValue.Set(0)
	stream.subscribe(
		func(v): res.v = v,
		func(__): _fail(test_id, succ, 0),
		func(): _assert(res.v == 42, test_id, succ)
	)

