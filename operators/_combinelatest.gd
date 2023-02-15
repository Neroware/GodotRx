static func combine_latest_(others : Array[Observable]) -> Callable:
	var combine_latest = func(source : Observable) -> Observable:
#		"""Merges the specified observable sequences into one
#		observable sequence by creating a tuple whenever any
#		of the observable sequences produces an element.
#
#		Examples:
#			>>> var obs = combine_latest.call(source)
#
#		Returns:
#			An observable sequence containing the result of combining
#			elements of the sources into a tuple.
#		"""
		
		var sources : Array[Observable] = others.duplicate()
		sources.push_front(source)
		return GDRx.obs.combine_latest(sources)
	
	return combine_latest
