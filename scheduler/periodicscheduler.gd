extends PeriodicSchedulerBase
class_name PeriodicScheduler


func schedule_periodic(
	period : float,
	action : Callable,
	state = null) -> DisposableBase:
		
		var disp : MultipleAssignmentDisposable = MultipleAssignmentDisposable.new()
		var seconds = period # to_seconds(period)
		
		var periodic : Callable = func(scheduler : SchedulerBase, state = null, periodic_ : Callable = func(__, ___, ____): return) -> Disposable:
			if disp.is_disposed:
				return null
			
			var now : float = scheduler.now()
			
			var state_res = RefValue.Null()
			if not GDRx.try(func():
				state_res.v = action.call(state)
			) \
			.catch("Exception", func(ex):
				disp.dispose()
				GDRx.raise(ex)
			) \
			.end_try_catch(): state = state_res.v 
			
			var time = seconds - (scheduler.now() - now)
			disp.disposable = scheduler.schedule_relative(time, periodic_.bind(periodic_), state)
			
			return null
		periodic = periodic.bind(periodic)
		
		disp.disposable = self.schedule_relative(period, periodic, state)
		return disp
