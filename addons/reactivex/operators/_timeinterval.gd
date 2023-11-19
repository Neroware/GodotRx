static func time_interval_(
	scheduler : SchedulerBase = null
) -> Callable:
	var time_interval = func(source : Observable) -> Observable:
#		"""Records the time interval between consecutive values in an
#		observable sequence.
#
#			>>> var res = time_interval.call(source)
#
#		Return:
#			An observable sequence with time interval information on
#			values.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler_ : SchedulerBase = null
		) -> DisposableBase:
			var _scheduler : SchedulerBase
			if scheduler != null: _scheduler = scheduler
			elif scheduler_ != null: _scheduler = scheduler_
			else: _scheduler = SceneTreeTimeoutScheduler.singleton()
			
			var last = RefValue.Set(_scheduler.now())
			
			var mapper = func(value) -> Tuple:
				var now = _scheduler.now()
				var span = now - last.v
				last.v = now
				return Tuple.new([value, span])
			
			return source.pipe1(GDRx.op.map(mapper)).subscribe(
				observer, GDRx.basic.noop, GDRx.basic.noop, _scheduler
			)
		
		return Observable.new(subscribe)
	
	return time_interval
