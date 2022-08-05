static func do_action_(
	on_next = null, on_error = null, on_completed = null
) -> Callable:
	
	var do_action = func(source : Observable) -> Observable:
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var _on_next = func(x):
				if on_next == null:
					observer.on_next(x)
				else:
					on_next.call(x)
					observer.on_next(x)
			
			var _on_error = func(exception):
				if on_error == null:
					observer.on_error(exception)
				else:
					on_error.call(exception)
					observer.on_error(exception)
			
			var _on_completed = func():
				if on_completed == null:
					observer.on_completed()
				else:
					on_completed.call()
					observer.on_completed()
			
			return source.subscribe(
				_on_next, _on_error, _on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return do_action

static func do_(observer : ObserverBase) -> Callable:
	return do_action_(observer.on_next, observer.on_error, observer.on_completed)

static func do_after_next(source : Observable, after_next : Callable) -> Observable:
	var subscribe = func(
		observer : ObserverBase, scheduler : SchedulerBase = null
	) -> DisposableBase:
		var on_next = func(value):
			observer.on_next(value)
			after_next.call(value)
		
		return source.subscribe(on_next, observer.on_error, observer.on_completed)
	
	return Observable.new(subscribe)

static func do_on_subscribe(source : Observable, on_subscribe : Callable) -> Observable:
	var subscribe = func(
		observer : ObserverBase, scheduler : SchedulerBase = null
	) -> DisposableBase:
		on_subscribe.call()
		return source.subscribe(
			observer.on_next,
			observer.on_error,
			observer.on_completed,
			scheduler
		)
	
	return Observable.new(subscribe)

class OnDispose extends DisposableBase:
	var on_dispose : Callable
	func _init(on_dispose : Callable):
		self.on_dispose = on_dispose
	func dispose():
		self.on_dispose.call()

static func do_on_dispose(source : Observable, on_dispose : Callable) -> Observable:
	var subscribe = func(
		observer : ObserverBase, scheduler : SchedulerBase = null
	) -> DisposableBase:
		var composite_disposable = CompositeDisposable.new()
		composite_disposable.add(OnDispose.new(on_dispose))
		var subscription = source.subscribe(
			observer.on_next,
			observer.on_error,
			observer.on_completed,
			scheduler
		)
		composite_disposable.add(subscription)
		return composite_disposable
	
	return Observable.new(subscribe)

static func do_on_terminate(source : Observable, on_terminate : Callable) -> Observable:
	var subscribe = func(
		observer : ObserverBase, scheduler : SchedulerBase = null
	) -> DisposableBase:
		var on_completed = func():
			on_terminate.call()
			observer.on_completed()
		
		var on_error = func(exception):
			on_terminate.call()
			observer.on_error(exception)
		
		return source.subscribe(
			observer.on_next, on_error, on_completed,
			scheduler
		)
	
	return Observable.new(subscribe)

static func do_after_terminate(source : Observable, after_terminate : Callable) -> Observable:
	var subscribe = func(
		observer : ObserverBase, scheduler : SchedulerBase = null
	) -> DisposableBase:
		var on_completed = func():
			observer.on_completed()
			after_terminate.call()
		
		var on_error = func(exception):
			observer.on_error(exception)
			after_terminate.call()
		
		return source.subscribe(
			observer.on_next, on_error, on_completed,
			scheduler
		)
	
	return Observable.new(subscribe)

class FinallyOnDispose extends DisposableBase:
	var finally_action : Callable
	var was_invoked : Array[bool]
	
	func _init(finally_action : Callable, was_invoked : Array[bool]):
		self.finally_action = finally_action
		self.was_invoked = was_invoked
	
	func dispose():
		if not self.was_invoked[0]:
			finally_action.call()
			self.was_invoked[0] = true

static func do_finally(finally_action : Callable) -> Callable:
	var partial = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase, scheduler : SchedulerBase = null
		) -> DisposableBase:
			
			var was_invoked : Array[bool] = [false]
			
			var on_completed = func():
				observer.on_completed()
				if not was_invoked[0]:
					finally_action.call()
					was_invoked[0] = true
			
			var on_error = func(exception):
				observer.on_error(exception)
				if not was_invoked[0]:
					finally_action.call()
					was_invoked[0] = true
			
			var composite_disposable = CompositeDisposable.new()
			composite_disposable.add(FinallyOnDispose.new(finally_action, was_invoked))
			var subscription = source.subscribe(
				observer.on_next, on_error, on_completed,
				scheduler
			)
			composite_disposable.add(subscription)
			
			return composite_disposable
		
		return Observable.new(subscribe)
	
	return partial
