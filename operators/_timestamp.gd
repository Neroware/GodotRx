static func timestamp_(
	scheduler : SchedulerBase = null
) -> Callable:
	var timestamp = func(source : Observable) -> Observable:
#		"""Records the timestamp for each value in an observable sequence.
#
#		Examples:
#			>>> timestamp.call(source)
#
#		Produces objects with attributes `value` and `timestamp`, where
#		value is the original value.
#
#		Args:
#			source: Observable source to timestamp.
#
#		Returns:
#			An observable sequence with timestamp information on values.
#		"""
		var factory = func(scheduler_ : SchedulerBase = null):
			var _scheduler : SchedulerBase
			if scheduler != null: _scheduler = scheduler
			elif scheduler_ != null: _scheduler = scheduler_
			else: _scheduler = SceneTreeTimeoutScheduler.singleton()
			
			var mapper = func(value) -> Tuple:
				return Tuple.new([value, _scheduler.now()])
			
			return source.pipe1(GDRx.op.map(mapper))
		
		return GDRx.obs.defer(factory)
	
	return timestamp
