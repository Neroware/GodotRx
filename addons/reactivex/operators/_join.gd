static func join_(
	right : Observable,
	left_duration_mapper : Callable,
	right_duration_mapper : Callable
) -> Callable:
	var join = func(source : Observable) -> Observable:
#		"""Correlates the elements of two sequences based on
#		overlapping durations.
#
#		Args:
#			source: Source observable.
#
#		Return:
#			An observable sequence that contains elements
#			combined into a tuple from source elements that have an overlapping
#			duration.
#		"""
		var left = source
		
		var subscribe = func(
			observer : ObserverBase, 
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var group = CompositeDisposable.new()
			var left_done = RefValue.Set(false)
			var left_map : Dictionary = {} # TODO OrderedDict()
			var left_id = RefValue.Set(0)
			var right_done = RefValue.Set(false)
			var right_map : Dictionary = {} # TODO OrderedDict()
			var right_id = RefValue.Set(0)
			
			var on_next_left = func(value):
				var duration = RefValue.Null()
				var current_id = left_id.v
				left_id.v += 1
				var md = SingleAssignmentDisposable.new()
				
				left_map[current_id] = value
				group.add(md)
				
				var expire = func():
					if left_map.has(current_id):
						left_map.erase(current_id)
					if left_map.is_empty() and left_done.v:
						observer.on_completed()
					
					group.remove(md)
				
				if GDRx.try(func():
					duration.v = left_duration_mapper.call(value)
				) \
				.catch("Error", func(error):
					observer.on_error(error)
				) \
				.end_try_catch(): return
				
				md.disposable = duration.v.pipe1(GDRx.op.take(1)).subscribe(
					func(__):return, observer.on_error, func(): expire.call(),
					scheduler
				)
				
				for val in right_map.values():
					var result = Tuple.new([value, val])
					observer.on_next(result)
			
			var on_completed_left = func():
				left_done.v = true
				if right_done.v or left_map.is_empty():
					observer.on_completed()
			
			group.add(
				left.subscribe(
					on_next_left,
					observer.on_error,
					on_completed_left,
					scheduler
				)
			)
			
			var on_next_right = func(value):
				var duration = RefValue.Null()
				var current_id = right_id.v
				right_id.v += 1
				var md = SingleAssignmentDisposable.new()
				right_map[current_id] = value
				group.add(md)
				
				var expire = func():
					if right_map.has(current_id):
						right_map.erase(current_id)
					if right_map.is_empty() and right_done.v:
						observer.on_completed()
					
					group.remove(md)
				
				if GDRx.try(func():
					duration.v = right_duration_mapper.call(value)
				) \
				.catch("Error", func(error):
					observer.on_error(error)
				) \
				.end_try_catch(): return
				
				md.disposable = duration.v.pipe1(GDRx.op.take(1)).subscribe(
					func(__):return, observer.on_error, func(): expire.call(),
					scheduler
				)
				
				for val in left_map.values():
					var result = Tuple.new([val, value])
					observer.on_next(result)
			
			var on_completed_right = func():
				right_done.v = true
				if left_done.v or right_map.is_empty():
					observer.on_completed()
			
			group.add(
				right.subscribe(
					on_next_right,
					observer.on_error,
					on_completed_right,
					scheduler
				)
			)
			return group
		
		return Observable.new(subscribe)
	
	return join
