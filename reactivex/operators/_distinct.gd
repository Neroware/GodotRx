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
		var ret_value = array_index_of_comparer(self._set, value, self._comparer) == -1
		if ret_value:
			self._set.append(ret_value)
		return ret_value

func distinct_(
	key_mapper : Callable = GDRx.basic.identity,
	comparer : Callable = GDRx.basic.default_comparer
) -> Callable:
	var comparer_ = comparer
	
	var distinct = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var hashset = HashSet.new(comparer_)
			
			var on_next = func(x):
				var key = x
				key = key_mapper.call(key)
				if key is GDRx.err.Error:
					observer.on_error(key)
					return
				
				if hashset.push(key):
					observer.on_next(x)
			
			return source.subscribe(
				on_next, observer.on_error, observer.on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return distinct
