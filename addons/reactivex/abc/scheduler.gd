class_name SchedulerBase

## A scheduler performs a scheduled action at some future point.
## 
## Schedules actions for execution at some point in the future.
## [br]
## [color=yellow]Important: We will always use time values of type 
## [float] representing seconds![/color]

func _init():
	pass

## Invoke the given action. 
func invoke_action(_action : Callable, _state = null) -> DisposableBase:
	NotImplementedError.raise()
	return null

## Returns the current point in time (timestamp)
func now() -> float:
	NotImplementedError.raise()
	return -1.0

## Schedule a new action for future execution
func schedule(_action : Callable, _state = null) -> DisposableBase:
	NotImplementedError.raise()
	return null

## Schedule a new action for future execution in [code]duetime[/code] seconds.
func schedule_relative(_duetime : float, _action : Callable, _state = null) -> DisposableBase:
	NotImplementedError.raise()
	return null

## Schedule a new action for future execution at [code]duetime[/code].
func schedule_absolute(_duetime : float, _action : Callable, _state = null) -> DisposableBase:
	NotImplementedError.raise()
	return null
