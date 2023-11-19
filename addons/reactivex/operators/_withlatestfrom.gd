static func with_latest_from_(sources_) -> Callable:
#	"""With latest from operator.
#
#	Merges the specified observable sequences into one observable
#	sequence by creating a tuple only when the first
#	observable sequence produces an element. The observables can be
#	passed either as seperate arguments or as a list.
#
#	Examples:
#		>>> var op = GDRx.op.with_latest_from([obs1])
#		>>> var op = GDRx.op.with_latest_from([obs1, obs2, obs3])
#
#	Returns:
#		An observable sequence containing the result of combining
#	elements of the sources into a tuple.
#	"""
	var sources : Array[Observable] = GDRx.util.unpack_arg(sources_)
	var with_latest_from = func(source : Observable) -> Observable:
		return GDRx.obs.with_latest_from(source, sources)
	return with_latest_from
