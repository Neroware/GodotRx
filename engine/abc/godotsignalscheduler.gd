extends Scheduler
class_name GodotSignalSchedulerBase

## A scheduler for Godot signals
##
## Schedules actions for repeated future execution when a Godot [Signal] is emitted.

## Schedule a periodic action for repeated execution every time a Godot [Signal]
## is emitted.
func schedule_signal(
	sig : Signal,
	n_args : int,
	action : Callable, 
	state = null
) -> DisposableBase:
	GDRx.exc.NotImplementedException.Throw()
	return null
