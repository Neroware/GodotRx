static func group_join_(
	right : Observable,
	left_duration_mapper : Callable,
	right_duration_mapper : Callable
) -> Callable:
	
#	"""Correlates the elements of two sequences based on overlapping
#	durations, and groups the results.
#
#	Args:
#		right: The right observable sequence to join elements for.
#		left_duration_mapper: A function to select the duration (expressed
#			as an observable sequence) of each element of the left observable
#			sequence, used to determine overlap.
#		right_duration_mapper: A function to select the duration (expressed
#			as an observable sequence) of each element of the right observable
#			sequence, used to determine overlap.
#
#	Returns:
#		An observable sequence that contains elements combined into a tuple
#	from source elements that have an overlapping duration.
#	"""
	
	var nothing = func(__):
		return null
	
	var group_join = func(left : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase, 
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var group = CompositeDisposable.new()
			var rcd = RefCountDisposable.new(group)
			var left_map : Dictionary = {} # TODO OrderedDict()
			var right_map : Dictionary = {}
			var left_id = [0]
			var right_id = [0]
			
			var on_next_left = func(value):
				var subject : Subject = Subject.new()
				
				var _id
				if true:
					var __ = LockGuard.new(left.lock)
					_id = left_id[0]
					left_id[0] += 1
					left_map[_id] = subject
				
				var result = RefValue.Null()
				if GDRx.try(func():
					result.v = Tuple.new([value, GDRx.util.add_ref(subject.as_observable(), rcd)])
				) \
				.catch("Error", func(e):
					push_error("*** Error: ", e)
					for left_value in left_map.values():
						left_value.on_error(e)
					
					observer.on_error(e)
				) \
				.end_try_catch(): return
				
				observer.on_next(result.v)
				
				for right_value in right_map.values():
					subject.on_next(right_value)
				
				var md = SingleAssignmentDisposable.new()
				group.add(md)
				
				var expire = func():
					if left_map.has(_id):
						left_map.erase(_id)
						subject.on_completed()
					
					group.remove(md)
				
				var duration = RefValue.Null()
				if GDRx.try(func():
					duration.v = left_duration_mapper.call(value)
				) \
				.catch("Error", func(e):
					for left_value in left_map.values():
						left_value.on_error(e)
					
					observer.on_error(e)
				) \
				.end_try_catch(): return
				
				var on_error = func(error):
					for left_value in left_map.values():
						left_value.on_error(error)
					
					observer.on_error(error)
				
				md.disposable = duration.v.pipe1(GDRx.op.take(1)).subscribe(
					nothing, on_error, expire, scheduler
				)
			
			var on_error_left = func(error):
				for left_value in left_map.values():
					left_value.on_error(error)
				
				observer.on_error(error)
			
			group.add(
				left.subscribe(
					on_next_left,
					on_error_left,
					observer.on_completed,
					scheduler
				)
			)
			
			var send_right = func(value):
				var _id
				if true:
					var __ = LockGuard.new(left.lock)
					_id = right_id[0]
					right_id[0] += 1
					right_map[_id] = value
				
				var md = SingleAssignmentDisposable.new()
				group.add(md)
				
				var expire = func():
					right_map.erase(_id)
					group.remove(md)
				
				var duration = RefValue.Null()
				if GDRx.try(func():
					duration.v = right_duration_mapper.call(value)
				) \
				.catch("Error", func(e):
					for left_value in left_map.values():
						left_value.on_error(e)
					
					observer.on_error(e)
				) \
				.end_try_catch(): return
				
				var on_error = func(error):
					var _guard = LockGuard.new(left.lock)
					for left_value in left_map.values():
						left_value.on_error(error)
					
					observer.on_error(error)
				
				md.disposable = duration.v.pipe1(GDRx.obs.take(1)).subscribe(
					nothing, on_error, expire,
					scheduler
				)
				
				if true:
					var __ = LockGuard.new(left.lock)
					for left_value in left_map.values():
						left_value.on_next(value)
			
			var on_error_right = func(error):
				for left_value in left_map.values():
					left_value.as_observer().on_error(error)
				
				observer.on_error(error)
			
			group.add(right.subscribe(
				send_right, on_error_right, func():return, scheduler
			))
			return rcd
		
		return Observable.new(subscribe)
	
	return group_join
