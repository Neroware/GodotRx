static func take_with_time_(
	duration : float, scheduler : SchedulerBase = null
) -> Callable:
	var take_with_time = func(source : Observable) -> Observable:
#		"""Takes elements for the specified duration from the start of
#		the observable source sequence.
#
#		Example:
#			>>> var res = take_with_time.call(source)
#
#		This operator accumulates a queue with a length enough to store
#		elements received during the initial duration window. As more
#		elements are received, elements older than the specified
#		duration are taken from the queue and produced on the result
#		sequence. This causes elements to be delayed with duration.
#
#		Args:
#			source: Source observable to take elements from.
#
#		Returns:
#			An observable sequence with the elements taken during the
#			specified duration from the start of the source sequence.
#		"""
		var subscribe = func(
			observer : ObserverBase,
			scheduler_ : SchedulerBase = null
		) -> DisposableBase:
			var _scheduler : SchedulerBase
			if scheduler != null: _scheduler = scheduler
			elif scheduler_ != null: _scheduler = scheduler_
			else: _scheduler = SceneTreeTimeoutScheduler.singleton()
			
			var action = func(_scheduler : SchedulerBase, _state = null):
				observer.on_completed()
			
			var disp = _scheduler.schedule_relative(duration, action)
			return CompositeDisposable.new([
				disp, source.subscribe(observer, GDRx.basic.noop, GDRx.basic.noop, 
				scheduler_)
			])
		
		return Observable.new(subscribe)
	
	return take_with_time
