extends PeriodicSchedulerBase
class_name PeriodicScheduler


func schedule_periodic(
	period : float,
	action : Callable,
	state = null) -> DisposableBase:
		
		var disp : MultipleAssignmentDisposable = MultipleAssignmentDisposable.new()
		var seconds = period # to_seconds(period)
		
		var periodic : Callable = func(scheduler : SchedulerBase, state = null, periodic_ : Callable = func(__, ___, ____): return) -> Disposable:
			if disp._is_disposed:
				return null
			
			var now : float = scheduler.now()
			
			state = action.call(state)
			if state is GDRx.err.Error:
				disp.dispose()
				push_error(state)
				return
			
			var time = seconds - (scheduler.now() - now)
			disp.set_disposable(scheduler.schedule_relative(time, periodic_.bind(periodic_), state))
			
			return null
		### Weird binding because durng definition, periodic() is still empty...
		periodic = periodic.bind(periodic)
		
		disp.set_disposable(self.schedule_relative(period, periodic, state))
		return disp
