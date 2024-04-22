extends GodotSignalSchedulerBase
class_name GodotSignalScheduler

const UTC_ZERO : float = Scheduler.UTC_ZERO
const DELTA_ZERO : float = Scheduler.DELTA_ZERO

func _init(verify_ = null):
	if not verify_ == "GDRx":
		push_warning("Warning! Must only instance Scheduler from GDRx singleton!")

static func singleton() -> GodotSignalScheduler:
	return GDRx.GodotSignalScheduler_

## Represents a notion of time for this scheduler. Tasks being
## scheduled on a scheduler will adhere to the time denoted by this
## property.
## [br]
## [b]Returns:[/b]
## [br]
##    The scheduler's current time, as a datetime instance.
func now() -> float:
	return GDRx.basic.default_now()

## Invoke the given given action. This is typically called by instances
## of [ScheduledItem].
## [br]
## [b]Args:[/b]
## [br]
##    [code]action[/code] Action to be executed.
## [br]
##    [code]state[/code] [Optional] state to be given to the action function.
## [br][br]
## [b]Returns:[/b]
## [br]
##    The disposable object returned by the action, if any; or a new
##    (no-op) disposable otherwise.
func invoke_action(action : Callable, state = null) -> DisposableBase:
	var ret = action.call(self, state)
	if ret is DisposableBase:
		return ret
	return Disposable.new()

## Schedules an action to be executed when the [Signal] is emitted.
## [br]
## [b]Args:[/b]
## [br]
##    [code]sig[/code] A Godot [Signal] instance to schedule.
## [br]
##    [code]n_args[/code] Number of signal arguments. This is the same number
##                        of parameters for [code]action[/code].
## [br]
##    [code]action[/code] Scheduled callback action for the signal. This is a 
##                        function with [code]n_args[/code] parameters.
## [br]
##    [code]state[/code] [Optional] state to be given to the action function.
## [br][br]
## 
## [b]Returns:[/b]
## [br]
##    The disposable object used to cancel the scheduled action.
func schedule_signal(
	sig : Signal,
	n_args : int, 
	action : Callable, 
	state = null
) -> DisposableBase:
	
	var disp : Disposable = Disposable.new()
	
	var signal_callback : Callable
	match n_args:
		0:
			signal_callback = func():
				var action_ = func(_scheduler : SchedulerBase, _state = null):
					action.call()
				disp = self.invoke_action(action_, state)
		1:
			signal_callback = func(arg1):
				var action_ = func(_scheduler : SchedulerBase, _state = null):
					action.call(arg1)
				disp = self.invoke_action(action_, state)
		2:
			signal_callback = func(arg1, arg2):
				var action_ = func(_scheduler : SchedulerBase, _state = null):
					action.call(arg1, arg2)
				disp = self.invoke_action(action_, state)
		3:
			signal_callback = func(arg1, arg2, arg3):
				var action_ = func(_scheduler : SchedulerBase, _state = null):
					action.call(arg1, arg2, arg3)
				disp = self.invoke_action(action_, state)
		4:
			signal_callback = func(arg1, arg2, arg3, arg4):
				var action_ = func(_scheduler : SchedulerBase, _state = null):
					action.call(arg1, arg2, arg3, arg4)
				disp = self.invoke_action(action_, state)
		5:
			signal_callback = func(arg1, arg2, arg3, arg4, arg5):
				var action_ = func(_scheduler : SchedulerBase, _state = null):
					action.call(arg1, arg2, arg3, arg4, arg5)
				disp = self.invoke_action(action_, state)
		6:
			signal_callback = func(arg1, arg2, arg3, arg4, arg5, arg6):
				var action_ = func(_scheduler : SchedulerBase, _state = null):
					action.call(arg1, arg2, arg3, arg4, arg5, arg6)
				disp = self.invoke_action(action_, state)
		7:
			signal_callback = func(arg1, arg2, arg3, arg4, arg5, arg6, arg7):
				var action_ = func(_scheduler : SchedulerBase, _state = null):
					action.call(arg1, arg2, arg3, arg4, arg5, arg6, arg7)
				disp = self.invoke_action(action_, state)
		8:
			signal_callback = func(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8):
				var action_ = func(_scheduler : SchedulerBase, _state = null):
					action.call(arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
				disp = self.invoke_action(action_, state)
		_:
			GDRx.raise(TooManyArgumentsError.new(
				"Only up to 8 signal parameters supported! Use lists instead!"))
			return null
	
	var obj = instance_from_id(sig.get_object_id())
	
	var dispose = func():
		if obj != null:
			sig.disconnect(signal_callback)
	
	sig.connect(signal_callback)
	
	var cd : CompositeDisposable = CompositeDisposable.new([disp, Disposable.new(dispose)])
	return cd

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
	
	var timer : SceneTreeTimer = GDRx.get_tree().create_timer(0.0)
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
	
	var timer = GDRx.get_tree().create_timer(seconds)
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
