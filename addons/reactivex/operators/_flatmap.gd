static func _flat_map_internal(
	source : Observable,
	mapper = null,
	mapper_indexed = null
) -> Observable:
	var projection = func(x, i : int) -> Observable:
		var mapper_result = mapper.call(x) if mapper != null else mapper_indexed.call(x, i) if mapper_indexed != null else GDRx.basic.identity
		var result : Observable
		if mapper_result is Observable:
			result = mapper_result
		elif mapper_result is IterableBase:
			result = GDRx.obs.from_iterable(mapper_result)
		elif mapper_result is Array:
			result = GDRx.obs.from_iterable(GDRx.to_iterable(mapper_result))
		else:
			BadMappingError.new(
				"Mapper failed to produce a sequence of observables!").throw()
			result = GDRx.obs.empty()
		return result
	
	return source.pipe2(
		GDRx.op.map_indexed(projection),
		GDRx.op.merge_all()
	)

static func flat_map_(
	mapper = null
) -> Callable:
	var flat_map = func(source : Observable) -> Observable:
#		"""One of the Following:
#		Projects each element of an observable sequence to an observable
#		sequence and merges the resulting observable sequences into one
#		observable sequence.
#
#		Example:
#			>>> flat_map.call(source)
#
#		Args:
#			source: Source observable to flat map.
#
#		Returns:
#			An operator function that takes a source observable and returns
#			an observable sequence whose elements are the result of invoking
#			the one-to-many transform function on each element of the
#			input sequence .
#		"""
		var ret : Observable
		if mapper is Callable:
			ret = _flat_map_internal(source, mapper)
		else:
			ret = _flat_map_internal(source, func(__): return mapper)
		return ret
	
	return flat_map

static func flat_map_indexed_(
	mapper_indexed = null
) -> Callable:
	var flat_map_indexed = func(source : Observable) -> Observable:
#		"""One of the Following:
#		Projects each element of an observable sequence to an observable
#		sequence and merges the resulting observable sequences into one
#		observable sequence.
#
#		Example:
#			>>> flat_map_indexed.call(source)
#
#		Args:
#			source: Source observable to flat map.
#
#		Returns:
#			An observable sequence whose elements are the result of invoking
#			the one-to-many transform function on each element of the input
#			sequence.
#		"""
		var ret : Observable
		if mapper_indexed is Callable:
			ret = _flat_map_internal(source, null, mapper_indexed)
		else:
			ret = _flat_map_internal(source, func(__): return mapper_indexed)
		return ret
	
	return flat_map_indexed

static func flat_map_latest_(
	mapper : Callable
) -> Callable:
	var flat_map_latest = func(source : Observable) -> Observable:
#		"""Projects each element of an observable sequence into a new
#		sequence of observable sequences by incorporating the element's
#		index and then transforms an observable sequence of observable
#		sequences into an observable sequence producing values only
#		from the most recent observable sequence.
#
#		Args:
#			source: Source observable to flat map latest.
#
#		Returns:
#			An observable sequence whose elements are the result of
#			invoking the transform function on each element of source
#			producing an observable of Observable sequences and that at
#			any point in time produces the elements of the most recent
#			inner observable sequence that has been received.
#		"""
		return source.pipe2(
			GDRx.op.map(mapper),
			GDRx.op.switch_latest()
		)
	
	return flat_map_latest
