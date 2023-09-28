extends PeriodicScheduler
class_name SceneTreeTimeoutScheduler
## A scheduler that schedules work via a [SceneTreeTimer].

var _process_always : bool
var _process_in_physics : bool
var _ignore_time_scale : bool

func _init(
	verify_ = null, 
	process_always : bool = false, 
	process_in_physics : bool = false, 
	ignore_time_scale : bool = false):
		if not verify_ == "GDRx":
			push_warning("Warning! Must only instance Scheduler from GDRx singleton!")
		self._process_always = process_always
		self._process_in_physics = process_in_physics
		self._ignore_time_scale = ignore_time_scale

## Returns singleton
static func singleton(
	process_always : bool = false, 
	process_in_physics : bool = false, 
	ignore_time_scale : bool = false) -> SceneTreeTimeoutScheduler:
		return GDRx.SceneTreeTimeoutScheduler_[
			int(process_always) * 0b1 +
			int(process_in_physics) * 0b10 + 
			int(ignore_time_scale) * 0b100
		]

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
	
	var timer : SceneTreeTimer = GDRx.get_tree().create_timer(
			0.0, self._process_always, self._process_in_physics, self._ignore_time_scale)
	timer.connect("timeout", func(): interval.call() ; _cancel_timer(timer))
	
	var dispose = func():
		_cancel_timer(timer)
	
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
	
	var timer = GDRx.get_tree().create_timer(
		seconds, self._process_always, self._process_in_physics, self._ignore_time_scale)
	timer.connect("timeout", func(): interval.call() ; _cancel_timer(timer))
	
	var dispose = func():
		_cancel_timer(timer)
	
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

## Utility function to cancel a timer
func _cancel_timer(timer : SceneTreeTimer):
	for conn in timer.timeout.get_connections():
		timer.timeout.disconnect(conn["callable"])
