static func concat_(sources : Array[Observable]) -> Callable:
	var concat = func(source : Observable) -> Observable:
#		"""Concatenates all the observable sequences.
#
#		Examples:
#			>>> var op = concat.call([xs, ys, zs])
#
#		Returns:
#			An operator function that takes one or more observable sources and
#			returns an observable sequence that contains the elements of
#			each given sequence, in sequential order.
#		"""
		var sources_ : Array[Observable] = sources.duplicate()
		sources_.push_front(source)
		return GDRx.obs.concat_with_iterable(GDRx.util.Iter(sources_))
	
	return concat
