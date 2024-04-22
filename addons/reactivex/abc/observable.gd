class_name ObservableBase

## Interface of an observable stream/subject/signal etc. 
## 
## All communication in GDRx is handled asynchronously via observable data 
## streams, so-called [Observable]s. An [Observer] can subscribe to an 
## [Observable] to receive emitted items sent on the stream.
## Create a new subscription via [method subscribe].

func _init():
	pass

## Creates a new subscription.
## [br]
## There are two ways to invoke this method:
## [br]
## 1.  Subscribes an instance of [ObserverBase].
## [br]
## 2.  Builds a new Observer in accordance to the Observer-Observable-Contract 
## (see [ObserverBase]) from callbacks and subscribes it.
##
## [codeblock]
## var disp = obs.subscribe(observer)
## var disp = obs.subscribe(func(i) ..., func(e): ..., func(): ...)
## [/codeblock]
## [br]
## Since GDScript has no overloading to this date, use [code]subscribe{n}(...)[/code]
## for faster access!
func subscribe(
	_on_next, # Callable or Observer or Object with callbacks
	_on_error : Callable = GDRx.basic.noop,
	_on_completed : Callable = GDRx.basic.noop,
	_scheduler : SchedulerBase = null) -> DisposableBase:
		NotImplementedError.raise()
		return null

## Simulated overload for [code]subscribe[/code]
func subscribe1(obv : ObserverBase = null, _scheduler : SchedulerBase = null) -> DisposableBase:
	return self.subscribe(obv, GDRx.basic.noop, GDRx.basic.noop, _scheduler)
## Simulated overload for [code]subscribe[/code]
func subscribe2(on_next : Callable = GDRx.basic.noop, _scheduler : SchedulerBase = null) -> DisposableBase:
	return self.subscribe(on_next, GDRx.basic.noop, GDRx.basic.noop, _scheduler)
## Simulated overload for [code]subscribe[/code]
func subscribe3(on_error : Callable = GDRx.basic.noop, _scheduler : SchedulerBase = null) -> DisposableBase:
	return self.subscribe(GDRx.basic.noop, on_error, GDRx.basic.noop, _scheduler)
## Simulated overload for [code]subscribe[/code]
func subscribe4(on_completed : Callable = GDRx.basic.noop, _scheduler : SchedulerBase = null) -> DisposableBase:
	return self.subscribe(GDRx.basic.noop, GDRx.basic.noop, on_completed, _scheduler)
## Simulated overload for [code]subscribe[/code]
func subscribe5(on_next : Callable = GDRx.basic.noop, on_completed : Callable = GDRx.basic.noop, _scheduler : SchedulerBase = null) -> DisposableBase:
	return self.subscribe(on_next, GDRx.basic.noop, on_completed, _scheduler)
## Simulated overload for [code]subscribe[/code]
func subscribe6(on_next : Callable = GDRx.basic.noop, on_error : Callable = GDRx.basic.noop, _scheduler : SchedulerBase = null) -> DisposableBase:
	return self.subscribe(on_next, on_error, GDRx.basic.noop, _scheduler)
## Simulated overload for [code]subscribe[/code]
func subscribe7(on_completed : Callable = GDRx.basic.noop, on_error : Callable = GDRx.basic.noop, _scheduler : SchedulerBase = null) -> DisposableBase:
	return self.subscribe(GDRx.basic.noop, on_error, on_completed, _scheduler)
## Simulated overload for [code]subscribe[/code]
func subscribe8(_scheduler : SchedulerBase = null) -> DisposableBase:
	return self.subscribe(GDRx.basic.noop, GDRx.basic.noop, GDRx.basic.noop, _scheduler)
