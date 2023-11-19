static func retry_(retry_count : int = -1) -> Callable:
#	"""Repeats the source observable sequence the specified number of
#	times or until it successfully terminates. If the retry count is
#	not specified, it retries indefinitely.
#
#	Examples:
#		>>> var retried = GDRx.op.retry()
#		>>> var retried = GDRx.op.retry(42)
#
#	Args:
#		retry_count: [Optional] Number of times to retry the sequence.
#			If not provided, retry the sequence indefinitely.
#
#	Returns:
#		An observable sequence producing the elements of the given
#		sequence repeatedly until it terminates successfully.
#	"""
	var retry = func(source : Observable) -> Observable:
		var gen : IterableBase
		if retry_count < 0:
			gen = InfiniteIterable.new(source)
		else:
			var _gen_lst = [] ; for __ in range(retry_count): _gen_lst.append(source)
			gen = GDRx.to_iterable(_gen_lst)
		
		return GDRx.obs.catch_with_iterable(gen)
	
	return retry
