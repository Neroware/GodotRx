static func concat_(sources_) -> Callable:
	var sources : Array[Observable] = GDRx.util.unpack_arg(sources_)
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
		var _sources : Array[Observable] = sources.duplicate()
		_sources.push_front(source)
		return GDRx.obs.concat_with_iterable(GDRx.to_iterable(_sources))
	
	return concat
