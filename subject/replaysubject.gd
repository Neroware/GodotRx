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
	
	func _init(subject : Subject, observer : Observer):
		self.subject = subject
		self.observer = observer
	
	func dispose():
		self.observer.dispose()
		if not self.subject.is_disposed and self.observer in self.subject.observers:
			self.subject.observers.erase(self.observer)

class QueueItem extends Tuple:
	func _init(interval : float, value):
		super._init([interval, value])
	var interval : float:
		get: return self.at(0)
	var value:
		get: return self.at(1)

var buffer_size : int
var window : float
var scheduler : SchedulerBase
var queue : Array

## Initializes a new instance of the [ReplaySubject] class with
##        the specified buffer size, window and scheduler.
## [br]
##        [b]Args:[/b]
## [br]
##            [code]buffer_size[/code] [Optional] Maximum element count of the replay
##                buffer.
## [br]
##            [code]window[/code] [Optional] Maximum time length of the replay buffer.
## [br]
##            [code]scheduler[/code] [Optional] Scheduler the observers are invoked on.
func _init(
	buffer_size : int = GDRx.util.MAX_SIZE,
	window : float = GDRx.util.MAX_SIZE,
	scheduler : SchedulerBase = null
):
	super._init()
	self.buffer_size = buffer_size
	self.scheduler = scheduler if scheduler != null else CurrentThreadScheduler.singleton()
	self.window = window
	self.queue = []

func _subscribe_core(
	__super : Callable,
	observer : ObserverBase,
	scheduler : SchedulerBase = null,
) -> DisposableBase:
	var so = ScheduledObserver.new(self.scheduler, observer)
	var subscription = RemovableDisposable.new(self, so)
	
	self.lock.lock()
	if not check_disposed(): self.lock.unlock() ; return Disposable.new()
	self._trim(self.scheduler.now())
	self.observers.append(so)
	
	for item in self.queue:
		so.on_next(item.value)
	
	if self.exception != null:
		so.on_error(self.exception)
	elif _OBV.is_stopped:
		so.on_completed()
	self.lock.unlock()
	
	so.ensure_active()
	return subscription

func _trim(now : float):
	while self.queue.size() > self.buffer_size:
		self.queue.pop_front()
	
	while self.queue.size() > 0 and (now - self.queue[0].interval) > self.window:
		self.queue.pop_front()

## Notifies all subscribed observers with the value.
func _on_next_core(__super : Callable, i):
	self.lock.lock()
	var observers = self.observers.duplicate()
	var now = self.scheduler.now()
	self.queue.append(QueueItem.new(now, i))
	self._trim(now)
	self.lock.unlock()
	
	for observer in observers:
		observer.on_next(i)
	
	for observer in observers:
		var obv : ScheduledObserver = observer
		obv.ensure_active()

## Notifies all subscribed observers with the exception.
func _on_error_core(__super : Callable, e):
	self.lock.lock()
	var observers = self.observers.duplicate()
	self.observers.clear()
	self.exception = e
	var now = self.scheduler.now()
	self._trim(now)
	self.lock.unlock()
	
	for observer in observers:
		observer.on_error(e)
		var obv : ScheduledObserver = observer
		obv.ensure_active()

## Notifies all subscribed observers of the end of the sequence.
func _on_completed_core(__super : Callable):
	self.lock.lock()
	var observers = self.observers.duplicate()
	self.observers.clear()
	var now = self.scheduler.now()
	self._trim(now)
	self.lock.unlock()
	
	for observer in observers:
		observer.on_completed()
		var obv : ScheduledObserver = observer
		obv.ensure_active()

## Releases all resources used by the current instance of the
## [ReplaySubject] class and unsubscribe all observers.
func dispose(__super : Callable):
	self.lock.lock()
	self.queue.clear()
	__super.call()
	self.lock.unlock()
