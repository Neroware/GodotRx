extends PeriodicSchedulerBase
class_name PeriodicScheduler

const UTC_ZERO : float = Scheduler.UTC_ZERO
const DELTA_ZERO : float = Scheduler.DELTA_ZERO

## Represents a notion of time for this scheduler. Tasks being
## scheduled on a scheduler will adhere to the time denoted by this
## property.
## [br]
## [b]Returns:[/b]
## [br]
##    The scheduler's current time, as a datetime instance.
func now() -> float:
	return GDRx.basic.default_now()

## Invoke the given given action. This is typically called by instances
## of [ScheduledItem].
## [br]
## [b]Args:[/b]
## [br]
##    [code]action[/code] Action to be executed.
## [br]
##    [code]state[/code] [Optional] state to be given to the action function.
## [br][br]
## [b]Returns:[/b]
## [br]
##    The disposable object returned by the action, if any; or a new
##    (no-op) disposable otherwise.
func invoke_action(action : Callable, state = null) -> DisposableBase:
	var ret = action.call(self, state)
	if ret is DisposableBase:
		return ret
	return Disposable.new()

## Schedule a periodic action for repeated execution every time
## [code]period[/code] seconds have expired.
func schedule_periodic(
	period : float,
	action : Callable,
	state = null) -> DisposableBase:
		
		var disp : MultipleAssignmentDisposable = MultipleAssignmentDisposable.new()
		var seconds : float = period
		
		var periodic : Callable = func(scheduler : SchedulerBase, state = null, periodic_ : Callable = func(__, ___, ____): return) -> Disposable:
			if disp.is_disposed:
				return null
			
			var _now : float = scheduler.now()
			
			var state_res = RefValue.Null()
			if not GDRx.try(func():
				state_res.v = action.call(state)
			) \
			.catch("Error", func(err):
				disp.dispose()
				GDRx.raise(err)
			) \
			.end_try_catch(): state = state_res.v 
			
			var time = seconds - (scheduler.now() - _now)
			disp.disposable = scheduler.schedule_relative(time, periodic_.bind(periodic_), state)
			
			return null
		periodic = periodic.bind(periodic)
		
		disp.disposable = self.schedule_relative(period, periodic, state)
		return disp
