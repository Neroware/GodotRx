static func fork_join_(args) -> Callable:
	var fork_join = func(source : Observable) -> Observable:
#		"""Wait for observables to complete and then combine last values
#		they emitted into a tuple. Whenever any of that observables
#		completes without emitting any value, result sequence will
#		complete at that moment as well.
#
#		Examples:
#			>>> var obs = fork_join.call(source)
#
#		Returns:
#			An observable sequence containing the result of combining
#			last element from each source in given sequence.
#		"""
		var sources : Array[Observable] = GDRx.util.unpack_arg(args)
		sources.push_front(source)
		return GDRx.obs.fork_join(sources)
	
	return fork_join
