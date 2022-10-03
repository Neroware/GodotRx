extends PeriodicScheduler
class_name SceneTreeTimeoutScheduler
## A scheduler that schedules work via a [SceneTreeTimer].

func _init(verify_ = null):
	if not verify_ == "GDRx":
		push_warning("Warning! Must only instance Scheduler from GDRx singleton!")

## Returns singleton
static func singleton() -> SceneTreeTimeoutScheduler:
	return GDRx.SceneTreeTimeoutScheduler_

## Schedules an action to be executed.
## [br]
##        [b]Args:[/b]
## [br]
##            [code]action[/code] Action to be executed.
## [br]
##            [code]state[/code] [Optional] state to be given to the action function.
## [br][br]
##        [b]Returns:[/b]
## [br]
##            The disposable object used to cancel the scheduled action
##            (best effort).
func schedule(action : Callable, state = null) -> DisposableBase:
	var sad : SingleAssignmentDisposable = SingleAssignmentDisposable.new()
	
	var interval = func():
		sad.disposable = self.invoke_action(action, state)
	
	var timer : SceneTreeTimer = GDRx.get_tree().create_timer(0.0)
	timer.connect("timeout", func(): interval.call() ; _cancel_timer(timer))
	
	var dispose = func():
		_cancel_timer(timer)
	
	return CompositeDisposable.new([sad, Disposable.new(dispose)])

## Schedules an action to be executed after duetime.
## [br]
##        [b]Args:[/b]
## [br]
##            [code]duetime[/code] Relative time after which to execute the action.
## [br]
##            [code]action[/code] Action to be executed.
## [br]
##            [code]state[/code] [Optional] state to be given to the action function.
## [br][br]
##
##        [b]Returns:[/b]
## [br]
##            The disposable object used to cancel the scheduled action
##            (best effort).
func schedule_relative(duetime, action : Callable, state = null) -> DisposableBase:
	var seconds = self.to_seconds(duetime)
	if seconds <= 0.0:
		return self.schedule(action, state)
	
	var sad : SingleAssignmentDisposable = SingleAssignmentDisposable.new()
	
	var interval = func():
		sad.disposable = self.invoke_action(action, state)
	
	var timer = GDRx.get_tree().create_timer(seconds)
	timer.connect("timeout", func(): interval.call() ; _cancel_timer(timer))
	
	var dispose = func():
		_cancel_timer(timer)
	
	return CompositeDisposable.new([sad, Disposable.new(dispose)])

## Schedules an action to be executed at duetime.
## [br]
##        [b]Args:[/b]
## [br]
##            [code]duetime[/code] Absolute time at which to execute the action.
## [br]
##            [code]action[/code] Action to be executed.
## [br]
##            [code]state[/code] [Optional] state to be given to the action function.
## [br][br]
##
##        [b]Returns:[/b]
## [br]
##            The disposable object used to cancel the scheduled action
##            (best effort).
func schedule_absolute(duetime, action : Callable, state = null) -> DisposableBase:
	duetime = self.to_seconds(duetime)
	return self.schedule_relative(duetime - self.now(), action, state)

## Utility function to cancel a timer
func _cancel_timer(timer : SceneTreeTimer):
	for conn in timer.timeout.get_connections():
		timer.timeout.disconnect(conn["callable"])
