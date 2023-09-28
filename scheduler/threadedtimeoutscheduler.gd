extends PeriodicScheduler
class_name ThreadedTimeoutScheduler
## A scheduler that schedules work via a threaded timer.

func _init(verify_ = null):
	if not verify_ == "GDRx":
		push_warning("Warning! Must only instance Scheduler from GDRx singleton!")

## Returns singleton
static func singleton() -> ThreadedTimeoutScheduler:
	return GDRx.ThreadedTimeoutScheduler_

## Schedules an action to be executed.
## [br]
## [b]Args:[/b]
## [br]
##    [code]action[/code] Action to be executed.
## [br]
##    [code]state[/code] [Optional] state to be given to the action function.
## [br][br]
## [b]Returns:[/b]
## [br]
##    The disposable object used to cancel the scheduled action
##    (best effort).
func schedule(action : Callable, state = null) -> DisposableBase:
	var sad : SingleAssignmentDisposable = SingleAssignmentDisposable.new()
	
	var interval = func():
		sad.disposable = self.invoke_action(action, state)
	
	var disposed = RefValue.Set(false)
	var dispose = func():
		disposed.v = true
	
	var timer_thread = RefValue.Null()
	var timer = func():
		OS.delay_msec(0)
		if not disposed.v:
			interval.call()
		GDRx.THREAD_MANAGER.finish(timer_thread.v)
	
	timer_thread.v = GDRx.concur.default_thread_factory.call(timer)
	timer_thread.v.start()
	
	return CompositeDisposable.new([sad, Disposable.new(dispose)])

## Schedules an action to be executed after duetime.
## [br]
## [b]Args:[/b]
## [br]
##    [code]duetime[/code] Relative time after which to execute the action.
## [br]
##    [code]action[/code] Action to be executed.
## [br]
##    [code]state[/code] [Optional] state to be given to the action function.
## [br][br]
## 
## [b]Returns:[/b]
## [br]
##    The disposable object used to cancel the scheduled action
##    (best effort).
func schedule_relative(duetime, action : Callable, state = null) -> DisposableBase:
	var seconds : float = duetime
	if seconds <= 0.0:
		return self.schedule(action, state)
	
	var sad : SingleAssignmentDisposable = SingleAssignmentDisposable.new()
	
	var interval = func():
		sad.disposable = self.invoke_action(action, state)
	
	var disposed = RefValue.Set(false)
	var dispose = func():
		disposed.v = true
	
	var timer_thread = RefValue.Null()
	var timer = func():
		OS.delay_msec((1000.0 * seconds) as int)
		if not disposed.v:
			interval.call()
		GDRx.THREAD_MANAGER.finish(timer_thread.v)
	
	timer_thread.v = GDRx.concur.default_thread_factory.call(timer)
	timer_thread.v.start()
	
	return CompositeDisposable.new([sad, Disposable.new(dispose)])

## Schedules an action to be executed at duetime.
## [br]
## [b]Args:[/b]
## [br]
##    [code]duetime[/code] Absolute time at which to execute the action.
## [br]
##    [code]action[/code] Action to be executed.
## [br]
##    [code]state[/code] [Optional] state to be given to the action function.
## [br][br]
## 
## [b]Returns:[/b]
## [br]
##    The disposable object used to cancel the scheduled action
##    (best effort).
func schedule_absolute(duetime, action : Callable, state = null) -> DisposableBase:
	return self.schedule_relative(duetime - self.now(), action, state)
