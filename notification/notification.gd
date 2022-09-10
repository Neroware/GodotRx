class_name Notification

## Represents a notification to an observer.

var _has_value : bool
var _value
var _kind : String

## Default constructor used by derived types.
func _init():
	self._has_value = false
	self._value = null
	self._kind = ""

## Invokes the delegate corresponding to the notification or an
##        observer and returns the produced result.
## [br]
##        [b]Examples:[/b]
##            [codeblock]
##            notification.accept(observer)
##            notification.accept(on_next, on_error, on_completed)
##            [/codeblock]
## [br]
##        [b]Args:[/b]
## [br]
##            [code]on_next[/code] Delegate to invoke for an OnNext notification.
## [br]
##            [code]on_error[/code] [Optional] Delegate to invoke for an OnError
##                notification.
## [br]
##            [code]on_completed[/code] [Optional] Delegate to invoke for an
##                OnCompleted notification.
## [br][br]
##        [b]Returns:[/b]
## [br]
##            Result produced by the observation.
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

## Returns an observable sequence with a single notification,
##        using the specified scheduler, else the immediate scheduler.
## [br]
##        [b]Args:[/b]
## [br]
##            [code]scheduler[/code] [Optional] Scheduler to send out the
##                notification calls on.
## [br][br]
##        [b]Returns:[/b]
## [br]
##            An observable sequence that surfaces the behavior of the
##            notification upon subscription.
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

## Indicates whether this instance and a specified object are equal.
func equals(other : Notification) -> bool:
	var other_string = "" if other == null else str(other)
	return str(self) == other_string

## Creates an observer from a notification callback.
## [br]
##    [b]Args:[/b]
## [br]
##        [code]handler[/code] Action that handles a notification.
## [br][br]
##    [b]Returns:[/b]
## [br]
##        The observer object that invokes the specified handler using
##        a notification corresponding to each message it receives.
static func from_notifier(handler : Callable) -> Observer:
	var _on_next = func(value):
		return handler.call(GDRx.OnNext.new(value))
	var _on_error = func(err):
		return handler.call(GDRx.OnError.new(err))
	var _on_completed = func():
		return handler.call(GDRx.OnCompleted.new())
	
	return Observer.new(_on_next, _on_error, _on_completed)
