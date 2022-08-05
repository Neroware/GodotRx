extends DisposableBase
class_name ScheduledDisposable


var _scheduler : SchedulerBase
var _disposable : SingleAssignmentDisposable
var _lock : RLock

func _init(scheduler : SchedulerBase, disposable : DisposableBase):
	self._scheduler = scheduler
	self._disposable = SingleAssignmentDisposable.new()
	self._disposable.set_disposable(disposable)
	self._lock = RLock.new()

func is_dispose() -> bool:
	return self._disposable._is_disposed

func dispose():
	var action = func(scheduler : SchedulerBase, state):
		self._disposable.dispose()
	self._scheduler.schedule(action)
