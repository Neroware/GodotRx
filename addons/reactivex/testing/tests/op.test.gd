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
