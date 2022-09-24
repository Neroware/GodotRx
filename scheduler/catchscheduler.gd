extends PeriodicScheduler
class_name CatchScheduler

## A scheduler with exception handling wrapping a [SchedulerBase]

var _scheduler : SchedulerBase
var _handler : Callable
var _recursive_original : SchedulerBase
var _recursive_wrapper : CatchScheduler

## Wraps a scheduler, passed as constructor argument, adding exception
## handling for scheduled actions. The handler should return [b]true[/b] to
## indicate it handled the exception successfully. Falsy return values will
## be taken to indicate that the exception should be escalated (raised by
## this scheduler).
## [br][br]
## [b]Args:[/b] [br]
## [code]scheduler[/code]: The scheduler to be wrapped. [br]
## [code]handler[/code]: Callable to handle exceptions raised by wrapped scheduler.
func _init(scheduler : SchedulerBase, handler : Callable):
	super._init()
	self._scheduler = scheduler
	self._handler = handler
	self._recursive_original = null
	self._recursive_wrapper = null

## Returns the current point in time (timestamp)
func now() -> float:
	return self._scheduler.now()

## Schedule a new action for future execution
func schedule(action : Callable, state = null) -> DisposableBase:
	action = self._wrap(action)
	return self._scheduler.schedule(action, state)

## Schedule a new action for future execution in [code]duetime[/code] seconds.
func schedule_relative(duetime, action : Callable, state = null) -> DisposableBase:
	action = self._wrap(action)
	return self._scheduler.schedule_relative(duetime, action, state)

## Schedule a new action for future execution at [code]duetime[/code].
func schedule_absolute(duetime, action : Callable, state = null) -> DisposableBase:
	action = self._wrap(action)
	return self._scheduler.schedule_absolute(duetime, action, state)

## Schedule a periodic action for repeated execution every time
## [code]period[/code] seconds have expired.
func schedule_periodic(
	period : float,
	action : Callable,
	state = null) -> DisposableBase:
		var schedule_periodic = self._scheduler.get("schedule_periodic")
		if schedule_periodic == null:
			GDRx.raise(GDRx.exc.NotImplementedException.new())
			return Disposable.new()
		
		var disp : SingleAssignmentDisposable = SingleAssignmentDisposable.new()
		var failed : RefValue = RefValue.Set(false)
		
		var periodic = func(state = null):
			if failed.v:
				return null
			var ex = action.call(state)
			if ex is GDRx.exc.Exception:
				failed.v = true
				if not self._handler.call(ex):
					ex.throw()
					return
				disp.dispose()
				return null
			return ex
		
		var scheduler : PeriodicScheduler = self._scheduler
		disp.set_disposable(scheduler.schedule_periodic(period, periodic, state))
		return disp

func _clone(scheduler : SchedulerBase) -> CatchScheduler:
	return CatchScheduler.new(scheduler, self._handler)

func _wrap(action : Callable) -> Callable:
	var parent : CatchScheduler = self
	
	var wrapped_action = func(self_ : SchedulerBase, state = null):
		var ex = action.call(parent._get_recursive_wrapper(self_), state)
		if ex is GDRx.err.Error:
			if not parent._handler.call(ex):
				ex.throw()
		return Disposable.new()
	
	return wrapped_action

func _get_recursive_wrapper(scheduler : SchedulerBase) -> CatchScheduler:
	if self._recursive_wrapper == null or self._recursive_original != scheduler:
		self._recursive_original = scheduler
		var wrapper = self._clone(scheduler)
		wrapper._recursive_original = scheduler
		wrapper._recursive_wrapper = wrapper
		self._recursive_wrapper = wrapper
	
	return self._recursive_wrapper
