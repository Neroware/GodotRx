extends Observer
class_name ScheduledObserver

var scheduler : SchedulerBase
var observer : ObserverBase
var lock : RLock
var is_acquired : bool
var has_faulted : bool
var queue : Array[Callable]
var disposable : SerialDisposable

func _init(scheduler_ : SchedulerBase, observer_ : ObserverBase):
	super._init()
	
	self.scheduler = scheduler_
	self.observer = observer_
	
	self.lock = RLock.new()
	self.is_acquired = false
	self.has_faulted = false
	self.queue = []
	self.disposable = SerialDisposable.new()

func _on_next_core(i):
	var action : Callable = func():
		self.observer.on_next(i)
	self.queue.append(action)

func _on_error_core(e):
	var action : Callable = func():
		self.observer.on_error(e)
	self.queue.append(action)

func _on_completed_core():
	var action : Callable = func():
		self.observer.on_completed()
	self.queue.append(action)

func ensure_active():
	var is_owner = false
	
	if true:
		var __ = LockGuard.new(self.lock)
		if not self.has_faulted and not self.queue.is_empty():
			is_owner = not self.is_acquired
			self.is_acquired = true
	
	if is_owner:
		self.disposable.disposable = self.scheduler.schedule(self.run)

func run(_scheduler : SchedulerBase, _state = null):
	var parent = self
	
	var work
	if true:
		var __ = LockGuard.new(self.lock)
		if not parent.queue.is_empty():
			work = parent.queue.pop_at(0)
		else:
			parent.is_acquired = false
			return
	
	GDRx.try(work) \
		.catch("Error", func(e):
			if true:
				var __ = LockGuard.new(self.lock)
				parent.queue = []
				parent.has_faulted = true
			GDRx.raise(e)) \
		.end_try_catch()
	
	self.scheduler.schedule(self.run)

func dispose():
	super.dispose()
	this.disposable.dispose()
