extends Subject
class_name ReplaySubject

## Represents an object that is both an observable sequence as well
## as an observer. 
##
## Each notification is broadcasted to all subscribed
## and future observers, subject to buffer trimming policies.

class RemovableDisposable extends DisposableBase:
	var _subject : Subject
	var _observer : Observer
	
	func _init(subject : Subject, observer : Observer):
		self._subject = subject
		self._observer = observer
	
	func dispose():
		self._observer.dispose()
		if not self._subject._is_disposed and self._observer in self._subject._observers:
			self._subject._observers.erase(self._observer)

class QueueItem extends Tuple:
	func _init(interval : float, value):
		super._init([interval, value])
	func interval() -> float:
		return self.at(0)
	func value():
		return self.at(1)

var _buffer_size : int
var _window : float
var _scheduler : SchedulerBase
var _queue : Array

## Initializes a new instance of the ReplaySubject class with
##        the specified buffer size, window and scheduler.
## [br]
##        Args:
## [br]
##            -> buffer_size: [Optional] Maximum element count of the replay
##                buffer.
## [br]
##            -> window [Optional]: Maximum time length of the replay buffer.
## [br]
##            -> scheduler: [Optional] Scheduler the observers are invoked on.
func _init(
	buffer_size : int = GDRx.util.MAX_SIZE,
	window : float = GDRx.util.MAX_SIZE,
	scheduler : SchedulerBase = null
):
	super._init()
	self._buffer_size = buffer_size
	self._scheduler = scheduler if scheduler != null else CurrentThreadScheduler.singleton()
	self._window = window
	self._queue = []

func _subscribe_core(
	__super : Callable,
	observer : ObserverBase,
	scheduler : SchedulerBase = null,
) -> DisposableBase:
	var so = ScheduledObserver.new(self._scheduler, observer)
	var subscription = RemovableDisposable.new(self, so)
	
	self._lock.lock()
	if check_disposed() != false: self._lock.unlock() ; return Disposable.new()
	self._trim(self._scheduler.now())
	self._observers.append(so)
	
	for item in self._queue:
		so.on_next(item.value())
	
	if self._exception != null:
		so.on_error(self._exception)
	elif _OBV._is_stopped:
		so.on_completed()
	self._lock.unlock()
	
	so.ensure_active()
	return subscription

func _trim(now : float):
	while self._queue.size() > self._buffer_size:
		self._queue.pop_front()
	
	while self._queue.size() > 0 and (now - self._queue[0].interval()) > self._window:
		self._queue.pop_front()

## Notifies all subscribed observers with the value.
func _on_next_core(__super : Callable, i):
	self._lock.lock()
	var observers = self._observers.duplicate()
	var now = self._scheduler.now()
	self._queue.append(QueueItem.new(now, i))
	self._trim(now)
	self._lock.unlock()
	
	for observer in observers:
		observer.on_next(i)
	
	for observer in observers:
		var obv : ScheduledObserver = observer
		obv.ensure_active()

## Notifies all subscribed observers with the exception.
func _on_error_core(__super : Callable, e):
	self._lock.lock()
	var observers = self._observers.duplicate()
	self._observers.clear()
	self._exception = e
	var now = self._scheduler.now()
	self._trim(now)
	self._lock.unlock()
	
	for observer in observers:
		observer.on_error(e)
		var obv : ScheduledObserver = observer
		obv.ensure_active()

## Notifies all subscribed observers of the end of the sequence.
func _on_completed(__super : Callable):
	self._lock.lock()
	var observers = self._observers.duplicate()
	self._observers.clear()
	var now = self._scheduler.now()
	self._trim(now)
	self._lock.unlock()
	
	for observer in observers:
		observer.on_completed()
		var obv : ScheduledObserver = observer
		obv.ensure_active()

## Releases all resources used by the current instance of the
## ReplaySubject class and unsubscribe all observers.
func dispose(__super : Callable):
	self._lock.lock()
	self._queue.clear()
	__super.call()
	self._lock.unlock()
