extends Observable
class_name GroupedObservable

var key
var underlying_observable : Observable

func _init(
	key,
	underlying_observable : Observable,
	merged_disposable : RefCountDisposable = null):
		super._init()
		self.key = key
		
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			return CompositeDisposable.new([
				merged_disposable.disposable if merged_disposable != null else Disposable.new(),
				underlying_observable.subscribe(observer, func(e): return, func(): return, scheduler)
			])
		
		self.underlying_observable = underlying_observable if merged_disposable == null else Observable.new(subscribe)

func _subscribe_core(
	observer : ObserverBase,
	scheduler : SchedulerBase = null
) -> DisposableBase:
	return self.underlying_observable.subscribe(observer, func(e): return, func(): return, scheduler)
