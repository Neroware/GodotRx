static func window_toggle_(
	openings : Observable, closing_mapper : Callable
) -> Callable:
#	"""Projects each element of an observable sequence into zero or
#	more windows.
#
#	Args:
#		source: Source observable to project into windows.
#
#	Returns:
#		An observable sequence of windows.
#	"""
	var window_toggle = func(source : Observable) -> Observable:
		var mapper = func(args : Tuple):
			var window = args.at(1)
			return window
		
		return openings.pipe2(
			GDRx.op.group_join(
				source,
				closing_mapper,
				func(__): return GDRx.obs.empty()
			),
			GDRx.op.map(mapper)
		)
	
	return window_toggle

static func window_(boundaries : Observable) -> Callable:
#	"""Projects each element of an observable sequence into zero or
#	more windows.
#
#	Args:
#		source: Source observable to project into windows.
#
#	Returns:
#		An observable sequence of windows.
#	"""
	var window = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var window_subject = RefValue.Set(Subject.new())
			var d = CompositeDisposable.new()
			var r = RefCountDisposable.new(d)
			
			observer.on_next(GDRx.util.add_ref(window_subject.v.as_observable(), r))
			
			var on_next_window = func(x):
				window_subject.v.on_next(x)
			
			var on_error = func(err):
				window_subject.v.on_error(err)
				observer.on_error(err)
			
			var on_completed = func():
				window_subject.v.on_completed()
				observer.on_completed()
			
			d.add(
				source.subscribe(
					on_next_window, on_error, on_completed,
					scheduler
				)
			)
			
			var on_next_observer = func(_w : Observable):
				window_subject.v.on_completed()
				window_subject.v = Subject.new()
				observer.on_next(GDRx.util.add_ref(window_subject.v.as_observable(), r))
			
			d.add(
				boundaries.subscribe(
					on_next_observer, on_error, on_completed,
					scheduler
				)
			)
			
			return r
		
		return Observable.new(subscribe)
	
	return window


static func window_when_(closing_mapper : Callable) -> Callable:
#	"""Projects each element of an observable sequence into zero or
#	more windows.
#
#	Args:
#		source: Source observable to project into windows.
#
#	Returns:
#		An observable sequence of windows.
#	"""
	var window_when = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var m = SerialDisposable.new()
			var d = CompositeDisposable.new(m)
			var r = RefCountDisposable.new(d)
			var window = RefValue.Set(Subject.new())
			
			observer.on_next(GDRx.util.add_ref(window.v, r))
			
			var on_next = func(value):
				window.v.on_next(value)
			
			var on_error = func(error):
				window.v.on_error(error)
				observer.on_error(error)
			
			var on_completed = func():
				window.v.on_completed()
				observer.on_completed()
			
			d.add(
				source.subscribe(on_next, on_error, on_completed,
				scheduler)
			)
			
			var create_window_on_completed = func(__rec_cb : Callable):
				var window_close = RefValue.Null()
				if GDRx.try(func():
					window_close.v = closing_mapper.call()
				) \
				.catch("Error", func(error):
					observer.on_error(error)
				) \
				.end_try_catch(): return
				
				var on_completed_inner = func():
					window.v.on_completed()
					window.v = Subject.new()
					observer.on_next(GDRx.util.add_ref(window.v, r))
					__rec_cb.bind(__rec_cb).call()
				
				var m1 = SingleAssignmentDisposable.new()
				m.disposable = m1
				m1.disposable = window_close.v.pipe1(GDRx.op.take(1)).subscribe(
					func(__): return, on_error, on_completed_inner, scheduler
				)
			
			create_window_on_completed.bind(create_window_on_completed).call()
			return r
		
		return Observable.new(subscribe)
	
	return window_when
