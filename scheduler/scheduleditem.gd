extends Comparable
class_name ScheduledItem

## Represents a scheduled action.

var _scheduler : Scheduler
var _state
var _action : Callable
var _duetime : float
var _disposable : SingleAssignmentDisposable

func _init(scheduler : Scheduler, duetime : float, state = null, action : Callable = func(scheduler : Scheduler, state = null): return):
	self._scheduler = scheduler
	self._state = state
	self._action = action
	self._duetime = duetime
	self._disposable = SingleAssignmentDisposable.new()

func invoke():
	var ret = self._scheduler.invoke_action(self._action, self._state)
	self._disposable.set_disposable(ret)

## Cancels the work item by disposing the resource returned by
## invoke_core as soon as possible.
func cancel():
	self._disposable.dispose()

func is_cancelled() -> bool:
	return self._disposable._is_disposed

func lt(other : ScheduledItem) -> bool:
	return self._duetime < other._duetime

func gt(other : ScheduledItem) -> bool:
	return self._duetime > other._duetime

func eq(other : ScheduledItem) -> bool:
	return self._duetime == other._duetime
