extends SubjectBase
class_name Subject

var is_stopped : bool
var lock : RLock

var is_disposed : bool
var observers : Array[ObserverBase]
var exception

var this

## View to the [Observable] behavior of the [Subject]
var obs : Observable:
	get: return self.as_observable()
## View to the [ObserverBase] behavior of the [Subject]
var obv : ObserverBase:
	get: return self.as_observer()

func _init():
	this = self
	this.unreference()
	
	self.is_stopped = false
	self.lock = RLock.new()
	
	self.is_disposed = false
	self.observers = []
	self.exception = null

func check_disposed():
	if self.is_disposed:
		GDRx.exc.DisposedException.Throw()
		return false
	return true

## Subscribe an observer to the observable sequence.
## [br]
## You may subscribe using an observer or callbacks, not both; if the first
## argument is an instance of [Observer] ([ObserverBase]) or if
## it has a [Callable] attribute named [code]on_next[/code], then any callback
## arguments will be ignored.
## [br][br]
## [b]Examples:[/b]
##    [codeblock]
##    source.subscribe(observer)
##    source.subscribe(on_next)
##    source.subscribe(on_next, on_error)
##    source.subscribe(on_next, on_error, on_completed)
##    source.subscribe(on_next, on_error, on_completed, scheduler)
##    [/codeblock]
## [br]
## [b]Args:[/b]
## [br]
##    [code]observer[/code] The object that is to receive
##    notifications.
## [br]
##    [code]on_error[/code] [Optional] Action to invoke upon exceptional termination
##    of the observable sequence.
## [br]
##    [code]on_completed[/code] [Optional] Action to invoke upon graceful termination
##    of the observable sequence.
## [br]
##    [code]on_next[/code] Action to invoke for each element in the
##    observable sequence.
## [br]
##    [code]scheduler[/code] [Optional] The default scheduler to use for this
##    subscription.
## [br][br]
## [b]Returns:[/b]
## [br]
##    Disposable object representing an observer's subscription to
##    the observable sequence.
func subscribe(
	on_next = null, # Callable or Observer or Object with callbacks
	on_error : Callable = GDRx.basic.noop,
	on_completed : Callable = GDRx.basic.noop,
	scheduler : SchedulerBase = null) -> DisposableBase:
		if on_next == null:
			on_next = GDRx.basic.noop
		
		if on_next is ObserverBase:
			var obv : ObserverBase = on_next
			on_next = func(i): obv.on_next.call(i)
			on_error = func(e): obv.on_error.call(e)
			on_completed = func(): obv.on_completed.call()
		elif on_next is Object and on_next.has_method("on_next"):
			var obv : Object = on_next
			if obv.has_method("on_next"):
				on_next = func(i): obv.on_next.call(i)
			if obv.has_method("on_error"):
				on_error = func(e): obv.on_error.call(e)
			if obv.has_method("on_completed"):
				on_completed = func(): obv.on_completed.call()
		
		var auto_detach_observer : AutoDetachObserver = AutoDetachObserver.new(
			on_next, on_error, on_completed
		)
		
		var fix_subscriber = func(subscriber) -> DisposableBase:
			if subscriber is DisposableBase or subscriber.has_method("dispose"):
				return subscriber
			return Disposable.new(subscriber)
		
		var set_disposable = func(__ : SchedulerBase = null, ___ = null):
			var subscriber = RefValue.Null()
			if not GDRx.try(func():
				subscriber.v = self._subscribe_core(auto_detach_observer, scheduler)
			) \
			.catch("Exception", func(ex):
				if not auto_detach_observer.fail(ex):
					GDRx.raise(ex)
			) \
			.end_try_catch():
				auto_detach_observer.subscription = fix_subscriber.call(subscriber.v)
		
		var current_thread_scheduler = CurrentThreadScheduler.singleton()
		if current_thread_scheduler.schedule_required():
			current_thread_scheduler.schedule(set_disposable)
		else:
			set_disposable.call()
		
		return Disposable.new(func(): auto_detach_observer.dispose())

func _subscribe_core(
	observer : ObserverBase,
	scheduler : SchedulerBase = null) -> DisposableBase:
		var __ = LockGuard.new(self.lock)
		self.check_disposed()
		if not self.is_stopped:
			self.observers.append(observer)
			return InnerSubscription.new(self, observer)
		
		if self.exception != null:
			observer.on_error(self.exception)
		else:
			observer.on_completed()
		return Disposable.new()

func on_next(i):
	if true:
		var __ = LockGuard.new(self.lock)
		self.check_disposed()
	if not self.is_stopped:
		self._on_next_core(i)

func _on_next_core(i):
	var observers_ : Array[ObserverBase]
	if true:
		var __ = LockGuard.new(this.lock)
		observers_ = self.observers.duplicate()
	
	for observer in observers_:
		observer.on_next(i)

func on_error(e):
	if true:
		var __ = LockGuard.new(self.lock)
		self.check_disposed()
	if not self.is_stopped:
		self.is_stopped = true
		self._on_error_core(e)

func _on_error_core(e):
	var observers_ : Array[ObserverBase]
	if true:
		var __ = LockGuard.new(this.lock)
		observers_ = self.observers.duplicate()
		self.observers.clear()
		self.exception = e
	
	for observer in observers_:
		observer.on_error(e)

func on_completed():
	if true:
		var __ = LockGuard.new(self.lock)
		self.check_disposed()
	if not self.is_stopped:
		self.is_stopped = true
		self._on_completed_core()

func _on_completed_core():
	var observers_ : Array[ObserverBase]
	if true:
		var __ = LockGuard.new(this.lock)
		observers_ = self.observers.duplicate()
		self.observers.clear()
	
	for observer in observers_:
		observer.on_completed()

func dispose():
	if true:
		var __ = LockGuard.new(this.lock)
		this.is_disposed = true
		this.observers = []
		this.exception = null
		this.is_stopped = true

func fail(e):
	if not self.is_stopped:
		self.is_stopped = true
		self._on_error_core(e)
		return true
	return false

func throw(error : ThrowableBase):
	print_stack()
	GDRx.raise(error)

func to_notifier() -> Callable:
	return func(notifier : Notification): 
		return notifier.accept(self.as_observer())

func as_observer() -> ObserverBase:
	return _Observer.new(self)

func as_observable() -> Observable:
	return _Observable.new(self)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		this.dispose()

## Anonymous [ObserverBase]
class _Observer extends ObserverBase:
	var _subject : Subject
	func _init(subject : Subject):
		self._subject = subject
	## Called when the [Observable] emits a new item on the stream
	func on_next(i):
		self._subject.on_next(i)
	## Called when the [Observable] emits an error on the stream
	func on_error(e):
		self._subject.on_error(e)
	## Called when the [Observable] is finished and no more items are sent.
	func on_completed():
		self._subject.on_completed()

## Anonymous [ObservableBase]
class _Observable extends Observable:
	var _subject : Subject
	func _init(subject : Subject):
		self._subject = subject
	func _subscribe_core(
		observer : ObserverBase, scheduler : SchedulerBase = null) -> DisposableBase:
			return self._subject.subscribe1(observer, scheduler)
