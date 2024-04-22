extends Subject
class_name ReplaySubject

## Represents an object that is both an observable sequence as well
## as an observer. 
## 
## Each notification is broadcasted to all subscribed
## and future observers, subject to buffer trimming policies.

class RemovableDisposable extends DisposableBase:
	var subject : Subject
	var observer : Observer
	
	func _init(subject_ : Subject, observer_ : Observer):
		self.subject = subject_
		self.observer = observer_
	
	func dispose():
		self.observer.dispose()
		if not self.subject.is_disposed and self.observer in self.subject.observers:
			self.subject.observers.erase(self.observer)

class QueueItem extends Tuple:
	func _init(interval_ : float, value_):
		super._init([interval_, value_])
	var interval : float:
		get: return self.at(0)
	var value:
		get: return self.at(1)

var buffer_size : int
var window : float
var scheduler : SchedulerBase
var queue : Array

## Initializes a new instance of the [ReplaySubject] class with
## the specified buffer size, window and scheduler.
## [br]
## [b]Args:[/b]
## [br]
##    [code]buffer_size[/code] [Optional] Maximum element count of the replay
##    buffer.
## [br]
##    [code]window[/code] [Optional] Maximum time length of the replay buffer.
## [br]
##    [code]scheduler[/code] [Optional] Scheduler the observers are invoked on.
func _init(
	buffer_size_ : int = GDRx.util.MAX_SIZE,
	window_ : float = GDRx.util.MAX_SIZE,
	scheduler_ : SchedulerBase = null
):
	super._init()
	self.buffer_size = buffer_size_
	self.scheduler = scheduler_ if scheduler_ != null else CurrentThreadScheduler.singleton()
	self.window = window_
	self.queue = []

func _subscribe_core(
	observer : ObserverBase,
	_scheduler : SchedulerBase = null,
) -> DisposableBase:
	var so = ScheduledObserver.new(self.scheduler, observer)
	var subscription = RemovableDisposable.new(self, so)
	
	if true:
		var __ = LockGuard.new(self.lock)
		if not check_disposed(): return Disposable.new()
		self._trim(self.scheduler.now())
		self.observers.append(so)
		
		for item in self.queue:
			so.on_next(item.value)
		
		if self.error_value != null:
			so.on_error(self.error_value)
		elif self.is_stopped:
			so.on_completed()
	
	so.ensure_active()
	return subscription

func _trim(now : float):
	while self.queue.size() > self.buffer_size:
		self.queue.pop_front()
	
	while self.queue.size() > 0 and (now - self.queue[0].interval) > self.window:
		self.queue.pop_front()

## Notifies all subscribed observers with the value.
func _on_next_core(i):
	var observers_
	if true:
		var __ = LockGuard.new(self.lock)
		observers_ = self.observers.duplicate()
		var now = self.scheduler.now()
		self.queue.append(QueueItem.new(now, i))
		self._trim(now)
	
	for observer in observers_:
		observer.on_next(i)
	
	for observer in observers_:
		var so : ScheduledObserver = observer
		so.ensure_active()

## Notifies all subscribed observers with the error.
func _on_error_core(e):
	var observers_
	if true:
		var __ = LockGuard.new(self.lock)
		observers_ = self.observers.duplicate()
		self.observers.clear()
		self.error_value = e
		var now = self.scheduler.now()
		self._trim(now)
	
	for observer in observers_:
		observer.on_error(e)
		(observer as ScheduledObserver).ensure_active()

## Notifies all subscribed observers of the end of the sequence.
func _on_completed_core():
	var observers_
	if true:
		var __ = LockGuard.new(self.lock)
		observers_ = self.observers.duplicate()
		self.observers.clear()
		var now = self.scheduler.now()
		self._trim(now)
	
	for observer in observers_:
		observer.on_completed()
		(observer as ScheduledObserver).ensure_active()

## Releases all resources used by the current instance of the
## [ReplaySubject] class and unsubscribe all observers.
func dispose():
	var __ = LockGuard.new(self.lock)
	self.queue.clear()
	super.dispose()
