extends Comparable
class_name ScheduledItem

## Represents a scheduled action.

var scheduler : SchedulerBase
var state
var action : Callable
var duetime : float
var disposable : SingleAssignmentDisposable

func _init(scheduler_ : SchedulerBase, duetime_ : float, state_ = null, action_ : Callable = GDRx.basic.noop):
	self.scheduler = scheduler_
	self.state = state_
	self.action = action_
	self.duetime = duetime_
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
