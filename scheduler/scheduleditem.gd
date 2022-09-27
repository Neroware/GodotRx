extends Comparable
class_name ScheduledItem

## Represents a scheduled action.

var scheduler : Scheduler
var state
var action : Callable
var duetime : float
var disposable : SingleAssignmentDisposable

func _init(scheduler : Scheduler, duetime : float, state = null, action : Callable = func(scheduler : Scheduler, state = null): return):
	self.scheduler = scheduler
	self.state = state
	self.action = action
	self.duetime = duetime
	self.disposable = SingleAssignmentDisposable.new()

func invoke():
	var ret = self.scheduler.invoke_action(self.action, self.state)
	self.disposable.disposable = ret

## Cancels the work item by disposing the resource returned by
## invoke_core as soon as possible.
func cancel():
	self.disposable.dispose()

func is_cancelled() -> bool:
	return self.disposable.is_disposed

func lt(other : ScheduledItem) -> bool:
	return self.duetime < other.duetime

func gt(other : ScheduledItem) -> bool:
	return self.duetime > other.duetime

func eq(other : ScheduledItem) -> bool:
	return self.duetime == other.duetime
