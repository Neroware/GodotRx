extends Scheduler
class_name GodotSignalSchedulerBase


func schedule_signal(
	conn : Node,
	signal_name : String, 
	n_args : int, 
	action : Callable, 
	state = null
) -> DisposableBase:
	push_error("No implementation here!")
	return null
