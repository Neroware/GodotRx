extends PeriodicScheduler
class_name TimeoutScheduler
## A scheduler that schedules work via a timer

## A list of [SceneTreeTimeoutScheduler]s
##
## A selection of schedulers for each type of timeout (pause mode, process mode 
## & time scale)
class TimeoutType:
	
	var _special_timeouts = {
		"default":SceneTreeTimeoutScheduler.new("GDRx", true, false, false),
		"physics":SceneTreeTimeoutScheduler.new("GDRx", true, true, false),
		"inherit":SceneTreeTimeoutScheduler.new("GDRx", false, false, false),
		"physics_inherit":SceneTreeTimeoutScheduler.new("GDRx", false, true, false),
		"fixed":SceneTreeTimeoutScheduler.new("GDRx", true, false, true),
		"physics_fixed":SceneTreeTimeoutScheduler.new("GDRx", true, true, true),
		"inherit_fixed":SceneTreeTimeoutScheduler.new("GDRx", false, false, true),
		"physics_inherit_fixed":SceneTreeTimeoutScheduler.new("GDRx", false, true, true)
	}
	
	## The default [SceneTreeTimeoutScheduler]: Timeout runs always with process 
	## timestep, [code]Engine.time_scale[/code] is accounted.
	var Default : SceneTreeTimeoutScheduler: 
		get: return self._special_timeouts["default"]
	## Timer runs always with physics timestep, [code]Engine.time_scale[/code] is 
	## accounted.
	var Physics : SceneTreeTimeoutScheduler:
		get: return self._special_timeouts["physics"]
	## Timer runs unless paused, [code]Engine.time_scale[/code] is accounted.
	var Inherit : SceneTreeTimeoutScheduler:
		get: return self._special_timeouts["inherit"]
	## Timer runs unless paused with physics timestep, 
	## [code]Engine.time_scale[/code] is accounted.
	var PhysicsInherit : SceneTreeTimeoutScheduler:
		get: return self._special_timeouts["physics_inherit"]
	## Timer runs always without timescale.
	var Fixed : SceneTreeTimeoutScheduler:
		get: return self._special_timeouts["fixed"]
	## Timer runs always at physics timestep without timescale.
	var PhysicsFixed : SceneTreeTimeoutScheduler:
		get: return self._special_timeouts["physics_fixed"]
	## Timer runs unless paused without timescale.
	var InheritFixed : SceneTreeTimeoutScheduler:
		get: return self._special_timeouts["inherit_fixed"]
	## Timer runs at physics timestep unless paused without timescale.
	var PhysicsInheritFixed : SceneTreeTimeoutScheduler:
		get: return self._special_timeouts["physics_inherit_fixed"]

func _init(verify_ = null):
	if not verify_ == "GDRx":
		push_warning("Warning! Must only instance Scheduler from GDRx singleton!")

## Returns singleton
static func singleton() -> TimeoutScheduler:
	return GDRx.TimeoutScheduler_

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
	if OS.get_thread_caller_id() == GDRx.MAIN_THREAD_ID:
		return SceneTreeTimeoutScheduler.singleton().schedule(action, state)
	return ThreadedTimeoutScheduler.singleton().schedule(action, state)

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
	if OS.get_thread_caller_id() == GDRx.MAIN_THREAD_ID:
		return SceneTreeTimeoutScheduler.singleton().schedule_relative(duetime, action, state)
	return ThreadedTimeoutScheduler.singleton().schedule_relative(duetime, action, state)

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
	if OS.get_thread_caller_id() == GDRx.MAIN_THREAD_ID:
		return SceneTreeTimeoutScheduler.singleton().schedule_absolute(duetime, action, state)
	return ThreadedTimeoutScheduler.singleton().schedule_absolute(duetime, action, state)
