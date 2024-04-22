class HashSet:
	var _comparer : Callable
	var _set : Array
	
	func _init(comparer : Callable):
		self._comparer = comparer
		self._set = []
	
	static func array_index_of_comparer(
		array : Array, item, comparer : Callable
	):
		for i in range(array.size()):
			var a = array[i]
			if comparer.call(a, item):
				return i
		return -1
	
	func push(value):
		var ret_value = HashSet.array_index_of_comparer(self._set, value, self._comparer) == -1
		if ret_value:
			self._set.append(ret_value)
		return ret_value

static func distinct_(
	key_mapper : Callable = GDRx.basic.identity,
	comparer : Callable = GDRx.basic.default_comparer
) -> Callable:
	var comparer_ = comparer
	
	var distinct = func(source : Observable) -> Observable:
#		"""Returns an observable sequence that contains only distinct
#		elements according to the key_mapper and the comparer. Usage of
#		this operator should be considered carefully due to the
#		maintenance of an internal lookup structure which can grow
#		large.
#
#		Examples:
#			>>> var obs = distinct.call(source)
#
#		Args:
#			source: Source observable to return distinct items from.
#
#		Returns:
#			An observable sequence only containing the distinct
#			elements, based on a computed key value, from the source
#			sequence.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var hashset = HashSet.new(comparer_)
			
			var on_next = func(x):
				var key = RefValue.Set(x)
				if GDRx.try(func():
					key.v = key_mapper.call(key.v)
				) \
				.catch("Error", func(err):
					observer.on_error(err)
				) \
				.end_try_catch(): return
				
				if hashset.push(key.v):
					observer.on_next(x)
			
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return distinct
