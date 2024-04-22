extends PeriodicScheduler
class_name CatchScheduler

## A scheduler with error handling wrapping a [SchedulerBase]

var _scheduler : SchedulerBase
var _handler : Callable
var _recursive_original : SchedulerBase
var _recursive_wrapper : CatchScheduler

## Wraps a scheduler, passed as constructor argument, adding error
## handling for scheduled actions. The handler should return [b]true[/b] to
## indicate it handled the error successfully. Falsy return values will
## be taken to indicate that the error should be escalated (raised by
## this scheduler).
## [br][br]
## [b]Args:[/b] [br]
##    [code]scheduler[/code]: The scheduler to be wrapped. [br]
##    [code]handler[/code]: Callable to handle errors raised by wrapped scheduler.
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
			NotImplementedError.raise()
			return Disposable.new()
		
		var disp : SingleAssignmentDisposable = SingleAssignmentDisposable.new()
		var failed : RefValue = RefValue.Set(false)
		
		var periodic = func(state = null):
			if failed.v:
				return null
			var res = RefValue.Null()
			if GDRx.try(func():
				res.v = action.call(state)
			) \
			.catch("Error", func(e):
				failed.v = true
				if not self._handler.call(e):
					GDRx.raise(e)
				disp.dispose()
			) \
			.end_try_catch():
				return null
			return res.v
		
		var scheduler : PeriodicScheduler = self._scheduler
		disp.disposable = scheduler.schedule_periodic(period, periodic, state)
		return disp

func _clone(scheduler : SchedulerBase) -> CatchScheduler:
	return CatchScheduler.new(scheduler, self._handler)

func _wrap(action : Callable) -> Callable:
	var parent : CatchScheduler = self
	
	var wrapped_action = func(self_ : SchedulerBase, state = null):
		var res = RefValue.Null()
		if GDRx.try(func():
			res.v = action.call(parent._get_recursive_wrapper(self_), state)
		) \
		.catch("Error", func(ex):
			if not parent._handler.call(ex):
				GDRx.raise(ex)
		) \
		.end_try_catch():
			return Disposable.new()
		return res.v
	
	return wrapped_action

func _get_recursive_wrapper(scheduler : SchedulerBase) -> CatchScheduler:
	if self._recursive_wrapper == null or self._recursive_original != scheduler:
		self._recursive_original = scheduler
		var wrapper = self._clone(scheduler)
		wrapper._recursive_original = scheduler
		wrapper._recursive_wrapper = wrapper
		self._recursive_wrapper = wrapper
	
	return self._recursive_wrapper
