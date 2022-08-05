static func group_join_(
	right : Observable,
	left_duration_mapper : Callable,
	right_duration_mapper : Callable
) -> Callable:
	
	var nothing = func(__):
		return null
	
	var group_join = func(left : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase, 
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var group = CompositeDisposable.new()
			var rcd = RefCountDisposable.new(group)
			var left_map : Dictionary = {} ## TODO OrderedDict()
			var right_map : Dictionary = {}
			var left_id = [0]
			var right_id = [0]
			
			var on_next_left = func(value):
				var subject : Subject = Subject.new()
				
				left._lock.lock()
				var _id = left_id[0]
				left_id[0] += 1
				left_map[_id] = subject
				left._lock.unlock()
				
				var result = Tuple.new([value, GDRx.util.AddRef(subject.observable(), rcd)])
				observer.on_next(result)
				
				for right_value in right_map.values():
					subject.observer().on_next(right_value)
				
				var md = SingleAssignmentDisposable.new()
				group.add(md)
				
				var expire = func():
					if _id in left_map.keys():
						left_map.erase(_id)
						subject.observer().on_completed()
					group.remove(md)
				
				var duration = left_duration_mapper.call(value)
				if duration is GDRx.err.Error:
					for left_value in left_map.values():
						left_value.observer().on_error(duration)
					
					observer.on_error(duration)
					return
				if not duration is Observable:
					for left_value in left_map.values():
						left_value.observer().on_error(GDRx.err.BadMappingException.new())
					
					observer.on_error(GDRx.err.BadMappingException.new())
					return
				
				var on_error = func(error):
					for left_value in left_map.values():
						left_value.observer().on_error(error)
					
					observer.on_error(error)
				
				md.set_disposable(duration.pipe1(GDRx.op.take(1)).subscribe(
					nothing, on_error, expire, scheduler
				))
			
			var on_error_left = func(error):
				for left_value in left_map.values():
					left_value.observer().on_error(error)
				
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
				left._lock.lock()
				var _id = right_id[0]
				right_id[0] += 1
				right_map[_id] = value
				left._lock.unlock()
				
				var md = SingleAssignmentDisposable.new()
				group.add(md)
				
				var expire = func():
					right_map.erase(_id)
					group.remove(md)
				
				var duration = right_duration_mapper.call(value)
				if duration is GDRx.err.Error:
					for left_value in left_map.values():
						left_value.observer().on_error(duration)
					
					observer.on_error(duration)
					return
				if not duration is Observable:
					for left_value in left_map.values():
						left_value.observer().on_error(GDRx.err.BadMappingException.new())
					
					observer.on_error(GDRx.err.BadMappingException.new())
					return
				
				var on_error = func(error):
					left._lock.lock()
					for left_value in left_map.values():
						left_value.observer().on_next(value)
					left._lock.unlock()
			
			var on_error_right = func(error):
				for left_value in left_map.values():
					left_value.observer().on_error(error)
				
				observer.on_error(error)
			
			group.add(right.subscribe(
				send_right, on_error_right, func():return, scheduler
			))
			return rcd
		
		return Observable.new(subscribe)
	
	return group_join
