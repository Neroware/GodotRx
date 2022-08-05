extends ObservableBase
class_name Observable

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

func pipe0() -> Variant:
	return GDRx.pipe.pipe(self, GDRx.util.Iter([]))

func pipe1(__fn1 : Callable) -> Variant:
	return GDRx.pipe.pipe(self, GDRx.util.Iter([__fn1]))

func pipe2(
	__fn1 : Callable,
	__fn2 : Callable
) -> Variant:
	return GDRx.pipe.pipe(self, GDRx.util.Iter([__fn1, __fn2]))

func pipe3( 
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable
) -> Variant:
	return GDRx.pipe.pipe(self, GDRx.util.Iter([__fn1, __fn2, __fn3]))

func pipe4( 
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable
) -> Variant:
	return GDRx.pipe.pipe(self, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4]))

func pipe5(
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable,
	__fn5 : Callable
) -> Variant:
	return GDRx.pipe.pipe(self, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4, __fn5]))

func pipe6(
	__fn1 : Callable,
	__fn2 : Callable,
	__fn3 : Callable,
	__fn4 : Callable,
	__fn5 : Callable,
	__fn6 : Callable
) -> Variant:
	return GDRx.pipe.pipe(self, GDRx.util.Iter([__fn1, __fn2, __fn3, __fn4, __fn5, __fn6]))

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

func pipea(arr : Array):
	return GDRx.pipe.pipe(self, GDRx.util.Iter(arr))

func pipe(fns : IterableBase) -> Variant:
	return GDRx.pipe.compose(fns).call(self)
