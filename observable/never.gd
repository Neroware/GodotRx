## Returns a non-terminating observable sequence, which can be used
##    to denote an infinite duration (e.g. when using reactive joins).
## [br][br]
##    [b]Returns:[/b]
## [br]
##        An observable sequence whose observers will never get called.
static func never_() -> Observable:
	
	var subscribe = func(_observer : ObserverBase, _scheduler : SchedulerBase = null) -> DisposableBase:
		return Disposable.new()
	
	return Observable.new(subscribe)
