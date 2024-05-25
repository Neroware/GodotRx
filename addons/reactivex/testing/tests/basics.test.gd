extends __GDRx_Test__

const TEST_UNIT_NAME = "BASICS"

func test_rx_map() -> bool:
	var observable = GDRx.of([1, 2, 3, 4])
	var mapped_observable = observable.map(func(x): return x * 2)
	var result = [2, 4, 6, 8, Comp()]
	return await is_equals(mapped_observable, result)

func test_rx_filter() -> bool:
	var observable = GDRx.of([1, 2, 3, 4])
	var filtered_observable = observable.filter(func(x): return x % 2 == 0)
	var result = [2, 4, Comp()]
	return await is_equals(filtered_observable, result)
