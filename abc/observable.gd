class_name ObservableBase

## Interface of an observable stream/subject/signal etc. 
##
## All communication in GDRx is handled asynchronously via observable data 
## streams, so-called [Observable]s. An [Observer] can subscribe to an 
## [Observable] to receive emitted items sent on the stream.
## Create a new subscription via [method subscribe].

## Creates a new subscription.
## [br]
## There are two ways to invoke this method:
## [br]
## 1.  Subscribes an instance of [ObserverBase].
## [br]
## 2.  Builds a new Observer in accordance to the Observer-Observable-Contract 
## (see [ObserverBase]) from callbacks and subscribes it.
##
## 		[codeblock]
##		var disp = obs.subscribe(observer)
##		var disp = obs.subscribe(func(i) ..., func(e): ..., func(): ...)
##		[/codeblock]
func subscribe(
	_on_next, # Callable or Observer or Object with callbacks
	_on_error : Callable = func(e): return,
	_on_completed : Callable = func(): return,
	_scheduler : SchedulerBase = null) -> DisposableBase:
		GDRx.exc.NotImplementedException.Throw()
		return null

## Shortcut leaving out the [code]on_error[/code] and [code]on_completed[/code]
## contracts.
func subscribe_obv(obv = null, _scheduler : SchedulerBase = null) -> DisposableBase:
	return self.subscribe(obv, func(e):return, func():return, _scheduler)
