static func do_action_(
	on_next = null, on_error = null, on_completed = null
) -> Callable:
	
	var do_action = func(source : Observable) -> Observable:
#		"""Invokes an action for each element in the observable
#		sequence and invokes an action on graceful or exceptional
#		termination of the observable sequence. This method can be used
#		for debugging, logging, etc. of query behavior by intercepting
#		the message stream to run arbitrary actions for messages on the
#		pipeline.
#
#		Examples:
#			>>> do_action(send).call(observable)
#			>>> do_action(on_next, on_error).call(observable)
#			>>> do_action(on_next, on_error, on_completed).call(observable)
#
#		Args:
#			on_next: [Optional] Action to invoke for each element in
#				the observable sequence.
#			on_error: [Optional] Action to invoke on exceptional
#				termination of the observable sequence.
#			on_completed: [Optional] Action to invoke on graceful
#				termination of the observable sequence.
#
#		Returns:
#			An observable source sequence with the side-effecting
#			behavior applied.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var _on_next = func(x):
				if on_next == null:
					observer.on_next(x)
				else:
					GDRx.try(func():
						on_next.call(x)
					).catch("Error", func(e):
						observer.on_error(e)
					).end_try_catch()
					
					observer.on_next(x)
			
			var _on_error = func(error):
				if on_error == null:
					observer.on_error(error)
				else:
					GDRx.try(func():
						on_error.call(error)
					).catch("Error", func(e):
						observer.on_error(e)
					).end_try_catch()
					
					observer.on_error(error)
			
			var _on_completed = func():
				if on_completed == null:
					observer.on_completed()
				else:
					GDRx.try(func():
						on_completed.call()
					).catch("Error", func(e):
						observer.on_error(e)
					).end_try_catch()
					
					observer.on_completed()
			
			return source.subscribe(
				_on_next, _on_error, _on_completed,
				scheduler
			)
		
		return Observable.new(subscribe)
	
	return do_action

static func do_(observer : ObserverBase) -> Callable:
#	"""Invokes an action for each element in the observable sequence and
#	invokes an action on graceful or exceptional termination of the
#	observable sequence. This method can be used for debugging, logging,
#	etc. of query behavior by intercepting the message stream to run
#	arbitrary actions for messages on the pipeline.
#
#	>>> do(observer)
#
#	Args:
#		observer: Observer
#
#	Returns:
#		An operator function that takes the source observable and
#		returns the source sequence with the side-effecting behavior
#		applied.
#	"""
	return do_action_(observer.on_next, observer.on_error, observer.on_completed)

static func do_after_next(source : Observable, after_next : Callable) -> Observable:
#	"""Invokes an action with each element after it has been emitted downstream.
#	This can be helpful for debugging, logging, and other side effects.
#
#	after_next -- Action to invoke on each element after it has been emitted
#	"""
	var subscribe = func(
		observer : ObserverBase, _scheduler : SchedulerBase = null
	) -> DisposableBase:
		var on_next = func(value):
			GDRx.try(func():
				observer.on_next(value)
				after_next.call(value)
			).catch("Error", func(e):
				observer.on_error(e)
			).end_try_catch()
		
		return source.subscribe(on_next, observer.on_error, observer.on_completed)
	
	return Observable.new(subscribe)

static func do_on_subscribe(source : Observable, on_subscribe : Callable) -> Observable:
#	"""Invokes an action on subscription.
#
#	This can be helpful for debugging, logging, and other side effects
#	on the start of an operation.
#
#	Args:
#		on_subscribe: Action to invoke on subscription
#	"""
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
	func _init(on_dispose_ : Callable):
		super._init()
		self.on_dispose = on_dispose_
	func dispose():
		this.on_dispose.call()

static func do_on_dispose(source : Observable, on_dispose : Callable) -> Observable:
#	"""Invokes an action on disposal.
#
#	 This can be helpful for debugging, logging, and other side effects
#	 on the disposal of an operation.
#
#	Args:
#		on_dispose: Action to invoke on disposal
#	"""
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
#	"""Invokes an action on an on_complete() or on_error() event.
#	 This can be helpful for debugging, logging, and other side effects
#	 when completion or an error terminates an operation.
#
#
#	on_terminate -- Action to invoke when on_complete or throw is called
#	"""
	var subscribe = func(
		observer : ObserverBase, scheduler : SchedulerBase = null
	) -> DisposableBase:
		var on_completed = func():
			if not GDRx.try(func():
				on_terminate.call()
			).catch("Error", func(err):
				observer.on_error(err)
			).end_try_catch():
				observer.on_completed()
		
		var on_error = func(error):
			if not GDRx.try(func():
				on_terminate.call()
			).catch("Error", func(err):
				observer.on_error(err)
			).end_try_catch():
				observer.on_error(error)
		
		return source.subscribe(
			observer.on_next, on_error, on_completed,
			scheduler
		)
	
	return Observable.new(subscribe)

static func do_after_terminate(source : Observable, after_terminate : Callable) -> Observable:
#	"""Invokes an action after an on_complete() or on_error() event.
#	 This can be helpful for debugging, logging, and other side effects
#	 when completion or an error terminates an operation
#
#
#	on_terminate -- Action to invoke after on_complete or throw is called
#	"""
	var subscribe = func(
		observer : ObserverBase, scheduler : SchedulerBase = null
	) -> DisposableBase:
		var on_completed = func():
			observer.on_completed()
			GDRx.try(func():
				after_terminate.call()
			).catch("Error", func(err):
				observer.on_error(err)
			).end_try_catch()
		
		var on_error = func(error):
			observer.on_error(error)
			GDRx.try(func():
				after_terminate.call()
			).catch("Error", func(err):
				observer.on_error(err)
			).end_try_catch()
		
		return source.subscribe(
			observer.on_next, on_error, on_completed,
			scheduler
		)
	
	return Observable.new(subscribe)

class FinallyOnDispose extends DisposableBase:
	var finally_action : Callable
	var was_invoked : Array[bool]
	
	func _init(finally_action_ : Callable, was_invoked_ : Array[bool]):
		super._init()
		self.finally_action = finally_action_
		self.was_invoked = was_invoked_
	
	func dispose():
		if not this.was_invoked[0]:
			finally_action.call()
			this.was_invoked[0] = true

static func do_finally(finally_action : Callable) -> Callable:
#	"""Invokes an action after an on_complete(), on_error(), or disposal
#	event occurs.
#
#	This can be helpful for debugging, logging, and other side effects
#	when completion, an error, or disposal terminates an operation.
#
#	Note this operator will strive to execute the finally_action once,
#	and prevent any redudant calls
#
#	Args:
#		finally_action -- Action to invoke after on_complete, on_error,
#		or disposal is called
#	"""
	var partial = func(source : Observable) -> Observable:
		var subscribe = func(
			observer : ObserverBase, scheduler : SchedulerBase = null
		) -> DisposableBase:
			
			var was_invoked : Array[bool] = [false]
			
			var on_completed = func():
				observer.on_completed()
				GDRx.try(func():
					if not was_invoked[0]:
						finally_action.call()
						was_invoked[0] = true
				) \
				.catch("Error", func(err):
					observer.on_error(err)
				) \
				.end_try_catch()
			
			var on_error = func(error):
				observer.on_error(error)
				GDRx.try(func():
					if not was_invoked[0]:
						finally_action.call()
						was_invoked[0] = true
				) \
				.catch("Error", func(err):
					observer.on_error(err)
				) \
				.end_try_catch()
			
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
