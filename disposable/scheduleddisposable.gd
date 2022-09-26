extends DisposableBase
class_name ScheduledDisposable


var scheduler : SchedulerBase
var disposable : SingleAssignmentDisposable
var lock : RLock

func _init(scheduler : SchedulerBase, disposable : DisposableBase):
	self.scheduler = scheduler
	self.disposable = SingleAssignmentDisposable.new()
	self.disposable.disposable = disposable
	self.lock = RLock.new()
	
	super._init()

var is_disposed:
	get: return self.disposable.is_disposed

func dispose():
	var action = func(scheduler : SchedulerBase, state):
		self.disposable.dispose()
	self.scheduler.schedule(action)
