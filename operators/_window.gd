static func window_toggle_(
	openings : Observable, closing_mapper : Callable
) -> Callable:
	"""Projects each element of an observable sequence into zero or
	more windows.

	Args:
		source: Source observable to project into windows.

	Returns:
		An observable sequence of windows.
	"""
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
	"""Projects each element of an observable sequence into zero or
	more windows.

	Args:
		source: Source observable to project into windows.

	Returns:
		An observable sequence of windows.
	"""
	var window = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var window_subject = RefValue.Set(Subject.new())
			var d = CompositeDisposable.new()
			var r = RefCountDisposable.new(d)
			
			observer.on_next(GDRx.util.AddRef(window_subject.v.observable(), r))
			
			var on_next_window = func(x):
				window_subject.v.observer().on_next(x)
			
			var on_error = func(err):
				window_subject.v.observer().on_error(err)
				observer.on_error(err)
			
			var on_completed = func():
				window_subject.v.observer().on_completed()
				observer.on_completed()
			
			d.add(
				source.subscribe(
					on_next_window, on_error, on_completed,
					scheduler
				)
			)
			
			var on_next_observer = func(w : Observable):
				window_subject.v.observer().on_completed()
				window_subject.v = Subject.new()
				observer.on_next(GDRx.util.AddRef(window_subject.v.observable(), r))
			
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
	"""Projects each element of an observable sequence into zero or
	more windows.

	Args:
		source: Source observable to project into windows.

	Returns:
		An observable sequence of windows.
	"""
	var window_when = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var m = SerialDisposable.new()
			var d = CompositeDisposable.new(m)
			var r = RefCountDisposable.new(d)
			var window = RefValue.Set(Subject.new())
			
			observer.on_next(GDRx.util.AddRef(window.v, r))
			
			var on_next = func(value):
				window.v.observer().on_next(value)
			
			var on_error = func(error):
				window.v.observer().on_error(error)
				observer.on_error(error)
			
			var on_completed = func():
				window.v.observer().on_completed()
				observer.on_completed()
			
			d.add(
				source.subscribe(on_next, on_error, on_completed,
				scheduler)
			)
			
			var create_window_on_completed = func(__rec_cb : Callable):
				var window_close = closing_mapper.call()
				if not window_close is Observable:
					observer.on_error(GDRx.err.BadMappingException.new())
					return
				
				var on_completed_inner = func():
					window.v.observer().on_completed()
					window.v = Subject.new()
					observer.on_next(GDRx.util.AddRef(window.v, r))
					__rec_cb.bind(__rec_cb).call()
				
				var m1 = SingleAssignmentDisposable.new()
				m.set_disposable(m1)
				m1.set_disposable(window_close.pipe1(GDRx.op.take(1)).subscribe(
					func(__): return, on_error, on_completed_inner, scheduler
				))
			
			create_window_on_completed.bind(create_window_on_completed).call()
			return r
		
		return Observable.new(subscribe)
	
	return window_when
