extends __GDRx_Test__

const TEST_UNIT_NAME = "TIMERS"

func test_rx_timer() -> bool:
	var obs = GDRx.start_timer(0.1)
	var result = [0, Comp()]
	return await is_equals(obs, result)

func test_rx_periodic_timer() -> bool:
	var obs = GDRx.start_periodic_timer(0.1).take(5)
	var result = [0, 1, 2, 3, 4, Comp()]
	return await is_equals(obs, result)
