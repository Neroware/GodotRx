extends __GDRx_Test__

const TEST_UNIT_NAME = "SCHEDULER"

func test_nts_priodic_timer() -> bool:
	var t = GDRx.start_periodic_timer(0.1, NewThreadScheduler.singleton()).take(2)
	var result = [0, 1, Comp()]
	return await compare(t, result)
