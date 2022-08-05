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
			result = GDRx.obs.from_iterable(GDRx.util.Iter(mapper_result))
		else:
			push_error("Mapper failed to produce a squence of observables!")
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
		return source.pipe2(
			GDRx.op.map(mapper),
			GDRx.op.switch_latest()
		)
	
	return flat_map_latest
