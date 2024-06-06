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

