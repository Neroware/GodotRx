extends Scheduler
class_name GodotSignalSchedulerBase

## A scheduler for Godot signals
##
## Schedules actions for repeated future execution when a Godot [Signal] is emitted.

## Schedule a periodic action for repeated execution every time a Godot [Signal]
## is emitted.
func schedule_signal(
	conn : Object,
	signal_name : String, 
	n_args : int, 
	action : Callable, 
	state = null
) -> DisposableBase:
	push_error("No implementation here!")
	return null
