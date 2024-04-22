static func sequence_equal_(
	second, # Array or Observable
	comparer  = null,
	second_it : IterableBase = null
) -> Callable:
	var comparer_ = comparer if comparer != null else GDRx.basic.default_comparer
	var second_ : Observable 
	if second is Array:
		second_ = GDRx.obs.from_iterable(GDRx.util.Iter(second))
	else:
		second_ = second if second_it == null else GDRx.obs.from_iterable(second_it)
	
	var sequence_equal = func(source : Observable) -> Observable:
#		"""Determines whether two sequences are equal by comparing the
#		elements pairwise using a specified equality comparer.
#
#		Examples:
#			>>> var res = sequence_equal([1,2,3])
#			>>> var res = sequence_equal([{ "value": 42 }], func(x, y): return x.value == y.value)
#			>>> var res = sequence_equal(GDRx.obs.return_value(42))
#			>>> var res = sequence_equal(
#				GDRx.obs.return_value({ "value": 42 }),
#				func(x, y): return x.value == y.value
#			)
#
#		Args:
#			source: Source obserable to compare.
#
#		Returns:
#			An observable sequence that contains a single element which
#		indicates whether both sequences are of equal length and their
#		corresponding elements are equal according to the specified
#		equality comparer.
#		"""
		var first = source
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var donel = [false]
			var doner = [false]
			var ql = []
			var qr = []
			
			var on_next1 = func(x):
				if qr.size() > 0:
					var v = qr.pop_front()
					var equal = RefValue.Set(true)
					if GDRx.try(func():
						equal.v = comparer_.call(v, x)
					) \
					.catch("Error", func(e):
						observer.on_error(e)
					) \
					.end_try_catch(): return
					
					if not equal.v:
						observer.on_next(false)
						observer.on_completed()
				
				elif doner[0]:
					observer.on_next(false)
					observer.on_completed()
				else:
					ql.append(x)
			
			var on_completed1 = func():
				donel[0] = true
				if ql.is_empty():
					if not qr.is_empty():
						observer.on_next(false)
						observer.on_completed()
					elif doner[0]:
						observer.on_next(true)
						observer.on_completed()
			
			var on_next2 = func(x):
				if ql.size() > 0:
					var v = ql.pop_front()
					var equal = RefValue.Set(true)
					if GDRx.try(func():
						equal.v = comparer_.call(v, x)
					) \
					.catch("Error", func(e):
						observer.on_error(e)
					) \
					.end_try_catch(): return
					
					if not equal.v:
						observer.on_next(false)
						observer.on_completed()
				
				elif donel[0]:
					observer.on_next(false)
					observer.on_completed()
				else:
					qr.append(x)
			
			var on_completed2 = func():
				doner[0] = true
				if qr.is_empty():
					if not ql.is_empty():
						observer.on_next(false)
						observer.on_completed()
					elif donel[0]:
						observer.on_next(true)
						observer.on_completed()
			
			var subscription1 = first.subscribe(
				on_next1, observer.on_error, on_completed1, scheduler
			)
			var subscription2 = second_.subscribe(
				on_next2, observer.on_error, on_completed2, scheduler
			)
			
			return CompositeDisposable.new([subscription1, subscription2])
		
		return Observable.new(subscribe)
	
	return sequence_equal
