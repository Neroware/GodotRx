class_name SchedulerBase

## A scheduler performs a scheduled action at some future point.
##
## Schedules actions for execution at some point in the future.
## [color=yellow]Important![/color] We will always use DateTime/DeltaTime in Seconds!

## Returns the current point in time (timestamp)
func now() -> float:
	push_error("No implementation here!")
	return -1.0

## Schedule a new action for future execution
func schedule(action : Callable, state = null) -> DisposableBase:
	push_error("No implementation here!")
	return null

## Schedule a new action for future execution in [code]duetime[/code] seconds.
func schedule_relative(duetime, action : Callable, state = null) -> DisposableBase:
	push_error("No implementation here!")
	return null

## Schedule a new action for future execution at [code]duetime[/code].
func schedule_absolute(duetime, action : Callable, state = null) -> DisposableBase:
	push_error("No implementation here!")
	return null

## Converts a timestamp-dictionary to Unix-time
static func to_seconds(datetime : Dictionary) -> float:
	push_error("No implementation here!")
	return -1.0
