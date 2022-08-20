extends ObservableBase
class_name Observable

## Observable base class.

var _lock : RLock
var _subscribe : Callable

func _init(subscribe : Callable = func(observer : ObserverBase, scheduler : SchedulerBase = null) -> DisposableBase: 
	return Disposable.new()):
		self._lock = RLock.new()
		self._subscribe = subscribe

func _subscribe_core(
	observer : ObserverBase,
	scheduler : SchedulerBase = null) -> DisposableBase:
		return self._subscribe.call(observer, scheduler)

## Subscribe an observer to the observable sequence.
## [br]
##        You may subscribe using an observer or callbacks, not both; if the first
##        argument is an instance of [Observer] ([ObserverBase]) or if
##        it has a [Callable] attribute named [code]on_next[/code], then any callback
##        arguments will be ignored.
## [br][br]
##        Examples:
## [br]
##            [codeblock]
##            source.subscribe(observer)
##            source.subscribe(on_next)
##            source.subscribe(on_next, on_error)
##            source.subscribe(on_next, on_error, on_completed)
##            source.subscribe(on_next, on_error, on_completed, scheduler)
##            [/codeblock]
## [br]
##        Args:
## [br]
##            -> observer: The object that is to receive
##                notifications.
## [br]
##            -> on_error: [Optional] Action to invoke upon exceptional termination
##                of the observable sequence.
## [br]
##            -> on_completed: [Optional] Action to invoke upon graceful termination
##                of the observable sequence.
## [br]
##            -> on_next: Action to invoke for each element in the
##                observable sequence.
## [br]
##            -> scheduler: [Optional] The default scheduler to use for this
##                subscription.
## [br][br]
##        Returns:
## [br]
##            Disposable object representing an observer's subscription to
##            the observable sequence.
func subscribe(
	on_next, # Callable or Observer or Object with callbacks
	on_error : Callable = func(e): return,
	on_completed : Callable = func(): return,
	scheduler : SchedulerBase = null) -> DisposableBase:
		
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
			var subscriber = self._subscribe_core(auto_detach_observer, scheduler)
			auto_detach_observer.set_disposable(fix_subscriber.call(subscriber))
		
		var current_thread_scheduler = CurrentThreadScheduler.singleton()
		if current_thread_scheduler.schedule_required():
			current_thread_scheduler.schedule(set_disposable)
		else:
			set_disposable.call()
		
		return Disposable.new(auto_detach_observer.dispose)

## Pipe operator
func pipe0() -> Variant:
	return GDRx.pipe.pipe(self, GDRx.util.Iter([]))

## Pipe operator
func pipe1(__fn1 : Callable) -> Variant:
	return GDRx.pipe.pipe(self, GDRx.util.Iter([__fn1]))

## Pipe operator
func pipe2(
	__fn1 : Callable,
	__fn2 : Callable
) -> Variant:
	return GDRx.pipe.pipe(self, GDRx.util.Iter([__fn1, __fn2]))

## Pipe operator
func pipe3( 
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable
) -> Variant:
	return GDRx.pipe.pipe(self, GDRx.util.Iter([__fn1, __fn2, __fn3]))

## Pipe operator
func pipe4( 
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable
) -> Variant:
	return GDRx.pipe.pipe(self, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4]))

## Pipe operator
func pipe5(
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable,
	__fn5 : Callable
) -> Variant:
	return GDRx.pipe.pipe(self, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4, __fn5]))

## Pipe operator
func pipe6(
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable,
	__fn5 : Callable,
	__fn6 : Callable
) -> Variant:
	return GDRx.pipe.pipe(self, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4, __fn5, __fn6]))

## Pipe operator
func pipe7(
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable,
	__fn5 : Callable,
	__fn6 : Callable,
	__fn7 : Callable
) -> Variant:
	return GDRx.pipe.pipe(self, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4, __fn5, __fn6, __fn7]))

## Pipe operator
func pipe8( 
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable,
	__fn5 : Callable,
	__fn6 : Callable,
	__fn7 : Callable,
	__fn8 : Callable
) -> Variant:
	return GDRx.pipe.pipe(self, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4, __fn5, __fn6, __fn7, __fn8]))

## Pipe operator
func pipe9(
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable,
	__fn5 : Callable,
	__fn6 : Callable,
	__fn7 : Callable,
	__fn8 : Callable,
	__fn9 : Callable
) -> Variant:
	return GDRx.pipe.pipe(self, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4, __fn5, __fn6, __fn7, __fn8, __fn9]))

## Pipe operator taking a list
func pipea(arr : Array):
	return GDRx.pipe.pipe(self, GDRx.util.Iter(arr))

## Compose multiple operators left to right.
## [br]
##        Composes zero or more operators into a functional composition.
##        The operators are composed from left to right. A composition of zero
##        operators gives back the original source.
## [br][br]
##        Examples:
##            [codeblock]
##            source.pipe0() == source
##            source.pipe1(f) == f(source)
##            source.pipe2(g, f) == f(g(source))
##            source.pipe3(h, g, f) == f(g(h(source)))
##            [/codeblock]
## [br]
##        Args:
## [br]
##            operators: Sequence of operators.
## [br][br]
##        Returns:
## [br]
##             The composed observable.
func pipe(fns : IterableBase) -> Variant:
	return GDRx.pipe.compose(fns).call(self)
