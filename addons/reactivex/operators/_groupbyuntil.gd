static func group_by_until_(
	key_mapper : Callable,
	duration_mapper : Callable,
	element_mapper = null,
	subject_mapper = null
) -> Callable:
	
#	"""Groups the elements of an observable sequence according to a
#	specified key mapper function. A duration mapper function is used
#	to control the lifetime of groups. When a group expires, it receives
#	an OnCompleted notification. When a new element with the same key
#	value as a reclaimed group occurs, the group will be reborn with a
#	new lifetime request.
#
#	Examples:
#		>>> GDRx.op.group_by_until(func(x): return x.id, null, func() : return GDRx.obs.never())
#		>>> GDRx.op.group_by_until(
#			func(x): return x.id, func(x): return x.name, func(grp): return GDRx.obs.never()
#		)
#		>>> GDRx.op.group_by_until(
#			func(x): return x.id,
#			func(x): return x.name,
#			func(grp): return GDRx.obs.never(),
#			func(): return ReplaySubject.new()
#		)
#
#	Args:
#		key_mapper: A function to extract the key for each element.
#		duration_mapper: A function to signal the expiration of a group.
#		subject_mapper: A function that returns a subject used to initiate
#			a grouped observable. Default mapper returns a Subject object.
#
#	Returns: a sequence of observable groups, each of which corresponds to
#	a unique key value, containing all elements that share that same key
#	value. If a group's lifetime expires, a new group with the same key
#	value can be created once an element with such a key value is
#	encountered.
#	"""
	
	var element_mapper_ : Callable = element_mapper if element_mapper != null else GDRx.basic.identity
	
	var default_subject_mapper = func(): return Subject.new()
	@warning_ignore("incompatible_ternary")
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
				var writer = RefValue.Null()
				var key = RefValue.Null()
				
				if GDRx.try(func():
					key.v = key_mapper.call(x)
				) \
				.catch("Error", func(__):
					for wrt in writers.values():
						wrt.on_error(key.v)
					observer.on_error(key.v)
				) \
				.end_try_catch(): return
				
				var fire_new_map_entry = false
				writer.v = writers.get(key.v)
				if writer.v == null:
					if GDRx.try(func():
						writer.v = subject_mapper_.call()
					) \
					.catch("Error", func(e):
						for wrt in writers.values():
							wrt.on_error(e)
						observer.on_error(e)
					) \
					.end_try_catch(): return
					
					writers[key.v] = writer.v
					fire_new_map_entry = true
				
				if fire_new_map_entry:
					var group : GroupedObservable = GroupedObservable.new(
						key.v, writer.v.as_observable(), ref_count_disposable
					)
					var duration_group : GroupedObservable = GroupedObservable.new(
						key.v, writer.v.as_observable()
					)
					var duration = RefValue.Null()
					if GDRx.try(func():
						duration.v = duration_mapper.call(duration_group)
					) \
					.catch("Error", func(e):
						for wrt in writers.values():
							wrt.on_error(e)
						observer.on_error(e)
					) \
					.end_try_catch(): return
					
					observer.on_next(group)
					var sad = SingleAssignmentDisposable.new()
					group_disposable.add(sad)
					
					var expire = func():
						if writers.get(key.v) != null:
							writers.erase(key.v)
							writer.v.on_completed()
						
						group_disposable.remove(sad)
					
					var on_next = func(__):
						pass
					
					var on_error = func(exn):
						for wrt in writers.values():
							wrt.on_error(exn)
						observer.on_error(exn)
					
					var on_completed = func():
						expire.call()
					
					sad.disposable = duration.v.pipe1(
						GDRx.op.take(1)
					).subscribe(
						on_next, on_error, on_completed, scheduler
					)
				
				var element = RefValue.Null()
				if GDRx.try(func():
					element.v = element_mapper_.call(x)
				) \
				.catch("Error", func(e):
					for wrt in writers.values():
						wrt.on_error(e)
					observer.on_error(e)
				) \
				.end_try_catch(): return
				
				writer.v.on_next(element.v)
			
			var on_error = func(ex):
				for wrt in writers.values():
					wrt.on_error(ex)
				observer.on_error(ex)
			
			var on_completed = func():
				for wrt in writers.values():
					wrt.on_completed()
				observer.on_completed()
			
			group_disposable.add(source.subscribe(
				on_next, on_error, on_completed, scheduler
			))
			return ref_count_disposable
		
		return Observable.new(subscribe)
	
	return group_by_until
