extends SubjectBase
class_name Subject

## Represents an object that is both an observable sequence as well
## as an observer. Each notification is broadcasted to all subscribed
## observers.

var is_disposed : bool
var observers : Array[ObserverBase]
var exception

var lock : RLock

var _OBS : _Observable
var _OBV : _Observer


class _Observable extends Observable:
	var _subject : WeakRef
	
	func _init(subject : Subject, lock_ : RLock):
		super._init()
		self._subject = weakref(subject)
		self.lock = lock_
	
	func _subscribe_core(observer : ObserverBase, scheduler : SchedulerBase = null) -> DisposableBase:
		if self._subject.get_ref() == null:
			return Disposable.new()
		var subject : Subject = self._subject.get_ref()
		return subject._subscribe_core(
			func(observer, scheduler) -> DisposableBase: return super._subscribe_core(observer, scheduler), 
			observer, 
			scheduler
		)

class _Observer extends Observer:
	var _subject : WeakRef
	
	func _init(subject : Subject):
		super._init()
		self._subject = weakref(subject)
	
	func on_next(i):
		if self._subject.get_ref() == null:
			return
		var subject = self._subject.get_ref()
		subject.on_next(func(i): super.on_next(i), i)
	
	func _on_next_core(i):
		if self._subject.get_ref() == null:
			return
		var subject = self._subject.get_ref()
		subject._on_next_core(func(i): super._on_next_core(i), i)
	
	func on_error(e):
		if self._subject.get_ref() == null:
			return
		var subject = self._subject.get_ref()
		subject.on_error(func(e): super.on_error(e), e)
	
	func _on_error_core(e):
		if self._subject.get_ref() == null:
			return
		var subject = self._subject.get_ref()
		subject._on_error_core(func(e): super._on_error_core(e), e)
	
	func on_completed():
		if self._subject.get_ref() == null:
			return
		var subject = self._subject.get_ref()
		subject.on_completed(func(): super.on_completed())
	
	func _on_completed_core():
		if self._subject.get_ref() == null:
			return
		var subject = self._subject.get_ref()
		subject._on_completed_core(func(): super._on_completed_core())
	
	func dispose():
		if self._subject.get_ref() == null:
			return
		var subject = self._subject.get_ref()
		subject.dispose(func(): super.dispose())


func _init():
	self.is_disposed = false
	self.observers = []
	self.exception = null
	self.lock = RLock.new()
	
	self._OBS = _Observable.new(self, self.lock)
	self._OBV = _Observer.new(self)

## Return [ObservableBase] behaviour.
func as_observable() -> ObservableBase:
	return self._OBS

## Return [ObserverBase] behaviour.
func as_observer() -> ObserverBase:
	return self._OBV

## Causes an error when already disposed.
func check_disposed():
	if self.is_disposed:
		GDRx.exc.DisposedException.Throw()
		return false
	return true
	

func _subscribe_core(
	__super : Callable,
	observer : ObserverBase,
	_scheduler : SchedulerBase = null,
) -> DisposableBase:
	self.lock.lock()
	if not check_disposed(): self.lock.unlock() ; return
	if not _OBV.is_stopped:
		self.observers.append(observer)
		var _sub = InnerSubscription.new(self, observer)
		self.lock.unlock()
		return _sub
	
	if self.exception != null:
		observer.on_error(self.exception)
	else:
		observer.on_completed()
	self.lock.unlock()
	return Disposable.new()

## Notifies all subscribed observers with the value
## [br]
##        [b]Args:[/b]
## [br]
##            [code]__super[/code] Callback of super-class 
## [br]
##            [code]value[/code] The value to send to all subscribed observers.
func on_next(__super : Callable, i):
	self.lock.lock()
	if not check_disposed(): self.lock.unlock() ; return
	self.lock.unlock()
	__super.call(i)

func _on_next_core(__super : Callable, i):
	self.lock.lock()
	var observers_ : Array = self.observers.duplicate()
	self.lock.unlock()
	
	for ob in observers_:
		ob.on_next(i)

## Notifies all subscribed observers with the exception.
## [br]
##        [b]Args:[/b]
## [br]
##            [code]__super[/code] Callback of super-class 
## [br]
##            [code]error[/code] The exception to send to all subscribed observers.
func on_error(__super : Callable, e):
	self.lock.lock()
	if not check_disposed(): self.lock.unlock() ; return
	self.lock.unlock()
	__super.call(e)

func _on_error_core(__super : Callable, e):
	self.lock.lock()
	var observers_ : Array = self.observers.duplicate()
	self.observers.clear()
	self.exception = e
	self.lock.unlock()
	
	for ob in observers_:
		ob.on_error(e)

## Notifies all subscribed observers of the end of the sequence.
func on_completed(__super : Callable):
	self.lock.lock()
	if not check_disposed(): self.lock.unlock() ; return
	self.lock.unlock()
	__super.call()

func _on_completed_core(__super : Callable):
	self.lock.lock()
	var observers_ : Array = self.observers.duplicate()
	self.observers.clear()
	self.lock.unlock()
	
	for ob in observers_:
		ob.on_completed()

## Unsubscribe all observers and release resources.
func dispose(__super : Callable):
	self.lock.lock()
	self.is_disposed = true
	self.observers = []
	self.exception = []
	__super.call()
	self.lock.unlock()
