static func group_by_until_(
	key_mapper : Callable,
	duration_mapper : Callable,
	element_mapper = null,
	subject_mapper = null
) -> Callable:
	
	"""Groups the elements of an observable sequence according to a
	specified key mapper function. A duration mapper function is used
	to control the lifetime of groups. When a group expires, it receives
	an OnCompleted notification. When a new element with the same key
	value as a reclaimed group occurs, the group will be reborn with a
	new lifetime request.

	Examples:
		>>> GDRx.op.group_by_until(func(x): return x.id, null, func() : return GDRx.obs.never())
		>>> GDRx.op.group_by_until(
			func(x): return x.id, func(x): return x.name, func(grp): return GDRx.obs.never()
		)
		>>> GDRx.op.group_by_until(
			func(x): return x.id,
			func(x): return x.name,
			func(grp): return GDRx.obs.never(),
			func(): return ReplaySubject.new()
		)

	Args:
		key_mapper: A function to extract the key for each element.
		duration_mapper: A function to signal the expiration of a group.
		subject_mapper: A function that returns a subject used to initiate
			a grouped observable. Default mapper returns a Subject object.

	Returns: a sequence of observable groups, each of which corresponds to
	a unique key value, containing all elements that share that same key
	value. If a group's lifetime expires, a new group with the same key
	value can be created once an element with such a key value is
	encountered.
	"""
	
	var element_mapper_ : Callable = element_mapper if element_mapper != null else GDRx.basic.identity
	
	var default_subject_mapper = func(): return Subject.new()
	var subject_mapper_ : Callable = subject_mapper if subject_mapper != null else default_subject_mapper
	
	var group_by_until = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase, 
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var writers : Dictionary = {} # TODO OrderedDict
			var group_disposable = CompositeDisposable.new()
			var ref_count_disposable = RefCountDisposable.new(group_disposable)
			
			var on_next = func(x):
				var writer : Subject = null
				var key = null
				
				key = key_mapper.call(x)
				if key is GDRx.err.Error:
					for wrt in writers.values():
						wrt.as_observer().on_error(key)
					observer.on_error(key)
					return
				
				var fire_new_map_entry = false
				writer = writers.get(key)
				if writer == null:
					writer = subject_mapper_.call()
					if writer is GDRx.err.Error:
						for wrt in writers.values():
							wrt.as_observer().on_error(writer)
						observer.on_error(writer)
						return
					if not writer is Subject:
						for wrt in writers.values():
							wrt.as_observer().on_error(GDRx.err.BadMappingException.new())
						observer.on_error(GDRx.err.BadMappingException.new())
						return
					
					writers[key] = writer
					fire_new_map_entry = true
				
				if fire_new_map_entry:
					var group : GroupedObservable = GroupedObservable.new(
						key, writer.as_observable(), ref_count_disposable
					)
					var duration_group : GroupedObservable = GroupedObservable.new(
						key, writer.as_observable()
					)
					var duration = duration_mapper.call(duration_group)
					if duration is GDRx.err.Error:
						for wrt in writers.values():
							wrt.as_observer().on_error(duration)
						observer.on_error(duration)
						return
					if not duration is Observable:
						for wrt in writers.values():
							wrt.as_observer().on_error(GDRx.err.BadMappingException.new())
						observer.on_error(GDRx.err.BadMappingException.new())
						return
					
					observer.on_next(group)
					var sad = SingleAssignmentDisposable.new()
					group_disposable.add(sad)
					
					var expire = func():
						if writers.get(key) != null:
							writers.erase(key)
							writer.as_observer().on_completed()
						
						group_disposable.remove(sad)
					
					var on_next = func(value):
						pass
					
					var on_error = func(exn):
						for wrt in writers.values():
							wrt.as_observer().on_error(exn)
						observer.on_error(exn)
					
					var on_completed = func():
						expire.call()
					
					sad.set_disposable(duration.pipe1(
						GDRx.op.take(1)
					).subscribe(
						on_next, on_error, on_completed, scheduler
					))
				
				var element = element_mapper_.call(x)
				if element is GDRx.err.Error:
					for wrt in writers.values():
						wrt.as_observer().on_error(element)
					observer.on_error(element)
					return
				
				writer.as_observer().on_next(element)
			
			var on_error = func(ex):
				for wrt in writers.values():
					wrt.as_observer().on_error(ex)
				observer.on_error(ex)
			
			var on_completed = func():
				for wrt in writers.values():
					wrt.as_observer().on_completed()
				observer.on_completed()
			
			group_disposable.add(source.subscribe(
				on_next, on_error, on_completed, scheduler
			))
			return ref_count_disposable
		
		return Observable.new(subscribe)
	
	return group_by_until
