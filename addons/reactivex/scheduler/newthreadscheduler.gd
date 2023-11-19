extends PeriodicScheduler
class_name NewThreadScheduler

## Creates an object that schedules each unit of work on a separate thread.

var thread_factory : Callable

func _init(thread_factory_ : Callable = GDRx.concur.default_thread_factory):
	super._init()
	self.thread_factory = thread_factory_

## Access to global singleton
static func singleton() -> NewThreadScheduler:
	return GDRx.NewThreadScheduler_

## Schedule a new action for future execution
func schedule(action : Callable, state = null) -> DisposableBase:
	var scheduler : EventLoopScheduler = EventLoopScheduler.new(self.thread_factory, true)
	return CompositeDisposable.new([
		scheduler.schedule(action, state),
		Disposable.Cast(scheduler)
	])

## Schedule a new action for future execution in [code]duetime[/code] seconds.
func schedule_relative(duetime, action : Callable, state = null) -> DisposableBase:
	var scheduler : EventLoopScheduler = EventLoopScheduler.new(self.thread_factory, true)
	return CompositeDisposable.new([
		scheduler.schedule_relative(duetime, action, state),
		Disposable.Cast(scheduler)
	])

## Schedule a new action for future execution at [code]duetime[/code].
func schedule_absolute(duetime, action : Callable, state = null) -> DisposableBase:
	var dt : float = duetime
	return self.schedule_relative(dt - self.now(), action, state)

## Schedule a periodic action for repeated execution every time
## [code]period[/code] seconds have expired.
func schedule_periodic(
	period : float,
	action : Callable,
	state = null) -> DisposableBase:
		var seconds : RefValue = RefValue.Set(period)
		var timeout : RefValue = RefValue.Set(seconds.v)
		var _state : RefValue = RefValue.Set(state)
		var disposed : ThreadingEvent = ThreadingEvent.new()
		
		var run = func():
			while true:
				if timeout.v > 0.0:
					disposed.wait(timeout.v)
				if disposed.is_set():
					return
				
				var time : float = self.now()
				
				_state.v = action.call(_state.v)
				
				timeout.v = seconds.v - (self.now() - time)
		
		var thread : StartableBase = self.thread_factory.call(run)
		thread.start()
		
		var dispose = func():
			disposed.set_flag()
			thread.wait_to_finish()
		
		return Disposable.new(dispose)
