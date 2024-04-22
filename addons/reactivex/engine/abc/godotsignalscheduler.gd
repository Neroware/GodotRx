extends SchedulerBase
class_name GodotSignalSchedulerBase

## A scheduler for Godot signals
## 
## Schedules actions for repeated future execution when a Godot [Signal] is emitted.

## Schedule a signal callback for repeated execution every time a Godot [Signal]
## is emitted.
func schedule_signal(
	_sig : Signal,
	_n_args : int,
	_action : Callable, 
	_state = null
) -> DisposableBase:
	NotImplementedError.raise()
	return null
