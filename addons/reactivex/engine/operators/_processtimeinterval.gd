## Returns the amount of process time passed between two items using idle time.
## The emitted item is a [Tuple] containing the real item as first and the 
## time delta as second component.
static func process_time_interval_(initial_time : float = 0.0) -> Callable:
	var process_time_interval = func(source : Observable) -> Observable:
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var _scheduler : SchedulerBase
			_scheduler = scheduler if scheduler != null else CurrentThreadScheduler.singleton()
			
			var dt = RefValue.Set(initial_time)
			
			var on_process = func(delta : float):
				dt.v += delta
			var process_sub : DisposableBase = GDRx.on_idle_frame().subscribe(on_process)
			
			var on_next = func(value):
				var span : float = dt.v
				dt.v = 0.0
				observer.on_next(Tuple.new([value, span]))
			
			var sub : DisposableBase = source.subscribe(
				on_next, observer.on_error, observer.on_completed,
				_scheduler
			)
			
			return CompositeDisposable.new([process_sub, sub])
		
		return Observable.new(subscribe)
	
	return process_time_interval

## Returns the amount of time passed between two items using physics steps.
## The emitted item is a [Tuple] containing the real item as first and the 
## time delta as second component.
static func physics_time_interval_(initial_time : float = 0.0) -> Callable:
	var physics_time_interval = func(source : Observable) -> Observable:
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			var _scheduler : SchedulerBase
			_scheduler = scheduler if scheduler != null else CurrentThreadScheduler.singleton()
			
			var dt = RefValue.Set(initial_time)
			
			var on_process = func(delta : float):
				dt.v += delta
			var process_sub : DisposableBase = GDRx.on_physics_step().subscribe(on_process)
			
			var on_next = func(value):
				var span : float = dt.v
				dt.v = 0.0
				observer.on_next(Tuple.new([value, span]))
			
			var sub : DisposableBase = source.subscribe(
				on_next, observer.on_error, observer.on_completed,
				_scheduler
			)
			
			return CompositeDisposable.new([process_sub, sub])
		
		return Observable.new(subscribe)
	
	return physics_time_interval
