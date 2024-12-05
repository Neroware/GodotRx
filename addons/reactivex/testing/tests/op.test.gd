extends __GDRx_Test__

const TEST_UNIT_NAME = "OPS"

func test_op_all() -> bool:
	var obs = GDRx.from([1, 2, 3, 4]).all(func(i): return i <= 4)
	var result = [true, Comp()]
	return await compare(obs, result)

func test_op_amb() -> bool:
	var els = EventLoopScheduler.new()
	var t1 = GDRx.start_periodic_timer(0.25).take(3)
	var t2 = GDRx.start_periodic_timer(0.1).take(2)
	var obs = t1.amb(t2)
	var result = [0, 1, Comp()]
	return await compare(obs, result)

func test_op_average() -> bool:
	var obs = GDRx.from([1.0, 2.0, 3.0, 4.0]).average()
	var result = [2.5, Comp()]
	return await compare(obs, result)

#func test_op_buffer() -> bool:
	#var t1 = GDRx.start_periodic_timer(0.1).take(8)
	#var t2 = GDRx.start_periodic_timer(0.45)
	#var obs = t1.buffer(t2)
	#var result = [[0, 1, 2, 3], [4, 5, 6, 7], Comp()]
	#return await compare(obs, result)

func test_op_buffer_with_count() -> bool:
	var obs = GDRx.from([1, 2, 3, 4, 5, 6, 7, 8]).buffer_with_count(3)
	var result = [[1, 2, 3], [4, 5, 6], [7, 8], Comp()]
	return await compare(obs, result)

#func test_op_buffer_with_time() -> bool:
	#var obs = GDRx.start_periodic_timer(0.1).take(8).buffer_with_time(0.45)
	#var result = [[0, 1, 2, 3], [4, 5, 6, 7], Comp()]
	#return await compare(obs, result)

func test_op_catch() -> bool:
	var obs = GDRx.from([1, 2, 3, 4, "5", 6, "7", 8]) \
		.filter(func(i): return i if i is int else BadArgumentError.raise(-1)) \
		.catch(func(err, source): return GDRx.just(42))
	var result = [1, 2, 3, 4, 42, Comp()]
	return await compare(obs, result)

func test_op_combine_latest() -> bool:
	var obs1 = GDRx.from([0, 1, 2, 3])
	var obs2 = GDRx.from([0, 1, 2, 3, 4])
	var t1 = GDRx.start_periodic_timer(0.05).take(3)
	var obs = obs1.combine_latest([t1, obs2])
	var result = [
		Tuple.new([3, 0, 4]),
		Tuple.new([3, 1, 4]),
		Tuple.new([3, 2, 4]),
		Comp()
	]
	return await compare(obs, result)

func test_op_concat() -> bool:
	var obs1 = GDRx.from(["a", "b", "c"])
	var t1 = GDRx.start_periodic_timer(0.05).take(3)
	var obs2 = GDRx.just(42)
	var obs = obs1.concat([t1, obs2])
	var result = ["a", "b", "c", 0, 1, 2, 42, Comp()]
	return await compare(obs, result)

func test_op_contains() -> bool:
	var seq = GDRx.from(["aaa", "aab", "bb", "baa"])
	var obs1 = seq.contains("bb")
	var obs2 = seq.contains("bbb")
	return await compare(obs1, [true, Comp()]) and await compare(obs2, [false, Comp()])

func test_op_count() -> bool:
	var obs = GDRx.from(["aaa", "aab", "bb", "baa"]).count()
	var result = [4, Comp()]
	return await compare(obs, result)

func test_op_debounce() -> bool:
	var obs = GDRx.merge([
			GDRx.from([1, 2, 3, 4]),
			GDRx.start_timer(0.1)]) \
		.debounce(0.05)
	var result = [4, 0, Comp()]
	return await compare(obs, result)

func test_op_default_if_empty() -> bool:
	var seq = GDRx.from([1, 2, 3, 4])
	var obs1 = seq.filter(func(i): return i > 42).default_if_empty(-1)
	var obs2 = seq.filter(func(i): return i < 42).default_if_empty(-1)
	return await compare(obs1, [-1, Comp()]) or await compare(obs2, [1, 2, 3, 4, Comp()])

func test_op_delay() -> bool:
	var obs = GDRx.merge([
		GDRx.from([1, 2, 3]).delay(0.2),
		GDRx.start_timer(0.1)])
	var result = [0, 1, 2, 3, Comp()]
	return await compare(obs, result)

func test_op_delay_subscription() -> bool:
	var obs = GDRx.merge([
		GDRx.from([1, 2, 3]).delay_subscription(0.2),
		GDRx.start_timer(0.1)])
	var result = [0, 1, 2, 3, Comp()]
	return await compare(obs, result)

func test_op_delay_with_mapper() -> bool:
	var obs = GDRx.merge([
		GDRx.from([1, 2, 3]).delay_with_mapper(func(x): return GDRx.just(x).delay(0.1) if x > 0 else GDRx.just(x)),
		GDRx.start_timer(0.05)])
	var result = [0, 1, 2, 3, Comp()]
	return await compare(obs, result)

func test_op_dematerialize() -> bool:
	var obs = GDRx.from([
			OnNextNotification.new(42),
			OnNextNotification.new("Foo"),
			OnErrorNotification.new(BadArgumentError.new())]) \
		.dematerialize()
	var result = [42, "Foo", Err("BadArgumentError")]
	return await compare(obs, result)

func test_op_distinct() -> bool:
	var obs = GDRx.from(["aa", "ab", "aa", "aba", "bb", "aba", "abb"]).distinct()
	var result = ["aa", "ab", "aba", "bb", "abb", Comp()]
	return await compare(obs, result)

func test_op_distinct_until_changed() -> bool:
	var obs = GDRx.from(["a", "a", "b", "a", "b", "b", "c"]).distinct_until_changed()
	var result = ["a", "b", "a", "b", "c", Comp()]
	return await compare(obs, result)

func test_op_do():
	var flag_on_next = RefValue.Set(true)
	var flag_on_complete = RefValue.Set(true)
	var flag_after_next = RefValue.Set(true)
	var flag_on_subscribe = RefValue.Set(true)
	var flag_on_terminate = RefValue.Set(true)
	var flag_after_terminate = RefValue.Set(true)
	var flag_finally = RefValue.Set(true)
	var obs = GDRx.just(42) \
		.do_action(func(__): flag_on_next.v = false, null, func(): flag_on_complete.v = false) \
		.do_after_next(func(__): flag_after_next.v = false) \
		.do_on_subscribe(func(): flag_on_subscribe.v = false) \
		.do_on_terminate(func(): flag_on_terminate.v = false) \
		.do_after_terminate(func(): flag_after_terminate.v = false) \
		.do_finally(func(): flag_finally.v = false)
	return await compare(obs, [42, Comp()]) or flag_on_next.v or flag_on_complete.v or flag_after_next.v or flag_on_subscribe.v or flag_on_terminate.v or flag_after_terminate.v or flag_finally.v

func test_op_with_latest_from():
	var t1 = GDRx.start_periodic_timer(1.1).take(2)
	var t2 = GDRx.start_periodic_timer(0.25)
	var t3 = GDRx.start_periodic_timer(0.5)
	var obs = t1.with_latest_from([t2, t3])
	return await compare(obs, [Tuple.new([0, 3, 1]), Tuple.new([1, 7, 3]), Comp()])
