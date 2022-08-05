extends Observer
class_name ScheduledObserver

var _scheduler : SchedulerBase
var _observer : ObserverBase
var _lock : RLock
var _is_acquired : bool
var _has_faulted : bool
var _queue : Array[Callable]
var _disposable : SerialDisposable

func _init(scheduler : SchedulerBase, observer : ObserverBase):
	super._init()
	
	self._scheduler = scheduler
	self._observer = observer
	self._lock = RLock.new()
	self._is_acquired = false
	self._has_faulted = false
	self._queue = []
	self._disposable = SerialDisposable.new()

func _on_next_core(i):
	var action : Callable = func():
		self._observer.on_next(i)
	self._queue.append(action)

func _on_error_core(e):
	var action : Callable = func():
		self._observer.on_error(e)
	self._queue.append(action)

func _on_completed_core():
	var action : Callable = func():
		self._observer.on_completed()
	self._queue.append(action)

func ensure_active():
	var is_owner = false
	
	self._lock.lock()
	if not self._has_faulted and not self._queue.is_empty():
		is_owner = not self._is_acquired
		self._is_acquired = true
	self._lock.unlock()
	
	if is_owner:
		self._disposable.set_disposable(self._scheduler.schedule(self.run))

func run(scheduler : SchedulerBase, state = null):
	var parent = self
	
	self._lock.lock()
	var work
	if not parent._queue.is_empty():
		work = parent._queue.pop_at(0)
	else:
		parent._is_acquired = false
		self._lock.unlock()
		return
	self._lock.unlock()
	
	work.call()
	
	self._scheduler.schedule(self.run)

func dispose():
	super.dispose()
	self._disposable.dispose()
