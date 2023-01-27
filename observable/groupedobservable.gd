extends Observable
class_name GroupedObservable

var key
var underlying_observable : Observable

func _init(
	key_,
	underlying_observable_ : Observable,
	merged_disposable : RefCountDisposable = null):
		super._init()
		self.key = key_
		
		@warning_ignore("shadowed_variable")
		var subscribe = func(
			observer : ObserverBase,
			scheduler : SchedulerBase = null
		) -> DisposableBase:
			return CompositeDisposable.new([
				merged_disposable.disposable if merged_disposable != null else Disposable.new(),
				underlying_observable_.subscribe(observer, GDRx.basic.noop, GDRx.basic.noop, scheduler)
			])
		
		self.underlying_observable = underlying_observable_ if merged_disposable == null else Observable.new(subscribe)

func _subscribe_core(
	observer : ObserverBase,
	scheduler : SchedulerBase = null
) -> DisposableBase:
	return self.underlying_observable.subscribe(observer, GDRx.basic.noop, GDRx.basic.noop, scheduler)
