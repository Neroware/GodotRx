class_name ObservableBase


func subscribe(
	on_next, # Callable or Observer or Object with callbacks
	on_error : Callable = func(e): return,
	on_completed : Callable = func(): return,
	scheduler : SchedulerBase = null) -> DisposableBase:
		push_error("No implementation here!")
		return null
