extends Comparable
class_name ScheduledItem

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
