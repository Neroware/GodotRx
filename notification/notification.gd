class_name Notification

var _has_value : bool
var _value
var _kind : String

func _init():
	self._has_value = false
	self._value = null
	self._kind = ""

func accept(
	on_next, # Callable or ObserverBase
	on_error : Callable = func(e): return,
	on_completed : Callable = func(): return):
		if on_next is ObserverBase:
			return self._accept_observer(on_next)
		
		return self._accept(on_next, on_error, on_completed)

func _accept(
	on_next : Callable,
	on_error : Callable = func(e): return,
	on_completed : Callable = func(): return):
		push_error("No implementation here!")

func _accept_observer(observer : ObserverBase):
	push_error("No implementation here!")

func to_observable(scheduler : SchedulerBase = null) -> ObservableBase:
	var _scheduler = scheduler if scheduler != null else ImmediateScheduler.singleton()
	
	var subscribe = func(observer : ObserverBase, scheduler : SchedulerBase = null) -> DisposableBase:
		var action = func(scheduler : SchedulerBase, state):
			self._accept_observer(observer)
			if self._kind == "N":
				observer.on_completed()
			
		var __scheduler = scheduler if scheduler != null else _scheduler
		return __scheduler.schedule(action)
	
	return Observable.new(subscribe)

func equals(other : Notification) -> bool:
	var other_string = "" if other == null else str(other)
	return str(self) == other_string

static func from_notifier(handler : Callable) -> Observer:
	var _on_next = func(value):
		return handler.call(GDRx.OnNext.new(value))
	var _on_error = func(err):
		return handler.call(GDRx.OnError.new(err))
	var _on_completed = func():
		return handler.call(GDRx.OnCompleted.new())
	
	return Observer.new(_on_next, _on_error, _on_completed)
