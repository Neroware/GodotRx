class_name SubjectBase

## Interface of a Subject.
## 
## A subject is both an [Observer] and [Observable] in RxPY, 
## meaning it implements both interfaces, however, in GDScript, this is not 
## allowed! So, this interface provides all interface methods from 
## [ObserverBase] and [ObservableBase].

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
func subscribe2(_on_next : Callable = GDRx.basic.noop, _scheduler : SchedulerBase = null) -> DisposableBase:
	return self.subscribe(_on_next, GDRx.basic.noop, GDRx.basic.noop, _scheduler)
## Simulated overload for [code]subscribe[/code]
func subscribe3(_on_error : Callable = GDRx.basic.noop, _scheduler : SchedulerBase = null) -> DisposableBase:
	return self.subscribe(GDRx.basic.noop, _on_error, GDRx.basic.noop, _scheduler)
## Simulated overload for [code]subscribe[/code]
func subscribe4(_on_completed : Callable = GDRx.basic.noop, _scheduler : SchedulerBase = null) -> DisposableBase:
	return self.subscribe(GDRx.basic.noop, GDRx.basic.noop, _on_completed, _scheduler)
## Simulated overload for [code]subscribe[/code]
func subscribe5(_on_next : Callable = GDRx.basic.noop, _on_completed : Callable = GDRx.basic.noop, _scheduler : SchedulerBase = null) -> DisposableBase:
	return self.subscribe(_on_next, GDRx.basic.noop, _on_completed, _scheduler)
## Simulated overload for [code]subscribe[/code]
func subscribe6(_on_next : Callable = GDRx.basic.noop, _on_error : Callable = GDRx.basic.noop, _scheduler : SchedulerBase = null) -> DisposableBase:
	return self.subscribe(_on_next, _on_error, GDRx.basic.noop, _scheduler)
## Simulated overload for [code]subscribe[/code]
func subscribe7(_on_completed : Callable = GDRx.basic.noop, _on_error : Callable = GDRx.basic.noop, _scheduler : SchedulerBase = null) -> DisposableBase:
	return self.subscribe(GDRx.basic.noop, _on_error, _on_completed, _scheduler)
## Simulated overload for [code]subscribe[/code]
func subscribe8(_scheduler : SchedulerBase = null) -> DisposableBase:
	return self.subscribe(GDRx.basic.noop, GDRx.basic.noop, GDRx.basic.noop, _scheduler)

## Called when the [Observable] emits a new item on the stream
func on_next(_i):
	NotImplementedError.raise()

## Called when the [Observable] emits an error on the stream
func on_error(_e):
	NotImplementedError.raise()

## Called when the [Observable] is finished and no more items are sent.
func on_completed():
	NotImplementedError.raise()
