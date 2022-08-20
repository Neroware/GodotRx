static func group_by_until_(
	key_mapper : Callable,
	duration_mapper : Callable,
	element_mapper = null,
	subject_mapper = null
) -> Callable:
	
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
						wrt.observer().on_error(key)
					observer.on_error(key)
					return
				
				var fire_new_map_entry = false
				writer = writers.get(key)
				if writer == null:
					writer = subject_mapper_.call()
					if writer is GDRx.err.Error:
						for wrt in writers.values():
							wrt.observer().on_error(writer)
						observer.on_error(writer)
						return
					if not writer is Subject:
						for wrt in writers.values():
							wrt.observer().on_error(GDRx.err.BadMappingException.new())
						observer.on_error(GDRx.err.BadMappingException.new())
						return
					
					writers[key] = writer
					fire_new_map_entry = true
				
				if fire_new_map_entry:
					var group : GroupedObservable = GroupedObservable.new(
						key, writer.observable(), ref_count_disposable
					)
					var duration_group : GroupedObservable = GroupedObservable.new(
						key, writer.observable()
					)
					var duration = duration_mapper.call(duration_group)
					if duration is GDRx.err.Error:
						for wrt in writers.values():
							wrt.observer().on_error(duration)
						observer.on_error(duration)
						return
					if not duration is Observable:
						for wrt in writers.values():
							wrt.observer().on_error(GDRx.err.BadMappingException.new())
						observer.on_error(GDRx.err.BadMappingException.new())
						return
					
					observer.on_next(group)
					var sad = SingleAssignmentDisposable.new()
					group_disposable.add(sad)
					
					var expire = func():
						if writers.get(key) != null:
							writers.erase(key)
							writer.observer().on_completed()
						
						group_disposable.remove(sad)
					
					var on_next = func(value):
						pass
					
					var on_error = func(exn):
						for wrt in writers.values():
							wrt.observer().on_error(exn)
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
						wrt.observer().on_error(element)
					observer.on_error(element)
					return
				
				writer.observer().on_next(element)
			
			var on_error = func(ex):
				for wrt in writers.values():
					wrt.observer().on_error(ex)
				observer.on_error(ex)
			
			var on_completed = func():
				for wrt in writers.values():
					wrt.observer().on_completed()
				observer.on_completed()
			
			group_disposable.add(source.subscribe(
				on_next, on_error, on_completed, scheduler
			))
			return ref_count_disposable
		
		return Observable.new(subscribe)
	
	return group_by_until
