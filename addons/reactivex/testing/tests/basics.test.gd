extends __GDRx_Test__

const TEST_UNIT_NAME = "BASICS"

func test_rx_map() -> bool:
	var observable = GDRx.of([1, 2, 3, 4])
	var mapped_observable = observable.map(func(x): return x * 2)
	var result = [2, 4, 6, 8, Comp()]
	return await compare(mapped_observable, result)

func test_rx_filter() -> bool:
	var observable = GDRx.of([1, 2, 3, 4])
	var filtered_observable = observable.filter(func(x): return x % 2 == 0)
	var result = [2, 4, Comp()]
	return await compare(filtered_observable, result)

func test_rx_zip() -> bool:
	var obs1 = GDRx.of([1, 2, 3])
	var obs2 = GDRx.of([4, 5])
	var obs3 = GDRx.of([6, 7, 8, 9])
	var zipped = GDRx.zip([obs1, obs2, obs3]).map(func(x : Tuple): return x.as_list())
	var result = [[1, 4, 6], [2, 5, 7], Comp()]
	return await compare(zipped, result)

func test_rx_safe_divison() -> bool:
	var safe_division = func(a, b):
		return a / b if b != 0 else DividedByZeroError.raise(-1)
	var mapped = GDRx.of([6, 2, 1, 0, 2, 1]) \
		.pairwise() \
		.map(func(tup : Tuple): return safe_division.call(tup.first, tup.second))
	var result = [3, 2, Err("DividedByZeroError")]
	return await compare(mapped, result)
