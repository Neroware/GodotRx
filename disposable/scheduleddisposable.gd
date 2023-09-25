extends DisposableBase
class_name ScheduledDisposable


var scheduler : SchedulerBase
var disposable : SingleAssignmentDisposable
var lock : RLock

func _init(scheduler_ : SchedulerBase, disposable_ : DisposableBase):
	self.scheduler = scheduler_
	self.disposable = SingleAssignmentDisposable.new()
	self.disposable.disposable = disposable_
	self.lock = RLock.new()
	
	super._init()

var is_disposed:
	get: return self.disposable.is_disposed

func dispose():
	var action = func(_scheduler : SchedulerBase, _state):
		this.disposable.dispose()
	this.scheduler.schedule(action)

## Links disposable to [Object] lifetime via an [AutoDisposer]
func dispose_with(obj : Object) -> DisposableBase:
	AutoDisposer.add(obj, self)
	return self
